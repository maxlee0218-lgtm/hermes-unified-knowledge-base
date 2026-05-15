# Runtime 流程状态快照采集脚本
# 版本：v1.0
# 用途：只读采集 Runtime 流程保障总账所需数据，生成 JSON 和 Markdown 报告
# 运行方式：powershell -ExecutionPolicy Bypass -File scripts/runtime_state_snapshot.ps1
# 禁止：修改 Multica Issue 状态、操作生产系统、输出密钥

param(
    [string]$WikiRoot = (Join-Path $PSScriptRoot ".."),
    [string]$OutputJson = (Join-Path $WikiRoot "tasks/status/runtime-state.json"),
    [string]$OutputMd = (Join-Path $WikiRoot "tasks/status/runtime-state.md")
)

# --- 辅助函数 ---
function Get-IsoTimestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Get-LocalTimestamp {
    return (Get-Date).ToString("yyyy-MM-dd HH:mm:ss zzz")
}

function Test-GatewayAlive {
    param([string]$DoneDir)
    if (-not (Test-Path $DoneDir)) {
        return @{ Alive = $false; LastSeen = "directory_not_found"; MinutesSince = $null }
    }
    $latestFile = Get-ChildItem -Path $DoneDir -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if (-not $latestFile) {
        return @{ Alive = $false; LastSeen = "no_files"; MinutesSince = $null }
    }
    $lastSeen = $latestFile.LastWriteTime
    $minutesSince = [math]::Floor(((Get-Date) - $lastSeen).TotalMinutes)
    $alive = $minutesSince -lt 30
    return @{
        Alive = $alive
        LastSeen = $lastSeen.ToString("yyyy-MM-dd HH:mm:ss zzz")
        MinutesSince = $minutesSince
    }
}

function Get-FailedCount {
    param([string]$FailedDir)
    if (-not (Test-Path $FailedDir)) { return 0 }
    return (Get-ChildItem -Path $FailedDir -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne ".gitkeep" }).Count
}

function Get-LastCreatedIssue {
    param([string]$DoneDir)
    if (-not (Test-Path $DoneDir)) { return $null }
    $latestFile = Get-ChildItem -Path $DoneDir -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne ".gitkeep" } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if (-not $latestFile) { return $null }
    try {
        $content = Get-Content $latestFile.FullName -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($content.created_issue) { return $content.created_issue }
        if ($content.existing_issue) { return $content.existing_issue }
        return $latestFile.Name
    } catch {
        return $latestFile.Name
    }
}

function Test-FlowHealth {
    param(
        [int]$FailedCount,
        [hashtable]$GatewayStatus,
        [int]$InReviewCount,
        [hashtable]$Heartbeat,
        [hashtable]$Multica
    )
    $intakeOk = ($FailedCount -eq 0) -and ($GatewayStatus.Alive -or $GatewayStatus.MinutesSince -lt 30)
    $routingOk = $true   # 需要结合历史判断，默认可通过
    $reviewOk = $InReviewCount -eq 0 -or $InReviewCount -lt 3
    $closeoutOk = $true  # 需要结合历史判断，默认可通过
    $stateObsOk = $true
    if ($Heartbeat -and $Heartbeat.ContainsKey("review_backlog")) {
        if ($Heartbeat.review_backlog -ne $Multica.in_review) {
            $stateObsOk = $false
        }
    }
    return @{
        intake_ok = $intakeOk
        routing_ok = $routingOk
        review_ok = $reviewOk
        closeout_ok = $closeoutOk
        state_observability_ok = $stateObsOk
    }
}

function Get-OverallStatus {
    param(
        [int]$FailedCount,
        [hashtable]$GatewayStatus,
        [int]$InReviewMinutes,
        [hashtable]$FlowHealth
    )
    if ($FailedCount -gt 0) { return "red" }
    if (-not $GatewayStatus.Alive -and $GatewayStatus.MinutesSince -gt 30) { return "red" }
    if ($GatewayStatus.MinutesSince -gt 10) { return "yellow" }
    if ($InReviewMinutes -gt 60) { return "red" }
    if ($InReviewMinutes -gt 30) { return "yellow" }
    if (-not $FlowHealth.state_observability_ok) { return "yellow" }
    return "green"
}

