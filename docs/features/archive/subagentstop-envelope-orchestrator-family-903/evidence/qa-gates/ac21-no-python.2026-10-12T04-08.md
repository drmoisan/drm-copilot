# AC-21 No Python ([P6-T6])

Timestamp: 2026-10-12T04-08
Command: rg -n "(&\s*(python|py|poetry)\b|poetry run|Start-Process|ProcessStartInfo)" .claude/hooks/validate-orchestrator-output.ps1 .claude/hooks/validate-orchestrator-output-routing.ps1 .claude/hooks/validate-orchestrator-output-resolution.ps1 .claude/hooks/validate-executor-output.ps1 .claude/hooks/validate-planner-output.ps1 .claude/hooks/validate-required-artifact-output.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: no match lines (baseline MATCHES-AC-21: 1, validate-executor-output.ps1:265, now the L6 literal poetry[ ]run).

Match lines: none
