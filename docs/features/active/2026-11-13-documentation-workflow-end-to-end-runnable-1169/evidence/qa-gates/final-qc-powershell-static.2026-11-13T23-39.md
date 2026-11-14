# Final QC: PowerShell Static (P6-T1, restarted loop)

Timestamp: 2026-11-13T23-35
Command: sh SCRATCH/issue-1169-static.sh final3 (pwsh 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root <worktree root> with a no-op WriteFile seam that records each would-be change; then Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 on every file of Get-PoshQCFileList -Root <worktree root>, PSScriptAnalyzer 1.25.0, one retry per file on an analyzer exception)
EXIT_CODE: 0
Output Summary:
- Why this run supersedes final-qc-powershell-static.2026-11-13T23-20.md: the first final pass found a per-file coverage drop in DocsLedgerCommands.psm1 (P6-T4), fixed by two new unit rows in tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1, so the loop restarted. The first restarted static run (2026-11-13T23-31) hit the intermittent PSScriptAnalyzer 1.25 exception twice on extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1, a file this branch does not change; it counted as a lint error and the loop restarted again with this run.
- Step 1, format: Invoke-PoshQCFormat over 1572 files; exit 0; finding count 0 (the formatter reports zero changed files: FORMAT_CHANGED=0).
- Step 2, lint: Invoke-ScriptAnalyzer with the repository settings over the same 1572 files; exit 0; finding count 0; one analyzer exception on .claude/lib/docs/DocsPythonSyntax.psm1 (not changed by this branch) succeeded on its retry.
- Step 3, type check: not applicable to PowerShell.
- `git status --porcelain` is unchanged by the run (the only working-tree change is the new test rows, made before the run).
