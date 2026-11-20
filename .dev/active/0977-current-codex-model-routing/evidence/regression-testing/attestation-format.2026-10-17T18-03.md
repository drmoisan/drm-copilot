Timestamp: 2026-10-17T18:03:17.298188+00:00
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root . -GetFileList { Get-Item .codex/hooks/record-subagent-routing-attestation.ps1, tests/scripts/codex-hooks/subagent-attestation-persistence.Tests.ps1, tests/scripts/codex-hooks/subagent-attestation-command.Tests.ps1, tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1 }
EXIT_CODE: 0
Output Summary:

Already formatted: .\.codex\hooks\record-subagent-routing-attestation.ps1
Already formatted: .\tests\scripts\codex-hooks\subagent-attestation-persistence.Tests.ps1
Already formatted: .\tests\scripts\codex-hooks\subagent-attestation-command.Tests.ps1
Already formatted: .\tests\scripts\claude-lib\orchestrator-state\OrchestratorStateCodexModelReceipts.Tests.ps1

Full sanitized output: SCRATCH/issue-977-regression-testing-attestation-format.log
