# r1 P8-T15 — line counts of every changed or new code and test file (AC-28)

Timestamp: 2026-10-03T13-41
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p8-t15.ps1 -Worktree WORKTREE (A0; the 19-file count loop; the HOOKS-OVER-500 count; the P8-T15 VERDICT line)
EXIT_CODE: 0
Output Summary:
- .claude/hooks/hook-command-raw-invocation.ps1 298; .codex/hooks/hook-command-raw-invocation.ps1 298 (at most 320, equal)
- .claude/hooks/enforce-epic-worktree-removal-gate.ps1 464; .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 481; .codex/hooks/enforce-epic-worktree-removal-gate.ps1 184
- .claude/hooks/validate-feature-review-coverage.ps1 471 (at most 490); .claude/hooks/feature-review-coverage-thresholds.ps1 68 (at most 120)
- .codex/codex-web-setup.sh 394
- tests: S1 292, S2 278, S6 259, S7 239, S8 242, U1 159, U2 159, NT1 274, U3 44, PYG 263, PYA 493
- Every count is at most 500; HOOKS-OVER-500=0
