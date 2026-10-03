# r2 P0-T14 baseline per-file PowerShell coverage

Timestamp: 2026-10-03T15-59
Command: $cov = @(& "$Scratch/cov-derive.ps1" -CoveragePath "$Scratch/r2-baseline-coverage.xml" -BaseSha 'bda1982bcb9048a22efe9ba124a2b53516e9e3c1' -Target @(COV-TARGETS, the seven files below)); $covExit = $LASTEXITCODE (step script SCRATCH/steps/r2-p0-t14.ps1; A1 without -FailBelow; VERDICT on eight numeric COV lines and no ABSENT line)
EXIT_CODE: 0
Output Summary: COV-DERIVE-EXIT=0; eight numeric COV lines; no ABSENT or SOURCE-ABSENT line. BASELINE values:
- COV TOTAL covered=13612 missed=2316 pct=85.46
- .claude/hooks/hook-command-raw-invocation.ps1 covered=78 missed=0 pct=100 (BASELINE 100)
- .codex/hooks/hook-command-raw-invocation.ps1 covered=78 missed=0 pct=100 (BASELINE 100)
- .claude/hooks/hook-command-invocation.ps1 covered=124 missed=1 pct=99.2 (BASELINE 99.2)
- .codex/hooks/hook-command-invocation.ps1 covered=122 missed=3 pct=97.6 (BASELINE 97.6)
- .claude/hooks/enforce-epic-worktree-removal-gate.ps1 covered=107 missed=5 pct=95.54 (BASELINE 95.54)
- .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 covered=103 missed=7 pct=93.64 (BASELINE 93.64)
- .codex/hooks/enforce-epic-worktree-removal-gate.ps1 covered=70 missed=1 pct=98.59 (BASELINE 98.59)
- UNCOVERED-CHANGED NONE for every target (no change exists at BASE_SHA); GATE-FAILED=False (gate off for the baseline).
