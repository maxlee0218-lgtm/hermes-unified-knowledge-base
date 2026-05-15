# with_attr_value warehouse / document type Closure

## 1. 本轮目标

本轮只验证：

- `with_attr_value` 在 `ADS_SC_XL_13` 中与仓库 scene 的关系
- `with_attr_value` 在 `ADS_SC_XL_13` 中与单据类型 scene 的关系

目标不是臆造一条完整生产链，而是把下面几件事收清：

- 哪些 scene family 已经被稳定链实际消费
- 哪些事实字段是仓库 / 单据类型映射的候选 join key
- 哪些结论已经有证据
- 哪些地方仍然只能标 `pending_execution` 或 `needs_business_clarification`

## 2. 已读取的依据文件

- `README.md`
- `docs/01_current_status.md`
- `docs/04_codex_cli_handoff.md`
  - 状态：`not_found`
- `docs/08_automation_registry.md`
- `docs/09_execution_wip_policy.md`
- `docs/10_executor_no_midpoint_prompt_policy.md`
- `lineage/ads_sc_xl_13/01_main_chain.md`
- `lineage/ads_sc_xl_13/02_supporting_chains.md`
- `lineage/ads_sc_xl_13/05_missing_links.md`
- `lineage/ads_sc_xl_13/06_next_rebuild_order.md`
- `lineage/ads_sc_xl_13/supporting/with_attr_value_scene_matrix.md`
- `lineage/ads_sc_xl_13/supporting/with_attr_value_attr1_manuf_line_name_closure.md`
- `sql/inspect/ads_sc_xl_13/inspect_with_attr_value.sql`
- `sql/inspect/ads_sc_xl_13/inspect_with_attr_value_attr1_manuf_line_name.sql`
- `sql/recon/ads_sc_xl_13/recon_with_attr_value_mapping.sql`
- `sql/recon/ads_sc_xl_13/recon_with_attr_value_attr1_manuf_line_name.sql`
- `audit/ads_sc_xl_13/runs/20260426_132217/00_run_summary.md`
- `sql/source/ads_sc_xl_13/09_ads_sc_xl_01_source_snapshot.sql`
- `audit/ads_sc_xl_13/runs/20260426_090204/source_docs/dolphin-process-chain-18340742659072.md`

## 3. 当前已经坐实的事实

### 3.1 `with_attr_value` 的角色

- `with_attr_value` 是配置 / 映射表
- 它不是单一 ODS 镜像
- `scene` 是业务 / 报表场景，而不是统一语义字典
- `attribute1..attribute7` 是通用槽位，不能跨 scene 直接假设固定业务含义

### 3.2 这轮和哪条稳定链直接相关

当前和仓库 / 单据类型 scene 关联最强的稳定链是：

- workflow `18340742659072` `入库单`
- task `18340742659074` `ads_sc_xl_01(入库量)`

当前证据里已经明确：

- `ads_sc_xl_01` 来源快照包含
  - `bill_type`
  - `wh_code`
  - `dept_code`
  - `machine_code`
  - `other_machine_code`
  - `rd_style`
  - `rd_style_name`
- `入库单` 工作流读取表里已经包含：
  - `with_attr_value`
  - `dwd_mes_wms_wh_enter_item`
  - `dwd_silicon_steel_surface_info`
  - `dim_ums_tenant`

## 4. 仓库 scene 闭环

### 4.1 已知 scene family

当前仓库证据已经明确指向：

- `BI-SC-KC-013-WH-CODE-*`

### 4.2 当前影响对象

- `ads_sc_xl_01`
- 生产入库量
- 成品入库量

### 4.3 当前候选 join 字段

只能安全收成候选，不应臆造固定语义：

- 事实侧字段：
  - `tenant_id`
  - `wh_code`
  - `dept_code`
  - `machine_code`
  - `other_machine_code`
  - `steel_grade`
  - `sku_code`
- 映射侧字段：
  - `tenant_id`
  - `attribute1`
  - `attribute2`
  - `attribute3`
  - `attribute4`
  - `attribute5`
  - `attribute6`
  - `scene`

### 4.4 当前能下到什么结论

- 可以确认：
  - 仓库 scene family 已被现网稳定链消费
  - 它会影响哪些仓库记录进入 `ads_sc_xl_01`
- 不能确认：
  - `attribute1..attribute6` 在所有 `BI-SC-KC-013-WH-CODE-*` scene 中的统一含义

所以这部分当前状态只能是：

- 证据状态：`partial`
- 执行状态：`pending_execution`

## 5. 单据类型 scene 闭环

### 5.1 已知 scene family

当前仓库证据已经明确指向：

- `BI-SC-KC-013-RD-FINISHED-*`

### 5.2 当前影响对象

- `ads_sc_xl_01`
- 成品入库量

### 5.3 当前候选 join 字段

- 事实侧字段：
  - `tenant_id`
  - `rd_style`
  - `rd_style_name`
  - `bill_type`
- 映射侧字段：
  - `tenant_id`
  - `attribute1`
  - `attribute2`
  - `attribute3`
  - `scene`

### 5.4 当前能下到什么结论

- 可以确认：
  - 单据类型 scene family 已被现网稳定链消费
  - 它决定哪些 `rd_style / rd_style_name` 纳入成品入库统计
- 不能确认：
  - `rd_style` 和 `rd_style_name` 分别落在哪个 `attribute*` 槽位
  - 是否存在按 `bill_type` 的额外过滤分支

所以这部分当前状态只能是：

- 证据状态：`partial`
- 执行状态：`pending_execution`

## 6. 不能跨 scene 泛化的地方

这轮必须严格保守：

- 不能把 `attribute1 = wh_code` 当成全局事实
- 不能把 `attribute1 = rd_style_name` 当成全局事实
- 不能把 `attr1`、`attribute1`、`scene` 混成一套固定业务语义

如果要验证，只能按：

- `scene family`
- `tenant_id`
- `候选事实字段`
- `候选 attribute 槽位`

做探测式检查。

语义如果不闭合，必须标记：

- `needs_business_clarification`

## 7. 对重构推进的影响

### 7.1 是否可以进入 `ads_sc_xl_01_local`

- **Yes**
- 原因：
  - `ads_sc_xl_01` 的上游事实字段已经锚定
  - 仓库 / 单据类型 scene family 已经锚定
  - 可以开始写本地 join skeleton

限制：

- 仍然只能先做蓝图和 candidate join
- 不能把 scene 语义写死成唯一映射

### 7.2 是否可以进入 `combined_candidate`

- **Yes**
- 原因：
  - `combined_candidate` 可以继续候选评估
  - 当前这轮已经把 `ads_sc_xl_01` 的依赖入口收得更明确

限制：

- 候选推进不等于闭环完成

### 7.3 是否可以进入完整 `combined_local`

- **No**
- 原因：
  - `with_attr_value warehouse/doc_type` 仍是 `partial + pending_execution`
  - `with_result_confirm` 仍未闭合
  - `ads_sc_xl_01_local` 还没真正复刻
  - `合计 / 总计` 后置行还没闭合

## 8. 当前结论

- `with_attr_value` 的仓库 / 单据类型 scene family 已经定位到稳定入库链
- `ads_sc_xl_01_local` 可以进入蓝图阶段
- 但当前仍然不能说 scene 语义已经“闭合完成”

最终状态收口为：

- `with_attr_value warehouse/doc_type status`: `partial`
- `execution status`: `pending_execution`
- `next suggested node`: `ads_sc_xl_01_local`
