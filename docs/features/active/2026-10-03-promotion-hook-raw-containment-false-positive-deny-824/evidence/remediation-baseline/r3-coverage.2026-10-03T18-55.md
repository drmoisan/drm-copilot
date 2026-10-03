# r3 P0-T14 baseline per-file PowerShell coverage (issue #824)

Timestamp: 2026-10-03T18-55
Command: $cov = @(& "$Scratch/cov-derive.ps1" -CoveragePath "$Scratch/r3-baseline-coverage.xml" -BaseSha '32e9153773f9bedbfe64dbd5e5bf8909038e59cb' -Target @('.claude/hooks/hook-command-raw-invocation.ps1', '.codex/hooks/hook-command-raw-invocation.ps1', '.claude/hooks/enforce-epic-worktree-removal-gate.ps1', '.claude/hooks/enforce-parallel-worktree-removal-gate.ps1', '.codex/hooks/enforce-epic-worktree-removal-gate.ps1')); $covExit = $LASTEXITCODE; $cov; "COV-DERIVE-EXIT=$covExit" (inside SCRATCH/steps/r3-p0-t14.ps1; VERDICT over six numeric COV lines and no ABSENT line)
EXIT_CODE: 0
Output Summary:
TS=2026-10-03T18-55
COV TOTAL covered=13676 missed=2316 pct=85.52
COV .claude/hooks/hook-command-raw-invocation.ps1 covered=80 missed=0 pct=100
COV .codex/hooks/hook-command-raw-invocation.ps1 covered=80 missed=0 pct=100
COV .claude/hooks/enforce-epic-worktree-removal-gate.ps1 covered=106 missed=5 pct=95.5
COV .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 covered=102 missed=7 pct=93.58
COV .codex/hooks/enforce-epic-worktree-removal-gate.ps1 covered=69 missed=1 pct=98.57
(UNCOVERED-CHANGED lines print NONE for all five files; no change yet against BASE_SHA)
GATE-FAILED=False
COV-DERIVE-EXIT=0
BASELINE values: CLAUDE-RAW 100, CODEX-RAW 100, EPIC-GATE 95.5, PAR-GATE 93.58, CODEX-GATE 98.57, TOTAL 85.52.
