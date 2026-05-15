#!/bin/bash
# task_inbox_check.sh
# PocketClaw 定时任务入口
# 功能：检查 inbox 新任务，校验边界，创建 Multica Issue，移动状态
# 调用方式：bash /root/wiki/tasks/task_inbox_check.sh
# 日志：/root/wiki/tasks/logs/task_inbox_watcher.log
#
# 支持 DRY_RUN 模式：
# DRY_RUN=1 bash /root/wiki/tasks/task_inbox_check.sh
# 只验证文件读取、状态迁移、日志记录，不创建真实 Multica Issue

set -euo pipefail

# 配置
INBOX_DIR="/root/wiki/tasks/inbox"
ACTIVE_DIR="/root/wiki/tasks/active"
REVIEW_DIR="/root/wiki/tasks/review"
DONE_DIR="/root/wiki/tasks/done"
ARCHIVED_DIR="/root/wiki/tasks/archived"
STATUS_DIR="/root/wiki/tasks/status"
LOG_FILE="/root/wiki/tasks/logs/task_inbox_watcher.log"
REVIEW_THRESHOLD=3

# 当前时间（北京时间）
NOW=$(TZ=Asia/Shanghai date +"%Y-%m-%d %H:%M:%S")

# 日志函数
log() {
    echo "[$NOW] $1" >> "$LOG_FILE"
}

# 初始化日志
log "=== 开始检查 inbox ==="

# 先更新 heartbeat（无论后续是否处理任务，都记录 loop 运行）
bash /root/wiki/tasks/heartbeat_update.sh inbox "running" "inbox scan started" 2>/dev/null || true

# 检查 REVIEW 任务数量
review_count=0
for f in "$REVIEW_DIR"/*.md; do
    [ -f "$f" ] && review_count=$((review_count + 1))
done
log "当前 REVIEW 任务数量: $review_count"

if [ "$review_count" -gt "$REVIEW_THRESHOLD" ]; then
    log "⚠️ REVIEW 任务超过阈值 ($REVIEW_THRESHOLD)，暂停拉取新任务"
    log "=== 检查结束 ==="
    exit 0
fi

# 检查是否 DRY_RUN 模式
DRY_RUN=${DRY_RUN:-0}
if [ "$DRY_RUN" = "1" ]; then
    log "🔍 DRY_RUN 模式：只验证文件读取、状态迁移、日志记录，不创建真实 Multica Issue"
fi

# 检查 inbox 新任务
new_tasks=""
for f in "$INBOX_DIR"/*.md; do
    [ -f "$f" ] || continue
    [ "$(basename "$f")" = "task_template.md" ] && continue
    new_tasks="$new_tasks $f"
done

if [ -z "$new_tasks" ]; then
    log "📭 inbox 无新任务"
    log "=== 检查结束 ==="
    exit 0
fi

# 处理每个新任务
for task_file in $new_tasks; do
    task_name=$(basename "$task_file")
    task_id=$(grep "^task_id:" "$task_file" | awk '{print $2}' || echo "UNKNOWN")
    title=$(grep "^title:" "$task_file" | sed 's/title: "//;s/"$//' || echo "无标题")
    target_agent=$(grep "^target_agent:" "$task_file" | sed 's/target_agent: //;s/^"//;s/"$//' || echo "数据专家")
    
    log "📥 发现新任务: $task_name (ID: $task_id, 标题: $title)"
    
    # 校验边界
    if grep -q "forbidden_actions:" "$task_file"; then
        log "✅ 边界校验通过: 已定义禁止动作"
    else
        log "❌ 边界校验失败: 未定义禁止动作，跳过"
        continue
    fi
    
    # 检查是否已创建过 Multica Issue
    status_file="$STATUS_DIR/${task_id}.json"
    if [ -f "$status_file" ]; then
        log "⚠️ 任务 $task_id 已存在状态文件，跳过重复创建"
        continue
    fi
    
    # DRY_RUN 模式：不创建真实 Multica Issue
    if [ "$DRY_RUN" = "1" ]; then
        log "🔍 DRY_RUN: 模拟创建 Multica Issue (不实际创建)"
        issue_number="DRY-RUN-TEST"
        log "✅ DRY_RUN: 模拟 Multica Issue 创建成功: $issue_number"
        
        # 创建状态文件（dry-run标记）
        cat > "$status_file" <<EOF
{
  "task_id": "$task_id",
  "task_file": "$task_name",
  "multica_issue": "$issue_number",
  "status": "dry-run",
  "created_at": "$NOW",
  "agent": "$target_agent",
  "log_file": "$LOG_FILE",
  "dry_run": true
}
EOF
        
        # DRY_RUN 模式下不移动文件，保留在 inbox
        log "📂 DRY_RUN: 任务保留在 inbox (不移动到 active)"
        log "✅ DRY_RUN: 测试任务验证完成"
        continue
    fi
    
    # 正常模式：创建 Multica Issue
    log "🚀 创建 Multica Issue..."
    issue_result=$(multica issue create \
        --title "$title" \
        --description "任务来源: $task_file\n\n$(cat "$task_file")" \
        --assignee "$target_agent" \
        --priority high \
        --status in_progress 2>&1)
    
    issue_number=$(echo "$issue_result" | grep '"number":' | awk '{print $2}' | tr -d ',')
    
    if [ -n "$issue_number" ]; then
        log "✅ Multica Issue 创建成功: LEE-$issue_number"
        
        # 更新 heartbeat（记录最近创建的 issue）
        bash /root/wiki/tasks/heartbeat_update.sh inbox "ok" "issue created" "LEE-$issue_number" 2>/dev/null || true
        
        # 创建状态文件
        cat > "$status_file" <<EOF
{
  "task_id": "$task_id",
  "task_file": "$task_name",
  "multica_issue": "LEE-$issue_number",
  "status": "active",
  "created_at": "$NOW",
  "agent": "$target_agent",
  "log_file": "$LOG_FILE"
}
EOF
        
        # 移动到 active
        mv "$task_file" "$ACTIVE_DIR/"
        log "📂 任务已移动到 active: $ACTIVE_DIR/$task_name"
    else
        log "❌ Multica Issue 创建失败: $issue_result"
    fi
done

log "=== 检查结束 ==="

# 结束前更新 heartbeat（记录本次检查结果）
if [ -z "$new_tasks" ]; then
    bash /root/wiki/tasks/heartbeat_update.sh inbox "ok" "no new task" 2>/dev/null || true
fi
