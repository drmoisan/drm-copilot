# Baseline PSScriptAnalyzer - Issue #1021

Timestamp: 2026-11-03T21-51
Task: [P0-T7]
Command: `sh SCRATCH/issue-1021-pssa.sh` (PowerShell 7: `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -ErrorAction Stop` for every `.ps1`, `.psm1` and `.psd1` file found recursively under `.claude/lib/docs` and `tests/scripts/claude-lib/docs`, with the per-file NullReferenceException retry that `Invoke-PoshQCAnalyze` uses)
EXIT_CODE: 0
Output Summary: 23 files analyzed; 0 findings (Error 0, Warning 0, Information 0, ParseError 0); no retry was needed.

Note: a first attempt that passed each folder to `Invoke-ScriptAnalyzer -Recurse` in one call threw `Object reference not set to an instance of an object.` (the intermittent engine NullReferenceException that `Invoke-PoshQCAnalyze` retries) and recorded no result; it was replaced by the per-file run above.
