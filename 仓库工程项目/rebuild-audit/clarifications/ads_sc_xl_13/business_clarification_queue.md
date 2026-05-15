# ADS_SC_XL_13 Business Clarification Queue

## Confirmed business clarifications

- `with_attr_value` = configuration / mapping table, not a source fact table
- `scene` = business report scene / reporting semantics
- `attr*` / `attribute*` = generic dimension slots, not globally fixed business fields
- `attr*` meaning must be determined by `scene + join/match field`
- warehouse / document-type scenes are used to map warehouse facts or aggregations into report-required warehouse and document-type semantics
- current multi-agent wording is only `future Shrimp role + future Hermes execution seat interface`
- current Windows Hermes does not participate in this round's multi-agent architecture

## Clarification ledger

| ID | Topic | Source issue / file | Impact chain | Blocks combined_candidate | Blocks combined_local | Suggested ask | User answered content | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `C-ANS-001` | `with_attr_value` role | issue `#6` owner clarification | `with_attr_value` support chain, `combined`, `ads_sc_xl_01` | No | Yes | None. Use the confirmed wording directly. | `with_attr_value` should be treated as a configuration / mapping table, not as a source fact table or independent production data chain. | `answered` |
| `C-ANS-002` | `scene` meaning | issue `#6` owner clarification | all `with_attr_value` scene-dependent joins | No | Yes | None. Use the confirmed wording directly. | `scene` means business/report scenario or reporting semantics. | `answered` |
| `C-ANS-003` | `attr*` semantics | issue `#6` owner clarification and issue `#10` confirmed semantics | `process1`, `defined`, `combined`, `ads_sc_xl_01` mapping language | No | Yes | None. Use scene-local wording only. | `attr*` fields are generic dimension slots; concrete meaning is determined by usage scene and warehouse join/match field. | `answered` |
| `C-ANS-004` | warehouse / document-type mapping semantics | issue `#10` confirmed semantics and issue `#7` receipt | `ads_sc_xl_01`, production in-stock, finished-goods in-stock | No | Yes | None. Use mapping-table wording only. | warehouse / document-type scenes map warehouse facts and aggregations into report-required warehouse and document-type semantics. | `answered` |
| `C-ANS-005` | Hermes participation wording | issue `#6` owner clarification | Track B wording, future coordinator interface notes | No | No | None. Keep as architectural constraint. | current Windows Hermes does not participate in this multi-agent architecture; only a future interface placeholder is kept. | `answered` |
| `C-OPEN-001` | `with_result_confirm` business semantics by `report_id 237 / 239 / 543` | `lineage/ads_sc_xl_13/02_supporting_chains.md`, issue `#9` scope | `with_result_confirm_local`, downtime metrics, remarks, `combined` | Yes | Yes | For each `report_id 237 / 239 / 543`, which exact daily/monthly fields are authoritative overrides, and what is the priority if source facts disagree? | none yet | `open` |
| `C-OPEN-002` | `attr1='合计'` and `manuf_line_name='总计'` postprocess rule | `lineage/ads_sc_xl_13/05_missing_links.md`, issue `#9` scope | total-row postprocess, `_001/_002` display outputs, `combined` | Yes | Yes | After which aggregation layer should `合计/总计` rows be generated, and should zero-fill rows participate before or after this postprocess? | none yet | `open` |
| `C-OPEN-003` | scene-local slot semantics for warehouse/doc-type joins | issue `#7` receipt, `lineage/ads_sc_xl_13/supporting/with_attr_value_warehouse_doc_type_closure.md`, `lineage/ads_sc_xl_13/supporting/ads_sc_xl_01_local_join_skeleton.md` | `ads_sc_xl_01_local`, warehouse/doc-type validation, `combined` input | Yes | Yes | For each `BI-SC-KC-013-WH-CODE-*` and `BI-SC-KC-013-RD-FINISHED-*` scene family, which `attribute*` slot corresponds to which warehouse-side field under each tenant or sub-scene? | none yet | `open` |
| `C-OPEN-004` | `group_manuf_line_name` business role | `lineage/ads_sc_xl_13/defined_manuf_line_name_execution_result.md` | `defined_manuf_line_name`, `combined_candidate`, display grouping | Yes | Yes | Is `group_manuf_line_name` merely another label for `manuf_line_name`, or is it a higher-level grouping dimension that must survive into `combined`? | none yet | `open` |

## Queue handling rules

1. If a point is answered by the coordinator or domain owner, move it to `answered` and preserve the original wording.
2. If a point becomes irrelevant because a later stage package removes the dependency, mark it `obsolete`.
3. Track C must not resolve any `open` row by inference alone.
