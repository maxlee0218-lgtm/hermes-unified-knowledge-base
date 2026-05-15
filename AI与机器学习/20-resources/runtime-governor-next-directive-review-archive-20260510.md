# Runtime Governor 下一轮治理指令：review 与 archive 收口

> 创建时间：2026-05-10  
> 发起方：ChatGPT  
> 接收方：Runtime首脑  
> 状态：生效  
> 原则：只读分析，输出逐任务治理清单；禁止自动关闭、自动验收、自动归档、自动 retry、自动恢复、生产变更。

---

## 001 当前任务

下一轮 Runtime Governor 巡检必须直接输出逐任务治理清单，不再只输出总数。

重点处理：

1. LEE-25 / LEE-26 重复任务判断；
2. 7 个 in_review 任务逐项收口建议；
3. 20 个 done 任务逐项归档建议；
4. 本地 active 文件 8 个 vs Multica active 3 个的状态漂移清单；
5. inbox_loop unknown 的修复建议。

---

## 002 LEE-25 / LEE-26 重复任务

必须输出：

- LEE-25 标题、状态、Agent、报告状态；
- LEE-26 标题、状态、Agent、报告状态；
- 二者是否重复；
- 哪个应保留；
- 哪个建议取消/关闭；
- 风险；
- 是否需要用户确认。

默认判断方向：

```text
如果 LEE-26 已 done 且报告完整，LEE-25 与其标题/目标重复，则建议取消 LEE-25，保留 LEE-26。
```

仅输出建议，不自动关闭。

---

## 003 7 个 in_review 任务逐项治理

必须输出表格：

| LEE | 标题 | Agent | 状态 | 是否有报告 | 报告路径 | 是否有 Wiki/GitHub | 分类 | 建议动作 | 是否需要用户确认 |
|---|---|---|---|---|---|---|---|---|---|

分类只能使用：

- review_ready
- review_missing_report
- review_missing_github
- review_missing_knowledge
- review_need_manual_decision
- review_blocked
- review_stuck

必须明确：

- 哪些可以验收；
- 哪些缺报告；
- 哪些缺 GitHub/Wiki；
- 哪些需要用户拍板；
- 哪些建议 blocked；
- 哪些是重复任务。

---

## 004 20 个 done 任务逐项归档建议

必须输出表格：

| LEE | 标题 | Agent | done时间 | 是否有报告 | 是否有 Wiki/GitHub | 本地done是否存在 | archived是否存在 | 建议 |
|---|---|---|---|---|---|---|---|---|

建议只能使用：

- archive_ready
- archive_missing_report
- archive_missing_wiki
- archive_conflict
- keep_done

禁止自动归档。

---

## 005 状态漂移清单

必须输出：

- 本地 active 文件清单；
- Multica active Issue 清单；
- 本地 active 但 Multica 非 active 的任务；
- Multica active 但本地 active 缺失的任务；
- 建议以 Multica 为准的同步动作；
- 是否需要用户确认。

---

## 006 heartbeat / inbox_loop 修复建议

必须输出：

- 当前 heartbeat.updated_at；
- inbox_loop.status 当前值；
- 为什么是 unknown；
- Runtime首脑是否应接管 inbox 状态；
- 修复步骤草案；
- 风险。

仅输出建议，不直接改脚本。

---

## 007 输出路径

更新：

```text
/root/multica-work/output/Runtime首脑治理报告.md
/root/wiki/20-resources/runtime-governor-report.md
```

并提交 GitHub。

---

## 008 严格禁止

- 不自动关闭 LEE-25；
- 不自动验收任何 review；
- 不自动归档 done；
- 不自动 retry；
- 不自动恢复；
- 不修改生产数据库；
- 不修改 DolphinScheduler；
- 不修改 DataX；
- 不删除任务文件；
- 不 force push；
- 不写入密码/token/连接串/密钥。
