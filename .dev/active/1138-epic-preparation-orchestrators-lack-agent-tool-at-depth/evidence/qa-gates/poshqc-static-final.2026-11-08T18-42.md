# PowerShell Final-QC Static (remediation cycle 1, P0-T1 and P0-T2)

Timestamp: 2026-11-08T18-25
Command: sh SCRATCH/issue-1138-r1-static.sh (sh-launched pwsh 7.6.9 running SCRATCH/issue-1138-static.ps1 -LeakScan over .claude/hooks/epic-invocation-nesting-depth.ps1, tests/scripts/claude-hooks/epic-invocation-nesting-depth.Tests.ps1, tests/scripts/claude-runtime/NestingDepthContract.Tests.ps1); preceded by mcp__drm-copilot__run_poshqc_format over .claude/hooks, tests/scripts/claude-hooks, tests/scripts/claude-runtime
EXIT_CODE: 0
Output Summary:
- Step 1 formatter (Invoke-Formatter with scripts/powershell/PoshQC/settings/pssa.settings.psd1, check-only comparison): exit 0, 0 of 3 files needing change
- Step 2 Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1: exit 0, 0 findings
- Step 3 Invoke-PoshQCLeakScan -Root <worktree root> (branch-current PoshQC.psd1): exit 0; "712 files, 74 findings, 72 exempt, 2 allowlisted, 0 failures"
- git status after the MCP format run listed only the files edited by this cycle (no formatter rewrite)
- Bundle copy of the hook: byte-identical to the live file (cmp)
- Loop restarts: none
