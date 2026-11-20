# Final QC static — PowerShell ([P7-T1])

Timestamp: 2026-11-18T01-31
Command: sh SCRATCH/issue-1028-final-static.sh (PowerShell section)
EXIT_CODE: 0
Output Summary: Format and analysis pass with zero findings over `scripts` and `tests/scripts`. The formatter changed no file: the porcelain status was empty after the step. Both counts equal the [P0-T2] baseline of 0. The file count rose from 950 to 965 with the 15 new files.

| Step | Command | Exit code | Finding count | Baseline ([P0-T2]) |
| --- | --- | --- | --- | --- |
| Format | `pwsh -NoProfile -File SCRATCH/issue-1028-psstatic.ps1 -Mode format -FolderList 'scripts;tests/scripts'`: `Invoke-PoshQCFormat` through `scripts/powershell/PoshQC/PoshQC.psd1` with an injected `WriteFile` that records and does not write | 0 | 0 of 965 files would change, 0 errors; porcelain status unchanged (empty) | 0 of 950 |
| Analyze | `pwsh -NoProfile -File SCRATCH/issue-1028-psstatic.ps1 -Mode analyze -FolderList 'scripts;tests/scripts'`: `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` per file | 0 | 0 findings, 0 errors over 965 files (1 same-file retry after the host-level transient `NullReferenceException`) | 0 of 950 |
| Type check | Not applicable for PowerShell | n/a | n/a | n/a |
