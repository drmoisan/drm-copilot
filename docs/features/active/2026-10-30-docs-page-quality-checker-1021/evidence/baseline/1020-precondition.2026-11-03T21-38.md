# 1020 Precondition - Issue #1021

Timestamp: 2026-11-03T21-38
Task: [P0-T2]
Command: file-presence test per item; `grep -n -F -e '<anchor>' <file>` per anchor; `git merge-base --is-ancestor fd6ee4e5a HEAD`
EXIT_CODE: 0
Output Summary: every 1020 item present; 1020 merge (PR #1063, `fd6ee4e5a`) is an ancestor of HEAD (exit 0); HEAD equals the integration-branch tip and MERGE_BASE (`fd6ee4e5a`). CR-3 gate: option A.

## Items

| Item | Status |
|---|---|
| `.claude/lib/docs/DocsJson.psm1` | present |
| `.claude/lib/docs/DocsFinding.psm1` | present |
| `.claude/lib/docs/DocsSchema.psm1` | present |
| `.claude/lib/docs/DocsSurface.psm1` | present |
| `.claude/lib/docs/DocsAnalyzerRegistry.psm1` | present |
| `.claude/lib/docs/DocsProfile.psm1` | present |
| `.claude/lib/docs/DocsProfileCommands.psm1` | present |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | present |
| `tests/scripts/claude-lib/docs/Docs.TestSupport.psm1` | present |
| `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` | present |
| `tests/scripts/claude-lib/docs/DocsSchemaContract.Tests.ps1` | present |
| `tests/scripts/claude-lib/docs/DocsNeutrality.Tests.ps1` | present |
| `schemas/docs/v1/docs-command-envelope.schema.json` | present |
| anchor `# --- 1021: check ---` in `Invoke-DocsCommand.ps1` (inside `$script:DocsCommandRow`) | present |
| anchor `# --- 1021: page-metadata ---` in `DocsSchema.psm1` (inside `Get-DocsSchemaName`) | present |
| anchor `# --- 1021: page-check configuration ---` in `DocsProfileCommands.psm1` (inside `Get-DocsInitTemplate`) | present |
| `git merge-base --is-ancestor` of the 1020 merge and HEAD | exit 0 (ancestor) |

Additional 1020 module present: `DocsSchemaWalk.psm1` (the structural walk; imported by `DocsSchema.psm1`), inside the spec allowed import set.

## Contract Requests

| CR | Outcome | Proof (1020 symbol or schema `$defs`) | Fallback applied |
|---|---|---|---|
| CR-1 | accepted | `common.schema.json` `$defs/audience-id` (pattern `^[a-z0-9][a-z0-9-]*$(?![\s\S])`) and `$defs/audience-ids`; `docs-profile.schema.json` types `audiences[].id` as `audience-id` and `documentation_roots[].audience_ids` as `audience-ids` | none (page-metadata uses docs common `audience-id`) |
| CR-2 | not accepted | `Get-DocsSchemaPath` carries no `# --- 1021: page-metadata ---` anchor; its map is an ordered literal ending with `docs-command-envelope` | path row appended as the last `Get-DocsSchemaPath` entry |
| CR-3 | accepted - gate: option A | `Get-DocsComposedSchemaSet` iterates every key of `-SchemaSet` except `common` (no fixed kind list; the set keys come from `Read-DocsSchemaSet` over `Get-DocsSchemaPath`); `Test-DocsArtifactText` resolves `-ArtifactKind` with `$ComposedSchemaSet.Contains($ArtifactKind)` (not against `docs-artifact-kind`). The composed map is the `Schemas` member of the `Get-DocsComposedSchemaSet` result | none; schema gate is `Test-DocsArtifactText -ArtifactKind 'page-metadata'`. (Export status recorded for completeness: `Join-DocsSchemaText`, `Get-DocsSchemaStructuralFinding`, `ConvertFrom-DocsSchemaErrorRecord` are all listed in `Export-ModuleMember` of `DocsSchema.psm1`.) |
| CR-4 | not accepted | `DocsSchemaWalk.psm1` walk subset is `$ref`, `type`, `required`, `properties`, `patternProperties`, `additionalProperties`, `enum`, `const`, `items`, `minItems`, `maxItems`, `allOf`, `if/then/else`, `anyOf`; no `pattern`, `minLength`, `uniqueItems` | `Get-DocsPageConstraintFinding` kept |
| CR-5 | accepted | `Get-DocsContextFileList` (`Invoke-DocsCommand.ps1`) returns ordinal-sorted repository-relative POSIX paths (`GetRelativePath($Root, ...)`) and an empty list when the directory does not exist; `Test-DocsContextFile` uses `[System.IO.File]::Exists`, so `TestFile` is false for a directory | none (absent directory = empty listing, as stated) |
| CR-6 | not a contract request | owner question OQ-A | n/a |
| CR-7 | accepted | `New-DocsStarterProfile` (`DocsProfile.psm1`) sets `required_front_matter = @('owner', 'last_reviewed', 'audience', 'diataxis_mode', 'surface_refs')` | none |
| CR-8 | not accepted | no exported path-or-glob matcher in any 1020 module (no `WildcardPattern` use in `.claude/lib/docs/*.psm1`) | `Test-DocsPagePathMatch` in `DocsPageDiataxis.psm1` |
| CR-9 | accepted | `docs-command-envelope` is a `Get-DocsSchemaName`/`Get-DocsSchemaPath` entry, so it is composed by `Get-DocsComposedSchemaSet`; the named route is `Test-DocsArtifactText -ArtifactKind 'docs-command-envelope'` (1020 spec `## Decisions Later Children Must Honor`); envelope `result` is `{}` (unconstrained per command) | none |
| CR-10 | accepted (1020 form) | `DocsProfileCommands.psm1` private helper `Invoke-DocsContextMember -Member <[scriptblock]> -ArgumentList <object[]>` that runs `& $Member @ArgumentList` on its own `[scriptblock]` parameter; callers pass `$Context.<Member>` | 1021 copies this form (a private `[scriptblock]`-parameter helper in `DocsPageCheck.psm1`); `.InvokeReturnAsIs(...)` fallback not needed |
| CR-11 | not accepted | `New-DocsCommandResult` has no `-Limit` parameter; it calls `Get-DocsOrderedFinding` with its default limit | default bound 100 |

## Init template Source and TestFile

- `init` reads a template `Source` through `Invoke-DocsContextMember -Member $Context.ReadText -ArgumentList @($target.Source)`. `Invoke-DocsInitCommand` first requires `Test-DocsRelativePath` to hold for every row `Source` and `Destination`, and exits 3 with `DOCS_CLI_RUNTIME` otherwise. The `DocsProfileCommands.psm1` help block and 1020 spec `### DocsProfileCommands.psm1` fix the row form as `Source = '.claude/lib/docs/templates/<file>'` (repository-relative string, never built with `$PSScriptRoot`).
- Note for [P4-T5]: the plan task text names a `Join-Path -Path $PSScriptRoot -ChildPath 'templates/page-check/<file>'` `Source`; that value is absolute and would fail the `Test-DocsRelativePath` row check (exit 3). The merged 1020 contract requires the repository-relative literal form. This is outside Phases 0 to 2 and is reported to the orchestrator.
- `TestFile` is false for a directory (`[System.IO.File]::Exists`).

## Context-call form (CR-10)

Context members are invoked through a private helper whose `[scriptblock]` parameter is invoked with `&`, matching `Invoke-DocsContextMember` in `DocsProfileCommands.psm1`.

Result: PASS
