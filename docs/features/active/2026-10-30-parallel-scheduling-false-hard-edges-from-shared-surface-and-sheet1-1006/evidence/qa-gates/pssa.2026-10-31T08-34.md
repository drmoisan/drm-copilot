# PSScriptAnalyzer (issue #1006)

Timestamp: 2026-10-31T08-34
Task: P8-T6
Command: sh SCRATCH/issue-1006-ps.sh issue-1006-pssa.ps1 -Final (Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, one child process per file)
EXIT_CODE: 0
Output Summary: `PSSA_TOTAL: 0`, `PSSA_ERRORS: 0`.

| File | Findings |
|---|---|
| .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 0 |
| .claude/lib/blast-radius/BlastRadiusExtraction.psm1 | 0 |
| .claude/lib/blast-radius/BlastRadiusNormalization.psm1 | 0 |
| .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 | 0 |
| .claude/lib/blast-radius/BlastRadius.psm1 | 0 |
| tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 | 0 |
| tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 | 0 |
| tests/scripts/claude-lib/blast-radius/BlastRadiusGenericContract.Tests.ps1 | 0 |
| tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 | 0 |

An earlier loop pass reported two `PSUseShouldProcessForStateChangingFunctions` findings on the test helpers `New-ScenarioRadius` and `New-ScenarioItem`; they were renamed to `Get-ScenarioRadius` and `Get-ScenarioItem` (they build and return values) and the loop restarted from P8-T1.
