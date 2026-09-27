# Final QC Loop Single-Pass Record (P5-T8, reconciled under spec D7)

Timestamp: 2026-09-27T09-45
Command: git status --porcelain -- tests/scripts/dev_tools/test_workflow_npm_token_guard.py docs/engineering/npm-token-rotation.runbook.md
EXIT_CODE: 0
Output Summary: no output now; `PrePassStatus:` in the last P5-T1 artifact is also empty. The two captures are identical, so no command in the pass changed an in-scope file.
SupersedesArtifact: docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-loop-single-pass.2026-09-27T09-21.md (retained as history)
Decision: docs/features/active/unused-npm-token-secret-712/spec.md D7 (approval operator-supplied 2026-09-26)

## Artifacts of the pass (one pass, no restart)

| Task | Artifact | Recorded result |
|---|---|---|
| P5-T1 | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-black.2026-09-27T09-19.md` | `1 file left unchanged.`, EXIT_CODE 0 (acceptance literal) |
| P5-T2 | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-ruff.2026-09-27T09-19.md` | `All checks passed!`, EXIT_CODE 0 (acceptance literal) |
| P5-T3 | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pyright.2026-09-27T09-19.md` | `0 errors, 0 warnings, 0 informations`, EXIT_CODE 0 (acceptance literal) |
| P5-T4 | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pytest-guard.2026-09-27T09-19.md` | `17 passed`, EXIT_CODE 0 (acceptance literal) |
| P5-T5 | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-pytest-coverage.2026-09-27T09-20.md` | EXIT_CODE 1, ExpectedExitCode 1; one local failing node, classified pre-existing and environmental under D7 (issue #510); CI run 36322316826 at bf4dc2b1: 5149 passed, 5 skipped, no failures, 91% |
| P5-T6 | `docs/features/active/unused-npm-token-secret-712/evidence/qa-gates/final-coverage-thresholds.2026-09-27T09-21.md` | no output, EXIT_CODE 0 (acceptance literal) |

## Acceptance status

P5-T1, P5-T2, P5-T3, P5-T4, and P5-T6 record their acceptance literals. P5-T5 records a pre-existing condition as the Phase 5 loop rule defines one after the plan's Amendment (spec D7). The two porcelain captures are identical. P5-T8 acceptance is met.
