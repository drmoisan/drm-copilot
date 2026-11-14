# PowerShell Format and Lint Gate

Timestamp: 2026-11-07T03-46
Command: Invoke-PoshQCFormat -Root <worktree root> -ScanFolders scripts/dev-tools, tests/scripts/dev-tools, with a no-op -WriteFile; then Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 on each file below
EXIT_CODE: 0
Output Summary: format log of 78 lines with 0 `Formatted: ` lines. `Already formatted: ` appears for `scripts/dev-tools/ProcessReductionLedger.psm1`, `tests/scripts/dev-tools/ProcessReductionLedger.Tests.ps1`, and `tests/scripts/dev-tools/ProcessReductionLedger.Index.Tests.ps1`. Analyzer findings: 0 in each of the three files.

Notes:

- `ProcessReductionLedger.Index.Tests.ps1` is the split test file named in the plan's `File size` Pre-Mortem bullet, so it joins this gate.
- An earlier pass reported one `PSUseOutputTypeCorrectly` finding in `Get-ProcessReductionPlainLine`. It was fixed by emitting to the pipeline, and the gate was re-run from the format stage.
- An earlier format process stalled with almost no CPU use and was stopped. The next run completed in under a minute. No file was changed by that run.
