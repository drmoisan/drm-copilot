# Static baseline: PoshQC format (no-op write)

Timestamp: 2026-11-07T14-49
Command: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root <worktree> -ScanFolders tests/scripts/claude-runtime -WriteFile { no-op } -Logger { Write-Output } (pwsh via SCRATCH/issue-1106-static.sh)
EXIT_CODE: 0
Output Summary: 23 files scanned; Already formatted: 23 lines; Formatted: 0 lines.
