# PowerShell Changed-Line Baseline (P1-T4)

Timestamp: 2026-10-13T11-14
Command: poetry -C <worktree> run python -I artifacts/scratch-903/ps_cov_extract_903.py artifacts/scratch-903/ci-baseline-903/powershell-coverage.xml lines (reads the `ci` attribute of each `line` element of the named `sourcefile` from the P1-T3 coverage XML of CI run 38386628228)
EXIT_CODE: 0

A line is covered when `ci` is greater than 0. A line with no `line` element would be recorded as `not-executable`; none occurred.

| File | Line | ci | State |
|---|---|---|---|
| .claude/hooks/enforce-epic-wave-barrier.ps1 | 61 | 1 | covered |
| .claude/hooks/enforce-epic-wave-barrier.ps1 | 62 | 1 | covered |
| .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 75 | 1 | covered |
| .claude/hooks/enforce-parallel-cohort-barrier.ps1 | 76 | 1 | covered |
| .claude/hooks/enforce-parallel-drift-gate.ps1 | 86 | 2 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 41 | 1 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 41 | 0 | uncovered |
| .claude/hooks/enforce-feature-folder-order.ps1 | 51 | 1 | covered |
| .claude/hooks/enforce-prd-feature-before-planner-helpers.ps1 | 39 | 1 | covered |
| .claude/hooks/enforce-completion-consistency.ps1 | 466 | 0 | uncovered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 25 | 2 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 109 | 5 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 146 | 4 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 152 | 2 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 202 | 3 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 219 | 3 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 231 | 4 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 237 | 5 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 270 | 4 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 286 | 4 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 318 | 1 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 321 | 1 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 324 | 1 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 327 | 1 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 195 | 2 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 211 | 3 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 213 | 2 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 221 | 3 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 230 | 3 | covered |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 239 | 2 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 25 | 2 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 109 | 5 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 146 | 4 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 152 | 2 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 202 | 3 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 219 | 3 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 231 | 4 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 237 | 5 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 270 | 4 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 286 | 4 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 318 | 1 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 321 | 1 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 324 | 1 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 327 | 1 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 195 | 2 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 211 | 3 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 213 | 2 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 221 | 3 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 230 | 3 | covered |
| .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 239 | 2 | covered |

Output Summary: 50 rows recorded (9 catch lines + 1 completion-consistency tail line + 2 x 20 targets lines). 48 covered; 2 uncovered at baseline: `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:41` (ci 0) and `.claude/hooks/enforce-completion-consistency.ps1:466` (ci 0). No not-executable rows.
