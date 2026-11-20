# Final QC static — PowerShell ([P7-T1], re-run after the [P7-T5] fix)

Timestamp: 2026-11-18T02-20
Command: sh SCRATCH/issue-1028-final-static.sh (PowerShell section)
EXIT_CODE: 0
Output Summary: This re-run follows the self-review fix `fix(1028): give the generator sources schemas and sorted keys`. The earlier record is `static-powershell.2026-11-18T01-31.md`. Both steps pass with zero findings, and the formatter changed no file. The counts equal the [P0-T2] baseline of 0.

| Step | Command | Exit code | Finding count | Baseline ([P0-T2]) |
| --- | --- | --- | --- | --- |
| Format | `pwsh -NoProfile -File SCRATCH/issue-1028-psstatic.ps1 -Mode format -FolderList 'scripts;tests/scripts'` (`Invoke-PoshQCFormat`, record-only `WriteFile`) | 0 | 0 of 965 files would change; porcelain status unchanged (empty) | 0 of 950 |
| Analyze | `pwsh -NoProfile -File SCRATCH/issue-1028-psstatic.ps1 -Mode analyze -FolderList 'scripts;tests/scripts'` (`Invoke-ScriptAnalyzer` with the PoshQC settings) | 0 | 0 findings, 0 errors over 965 files (2 same-file retries after the host-level transient `NullReferenceException`) | 0 of 950 |
| Type check | Not applicable for PowerShell | n/a | n/a | n/a |
