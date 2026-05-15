#!/bin/bash
# heartbeat_sync.sh
# PocketClaw heartbeat GitHub 同步脚本
# 职责：将 heartbeat.json 安全同步到 GitHub，避免高频 push 噪声
# 策略：
#   - 本地每次 loop 运行都更新 heartbeat.json
#   - 每 30 分钟或 heartbeat 内容变化时才 commit/push
#   - 由 cron 调用（如 */30 * * * *）
# 禁止：force push、删除历史、泄露密钥

set -euo pipefail

HEARTBEAT_FILE="/root/wiki/tasks/status/heartbeat.json"
WIKI_DIR="/root/wiki"
LOG_FILE="/root/wiki/tasks/logs/heartbeat_sync.log"

# 当前时间
NOW=$(TZ=Asia/Shanghai date +"%Y-%m-%d %H:%M:%S")

# 日志函数
log() {
    echo "[$NOW] $1" >> "$LOG_FILE"
}

# 检查 heartbeat 文件是否存在
if [[ ! -f "$HEARTBEAT_FILE" ]]; then
    log "❌ heartbeat.json 不存在，跳过同步"
    exit 0
fi

cd "$WIKI_DIR"

# 检查 git 状态
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    log "❌ $WIKI_DIR 不是 git 仓库"
    exit 1
fi

# 检查是否有变化
if git diff --quiet -- "$HEARTBEAT_FILE" 2>/dev/null && git diff --cached --quiet -- "$HEARTBEAT_FILE" 2>/dev/null; then
    log "ℹ️ heartbeat.json 无变化，跳过同步"
    exit 0
fi

# 检查 remote 是否可达
if ! git ls-remote origin >/dev/null 2>&1; then
    log "❌ GitHub remote 不可达，跳过同步"
    exit 0
fi

# 先 pull 避免冲突
if ! git pull origin main --ff-only >/dev/null 2>&1; then
    log "⚠️ git pull 失败，可能存在冲突，跳过同步"
    exit 0
fi

# 添加 heartbeat 文件
git add "$HEARTBEAT_FILE"

# 检查是否有 staged changes
if git diff --cached --quiet; then
    log "ℹ️ 无 staged changes，跳过 commit"
    exit 0
fi

# commit
COMMIT_MSG="chore(heartbeat): sync loop heartbeat at $NOW

- inbox_loop last_run: $(python3 -c "import json; d=json.load(open('$HEARTBEAT_FILE')); print(d.get('inbox_loop',{}).get('last_run','N/A'))")
- review_loop last_run: $(python3 -c "import json; d=json.load(open('$HEARTBEAT_FILE')); print(d.get('review_loop',{}).get('last_run','N/A'))")
- mode: $(python3 -c "import json; d=json.load(open('$HEARTBEAT_FILE')); print(d.get('mode','N/A'))")

[auto-sync]"

if git commit -m "$COMMIT_MSG" >/dev/null 2>&1; then
    COMMIT_ID=$(git rev-parse HEAD)
    
    # push
    if git push origin main >/dev/null 2>&1; then
        log "✅ heartbeat 同步成功: commit $COMMIT_ID"
        
        # 更新 heartbeat 中的 sync 元数据
        python3 -c "
import json, sys
hb_file = '$HEARTBEAT_FILE'
with open(hb_file, 'r') as f:
    hb = json.load(f)
hb['github_sync']['last_sync'] = '$NOW'
hb['github_sync']['pending_sync'] = False
hb['github_sync']['commit_id'] = '$COMMIT_ID'
with open(hb_file, 'w') as f:
    json.dump(hb, f, indent=2, ensure_ascii=False)
" >/dev/null 2>&1 || true
        
        # 二次 commit 更新 sync 元数据（只在有变化时）
        git add "$HEARTBEAT_FILE" >/dev/null 2>&1 || true
        if ! git diff --cached --quiet 2>/dev/null; then
            git commit -m "chore(heartbeat): update sync meta $COMMIT_ID" >/dev/null 2>&1 || true
            git push origin main >/dev/null 2>&1 || true
        fi
    else
        log "❌ git push 失败"
        exit 1
    fi
else
    log "❌ git commit 失败"
    exit 1
fi
