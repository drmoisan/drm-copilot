# P4-T2 Every test in tests/scripts/claude-hooks and tests/scripts/codex-hooks (no coverage)

Timestamp: 2026-10-03T09-57
Command: pwsh -NoProfile -Command "& 'SCRATCH/issue824-pester.ps1' -Path @('tests/scripts/claude-hooks', 'tests/scripts/codex-hooks') -JUnitPath 'SCRATCH/hook-suites.junit.xml'; exit `$LASTEXITCODE" *> "SCRATCH/hook-suites.log"; $LASTEXITCODE; then Select-String '^(TOTALS|FAILED:|CONTAINER-ERROR:)' over the log
EXIT_CODE: 0
Output Summary:
- Child exit code: 0
- TOTALS passed=3509 failed=0 skipped=0 notrun=0 total=3509
- FAILED lines: none; CONTAINER-ERROR lines: none
- Local Windows equivalent of the 'poshqc / PowerShell hook suites (Linux)' job suite selection; covers the research section 6.1 wrapper deny pins, including tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 (AT-6) and both promotion decision-surface suites (AC-16).
- Result: PASS
