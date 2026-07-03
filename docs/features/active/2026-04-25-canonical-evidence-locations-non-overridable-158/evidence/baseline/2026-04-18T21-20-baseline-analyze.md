Timestamp: 2026-04-18T21-20
Command: pwsh -NoProfile -ExecutionPolicy Bypass -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path"
EXIT_CODE: non-zero (threw "PSScriptAnalyzer reported 20 issue(s).")
Output Summary:
- Total findings: 20 (all Warning severity)
- Rule breakdown:
  - PSUseConsistentWhitespace x16 in .claude/hooks/check-powershell-test-purity.ps1 (lines 71-87; "Use space after a semicolon")
  - PSAvoidUsingEmptyCatchBlock x2 in .claude/hooks/enforce-powershell-batch-budget.ps1 (lines 100, 135)
  - PSAvoidUsingEmptyCatchBlock x2 in .claude/hooks/enforce-python-batch-budget.ps1 (lines 97, 131)
- All 20 findings originate from untracked hook files introduced before this task. Per the task context these are pre-existing environment state on this branch, not defects attributable to the failing test.
