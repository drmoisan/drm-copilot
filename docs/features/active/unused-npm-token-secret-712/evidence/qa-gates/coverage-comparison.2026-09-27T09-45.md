# Coverage Comparison (P5-T7, reconciled under spec D7)

Timestamp: 2026-09-27T09-45
BaselineArtifact: docs/features/active/unused-npm-token-secret-712/evidence/baseline/baseline-pytest-coverage.2026-09-27T09-14.md
FinalArtifact: docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pytest-coverage.2026-09-27T09-20.md
BaselineThresholdArtifact: docs/features/active/unused-npm-token-secret-712/evidence/baseline/baseline-coverage-thresholds.2026-09-27T09-14.md
CIFullSuiteArtifact: docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/ci-python-full-suite.2026-09-27T09-35.md
SupersedesArtifact: docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/coverage-comparison.2026-09-27T09-21.md (retained as history; its verdict was REMEDIATION-REQUIRED)
Decision: docs/features/active/unused-npm-token-secret-712/spec.md D7 (approval operator-supplied 2026-09-26)
BaselineTotalCover: 91%
PostChangeTotalCover: 91%
BaselineTotalRow: TOTAL 15841 1114 5760 573 91%
PostChangeTotalRow (local): TOTAL 15841 1114 5760 573 91% (identical to baseline)
CITotalRow (run 36322316826, Python 3.10-3.13, head bf4dc2b1): TOTAL 15841 1129 5760 573 91%
ChangedProductionFiles: none
NewOrChangedCodeCoverage: not applicable - no production line changed
FinalThresholdGate: EXIT_CODE 0 (docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-coverage-thresholds.2026-09-27T09-21.md); CI threshold step success on all four Python jobs
FinalFailingNodes (under D7): none - the one local failure is the issue #510 environmental condition; CI run 36322316826 reported 5149 passed, 5 skipped, no failures on each Python job
Verdict: PASS

## Basis

- PostChangeTotalCover (91%) is greater than or equal to BaselineTotalCover (91%).
- P5-T6 recorded EXIT_CODE 0.
- The full-suite `FinalFailingNodes: none` condition is satisfied under spec D7 by the Linux CI run https://github.com/drmoisan/drm-copilot/actions/runs/36322316826 at head bf4dc2b103d04cebc615238c60834573eb53bbfe. The local-only failure of `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` is caused solely by the gitignored `.claude/state` hook file (issue #510) and is classified as pre-existing and environmental by D7.
