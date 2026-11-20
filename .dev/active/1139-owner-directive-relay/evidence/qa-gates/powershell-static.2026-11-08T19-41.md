# PowerShell Final Static Loop, Pass 2 ([P4-T2] restart after the [P4-T3] fix)

Timestamp: 2026-11-08T19-40
Command: sh SCRATCH/issue-1139-final-static.sh (pwsh -NoProfile -File SCRATCH/issue-1139-ps-static.ps1 over the PowerShell files changed since MB; then the branch-current module's Invoke-PoshQCLeakScan -Root <worktree root>; then Black, Ruff, and Pyright on the one changed Python file)
EXIT_CODE: 0
Output Summary: Restarted after the [P4-T3] fix added one help-block line to OrchestratorStateOwnerDirectives.psm1 and its bundle copy. 10 PowerShell files examined: 0 files the formatter would change, 0 Invoke-ScriptAnalyzer findings. Invoke-PoshQCLeakScan: "717 files, 74 findings, 72 exempt, 2 allowlisted, 0 failures", exit 0. Python: Black "1 file would be left unchanged.", Ruff "All checks passed!" (the Python file is unchanged since python-static.2026-11-08T19-26.md, which records Pyright 0 errors). P0-T1 comparison: format 0 -> 0, analyzer 0 -> 0.

## Steps

| Step | Command | EXIT_CODE | Finding count |
|---|---|---|---|
| Format (check-only) | `Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`, compared with the file text (no file written) | 0 | 0 files would change |
| Analyze | `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | 0 | 0 findings |
| Leak scan | `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCLeakScan -Root <worktree root>` | 0 | 0 failures |

The file list is the one in powershell-static.2026-11-08T19-26.md.
