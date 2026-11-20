# Final QC: PowerShell Static (P6-T1)

Timestamp: 2026-11-13T23-17
Command: sh SCRATCH/issue-1169-static.sh final (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root <worktree root> with a no-op WriteFile seam that records each would-be change; then Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 on every file of Get-PoshQCFileList -Root <worktree root>, PSScriptAnalyzer 1.25.0, one retry per file on an analyzer exception)
EXIT_CODE: 0
Output Summary:
- Step 1, format: Invoke-PoshQCFormat over 1572 files (whole worktree root, the CI static-job scope); exit 0; finding count 0 (the formatter reports zero changed files: FORMAT_CHANGED=0).
- Step 2, lint: Invoke-ScriptAnalyzer with the repository settings over the same 1572 files; exit 0; finding count 0 (0 errors, 0 warnings, 0 information); 0 analyzer retries.
- Step 3, type check: not applicable to PowerShell.
- `git status --porcelain` after the run: empty (0 lines), so the run changed no tracked file.
- No restart was needed: no step failed or changed a file.
