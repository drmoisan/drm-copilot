# Final QC loop single-pass record (P2-T8)

Timestamp: 2026-10-01T20-58
Command: git status --porcelain -- tests/scripts/dev_tools/test_workflow_npm_token_guard.py docs/features/completed/unused-npm-token-secret-712/runbooks/delete-unused-npm-token-secret.runbook.md
EXIT_CODE: 0
Output Summary: single pass of P2-T1 through P2-T7 with no restart; pre-pass and current status outputs are identical (both no output).

## Last P2-T1 through P2-T7 run (one pass, no restarts)

| Task | Artifact | Acceptance literal recorded |
| --- | --- | --- |
| P2-T1 | docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-black.2026-10-01T20-55.md | `EXIT_CODE: 0`, `1 file left unchanged.` |
| P2-T2 | docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-ruff.2026-10-01T20-55.md | `EXIT_CODE: 0`, `All checks passed!` |
| P2-T3 | docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-pyright.2026-10-01T20-55.md | `EXIT_CODE: 0`, `0 errors, 0 warnings, 0 informations` |
| P2-T4 | docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-pytest-guard.2026-10-01T20-55.md | `EXIT_CODE: 0`, `52 passed` |
| P2-T5 | docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-pytest-coverage.2026-10-01T20-57.md | `PostChangeTotalCover: 92%`, `FinalFailingNodes: none` |
| P2-T6 | docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-coverage-thresholds.2026-10-01T20-57.md | `EXIT_CODE: 0`, `Output Summary: no output` |
| P2-T7 | docs/features/active/2026-09-27-npm-token-guard-gaps-739/evidence/qa-gates/final-coverage-percentages.2026-10-01T20-57.md | `EXIT_CODE: 1`, two lines; line 93.53 >= 85, branch 86.76 >= 75 |

## Status comparison

- PrePassStatus (from the P2-T1 artifact): no output
- CurrentStatus (command above, run now): no output
- Identical: yes
