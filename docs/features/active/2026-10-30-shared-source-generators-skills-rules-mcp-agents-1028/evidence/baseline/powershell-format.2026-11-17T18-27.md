# Baseline — PowerShell format (check mode)

Timestamp: 2026-11-17T18-27
Command: sh SCRATCH/issue-1028-psstatic.sh format issue-1028-psformat.out (imports `scripts/powershell/PoshQC/PoshQC.psd1` and calls `Invoke-PoshQCFormat -Root <worktree root> -ScanFolders scripts,tests/scripts` with an injected `WriteFile` seam that records each path the formatter would rewrite and writes nothing)
EXIT_CODE: 0
Output Summary: 950 files scanned; 0 files would change; 0 errors. `git status --porcelain` was empty after the run, so no file was written.
