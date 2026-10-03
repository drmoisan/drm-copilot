# r1 P8-T4 — post-change PowerShell coverage and delta (AC-26, AC-33)

Timestamp: 2026-10-03T13-40
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p8-t4.ps1 -Worktree WORKTREE; step script runs `& "$Scratch/cov-derive.ps1" -CoveragePath "$Scratch/r1-final-coverage.xml" -BaseSha '079ebb9fad8fab1ee24e137e5bc605fc1df1948a' -Target @('.claude/hooks/hook-command-raw-invocation.ps1', '.codex/hooks/hook-command-raw-invocation.ps1', '.claude/hooks/enforce-epic-worktree-removal-gate.ps1', '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1', '.codex/hooks/enforce-epic-worktree-removal-gate.ps1', '.claude/hooks/validate-feature-review-coverage.ps1', '.claude/hooks/feature-review-coverage-thresholds.ps1') -FailBelow 85; $LASTEXITCODE`
EXIT_CODE: 0
Output Summary:
- GATE-FAILED=False; A1 exit 0
- Repository-wide PowerShell line coverage: baseline (P0-T14) 84.72% (13370/15782) -> post-change 85.46% (covered=13612 missed=2316)

| File | Baseline pct (P0-T14) | Post-change covered / missed | Post-change pct | UNCOVERED-CHANGED |
|---|---|---|---|---|
| .claude/hooks/hook-command-raw-invocation.ps1 | 100 (21/0) | 78 / 0 | 100 | NONE |
| .codex/hooks/hook-command-raw-invocation.ps1 | 100 (21/0) | 78 / 0 | 100 | NONE |
| .claude/hooks/enforce-epic-worktree-removal-gate.ps1 | 95.41 (104/5) | 107 / 5 | 95.54 | NONE |
| .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 | 93.46 (100/7) | 103 / 7 | 93.64 | NONE |
| .codex/hooks/enforce-epic-worktree-removal-gate.ps1 | 98.53 (67/1) | 70 / 1 | 98.59 | NONE |
| .claude/hooks/validate-feature-review-coverage.ps1 | 49.52 (104/106) | 202 / 10 | 95.28 | NONE |
| .claude/hooks/feature-review-coverage-thresholds.ps1 | ABSENT (new file) | 21 / 0 | 100 | NONE |

- Every pct is at least 85; every UNCOVERED-CHANGED line prints NONE (no changed line is uncovered). New/changed-code coverage: FR-THRESH 100% plus NONE on all seven UNCOVERED-CHANGED results. FR-HOOK rose from 49.52% to 95.28%.
- Pester measures no branch coverage; no PowerShell branch gate applies.
