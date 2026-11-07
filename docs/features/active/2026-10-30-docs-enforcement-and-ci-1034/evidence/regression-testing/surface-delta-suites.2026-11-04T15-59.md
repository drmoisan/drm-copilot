# Command-Context Revision Members and surface-delta Suites - Issue 1034 (Phase 3)

Timestamp: 2026-11-04T15-59
Command: sh SCRATCH/issue-1034-run.sh SCRATCH/issue-1034-pester-files.ps1 -Path <suite> -JUnitPath SCRATCH/<task>-junit.xml [-CoveragePath <module>] for each suite below (branch-current Pester 5); Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over every created or edited file; git diff --ignore-all-space MERGE_BASE -- .claude/lib/docs/Invoke-DocsCommand.ps1 and git diff MERGE_BASE -- .claude/lib/docs/Invoke-DocsCommand.ps1
EXIT_CODE: 0
Output Summary: Every suite reports 0 failures and 0 errors. PSScriptAnalyzer reports 0 findings for every Phase 3 file. The whitespace-insensitive merge-base diff of Invoke-DocsCommand.ps1 has 0 removed lines; the whitespace-sensitive diff removes only the eight realigned member lines of the New-DocsCommandContext literal. MERGE_BASE is a94dea9a4be0743f00ff78de095c51e14d513b20.

| Task | Suite | Tests | Failures | Scoped line coverage |
|---|---|---|---|---|
| P3-T2 | tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1 (includes "exposes the same member names as the in-memory context and the four InvokeProcess parameters") | 47 | 0 | n/a |
| P3-T3 | tests/scripts/claude-lib/docs/Invoke-DocsCommand.RevisionContext.Tests.ps1 | 23 | 0 | every line of Resolve-DocsContextRevision, Read-DocsContextRevisionText and the two member closures covered |
| P3-T5 | tests/scripts/claude-lib/docs/DocsSurfaceDelta.Tests.ps1 | 17 | 0 | DocsSurfaceDelta.psm1 100% (70 of 70) |
| P3-T7 | tests/scripts/claude-lib/docs/Invoke-DocsCommand.Tests.ps1 after the row (includes "returns no finding for the committed table") | 47 | 0 | n/a |
| P3-T8 | tests/scripts/claude-lib/docs/DocsSurfaceDeltaCommands.Tests.ps1 | 15 | 0 | DocsSurfaceDeltaCommands.psm1 97.47% (77 of 79) |

## Passing Tests per Error Code

- P3-T3: DOCS_CONTEXT_REF_INVALID 3, DOCS_CONTEXT_PROCESS_OUTPUT_INVALID 1, DOCS_CONTEXT_PROCESS_TIMEOUT 2, DOCS_PROCESS_START_FAILED 1, DOCS_CONTEXT_PATH_INVALID 3, DOCS_CONTEXT_REVISION_INVALID 2.
- P3-T5: DOCS_SURFACE_UNLEDGERED_ADDITION 1, DOCS_SURFACE_UNLEDGERED_CHANGE 1, DOCS_SURFACE_REMOVED_ENTRY_RETAINED 1, DOCS_SURFACE_SNAPSHOT_MISSING 1, DOCS_SURFACE_SNAPSHOT_STALE 1, DOCS_SURFACE_BASE_UNRESOLVED 1 (plus the seeded shuffle test, seed 1034, five iterations).
- P3-T8: DOCS_CLI_ARGUMENTS 2 (`--upload-pack=x`, `main..topic`), DOCS_SURFACE_BASE_UNRESOLVED 1, DOCS_SURFACE_SNAPSHOT_MISSING 1, DOCS_SURFACE_SNAPSHOT_STALE 1, DOCS_SURFACE_UNLEDGERED_ADDITION 1; each tested exit path's -Json envelope passes Test-DocsArtifactText with ArtifactKind docs-command-envelope against Get-DocsComposedSchemaSet.

## File Sizes (physical lines)

- .claude/lib/docs/Invoke-DocsCommand.ps1: 534
- .claude/lib/docs/DocsSurfaceDelta.psm1: 292
- .claude/lib/docs/DocsSurfaceDeltaCommands.psm1: 208

## P0-T3 Enumeration Record

P0-T3 recorded `none` for further assertions enumerating the complete subcommand set, so P3-T7 changed no test file.

## Folder Sanity Run (informational)

A branch-current run of every suite under `tests/scripts/claude-lib/docs/` after P3-T8 reported 1408 tests, 1404 passed, 4 failed, 0 errored. All four failures are in `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` ("lists every filtered docs file exactly once in core.json paths", "reports a path absent from an in-memory manifest (positive control)", "ships a bundled counterpart for every filtered docs file", "ships byte-identical bundled counterparts"). They name only `DocsCompleteGate.psm1`, `DocsSurfaceDelta.psm1` and `DocsSurfaceDeltaCommands.psm1`, which have no bundle copy or `core.json` entry yet. The plan adds both in P6-T1 and P6-T2 and runs this suite in P6-T4 (`## Existing Asserting Tests and Dispositions`), so these failures are expected until Phase 6.
