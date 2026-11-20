# PowerShell static baseline (issue #1157)

Timestamp: 2026-11-10T03-13
Command: sh SCRATCH/issue-1157-static.sh issue-1157-p0-files.txt (pwsh 7: Invoke-Formatter check mode comparing formatted text with file text, Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1, then Invoke-PoshQCLeakScan -Root from the branch-current scripts/powershell/PoshQC/PoshQC.psd1)
EXIT_CODE: 0
Output Summary:
- Files checked: 7 (.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1, .claude/hooks/validate-orchestrator-output.ps1, tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1, tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1, tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1, tests/scripts/claude-runtime/owner-directives-skill-contract.Tests.ps1, tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1)
- Format step: Invoke-Formatter check mode, nothing written; files whose formatted text differs: 0 (EXIT_CODE 0)
- Lint step: Invoke-ScriptAnalyzer findings: 0 (EXIT_CODE 0)
- Leak scan step: Invoke-PoshQCLeakScan -Root; "Leak scan: 739 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures."; EXIT_CODE 0
