#!/usr/bin/env python3
"""
证照查询 → 钉钉AI表格 自动化脚本
读取「人员清单」→ 调用两个政府网站查询 → 结果写入「证照查询结果」表
"""

import base64
import json
import logging
import random
import re
import ssl
import sys
import time
from datetime import datetime
from http.cookiejar import CookieJar
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import HTTPCookieProcessor, HTTPSHandler, Request, build_opener

import requests

# ── MCP 网关配置 ────────────────────────────────────────────────────────────────
MCP_BASE_URL = (
    "https://mcp-gw.dingtalk.com/server/"
    "85952ec7084922fe711f6281d0c02b9ebd856f8cee6f07f54e9e696eb0c77e00"
    "?key=07d3d5d85edf549ba136b230b39dbe93"
)
MCP_SERVER_ID = "19dbf5a445d"

# ── 钉钉AI表格配置 ─────────────────────────────────────────────────────────────
BASE_ID   = "4lgGw3P8vRYZZ0rvHpeXmdGp85daZ90D"
SRC_TABLE = "OtCAXux"   # 人员清单
RES_TABLE = "TIt20gf"   # 证照查询结果

# 人员清单字段
F_NAME    = "06z0IUP"
F_IDCARD  = "eCCUX5m"
F_STATUS  = "M2JeiAF"

# 证照查询结果字段
F_R_NAME    = "1P4gh25"
F_R_IDCARD  = "ZsEEJev"
F_R_TYPE    = "I9iOJBp"
F_R_NUM     = "70iCsOJ"
F_R_ITEM    = "34sAUAa"
F_R_AUTH    = "I0aDKYi"
F_R_VALID   = "d2c7L0D"
F_R_EXPIRE  = "sKry9I5"
F_R_REVIEW  = "dsPZ0C6"
F_R_STATUS  = "qY9kLpr"
F_R_REMARK  = "BZmUNTS"

# 单选项ID（证照类型）
OPT_SPECIAL  = "CCnuMR9jP4"   # 特种作业操作证
OPT_WELDER   = "4E2Xhv6fUz"   # 焊工证
OPT_NONE     = "19GTaJpL2f"   # 未查到

# 单选项ID（查询状态）
STATUS_OK     = "vWi3yzlHIJ"  # 一致
STATUS_MISM   = "RXgtF9bh3K"  # 不一致
STATUS_NOTFND = "0pgdwrqXkY"  # 未查到
STATUS_ERROR  = "DyBmXJpjex"  # 查询异常

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)
logger = logging.getLogger(__name__)

# ── MCP 工具调用 ───────────────────────────────────────────────────────────────

def mcp_call(tool_name: str, arguments: dict) -> dict:
    import urllib.request
    import urllib.parse

    payload = {
        "jsonrpc": "2.0",
        "method": "tools/call",
        "params": {
            "name": tool_name,
            "arguments": arguments,
        },
        "id": 1,
    }
    body = json.dumps(payload).encode("utf-8")
    req = Request(
        f"{MCP_BASE_URL}/tools/{tool_name}",
        data=body,
        headers={
            "Content-Type": "application/json",
            "Accept": "application/json, text/event-stream",
        },
    )
    try:
        resp = urllib.request.urlopen(req, timeout=30)
        raw = resp.read().decode("utf-8", errors="ignore")
        # SSE 格式：data: {...}\n\n
        for line in raw.strip().split("\n"):
            if line.startswith("data:"):
                data = json.loads(line[5:].strip())
                if "result" in data:
                    return data["result"]
        return {}
    except Exception as exc:
        logger.error("MCP 调用失败 [%s]: %s", tool_name, exc)
        return {}


def query_employees() -> list:
    """读取人员清单中待查询的记录"""
    result = mcp_call("query_records", {
        "baseId": BASE_ID,
        "tableId": SRC_TABLE,
        "fieldIds": [F_NAME, F_IDCARD, F_STATUS],
        "limit": 30,
    })
    records = result.get("data", {}).get("records", [])
    logger.info("读取到 %d 条人员记录", len(records))
    return records


def update_employee_status(record_id: str, status_id: str):
    """更新人员清单查询状态"""
    mcp_call("update_records", {
        "baseId": BASE_ID,
        "tableId": SRC_TABLE,
        "records": [{
            "recordId": record_id,
            "cells": {F_STATUS: status_id},
        }],
    })


