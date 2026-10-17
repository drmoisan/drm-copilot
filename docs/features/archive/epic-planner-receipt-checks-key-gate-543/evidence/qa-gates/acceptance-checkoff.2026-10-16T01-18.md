# Acceptance Criteria Check-Off (P9-T5)

Timestamp: 2026-10-16T01-18
Command: grep -c -e '^- \[x\] ' docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md; grep -c -e '^- \[ \] ' docs/features/active/epic-planner-receipt-checks-key-gate-543/spec.md
EXIT_CODE: 0
Output Summary:
- Checked: 17 (baseline 0, P0-T19)
- Unchecked: 1 (baseline 18, P0-T19)
- Each of AC1-AC17 was ticked at its mapped task under the tick rule; no criterion text or other section was changed; P9-T5 found no remaining tick to apply.

Citations:
- AC1: evidence/regression-testing/fail-before-python.2026-10-16T00-41.md and evidence/regression-testing/pass-after-python.2026-10-16T00-45.md (test_ready_gate_skips_feature_receipts_when_keys_absent)
- AC2: evidence/regression-testing/fail-before-typescript.2026-10-16T00-42.md and evidence/regression-testing/pass-after-typescript.2026-10-16T00-48.md
- AC3: evidence/regression-testing/python-feature-receipts-suite.2026-10-16T00-54.md and evidence/regression-testing/typescript-feature-receipts-suites.2026-10-16T00-59.md (test_codex_flag_keeps_feature_receipts_unconditional; "keeps the per-feature receipts unconditional under %p")
- AC4: same two artifacts (test_ready_gate_validates_present_null_feature_receipt; "validates a present null %s without a Codex flag")
- AC5: same two artifacts (test_ready_gate_gates_each_feature_receipt_independently; "gates each per-feature receipt independently")
- AC6: same two artifacts (test_ready_gate_preserves_feature_index_when_receipts_skipped; "preserves the feature index when receipts are skipped")
- AC7: evidence/qa-gates/byte-identical-strings.2026-10-16T01-04.md
- AC8: evidence/regression-testing/python-feature-receipts-suite.2026-10-16T00-54.md (test_readiness_requires_resolved_child_model_receipt)
- AC9: evidence/regression-testing/typescript-feature-receipts-suites.2026-10-16T00-59.md ("threads the Codex flags into epic-planner-state")
- AC10: evidence/qa-gates/gating-predicate.2026-10-16T01-01.md
- AC11: evidence/qa-gates/error-strings-unchanged.2026-10-16T01-03.md
- AC12: evidence/regression-testing/preserved-tests.2026-10-16T01-05.md, evidence/regression-testing/targeted-python.2026-10-16T01-04.md, evidence/regression-testing/targeted-typescript.2026-10-16T01-05.md
- AC13: evidence/qa-gates/scope-exclusions.2026-10-16T01-06.md
- AC14: evidence/qa-gates/docs-updated.2026-10-16T01-06.md
- AC15: evidence/qa-gates/line-counts-final.2026-10-16T01-17.md (with evidence/other/ts-line-budget.2026-10-16T00-48.md)
- AC16: evidence/qa-gates/final-python-per-file-coverage.2026-10-16T01-08.md, evidence/qa-gates/coverage-delta-verification.2026-10-16T01-16.md, evidence/qa-gates/final-qa-clean-pass.2026-10-16T01-17.md
- AC17: evidence/qa-gates/final-typescript-test-coverage.2026-10-16T01-13.md, evidence/qa-gates/coverage-delta-verification.2026-10-16T01-16.md, evidence/qa-gates/final-qa-clean-pass.2026-10-16T01-17.md
- AC18: deferred to S9 (PR body Closes #543 and CI success on the final PR head)
