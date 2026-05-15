import base64
import json
import logging
import os
import random
import re
import time
from contextlib import suppress
from datetime import date, datetime, timedelta
from http.cookiejar import CookieJar
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import HTTPCookieProcessor, HTTPSHandler, Request, build_opener
import ssl

import ddddocr
from sqlalchemy import or_
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import TimeoutException

from models import (
    Certificate,
    CertificateHistory,
    Employee,
    ExpiryAlert,
    QueryLog,
    QueryQueue,
    UpdateNotification,
    db,
)

logger = logging.getLogger(__name__)


class QueryService:
    def __init__(self):
        self.ocr = ddddocr.DdddOcr(show_ad=False)
        self.delay_min = int(os.environ.get("QUERY_DELAY_MIN", "2"))
        self.delay_max = int(os.environ.get("QUERY_DELAY_MAX", "5"))
        self.queue_delay_min = float(os.environ.get("QUEUE_DELAY_MIN", str(self.delay_min + 2)))
        self.queue_delay_max = float(os.environ.get("QUEUE_DELAY_MAX", str(self.delay_max + 6)))
        self.queue_batch_pause_min = float(os.environ.get("QUEUE_BATCH_PAUSE_MIN", "8"))
        self.queue_batch_pause_max = float(os.environ.get("QUEUE_BATCH_PAUSE_MAX", "18"))
        self.queue_shuffle_window = max(1, int(os.environ.get("QUEUE_SHUFFLE_WINDOW", "6")))
        self.processing_timeout_minutes = max(
            1, int(os.environ.get("QUEUE_PROCESSING_TIMEOUT_MINUTES", "30"))
        )

    def _create_driver(self, mobile_device=None):
        chrome_options = Options()
        if mobile_device:
            chrome_options.add_experimental_option(
                "mobileEmulation", {"deviceName": mobile_device}
            )
        chrome_options.add_argument("--headless=new")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--window-size=1920,1080")
        chrome_options.add_argument(
            "--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
        )
        chrome_options.add_experimental_option(
            "prefs", {"profile.managed_default_content_settings.images": 2}
        )
        try:
            return webdriver.Chrome(options=chrome_options)
        except Exception as exc:
            logger.error("创建浏览器驱动失败: %s", exc)
            return None

    def _recognize_captcha(self, image_data):
        try:
            text = self.ocr.classification(image_data)
            cleaned = re.sub(r"[^0-9A-Za-z]", "", text or "").strip()
            if len(cleaned) > 4:
                cleaned = cleaned[:4]
            return cleaned
        except Exception as exc:
            logger.error("验证码识别失败: %s", exc)
            return None

    def _sleep(self, low=None, high=None):
        low = self.delay_min if low is None else low
        high = self.delay_max if high is None else high
        time.sleep(random.randint(low, high))

    def _sleep_precise(self, low, high):
        low = float(low)
        high = float(high)
        if high < low:
            low, high = high, low
        duration = random.uniform(low, high)
        time.sleep(duration)
        return round(duration, 2)

    def _queue_sleep(self):
        return self._sleep_precise(self.queue_delay_min, self.queue_delay_max)

    def _batch_pause(self):
        return self._sleep_precise(self.queue_batch_pause_min, self.queue_batch_pause_max)

    def _select_queue_tasks(self, limit):
        tasks = (
            QueryQueue.query.filter(QueryQueue.status.in_(["待处理", "pending"]))
            .order_by(QueryQueue.priority.desc(), QueryQueue.created_at.asc())
            .limit(max(limit, self.queue_shuffle_window))
            .all()
        )
        if not tasks:
            return []

        shuffled = []
        for start in range(0, len(tasks), self.queue_shuffle_window):
            window = tasks[start : start + self.queue_shuffle_window]
            grouped = {}
            for task in window:
                grouped.setdefault(task.priority or 0, []).append(task)
            for same_priority_tasks in grouped.values():
                random.shuffle(same_priority_tasks)
            for priority in sorted(grouped.keys(), reverse=True):
                shuffled.extend(grouped[priority])
        return shuffled[:limit]

    def reclaim_stale_processing_tasks(self, timeout_minutes=None):
        timeout_minutes = (
            self.processing_timeout_minutes if timeout_minutes is None else max(1, int(timeout_minutes))
        )
        threshold = datetime.now() - timedelta(minutes=timeout_minutes)
        stale_tasks = (
            QueryQueue.query.filter(QueryQueue.status.in_(["处理中", "processing"]))
            .filter(
                or_(
                    QueryQueue.started_at.is_(None),
                    QueryQueue.started_at < threshold,
                )
            )
            .order_by(QueryQueue.started_at.asc().nullsfirst(), QueryQueue.id.asc())
            .all()
        )

        recovered = []
        for task in stale_tasks:
            previous_started_at = task.started_at
            elapsed_seconds = None
            if previous_started_at:
                elapsed_seconds = round((datetime.now() - previous_started_at).total_seconds(), 2)

            task.status = "待处理"
            task.started_at = None
            task.processed_at = None
            task.completed_at = None
            task.duration_seconds = None
            task.error_message = (
                f"系统自动回收超时任务，原处理中开始时间: {previous_started_at}"
                if previous_started_at
                else "系统自动回收异常处理中任务，原 started_at 为空"
            )
            db.session.add(
                QueryLog(
                    employee_id=task.employee_id,
                    task_id=task.id,
                    name=task.name,
                    id_card=task.id_card,
                    query_type=normalize_query_type(task.query_type),
                    query_source="系统自动回收",
                    result_count=task.result_count or 0,
                    has_new_data=False,
                    query_status="回收",
                    message=task.error_message,
                )
            )
            recovered.append(
                {
                    "task_id": task.id,
                    "name": task.name,
                    "elapsed_seconds": elapsed_seconds,
                }
            )
        if recovered:
            db.session.commit()
        return recovered

    def _build_samr_mobile_opener(self):
        base = "https://cnse.e-cqs.cn/info-pub"
        ssl_context = ssl._create_unverified_context()
        opener = build_opener(
            HTTPCookieProcessor(CookieJar()),
            HTTPSHandler(context=ssl_context),
        )
        opener.addheaders = [
            (
                "User-Agent",
                "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) "
                "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1",
            ),
            ("Referer", base + "/pubh5"),
            ("Accept", "application/json, text/plain, */*"),
        ]
        return opener

    def _build_mem_api_opener(self):
        base = "https://cx.mem.gov.cn"
        ssl_context = ssl._create_unverified_context()
        opener = build_opener(
            HTTPCookieProcessor(CookieJar()),
            HTTPSHandler(context=ssl_context),
        )
        opener.addheaders = [
            (
                "User-Agent",
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                "(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
            ),
            ("Referer", base + "/special?index=0"),
            ("Accept", "application/json, text/plain, */*"),
        ]
        return opener

    def query_mem_certificate(self, id_number, name=None, allow_browser_fallback=True):
        direct_result = self._query_mem_certificate_direct_api(id_number, name)
        if direct_result.get("success"):
            return direct_result
        if not allow_browser_fallback:
            return direct_result

        driver = None
        try:
            driver = self._create_driver()
            if not driver:
                return {"success": False, "error": "无法创建浏览器驱动"}

            driver.get("https://cx.mem.gov.cn/")
            time.sleep(2)

            try:
                id_input = WebDriverWait(driver, 5).until(
                    EC.presence_of_element_located((By.ID, "idCard"))
                )
            except TimeoutException:
                self._navigate_mem_entry(driver)
                id_input = self._find_first(
                    driver,
                    [
                        (By.ID, "idCard"),
                        (By.NAME, "idCard"),
                        (By.CSS_SELECTOR, "input[placeholder*='身份证']"),
                        (By.CSS_SELECTOR, "input[placeholder*='证件号码']"),
                        (By.CSS_SELECTOR, "input[type='text']"),
                    ],
                    timeout=10,
                )
            id_input.clear()
            id_input.send_keys(id_number)

            for _ in range(3):
                captcha_img = self._find_first(
                    driver,
                    [
                        (By.ID, "captchaImg"),
                        (By.CSS_SELECTOR, "img[id*='captcha']"),
                        (By.CSS_SELECTOR, "img[src*='captcha']"),
                        (By.CSS_SELECTOR, "canvas"),
                    ],
                    timeout=5,
                )
                captcha_code = self._recognize_captcha(captcha_img.screenshot_as_png)
                if not captcha_code or len(captcha_code) < 4:
                    with suppress(Exception):
                        captcha_img.click()
                    time.sleep(1)
                    continue

                captcha_input = self._find_first(
                    driver,
                    [
                        (By.ID, "captcha"),
                        (By.NAME, "captcha"),
                        (By.CSS_SELECTOR, "input[placeholder*='验证码']"),
                    ],
                    timeout=5,
                )
                captcha_input.clear()
                captcha_input.send_keys(captcha_code)
                self._find_clickable(
                    driver,
                    [
                        (By.ID, "queryBtn"),
                        (By.XPATH, '//button[contains(text(),"查询")]'),
                        (By.XPATH, '//span[contains(text(),"查询")]/..'),
                        (By.CSS_SELECTOR, "button"),
                    ],
                    timeout=5,
                ).click()
                time.sleep(2)

                with suppress(Exception):
                    error_msg = driver.find_element(By.CLASS_NAME, "error-message").text
                    if "验证码" in error_msg:
                        continue
                    if "未找到" in error_msg or "不存在" in error_msg:
                        return {"success": True, "data": [], "message": "未找到证书信息"}

                with suppress(Exception):
                    rows = driver.find_element(By.CLASS_NAME, "result-table").find_elements(By.TAG_NAME, "tr")
                    certificates = []
                    for row in rows[1:]:
                        cells = row.find_elements(By.TAG_NAME, "td")
                        if len(cells) >= 6:
                            certificates.append(
                                {
                                    "cert_type": "特种作业操作证",
                                    "cert_category": cells[0].text,
                                    "cert_item": cells[1].text,
                                    "cert_number": cells[2].text,
                                    "issue_authority": cells[3].text,
                                    "valid_from": cells[4].text,
                                    "valid_until": cells[5].text,
                                    "review_date": cells[6].text if len(cells) > 6 else None,
                                }
                            )
                    return {"success": True, "data": certificates}

            return {"success": False, "error": "验证码识别失败"}
        except Exception as exc:
            logger.exception("特种作业查询异常")
            return {"success": False, "error": str(exc)}
        finally:
            if driver:
                driver.quit()

    def _query_mem_certificate_direct_api(self, id_number, name=None):
        base = "https://cx.mem.gov.cn/prod-api"
        opener = self._build_mem_api_opener()
        last_error = "验证码识别失败"

        for _ in range(6):
            try:
                captcha_resp = opener.open(base + "/certsearch/code", timeout=20).read()
                captcha_payload = json.loads(captcha_resp.decode("utf-8", errors="ignore"))
                image_base64 = captcha_payload.get("img") or ""
                uuid = captcha_payload.get("uuid") or ""
                if not image_base64 or not uuid:
                    last_error = captcha_payload.get("msg") or "获取验证码失败"
                    time.sleep(1)
                    continue

                image_bytes = base64.b64decode(image_base64)
                captcha_code = self._recognize_captcha(image_bytes)
                if not captcha_code or len(captcha_code) < 4:
                    continue

                params = {
                    "name": name or "",
                    "searchType": "1",
                    "idcardNum": id_number,
                    "idcardTypeCode": "01",
                    "code": captcha_code,
                    "uuid": uuid,
                    "personTypeCode": "03",
                }
                url = base + "/certsearch/certInfo/netQuery?" + urlencode(params)
                resp = opener.open(Request(url), timeout=20).read()
                payload = json.loads(resp.decode("utf-8", errors="ignore"))

                if payload.get("code") == 200:
                    items = payload.get("data") or []
                    if not items:
                        return {"success": True, "data": [], "message": "未找到证书信息"}
                    return {
                        "success": True,
                        "data": [self._normalize_mem_api_item(item) for item in items],
                        "message": payload.get("msg") or None,
                    }

                message = payload.get("msg") or "查询失败"
                last_error = message
                if "验证码" in message:
                    continue
                if any(token in message for token in ("无数据", "未查询到", "没有查询到")):
                    return {"success": True, "data": [], "message": "未找到证书信息"}
            except HTTPError as exc:
                last_error = f"HTTP {exc.code}"
                if exc.code in {403, 404}:
                    time.sleep(1)
                    continue
            except (URLError, ssl.SSLError, ValueError) as exc:
                last_error = str(exc)
                opener = self._build_mem_api_opener()
                time.sleep(1)
                continue
            except Exception as exc:
                last_error = str(exc)
                logger.warning("MEM direct query failed: %s", exc)
                opener = self._build_mem_api_opener()
                time.sleep(1)
                continue
        return {"success": False, "error": last_error}

    def _normalize_mem_api_item(self, item):
        valid_from = item.get("validBeginDate") or item.get("issueDate")
        valid_until = item.get("validEndDate")
        operation_item = item.get("operItemName") or item.get("jobTypeName") or item.get("allowItem")
        cert_number = item.get("certNum") or item.get("idcardNum") or item.get("cardNo") or ""
        return {
            "cert_type": "特种作业操作证",
            "cert_category": item.get("jobCategoryName") or item.get("jobTypeName") or "特种作业操作证",
            "cert_item": operation_item or "",
            "cert_number": cert_number,
            "issue_authority": item.get("issueOrgName") or "",
            "issue_date": valid_from,
            "valid_from": valid_from,
            "valid_until": valid_until,
            "review_date": item.get("shouldReviewDate"),
            "actual_review_date": item.get("reviewDate"),
            "raw_cert_status": item.get("certStatus"),
        }

    def query_samr_certificate(self, id_number, name=None):
        direct_result = self._query_samr_certificate_mobile_api(id_number)
        if direct_result.get("success"):
            return direct_result

        driver = None
        try:
            driver = self._create_driver(mobile_device="iPhone X")
            if not driver:
                return {"success": False, "error": "无法创建浏览器驱动"}

            driver.get("https://cnse.samr.gov.cn/info-pub/pub")
            time.sleep(3)

            keyword_input = self._find_first(
                driver,
                [
                    (By.ID, "keyword"),
                    (By.CSS_SELECTOR, "input[placeholder*='查询内容']"),
                    (By.CSS_SELECTOR, "input[type='text']"),
                ],
                timeout=10,
            )
            keyword_input.send_keys(id_number)

            for _ in range(4):
                captcha_img = self._find_first(
                    driver,
                    [
                        (By.ID, "imgVCode"),
                        (By.CSS_SELECTOR, "img[id*='Code']"),
                        (By.CSS_SELECTOR, "img[src*='ValiCode']"),
                    ],
                    timeout=5,
                )
                captcha_code = self._recognize_captcha(captcha_img.screenshot_as_png)
                if not captcha_code or len(captcha_code) < 4:
                    with suppress(Exception):
                        captcha_img.click()
                    time.sleep(1)
                    continue

                captcha_input = self._find_first(
                    driver,
                    [
                        (By.ID, "vCode"),
                        (By.NAME, "vCode"),
                        (By.CSS_SELECTOR, "input[placeholder*='验证码']"),
                    ],
                    timeout=5,
                )
                with suppress(Exception):
                    captcha_input.clear()
                captcha_input.send_keys(captcha_code)
                self._find_clickable(
                    driver,
                    [
                        (By.XPATH, '//button[contains(text(),"查询")]'),
                        (By.CSS_SELECTOR, "button.mui-btn-primary"),
                    ],
                    timeout=5,
                ).click()
                time.sleep(3)

                page_text = driver.find_element(By.TAG_NAME, "body").text
                if "请输入验证码" in page_text or "验证码错误" in page_text:
                    with suppress(Exception):
                        captcha_img.click()
                    with suppress(Exception):
                        captcha_input.clear()
                    time.sleep(1)
                    continue
                if "未查询到" in page_text or "无相关数据" in page_text:
                    return {"success": True, "data": [], "message": "未找到证书信息"}
                if "身份证号" in page_text and "持证项目" in page_text:
                    certificates = self._parse_samr_mobile_results(page_text)
                    return {"success": True, "data": certificates}

            return {"success": False, "error": "验证码识别失败"}
        except Exception as exc:
            logger.exception("特种设备查询异常")
            return {"success": False, "error": str(exc)}
        finally:
            if driver:
                driver.quit()

    def _query_samr_certificate_mobile_api(self, id_number):
        base = "https://cnse.e-cqs.cn/info-pub"
        opener = self._build_samr_mobile_opener()
        init_error = None
        for _ in range(3):
            try:
                opener.open(base + "/pubh5", timeout=20).read()
                init_error = None
                break
            except Exception as exc:
                init_error = str(exc)
                opener = self._build_samr_mobile_opener()
                logger.warning("SAMR mobile init failed: %s", exc)
                time.sleep(1)
        if init_error:
            return {"success": False, "error": init_error}

        last_error = "验证码识别失败"
        for _ in range(6):
            try:
                img_req = Request(base + "/pubh5/queryValiCodeImg?r=" + str(int(time.time() * 1000)))
                image_bytes = opener.open(img_req, timeout=20).read()
                captcha_code = self._recognize_captcha(image_bytes)
                if not captcha_code or len(captcha_code) < 4:
                    continue

                query = urlencode({"keyword": id_number, "vCode": captcha_code})
                resp = opener.open(
                    Request(base + "/pubh5/remotePubQuery.json?" + query),
                    timeout=20,
                ).read()
                payload = json.loads(resp.decode("utf-8", errors="ignore"))
                level = payload.get("messageLevel")
                message_text = payload.get("messageText", "")
                data = payload.get("data") or {}
                item = data.get("data") or {}

                if level == "success" and item:
                    return {
                        "success": True,
                        "data": [self._normalize_samr_api_item(item)],
                        "message": message_text or None,
                    }
                if "验证码" in message_text:
                    last_error = message_text
                    continue
                if any(token in message_text for token in ("未查询到", "无相关数据", "未找到")):
                    return {"success": True, "data": [], "message": "未找到证书信息"}
                if message_text:
                    last_error = message_text
                if level == "success" and not item:
                    last_error = "查询结果为空，准备重试"
                    time.sleep(1)
                    continue
            except HTTPError as exc:
                last_error = f"HTTP {exc.code}"
                if exc.code == 403:
                    time.sleep(1)
                    continue
            except (URLError, ssl.SSLError) as exc:
                last_error = str(exc)
                opener = self._build_samr_mobile_opener()
                time.sleep(1)
                continue
            except Exception as exc:
                last_error = str(exc)
                logger.warning("SAMR mobile direct query failed: %s", exc)
                opener = self._build_samr_mobile_opener()
                time.sleep(1)
                continue
        return {"success": False, "error": last_error}

    def _normalize_samr_api_item(self, item):
        valid_from, valid_until = normalize_cnse_dates(item.get("pzrq"), item.get("yxrq"))
        cert_item = item.get("czxm") or item.get("xmmc") or item.get("projectName") or ""
        return {
            "cert_type": "特种设备作业人员证",
            "cert_category": item.get("zslb") or "特种设备作业人员",
            "cert_item": cert_item,
            "cert_number": item.get("zsbh") or item.get("sfzh") or "",
            "issue_authority": item.get("fzjg") or "",
            "issue_date": valid_from,
            "valid_from": valid_from,
            "valid_until": valid_until,
        }

    def _parse_samr_mobile_results(self, page_text):
        lines = [line.strip() for line in page_text.splitlines() if line.strip()]
        records = []
        current = None
        i = 0
        labels = {
            "身份证号",
            "姓名",
            "性别",
            "证书类别",
            "证书编号",
            "发证机关",
            "发证机关所在地",
            "从业种类",
            "取证方式",
            "考核单位",
            "考核日期",
            "持证项目",
            "批准日期",
            "批准单位",
            "有效日期",
            "备注",
        }
        while i < len(lines):
            line = lines[i]
            if line == "身份证号":
                if current:
                    records.append(current)
                current = {"cert_type": "特种设备作业人员证"}
                if i + 1 < len(lines):
                    current["person_id_number"] = lines[i + 1]
                    i += 2
                    continue
            if current and line in labels:
                value = ""
                if i + 1 < len(lines) and lines[i + 1] not in labels:
                    value = lines[i + 1]
                    i += 2
                else:
                    i += 1
                mapped = {
                    "证书类别": "cert_category",
                    "证书编号": "cert_number",
                    "发证机关": "issue_authority",
                    "持证项目": "cert_item",
                    "批准日期": "valid_from",
                    "有效日期": "valid_until",
                    "姓名": "holder_name",
                    "考核单位": "exam_org",
                    "批准单位": "approve_org",
                }.get(line)
                if mapped:
                    current[mapped] = value
                continue
            i += 1
        if current:
            records.append(current)

        normalized = []
        for item in records:
            cert_item = item.get("cert_item", "")
            valid_from, valid_until = normalize_cnse_dates(
                item.get("valid_from"), item.get("valid_until")
            )
            normalized.append(
                {
                    "cert_type": "特种设备作业人员证",
                    "cert_category": item.get("cert_category") or "特种设备作业人员",
                    "cert_item": cert_item,
                    "cert_number": item.get("cert_number") or "",
                    "issue_authority": item.get("issue_authority") or "",
                    "issue_date": valid_from,
                    "valid_from": valid_from,
                    "valid_until": valid_until,
                }
            )
        return normalized

    def _navigate_mem_entry(self, driver):
        with suppress(Exception):
            entry = self._find_clickable(
                driver,
                [
                    (By.XPATH, '//div[contains(@class,"card-text1")][.//*[contains(text(),"特种作业操作证查询")]]//*[contains(text(),"进入查询")]'),
                    (By.XPATH, '(//*[contains(text(),"特种作业操作证查询")])[1]'),
                    (By.CSS_SELECTOR, ".cont-link"),
                ],
                timeout=5,
            )
            driver.execute_script("arguments[0].click();", entry)
            time.sleep(3)

    def _find_first(self, driver, selectors, timeout=10):
        last_error = None
        for by, value in selectors:
            try:
                return WebDriverWait(driver, timeout).until(
                    EC.presence_of_element_located((by, value))
                )
            except Exception as exc:
                last_error = exc
        raise last_error or TimeoutException("无法定位元素")

    def _find_clickable(self, driver, selectors, timeout=10):
        last_error = None
        for by, value in selectors:
            try:
                return WebDriverWait(driver, timeout).until(
                    EC.element_to_be_clickable((by, value))
                )
            except Exception as exc:
                last_error = exc
        raise last_error or TimeoutException("无法定位可点击元素")

    def query_certificate(self, id_number, cert_type, name=None):
        self._sleep()
        query_type = normalize_query_type(cert_type)
        if query_type == "特种作业操作证":
            return self.query_mem_certificate(id_number, name)
        if query_type == "特种设备作业人员证":
            return self.query_samr_certificate(id_number, name)
        if query_type in {"全部", "全部证书", "两者"}:
            samr_result = self.query_samr_certificate(id_number, name)
            mem_policy = os.environ.get("ALL_CERT_QUERY_MEM_POLICY", "always").strip().lower()
            mem_result = {"success": False, "skipped": True, "message": "已跳过特种作业查询"}

            should_query_mem = mem_policy == "always"
            if mem_policy == "never":
                should_query_mem = False
            elif mem_policy == "fallback":
                should_query_mem = not (samr_result.get("success") and samr_result.get("data"))
            elif mem_policy == "smart":
                should_query_mem = not samr_result.get("success")

            if should_query_mem:
                self._sleep(1, 2)
                mem_result = self.query_mem_certificate(id_number, name, allow_browser_fallback=False)

            all_certs = []
            if samr_result.get("success"):
                all_certs.extend(samr_result.get("data", []))
            if mem_result.get("success"):
                all_certs.extend(mem_result.get("data", []))
            success = mem_result.get("success") or samr_result.get("success")
            error = None
            if not success:
                error = "；".join([x for x in [mem_result.get("error"), samr_result.get("error")] if x]) or "查询失败"
            partial = bool(samr_result.get("success") and mem_result.get("skipped"))
            message = None
            if partial:
                message = "已完成特种设备证书查询，特种作业操作证查询已跳过"
            return {
                "success": success,
                "data": all_certs,
                "mem_result": mem_result,
                "samr_result": samr_result,
                "error": error,
                "partial": partial,
                "message": message,
            }
        return {"success": False, "error": "未知的查询类型"}

    def save_certificate(self, employee_id, cert_data, raw_data=None):
        employee = db.session.get(Employee, employee_id)
        if not employee:
            return {"success": False, "error": "员工不存在"}

        parsed = normalize_certificate_payload(cert_data)
        existing = None
        if parsed["cert_number"]:
            existing = Certificate.query.filter_by(
                employee_id=employee_id, cert_number=parsed["cert_number"]
            ).first()

        if existing:
            snapshot = json.dumps(existing.to_dict(), ensure_ascii=False)
            self._apply_certificate(existing, parsed, raw_data)
            db.session.add(
                CertificateHistory(
                    certificate_id=existing.id,
                    event_type="update",
                    snapshot=snapshot,
                )
            )
            created = False
            cert = existing
        else:
            cert = Certificate(employee_id=employee_id, employee_code=employee.employee_code)
            self._apply_certificate(cert, parsed, raw_data)
            db.session.add(cert)
            db.session.flush()
            db.session.add(
                CertificateHistory(
                    certificate_id=cert.id,
                    event_type="create",
                    snapshot=json.dumps(cert.to_dict(), ensure_ascii=False),
                )
            )
            created = True

        self._sync_alert(cert)
        db.session.commit()
        return {"success": True, "certificate": cert.to_dict(), "created": created}

    def _apply_certificate(self, cert, parsed, raw_data):
        if cert.employee and cert.employee.employee_code:
            cert.employee_code = cert.employee.employee_code
        cert.cert_type = parsed["cert_type"]
        cert.certificate_type = parsed["certificate_type"]
        cert.cert_category = parsed["cert_category"]
        cert.operation_item = parsed["operation_item"]
        cert.cert_item = parsed["operation_item"]
        cert.cert_name = parsed["operation_item"] or parsed["certificate_type"]
        cert.cert_number = parsed["cert_number"]
        cert.issuing_authority = parsed["issuing_authority"]
        cert.issue_authority = parsed["issuing_authority"]
        cert.issue_date = parsed["issue_date"]
        cert.valid_from = parsed["valid_from"]
        cert.expiry_date = parsed["valid_until"]
        cert.valid_until = parsed["valid_until"]
        cert.review_date = parsed["review_date"]
        cert.actual_review_date = parsed["actual_review_date"]
        cert.raw_data = json.dumps(raw_data, ensure_ascii=False) if raw_data else cert.raw_data
        cert.status = evaluate_certificate_status(cert)
        cert.sync_alias_fields()

    def _sync_alert(self, cert):
        alert = ExpiryAlert.query.filter_by(certificate_id=cert.id, status="open").first()
        if not cert.valid_until:
            if alert:
                alert.status = "resolved"
                alert.resolved_at = datetime.now()
            return

        days_remaining = (cert.valid_until - datetime.now().date()).days
        if days_remaining > 60:
            if alert:
                alert.status = "resolved"
                alert.resolved_at = datetime.now()
            return

        if not alert:
            alert = ExpiryAlert(
                certificate_id=cert.id,
                alert_type="expiry",
                status="open",
            )
            db.session.add(alert)
        alert.days_remaining = days_remaining
        if days_remaining < 0:
            self._create_notification(
                title="证书已过期",
                content=f"{cert.employee.name} 的 {cert.certificate_type} 已过期 {abs(days_remaining)} 天",
                level="warning",
            )
        elif days_remaining <= 30:
            self._create_notification(
                title="证书即将到期",
                content=f"{cert.employee.name} 的 {cert.certificate_type} 将在 {days_remaining} 天后到期",
                level="info",
            )

    def _create_notification(self, title, content, level="info"):
        exists = UpdateNotification.query.filter_by(
            title=title, content=content, is_read=False
        ).first()
        if not exists:
            db.session.add(
                UpdateNotification(
                    title=title,
                    content=content,
                    notification_type=level,
                )
            )

    def process_task(self, task):
        started_at = datetime.now()
        task.status = "处理中"
        task.started_at = started_at
        db.session.commit()

        employee = task.employee or Employee.query.filter_by(id_number=task.id_card).first()
        if not employee:
            employee = Employee(
                employee_code=task.employee_code,
                name=task.name,
                id_number=task.id_card,
                employment_status="在职",
            )
            db.session.add(employee)
            db.session.commit()
            task.employee_id = employee.id

        result = self.query_certificate(task.id_card, task.query_type, task.name)
        result_count = len(result.get("data", []))
        created_count = 0
        error_message = result.get("error") or result.get("message")
        log_status = "成功"

        if result.get("success"):
            for cert_data in result.get("data", []):
                saved = self.save_certificate(employee.id, cert_data, raw_data=result)
                if saved.get("created"):
                    created_count += 1
            if result_count == 0:
                log_status = "无记录"
                task.status = "无记录"
            else:
                task.status = "已完成"
            task.result_count = result_count
            task.new_cert_count = created_count
            task.error_message = None
        else:
            log_status = "失败"
            task.status = "失败"
            task.error_message = error_message or "查询失败"

        finished_at = datetime.now()
        task.processed_at = finished_at
        task.completed_at = finished_at
        task.duration_seconds = round((finished_at - started_at).total_seconds(), 2)

        db.session.add(
            QueryLog(
                employee_id=employee.id,
                task_id=task.id,
                name=task.name,
                id_card=task.id_card,
                query_type=normalize_query_type(task.query_type),
                query_source="官网自动查询",
                result_count=result_count,
                has_new_data=created_count > 0,
                query_status=log_status,
                message=error_message,
            )
        )
        db.session.commit()
        return {
            "task_id": task.id,
            "status": task.status,
            "result_count": result_count,
            "new_cert_count": created_count,
            "duration_seconds": task.duration_seconds,
            "error": task.error_message,
        }

    def process_queue(self, limit=10):
        recovered_tasks = self.reclaim_stale_processing_tasks()
        tasks = self._select_queue_tasks(limit)
        results = []
        total = len(tasks)
        for index, task in enumerate(tasks, start=1):
            pre_delay = 0.0
            post_delay = 0.0
            batch_pause = 0.0
            try:
                if index > 1:
                    pre_delay = self._queue_sleep()
                task_result = self.process_task(task)
            except Exception as exc:
                logger.exception("处理队列任务失败: task_id=%s", task.id)
                task.status = "失败"
                task.error_message = str(exc)
                task.completed_at = datetime.now()
                task.processed_at = task.completed_at
                db.session.commit()
                task_result = {
                    "task_id": task.id,
                    "status": task.status,
                    "error": task.error_message,
                }

            if index < total:
                post_delay = self._queue_sleep()
                if index % 3 == 0:
                    batch_pause = self._batch_pause()

            task_result.update(
                {
                    "queue_pre_delay_seconds": pre_delay,
                    "queue_post_delay_seconds": post_delay,
                    "queue_batch_pause_seconds": batch_pause,
                    "queue_sequence": index,
                    "queue_total": total,
                }
            )
            results.append(task_result)
        if recovered_tasks:
            logger.warning("自动回收超时处理中任务: %s", recovered_tasks)
        return results