def create_result_records(rows: list):
    """批量写入证照查询结果"""
    if not rows:
        return
    records = []
    for r in rows:
        cells = {
            F_R_NAME:   r.get("name", ""),
            F_R_IDCARD: r.get("idcard", ""),
            F_R_TYPE:   {"id": r.get("type_id", "")},
            F_R_NUM:    r.get("cert_num", ""),
            F_R_ITEM:   r.get("item", ""),
            F_R_AUTH:   r.get("authority", ""),
            F_R_VALID:  r.get("valid_from", ""),
            F_R_EXPIRE: r.get("valid_until", ""),
            F_R_REVIEW: r.get("review_date", ""),
            F_R_STATUS: {"id": r.get("status_id", "")},
            F_R_REMARK: r.get("remark", ""),
        }
        records.append({"cells": cells})
    mcp_call("create_records", {
        "baseId": BASE_ID,
        "tableId": RES_TABLE,
        "records": records,
    })
    logger.info("写入 %d 条证照结果", len(rows))


# ── 证照查询 ───────────────────────────────────────────────────────────────────

def _build_mem_opener():
    """构造查询特种作业证的 HTTP opener"""
    ssl_ctx = ssl._create_unverified_context()
    opener = build_opener(
        HTTPCookieProcessor(CookieJar()),
        HTTPSHandler(context=ssl_ctx),
    )
    opener.addheaders = [
        ("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
         "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"),
        ("Referer", "https://cx.mem.gov.cn/special?index=0"),
        ("Accept", "application/json, text/plain, */*"),
    ]
    return opener


def _recognize_captcha(image_bytes: bytes) -> str:
    """用 ddddocr 识别验证码"""
    try:
        import ddddocr
        ocr = ddddocr.DdddOcr(show_ad=False)
        result = ocr.classification(image_bytes)
        cleaned = re.sub(r"[^0-9A-Za-z]", "", result or "").strip()
        return cleaned[:4] if len(cleaned) > 4 else cleaned
    except Exception as exc:
        logger.warning("验证码识别失败: %s", exc)
        return ""


def query_special_cert(idcard: str, name: str = "") -> list:
    """查询特种作业操作证（cx.mem.gov.cn）"""
    opener = _build_mem_opener()
    base = "https://cx.mem.gov.cn/prod-api"
    last_err = "验证码识别失败"

    for attempt in range(6):
        try:
            # 1. 获取验证码
            captcha_resp = opener.open(f"{base}/certsearch/code", timeout=20).read()
            captcha_data = json.loads(captcha_resp.decode("utf-8", errors="ignore"))
            img_b64 = captcha_data.get("img", "")
            uuid     = captcha_data.get("uuid", "")
            if not img_b64 or not uuid:
                last_err = captcha_data.get("msg", "获取验证码失败")
                time.sleep(1)
                continue

            # 2. 识别验证码
            img_bytes = base64.b64decode(img_b64)
            code = _recognize_captcha(img_bytes)
            if not code or len(code) < 4:
                last_err = "验证码识别为空"
                time.sleep(1)
                continue

            # 3. 提交查询
            params = {
                "name": name or "",
                "searchType": "1",
                "idcardNum": idcard,
                "idcardTypeCode": "01",
                "code": code,
                "uuid": uuid,
                "personTypeCode": "03",
            }
            url = f"{base}/certsearch/certInfo/netQuery?" + urlencode(params)
            resp = opener.open(Request(url), timeout=20).read()
            payload = json.loads(resp.decode("utf-8", errors="ignore"))

            if payload.get("code") == 200:
                items = payload.get("data") or []
                if not items:
                    return []
                results = []
                for item in items:
                    results.append({
                        "cert_type": "特种作业操作证",
                        "cert_num": item.get("certNumber", ""),
                        "item": item.get("certItem", ""),
                        "authority": item.get("issueAuth", ""),
                        "valid_from": item.get("validFrom", ""),
                        "valid_until": item.get("validUntil", ""),
                        "review_date": item.get("reviewDate", ""),
                    })
                return results

            msg = payload.get("msg", "查询失败")
            last_err = msg
            if "验证码" in msg:
                continue
            if any(t in msg for t in ("无数据", "未查询到", "没有查询到")):
                return []
        except HTTPError as exc:
            last_err = f"HTTP {exc.code}"
            if exc.code in (403, 404):
                time.sleep(1)
                continue
        except (URLError, ssl.SSLError) as exc:
            last_err = str(exc)
            opener = _build_mem_opener()
            time.sleep(1)
            continue
        except Exception as exc:
            last_err = str(exc)
            logger.warning("特种作业查询异常（尝试 %d）: %s", attempt + 1, exc)
            opener = _build_mem_opener()
            time.sleep(1)
            continue

    logger.warning("特种作业证查询最终失败 [%s]: %s", idcard, last_err)
    return None  # None 表示查询异常


