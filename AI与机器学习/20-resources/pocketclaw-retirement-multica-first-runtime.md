# PocketClaw 退出主链路：Multica First Runtime 架构裁决

> 创建时间：2026-05-10  
> 状态：生效  
> 裁决层：ChatGPT  
> 适用范围：数仓重构、Agent协同、任务生命周期、review收口、heartbeat、异常治理

---

## 一、架构裁决

PocketClaw 不再作为 Agent Runtime 主入口、主调度、主状态中枢或 review 收口机制。

后续尽量全部使用 Multica 承担运行期任务生命周期管理。

PocketClaw 可保留为临时备用触发器，但从主链路中剔除。

---

## 二、原因

当前已暴露的问题：

1. GitHub inbox 中存在任务，但 PocketClaw 未能稳定拉走；
2. heartbeat.json 未能稳定更新；
3. review loop 只看本地目录，未准确反映 Multica 真实 review 状态；
4. Multica 后台已有待审核堆积，但 GitHub/status 未同步；
5. 任务入口、状态、验收、异常分散在 PocketClaw / GitHub / Multica 三处，造成状态不一致；
6. PocketClaw 适合触发脚本，不适合作为 Runtime 状态机。

结论：

```text
Multica 是运行真相。
GitHub 是版本化记录。
ChatGPT 是方案裁决与用户入口。
PocketClaw 退出主链路。
```

---

## 三、新架构定位

### ChatGPT

- 用户唯一入口；
- 业务方案裁决；
- 任务设计；
- 阶段判断；
- Go / Conditional Go / No-Go；
- 统一验收收敛。

### Multica Runtime首脑

- 任务生命周期中枢；
- 扫描 GitHub 任务入口；
- 创建和维护 Multica Issue；
- 以 Multica Issue 状态为准；
- 识别 active / in_review / done / blocked / failed；
- 生成待审核清单；
- 生成异常清单；
- 更新 GitHub status 与 heartbeat；
- 生成用户决策清单。

### GitHub / LLM Wiki

- 业务方案版本化；
- 任务记录版本化；
- 知识沉淀；
- 报告归档；
- ADR / 决策记录。

### 执行 Agent

- 数据专家；
- 数仓管家；
- 深度研究智能体。

它们只执行具体任务，不做最终业务裁决。

### PocketClaw

- 不再承担主链路；
- 不再承担 review 判断；
- 不再作为 heartbeat 唯一来源；
- 不再作为任务收口机制；
- 可暂时保留为人工触发或备用兜底。

---

## 四、迁移原则

### 4.1 先建 Multica Runtime首脑

必须先在 Multica 中建立 Runtime首脑，使其能读取 GitHub、读取 Multica Issue 状态、输出差异报告。

### 4.2 先 DRY-RUN

Runtime首脑第一阶段只做只读巡检：

- 不自动验收；
- 不自动关闭；
- 不自动重试；
- 不自动恢复；
- 不自动修改生产；
- 不删除文件。

### 4.3 再接管入口

确认 DRY-RUN 正常后，Runtime首脑接管：

- GitHub inbox 扫描；
- Multica Issue 创建；
- status 反写；
- heartbeat 反写；
- review 堆积识别；
- 异常升级。

### 4.4 最后停用 PocketClaw

当 Multica Runtime首脑连续多轮稳定后，停用 PocketClaw 的：

- 10分钟 inbox 检查；
- 5分钟 review 检查；
- heartbeat 相关任务。

---

## 五、严格禁止

Runtime首脑不得执行：

- 修改生产数据库；
- 修改 PolarDB；
- 修改 DolphinScheduler；
- 修改 DataX；
- 重跑生产任务；
- 自动上线；
- 自动补数；
- 自动恢复服务；
- 自动关闭任务；
- 自动验收任务；
- 自动 retry；
- 删除任务文件；
- force push；
- 写入密码、token、连接串、密钥。

---

## 六、当前待处理问题

当前必须优先处理：

1. TASK-20260510-012 仍在 GitHub inbox，未进入 active，未生成 status；
2. heartbeat.json 仍为旧结构，未反映真实 loop 状态；
3. review_loop_status.json 未统计 Multica 待审核任务；
4. PocketClaw 触发不再作为主线依赖；
5. 需要 Multica Runtime首脑直接接管巡检和状态同步。

---

## 七、当前结论

```text
停止继续修 PocketClaw 主链路。
建立 Multica Runtime首脑。
Multica 成为运行期唯一状态真相。
GitHub 成为版本化记录与知识库。
ChatGPT 继续作为用户唯一入口和方案裁决层。
```
