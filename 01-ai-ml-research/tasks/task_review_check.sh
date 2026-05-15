#!/bin/bash
# task_review_check.sh
# REVIEW LOOP 治理层巡检脚本（修复版）
# 修复内容：
#   1. 同时统计本地 review 目录和 Multica in_review/review/review_ready 状态
#   2. 增加 review_stuck 检查（in_review 超过30分钟）
#   3. heartbeat 恢复为标准结构
#   4. alert 列出具体 LEE 编号和任务标题
# 职责：发现问题并提醒主脑，不自动推进任务
# 禁止：自动执行生产动作、自动恢复、自动retry、自动restart、自动上线
#
# 调用方式：bash /root/wiki/tasks/task_review_check.sh
# 日志：/root/wiki/tasks/logs/task_review_watcher.log
# 状态：/root/wiki/tasks/status/review_loop_status.json

set -euo pipefail

# 配置
REVIEW_DIR="/root/wiki/tasks/review"
DONE_DIR="/root/wiki/tasks/done"
ACTIVE_DIR="/root/wiki/tasks/active"
ARCHIVED_DIR="/root/wiki/tasks/archived"
STATUS_DIR="/root/wiki/tasks/status"
LOG_FILE="/root/wiki/tasks/logs/task_review_watcher.log"
STATUS_FILE="/root/wiki/tasks/status/review_loop_status.json"

# 超时阈值（分钟）
RUNNING_TIMEOUT_MIN=30
REVIEW_STUCK_MIN=30
REVIEW_BACKLOG_THRESHOLD=3

# 当前时间（北京时间）
NOW=$(TZ=Asia/Shanghai date +"%Y-%m-%d %H:%M:%S")
NOW_EPOCH=$(date +%s)

# 日志函数
log() {
    echo "[$NOW] $1" >> "$LOG_FILE"
}

# 初始化日志
log "=== REVIEW LOOP 开始巡检 ==="

# 先更新 heartbeat（记录 loop 运行）
bash /root/wiki/tasks/heartbeat_update.sh review "running" "review scan started" 0 0 0 0 0 0 2>/dev/null || true

# 检查结果计数器
issues_found=0
issues_details=""

# ============================================
# 1. 检查 RUNNING 任务是否超时
# ============================================
log "🔍 检查 RUNNING 任务超时..."

running_timeout_count=0
running_timeout_details=""

# 获取 Multica 运行中任务
running_issues=$(multica issue list --status in_progress --output json 2>/dev/null | python3 /tmp/parse_multica.py 2>/dev/null | tail -n +2)

if [ -n "$running_issues" ]; then
    while IFS=':' read -r issue_id title; do
        issue_id=$(echo "$issue_id" | sed 's/^[[:space:]]*-[[:space:]]*//')
        title=$(echo "$title" | sed 's/^[[:space:]]*//')
        # 获取任务创建时间（从 multica issue show 获取）
        created_at=$(multica issue show "$issue_id" --output json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('issue',{}).get('created_at',''))" 2>/dev/null || true)
        if [ -n "$created_at" ]; then
            created_epoch=$(date -d "$created_at" +%s 2>/dev/null || echo 0)
            if [ "$created_epoch" -gt 0 ]; then
                running_min=$(( (NOW_EPOCH - created_epoch) / 60 ))
                if [ "$running_min" -gt "$RUNNING_TIMEOUT_MIN" ]; then
                    running_timeout_count=$((running_timeout_count + 1))
                    running_timeout_details="${running_timeout_details}\n- ${issue_id}: ${title} (已运行 ${running_min} 分钟)"
                    log "⚠️ RUNNING 超时: ${issue_id} - ${title} (${running_min} 分钟)"
                fi
            fi
        fi
    done <<< "$running_issues"
fi

if [ "$running_timeout_count" -gt 0 ]; then
    issues_found=$((issues_found + 1))
    issues_details="${issues_details}\n\n## RUNNING 超时 (${running_timeout_count} 个)${running_timeout_details}"
fi

log "RUNNING 超时检查完成: ${running_timeout_count} 个"