def query_welder_cert(idcard: str, name: str = "") -> list:
    """查询焊工证（cnse.e-cqs.cn）"""
    ssl_ctx = ssl._create_unverified_context()
    opener = build_opener(
        HTTPCookieProcessor(CookieJar()),
        HTTPSHandler(context=ssl_ctx),
    )
    opener.addheaders = [
        ("User-Agent", "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) "
         "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"),
        ("Referer", "https://cnse.e-cqs.cn/info-pub/pubh5"),
        ("Accept", "application/json, text/plain, */*"),
    ]

    base = "https://cnse.e-cqs.cn/info-pub"
    last_err = "验证码识别失败"

    for attempt in range(6):
        try:
            # 1. 获取验证码
            captcha_resp = opener.open(base + "/randcode?_" + str(int(time.time() * 1000)),
                                       timeout=20).read()
            captcha_data = json.loads(captcha_resp.decode("utf-8", errors="ignore"))
            img_b64 = captcha_data.get("img", "")
            if not img_b64:
                last_err = captcha_data.get("msg", "获取验证码失败")
                time.sleep(1)
                continue

            # 2. 识别验证码
            img_bytes = base64.b64decode(img_b64)
            code = _recognize_captcha(img_bytes)
            if not code or len(code) < 4:
                last_err = "验证码识别为空"
                time.sleep(1)
                continue

            # 3. 提交查询
            params = urlencode({
                "keyword": idcard,
                "vCode": code,
                "name": name or "",
                "pageNum": 1,
                "pageSize": 10,
            })
            url = base + "/query?" + params
            resp = opener.open(Request(url), timeout=20).read()
            payload = json.loads(resp.decode("utf-8", errors="ignore"))

            if payload.get("success"):
                items = payload.get("data", [])
                if not items:
                    return []
                results = []
                for item in items:
                    results.append({
                        "cert_type": "焊工证",
                        "cert_num": item.get("certNo", ""),
                        "item": item.get("weldType", ""),
                        "authority": item.get("issueOrgan", ""),
                        "valid_from": item.get("effectiveDate", ""),
                        "valid_until": item.get("expireDate", ""),
                        "review_date": "",
                    })
                return results

            msg = payload.get("message", "查询失败")
            last_err = msg
            if "验证码" in msg:
                continue
            if any(t in msg for t in ("无数据", "未查到", "没有")):
                return []
        except HTTPError as exc:
            last_err = f"HTTP {exc.code}"
            if exc.code in (403, 404):
                time.sleep(1)
                continue
        except (URLError, ssl.SSLError) as exc:
            last_err = str(exc)
            ssl_ctx2 = ssl._create_unverified_context()
            opener = build_opener(
                HTTPCookieProcessor(CookieJar()),
                HTTPSHandler(context=ssl_ctx2),
            )
            opener.addheaders = list(opener.addheaders)
            time.sleep(1)
            continue
        except Exception as exc:
            last_err = str(exc)
            logger.warning("焊工证查询异常（尝试 %d）: %s", attempt + 1, exc)
            time.sleep(1)
            continue

    logger.warning("焊工证查询最终失败 [%s]: %s", idcard, last_err)
    return None


def parse_date(date_str: str) -> str:
    """标准化日期格式为 YYYY-MM-DD"""
    if not date_str:
        return ""
    # 去掉时间部分
    date_str = date_str.strip().split(" ")[0]
    # 尝试匹配 YYYY-MM-DD 或 YYYY/MM/DD
    m = re.search(r"(\d{4})[/-](\d{1,2})[/-](\d{1,2})", date_str)
    if m:
        return f"{m.group(1)}-{int(m.group(2)):02d}-{int(m.group(3)):02d}"
    return date_str


