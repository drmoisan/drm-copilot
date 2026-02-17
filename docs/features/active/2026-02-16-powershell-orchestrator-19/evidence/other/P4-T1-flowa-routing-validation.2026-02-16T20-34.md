Timestamp: 2026-02-16T20-34
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$a = Select-String -Path '.github/agents/powershell-orchestrator.agent.md' -Pattern '^## Small path \(budget 1-2 production PowerShell files\)$' -Quiet; $b = Select-String -Path '.github/agents/powershell-orchestrator.agent.md' -Pattern 'If estimate is `1-2` production PowerShell files' -Quiet; if ($a -and $b) { 'FlowA budget=2 => route=small'; exit 0 } else { 'Failure: FlowA routing rule missing'; exit 1 }"
EXIT_CODE: 0
Output Summary:
FlowA budget=2 => route=small
