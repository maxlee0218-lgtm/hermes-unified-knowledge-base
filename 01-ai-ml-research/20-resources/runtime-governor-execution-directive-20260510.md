# Runtime Governor 执行指令：收口 review/archive 并接入 Kimi Claw

> 创建时间：2026-05-10  
> 发起方：ChatGPT  
> 接收方：Runtime首脑  
> 状态：生效  
> 模式：DRY-RUN 优先；允许做状态建议与登记；禁止生产变更。

---

## 001 当前目标

Runtime首脑继续推进两条主线：

1. 收口 Runtime 生命周期治理：review / done / archived / ghost / drift；
2. 接入 Windows Kimi Claw：登记为 Windows 本地只读 Worker，完成握手验证。

---

## 002 第一优先级：review/archive 收口

请基于最新 Multica Issue 状态直接输出并推进以下治理建议：

### A. review_ready

对 LEE-32 / LEE-33 / LEE-34 / LEE-35 执行验收前检查：

- 报告是否存在；
- Wiki 是否沉淀；
- GitHub 是否更新；
- 是否包含敏感信息；
- 是否存在生产变更风险；
- 是否建议标记 done。

只输出建议，不自动标记 done，除非用户后续明确授权。

### B. 重复任务

对 LEE-25 与 LEE-26 执行重复确认：

- 如果 LEE-26 已 done 且报告完整；
- LEE-25 与 LEE-26 目标重复；

则建议关闭 LEE-25。

只输出建议，不自动关闭。

### C. Ghost Task

对 TASK-20260510-012 执行 ghost 处理判断：

- 是否本地 active 存在；
- 是否无 Multica Issue；
- 是否已由 Runtime Governor 替代完成原始目标；
- 是否建议归档。

只输出建议，不自动删除或归档。

### D. Done Archive

对 Multica done 任务输出 archive_ready 清单：

- 只列出 5月9日历史任务；
- 检查报告与 Wiki；
- 输出建议归档清单；
- 保留 5月10日核心任务暂不归档。

---

## 003 第二优先级：Kimi Claw 接入 Multica

请读取以下方案：

```text
/root/wiki/20-resources/windows-kimi-claw-multica-onboarding-20260510.md
```

然后输出 Kimi Claw 接入任务登记建议。

### 必须输出

1. Kimi Claw 在 Multica 中的建议角色名；
2. 是否作为独立 Agent 或 Worker 登记；
3. 允许动作；
4. 禁止动作；
5. 第一次握手任务内容；
6. 握手报告路径；
7. 需要用户在 Windows 上确认的最少事项。

### 严格边界

Kimi Claw 只能作为 Windows 本地只读 Worker：

- 不改生产；
- 不重跑生产；
- 不删文件；
- 不读密钥原文；
- 不写入 token/密码/连接串；
- 不绕过 Runtime首脑；
- 不绕过 ChatGPT。

---

## 004 输出路径

请更新：

```text
/root/multica-work/output/Runtime首脑治理报告.md
/root/wiki/20-resources/runtime-governor-report.md
```

并新增或更新：

```text
/root/wiki/20-resources/kimi-claw-windows-worker-handshake.md
```

---

## 005 输出格式

必须输出：

```text
001 本次检查时间
002 review_ready 验收建议
003 LEE-25/LEE-26 重复任务建议
004 TASK-012 ghost task 建议
005 done/archive 建议清单
006 Kimi Claw 接入建议
007 需要用户人工决策的问题
008 下一步动作
```

---

## 006 严格禁止

- 不自动验收；
- 不自动关闭；
- 不自动归档；
- 不自动 retry；
- 不自动恢复；
- 不修改生产数据库；
- 不修改 PolarDB；
- 不修改 DolphinScheduler；
- 不修改 DataX；
- 不删除文件；
- 不 force push；
- 不写入密码/token/连接串/密钥。
