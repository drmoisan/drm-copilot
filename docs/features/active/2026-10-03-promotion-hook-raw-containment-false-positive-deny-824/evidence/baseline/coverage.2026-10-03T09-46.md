# P0-T14 Baseline per-file coverage

Timestamp: 2026-10-03T09-46
Command: & "SCRATCH/cov-derive.ps1" -CoveragePath "SCRATCH/baseline-coverage.xml" -BaseSha '9e8fe7eb576a904ac22cab96faf8c5c12311833e'; $LASTEXITCODE
EXIT_CODE: 0
Output Summary:
- COV TOTAL covered=13325 missed=2413 pct=84.67
- COV .claude/hooks/hook-command-invocation.ps1 covered=123 missed=1 pct=99.19 (BASELINE-INV-CLAUDE = 99.19)
- UNCOVERED-CHANGED .claude/hooks/hook-command-invocation.ps1 NONE
- COV .codex/hooks/hook-command-invocation.ps1 covered=121 missed=3 pct=97.58 (BASELINE-INV-CODEX = 97.58)
- UNCOVERED-CHANGED .codex/hooks/hook-command-invocation.ps1 NONE
- COV .claude/hooks/hook-command-raw-invocation.ps1 ABSENT rows=0 (file does not exist yet)
- COV .codex/hooks/hook-command-raw-invocation.ps1 ABSENT rows=0 (file does not exist yet)
- Result: PASS
