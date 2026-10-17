Timestamp: 2026-10-17T18:00:30.275204+00:00
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root . -ScanFolders @(".codex/hooks", "tests/scripts/codex-hooks", "tests/scripts/claude-lib/codex-routing", "tests/scripts/claude-lib/orchestrator-state")
EXIT_CODE: 0
Output Summary:

PSScriptAnalyzer passed: no findings under .

Full sanitized output: SCRATCH/issue-977-regression-testing-attestation-lint.log
