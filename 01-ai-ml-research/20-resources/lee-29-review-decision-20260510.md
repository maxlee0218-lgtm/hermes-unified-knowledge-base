# LEE-29 验收判断与下一步收口指令

> 创建时间：2026-05-10  
> 裁决方：ChatGPT  
> 对象：LEE-29 数仓重构前全量摸排与资料通读  
> 当前判断：完成只读摸排，但不具备最终验收条件。

---

## 001 当前判断

LEE-29 已完成只读摸排，已有输出文件：

- /root/multica-work/output/20260510-数仓重构前全量摸排基线报告.md
- /root/wiki/20-resources/warehouse-rebuild-pre-inventory.md
- /root/multica-work/output/20260510-历史报告清单与关键结论摘要.md

但仍存在 7 个待确认问题，因此不能直接进入最终 done/archived。

当前状态应保持：

```text
review_need_manual_decision
```

---

## 002 七个待确认问题

1. Windows PC 当前实际状态：需修复或替代通道；
2. 111 遗留服务是否仍在运行：无法 SSH 验证；
3. 是否确认 ADS_SC_XL_13 作为第一条样板链路；
4. DataX 增量策略和物理删除处理方式需与运维确认；
5. DolphinScheduler 工作流全景清单需 Windows 智能体执行；
6. ADS 表消费端依赖图谱需业务确认；
7. 验收标准和回滚方案需用户评审。

---

## 003 ChatGPT 裁决

### 可确认

- ADS_SC_XL_13 暂定为第一条样板链路；
- 生产不动；
- Windows 测试环境先行；
- AI 只建议，不自动改生产；
- DataX / Dolphin 当前不替换；
- dbt 只做旁路建模、测试、文档、血缘；
- 速程监控作为生产数据护栏。

### 不能直接确认

以下问题必须继续由 Runtime首脑 协调执行节点补证：

- Windows PC 实际状态；
- 111 遗留服务状态；
- DolphinScheduler 工作流全景；
- ADS 消费端依赖；
- DataX 物理删除与增量策略当前真实配置。

---

## 004 下一步指令

Runtime首脑 下一轮请将 LEE-29 拆成补证清单，不要继续泛化研究。

必须输出：

| 待确认项 | 应由谁处理 | 是否只读 | 输出路径 | 阻断等级 | 建议动作 |
|---|---|---|---|---|---|

建议分工：

- Windows PC 状态：Kimi Claw / 数据专家；
- 111 遗留服务：数仓管家 / 运维只读验证；
- Dolphin 工作流全景：数仓管家；
- ADS 消费端依赖：数仓管家 + 数据专家；
- DataX 增量与物理删除：数仓管家；
- 验收标准与回滚方案：ChatGPT 裁决。

---

## 005 禁止事项

- 不自动修改生产；
- 不自动修复 111；
- 不自动重跑 Dolphin；
- 不自动修改 DataX；
- 不自动上线；
- 不自动关闭 LEE-29；
- 不自动归档 LEE-29。

---

## 006 当前状态

```text
LEE-29 = review_need_manual_decision / waiting for evidence closure
```

等补证清单返回后，再判断是否允许 LEE-29 done。
