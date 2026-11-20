# Phase 0 baseline: PSScriptAnalyzer (P0-T1)

Timestamp: 2026-11-14T23-15
Command: Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information per file over scripts/ci and tests/scripts/ci, run from an sh script under SCRATCH (one retry on the known engine NullReferenceException for CiChangeScope.psm1)
EXIT_CODE: 0
Output Summary: files=15 findings=0.
