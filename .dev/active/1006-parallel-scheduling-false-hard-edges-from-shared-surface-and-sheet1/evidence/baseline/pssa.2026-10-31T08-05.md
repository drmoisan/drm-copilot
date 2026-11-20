# PSScriptAnalyzer Baseline (issue #1006)

Timestamp: 2026-10-31T08-05
Task: P0-T8
Command: sh SCRATCH/issue-1006-ps.sh issue-1006-pssa.ps1 (Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, one child PowerShell 7 process per file)
EXIT_CODE: 0
Output Summary: zero findings and zero analyzer errors over 8 files.

| File | Findings |
|---|---|
| .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 | 0 |
| .claude/lib/blast-radius/BlastRadiusExtraction.psm1 | 0 |
| .claude/lib/blast-radius/BlastRadiusNormalization.psm1 | 0 |
| .claude/lib/blast-radius/BlastRadiusWriteIntent.psm1 | 0 |
| .claude/lib/blast-radius/BlastRadius.psm1 | 0 |
| tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 | 0 |
| tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 | 0 |
| tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 | 0 |

Note: a first single-process run raised the analyzer runtime error "more than one dynamic module in each dynamic assembly" on `BlastRadiusExtraction.psm1`, so per-file child processes are used; that run is not counted.
