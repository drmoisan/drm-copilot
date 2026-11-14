# [P0-T5] PoshQC analyzer baseline (issue #1022)

Timestamp: 2026-11-03T21-52
Command: pwsh -NoProfile -File SCRATCH/issue-1022-p0t5-analyze-baseline.ps1 -WorktreeRoot <item worktree> -OutputPath SCRATCH/issue-1022-p0t5-findings.txt (imports scripts/powershell/PoshQC/PoshQC.psd1, builds the file list with Get-PoshQCFileList -Root <item worktree> -ScanFolders @() -ExcludeDirs <PoshQC $script:DefaultExcludedDirs>, and runs Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 for each file)
EXIT_CODE: 0
Output Summary: Files analyzed: 621. Total findings: 0 (Error 0, Warning 0, Information 0). Excluded directories (PoshQC default): .git, .venv, venv, node_modules, dist, build, .pytest_cache, __pycache__, .mypy_cache, .ruff_cache, .vscode, .idea, artifacts, .vscode-test.

## Counts

| Severity | Count |
|---|---|
| Error | 0 |
| Warning | 0 |
| Information | 0 |
| Total | 0 |

The file set equals the 621 files that `Invoke-PoshQCFormat` visited in [P0-T4] (same discovery function and exclusion list).
