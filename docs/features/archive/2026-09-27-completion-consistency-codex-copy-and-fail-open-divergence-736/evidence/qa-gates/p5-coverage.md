# Per-file line coverage, final pass ([P5-T6])

Timestamp: 2026-10-08T18-32
Command: COVERAGE_EXTRACT (pwsh reading artifacts/pester/powershell-coverage.xml; plan template, run unchanged)
EXIT_CODE: 0
Output Summary: LINE_PCT .claude consistency 93.62; .claude helpers 97.01; .codex consistency 100; .codex helpers 88.06. Four COV lines, no COVERAGE_SELECT_COUNT line, no LINE_PCT_BELOW_85 line.

COV .claude/hooks/enforce-completion-consistency.ps1 LINE_COVERED=132 LINE_MISSED=9 LINE_PCT=93.62
COV .claude/hooks/enforce-completion-helpers.ps1 LINE_COVERED=65 LINE_MISSED=2 LINE_PCT=97.01
COV .codex/hooks/enforce-completion-consistency.ps1 LINE_COVERED=148 LINE_MISSED=0 LINE_PCT=100
COV .codex/hooks/enforce-completion-helpers.ps1 LINE_COVERED=59 LINE_MISSED=8 LINE_PCT=88.06
