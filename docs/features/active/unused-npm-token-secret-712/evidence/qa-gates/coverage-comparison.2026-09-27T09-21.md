# Coverage Comparison (P5-T7)

Timestamp: 2026-09-27T09-21
BaselineArtifact: docs/features/active/unused-npm-token-secret-712/evidence/baseline/baseline-pytest-coverage.2026-09-27T09-14.md
FinalArtifact: docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pytest-coverage.2026-09-27T09-20.md
BaselineThresholdArtifact: docs/features/active/unused-npm-token-secret-712/evidence/baseline/baseline-coverage-thresholds.2026-09-27T09-14.md
BaselineTotalCover: 91%
PostChangeTotalCover: 91%
BaselineTotalRow: TOTAL 15841 1114 5760 573 91%
PostChangeTotalRow: TOTAL 15841 1114 5760 573 91% (identical)
ChangedProductionFiles: none
NewOrChangedCodeCoverage: not applicable - no production line changed
FinalThresholdGate: EXIT_CODE 0 (`docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-coverage-thresholds.2026-09-27T09-21.md`)
Verdict: REMEDIATION-REQUIRED

## Reason for the verdict

Coverage did not regress: `PostChangeTotalCover` (91%) is equal to `BaselineTotalCover` (91%). The P5-T6 threshold gate exited 0. The PASS condition also requires that P5-T5 record `FinalFailingNodes: none`. P5-T5 recorded one failing node:

- `FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`

That failure comes from the gitignored hook state file `.claude/state/python-batch-budget.worktree-agent-aeab66e09fb7ca876-451b367f.json`, which was created after the baseline run. It is tracked as open issue #510 and is local-only. It is recorded as a pre-existing local-only condition per the caller's directive. The plan's PASS rule admits no exception for it, so the verdict is REMEDIATION-REQUIRED. P5-T7 remains unchecked, and AC2 remains unchecked under P6-T3/P6-T8.

Remediation path, outside this plan's scope: obtain the CI pytest result for this branch, where `.claude/state/` does not exist, or resolve issue #510.
