# ADS_SC_XL_13 Missing Links

## GAP-001

影响链路：
主链 `dwd_mes_mm_task_group_output -> ads_sc_xl_13_process1`
缺失对象：
`ads_sc_xl_13_process1` 的独立 SQL 源文件归档
已找到证据：
海豚任务 `18333852605954 ADS_SC_XL_13_PROCESS_001`
未找到证据：
独立、稳定、单文件化的 legacy SQL 归档
当前判断：
逻辑已找到，但还需要标准化归档到仓库
是否阻塞重构：
否
下一步怎么查：
继续补充归档 SQL 文件与字段级注释
建议优先级：
P3

## GAP-002

影响链路：
主链 `ads_sc_xl_13_process1 -> ads_sc_xl_13_defined`
缺失对象：
`ads_sc_xl_13_defined` 的独立 SQL 源文件归档
已找到证据：
海豚任务 `18333852605955 ADS_SC_XL_13_DEFINED`
未找到证据：
仓库内单独的 legacy SQL 文件
当前判断：
补零逻辑已定位，但需做标准归档
是否阻塞重构：
否
下一步怎么查：
补充源 SQL 归档
建议优先级：
P3

## GAP-003

影响链路：
主链 `ads_sc_xl_13_defined -> ads_sc_xl_13_defined_manuf_line_name`
缺失对象：
`ads_sc_xl_13_defined_manuf_line_name` 的独立 SQL 源文件归档
已找到证据：
海豚任务 `18333852605956 ADS_SC_XL_13_DEFINED_MANUF_LINE_NAME`
未找到证据：
仓库内单独的 legacy SQL 文件
当前判断：
聚合层逻辑已找到，但需标准归档
是否阻塞重构：
否
下一步怎么查：
补充源 SQL 归档
建议优先级：
P3

## GAP-004

影响链路：
主链 `ads_sc_xl_13_defined_manuf_line_name -> combined`
缺失对象：
`combined` 完整支线叠加后的最终复刻 SQL
已找到证据：
`18333852605959 ADS_SC_XL_13_defined_manuf_line_name_combined`
以及所有支线任务
未找到证据：
单文件化、可一次复现的 `combined_local` SQL
当前判断：
这是当前重构的核心缺口
是否阻塞重构：
是
下一步怎么查：
把支线逐条折叠进 `04_combined.sql`
建议优先级：
P1

## GAP-004A

影响链路：
`defined -> defined_manuf_line_name`
缺失对象：
`defined_manuf_line_name` 的聚合守恒验证
已找到证据：
主链 SQL 明确存在
未找到证据：
完整的 key-level / metric-level 对账结果
当前判断：
pending_execution
是否阻塞重构：
否
下一步怎么查：
执行 `inspect_defined_manuf_line_name_inputs.sql` 与 `recon_defined_manuf_line_name_aggregation.sql`
建议优先级：
P2

## GAP-005

影响链路：
字典链
缺失对象：
`with_attr_value` 完整来源闭环
已找到证据：
大量 Dolphin 任务读取或回写 `with_attr_value`
未找到证据：
单一、明确、完备的生产链
当前判断：
它是配置/映射复合结果，不是简单 ODS 镜像
是否阻塞重构：
是
下一步怎么查：
按 scene 分族补充来源矩阵
建议优先级：
P1

## GAP-005A

影响链路：
`attr1 / manuf_line_name` 主映射链
缺失对象：
`BI-SC-KC-013-DEFINED-TYPE-*` scene 的统一来源闭环
已找到证据：
这些 scene 被 `班组产能` 直接读取
未找到证据：
单一生产任务或单一来源表
当前判断：
pending_execution
是否阻塞重构：
是
下一步怎么查：
按 `scene + tenant + machine_code` 做映射矩阵，并将未知语义标记为 `needs_business_clarification`
建议优先级：
P1

## GAP-005B

影响链路：
仓库 / 单据类型映射链
缺失对象：
`BI-SC-KC-013-WH-CODE-*` 与 `BI-SC-KC-013-RD-FINISHED-*` scene 闭环
已找到证据：
`ads_sc_xl_01`、生产入库量、成品入库量都依赖这些 scene；
`18340742659074 ads_sc_xl_01(入库量)` 的来源快照已经锚定
`wh_code / dept_code / machine_code / other_machine_code / rd_style / rd_style_name`
未找到证据：
已经执行过的 slot-level coverage 结果；
跨 scene 稳定成立的 `attribute* -> 业务字段` 统一语义
当前判断：
`partial + pending_execution`；
scene family 已锚定，但槽位语义仍不能写死
是否阻塞重构：
是
下一步怎么查：
执行
`sql/inspect/ads_sc_xl_13/inspect_with_attr_value_warehouse_doc_type.sql`
与
`sql/recon/ads_sc_xl_13/recon_with_attr_value_warehouse_doc_type.sql`
建议优先级：
P1

