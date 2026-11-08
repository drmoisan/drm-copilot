# PowerShell Final-QC Static (P5-T1)

Timestamp: 2026-11-08T17-52
Command: sh-launched pwsh 7.6.9 running SCRATCH/issue-1138-static.ps1 -LeakScan over .claude/hooks/epic-invocation-nesting-depth.ps1, .claude/hooks/enforce-epic-invocation-origin.ps1, tests/scripts/claude-hooks/epic-invocation-nesting-depth.Tests.ps1, tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1, tests/scripts/claude-runtime/NestingDepthContract.Tests.ps1, and the BUNDLE copies of the two hooks
EXIT_CODE: 0
Output Summary:
- Step 1 formatter (Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1, check-only comparison): exit 0, 0 of 7 files needing change
- Step 2 Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1: exit 0, 0 findings
- Step 3 Invoke-PoshQCLeakScan -Root <worktree root> (branch-current scripts/powershell/PoshQC/PoshQC.psd1): exit 0; "712 files, 74 findings, 72 exempt, 2 allowlisted, 0 failures"
- git status --porcelain after the run: empty (no tracked file modified by the formatter)
- Loop restarts: none (no step changed a file or failed)
