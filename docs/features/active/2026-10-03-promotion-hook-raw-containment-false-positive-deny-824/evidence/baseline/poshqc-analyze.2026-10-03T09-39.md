# P0-T12 Baseline analyze

Timestamp: 2026-10-03T09-39
Command: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path' *> "SCRATCH/analyze-baseline.log"; $LASTEXITCODE; then (Select-String -SimpleMatch 'PSScriptAnalyzer passed: no findings under').Count
EXIT_CODE: 0
Output Summary:
- Analyze run exit code: 0
- 'PSScriptAnalyzer passed: no findings under' count: 1
- Log line: "PSScriptAnalyzer passed: no findings under WORKTREE"
- Result: PASS (zero findings)