# ============================================
# 2. 检查 REVIEW 任务堆积（本地 + Multica）
# ============================================
log "🔍 检查 REVIEW 任务堆积..."

# 2a. 本地 review 目录
local_review_count=0
local_review_details=""

for f in "$REVIEW_DIR"/*.md; do
    [ -f "$f" ] || continue
    local_review_count=$((local_review_count + 1))
    task_name=$(basename "$f" .md)
    local_review_details="${local_review_details}\n- ${task_name} (本地 review 目录)"
done

# 2b. Multica in_review 状态
multica_review_count=0
multica_review_details=""

multica_in_review=$(multica issue list --status in_review --output json 2>/dev/null | python3 /tmp/parse_multica.py 2>/dev/null | tail -n +2)

if [ -n "$multica_in_review" ]; then
    while IFS=':' read -r issue_id title; do
        issue_id=$(echo "$issue_id" | sed 's/^[[:space:]]*-[[:space:]]*//')
        title=$(echo "$title" | sed 's/^[[:space:]]*//')
        multica_review_count=$((multica_review_count + 1))
        multica_review_details="${multica_review_details}\n- ${issue_id}: ${title} (Multica in_review)"
    done <<< "$multica_in_review"
fi

# 2c. Multica review 状态
multica_review_status_count=0
multica_review_status_details=""

multica_review_status=$(multica issue list --status review --output json 2>/dev/null | python3 /tmp/parse_multica.py 2>/dev/null | tail -n +2)

if [ -n "$multica_review_status" ]; then
    while IFS=':' read -r issue_id title; do
        issue_id=$(echo "$issue_id" | sed 's/^[[:space:]]*-[[:space:]]*//')
        title=$(echo "$title" | sed 's/^[[:space:]]*//')
        multica_review_status_count=$((multica_review_status_count + 1))
        multica_review_status_details="${multica_review_status_details}\n- ${issue_id}: ${title} (Multica review)"
    done <<< "$multica_review_status"
fi

# 2d. Multica review_ready 状态
multica_review_ready_count=0
multica_review_ready_details=""

multica_review_ready=$(multica issue list --status review_ready --output json 2>/dev/null | python3 /tmp/parse_multica.py 2>/dev/null | tail -n +2)

if [ -n "$multica_review_ready" ]; then
    while IFS=':' read -r issue_id title; do
        issue_id=$(echo "$issue_id" | sed 's/^[[:space:]]*-[[:space:]]*//')
        title=$(echo "$title" | sed 's/^[[:space:]]*//')
        multica_review_ready_count=$((multica_review_ready_count + 1))
        multica_review_ready_details="${multica_review_ready_details}\n- ${issue_id}: ${title} (Multica review_ready)"
    done <<< "$multica_review_ready"
fi

# 总 review backlog
review_backlog_total=$((local_review_count + multica_review_count + multica_review_status_count + multica_review_ready_count))

if [ "$review_backlog_total" -ge "$REVIEW_BACKLOG_THRESHOLD" ]; then
    issues_found=$((issues_found + 1))
    review_details="\n\n## REVIEW 堆积 (${review_backlog_total} 个，阈值 ${REVIEW_BACKLOG_THRESHOLD})\n\n### 本地 review 目录 (${local_review_count} 个)${local_review_details}\n\n### Multica in_review (${multica_review_count} 个)${multica_review_details}\n\n### Multica review (${multica_review_status_count} 个)${multica_review_status_details}\n\n### Multica review_ready (${multica_review_ready_count} 个)${multica_review_ready_details}"
    log "⚠️ REVIEW 堆积: ${review_backlog_total} 个任务待验收"
fi

log "REVIEW 堆积检查完成: 本地=${local_review_count}, Multica in_review=${multica_review_count}, Multica review=${multica_review_status_count}, Multica review_ready=${multica_review_ready_count}, 总计=${review_backlog_total}"

# ============================================
# 3. 检查 review_stuck 任务（in_review 超过30分钟）
# ============================================
log "🔍 检查 review_stuck 任务..."

review_stuck_count=0
review_stuck_details=""

