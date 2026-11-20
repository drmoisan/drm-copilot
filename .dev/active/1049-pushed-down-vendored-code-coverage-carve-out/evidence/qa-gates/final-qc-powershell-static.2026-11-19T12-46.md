# Final QC - PowerShell Static - [P4-T1]

Timestamp: 2026-11-19T12-46
Command: sh SCRATCH/issue-1049-final.sh issue-1049-final1 (steps T1, 12:41Z to 12:45Z): sh SCRATCH/issue-1049-static.sh format | analyze | leak, each a PowerShell 7 session importing scripts/powershell/PoshQC/PoshQC.psd1 over the scan folders scripts and tests/scripts
EXIT_CODE: 0
Output Summary: Format: identical porcelain listings, 0 files formatted. Analyzer: 0 findings. Leak scan: exit 0, 0 failures. PowerShell has no type check. No step changed a file, so the final loop did not restart.

| Step | Command | Exit | Findings |
| --- | --- | --- | --- |
| Format | git status --porcelain; Invoke-PoshQCFormat -ScanFolders scripts, tests/scripts -SettingsPath scripts/powershell/PoshQC/settings/pssa.settings.psd1; git status --porcelain | 0 | PORCELAIN: identical; FORMATTED_COUNT 0; ALREADY_FORMATTED_COUNT 986 |
| Lint | Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information (through Invoke-PoshQCAnalyze) | 0 | 0 findings |
| Leak scan | Invoke-PoshQCLeakScan -Root | 0 | `Leak scan: 899 files, 80 findings, 78 exempt, 2 allowlisted, 0 failures.` (0 failures) |
| Type check | not applicable to PowerShell | n/a | n/a |
