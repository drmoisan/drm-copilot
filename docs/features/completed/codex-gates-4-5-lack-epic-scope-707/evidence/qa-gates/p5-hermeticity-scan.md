# Phase 5 Hermeticity Scan ([P5-T5], AC-15, AC-16 local proxy)

Timestamp: 2026-09-27T07-22
Command: sh <SCRATCHPAD>/x707p1-run.sh x707p5-collect (fresh PowerShell 7 process, section `T5 HERMETICITY`: per file, case-insensitive `Select-String -SimpleMatch` counts of seven tokens and `Select-String -Pattern` counts of two regular expressions; mocked command names from `CommandAst` nodes named `Mock`, first positional or `-CommandName` argument)
EXIT_CODE: 0
Output Summary: All 27 counts (3 files x 9 patterns) are 0. Suite B mocks include Find-WorktreeResolutionRoot, Get-EpicScopeCheckpointText, Get-EpicScopeWorktreeHeadBranch, and Test-EpicScopeMergeInProgress; Suite A mocks include those four plus Get-WorktreeResolutionGitEntryKind and Get-WorktreeResolutionGitFileText. Suite C registers no Mock (it injects its readers through decision parameters).

## Count rows

Tokens (simple match, case-insensitive): `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName`, `origin/main`, `Set-Location`, `Push-Location`. Regular expressions: `\b[A-Za-z]:[\\/]`, `Get-Content.*orchestrator-state\.json`.

| File | New-TemporaryFile | TestDrive | GetTempPath | GetTempFileName | origin/main | Set-Location | Push-Location | drive-letter regex | Get-Content checkpoint regex |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` (Suite B) | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1` (Suite A) | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| `tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1` (Suite C) | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

## Mocked command names

- Suite B (`enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`): `Find-WorktreeResolutionRoot`, `Get-Content`, `Get-EpicScopeCheckpointText`, `Get-EpicScopeWorktreeHeadBranch`, `Get-OrchestrationDelegationCheckpointPath`, `Resolve-EpicScopeCheckpoint`, `Test-EpicScopeMergeInProgress`, `Test-Path`
- Suite A (`enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1`): `Find-WorktreeResolutionRoot`, `Get-EpicScopeCheckpointText`, `Get-EpicScopeWorktreeHeadBranch`, `Get-WorktreeResolutionGitEntryKind`, `Get-WorktreeResolutionGitFileText`, `Test-EpicScopeMergeInProgress`
- Suite C (`enforce-completion-consistency-epic-scope.Tests.ps1`): none (readers are supplied through `-FolderExistsCheck`, `-RoutingMatrixReader`, and `-CheckpointReader` parameters)

Result: every count is 0 and both required mocked-name lists are satisfied.