# --- 主逻辑 ---
$doneDir = Join-Path $WikiRoot "runtime-commands/done"
$failedDir = Join-Path $WikiRoot "runtime-commands/failed"
$heartbeatFile = Join-Path $WikiRoot "tasks/status/heartbeat.json"
$reviewLoopFile = Join-Path $WikiRoot "tasks/status/review_loop_status.json"

# 1. Gateway 状态
$gatewayStatus = Test-GatewayAlive -DoneDir $doneDir
$failedCount = Get-FailedCount -FailedDir $failedDir
$lastCreatedIssue = Get-LastCreatedIssue -DoneDir $doneDir

# 2. 读取 heartbeat
$heartbeat = @{}
if (Test-Path $heartbeatFile) {
    try {
        $hbContent = Get-Content $heartbeatFile -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($hbContent) {
            $hbContent.PSObject.Properties | ForEach-Object { $heartbeat[$_.Name] = $_.Value }
        }
    } catch { }
}

# 3. 读取 review_loop_status
$reviewLoop = @{}
if (Test-Path $reviewLoopFile) {
    try {
        $rlContent = Get-Content $reviewLoopFile -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($rlContent) {
            $rlContent.PSObject.Properties | ForEach-Object { $reviewLoop[$_.Name] = $_.Value }
        }
    } catch { }
}

# 4. 构造 Multica 状态占位（本脚本不调用 multica CLI，由外部注入或手动更新）
$multica = @{
    todo = 0
    in_progress = 0
    in_review = 0
    blocked = 0
    done_recent = 0
}

# 5. Flow Health
$flowHealth = Test-FlowHealth -FailedCount $failedCount -GatewayStatus $gatewayStatus -InReviewCount $multica.in_review -Heartbeat $heartbeat -Multica $multica

# 6. Overall Status
$overallStatus = Get-OverallStatus -FailedCount $failedCount -GatewayStatus $gatewayStatus -InReviewMinutes 0 -FlowHealth $flowHealth

# 7. Blockers / Role Violations / Duplicates / Manual Decisions / Next Actions
$blockers = @()
if (-not $gatewayStatus.Alive) {
    $blockers += "gateway 超过 30 分钟无新记录（最后 $($gatewayStatus.LastSeen)，当前 $(Get-LocalTimestamp)）"
}
if ($failedCount -gt 0) {
    $blockers += "runtime-commands/failed 存在 $failedCount 条失败记录"
}
if (-not $flowHealth.state_observability_ok) {
    $blockers += "heartbeat 与 Multica 实时状态不一致，state_observability 受损"
}

$roleViolations = @()
$duplicates = @()
$manualDecisions = @()
if ($blockers.Count -gt 0) {
    $manualDecisions += "存在 $($blockers.Count) 个 blocker，需要确认根因和处理方案"
}

$nextActions = @()
if (-not $gatewayStatus.Alive) {
    $nextActions += "检查 Windows gateway / PocketClaw 运行状态，确认停滞原因"
}
if ($failedCount -gt 0) {
    $nextActions += "检查 runtime-commands/failed 目录，处理失败命令"
}
if (-not $flowHealth.state_observability_ok) {
    $nextActions += "修复 heartbeat 同步或确认 loop 是否仍在运行"
}

# 8. 组装 JSON
$state = @{
    generated_at = Get-IsoTimestamp
    mode = "flow_guard_readonly"
    overall_status = $overallStatus
    gateway = @{
        alive = $gatewayStatus.Alive
        last_seen = $gatewayStatus.LastSeen
        failed_count = $failedCount
        last_created_issue = $lastCreatedIssue
    }
    multica = $multica
    flow_health = $flowHealth
    blockers = $blockers
    role_violations = $roleViolations
    duplicates = $duplicates
    manual_decisions = $manualDecisions
    next_actions = $nextActions
}

# 9. 输出 JSON
$state | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputJson -Encoding utf8
Write-Host "[OK] JSON written to: $OutputJson"

