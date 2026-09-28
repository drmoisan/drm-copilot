# Final QC Loop Single-Pass Record (P5-T8)

Timestamp: 2026-09-27T09-21
Command: git status --porcelain -- tests/scripts/dev_tools/test_workflow_npm_token_guard.py docs/engineering/npm-token-rotation.runbook.md
EXIT_CODE: 0
Output Summary: no output now; `PrePassStatus:` in the P5-T1 artifact was also empty. The two captures are identical, so no command in the pass changed an in-scope file.

## Artifacts of the pass (one pass, no restart)

| Task | Artifact | Recorded result |
|---|---|---|
| P5-T1 | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-black.2026-09-27T09-19.md` | `1 file left unchanged.`, EXIT_CODE 0 (acceptance literal) |
| P5-T2 | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-ruff.2026-09-27T09-19.md` | `All checks passed!`, EXIT_CODE 0 (acceptance literal) |
| P5-T3 | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pyright.2026-09-27T09-19.md` | `0 errors, 0 warnings, 0 informations`, EXIT_CODE 0 (acceptance literal) |
| P5-T4 | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pytest-guard.2026-09-27T09-19.md` | `17 passed`, EXIT_CODE 0 (acceptance literal) |
| P5-T5 | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pytest-coverage.2026-09-27T09-20.md` | EXIT_CODE 1; one failing node (issue #510, local-only), not in `BaselineFailingNodes:` |
| P5-T6 | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-coverage-thresholds.2026-09-27T09-21.md` | no output, EXIT_CODE 0 (acceptance literal) |

## Acceptance status

P5-T1, P5-T2, P5-T3, P5-T4, and P5-T6 record their acceptance literals. P5-T5 records neither its acceptance literal nor a pre-existing condition as the Phase 5 loop rule defines one, because the failing node is absent from `BaselineFailingNodes:`. The condition is classified as pre-existing and local-only (issue #510) under the caller's directive, and the loop was not restarted for it. Because the plan's definition is not met, P5-T8 is left unchecked.
