# [P6-T2] PoshQC analyzer QA gate (issue #1022)

Timestamp: 2026-11-04T02-39
Command: pwsh -NoProfile -File SCRATCH/issue-1022-p0t5-analyze-baseline.ps1 -WorktreeRoot <item worktree> -OutputPath SCRATCH/issue-1022-p6t2-findings.txt (imports scripts/powershell/PoshQC/PoshQC.psd1, builds the file list with Get-PoshQCFileList -Root <item worktree> -ScanFolders @() -ExcludeDirs <PoshQC $script:DefaultExcludedDirs>, and runs Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 for each file)
EXIT_CODE: 0
Output Summary: Files analyzed: 640 (baseline 621). Total findings: 0 (Error 0, Warning 0, Information 0); baseline [P0-T5] total 0. Zero findings in files this plan created or changed. The findings output file was not written because the finding list was empty.

## Counts

| Severity | This run | [P0-T5] baseline |
|---|---|---|
| Error | 0 | 0 |
| Warning | 0 | 0 |
| Information | 0 | 0 |
| Total | 0 | 0 |
