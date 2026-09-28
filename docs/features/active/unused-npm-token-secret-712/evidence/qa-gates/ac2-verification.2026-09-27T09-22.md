# AC2 Verification Cross-Reference (P6-T3)

Timestamp: 2026-09-27T09-22
Result: NOT MET - two of the listed items are not satisfied; AC2 stays unchecked.

| Item | Artifact | Observed | Status |
|---|---|---|---|
| P5-T4 records `17 passed` | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pytest-guard.2026-09-27T09-19.md` | `17 passed in 0.06s`, EXIT_CODE 0 | met |
| P2-T1 lists `PASSED` for `tests/scripts/dev_tools/test_workflow_npm_token_guard.py::test_github_yaml_files_reference_no_npm_token_secret` | `docs/features/active/unused-npm-token-secret-712/evidence/regression-testing/guard-detection.2026-09-27T09-17.md` | PASSED | met |
| P2-T1 lists `PASSED` for `::test_github_yaml_files_reference_no_node_auth_token` | same | PASSED | met |
| P2-T1 lists `PASSED` for `::test_github_yaml_enumeration_is_non_vacuous` | same | PASSED | met |
| P2-T1 lists `PASSED` for every `::test_find_npm_token_references_detects_reintroduced_reference[...]` node | same | 5 of 5 PASSED (`dot-access`, `single-quoted-bracket`, `double-quoted-bracket`, `spaced-lowercase-dot`, `third-line-of-three`) | met |
| P2-T1 lists `PASSED` for every `::test_find_node_auth_token_references_detects_reference[...]` node | same | 2 of 2 PASSED (`other-secret-name`, `lowercase-second-line`) | met |
| P1-T9 records `EXIT_CODE: 1` | `docs/features/active/unused-npm-token-secret-712/evidence/regression-testing/guard-constraint-scan.2026-09-27T09-17.md` | EXIT_CODE 1, no output | met |
| P1-T10 records `1` and a line count of at most 500 | `docs/features/active/unused-npm-token-secret-712/evidence/regression-testing/guard-root-and-size.2026-09-27T09-17.md` | `1`; 263 lines | met |
| P5-T1 acceptance literal | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-black.2026-09-27T09-19.md` | `1 file left unchanged.` | met |
| P5-T2 acceptance literal | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-ruff.2026-09-27T09-19.md` | `All checks passed!` | met |
| P5-T3 acceptance literal | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pyright.2026-09-27T09-19.md` | `0 errors, 0 warnings, 0 informations` | met |
| P5-T5 records `FinalFailingNodes: none` | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pytest-coverage.2026-09-27T09-20.md` | one failing node: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` (gitignored `.claude/state` hook file; issue #510; local-only) | NOT met |
| P5-T6 records `EXIT_CODE: 0` | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-coverage-thresholds.2026-09-27T09-21.md` | EXIT_CODE 0, no output | met |
| P5-T7 records `Verdict: PASS` | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/coverage-comparison.2026-09-27T09-21.md` | `Verdict: REMEDIATION-REQUIRED` | NOT met |

The only unmet items trace to the single local-only #510 failure. Every guard-specific item is met: the guard module's own tests, its constraint scans, and its Black, Ruff, and Pyright checks. Coverage is unchanged at 91%, and the threshold gate passes. The plan's rule leaves AC2 unchecked in this state.
