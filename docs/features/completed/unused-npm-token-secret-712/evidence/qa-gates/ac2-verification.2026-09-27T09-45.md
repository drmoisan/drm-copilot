# AC2 Verification Cross-Reference (P6-T3, reconciled under spec D7)

Timestamp: 2026-09-27T09-45
Result: MET - every listed item is present; the two items previously NOT met are satisfied under spec D7.
SupersedesArtifact: docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/ac2-verification.2026-09-27T09-22.md (retained as history)
Decision: docs/features/active/unused-npm-token-secret-712/spec.md D7 (approval operator-supplied 2026-09-26)

| Item | Artifact | Observed | Status |
|---|---|---|---|
| P5-T4 records `17 passed` | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pytest-guard.2026-09-27T09-19.md` | `17 passed in 0.06s`, EXIT_CODE 0 | met |
| P2-T1 lists `PASSED` for `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_reference_no_npm_token_secret` | `docs/features/active/unused-npm-token-secret-712/evidence/regression-testing/guard-detection.2026-09-27T09-17.md` | PASSED | met |
| P2-T1 lists `PASSED` for `::test_github_yaml_files_reference_no_node_auth_token` | same | PASSED | met |
| P2-T1 lists `PASSED` for `::test_github_yaml_enumeration_is_non_vacuous` | same | PASSED | met |
| P2-T1 lists `PASSED` for every `::test_find_npm_token_references_detects_reintroduced_reference[...]` node | same | 5 of 5 PASSED | met |
| P2-T1 lists `PASSED` for every `::test_find_node_auth_token_references_detects_reference[...]` node | same | 2 of 2 PASSED | met |
| P1-T9 records `EXIT_CODE: 1` | `docs/features/active/unused-npm-token-secret-712/evidence/regression-testing/guard-constraint-scan.2026-09-27T09-17.md` | EXIT_CODE 1, no output | met |
| P1-T10 records `1` and a line count of at most 500 | `docs/features/active/unused-npm-token-secret-712/evidence/regression-testing/guard-root-and-size.2026-09-27T09-17.md` | `1`; 263 lines | met |
| P5-T1 acceptance literal | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-black.2026-09-27T09-19.md` | `1 file left unchanged.` | met |
| P5-T2 acceptance literal | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-ruff.2026-09-27T09-19.md` | `All checks passed!` | met |
| P5-T3 acceptance literal | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pyright.2026-09-27T09-19.md` | `0 errors, 0 warnings, 0 informations` | met |
| P5-T5 records `FinalFailingNodes: none` | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pytest-coverage.2026-09-27T09-20.md` (D7 reconciliation section) and `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/ci-python-full-suite.2026-09-27T09-35.md` | CI run 36322316826 at bf4dc2b1: `5149 passed, 5 skipped` with no failures on Python 3.10-3.13 (`CIFailingNodes: none`); the single local failure is the issue #510 environmental condition classified by D7 | met (under D7) |
| P5-T6 records `EXIT_CODE: 0` | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-coverage-thresholds.2026-09-27T09-21.md` | EXIT_CODE 0, no output | met |
| P5-T7 records `Verdict: PASS` | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/coverage-comparison.2026-09-27T09-45.md` | `Verdict: PASS` | met |

AC2 check-off state: `grep -c -F "[x] AC2." docs/features/active/unused-npm-token-secret-712/spec.md` prints `1` (checked off by the feature review; confirmed under P6-T8).
