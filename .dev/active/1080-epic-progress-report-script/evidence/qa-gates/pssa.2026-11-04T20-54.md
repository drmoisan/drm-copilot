# Analyzer Gate (Issue #1080, P2-T2)

Timestamp: 2026-11-04T20-54
Command: sh SCRATCH/issue-1080-tool.sh issue-1080-pssa.ps1 issue-1080-p2t2.log scripts/dev-tools/Get-EpicProgressReport.ps1,scripts/dev-tools/Get-EpicProgressReport.Logic.ps1,tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1,tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1 (Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, one call per file)
EXIT_CODE: 0

## Result

- FILES-CHECKED=4
- PSSA-FINDINGS=0
- ANALYZER-ERRORS=0

The same runner reported two findings (`PSUseSingularNouns`, `PSUseOutputTypeCorrectly`) during P1-T7 before their remediation, so it does report findings when they exist.

Output Summary: PSSA-FINDINGS=0 over the four change-set files, no analyzer errors.
