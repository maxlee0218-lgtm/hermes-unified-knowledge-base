# Multica Runtime首脑接管授权记录

> 授权时间：2026-05-10  
> 授权人：用户  
> 状态：生效  
> 范围：inbox / review / heartbeat 三类状态同步  
> 阶段：DRY-RUN 优先，正式接管需先验收

---

## 一、用户授权

用户已明确允许：

```text
Multica Runtime首脑接管 inbox / review / heartbeat 三类状态同步。
```

用户已在 Multica 中新建：

```text
Runtime首脑
```

---

## 二、接管原则

当前阶段为 DRY-RUN 接管，不是生产变更。

Runtime首脑可以：

- 读取 GitHub llm-wiki；
- 读取 /root/wiki/tasks；
- 读取 Multica Issue 状态；
- 识别 GitHub inbox 与 Multica Issue 差异；
- 识别 active / review / done / blocked / failed；
- 识别 review_stuck；
- 识别 active 超时；
- 生成 heartbeat 标准结构；
- 生成待用户决策清单；
- 输出 DRY-RUN 报告。

Runtime首脑暂时不得：

- 自动关闭任务；
- 自动验收任务；
- 自动 retry；
- 自动 restart；
- 自动恢复服务；
- 修改生产数据库；
- 修改 DolphinScheduler；
- 修改 DataX；
- 删除任务文件；
- force push；
- 写入密码、token、连接串、密钥。

---

## 三、当前必须优先解决的问题

1. GitHub inbox 中任务未稳定进入 Multica；
2. TASK-20260510-012 仍需确认是否进入 Runtime 管理；
3. heartbeat.json 当前仍为旧结构；
4. review_loop_status.json 未正确统计 Multica 待审核任务；
5. PocketClaw 不再作为主链路依赖；
6. Multica 需要成为运行期唯一状态真相。

---

## 四、第一阶段验收标准

Runtime首脑第一阶段必须输出：

- GitHub inbox 任务清单；
- Multica active / review / done / blocked / failed 数量；
- GitHub inbox 未进入 Multica 的任务；
- Multica in_review 未同步 GitHub/status 的任务；
- active 超时任务；
- done 未归档任务；
- heartbeat 标准结构草案；
- Runtime首脑最小状态机；
- 从 PocketClaw 迁移到 Multica 的正式启用步骤。

---

## 五、当前架构裁决

```text
ChatGPT = 用户唯一入口 / 业务方案裁决
Multica Runtime首脑 = 运行期状态中枢
GitHub = 版本化记录 / 知识库
执行 Agent = 数据专家 / 数仓管家 / 深度研究智能体
PocketClaw = 退出主链路，仅保留临时备用
```
