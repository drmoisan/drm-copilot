# PowerShell Final Static Loop ([P4-T2])

Timestamp: 2026-11-08T19-25
Command: sh SCRATCH/issue-1139-final-static.sh (pwsh -NoProfile -File SCRATCH/issue-1139-ps-static.ps1 over the PowerShell files changed since MB; then the branch-current module's Invoke-PoshQCLeakScan -Root <worktree root>)
EXIT_CODE: 0
Output Summary: 10 PowerShell files changed since MB examined (the hook and its bundle copy, the new module and its bundle copy, and six test files). Check-only format comparison: 0 files would change. Invoke-ScriptAnalyzer 1.25.0 with scripts/powershell/PoshQC/settings/pssa.settings.psd1: 0 findings. Invoke-PoshQCLeakScan: "717 files, 74 findings, 72 exempt, 2 allowlisted, 0 failures", exit 0. One loop pass; no finding, no file changed, so no restart. P0-T1 comparison: format 0 -> 0, analyzer 0 -> 0 (the P0-T1 file set was the hook, its bundle copy, and .claude/lib/orchestrator-state/; the new module is included here).

## Steps

| Step | Command | EXIT_CODE | Finding count |
|---|---|---|---|
| Format (check-only) | `Invoke-Formatter -ScriptDefinition <file text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`, compared with the file text (no file written) | 0 | 0 files would change |
| Analyze | `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` | 0 | 0 findings |
| Leak scan | `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCLeakScan -Root <worktree root>` | 0 | 0 failures (74 findings: 72 exempt, 2 allowlisted) |

## Files

- `.claude/hooks/validate-orchestrator-output.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1`
- `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1`
- `tests/scripts/claude-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1`
- `tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectives.Tests.ps1`
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1`
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Records.Tests.ps1`
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1`
- `tests/scripts/claude-runtime/owner-directives-skill-contract.Tests.ps1`

The format/analyze script reports counts on stdout and exits 0 by design; the counts are the observation. The leak scan warned that the scan-configuration folder `tests/powershell` does not exist and was skipped (a configuration notice, not a finding). `git status --porcelain` was empty after the loop.
