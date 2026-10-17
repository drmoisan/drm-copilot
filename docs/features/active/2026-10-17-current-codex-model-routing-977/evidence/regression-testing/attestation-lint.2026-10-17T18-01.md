Timestamp: 2026-10-17T18:01:08.971254+00:00
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root . -GetFileList { Get-Item .codex/hooks/record-subagent-routing-attestation.ps1, tests/scripts/codex-hooks/subagent-attestation-persistence.Tests.ps1, tests/scripts/codex-hooks/subagent-attestation-command.Tests.ps1 }
EXIT_CODE: 0
Output Summary:

PSScriptAnalyzer passed: no findings under .

Full sanitized output: SCRATCH/issue-977-regression-testing-attestation-lint.log
