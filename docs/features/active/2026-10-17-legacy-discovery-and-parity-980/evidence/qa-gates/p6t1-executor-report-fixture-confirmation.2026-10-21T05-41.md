# Issue 980 — Native report fixture refresh confirmation

Status: READY_FOR_BOUNDED_FIXTURE_REFRESH. No production defect or open probe is established by this finite diagnosis.

The decoded stored and recomputed parity documents differ only at `/input_sha256`: activation changed the semantic inputs. All other fields, including the `parity` identity and failed selected results, are identical. The strict REPORT_RESULT refusal and original failed pair assertion remain preserved.

Use the exact archived report-dry request, changing only `operation` to `parity-report` and `dry_run` to false. Preserve the full service-request envelope, same trusted workspace, `parity-complete`, `write=true`, `format=both`, empty inputs and null host references. Expected exit is 1, with ok=false and validation_result=fail, while the guarded public operation replaces only parity-report.json and parity-report.md.

The existing operation binds prior byte hashes and exact grants, overlays the new pair before strict prospective graph validation, and publishes through the unchanged guarded writer. No manual digest edit or validation weakening is needed.

Require report input digest `0247c8253e090ee06d0ff70e4fcf3fcbeb374069ccf597e1f3c39347fee3a568`. Preserve original pair bytes, verify no unrelated changes, record actual regenerated pair hashes, and capture a new completion-footprint baseline. Resume report-dry and the nine remaining calls with existing assertions. Full snapshot identity remains distinct from this semantic report digest. No prefix, clone or initialization replay is required by this fixture refresh.

Exact request, allowed changes, archived-byte bindings and continuation conditions are in `p6t1-executor-report-fixture-confirmation.2026-10-21T05-41.json`. This reviewer ran no operation, projection, test or rebuild; coordinator release and native success remain pending.

Current phase: P6-T1; 46/84 tasks, 23/66 source ACs. Next five: P6-T1, P6-T2, P6-T3, P7-T1, P7-T2.