# 检查所有 in_review 任务的创建时间
if [ -n "$multica_in_review" ]; then
    while IFS=':' read -r issue_id title; do
        issue_id=$(echo "$issue_id" | sed 's/^[[:space:]]*-[[:space:]]*//')
        title=$(echo "$title" | sed 's/^[[:space:]]*//')
        created_at=$(multica issue show "$issue_id" --output json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('issue',{}).get('created_at',''))" 2>/dev/null || true)
        if [ -n "$created_at" ]; then
            created_epoch=$(date -d "$created_at" +%s 2>/dev/null || echo 0)
            if [ "$created_epoch" -gt 0 ]; then
                review_min=$(( (NOW_EPOCH - created_epoch) / 60 ))
                if [ "$review_min" -gt "$REVIEW_STUCK_MIN" ]; then
                    review_stuck_count=$((review_stuck_count + 1))
                    review_stuck_details="${review_stuck_details}\n- ${issue_id}: ${title} (in_review ${review_min} 分钟)"
                    log "⚠️ REVIEW STUCK: ${issue_id} - ${title} (in_review ${review_min} 分钟)"
                fi
            fi
        fi
    done <<< "$multica_in_review"
fi

if [ "$review_stuck_count" -gt 0 ]; then
    issues_found=$((issues_found + 1))
    issues_details="${issues_details}\n\n## REVIEW STUCK (${review_stuck_count} 个，阈值 ${REVIEW_STUCK_MIN} 分钟)${review_stuck_details}"
fi

log "REVIEW STUCK 检查完成: ${review_stuck_count} 个"

# ============================================
# 4. 检查 DONE 是否未归档
# ============================================
log "🔍 检查 DONE 未归档..."

done_unarchived_count=0
done_unarchived_details=""

for f in "$DONE_DIR"/*.md; do
    [ -f "$f" ] || continue
    
    task_name=$(basename "$f")
    archived_file="$ARCHIVED_DIR/$task_name"
    
    if [ ! -f "$archived_file" ]; then
        done_unarchived_count=$((done_unarchived_count + 1))
        done_unarchived_details="${done_unarchived_details}\n- ${task_name}"
        log "⚠️ DONE 未归档: ${task_name}"
    fi
done

if [ "$done_unarchived_count" -gt 0 ]; then
    issues_found=$((issues_found + 1))
    issues_details="${issues_details}\n\n## DONE 未归档 (${done_unarchived_count} 个)${done_unarchived_details}"
fi

log "DONE 未归档检查完成: ${done_unarchived_count} 个"

# ============================================
# 5. 检查 BLOCKED / FAILED 是否未处理
# ============================================
log "🔍 检查 BLOCKED/FAILED 未处理..."

blocked_count=0
blocked_details=""

# 获取 Multica blocked 任务
blocked_issues=$(multica issue list --status blocked --output json 2>/dev/null | python3 /tmp/parse_multica_blocked.py 2>/dev/null | tail -n +2)

if [ -n "$blocked_issues" ]; then
    while IFS=':' read -r issue_id title; do
        issue_id=$(echo "$issue_id" | sed 's/^[[:space:]]*-[[:space:]]*//')
        title=$(echo "$title" | sed 's/^[[:space:]]*//')
        blocked_count=$((blocked_count + 1))
        blocked_details="${blocked_details}\n- ${issue_id}: ${title} (状态: blocked)"
        log "⚠️ BLOCKED: ${issue_id} - ${title}"
    done <<< "$blocked_issues"
fi

# 获取 Multica failed 任务
failed_issues=$(multica issue list --status failed --output json 2>/dev/null | python3 /tmp/parse_multica.py 2>/dev/null | tail -n +2)

if [ -n "$failed_issues" ]; then
    while IFS=':' read -r issue_id title; do
        issue_id=$(echo "$issue_id" | sed 's/^[[:space:]]*-[[:space:]]*//')
        title=$(echo "$title" | sed 's/^[[:space:]]*//')
        blocked_count=$((blocked_count + 1))
        blocked_details="${blocked_details}\n- ${issue_id}: ${title} (状态: failed)"
        log "⚠️ FAILED: ${issue_id} - ${title}"
    done <<< "$failed_issues"