# ── 主流程 ─────────────────────────────────────────────────────────────────────

def main():
    logger.info("=== 证照查询 → 钉钉AI表格 启动 ===")

    # 读取人员清单
    employees = query_employees()
    if not employees:
        logger.info("人员清单为空，退出")
        return

    total = len(employees)
    for idx, emp in enumerate(employees, 1):
        name    = emp["cells"].get(F_NAME, {}).get("value", "")
        idcard  = emp["cells"].get(F_IDCARD, {}).get("value", "")
        rec_id  = emp["recordId"]
        status_cell = emp["cells"].get(F_STATUS, {})
        current_status = status_cell.get("value", {}).get("name", "") if isinstance(status_cell.get("value"), dict) else ""

        if current_status == "已完成":
            logger.info("[%d/%d] 跳过已查询: %s %s", idx, total, name, idcard)
            continue

        logger.info("[%d/%d] 查询: %s %s", idx, total, name, idcard)

        # 更新状态为"查询中"
        update_employee_status(rec_id, "oQvPGkVCw5")  # 查询中

        result_rows = []

        # 1. 查询特种作业操作证
        special = query_special_cert(idcard, name)
        delay = random.uniform(2, 5)
        time.sleep(delay)

        if special is None:
            # 查询异常
            result_rows.append({
                "name": name,
                "idcard": idcard,
                "type_id": OPT_SPECIAL,
                "cert_num": "",
                "item": "",
                "authority": "",
                "valid_from": "",
                "valid_until": "",
                "review_date": "",
                "status_id": STATUS_ERROR,
                "remark": "特种作业证查询异常",
            })
        elif not special:
            result_rows.append({
                "name": name,
                "idcard": idcard,
                "type_id": OPT_SPECIAL,
                "cert_num": "",
                "item": "",
                "authority": "",
                "valid_from": "",
                "valid_until": "",
                "review_date": "",
                "status_id": STATUS_NOTFND,
                "remark": "特种作业操作证未查到",
            })
        else:
            for cert in special:
                result_rows.append({
                    "name": name,
                    "idcard": idcard,
                    "type_id": OPT_SPECIAL,
                    "cert_num": cert.get("cert_num", ""),
                    "item": cert.get("item", ""),
                    "authority": cert.get("authority", ""),
                    "valid_from": parse_date(cert.get("valid_from", "")),
                    "valid_until": parse_date(cert.get("valid_until", "")),
                    "review_date": parse_date(cert.get("review_date", "")),
                    "status_id": STATUS_OK,
                    "remark": "",
                })

        # 2. 查询焊工证
        welder = query_welder_cert(idcard, name)
        delay = random.uniform(2, 5)
        time.sleep(delay)

        if welder is None:
            result_rows.append({
                "name": name,
                "idcard": idcard,
                "type_id": OPT_WELDER,
                "cert_num": "",
                "item": "",
                "authority": "",
                "valid_from": "",
                "valid_until": "",
                "review_date": "",
                "status_id": STATUS_ERROR,
                "remark": "焊工证查询异常",
            })
        elif not welder:
            result_rows.append({
                "name": name,
                "idcard": idcard,
                "type_id": OPT_WELDER,
                "cert_num": "",
                "item": "",
                "authority": "",
                "valid_from": "",
                "valid_until": "",
                "review_date": "",
                "status_id": STATUS_NOTFND,
                "remark": "焊工证未查到",
            })
        else:
            for cert in welder:
                result_rows.append({
                    "name": name,
                    "idcard": idcard,
                    "type_id": OPT_WELDER,
                    "cert_num": cert.get("cert_num", ""),
                    "item": cert.get("item", ""),
                    "authority": cert.get("authority", ""),
                    "valid_from": parse_date(cert.get("valid_from", "")),
                    "valid_until": parse_date(cert.get("valid_until", "")),
                    "review_date": "",
                    "status_id": STATUS_OK,
                    "remark": "",
                })

        # 写入结果
        if result_rows:
            create_result_records(result_rows)

        # 更新状态为"已完成"
        update_employee_status(rec_id, "ZVkzT7TL5H")  # 已完成

        logger.info("完成: %s %s → 写入 %d 条", name, idcard, len(result_rows))

    logger.info("=== 全部完成 ===")


if __name__ == "__main__":
    main()
