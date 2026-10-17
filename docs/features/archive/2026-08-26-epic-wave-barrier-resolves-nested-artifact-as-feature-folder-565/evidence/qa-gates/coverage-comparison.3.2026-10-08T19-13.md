# Coverage Comparison (PS-PROD), Final QC Iteration 3

Timestamp: 2026-10-08T19-13
Command: Comparison of evidence/baseline/coverage-perfile.2026-10-08T17-54.md (P0-T21), qa-gates/coverage-perfile.3.2026-10-08T19-13.md (P10-T10), and qa-gates/coverage-changed-lines.3.2026-10-08T19-13.md (P10-T11); no new command.
EXIT_CODE: 0
Output Summary: Nine rows, every verdict PASS. Every post-change line coverage is at least 85%. Uncovered changed lines are confined to the D6 dot-source catch bodies, which run only when the shared resolver fails to load.

| Path | Baseline (P0-T21) | Post-change (P10-T10) | Changed lines covered / executable (P10-T11) | 85% verdict |
|---|---|---|---|---|
| `.claude/hooks/feature-folder-resolution.ps1` | new file | 100.00% | whole file (new): 111/111 | PASS |
| `.codex/hooks/feature-folder-resolution.ps1` | new file | 100.00% | whole file (new): 111/111 | PASS |
| `.claude/hooks/enforce-epic-wave-barrier.ps1` | 99.01% | 96.70% | 13/15 (uncovered: catch body 62-63) | PASS |
| `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | 98.68% | 96.10% | 15/17 (uncovered: catch body 82-83) | PASS |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 99.12% | 98.23% | 15/16 (uncovered: catch body 93) | PASS |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 98.51% | 97.79% | 18/19 (uncovered: catch body 41) | PASS |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 98.48% | 97.76% | 18/19 (uncovered: catch body 41) | PASS |
| `.claude/hooks/enforce-feature-folder-order.ps1` | 91.11% | 91.67% | 30/31 (uncovered: catch body 50) | PASS |
| `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` | 96.61% | 94.92% | 6/7 (uncovered: catch body 39) | PASS |

The small decreases in whole-file percentage for the barrier hooks and the modes files come from the new guarded dot-source catch bodies, which are executed only on a load failure of the shared resolver. The import-failure behavior those catch bodies feed is tested directly by W9, C7, D7, M9, F18, and P3, which set the import-failure variable and assert the deny (or $null) outcome. The AST-GUARD assertions in W9, C7, and D7 prove that each catch body assigns that variable.
