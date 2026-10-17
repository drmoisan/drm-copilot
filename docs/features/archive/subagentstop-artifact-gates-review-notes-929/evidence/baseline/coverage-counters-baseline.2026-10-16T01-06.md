# Coverage Counters Baseline (P0-T25, NB-10 baseline record)

Timestamp: 2026-10-16T01-06

Command: sh SCRATCH/issue-929/P0-T25-1.sh
Script: `[xml]$x = Get-Content -LiteralPath artifacts/pester/powershell-coverage.xml -Raw; $m = @($x.SelectNodes('/report/package') | Where-Object { ($_.GetAttribute('name') -replace '\\', '/') -like '*/.claude/hooks' } | ForEach-Object { $_.SelectNodes('sourcefile') } | Where-Object { $_.GetAttribute('name') -eq 'validate-task-researcher-output.ps1' }); 'SOURCEFILE_MATCHES=' + $m.Count; $m | ForEach-Object { $_.SelectNodes('counter') } | Where-Object { $_.GetAttribute('type') -eq 'LINE' } | ForEach-Object { $_.OuterXml }; $nrs = @(Select-String -Path .claude/hooks/validate-task-researcher-output.ps1 -SimpleMatch -Pattern 'IsNullOrWhiteSpace($agentOutput)','-AgentOutput $agentOutput' | ForEach-Object { [string]$_.LineNumber }); 'CHANGED_LINES=' + ($nrs -join ','); $m | ForEach-Object { $_.SelectNodes('line') } | Where-Object { $_.GetAttribute('nr') -in $nrs } | ForEach-Object { $_.OuterXml }`
EXIT_CODE: 0
Output (verbatim):
```
SOURCEFILE_MATCHES=1
<counter type="LINE" missed="2" covered="101" />
CHANGED_LINES=245,249,266
<line nr="245" mi="0" ci="1" mb="0" cb="0" />
<line nr="249" mi="0" ci="1" mb="0" cb="0" />
<line nr="266" mi="0" ci="1" mb="0" cb="0" />
```

Output Summary: `.claude/hooks/validate-task-researcher-output.ps1` baseline LINE counter `missed="2" covered="101"`; line coverage 101 / (101 + 2) = 98.06%. The three changed lines (245, 249, 266) are each covered (`ci="1"`, `mi="0"`). Source: the self-hosted PoshQC run of P0-T23 (scan folders `tests/scripts/claude-hooks`, `tests/scripts/claude-runtime`).
