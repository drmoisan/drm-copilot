# Baseline per-file line coverage ([P0-T13])

Timestamp: 2026-10-08T17-39
Command: COVERAGE_EXTRACT (pwsh reading artifacts/pester/powershell-coverage.xml; plan template, run unchanged)
EXIT_CODE: 0
Output Summary: LINE_PCT .claude consistency 92.13; .claude helpers 93.02; .codex consistency 100; .codex helpers 79.07 (below 85, pre-existing; becomes a gate in [P5-T6]).

COV .claude/hooks/enforce-completion-consistency.ps1 LINE_COVERED=117 LINE_MISSED=10 LINE_PCT=92.13
COV .claude/hooks/enforce-completion-helpers.ps1 LINE_COVERED=40 LINE_MISSED=3 LINE_PCT=93.02
COV .codex/hooks/enforce-completion-consistency.ps1 LINE_COVERED=136 LINE_MISSED=0 LINE_PCT=100
COV .codex/hooks/enforce-completion-helpers.ps1 LINE_COVERED=34 LINE_MISSED=9 LINE_PCT=79.07
LINE_PCT_BELOW_85 .codex/hooks/enforce-completion-helpers.ps1
