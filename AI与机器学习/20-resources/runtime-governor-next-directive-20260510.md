# Runtime Governor 下一轮治理指令

> 创建时间：2026-05-10  
> 发起方：ChatGPT  
> 接收方：Runtime首脑  
> 状态：生效  
> 原则：用户不再手工转发，Runtime首脑自行读取本指令并执行只读治理分析。

---

## 一、当前要求

Runtime首脑下一轮巡检不要只输出状态数量，必须直接推进 review / archive / heartbeat 三个治理闭环。

当前禁止要求不变：

- 不自动验收；
- 不自动关闭；
- 不自动归档；
- 不自动 retry；
- 不自动恢复；
- 不修改生产数据库；
- 不修改 DolphinScheduler；
- 不修改 DataX；
- 不写入密码、token、连接串、密钥。

---

## 二、下一轮只处理三件事

### 001 review_ready 收口清单

列出当前 5 个 review_ready 任务：

- LEE 编号；
- 任务标题；
- Agent；
- 是否有报告；
- 报告路径；
- 是否有 GitHub commit；
- 是否有 Wiki 沉淀；
- 是否建议用户验收；
- 验收风险。

输出目标：给 ChatGPT 一份可直接判断的验收清单。

### 002 LEE-30 缺失报告定位

明确说明：

- LEE-30 当前状态；
- 为什么被判定为 review_missing_report；
- 缺哪个报告；
- 预期报告路径；
- 应由哪个 Agent 补；
- 是否影响其他任务收口；
- 建议处理动作。

### 003 done 状态漂移清单

当前已知状态漂移：

```text
Multica done = 12
本地 done = 4
```

必须输出：

- Multica done 任务清单；
- 本地 done 任务清单；
- 缺失同步任务；
- 是否已有报告；
- 是否已有 Wiki/GitHub 沉淀；
- 是否建议进入 archived；
- 不自动归档，仅输出建议。

---

## 三、输出路径

请更新或生成：

```text
/root/multica-work/output/Runtime首脑治理报告.md
/root/wiki/20-resources/runtime-governor-report.md
```

并推送 GitHub。

---

## 四、输出格式

必须按以下结构输出：

```text
001 本次检查时间
002 review_ready 可验收清单
003 LEE-30 缺失报告定位
004 done 状态漂移清单
005 需要 ChatGPT 判断的问题
006 需要用户人工决策的问题
007 下一步治理建议
```

---

## 五、当前原则

Runtime首脑 和其他 Agent 已具备协同能力，后续不要再要求用户手工转发指令。

ChatGPT 负责写入 GitHub 指令，Runtime首脑负责读取并执行巡检治理。
