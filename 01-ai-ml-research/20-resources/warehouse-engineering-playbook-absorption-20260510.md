# Warehouse Engineering Playbook 吸收沉淀

> 来源仓库：https://github.com/maxlee0218-lgtm/warehouse-engineering-playbook  
> 吸收时间：2026-05-10  
> 用途：纳入数仓重构、Runtime 治理、Agent 协同开发的工程基线。

---

## 001 总体定位

`warehouse-engineering-playbook` 不是聊天记录归档，而是把真实数仓工作中的经验、排查流程、SQL 模式、调度治理、安全规则沉淀成可复用工程实践。

核心目标：

```text
把一次性的数仓排障经验
转成可重复、可审计、可交给 Agent 执行的工程流程。
```

---

## 002 核心原则

吸收为当前数仓重构工程原则：

1. 先查数据，再改逻辑；截图是症状，源表是证据。
2. 不轻易改业务口径；优先优化数据形态、索引、幂等性、刷新范围。
3. 只修最小确认范围；不要轻易做全历史变更。
4. 归档表默认是证据和基线，不能随意修。
5. 破坏性修复前必须备份影响行。
6. 验证总数，也要验证行粒度；总数对不代表报表行不重复。

---

## 003 标准排查流程

后续数仓问题统一按此流程：

```text
001 捕获症状：报表、日期、筛选条件、截图、期望、实际
002 找到报表 SQL 和 ADS 物理表
003 在 ADS 直接复现同一范围
004 追踪 Dolphin/DataX 任务与 ODS/DWD 来源
005 对比历史归档或已认可基线
006 分类问题：源数据、SQL逻辑、调度重叠、非幂等、索引/锁、展示粒度
007 选择最小安全修复
008 验证行数、汇总、重复、标签、重跑稳定性
```

---

## 004 Dolphin / DataX 调查规则

后续不要靠任务名猜测，要用元数据定位真实任务：

- 搜索 Dolphin 任务定义中的 SQL / 参数；
- 通过流程-任务关系找工作流；
- 检查调度、发布状态、实例失败、重试、长运行；
- DataX 重点看 reader 表、主键、增量字段、执行参数。

常见故障模式：

- SQL 非幂等，重跑主键冲突；
- 两个调度或手工运行重叠；
- 下游 ADS 早于上游 DataX/DWD 完成；
- 全表 UPDATE/DELETE 导致锁和慢报表；
- 任务 SQL 更新但历史快照未刷新；
- 字符集/排序规则不一致导致 join 失败。

安全刷新优先使用窗口刷新：

```sql
DELETE FROM target_table
WHERE business_date >= CURRENT_DATE - INTERVAL 7 DAY;

INSERT INTO target_table (...)
SELECT ...
WHERE business_date >= CURRENT_DATE - INTERVAL 7 DAY;
```

---

## 005 SQL 性能规则

性能问题先判断：

```text
扫太多？join太宽？排序太重？等锁？逻辑错还是执行计划差？
```

索引原则：

- 组合索引先等值过滤，再范围过滤，再 join/group 字段；
- 不要无证据给热 ODS 表加大量宽索引；
- 临时表/中间表参与 join 时也要考虑索引；
- DELETE 按 data_date 刷新，必须关注 date 字段索引；
- 报表更新要按真实 join 粒度建索引。

高风险反模式：

- 无日期窗口的全表 UPDATE；
- 小时任务全表 DELETE；
- 有稳定 ID 却按展示名 join；
- 聚合粒度和目标表更新粒度不一致；
- 隐藏维度造成展示行重复。

---

## 006 报表验证规则

报表问题不是 SQL 跑通就算修好，而是渲染后的报表符合业务含义才算修好。

必须同时验证：

```text
数字正确性
+ 展示粒度正确性
```

归档对比流程：

1. 找到该报表和期间的最新认可归档批次；
2. 用归档行重建新口径；
3. 对比可见列和合计；
4. 标签合并后验证展示粒度；
5. 用差异反推当前 ADS/任务逻辑。

重复粒度检查模板：

```sql
SELECT business_date, product_name, display_bucket, COUNT(*) AS row_count
FROM report_source
GROUP BY business_date, product_name, display_bucket
HAVING COUNT(*) > 1;
```

---

## 007 监控工作台方向

数仓监控不是摆状态数字，而是帮助开发者定位问题。

有效页面：

- Overview：失败、运行中、最新异常、未处理告警；
- DataX：任务状态、reader 表、主键、增量字段、执行参数；
- Dolphin：工作流实例、任务实例、日志路径、重试、host、耗时；
- Lineage Search：表名反查 DataX、Dolphin、治理阶段、资产快照；
- Governance Alerts：严重等级、链路、阶段、异常类型；
- Asset Health：行数、延迟、零行、重复、空值、对账。

关键工程原则：

- 昂贵状态要缓存；
- 前端不要 30 秒直连生产库；
- 最近执行与告警可进 SQLite；
- 告警要做 fingerprint，避免重复刷屏；
- 空状态和离线状态也要解释清楚。

---

## 008 安全脱敏规则

提交 Git 前必须替换：

```text
<db-host>
<db-port>
<db-user>
<db-password>
<server-ip>
<ssh-user>
<api-token>
```

通常可以保留：

- 表名；
- 报表名；
- 工作流/任务名；
- 脱敏 SQL 模式；
- 聚合行数。

通常不安全：

- 密码；
- 连接串；
- 带用户名的公网 IP；
- 员工个人记录；
- 原始证书/人员导出；
- token / cookie / SSH 私钥。

提交前扫描：

```bash
rg -n "password|passwd|pwd|secret|token|BEGIN .*PRIVATE KEY|ssh-rsa|aliyuncs|root@|admin|da_user|hw_dev" .
```

---

## 009 对当前数仓重构的吸收结论

当前 `ADS_SC_XL_13` 重构必须按 playbook 改造：

```text
先复现 → 再追链路 → 再定口径 → 再做旁路 → 再验证 → 再人工上线
```

不允许：

```text
看到 SQL 就直接改
看到慢就乱加索引
看到差异就补数
看到异常就重跑生产
```

必须形成：

- 链路图；
- 任务来源；
- DataX 增量策略；
- Dolphin 调度依赖；
- ADS 指标口径；
- 报表展示粒度；
- 归档/基线对比；
- 回滚方案；
- 监控护栏。

---

## 010 对 Agent 的执行要求

后续所有数据专家、数仓管家、Kimi Claw、Runtime首脑 相关任务都必须遵守：

```text
只读优先
证据优先
最小范围
先报告后修改
生产变更人工确认
敏感信息不进 Git
```

Runtime首脑 要把该 playbook 作为数仓类任务的默认验收标准。

---

## 011 下一步建议

1. 将该文档纳入 Runtime首脑 的数仓类任务验收标准；
2. 将 `ADS_SC_XL_13` 样板链路重构计划按该 playbook 重写；
3. 要求数据专家输出链路摸排时必须包含：源表、任务、调度、口径、验证 SQL、风险；
4. 要求数仓管家输出变更方案时必须包含：影响范围、备份、验证、回滚、监控；
5. 在 Windows 测试环境优先实现报表验证与监控护栏，不先动生产。