fi

if [ "$blocked_count" -gt 0 ]; then
    issues_found=$((issues_found + 1))
    issues_details="${issues_details}\n\n## BLOCKED/FAILED 未处理 (${blocked_count} 个)${blocked_details}"
fi

log "BLOCKED/FAILED 检查完成: ${blocked_count} 个"

# ============================================
# 6. 检查 status 文件是否缺失
# ============================================
log "🔍 检查 status 文件缺失..."

missing_status_count=0
missing_status_details=""

for f in "$ACTIVE_DIR"/*.md "$REVIEW_DIR"/*.md "$DONE_DIR"/*.md; do
    [ -f "$f" ] || continue
    
    task_name=$(basename "$f" .md)
    status_file="$STATUS_DIR/${task_name}.json"
    
    if [ ! -f "$status_file" ]; then
        missing_status_count=$((missing_status_count + 1))
        missing_status_details="${missing_status_details}\n- ${task_name}"
        log "⚠️ Status 缺失: ${task_name}"
    fi
done

if [ "$missing_status_count" -gt 0 ]; then
    issues_found=$((issues_found + 1))
    issues_details="${issues_details}\n\n## Status 文件缺失 (${missing_status_count} 个)${missing_status_details}"
fi

log "Status 缺失检查完成: ${missing_status_count} 个"

# ============================================
# 7. 检查知识沉淀是否未完成
# ============================================
log "🔍 检查知识沉淀..."

knowledge_pending_count=0
knowledge_pending_details=""

# 检查 DONE 任务是否有对应的报告文件
for f in "$DONE_DIR"/*.md; do
    [ -f "$f" ] || continue
    
    task_name=$(basename "$f" .md)
    # 使用 nullglob 避免 glob 未匹配时保留原样导致 ls 报错
    shopt -s nullglob
    report_files=(/root/multica-work/output/*${task_name}*.md)
    shopt -u nullglob
    report_count=${#report_files[@]}
    
    if [ "$report_count" -eq 0 ]; then
        knowledge_pending_count=$((knowledge_pending_count + 1))
        knowledge_pending_details="${knowledge_pending_details}\n- ${task_name} (无报告)"
        log "⚠️ 知识沉淀缺失: ${task_name}"
    fi
done

if [ "$knowledge_pending_count" -gt 0 ]; then
    issues_found=$((issues_found + 1))
    issues_details="${issues_details}\n\n## 知识沉淀未完成 (${knowledge_pending_count} 个)${knowledge_pending_details}"
fi

log "知识沉淀检查完成: ${knowledge_pending_count} 个"

# ============================================
# 8. 检查 GitHub push 是否未完成
# ============================================
log "🔍 检查 GitHub push 状态..."

github_pending_count=0
github_pending_details=""

cd /root/wiki

# 检查是否有未推送的 commit
unpushed=$(git log origin/main..main --oneline 2>/dev/null || true)

if [ -n "$unpushed" ]; then
    unpushed_count=$(echo "$unpushed" | wc -l)
    github_pending_count=$unpushed_count
    github_pending_details="\n\n## GitHub 未推送 (${unpushed_count} 个 commit)\n\n未推送 commits:\n${unpushed}"
    log "⚠️ GitHub 未推送: ${unpushed_count} 个 commit"
fi

log "GitHub push 检查完成: ${github_pending_count} 个 commit 未推送"

# ============================================
# 生成状态报告
# ============================================
log "📝 生成状态报告..."

cat > "$STATUS_FILE" <<EOF
{
  "check_time": "$NOW",
  "issues_found": $issues_found,
  "local_review_count": $local_review_count,
  "multica_review_count": $multica_review_count,
  "review_backlog_total": $review_backlog_total,
  "review_stuck_count": $review_stuck_count,
  "running_timeout": $running_timeout_count,
  "done_unarchived": $done_unarchived_count,
  "blocked_failed": $blocked_count,
  "missing_status": $missing_status_count,
  "knowledge_pending": $knowledge_pending_count,
  "github_pending": $github_pending_count,
  "requires_attention": $([ "$issues_found" -gt 0 ] && echo "true" || echo "false")
}
EOF

log "状态报告已生成: $STATUS_FILE"

# ============================================
# 输出提醒（如果有问题）
# ============================================
if [ "$issues_found" -gt 0 ]; then
    log "⚠️ 发现 ${issues_found} 类问题，需要主脑关注"
    
    # 生成提醒报告
    alert_file="/root/wiki/tasks/status/review_alert_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$alert_file" <<EOF
# REVIEW LOOP 巡检提醒

> 巡检时间: $NOW
> 发现问题: ${issues_found} 类

## 摘要

| 检查项 | 数量 | 状态 |
|--------|------|------|
| RUNNING 超时 | ${running_timeout_count} | $([ "$running_timeout_count" -gt 0 ] && echo "⚠️" || echo "✅") |
| REVIEW 堆积 | ${review_backlog_total} | $([ "$review_backlog_total" -ge "$REVIEW_BACKLOG_THRESHOLD" ] && echo "⚠️" || echo "✅") |
| REVIEW STUCK | ${review_stuck_count} | $([ "$review_stuck_count" -gt 0 ] && echo "⚠️" || echo "✅") |
| DONE 未归档 | ${done_unarchived_count} | $([ "$done_unarchived_count" -gt 0 ] && echo "⚠️" || echo "✅") |
| BLOCKED/FAILED | ${blocked_count} | $([ "$blocked_count" -gt 0 ] && echo "⚠️" || echo "✅") |
| Status 缺失 | ${missing_status_count} | $([ "$missing_status_count" -gt 0 ] && echo "⚠️" || echo "✅") |
| 知识沉淀缺失 | ${knowledge_pending_count} | $([ "$knowledge_pending_count" -gt 0 ] && echo "⚠️" || echo "✅") |
| GitHub 未推送 | ${github_pending_count} | $([ "$github_pending_count" -gt 0 ] && echo "⚠️" || echo "✅") |

## 详情
${issues_details}

## 建议动作

$([ "$running_timeout_count" -gt 0 ] && echo "- [ ] 检查 RUNNING 超时任务，确认是否需要人工干预" || echo "")
$([ "$review_backlog_total" -ge "$REVIEW_BACKLOG_THRESHOLD" ] && echo "- [ ] 及时验收 REVIEW 堆积任务" || echo "")
$([ "$review_stuck_count" -gt 0 ] && echo "- [ ] 处理 REVIEW STUCK 任务（超过 ${REVIEW_STUCK_MIN} 分钟未审核）" || echo "")
$([ "$done_unarchived_count" -gt 0 ] && echo "- [ ] 归档 DONE 未归档任务" || echo "")
$([ "$blocked_count" -gt 0 ] && echo "- [ ] 处理 BLOCKED/FAILED 任务" || echo "")
$([ "$missing_status_count" -gt 0 ] && echo "- [ ] 补充缺失的 status 文件" || echo "")
$([ "$knowledge_pending_count" -gt 0 ] && echo "- [ ] 完成知识沉淀" || echo "")
$([ "$github_pending_count" -gt 0 ] && echo "- [ ] 推送 GitHub" || echo "")

---

> ⚠️ 本报告由 REVIEW LOOP 自动生成，仅提醒不自动执行
> ⚠️ 所有动作需要主脑确认后手动执行
EOF

    log "提醒报告已生成: $alert_file"
else
    log "✅ 巡检完成，未发现异常"
fi

log "=== REVIEW LOOP 巡检结束 ==="

# 结束前更新 heartbeat（汇总本次巡检结果）
bash /root/wiki/tasks/heartbeat_update.sh review \
    "$([ "$issues_found" -gt 0 ] && echo "warning" || echo "ok")" \
    "$([ "$issues_found" -gt 0 ] && echo "issues found" || echo "all clear")" \
    "$issues_found" \
    "$running_timeout_count" \
    "$review_backlog_total" \
    "$blocked_count" \
    "$github_pending_count" \
    "0" \
    2>/dev/null || true
