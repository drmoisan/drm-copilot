# P7 Contract Tests Fail-Before (P2-T3) [expect-fail]

Timestamp: 2026-10-13T11-17
Command: poetry run pytest tests/scripts/dev_tools/test_evidence_timestamp_contracts.py -v
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 12 failed, 3 passed in 0.28s. Run before any skill edit. The 12 nodes of tests 1-4 FAILED and the 3 mirror-parity nodes PASSED, which matches the planned outcome exactly; no deviation.

## Per-node outcomes

| Node | Outcome | Failure reason |
|---|---|---|
| test_evidence_skill_states_utc_timestamp_source[claude] | FAILED | missing required text: The `Timestamp` value is UTC read from the host system clock |
| test_evidence_skill_states_utc_timestamp_source[agents] | FAILED | same |
| test_evidence_skill_states_utc_timestamp_source[github] | FAILED | same |
| test_evidence_skill_omits_local_time_wording[claude] | FAILED | still contains forbidden text: local time |
| test_evidence_skill_omits_local_time_wording[agents] | FAILED | same |
| test_evidence_skill_omits_local_time_wording[github] | FAILED | same |
| test_evidence_skill_requires_write_time_filename_stamp[claude] | FAILED | missing required text: ### Evidence Filename Timestamp |
| test_evidence_skill_requires_write_time_filename_stamp[agents] | FAILED | same |
| test_evidence_skill_requires_write_time_filename_stamp[github] | FAILED | same |
| test_atomic_plan_contract_forbids_plan_time_evidence_stamp[claude] | FAILED | ValueError: section heading not found: ## Evidence Filename Timestamps in Plans |
| test_atomic_plan_contract_forbids_plan_time_evidence_stamp[agents] | FAILED | same |
| test_atomic_plan_contract_forbids_plan_time_evidence_stamp[github] | FAILED | same |
| test_atomic_plan_contract_matches_bundled_mirror[claude] | PASSED | |
| test_atomic_plan_contract_matches_bundled_mirror[agents] | PASSED | |
| test_atomic_plan_contract_matches_bundled_mirror[github] | PASSED | |

Summary line: `======================== 12 failed, 3 passed in 0.28s =========================`

Deviation: none.
