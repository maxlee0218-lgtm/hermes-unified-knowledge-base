#!/bin/bash
# heartbeat_update.sh
# PocketClaw heartbeat 更新工具
# 职责：被 inbox loop 和 review loop 调用，安全更新 heartbeat.json
# 安全：使用 flock 文件锁避免并发写冲突
# 禁止：直接修改其他 loop 的执行边界
#
# 用法:
#   bash /root/wiki/tasks/heartbeat_update.sh inbox [status] [log_summary] [issue_created] [tasks_processed] [errors]
#   bash /root/wiki/tasks/heartbeat_update.sh review [status] [log_summary] [issues_found] [running_timeout] [review_backlog] [blocked_failed] [github_pending] [errors]

set -euo pipefail

HEARTBEAT_FILE="/root/wiki/tasks/status/heartbeat.json"
LOCK_FILE="/root/wiki/tasks/status/heartbeat.lock"

# 当前时间（北京时间）
NOW=$(TZ=Asia/Shanghai date +"%Y-%m-%d %H:%M:%S%z")

# 参数解析
LOOP_TYPE="${1:-}"

if [[ "$LOOP_TYPE" != "inbox" && "$LOOP_TYPE" != "review" ]]; then
    echo "❌ 用法: heartbeat_update.sh inbox|review [args...]" >&2
    exit 1
fi

# 使用 flock 获取文件锁（超时 5 秒）
exec 200>"$LOCK_FILE"
if ! flock -w 5 200; then
    echo "❌ 无法获取 heartbeat 文件锁，可能另一个 loop 正在写入" >&2
    exit 1
fi

# 读取现有 heartbeat（如果不存在则初始化）
if [[ -f "$HEARTBEAT_FILE" ]]; then
    HEARTBEAT_JSON=$(cat "$HEARTBEAT_FILE")
else
    HEARTBEAT_JSON='{"schema_version":"1.0","updated_at":"","inbox_loop":{},"review_loop":{},"mode":"limited_formal_run","forbidden_actions_enforced":true,"github_sync":{"sync_interval_min":30,"pending_sync":false}}'
fi

# 使用 Python 安全更新 JSON
if [[ "$LOOP_TYPE" == "inbox" ]]; then
    python3 -c "
import sys, json
hb = json.loads(sys.argv[1])
hb['updated_at'] = '$NOW'
hb['inbox_loop']['last_run'] = '$NOW'
hb['inbox_loop']['status'] = sys.argv[2] if len(sys.argv) > 2 else 'ok'
hb['inbox_loop']['last_log_summary'] = sys.argv[3] if len(sys.argv) > 3 else None
hb['inbox_loop']['last_issue_created'] = sys.argv[4] if len(sys.argv) > 4 else None
hb['inbox_loop']['tasks_processed'] = int(sys.argv[5]) if len(sys.argv) > 5 and sys.argv[5].isdigit() else 0
hb['inbox_loop']['errors'] = int(sys.argv[6]) if len(sys.argv) > 6 and sys.argv[6].isdigit() else 0
print(json.dumps(hb, indent=2, ensure_ascii=False))
" "$HEARTBEAT_JSON" "${2:-ok}" "${3:-}" "${4:-}" "${5:-0}" "${6:-0}" > "${HEARTBEAT_FILE}.tmp"

elif [[ "$LOOP_TYPE" == "review" ]]; then
    python3 -c "
import sys, json
hb = json.loads(sys.argv[1])
hb['updated_at'] = '$NOW'
hb['review_loop']['last_run'] = '$NOW'
hb['review_loop']['status'] = sys.argv[2] if len(sys.argv) > 2 else 'ok'
hb['review_loop']['last_log_summary'] = sys.argv[3] if len(sys.argv) > 3 else None
hb['review_loop']['issues_found'] = int(sys.argv[4]) if len(sys.argv) > 4 and sys.argv[4].isdigit() else 0
hb['review_loop']['running_timeout'] = int(sys.argv[5]) if len(sys.argv) > 5 and sys.argv[5].isdigit() else 0
hb['review_loop']['review_backlog'] = int(sys.argv[6]) if len(sys.argv) > 6 and sys.argv[6].isdigit() else 0
hb['review_loop']['blocked_failed'] = int(sys.argv[7]) if len(sys.argv) > 7 and sys.argv[7].isdigit() else 0
hb['review_loop']['github_pending'] = int(sys.argv[8]) if len(sys.argv) > 8 and sys.argv[8].isdigit() else 0
hb['review_loop']['errors'] = int(sys.argv[9]) if len(sys.argv) > 9 and sys.argv[9].isdigit() else 0
print(json.dumps(hb, indent=2, ensure_ascii=False))
" "$HEARTBEAT_JSON" "${2:-ok}" "${3:-}" "${4:-0}" "${5:-0}" "${6:-0}" "${7:-0}" "${8:-0}" "${9:-0}" > "${HEARTBEAT_FILE}.tmp"
fi

# 原子替换
mv "${HEARTBEAT_FILE}.tmp" "$HEARTBEAT_FILE"

# 释放锁（exec 200 关闭时自动释放）
exec 200>&-

echo "✅ heartbeat 已更新 ($LOOP_TYPE: $NOW)"
