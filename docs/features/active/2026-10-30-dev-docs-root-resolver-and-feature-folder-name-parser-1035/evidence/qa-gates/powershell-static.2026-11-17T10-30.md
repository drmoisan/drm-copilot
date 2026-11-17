# PowerShell Static Gate (P9-T7)

Timestamp: 2026-11-17T10-30
Command: sh SCRATCH/issue-1035-p9t7-run.sh (sh SCRATCH/issue-1035-ps-static.sh from the worktree root: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root . -WriteFile { no-op } -Logger { capture } over Get-PoshQCFileList -Root .; then Invoke-PoshQCAnalyze with Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information over the same files), and sh SCRATCH/issue-1035-p9t7-format-log.sh (the same format call, printing the log-line counts)
EXIT_CODE: 0
Output Summary: One pass, no finding, so no restart.

| Step | Observation | Findings |
| --- | --- | --- |
| Format check (no-op `-WriteFile`, the P0-T6 form) | 1802 files; 1802 log lines, every one `Already formatted:`; 0 `Formatted:` lines; no file rewritten | 0 |
| Analyzer (pssa.settings.psd1) | 1802 files; Invoke-PoshQCAnalyze logged 3 retry messages (its built-in NullReferenceException retry) and completed without a throw | 0 total: Error 0, Warning 0, Information 0 |