def normalize_query_type(value):
    mapping = {
        "特种作业": "特种作业操作证",
        "特种作业操作证": "特种作业操作证",
        "特种设备": "特种设备作业人员证",
        "特种设备作业人员证": "特种设备作业人员证",
        "两者": "全部证书",
        "全部": "全部证书",
        "全部证书": "全部证书",
    }
    return mapping.get(value or "", value or "全部证书")


def parse_date(date_str):
    if not date_str:
        return None
    if isinstance(date_str, date):
        return date_str
    for fmt in (
        "%Y-%m-%d",
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m",
        "%Y年%m月%d日",
        "%Y/%m/%d",
        "%Y.%m.%d",
    ):
        with suppress(ValueError):
            parsed = datetime.strptime(str(date_str).strip(), fmt)
            return parsed.date()
    return None


def normalize_certificate_payload(cert_data):
    cert_type = cert_data.get("cert_type") or cert_data.get("certificate_type") or "其他证书"
    cert_category = cert_data.get("cert_category") or cert_data.get("certificate_category") or ""
    operation_item = cert_data.get("cert_item") or cert_data.get("operation_item") or cert_category
    certificate_type = cert_data.get("certificate_type") or cert_type
    return {
        "cert_type": cert_type,
        "certificate_type": certificate_type,
        "cert_category": cert_category,
        "operation_item": operation_item,
        "cert_number": cert_data.get("cert_number") or cert_data.get("certificate_number") or "",
        "issuing_authority": cert_data.get("issue_authority")
        or cert_data.get("issuing_authority")
        or "",
        "issue_date": parse_date(cert_data.get("issue_date")),
        "valid_from": parse_date(cert_data.get("valid_from")),
        "valid_until": parse_date(cert_data.get("valid_until") or cert_data.get("expiry_date")),
        "review_date": parse_date(cert_data.get("review_date")),
        "actual_review_date": parse_date(cert_data.get("actual_review_date")),
    }


def evaluate_certificate_status(cert):
    today = datetime.now().date()
    if cert.review_date and not cert.actual_review_date and cert.review_date <= today:
        return "待复审"
    if cert.valid_until and cert.valid_until < today:
        return "已过期"
    if cert.valid_until and (cert.valid_until - today).days <= 30:
        return "即将到期"
    return "有效"


def normalize_cnse_dates(valid_from, valid_until):
    def normalize(value):
        if not value:
            return None
        value = str(value).strip()
        if len(value) == 7 and value.count("-") == 1:
            return f"{value}-01"
        return value

    return normalize(valid_from), normalize(valid_until)
