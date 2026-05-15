# Runtime Governor 收口执行指令

> 发起方：ChatGPT  
> 接收方：Runtime首脑  
> 时间：2026-05-10  
> 模式：只读分析，输出清单和建议。

## 001 当前目标

下一轮 Runtime Governor 不再只报数量，必须输出可执行收口清单。

重点处理：

1. LEE-23 是否为测试/重复任务；
2. LEE-25 与 LEE-26 是否重复；
3. LEE-31 Windows C盘迁移方案是否需要用户确认；
4. 所有 in_review 任务逐项收口建议；
5. 21 个 done 未归档任务的分批归档建议；
6. inbox_loop unknown 修复建议；
7. status_mismatch 8 处差异清单；
8. TASK-20260510-012 ghost task 处理建议。

## 002 必须输出

### A. 重复/测试任务

输出 LEE-23、LEE-25、LEE-26 的状态、报告、是否重复、建议保留/关闭哪一个、是否需要用户确认。

默认方向：LEE-26 已 done 且报告完整时，保留 LEE-26；LEE-25 建议关闭为 duplicate。

### B. LEE-31 决策清单

输出表格：

| 决策项 | 当前事实 | 风险 | 建议 | 是否需要用户确认 |
|---|---|---|---|---|

必须说明哪些 C 盘内容建议迁移，哪些不能迁移，哪些需备份，哪些需 Kimi Claw 或数据专家补证。

### C. Review backlog 逐项清单

输出表格：

| LEE | 标题 | Agent | 状态 | 分类 | 报告路径 | Wiki路径 | 缺口 | 建议动作 | 是否需要用户确认 |
|---|---|---|---|---|---|---|---|---|---|

分类只能用：review_ready、review_missing_report、review_missing_github、review_missing_knowledge、review_need_manual_decision、review_blocked、review_stuck、duplicate。

### D. Done 未归档分批建议

不要一次性归档全部 done。按三批输出：

- A批：历史沙箱/测试任务；
- B批：已沉淀知识的基础设施任务；
- C批：5月10日核心任务，暂时保留 done，等待总报告。

输出表格：

| LEE | 标题 | 批次 | 报告 | Wiki | 建议 | 风险 |
|---|---|---|---|---|---|---|

### E. 状态差异清单

列出 8 处 status_mismatch：

| 对象 | GitHub/本地状态 | Multica状态 | 差异类型 | 建议同步方向 |
|---|---|---|---|---|

原则：Multica 是运行真相，GitHub/本地是状态快照。

### F. inbox_loop unknown 修复建议

说明 inbox_loop 为什么 unknown、PocketClaw 退出后 Runtime首脑是否接管、是否依赖 Command Gateway、是否需要 Codex 实现。

## 003 输出路径

更新：

```text
/root/multica-work/output/Runtime首脑治理报告.md
/root/wiki/20-resources/runtime-governor-report.md
```

并推送 GitHub。

## 004 边界

只输出建议和清单。不得改生产、不得改 Dolphin/DataX、不得自动关闭、不得自动验收、不得自动归档、不得自动重试、不得删除任务文件、不得写入密钥。