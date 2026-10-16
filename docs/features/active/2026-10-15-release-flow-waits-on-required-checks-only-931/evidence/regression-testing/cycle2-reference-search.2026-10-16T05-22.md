# Cycle 2 Post-Edit Reference Search (Issue #931)

Timestamp: 2026-10-16T05-22
Command: git grep -l -F -e "Invoke-FullReleaseFlow" -- . ':(exclude)docs'
EXIT_CODE: 0
Output Summary: git grep lists 6 files, all in the P0-T11 list; the CheckClassification suite no longer appears. Both new files appear as `??` entries in porcelain (uncommitted at this point). The Grep tool found 0 matches for `CheckClassification.Tests` and `Invoke-FullReleaseFlow.CheckHelpers` in `.claude`, `.github`, `.codex`, `.agents`, `extensions`, `packages`, `config`, and `.vscode`. No mirror needs an edit.

## git grep (distinct files)

The command was run with `-l` to list files (`git grep -l -F -e "Invoke-FullReleaseFlow" -- . ':(exclude)docs'`, exit 0); the line-level form matches the P0-T11 inventory minus the deleted suite.

```text
.vscode/tasks.json
scripts/dev-tools/Invoke-FullReleaseFlow.ps1
tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1
tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1
tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py
```

## git status --porcelain

```text
 M scripts/dev-tools/Invoke-FullReleaseFlow.ps1
 D tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckClassification.Tests.ps1
 M tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1
 M tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1
?? SCRATCH/
?? docs/features/active/2026-10-15-release-flow-waits-on-required-checks-only-931/evidence/other/cycle2-phase1-handoff.2026-10-16T05-17.md
?? scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1
?? tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1
```

## Grep tool, eight directories

Regex `CheckClassification\.Tests|Invoke-FullReleaseFlow\.CheckHelpers` (both literals, metacharacters escaped), count mode:

| Directory | Matches |
|---|---|
| `.claude` | 0 |
| `.github` | 0 |
| `.codex` | 0 |
| `.agents` | 0 |
| `extensions` | 0 |
| `packages` | 0 |
| `config` | 0 |
| `.vscode` | 0 |