## GAP-005C

影响链路：
`ads_sc_xl_01` 依赖映射
缺失对象：
`ads_sc_xl_01` 与 `with_attr_value` 的完整 join 复刻
已找到证据：
`18340742659074 ads_sc_xl_01(入库量)`；
`ads_sc_xl_01_local` 的 join skeleton 和 candidate join 已经落蓝图
未找到证据：
执行过的 slot-level coverage 结果；
最终稳定成立的 scene-local `attribute*` 业务语义
当前判断：
`partial + pending_execution`；
蓝图可执行，但不能把 candidate join 当最终业务闭环
是否阻塞重构：
是
下一步怎么查：
执行
`sql/inspect/ads_sc_xl_13/inspect_ads_sc_xl_01_local.sql`
与
`sql/recon/ads_sc_xl_13/recon_ads_sc_xl_01_local_join.sql`，
并把未知语义保留为 `needs_business_clarification`
建议优先级：
P1

## GAP-005D

影响链路：
`combined` 映射层
缺失对象：
`with_attr_value` 在 `combined` 中的排序/板型/展示映射闭环
已找到证据：
`combined` 直接 join `scene in BI-SC-KC-013-DEFINED-PLATE-*`
未找到证据：
本地 `combined_local` 映射实现
当前判断：
这是 `combined_local` 重构前置
是否阻塞重构：
是
下一步怎么查：
按 `manuf_line_name / plate_type / rk` 对 scene 结果做行级核对
建议优先级：
P1

## GAP-005E

影响链路：
字典生产链
缺失对象：
`with_attr_value` 的完整生产来源
已找到证据：
大量任务读取和个别任务写入 `with_attr_value`
未找到证据：
稳定、单一、可整体回放的生产链
当前判断：
来源生产链不闭合
是否阻塞重构：
部分阻塞
下一步怎么查：
后续结合更多历史仓库或同步层配置继续补证据
建议优先级：
P2

## GAP-006

影响链路：
人工确认链
缺失对象：
`with_result_confirm` 的结构化复刻
已找到证据：
`report_id = 237 / 239 / 543`；
稳定 Dolphin 链已显式使用 `attribute1 / attribute2 / attribute3 / attribute23 / attribute9..13`
未找到证据：
本地已执行的 `with_result_confirm_local` 结果；
字段语义完全经执行验证闭合的本地层
当前判断：
`partial + pending_execution`；
停机时间与备注逻辑高度依赖这张表
是否阻塞重构：
是
下一步怎么查：
执行
`sql/inspect/ads_sc_xl_13/inspect_with_result_confirm_local.sql`
与
`sql/recon/ads_sc_xl_13/recon_with_result_confirm_local.sql`
建议优先级：
P1

## GAP-007

影响链路：
日期骨架链
缺失对象：
`dim_date_info` 补零逻辑的本地复刻
已找到证据：
`ads_sc_xl_13_defined` 明确使用日期骨架
未找到证据：
本地已落的同等补零 SQL
当前判断：
当前 `baseline_only` 零行主要由这一层产生，补零逻辑已基本明确
是否阻塞重构：
否，已调整为可执行待验证
下一步怎么查：
先把 `dim_date_info` 引入本地并复刻日期 x 组合集合 left join
建议优先级：
P2

## GAP-005A

影响链路：
`attr1 / manuf_line_name` 主映射链
缺失对象：
`BI-SC-KC-013-DEFINED-TYPE-*` scene 的统一来源闭环
已找到证据：
这些 scene 被 `班组产能` 直接读取
未找到证据：
单一生产任务或单一来源表
当前判断：
可分段复刻，但来源全貌未单点闭合
是否阻塞重构：
是
下一步怎么查：
按 `scene + tenant + machine_code` 做映射矩阵
建议优先级：
P1

## GAP-005B

影响链路：
仓库 / 单据类型映射链
缺失对象：
`BI-SC-KC-013-WH-CODE-*` 与 `BI-SC-KC-013-RD-FINISHED-*` scene 闭环
已找到证据：
`ads_sc_xl_01`、生产入库量、成品入库量都依赖这些 scene
未找到证据：
本地可重放的完整 mapping SQL
当前判断：
这是 `ads_sc_xl_01` 重构前置条件
是否阻塞重构：
是
下一步怎么查：
按 `wh_code / dept_code / rd_style_name / machine_code` 做 scene 覆盖检查
建议优先级：
P1

## GAP-005C

影响链路：
`ads_sc_xl_01` 依赖映射
缺失对象：
`ads_sc_xl_01` 与 `with_attr_value` 的完整 join 复刻
已找到证据：
`18340742659074 ads_sc_xl_01(入库量)`
未找到证据：
本地 `ads_sc_xl_01_local` 对应 mapping 层
当前判断：
不先解决这个，入库量字段无法稳定对账
是否阻塞重构：
是
下一步怎么查：
先复刻 `ads_sc_xl_01` 的仓库和单据类型 join
建议优先级：
P1

