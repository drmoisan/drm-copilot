Timestamp: 2026-02-16T20-34
Command: pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "$a = Select-String -Path '.github/prompts/orchestrate-powershell-work.prompt.md' -Pattern '^- **Request summary (required):** clear objective and expected outcome$' -Quiet; $b = Select-String -Path '.github/agents/powershell-orchestrator.agent.md' -Pattern '^2\. Estimate rough change budget\.$' -Quiet; if ($a -and $b) { 'Input contract present => budget intake required before route'; exit 0 } else { 'Failure: intake contract missing'; exit 1 }"
EXIT_CODE: 0
Output Summary:
Input contract present => budget intake required before route
