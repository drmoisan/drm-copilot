# Coverage Delta (Issue #1010, remediation cycle 1, P3-T5)

Timestamp: 2026-10-30T22-28
Command: sh SCRATCH/issue-1010-r1-delta.sh (copies artifacts/pester/powershell-coverage.xml from the P3-T4 pass-3 run to SCRATCH, writes `git diff -U0 HEAD` of the two edited `-epic-scope` files to SCRATCH, and runs SCRATCH/issue-1010-delta.ps1, which maps each added line of the diff to the `<line>` entries of the coverage XML)
EXIT_CODE: 0
Output Summary: Both edited files rose against the P0-T5 baseline (Claude 86.96% to 89.57%; Codex 96.40% to 97.01%), and every measurable line this cycle changed in `Get-OrchestrationGateCommandOperandPath` is covered (24 of 24 on each surface, 100%). No changed-line regression.

| File | Baseline (P0-T5) | Post-change (P3-T4) | Changed-line coverage |
|---|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 86.96% (80/92) | 89.57% (103/115) | 100.00% (24/24 measurable of 40 added lines) |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 96.40% (107/111) | 97.01% (130/134) | 100.00% (24/24 measurable of 40 added lines) |

The 16 added lines per file that are not measurable are comment-based help, blank lines, and closing braces. The lines still missed in each file are outside this cycle's change (the always-mocked listing wrapper `Get-OrchestrationGateWorktreeList` and pre-existing unexercised branches), as recorded in the uncovered-line list of the delta run.
