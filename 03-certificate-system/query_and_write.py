#!/usr/bin/env python3
"""
证照查询自动化脚本
读取人员清单 → 调用政府网站查询 → 结果写入证照查询结果表
"""
import base64
import json
import logging
import random
import re
import subprocess
import sys
import time
import ssl
from datetime import datetime
from http.cookiejar import CookieJar
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import HTTPCookieProcessor, HTTPSHandler, Request, build_opener

import ddddocr
import requests

# ── 配置 ─────────────────────────────────────────────────────────────────────
BASE_ID = "4lgGw3P8vRYZZ0rvHpeXmdGp85daZ90D"
SRC_TABLE = "XIcHzqY"   # 人员清单（实际有数据的表）
RES_TABLE = "TIt20gf"    # 证照查询结果

# 证照查询结果字段 → fieldId
FIELD_NAME   = "1P4gh25"
FIELD_IDCARD = "ZsEEJev"
FIELD_TYPE   = "I9iOJBp"
FIELD_NUM    = "70iCsOJ"
FIELD_ITEM   = "34sAUAa"
FIELD_AUTH   = "I0aDKYi"
FIELD_VALID  = "d2c7L0D"
FIELD_EXPIRE = "sKry9I5"
FIELD_REVIEW = "dsPZ0C6"
FIELD_STATUS = "qY9kLpr"
FIELD_REMARK = "BZmUNTS"

# 证照类型 → 选项名称（singleSelect 用名称字符串写入）
TYPE_SPECIAL = "特种作业操作证"
TYPE_WELDER  = "焊工证"
TYPE_NONE    = "未查到"

# 查询状态 → 选项名称
STATUS_OK     = "一致"
STATUS_DIFF   = "不一致"
STATUS_NOTFND = "未查到"
STATUS_ERROR  = "查询异常"

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)


# ── MCP 调用 ──────────────────────────────────────────────────────────────────
def mcp_call(tool: str, arguments: dict) -> dict:
    """通过 dws CLI 调用 AI 表格 API（已内置鉴权）"""
    args_json = json.dumps(arguments, ensure_ascii=False)
    cmd = [
        "dws", "aitable", "record", "create",
        "--base-id", BASE_ID,
        "--table-id", RES_TABLE,
        "--records", f'[{{"cells":{{}}}}]',  # 先测试连通性
        "--format", "json"
    ]
    # 用 process 方式检测连通性
    result = subprocess.run(
        ["dws", "aitable", "record", "query",
         "--base-id", BASE_ID, "--table-id", RES_TABLE,
         "--limit", "1", "--format", "json"],
        capture_output=True, text=True, timeout=30
    )
    if result.returncode == 0:
        data = json.loads(result.stdout)
        if data.get("status") == "success":
            logger.info("✅ AI表格 MCP 连通正常")
            return {"ok": True}
    logger.error(f"❌ AI表格 MCP 失败: {result.stderr[:200]}")
    return {"ok": False}


def dws_query_records(table_id: str, limit: int = 100, cursor: str = "") -> list:
    """用 dws CLI 分页读取记录"""
    cmd = [
        "dws", "aitable", "record", "query",
        "--base-id", BASE_ID, "--table-id", table_id,
        "--limit", str(limit), "--format", "json"
    ]
    if cursor:
        cmd.extend(["--cursor", cursor])
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
    if result.returncode != 0:
        logger.error(f"dws query failed: {result.stderr}")
        return []
    data = json.loads(result.stdout)
    return data.get("data", {}).get("records", []), data.get("data", {}).get("nextCursor", "")