## GAP-005D

影响链路：
`combined` 映射层
缺失对象：
`with_attr_value` 在 `combined` 中的排序/板型/展示映射闭环
已找到证据：
`combined` 直接 join `scene in BI-SC-KC-013-DEFINED-PLATE-*`
未找到证据：
本地 `combined_local` 映射实现
当前判断：
这是 `combined_local` 重构前置
是否阻塞重构：
是
下一步怎么查：
按 `manuf_line_name / plate_type / rk` 对 scene 结果做行级核对
建议优先级：
P1

## GAP-005E

影响链路：
字典生产链
缺失对象：
`with_attr_value` 的完整生产来源
已找到证据：
大量任务读取和个别任务写入 `with_attr_value`
未找到证据：
稳定、单一、可整体回放的生产链
当前判断：
来源生产链不闭合
是否阻塞重构：
部分阻塞
下一步怎么查：
后续结合更多历史仓库或同步层配置继续补证据
建议优先级：
P2

## GAP-008

影响链路：
合计 / 总计后置行
缺失对象：
`attr1='合计'` 与 `manuf_line_name='总计'` 的本地后置复刻
已找到证据：
`18333852605970 增加硅钢合计字段`
`18333852605971 增加硅钢板块总计字段`
未找到证据：
本地已执行的 summary-row postprocess 层
当前判断：
`partial + pending_execution`；
它们不是原始事实行，而是 `combined` 后置聚合分支
是否阻塞重构：
是
下一步怎么查：
执行
`sql/inspect/ads_sc_xl_13/inspect_total_rows_postprocess.sql`
与
`sql/recon/ads_sc_xl_13/recon_total_rows_postprocess.sql`
建议优先级：
P1

## GAP-009

影响链路：
tenant 支撑链
缺失对象：
`ods_mes_ums_tenant / ods_fair_ums_tenant -> ods_mes_mdm_tenant / dim_ums_tenant`
已找到证据：
`36`, `150` 两个 DataX 作业
未找到证据：
显式 Dolphin / DataX / DB-object 转换链
当前判断：
当前环境未显式暴露 tenant 最终转换闭环
是否阻塞重构：
部分阻塞
下一步怎么查：
如果后续有代码仓或别的同步层配置，再补查
建议优先级：
P2

## GAP-010

影响链路：
最终 candidate / readiness gate
缺失对象：
完整 `combined_candidate_blueprint` 的执行与 key/metric 验证
已找到证据：
当前主链与主要支撑链已达到候选层蓝图条件
未找到证据：
已执行的 candidate 层本地验证结果
当前判断：
`ready_for_candidate_blueprint`
是否阻塞重构：
部分阻塞
下一步怎么查：
先进入 `combined_candidate_blueprint`，不要直接进入完整 `combined_local`
建议优先级：
P2

## GAP-011

影响链路：
candidate execution validation
缺失对象：
P1 支撑链的真实只读执行结果与 evidence
已找到证据：
candidate execution validation plan、P1 checklist、runbook、evidence template 已建立
未找到证据：
真实只读执行产生的 row count / coverage / diff 结果
当前判断：
`ready_for_execution_validation_plan + pending_execution`
是否阻塞重构：
是
下一步怎么查：
进入 `readonly execution dry-run package`，按 runbook 顺序执行 inspect/recon SQL 并回填 evidence
建议优先级：
P1

## GAP-012

影响链路：
readonly execution dry-run
缺失对象：
实际 dry-run evidence 与 go/no-go 执行结果
已找到证据：
runbook、evidence ledger、go/no-go gate、dry-run wrapper SQL 已建立
未找到证据：
真实只读执行环境中的 evidence 结果
当前判断：
`ready + pending_execution`
是否阻塞重构：
是
下一步怎么查：
进入 `P1 support chain execution evidence collection`
建议优先级：
P1

## GAP-013

影响链路：
P1 support chain actual evidence
缺失对象：
真实只读执行结果与 evidence ledger 回填
已找到证据：
P1 support chain execution evidence matrix、actual evidence gate、fill-in template、business clarification split 已建立
未找到证据：
actual readonly execution 结果
当前判断：
`ready + pending_execution`
是否阻塞重构：
是
下一步怎么查：
进入 `P1 support chain execution evidence collection`
建议优先级：
P1

## 当前阶段判断更新

- `dim_date_info` 已不再是当前主阻塞点
- `process1 -> defined` 已形成可执行验证蓝图
- `defined -> defined_manuf_line_name` 已成为当前主线验证节点
- `with_attr_value attr1/manuf_line_name` 当前状态：`pending_execution`
- 仍然**不允许**直接进入完整 `combined_local`
