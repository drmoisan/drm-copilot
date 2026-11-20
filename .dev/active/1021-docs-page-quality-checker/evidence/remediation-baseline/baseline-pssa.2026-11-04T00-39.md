# Remediation Baseline - PSScriptAnalyzer - issue #1021

Timestamp: 2026-11-04T00-39
Task: [P0-T3]
Command: `sh SCRATCH/issue-1021-run.sh SCRATCH/issue-1021-pssa.ps1` (PowerShell 7, PSScriptAnalyzer 1.25.0: `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` for every `.ps1`, `.psm1` and `.psd1` file under `.claude/lib/docs` and `tests/scripts/claude-lib/docs`; an analyzer `NullReferenceException` is retried up to five times per file)
EXIT_CODE: 0
Output Summary: 40 files analyzed; 0 findings. One transient analyzer `NullReferenceException` was retried and the retry succeeded. A first attempt that passed the two folders with `-Recurse` in one call ended with the same exception and is not used as the baseline.
