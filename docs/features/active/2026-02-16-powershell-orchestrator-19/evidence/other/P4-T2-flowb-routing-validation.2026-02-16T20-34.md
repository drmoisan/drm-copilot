Timestamp: 2026-02-16T20-34
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$a = Select-String -Path '.github/agents/powershell-orchestrator.agent.md' -Pattern '^## Large path \(budget >2 production PowerShell files\)$' -Quiet; $b = Select-String -Path '.github/agents/powershell-orchestrator.agent.md' -Pattern 'If estimate is `>2` production PowerShell files' -Quiet; if ($a -and $b) { 'FlowB budget=3 => route=large'; exit 0 } else { 'Failure: FlowB routing rule missing'; exit 1 }"
EXIT_CODE: 0
Output Summary:
FlowB budget=3 => route=large
