# r1 P0-T14 — baseline per-file PowerShell coverage

Timestamp: 2026-10-03T12-49
Command: pwsh -NoProfile -File SCRATCH/steps/r1-p0-t14.ps1 -Worktree WORKTREE; step script runs `$cov = @(& "$Scratch/cov-derive.ps1" -CoveragePath "$Scratch/r1-baseline-coverage.xml" -BaseSha '079ebb9fad8fab1ee24e137e5bc605fc1df1948a' -Target @(<the seven COV-TARGETS>)); $covExit = $LASTEXITCODE; $cov; "COV-DERIVE-EXIT=$covExit"` and the P0-T14 VERDICT line
EXIT_CODE: 0
Output Summary:
- COV TOTAL covered=13370 missed=2412 pct=84.72 (repository-wide PowerShell line coverage baseline)
- BASELINE .claude/hooks/hook-command-raw-invocation.ps1 covered=21 missed=0 pct=100
- BASELINE .codex/hooks/hook-command-raw-invocation.ps1 covered=21 missed=0 pct=100
- BASELINE .claude/hooks/enforce-epic-worktree-removal-gate.ps1 covered=104 missed=5 pct=95.41
- BASELINE .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 covered=100 missed=7 pct=93.46
- BASELINE .codex/hooks/enforce-epic-worktree-removal-gate.ps1 covered=67 missed=1 pct=98.53
- BASELINE .claude/hooks/validate-feature-review-coverage.ps1 covered=104 missed=106 pct=49.52
- COV .claude/hooks/feature-review-coverage-thresholds.ps1 ABSENT rows=0 (file does not exist at BASE_SHA)
- Each UNCOVERED-CHANGED line prints NONE (no change yet); no SOURCE-ABSENT line; GATE-FAILED=False (no -FailBelow at baseline)
- COV-DERIVE-EXIT=0; VERDICT held.
