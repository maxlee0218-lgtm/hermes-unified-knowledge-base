# Runtime 第二阶段：归档与质量收口任务

时间：2026-05-10
发起方：ChatGPT
接收方：Runtime首脑
状态：用户已批准
模式：低风险状态治理；只处理 Runtime 状态、报告、归档摘要、知识缺口，不处理生产系统。

## 001 当前背景

第一阶段已验证：

- GitHub command file -> Windows gateway -> Multica CLI -> Multica Issue 链路已跑通；
- approved 测试已成功创建 LEE-49；
- review backlog 已从 7 降为 0；
- 当前主问题已从 review 堆积转为 done / blocked / archived / heartbeat / 知识沉淀治理。

## 002 当前目标

本轮目标：完成 Runtime 第二阶段收口。

重点处理：

1. DRY-RUN 测试任务归档建议；
2. blocked 任务逐项处理建议；
3. done=32 的分批归档摘要；
4. 缺失报告与 Wiki 的补齐清单；
5. inbox 残留与 GitHub active 残留同步建议；
6. heartbeat inbox_loop unknown 修复建议；
7. 更新 Runtime 治理报告。

## 003 允许执行的低风险动作

Runtime首脑允许执行：

1. 对测试任务生成归档摘要；
2. 对已完成任务生成归档摘要；
3. 标记测试任务为 archive_ready 或等价待归档状态；
4. 对 blocked 任务写明处理建议；
5. 对缺报告/缺 Wiki 任务生成补齐清单；
6. 对 inbox 残留、active 残留生成同步建议；
7. 更新 heartbeat 中 Runtime Governor 字段；
8. 更新 runtime-governor-report.md；
9. 写入 GitHub commit。

如 Multica 当前支持官方 archived 状态，必须先确认 `multica issue update --help` 和已有状态枚举；不确定时不要真实改 archived，只输出 archive_ready 清单。

## 004 本轮优先处理对象

### A. 测试任务归档候选

以下任务是 Runtime / Command Gateway / DRY-RUN 路径测试任务，优先生成归档摘要：

- LEE-37
- LEE-40
- LEE-41
- LEE-42
- LEE-43
- LEE-44
- LEE-49

要求输出：

| Issue | 标题 | 当前状态 | 是否测试任务 | 是否通过 | 建议 |
|---|---|---|---|---|---|

### B. blocked 任务治理

对当前 blocked 任务逐项输出：

| Issue | 标题 | blocked原因 | 是否预期blocked | 建议动作 | 是否需要用户确认 |
|---|---|---|---|---|---|

重点：

- LEE-23：历史测试/重复任务，建议废弃或归档；
- LEE-38：验收官批量验收失败，建议改为顺序验收规则；
- LEE-41/42/43：如为预期 blocked 测试，归入测试归档候选；
- 其他 blocked 任务按事实分类。

### C. done 分批归档摘要

对 32 个 done 任务分三批：

- A批：测试/沙箱/链路验证任务；
- B批：基础设施/机制建设任务；
- C批：数仓重构核心知识任务，暂缓归档，先补齐报告/Wiki。

输出：

| Issue | 标题 | 批次 | 报告 | Wiki | 建议 | 风险 |
|---|---|---|---|---|---|---|

### D. 缺失报告与 Wiki 补齐清单

重点核查：

- LEE-29
- LEE-30
- LEE-31
- LEE-32
- LEE-24

输出：

| Issue | 缺失报告 | 缺失Wiki | 当前证据 | 责任角色 | 下一步 |
|---|---|---|---|---|---|

### E. 状态同步建议

输出：

- GitHub inbox 残留清单；
- GitHub active 残留清单；
- Multica 当前真实状态；
- 建议同步方向；
- 是否需要真实移动文件；
- 是否需要用户确认。

### F. heartbeat 修复建议

必须说明：

- inbox_loop 当前为什么 unknown；
- Runtime首脑 是否正式成为 owner；
- 最小修复动作；
- 修复后字段格式；
- 是否需要 Codex 修脚本；
- 风险。

## 005 严格禁止

- 不修改生产数据库；
- 不修改 PolarDB；
- 不修改 DolphinScheduler；
- 不修改 DataX；
- 不重跑生产任务；
- 不自动补数；
- 不自动上线；
- 不修改 Multica 框架源码；
- 不修改 Multica daemon；
- 不修改 Multica 配置；
- 不修改 Multica 数据库；
- 不删除业务文件；
- 不读取或写入密钥原文；
- 不 force push。

## 006 输出文件

必须更新：

```text
/root/wiki/20-resources/runtime-governor-report.md
```

必须新增：

```text
/root/wiki/20-resources/runtime-phase2-archive-quality-closure-report.md
```

如生成归档摘要，建议输出：

```text
/root/wiki/20-resources/runtime-archive-candidates-20260510.md
```

## 007 验收标准

执行完成后必须看到：

1. 测试任务归档候选清单；
2. blocked 任务逐项治理建议；
3. done=32 分批归档摘要；
4. 缺失报告/Wiki 补齐清单；
5. inbox/active 残留同步建议；
6. heartbeat inbox_loop owner 修复建议；
7. runtime-governor-report.md 已更新；
8. GitHub commit id；
9. 未触碰生产；
10. 未修改 Multica 框架。
