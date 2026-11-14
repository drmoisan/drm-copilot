# PowerShell static baseline ([P0-T3])

Timestamp: 2026-11-10T03-56
Command: sh SCRATCH/issue-1159-ps-static.sh SCRATCH/issue-1159-p0-static-list.txt SCRATCH/issue-1159-p0-static.out (pwsh 7: for each listed file, `Invoke-Formatter -ScriptDefinition <LF-normalized text> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` compared with the file text, writing nothing; then `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1`)
EXIT_CODE: 0
Output Summary: 61 files checked, 0 missing. Format step (check mode, no rewrite): exit 0, 0 files need formatting. Analyzer step: exit 0, 0 findings.

## Steps

| Step | Command | Exit code | Finding count |
|---|---|---|---|
| Format check | `Invoke-Formatter` per file with the PoshQC settings, output compared with the LF-normalized file text, nothing written (`Invoke-PoshQCFormat` has no check mode) | 0 | 0 files needing formatting |
| Analyzer | `Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` per file | 0 | 0 findings |

## Files in scope (61)

- `.claude/lib/discovery-validation/DiscoveryCapability.psm1`
- The 35 D6-set files and the 7 D13-set hooks of `pretooluse-inventory.2026-11-10T03-48.md` (38 distinct files: the three Claude D13 hooks and the two Codex discovery hooks are also D6 members; `.codex/hooks/enforce-evidence-locations.ps1` and `.codex/hooks/enforce-file-size-limit.ps1` are D13 only).
- Phase 4 and related test files (22): `tests/scripts/claude-runtime/claude-settings.Tests.ps1`, `docs-authoring-roles.Registration.Tests.ps1`, `HookDependencyGraph.Helpers.ps1`, `hook-dependency-guard-completeness.Tests.ps1`, `hook-imported-modules-no-stdout.Tests.ps1`, `EnforcementHooksNoPythonInvocation.Helpers.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`, `claude-architecture-doc.Tests.ps1`; `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`, `enforce-worktree-poetry-venv.Tests.ps1`, `enforce-orchestration-preimplementation-gate.Tests.ps1`, `cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1`, `PreToolUsePayload.Contract.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `discovery-capability.Tests.ps1`; `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`, `codex-bundle-hook-probe.Tests.ps1`, `discovery-capability.Tests.ps1`, `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, `codex-epic-runtime-contracts.Tests.ps1`; `tests/scripts/claude-lib/discovery-validation/DiscoveryCapability.Tests.ps1`.

Pre-existing format drift: none (0 files), so no drift was repaired before capture.