def dws_write_record(cells: dict) -> bool:
    """用 dws CLI 单条写入记录"""
    # 构建 cells JSON，dws 期望 --records '[{"cells":{...}}]'
    cells_json = json.dumps(cells, ensure_ascii=False)
    record_str = f'[{{"cells":{cells_json}}}]'
    cmd = [
        "dws", "aitable", "record", "create",
        "--base-id", BASE_ID, "--table-id", RES_TABLE,
        "--records", record_str, "--format", "json"
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
    if result.returncode == 0:
        return True
    logger.error(f"写入失败: {result.stderr[:300]}")
    return False


# ── 证照查询 ─────────────────────────────────────────────────────────────────
class CertQueryService:
    """调用两个政府网站查询证照"""

    def __init__(self):
        self._mem_opener = self._build_mem_opener()
        self._weld_opener = self._build_weld_opener()
        self._ocr = ddddocr.DdddOcr(show_ad=False)
        logger.info("证照查询服务初始化完成")

    def _build_mem_opener(self):
        """构建特种作业证查询的 opener（处理验证码）"""
        cj = CookieJar()
        handler = HTTPCookieProcessor(cj)
        ssl_ctx = ssl.create_default_context()
        return build_opener(handler), ssl_ctx

    def _build_weld_opener(self):
        cj = CookieJar()
        handler = HTTPCookieProcessor(cj)
        ssl_ctx = ssl.create_default_context()
        return build_opener(handler), ssl_ctx

    def _ocr_recognize(self, img_bytes: bytes) -> str:
        try:
            res = self._ocr.classification(img_bytes)
            return res.strip()
        except Exception:
            return ""

    def query_special_ops(self, name: str, id_card: str) -> dict:
        """查询特种作业操作证 cx.mem.gov.cn"""
        opener, ssl_ctx = self._build_mem_opener()
        headers = {
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15",
            "Referer": "https://cx.mem.gov.cn/",
            "Accept": "application/json, text/plain, */*",
            "Origin": "https://cx.mem.gov.cn"
        }

        for attempt in range(3):
            try:
                # 1. 获取验证码图片
                code_url = "https://cx.mem.gov.cn/prod-api/certsearch/code"
                req = Request(code_url, headers=headers)
                code_resp = opener.open(req, timeout=15, context=ssl_ctx)
                code_img = code_resp.read()
                captcha = self._ocr_recognize(code_img)
                if not captcha or len(captcha) < 4:
                    time.sleep(1)
                    continue

                # 2. 提交查询
                params = {
                    "name": name,
                    "idCard": id_card,
                    "vCode": captcha,
                    "certType": "1"
                }
                query_url = "https://cx.mem.gov.cn/prod-api/certsearch/certInfo/netQuery?" + urlencode(params)
                req2 = Request(query_url, headers=headers)
                resp = opener.open(req2, timeout=20, context=ssl_ctx)
                result = json.loads(resp.read().decode("utf-8"))

                if result.get("code") == 200 or result.get("success"):
                    items = result.get("data", []) or result.get("list", [])
                    if items:
                        item = items[0]
                        return {
                            "found": True,
                            "type": "特种作业操作证",
                            "num": item.get("certNo", ""),
                            "item": item.get("workType", ""),
                            "auth": item.get("issueOrg", ""),
                            "valid_from": item.get("certStartDate", ""),
                            "valid_to": item.get("certEndDate", ""),
                            "review": item.get("reviewDate", "")
                        }
                    return {"found": False, "error": "未查到该人员特种作业证"}
                time.sleep(1)
            except Exception as e:
                logger.warning(f"特种作业证查询异常({attempt+1}): {e}")
                time.sleep(1)
        return {"found": False, "error": "查询超时"}

    def query_welder(self, name: str, id_card: str) -> dict:
        """查询焊工证 cnse.e-cqs.cn"""
        opener, ssl_ctx = self._build_weld_opener()
        headers = {
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15",
            "Referer": "https://cnse.e-cqs.cn/info-pub/pubh5",
            "Accept": "application/json, text/plain, */*"
        }

        for attempt in range(3):
            try:
                # 1. 获取验证码
                code_url = "https://cnse.e-cqs.cn/info-pub/pub/h5/vcode?" + str(int(time.time() * 1000))
                req = Request(code_url, headers=headers)
                code_resp = opener.open(req, timeout=15, context=ssl_ctx)
                code_img = code_resp.read()
                captcha = self._ocr_recognize(code_img)
                if not captcha or len(captcha) < 4:
                    time.sleep(1)
                    continue

                # 2. 提交查询
                data = {
                    "name": name,
                    "idCard": id_card,
                    "vCode": captcha
                }
                query_url = "https://cnse.e-cqs.cn/info-pub/pub/h5/query?" + urlencode(data)
                req2 = Request(query_url, headers=headers)
                resp = opener.open(req2, timeout=20, context=ssl_ctx)
                result = json.loads(resp.read().decode("utf-8"))

                if result.get("success") or result.get("code") == 0:
                    items = result.get("data", []) or result.get("list", [])
                    if items:
                        item = items[0]
                        return {
                            "found": True,
                            "type": "焊工证",
                            "num": item.get("certNo", ""),
                            "item": item.get("weldMethod", ""),
                            "auth": item.get("issueOrg", ""),
                            "valid_from": item.get("certStartDate", ""),
                            "valid_to": item.get("certEndDate", ""),
                            "review": item.get("reviewDate", "")
                        }
                    return {"found": False, "error": "未查到该人员焊工证"}
                time.sleep(1)
            except Exception as e:
                logger.warning(f"焊工证查询异常({attempt+1}): {e}")
                time.sleep(1)
        return {"found": False, "error": "查询超时"}


# ── 主流程 ───────────────────────────────────────────────────────────────────
def main():
    logger.info("🚀 开始证照查询自动化")
    logger.info(f"目标: 人员清单({SRC_TABLE}) → 证照查询结果({RES_TABLE})")

    # 1. 读取全部人员清单
    logger.info("📖 读取人员清单...")
    all_records = []
    cursor = ""
    while True:
        records, cursor = dws_query_records(SRC_TABLE, limit=100, cursor=cursor)
        all_records.extend(records)
        logger.info(f"  已读取 {len(all_records)} 条")
        if not cursor:
            break
        time.sleep(0.3)

    logger.info(f"✅ 共读取 {len(all_records)} 条人员数据")

    # 2. 初始化查询服务
    query_svc = CertQueryService()

    # 3. 逐条查询并写入
    success = 0
    not_found = 0
    errors = 0

    for i, record in enumerate(all_records):
        cells = record.get("cells", {})
        name = cells.get("OjcaR3c", "")
        id_card = cells.get("vvErw34", "")

        if not name or not id_card:
            logger.warning(f"  [{i+1}/{len(all_records)}] 跳过空记录")
            continue

        logger.info(f"  [{i+1}/{len(all_records)}] 查询: {name} {id_card[:4]}****{id_card[-4:]}")

        # 查询特种作业证
        special = query_svc.query_special_ops(name, id_card)
        # 查询焊工证
        welder = query_svc.query_welder(name, id_card)

        # 构造写入内容
        result_cells = {
            FIELD_NAME: name,
            FIELD_IDCARD: id_card
        }

        if special.get("found"):
            result_cells[FIELD_TYPE] = TYPE_SPECIAL
            result_cells[FIELD_NUM] = special.get("num", "")
            result_cells[FIELD_ITEM] = special.get("item", "")
            result_cells[FIELD_AUTH] = special.get("auth", "")
            result_cells[FIELD_EXPIRE] = special.get("valid_to", "")
            result_cells[FIELD_REVIEW] = special.get("review", "")
            result_cells[FIELD_STATUS] = STATUS_OK
            result_cells[FIELD_REMARK] = f"特种作业操作证，查到证照编号 {special.get('num','')}"
            logger.info(f"    ✅ 特种作业证: {special.get('num','')}")
        elif welder.get("found"):
            result_cells[FIELD_TYPE] = TYPE_WELDER
            result_cells[FIELD_NUM] = welder.get("num", "")
            result_cells[FIELD_ITEM] = welder.get("item", "")
            result_cells[FIELD_AUTH] = welder.get("auth", "")
            result_cells[FIELD_EXPIRE] = welder.get("valid_to", "")
            result_cells[FIELD_REVIEW] = welder.get("review", "")
            result_cells[FIELD_STATUS] = STATUS_OK
            result_cells[FIELD_REMARK] = f"焊工证，查到证照编号 {welder.get('num','')}"
            logger.info(f"    ✅ 焊工证: {welder.get('num','')}")
        else:
            result_cells[FIELD_TYPE] = TYPE_NONE
            result_cells[FIELD_STATUS] = STATUS_NOTFND
            result_cells[FIELD_REMARK] = f"特种作业证: {special.get('error','未知')}; 焊工证: {welder.get('error','未知')}"
            logger.info(f"    ❌ 未查到任何证照")
            not_found += 1

        # 写入 AI 表格
        ok = dws_write_record(result_cells)
        if ok:
            success += 1
            logger.info(f"    ✅ 已写入AI表格")
        else:
            errors += 1
            logger.error(f"    ❌ 写入失败")

        # 避免请求过快
        time.sleep(random.uniform(1.5, 3.0))

    logger.info(f"\n{'='*50}")
    logger.info(f"📊 查询完成！成功: {success} | 未查到: {not_found} | 失败: {errors}")
    logger.info(f"AI表格: https://docs.dingtalk.com/i/nodes/{BASE_ID}")


if __name__ == "__main__":
    main()
