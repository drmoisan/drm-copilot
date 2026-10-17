Timestamp: 2026-10-17T18:06:09.947879+00:00
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root . -GetFileList { Get-Item extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/record-subagent-routing-attestation.ps1 }
EXIT_CODE: 0
Output Summary:

PSScriptAnalyzer passed: no findings under .

Full sanitized output: SCRATCH/issue-977-regression-testing-attestation-bundle-lint.log