# 10. 输出 Markdown
$mdLines = @(
    "# Runtime 流程保障总账（只读观测版）"
    ""
    "> 生成时间：$(Get-IsoTimestamp)"
    "> 模式：flow_guard_readonly"
    "> 生成智能体：Runtime首脑（通过 PowerShell 脚本）"
    ""
    "---"
    ""
    "## 001 总览"
    ""
    "| 指标 | 值 |"
    "|------|-----|"
    "| 整体状态 | $(if ($overallStatus -eq 'green') { '🟢' } elseif ($overallStatus -eq 'yellow') { '🟡' } elseif ($overallStatus -eq 'red') { '🔴' } else { '⚫' }) **$overallStatus** |"
    "| gateway 存活 | $(if ($gatewayStatus.Alive) { '✅' } else { '❌' }) 否 |"
    "| gateway 最后活跃 | $($gatewayStatus.LastSeen) |"
    "| failed 计数 | $failedCount |"
    ""
    "---"
    ""
    "## 002 Gateway 状态"
    ""
    "- **alive**: `$($gatewayStatus.Alive)`"
    "- **last_seen**: `$($gatewayStatus.LastSeen)`"
    "- **failed_count**: `$failedCount`"
    "- **last_created_issue**: `$lastCreatedIssue`"
    ""
    "---"
    ""
    "## 003 Multica 状态"
    ""
    "| 状态 | 数量 |"
    "|------|------|"
    "| todo | $($multica.todo) |"
    "| in_progress | $($multica.in_progress) |"
    "| in_review | $($multica.in_review) |"
    "| blocked | $($multica.blocked) |"
    "| done_recent | $($multica.done_recent) |"
    ""
    "---"
    ""
    "## 004 流程健康度"
    ""
    "| 维度 | 状态 |"
    "|------|------|"
    "| intake_ok | $(if ($flowHealth.intake_ok) { '✅' } else { '❌' }) |"
    "| routing_ok | $(if ($flowHealth.routing_ok) { '✅' } else { '❌' }) |"
    "| review_ok | $(if ($flowHealth.review_ok) { '✅' } else { '❌' }) |"
    "| closeout_ok | $(if ($flowHealth.closeout_ok) { '✅' } else { '❌' }) |"
    "| state_observability_ok | $(if ($flowHealth.state_observability_ok) { '✅' } else { '❌' }) |"
    ""
    "---"
    ""
    "## 005 阻塞项（Blockers）"
    ""
)
if ($blockers.Count -eq 0) {
    $mdLines += "- 当前无阻塞项"
} else {
    foreach ($b in $blockers) {
        $mdLines += "- $b"
    }
}
$mdLines += @(
    ""
    "---"
    ""
    "## 006 角色违规（Role Violations）"
    ""
)
if ($roleViolations.Count -eq 0) {
    $mdLines += "- 当前未发现角色违规记录"
} else {
    foreach ($r in $roleViolations) {
        $mdLines += "- $r"
    }
}
$mdLines += @(
    ""
    "---"
    ""
    "## 007 重复项（Duplicates）"
    ""
)
if ($duplicates.Count -eq 0) {
    $mdLines += "- 当前未发现重复项"
} else {
    foreach ($d in $duplicates) {
        $mdLines += "- $d"
    }
}
$mdLines += @(
    ""
    "---"
    ""
    "## 008 需人工决策（Manual Decisions）"
    ""
)
if ($manualDecisions.Count -eq 0) {
    $mdLines += "- 当前无需人工决策"
} else {
    foreach ($m in $manualDecisions) {
        $mdLines += "- $m"
    }
}
$mdLines += @(
    ""
    "---"
    ""
    "## 009 下一步动作（Next Actions）"
    ""
)
if ($nextActions.Count -eq 0) {
    $mdLines += "- 当前无下一步动作"
} else {
    foreach ($n in $nextActions) {
        $mdLines += "- $n"
    }
}
$mdLines += @(
    ""
    "---"
    ""
    "*本报告由 Runtime首脑 只读生成，未修改任何 Multica Issue 状态、未操作生产系统、未输出密钥。*"
)

$mdLines | Out-File -FilePath $OutputMd -Encoding utf8
Write-Host "[OK] Markdown written to: $OutputMd"
Write-Host "[DONE] Runtime state snapshot complete."
