# readonly execution evidence ledger

| Evidence ID | Node | SQL file | Expected output | Actual output | Status | Blocking reason | Next action |
|---|---|---|---|---|---|---|---|
| `E-001` | `with_attr_value attr1/manuf_line_name` | `inspect_with_attr_value_attr1_manuf_line_name.sql` / `recon_with_attr_value_attr1_manuf_line_name.sql` | scene coverage / machine mapping coverage | `pending_execution` | `pending_execution` | no readonly execution evidence yet | collect evidence |
| `E-002` | `with_attr_value warehouse/doc_type` | `inspect_with_attr_value_warehouse_doc_type.sql` / `recon_with_attr_value_warehouse_doc_type.sql` | warehouse/doc type coverage | `pending_execution` | `pending_execution` | no readonly execution evidence yet | collect evidence |
| `E-003` | `ads_sc_xl_01_local` | `inspect_ads_sc_xl_01_local.sql` / `recon_ads_sc_xl_01_local_join.sql` | join skeleton / candidate join coverage | `pending_execution` | `pending_execution` | no readonly execution evidence yet | collect evidence |
| `E-004` | `with_result_confirm_local` | `inspect_with_result_confirm_local.sql` / `recon_with_result_confirm_local.sql` | report_id / downtime / remark coverage | `pending_execution` | `pending_execution` | no readonly execution evidence yet | collect evidence |
| `E-005` | `total_rows_postprocess_local` | `inspect_total_rows_postprocess.sql` / `recon_total_rows_postprocess.sql` | summary row existence / reducibility | `pending_execution` | `pending_execution` | no readonly execution evidence yet | collect evidence |
| `E-006` | `combined_candidate inputs` | `inspect_combined_candidate_inputs.sql` | input key / metric readiness | `pending_execution` | `pending_execution` | no readonly execution evidence yet | collect evidence |
| `E-007` | `candidate recon` | `recon_combined_candidate_blueprint.sql` / `recon_candidate_execution_validation_plan.sql` | candidate blocker / coverage summary | `pending_execution` | `pending_execution` | no readonly execution evidence yet | collect evidence |
