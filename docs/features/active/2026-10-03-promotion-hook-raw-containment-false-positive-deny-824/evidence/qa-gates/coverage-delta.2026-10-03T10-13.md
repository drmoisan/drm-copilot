# P6-T4 Coverage derivation and delta (AC-26)

Timestamp: 2026-10-03T10-13
Command: & "SCRATCH/cov-derive.ps1" -CoveragePath "SCRATCH/final-coverage.xml" -BaseSha '9e8fe7eb576a904ac22cab96faf8c5c12311833e'; $LASTEXITCODE
EXIT_CODE: 0
Output Summary:
- Baseline (P0-T14): COV TOTAL covered=13325 missed=2413 pct=84.67; BASELINE-INV-CLAUDE=99.19; BASELINE-INV-CODEX=97.58
- Post-change: COV TOTAL covered=13370 missed=2412 pct=84.72
- COV .claude/hooks/hook-command-invocation.ps1 covered=124 missed=1 pct=99.2 (>= 85; >= baseline 99.19)
- COV .codex/hooks/hook-command-invocation.ps1 covered=122 missed=3 pct=97.6 (>= 85; >= baseline 97.58)
- COV .claude/hooks/hook-command-raw-invocation.ps1 covered=21 missed=0 pct=100 (>= 85)
- COV .codex/hooks/hook-command-raw-invocation.ps1 covered=21 missed=0 pct=100 (>= 85)
- UNCOVERED-CHANGED .claude/hooks/hook-command-invocation.ps1 NONE
- UNCOVERED-CHANGED .codex/hooks/hook-command-invocation.ps1 NONE
- UNCOVERED-CHANGED .claude/hooks/hook-command-raw-invocation.ps1 NONE
- UNCOVERED-CHANGED .codex/hooks/hook-command-raw-invocation.ps1 NONE
- New/changed-code coverage: raw-invocation modules 100% on both surfaces; no uncovered changed line in any of the four files
- Pester measures no branch coverage; no branch gate applies (PowerShell exemption)
- Result: PASS
