# AC-22 No stop_hook_active Literal ([P6-T7])

Timestamp: 2026-10-12T04-08
Command: rg -n "stop_hook_active" .claude/hooks/validate-orchestrator-output.ps1 .claude/hooks/validate-orchestrator-output-routing.ps1 .claude/hooks/validate-orchestrator-output-resolution.ps1 .claude/hooks/validate-executor-output.ps1 .claude/hooks/validate-planner-output.ps1 .claude/hooks/validate-required-artifact-output.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: no match lines; the re-entry policy reads StopHookActive from the helper result only.

Match lines: none
