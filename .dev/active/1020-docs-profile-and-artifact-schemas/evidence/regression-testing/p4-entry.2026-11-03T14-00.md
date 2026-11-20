# Invoke-DocsCommand Suite ([P4-T4])

Timestamp: 2026-11-03T14-00
Command: sh SCRATCH/issue-1020-test.sh tests/scripts/claude-lib/docs issue-1020-exec-p4-entry-final.log (branch-current `Invoke-PoshQCTest -ScanFolders tests/scripts/claude-lib/docs` from `scripts/powershell/PoshQC/PoshQC.psd1`); counts read from `artifacts/pester/pester-junit.xml` by SCRATCH/issue-1020-summary.ps1 and SCRATCH/issue-1020-exec-suites.ps1
EXIT_CODE: 0
Output Summary: `Invoke-DocsCommand.Tests.ps1` tests=44 failures=0 errors=0 skipped=0, with `Test-Json` not mocked. Whole run (10 suites): tests=341 failures=0 errors=0 skipped=0. Line coverage of `.claude/lib/docs/Invoke-DocsCommand.ps1` 85.91% (128 covered, 21 missed); every missed line lies in the two capped bodies: 16 in `Invoke-DocsProcess` (cap 20) and 5 in `Write-DocsFileText` (cap 6). The per-file gate itself is asserted in [P6-T3].

## Per-suite counts

| Suite | tests | failures | errors | skipped |
|---|---|---|---|---|
| DocsAnalyzerRegistry.Tests.ps1 | 30 | 0 | 0 | 0 |
| DocsFinding.Tests.ps1 | 30 | 0 | 0 | 0 |
| DocsJson.Tests.ps1 | 27 | 0 | 0 | 0 |
| DocsProfile.Tests.ps1 | 24 | 0 | 0 | 0 |
| DocsProfileCommands.Tests.ps1 | 22 | 0 | 0 | 0 |
| DocsSchema.Tests.ps1 | 37 | 0 | 0 | 0 |
| DocsSchemaContract.Tests.ps1 | 49 | 0 | 0 | 0 |
| DocsSchemaWalk.Tests.ps1 | 12 | 0 | 0 | 0 |
| DocsSurface.Tests.ps1 | 66 | 0 | 0 | 0 |
| Invoke-DocsCommand.Tests.ps1 | 44 | 0 | 0 | 0 |

## Per-file line coverage (`artifacts/pester/powershell-coverage.xml`)

| File | covered | missed | percent |
|---|---|---|---|
| .claude/lib/docs/DocsAnalyzerRegistry.psm1 | 119 | 0 | 100 |
| .claude/lib/docs/DocsFinding.psm1 | 88 | 0 | 100 |
| .claude/lib/docs/DocsJson.psm1 | 102 | 0 | 100 |
| .claude/lib/docs/DocsProfile.psm1 | 81 | 0 | 100 |
| .claude/lib/docs/DocsProfileCommands.psm1 | 67 | 2 | 97.1 |
| .claude/lib/docs/DocsSchema.psm1 | 127 | 0 | 100 |
| .claude/lib/docs/DocsSchemaWalk.psm1 | 87 | 0 | 100 |
| .claude/lib/docs/DocsSurface.psm1 | 130 | 0 | 100 |
| .claude/lib/docs/Invoke-DocsCommand.ps1 | 128 | 21 | 85.91 |

## Implementation notes for review

- Context members. A closure created with `GetNewClosure()` resolves no script-scope function and, under Pester, no module function imported by the dot-sourced script (observed in the first run of this suite: 10 failures, `Test-DocsRelativePath` not recognized; probe scripts SCRATCH/issue-1020-exec-probe-closure*.ps1). The repository members (`ReadText`, `ReadBytes`, `TestFile`, `ListFile`, `WriteText`) are therefore closures over the repository root whose optional `[scriptblock] $Operation` parameter defaults to a script function (`Read-DocsContextText`, `Read-DocsContextByte`, `Test-DocsContextFile`, `Get-DocsContextFileList`, `Write-DocsContextText`) and is invoked as `& $Operation`, which the dynamic-invocation guard accepts as a `[scriptblock]` parameter. The positional contract of each member (`param($RelativePath)`, `param($RelativeRoot)`, `param($RelativePath, $Text, $Mode)`) is unchanged; the extra parameter is optional. `InvokeProcess` is a bound literal with exactly the four contract parameters, so `Invoke-DocsProcess` (and its Pester mock) resolves at call time.
- Working directory. The member signature carries no repository root, so `Invoke-DocsProcess` takes an optional `-WorkingDirectory` that defaults to the current location; the member forwards only its four arguments, as the spec and the mock assertion require. Callers run with the repository root as the current location (spec `## Decisions Later Children Must Honor`, 1036 invocation).
- File-size split. `DocsSchema.psm1` reached 542 lines after [P3-T3]; per the [P3-T3] instruction the structural walk moved to `.claude/lib/docs/DocsSchemaWalk.psm1` (`Get-DocsSchemaWalkFinding`) with its own suite `DocsSchemaWalk.Tests.ps1`. `Get-DocsSchemaStructuralFinding` stays exported from `DocsSchema.psm1` with the spec signature and delegates to the walk module. After the split: `DocsSchema.psm1` 404 lines, `DocsSchemaWalk.psm1` 208 lines. The split module adds one bundle copy and one `core.json` line to Phase 5 (the plan's sixteen-file counts in [P5-T1] and [P5-T2] become seventeen), and rows were added to `## Artifact Classification`.
- Import graph. `Invoke-DocsCommand.ps1` imports `DocsSurface.psm1` (relative-path check) and `DocsSchema.psm1` (version floor) in addition to `DocsJson.psm1` and `DocsFinding.psm1`; command modules are still imported only when their row is selected.
