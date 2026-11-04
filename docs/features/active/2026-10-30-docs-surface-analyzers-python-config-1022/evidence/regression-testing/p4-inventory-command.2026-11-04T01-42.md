# [P4-T4] Pester gate: DocsInventory (issue #1022)

Timestamp: 2026-11-04T01-42
Command: pwsh -NoProfile -File SCRATCH/issue-1022-pester-suite.ps1 -WorktreeRoot <item worktree> -Suite tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1 -CoverageFile .claude/lib/docs/DocsInventory.psm1 (Invoke-Pester with the configuration of scripts/powershell/PoshQC/settings/pester.runsettings.psd1, Run.PassThru, JUnit to artifacts/pester/pester-junit.xml, coverage over the module; one process)
EXIT_CODE: 0
Output Summary: tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1: 8 passed, 0 failed, 0 errored, 0 skipped (JUnit testsuite element; result object Passed=8 Failed=0 Skipped=0). Line execution: .claude/lib/docs/DocsInventory.psm1 100 of 100 analyzed lines (100%). The JUnit file is well-formed; counts were read from it.

## Toolchain for the new files

- Formatter: `Already formatted:` for `.claude/lib/docs/DocsInventory.psm1` and `tests/scripts/claude-lib/docs/DocsInventory.Tests.ps1` on the final pass (the first pass rewrote the hashtable alignment of the suite; 0 files rewritten afterwards).
- Analyzer (direct Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1): 0 findings for the two files on the final pass. Earlier passes reported `PSReviewUnusedParameter` on closure captures and an unused scriptblock parameter, `PSUseShouldProcessForStateChangingFunctions` on two `New-Test*` helpers, and `PSUseOutputTypeCorrectly` on the context-member helper; resolved by binding the captures to locals, dropping the parameter, renaming the helpers to `Get-Test*` and declaring `[object[]]` in the `OutputType`.
- Physical line counts: `DocsInventory.psm1` 278; `DocsInventory.Tests.ps1` 242.

## Design facts

- Exported: `Invoke-DocsInventoryCommand` only (the one non-pure 1022 function; no property test). Imports `DocsJson`, `DocsFinding`, `DocsSurface`, `DocsSchema`, `DocsProfile`, `DocsAnalyzerRegistry`, `DocsInventorySnapshot`.
- Context members are invoked only through the private `Invoke-DocsContextMember -Member <scriptblock>` helper (the 1020 `DocsProfileCommands.psm1` pattern), which re-wraps the result with the comma so that a byte array or a path list arrives as one object; the members used are `ReadText`, `ReadBytes`, `ListFile`, `UtcNow` and `WriteText` (no `TestFile`: existence of the profile and of the snapshot file is read through `ReadText`, with an item-not-found error meaning absence).
- Flow: `-Profile` (default `Get-DocsDefaultProfilePath`) must be repository-relative (else exit 2); `-Revision` must pass `Test-DocsFullRevision` (else exit 2; absent records `null`); runtime schemas composed from `Read-DocsSchemaSet`; absent profile exits 1 with `DOCS_PROFILE_MISSING` and no snapshot; profile findings exit 1 with no snapshot; rows selected through `Select-DocsAnalyzerRegistration` with `-Analyzer` ids, else `surface_selection.analyzers`, else every row covering a selected kind; an unknown `-Analyzer` or one whose row covers none of the selected kinds exits 2 naming it; files listed per source root with `ListFile`, selected with `Get-DocsInventorySelection` (env withholding); the input-count bound is checked before any read and the byte bound after each read (`Get-DocsInventoryBoundFinding`, exit 3 with `DOCS_CLI_RUNTIME`); each file is read with `ReadBytes` into `New-DocsCapturedInput -MaxBytes 1048576`; each row runs through `Invoke-DocsAnalyzer` (an output-contract finding exits 3); the snapshot is built with `New-DocsInventorySnapshot` and `UtcNow` and self-validated with `Test-DocsArtifactText -ArtifactKind 'surface-inventory-snapshot'` (exit 3 on failure); with `-Write` one `WriteText` call writes the indented text to `artifact_paths.inventory_snapshot` with mode `overwrite` when the file exists, else `create`; exit 1 with one `DOCS_INVENTORY_BLOCKING_DIAGNOSTIC` error finding per blocking diagnostic (`related_paths` its path), else exit 0; `result` is `{snapshot, snapshot_path, written}`; any other exception exits 3 with `DOCS_CLI_RUNTIME`. No output is printed and `exit` is never called.

## Behavior covered (in-memory context, fixed clock 2026-01-01T00:00:00Z)

- Exit 0 dry run: no finding, no `WriteText` call, `written` false, `revision` null, the fixed clock, the five analyzers, the expected architecture, public-symbol and config-key declarations, inputs sorted by path without the withheld `config/.env`, exactly one `ENV_FILE_NOT_CAPTURED` diagnostic, a schema-valid snapshot and no marker value in its canonical text.
- Exit 1: a blocking `YAML_INVALID` yields one `DOCS_INVENTORY_BLOCKING_DIAGNOSTIC` (error, `related_paths` `config/bad.yml`) with the snapshot still returned; an absent profile yields `DOCS_PROFILE_MISSING` with `result` null; an invalid profile and a profile naming an unknown analyzer (`DOCS_ANALYZER_UNKNOWN`) exit 1 with `result` null.
- Exit 2 (`result` null, exactly one `DOCS_CLI_ARGUMENTS` naming the value): `-Analyzer not-registered`; `-Analyzer python-cli` with a profile selecting `config-key` only; `-Revision abc`; `-Profile C:/abs.json` and `/abs.json`.
- Exit 3 (`result` null, one `DOCS_CLI_RUNTIME`): a `ReadBytes` wrapper returning 268,435,457 bytes (the byte bound stops the run after the first read; the 50,000-input bound is proven on the pure function by [P4-T3]); a `ReadBytes` wrapper that throws.
- `-Revision` recorded; without `-Write` no `WriteText` call; with `-Write` one call to the profile `artifact_paths.inventory_snapshot` with mode `create` when absent and `overwrite` when present, the written text equal to the indented snapshot and schema-valid, and a byte-identical second write with an equal `id`.
- Recording `ReadBytes` wrapper (chosen branch: `New-DocsTestContext` keeps no `ReadBytes` call record): `config/.env`, `config/.env.local` and `src/app.env` are never passed to `ReadBytes`, have no `inputs` entry and no element, and each yields `ENV_FILE_NOT_CAPTURED` (warning, non-blocking, `docs-inventory`); `config/.env.dist` and `config/.env.example` are read and produce `config-key` elements.
- A scan of the other seventeen new module texts finds no `Context` token; `DocsInventory.psm1` references `Context.ReadBytes`.

## Acceptance criteria checked off

- spec S9 (a non-template env-family file is never passed to `Context.ReadBytes`, asserted by a recording wrapper, has no `inputs` entry and no element, yields `ENV_FILE_NOT_CAPTURED`; only the four template names produce `config-key` elements): proven by [P4-T3] and this task.
- spec S16 and user-story U11 (no `WriteText` call without `-Write`; one call with mode `create` or `overwrite` with it; `DocsInventory.psm1` the only 1022 module referencing the context): proven by this task.

CI: `poshqc / PowerShell QC` (windows-latest shards).
