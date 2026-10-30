# docs-coverage-ledger-and-receipt — Spec

- **Issue:** #1023
- **Parent (optional):** #1019 (epic documentation-estate-tooling, wave 1, band C4)
- **Depends on:** #1020 (docs-profile-and-artifact-schemas, including its D3/D5 amendment; planned, not executed)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30
- **Status:** Draft
- **Version:** 0.3 (PowerShell design; new planning cycle under owner decision D1)
- **Research (design source):** `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/research/2026-10-30T22-40-docs-coverage-ledger-and-receipt-powershell-addendum.md`
- **1020 amendment cited:** `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/research/2026-10-30T22-35-docs-profile-amendment-d3-d5-addendum-research.md` (on branch `feature/docs-profile-and-artifact-schemas-1020`)
- **Superseded:** version 0.2 (withdrawn Python design under `packages/docs-runtime`). The earlier
  research `research/2026-10-30T20-59-docs-coverage-ledger-and-receipt-research.md` is kept
  unmodified; its language-independent semantics are carried forward below.

## Overview

A destination repository can inventory its documentable surface, but nothing records whether each
surface element is documented, nothing binds elements to pages, and nothing detects that a page
describes code that has since changed. In one consumer repository a feature epic changed 138 `src/`
files while only 4 of 79 documentation pages were edited, and the gap was measured by hand.

This feature is the correspondence core of the documentation-estate epic: the coverage ledger, the
parity matrix, evidence pins with staleness detection, and the `docs-complete` validation receipt.
It is implemented as PowerShell modules under `.claude/lib/docs/` behind the 1020 entry script
`Invoke-DocsCommand.ps1`, under the epic language rule (pushed-down libs are PowerShell or bash).
Later features depend on its contracts: 900007 wraps the three subcommands in MCP tools, #1034
(docs-enforcement-and-ci) consumes the persisted receipt in a workflow and an opt-in hook, and the
scanner analyzers #1022 and #1033 emit the precision-limit diagnostics this feature records. Those
contracts are stated in `## Contracts Later Children Must Honor` and are normative.

1020 contracts are consumed as written in the 1020 `spec.md` (`## Decisions Later Children Must
Honor`, module and schema sections) as amended for D3 and D5. This specification cites them by
module and function and does not re-specify them.

## Behavior

- `coverage` (read-only): reports totals, undocumented elements, deferred entries, scanner
  precision limits, stale pages and per-dimension parity scores.
- `update-ledger` (the only mutating subcommand): one operation per call over the ledger, the parity
  matrix and the evidence pin collection; dry run by default; `-Write` commits through the single
  write boundary.
- `validate`: modes `profile`, `ledger`, `matrix` and `docs-complete`, each including the checks of
  the modes before it; a required revision; the receipt is always returned in `result` and is
  persisted only with `-WriteReceipt`, which is permitted only with `-Mode docs-complete`.

Ledger dispositions are `documented` (at least one page binding), `excluded` (rationale) and
`deferred` (owner and target). Parity dimensions are `exists`, `accurate`, `example_present`,
`owner_assigned` and `diataxis_mode`. Pin states are `current`, `digest-changed` and
`element-missing`; a page is stale when any of its pins is not `current`. Each ledger entry records
`analysis_method` (`native` or `scanner`). A scanner precision limit (a construct the PowerShell
text scanner reports as a diagnostic instead of an element) is recorded as a `deferred` ledger entry
with an owner and a target (owner decision D3).

## Inputs / Outputs

- Inputs (all through the 1020 command context; no environment variable is read):
  - The docs profile (`-Profile`, default `Get-DocsDefaultProfilePath`,
    `docs/documentation-estate/docs-profile.json`), loaded with `ConvertFrom-DocsProfileText`.
    JSON only.
  - The artifacts named by `artifact_paths`: `inventory_snapshot`, `coverage_ledger`,
    `parity_matrix`, `evidence_pins`, `validation_receipt`; parsed with `ConvertFrom-DocsJsonText`
    and validated with `Test-DocsArtifactText` over the composed schema set
    (`Read-DocsSchemaSet`, `Get-DocsComposedSchemaSet`).
  - The page-path set: the ordinal-sorted union of `Context.ListFile` over each
    `documentation_roots[].path`.
  - `completion_gates.docs_complete.{allow_deferred, max_stale_pages, required_parity_dimensions}`
    and `page_owners[{path_or_glob, owner}]`.
  - The clock: `Context.UtcNow` (must have `Kind` `Utc`).
- Outputs:
  - Standard output: with `-Json`, one envelope; otherwise `ConvertTo-DocsReportText` lines.
  - Standard error: one fixed line on exit 3 only (1020 entry boundary).
  - Files, written only through `Invoke-DocsArtifactWrite` in `DocsLedgerMutation.psm1`: the
    ledger, matrix and pin collection (`update-ledger -Write`) and the receipt
    (`validate -Mode docs-complete -WriteReceipt`). Written text is
    `ConvertTo-DocsJsonText -Value <document> -Indented`; digests and identifiers use
    `ConvertTo-DocsCanonicalJson`.
- Versioning: artifact shapes are the 1020 schemas at `urn:drm-copilot:docs:1.0.0:<name>` as
  amended (ledger `$defs/entry` and snapshot `$defs/element` carry required `analysis_method`;
  `source_sha256` is the declaration-lines digest). The `-Json` envelope validates against
  `schemas/docs/v1/docs-command-envelope.schema.json`. No schema file is created or edited by 1023.

## API / CLI Surface

### Module conventions

Inherited from 1020 `### Module conventions`: advanced functions with `[CmdletBinding()]`; the help
token `imports its siblings with -ErrorAction Stop`; `Set-StrictMode -Version Latest` followed by
`$ErrorActionPreference = 'Stop'`; only literal `Join-Path -Path $PSScriptRoot -ChildPath
'<literal>'` sibling imports. Pure functions take strings and hashtables and touch no filesystem,
clock, process, environment or module-scope mutable state. File and clock access happens only
through the 1020 command context, whose only write function is `Write-DocsFileText` (exposed as
`Context.WriteText`). Command modules never print and never call `exit`. Additional 1023 rules:

- Context members are passed to `[scriptblock]`-typed parameters and invoked as `& $WriteText`,
  never as `& $Context.<Member>` (the existing
  `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` reports a member
  expression in command position as dynamic invocation).
- Pure functions whose verb is state-changing (`New-`) carry the
  `PSUseShouldProcessForStateChangingFunctions` suppression with the justification
  "Pure in-memory factory that changes no system state." (precedent `New-EpicScopeResult`);
  transformations use `Merge-`, `Get-`, `Measure-`, `Test-` or `ConvertTo-`.
- Identifier and path comparisons are ordinal and case-sensitive (`-ceq`, `-cne`,
  `[StringComparison]::Ordinal`); every sort uses `[System.StringComparer]::Ordinal`.
- Scores use integer arithmetic only.

### Modules (`.claude/lib/docs/`)

| Module | Exported functions (pure unless marked) | Imports (1020 unless named) |
|---|---|---|
| `DocsLedger.psm1` | `ConvertTo-DocsSnapshotView`, `Test-DocsPrecisionLimitDiagnostic`, `Get-DocsPrecisionLimitElementId`, `New-DocsLedgerEntry`, `New-DocsPrecisionLimitEntry`, `New-DocsLedgerDocument`, `Get-DocsLedgerEntryCompanionFinding`, `Get-DocsLedgerFinding`, `Merge-DocsLedgerEntry`, `Get-DocsLedgerWithoutEntry`, `Merge-DocsLedgerSnapshotRef` | `DocsJson`, `DocsFinding`, `DocsSurface` |
| `DocsParity.psm1` | `Get-DocsParityDimension`, `Test-DocsPathOrGlobMatch`, `Get-DocsPageOwner`, `New-DocsParityRow`, `New-DocsParityMatrixDocument`, `Get-DocsMatrixFinding`, `Merge-DocsParityDimension`, `Get-DocsMatrixWithoutBinding`, `Merge-DocsMatrixPinRemoval`, `Merge-DocsMatrixRef`, `Get-DocsScoreBasisPoint`, `Measure-DocsParityScore` | `DocsJson`, `DocsFinding`, `DocsSurface` |
| `DocsEvidencePins.psm1` | `Get-DocsPinId`, `New-DocsEvidencePin`, `New-DocsPinCollectionDocument`, `Get-DocsPinFinding`, `Merge-DocsEvidencePin`, `Get-DocsPinSetWithoutPin` | `DocsJson`, `DocsFinding`, `DocsSurface` |
| `DocsStaleness.psm1` | `Get-DocsPinStatus`, `Get-DocsStalePage`, `Get-DocsStalenessFinding` | `DocsFinding`, 1023 `DocsEvidencePins` |
| `DocsReceipt.psm1` | `ConvertTo-DocsTimestampText`, `Get-DocsWriterVersion`, `Get-DocsArtifactPin`, `Get-DocsReceiptId`, `Measure-DocsReceiptCount`, `New-DocsValidationReceipt`, `Get-DocsReceiptGateDecision` (pure apart from the built-in `Test-Json`) | `DocsJson`, `DocsFinding`, `DocsSchema`, `DocsSurface` |
| `DocsValidation.psm1` | `Get-DocsValidationMode`, `Get-DocsValidationInputKind`, `Get-DocsCompletionGateFinding`, `Invoke-DocsValidation` (pure apart from `Test-Json`) | `DocsJson`, `DocsFinding`, `DocsSchema`, `DocsProfile`, 1023 `DocsLedger`, `DocsParity`, `DocsEvidencePins`, `DocsStaleness`, `DocsReceipt` |
| `DocsLedgerMutation.psm1` | `Get-DocsArtifactWritePlan`; `Invoke-DocsArtifactWrite` (not pure: I/O only through its `-ReadBytes`, `-TestFile` and `-WriteText` scriptblock parameters) | `DocsJson`, `DocsFinding`, `DocsSurface` |
| `DocsLedgerCommands.psm1` | `Invoke-DocsCoverageCommand`, `Invoke-DocsUpdateLedgerCommand`, `Invoke-DocsValidateCommand` (I/O through the context); `Read-DocsLedgerInputSet` (I/O through scriptblock parameters); `Test-DocsUpdateLedgerArgument`, `Test-DocsValidateArgument`, `Get-DocsCoverageReport`, `ConvertTo-DocsCoverageReportLine` (pure) | every 1023 module above, `DocsProfile`, `DocsSchema`, `DocsFinding`, `DocsJson` |

No import cycle: `DocsLedgerCommands.psm1` is the only importer of `DocsLedgerMutation.psm1`, which
imports no 1023 module. Pre-approved splits at the 500-line guidance: `DocsLedgerRules.psm1` (rules
from `DocsLedger.psm1`) and `DocsCoverageReport.psm1` (coverage report from
`DocsLedgerCommands.psm1`), each with its own suite, bundle copy and `core.json` line.

Consumed 1020 functions: `ConvertFrom-DocsJsonText`, `ConvertTo-DocsJsonText`,
`ConvertTo-DocsCanonicalJson`, `Get-DocsSha256Hex`, `Get-DocsBytesSha256Hex`, `New-DocsFinding`,
`Get-DocsChildPointer`, `Get-DocsOrderedFinding`, `Test-DocsFindingHasError`,
`New-DocsCommandResult`, `Read-DocsSchemaSet`, `Get-DocsComposedSchemaSet`, `Test-DocsArtifactText`
(artifact kinds plus `docs-command-envelope`), `Get-DocsElementKind`, `Get-DocsAnalysisMethod`,
`Test-DocsRelativePath`, `Test-DocsFullRevision`, `Get-DocsStableId`, `Get-DocsElementId`,
`Test-DocsElementId`, `ConvertFrom-DocsSurfaceElement`, `Get-DocsDefaultProfilePath`,
`ConvertFrom-DocsProfileText`. Consumed 1020 finding codes: `DOCS_JSON_INVALID`,
`DOCS_JSON_DUPLICATE_KEY`, `DOCS_JSON_TOO_DEEP`, the `DOCS_SCHEMA_*` codes of the structural walk
and `DOCS_SCHEMA_INVALID`, `DOCS_PROFILE_*`, `DOCS_ELEMENT_ID_MISMATCH` (surfaced as
`DOCS_SNAPSHOT_ELEMENT_INVALID`), `DOCS_CLI_ARGUMENTS`, `DOCS_CLI_RUNTIME`, `FINDINGS_LIMIT`.

### Function contracts (summary)

- `ConvertTo-DocsSnapshotView -Snapshot <IDictionary> -SnapshotSha256 <string> [-ArtifactPath]`
  returns `@{ Repository; Revision; Sha256; Element; PrecisionLimit; Findings }`: `Element` maps
  `element_id` to each element rebuilt with `ConvertFrom-DocsSurfaceElement` (a rebuild failure is
  `DOCS_SNAPSHOT_ELEMENT_INVALID` at `/elements/<n>`); `PrecisionLimit` maps the precision-limit
  element id (below) to `@{ DiagnosticId; AnalyzerId; Code; Path; ElementKind; ElementId }`.
- `New-DocsLedgerEntry` copies `element_id`, `kind` and `analysis_method` from the current element;
  page bindings are sorted by `page_path` then `anchor` (null first).
- `Get-DocsLedgerFinding` implements the ledger rules in `### Finding codes`;
  `Get-DocsLedgerEntryCompanionFinding` implements the 1020 disposition companion table.
- `Merge-DocsLedgerEntry` replaces or inserts by `element_id` and returns a new ledger with entries
  sorted by `element_id`; inputs are never mutated (same for every `Merge-` and `Get-...Without...`
  function).
- `Test-DocsPathOrGlobMatch -Path -PathOrGlob` implements the epic rule (1024 decision): a value `E`
  covers `P` when `P` equals `E`, when `P` starts with `E` + `/`, or when `P` matches `E` as a
  case-sensitive glob (`*` any run including `/`, `?` one character, `[...]` a class, `[!...]` a
  negated class, no escape character), translated to an anchored .NET regular expression without
  `IgnoreCase` (PowerShell `-like` and `[WildcardPattern]` are not used). `Get-DocsPageOwner
  -PagePath -PageOwner` evaluates `page_owners` in array order; the first match gives the owner.
- `Get-DocsPinId -ElementId -PagePath -Symbol` is `Get-DocsStableId -Prefix 'pin' -Value
  [ordered]@{ element_id; page_path; symbol }`. `New-DocsEvidencePin` copies `source_sha256` from
  the element as an opaque value.
- `Get-DocsPinStatus -Pin -Element` returns `element-missing` when no current element has the pin's
  `element_id`, `digest-changed` when the digests differ (ordinal), otherwise `current`. A revision
  difference never changes the status.
- `Get-DocsStalePage` returns one record per page with at least one non-current pin,
  `{page_path, pins: [{pin_id, element_id, status}]}`, sorted by `page_path` then `pin_id`.
- `ConvertTo-DocsTimestampText -UtcNow <DateTime>` formats `yyyy-MM-dd'T'HH:mm:ss'Z'` with the
  invariant culture and throws when `Kind` is not `Utc` (exit 3, `DOCS_CLI_RUNTIME`).
- `Get-DocsScoreBasisPoint -Pass -Fail -NotAssessed` returns
  `floor(10000 * pass / (pass + fail + not_assessed))`, or `$null` when that denominator is 0.
- `Get-DocsArtifactWritePlan -Document <object[]>`: each input `@{ Path; ArtifactKind; ArtifactId;
  Text; BeforeSha256 }`; returns plans sorted by `Path` (ordinal) with `Sha256` of the UTF-8 text
  bytes and status `planned`, or `skipped` when `Sha256` equals `BeforeSha256`.
- `Invoke-DocsArtifactWrite -Plan -ReadBytes -TestFile -WriteText [-DryRun]`: with `-DryRun` it
  calls no scriptblock. Otherwise, in ascending path order and skipping `skipped` plans: when
  `BeforeSha256` is null, `& $TestFile` must return false, then `& $WriteText <path> <text>
  'create'` (status `created`); otherwise `& $ReadBytes` and `Get-DocsBytesSha256Hex` must equal
  `BeforeSha256`, then `& $WriteText <path> <text> 'overwrite'` (status `updated`). A mismatch, or a
  file present when absence was expected, is status `conflict` and stops the sequence; earlier
  writes are not rolled back. Returns `@{ Write; Failed; WrittenPath }`.

### Command contract (all three subcommands)

| Exit | Meaning |
|---|---|
| 0 | Success or `-Help`; no `error` finding in `findings`. `validate`: receipt `validation_result` `pass`. `update-ledger`: the operation introduces no new `error` finding and, with `-Write`, every planned write committed. `coverage`: report built. |
| 1 | Findings. `validate`: at least one `error` finding (receipt `fail`), or the profile does not load (`result` null). `update-ledger`: the operation would introduce a new `error` finding, or names a target that does not exist (`DOCS_UPDATE_TARGET_INVALID`); nothing is written. `coverage`: snapshot absent (`DOCS_INPUT_UNREADABLE`) or an input fails parse, schema or element rebuild; `result` null. |
| 2 | Usage or input error before any read: exactly one `DOCS_CLI_ARGUMENTS` finding; `result` null. |
| 3 | Internal or I/O error: exactly one `DOCS_CLI_RUNTIME` finding; `result` null; one stderr line. Covers a read failure other than absence, uncomposable schemas, a non-UTC clock, the receipt defect guard, and a commit `conflict` or write failure (the message names the failing path and its status; `related_paths` holds that path and every path already written). |

- `-Json`: one canonical JSON envelope `{command, exit_code, findings, ok, result}`; `command` is the
  subcommand name (`coverage`, `update-ledger`, `validate`); `ok` is true exactly when `exit_code`
  is 0; `findings` in `Get-DocsOrderedFinding` order. Identical inputs, arguments and clock produce
  identical bytes. Every envelope validates through
  `Test-DocsArtifactText -ArtifactKind 'docs-command-envelope'` against
  `schemas/docs/v1/docs-command-envelope.schema.json`.
- Without `-Json`: `ConvertTo-DocsReportText` (finding lines, command lines, summary line
  `<command>: exit=<n> errors=<n> warnings=<n> infos=<n>`).
- Exit codes and the receipt `validation_result` are computed from the unbounded finding set,
  before `Get-DocsOrderedFinding` applies its bound (risk R2, owner question OQ-3).
- Value grammars are checked by `Test-DocsUpdateLedgerArgument` and `Test-DocsValidateArgument`
  before any read: relative paths (`Test-DocsRelativePath`), `-Element` (`Test-DocsElementId`),
  `-Revision` (`Test-DocsFullRevision`), `-ActorId` and `-Owner` (docs `identifier`), `-Limit`
  (docs `identifier` with the prefix `diagnostic-`), `-Page` as `<relative path>[#<anchor>]`, and
  the enumerations listed below. A violation returns exit 2 through `New-DocsCommandResult`.

### `coverage` (read-only)

Options: `-Profile`. Reads the profile, snapshot, ledger, matrix, pin collection and page-path set;
an absent ledger, matrix or pin collection is treated as empty. Never passes `WriteText` anywhere.
On exit 0, `findings` is empty; rule violations are reported by `validate`. `result`:

- `totals`: the receipt `counts` object plus `by_analysis_method` `{native, scanner}` over ledger
  entries matching current elements;
- `undocumented`: `[{element_id, kind, declaration, path}]` sorted by `element_id`;
- `deferred`: `[{element_id, owner, target}]` for element entries, sorted by `element_id`;
- `precision_limits`: `[{element_id, diagnostic_id, analyzer_id, code, path, owner, target,
  recorded}]` sorted by `element_id`; `recorded` is false (and `owner`, `target` null) when no
  ledger entry exists;
- `stale_pages`: `[{page_path, pins: [{pin_id, element_id, status}]}]`;
- `parity`: per dimension `{pass, fail, not_assessed, not_applicable, score_basis_points}`.

### `update-ledger` (the only mutating subcommand)

| Operation | Required | Optional | Documents it may change |
|---|---|---|---|
| `set-disposition` | `-Element` xor `-Limit`; `-Disposition` | `-Page` (multi), `-Rationale`, `-Owner`, `-Target` | ledger; matrix rows and pins of a dropped binding |
| `remove-entry` | `-Element` xor `-Limit` | none | ledger; the element's matrix rows and pins |
| `pin` | `-Element`, one `-Page` without anchor | `-Claim` | pin collection |
| `unpin` | `-Element`, one `-Page` without anchor | none | pin collection; matrix `evidence_pin_ids` |
| `set-dimension` | `-Element`, one `-Page` without anchor, `-Dimension`, `-State` | `-Rationale` | matrix |
| `sync-refs` | none | none | ledger `snapshot_ref` and element-entry `analysis_method`; matrix `snapshot_ref` and `ledger_ref` |

- Every operation requires `-Operation`, `-ActorKind` (`human`, `agent`, `tool`) and `-ActorId`.
  Enumerations: `-Disposition` (`documented`, `excluded`, `deferred`), `-Dimension` (the five parity
  dimensions), `-State` (`pass`, `fail`, `not-assessed`, `not-applicable`).
- Exit 2: an option outside the operation's sets, `-Element` with `-Limit`, `-Limit` with a
  `-Disposition` other than `deferred`, or a repeated `-Page` value.
- Dry run is the default and calls no write scriptblock; `-Write` commits through
  `Invoke-DocsArtifactWrite`. `result` is `{dry_run, preexisting_errors, writes: [{path,
  artifact_kind, artifact_id, sha256, status}]}` sorted by `path`; `status` is one of `planned`,
  `created`, `updated`, `skipped`, `conflict`; `preexisting_errors` counts `error` findings present
  before the operation.
- Newly-introduced rule: each changed document is validated with `Test-DocsArtifactText` and the
  1023 rules; the operation fails (exit 1, nothing written) when the resulting `error` findings
  contain a finding absent before the operation, compared on every field except `pointer`. On exit 1
  `findings` holds those new errors. Pre-existing errors do not block an operation and are not
  emitted in `findings` (they are reported by `validate`), so an exit-0 envelope carries only
  `warning` and `info` findings introduced by the operation.
- Semantics: `set-disposition` replaces the whole entry (kind and `analysis_method` from the current
  element) and removes matrix rows and pins for a dropped binding; `remove-entry` removes the entry
  and the element's rows and pins; `pin` re-pins the same element and page under the same `pin_id`
  (revision from the snapshot, possibly null; `pinned_at` from the clock); `unpin` removes the pin
  and its id from every `evidence_pin_ids`; `set-dimension` creates the row when absent (other
  dimensions `not-assessed`) and derives that dimension's `evidence_pin_ids` from the existing pins
  for the element and page; `sync-refs` sets `snapshot_ref` to the snapshot bytes digest, refreshes
  each element entry's `analysis_method` from the current element, and sets the matrix `ledger_ref`
  to the digest of the ledger text as it will be written. A created document carries the 1020
  artifact header with `id` = `Get-DocsStableId -Prefix <artifact_kind> -Value @{ repository = <profile
  repository id> }`; an existing document keeps its `id`.
- Precision-limit operations: `set-disposition -Limit <diagnostic id> -Disposition deferred -Owner
  -Target [-Rationale]` writes the entry built by `New-DocsPrecisionLimitEntry` for a precision-limit
  diagnostic present in the current snapshot; `remove-entry -Limit <diagnostic id>` removes the entry
  whose marker names that diagnostic. Either target absent is `DOCS_UPDATE_TARGET_INVALID` (exit 1).
  `pin`, `unpin` and `set-dimension` naming a precision-limit element id are
  `DOCS_UPDATE_TARGET_INVALID`.

### `validate`

- Options: `-Mode` (required: `profile`, `ledger`, `matrix`, `docs-complete`), `-Revision`
  (required in every mode), `-WriteReceipt` (switch; any mode other than `docs-complete` with
  `-WriteReceipt` is exit 2), `-Profile`.

| Mode | Inputs | Checks (cumulative) |
|---|---|---|
| `profile` | profile | `ConvertFrom-DocsProfileText` findings |
| `ledger` | plus snapshot, ledger | schema validation; snapshot view; ledger rules including precision-limit rules; `DOCS_REVISION_MISMATCH` |
| `matrix` | plus matrix, pin collection, page-path set | schema validation; matrix rules; pin consistency; `DOCS_PAGE_STALE` as `warning` |
| `docs-complete` | as `matrix` | gate from `completion_gates.docs_complete`: `DOCS_SNAPSHOT_UNPINNED`, `DOCS_DEFERRED_NOT_ALLOWED`, `DOCS_PARITY_REQUIRED_DIMENSION`, `DOCS_PAGE_MISSING`, `DOCS_PAGE_STALE` severity per `max_stale_pages` |

- `result` is the receipt on exit 0 and on exit 1 with a loaded profile; otherwise null.
- `DOCS_REVISION_MISMATCH`: the snapshot revision is non-null and differs from `-Revision`.
  `DOCS_SNAPSHOT_UNPINNED`: in `docs-complete`, the snapshot revision is null; validation fails
  closed (D5).
- Persistence: without `-WriteReceipt`, no write scriptblock is passed in any mode. With
  `-Mode docs-complete -WriteReceipt`, the receipt (pass or fail) is written to
  `artifact_paths.validation_receipt` through `Invoke-DocsArtifactWrite` (create when absent,
  digest-checked overwrite when present); only that artifact kind is planned.

### Receipt (`docs-validation-receipt`)

| Field | Value |
|---|---|
| header | `$schema` and `artifact_kind` per 1020; `schema_version` `1.0.0`; `extensions` empty object |
| `id` | `Get-DocsReceiptId`: `Get-DocsStableId -Prefix 'docs-validation-receipt' -Value [ordered]@{ inputs; mode; repository; revision; validation_result }`; `issued_at`, `counts`, `findings` and `writer` are excluded, so the identifier does not depend on the issue time |
| `mode`, `repository`, `revision` | the `-Mode` value, profile `repository.id`, the `-Revision` value (never null) |
| `inputs` | one `artifact-pin` per artifact read (`sha256` = `Get-DocsBytesSha256Hex` of the raw bytes), sorted by `artifact_kind` then `path`; an absent artifact is not pinned |
| `counts` | `elements_total`, `undocumented`, `stale_pages`; `by_disposition` over entries matching current elements (precision-limit entries excluded, OQ-5); `by_kind` over snapshot elements; zeros where the mode reads no such input |
| `validation_result` | `fail` when the unbounded finding set has an `error` finding, otherwise `pass` |
| `findings` | the ordered finding set (bound per OQ-3) |
| `issued_at` | `ConvertTo-DocsTimestampText` of `Context.UtcNow` |
| `writer` | `{tool: "drm-copilot-docs", version: Get-DocsWriterVersion}` (`1.0.0`) |

Every built receipt is validated with `Test-DocsArtifactText -ArtifactKind
'docs-validation-receipt'`; a failure is a defect guard (exit 3, `DOCS_CLI_RUNTIME`).

`Get-DocsReceiptGateDecision -ReceiptText <string> -HeadRevision <string> -ComposedSchemaSet
<IDictionary>` returns `@{ Allow; Reason; ReceiptId }` with reasons in fixed precedence:
`receipt-invalid` (parse or schema finding), `mode-not-docs-complete`, `result-fail`,
`revision-mismatch` (ordinal comparison), else `Allow` true with `Reason` `pass`. An absent receipt
file is the caller's `receipt-missing`.

### Scanner precision limits (D3)

A precision-limit diagnostic is a snapshot `diagnostics[]` item that satisfies all of:

1. its `extensions` contains the key `docs.precision-limit` whose value is an object with
   `element_kind` set to one of the element kinds;
2. its `path` is a non-null relative path;
3. its `analyzer_id` names a snapshot `analyzers[]` item whose `analysis_method` is `scanner`.

A diagnostic with the key but failing rule 1 (value), 2 or 3 yields `DOCS_SNAPSHOT_LIMIT_INVALID`
(error, `ledger` mode and above). Diagnostics without the key are not read by 1023.

Precision-limit element id (`Get-DocsPrecisionLimitElementId`): `Get-DocsElementId -Kind
<element_kind> -Path <diagnostic path> -Declaration <diagnostic id>`, that is `<kind>-<sha256>` over
canonical `{declaration, kind, path}` with the diagnostic identity as the declaration. The id
satisfies the `element-id` grammar. Because the diagnostic `id` is `Get-DocsStableId -Prefix
'diagnostic' -Value @{ analyzer; code; path }` (1020 `New-DocsDiagnostic`), one entry covers every
construct with that analyzer and code in that file. A precision-limit element id equal to a
snapshot element id is `DOCS_SNAPSHOT_LIMIT_INVALID`.

The ledger entry (`New-DocsPrecisionLimitEntry`) uses the existing closed `$defs/entry` shape:
`element_id` (the precision-limit element id), `kind` (`element_kind`), `analysis_method`
`scanner`, `disposition` `deferred`, `page_bindings` empty, `rationale` (text or null), `owner` and
`target` (required by the 1020 companion rules), `updated_by`, and `extensions` holding
`docs.precision-limit` = `{analyzer_id, code, diagnostic_id}`. The `extensions` definition copied
into docs common from `schemas/discovery/v2/common.schema.json` admits this marker: the key matches
`^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)+$` and the value is a `json-value` object. Its `description`
annotation ("never merged into core IDs, claims, gates, references or dimensions") is the subject of
owner question OQ-2.

`docs-complete` treats precision-limit entries exactly as deferred entries:
`completion_gates.docs_complete.allow_deferred` true passes them and lists them in `coverage`;
false yields one `DOCS_DEFERRED_NOT_ALLOWED` per entry (risk R6).

### Finding codes

| Code | Severity | Owner function | Condition |
|---|---|---|---|
| 1020 `DOCS_JSON_*`, `DOCS_SCHEMA_*`, `DOCS_PROFILE_*` | error | 1020 | Parse, schema and profile findings |
| `DOCS_INPUT_UNREADABLE` | error | `Invoke-DocsValidation`, `Invoke-DocsCoverageCommand` | An artifact the mode needs is absent |
| `DOCS_SNAPSHOT_ELEMENT_INVALID` | error | `ConvertTo-DocsSnapshotView` | Element rebuild fails |
| `DOCS_SNAPSHOT_LIMIT_INVALID` | error | `ConvertTo-DocsSnapshotView` | Malformed precision-limit marker, null path, non-scanner analyzer, or id collision |
| `DOCS_LEDGER_MISSING_DISPOSITION` | error | `Get-DocsLedgerFinding` | Element without entry; message names kind, declaration and element id; `related_ids` the element id, `related_paths` its path |
| `DOCS_LEDGER_DUPLICATE_ENTRY`, `DOCS_LEDGER_ORPHAN_ENTRY`, `DOCS_LEDGER_KIND_MISMATCH` | error | `Get-DocsLedgerFinding` | Two entries for one id; entry for an id that is neither a current element nor a current precision limit and carries no marker; entry `kind` differs |
| `DOCS_LEDGER_BINDING_REQUIRED`, `DOCS_LEDGER_RATIONALE_REQUIRED`, `DOCS_LEDGER_OWNER_REQUIRED`, `DOCS_LEDGER_TARGET_REQUIRED` | error | `Get-DocsLedgerEntryCompanionFinding` | Companion rules |
| `DOCS_LEDGER_SNAPSHOT_REF` | warning | `Get-DocsLedgerFinding` | `snapshot_ref.sha256` differs from the snapshot bytes digest |
| `DOCS_LEDGER_ANALYSIS_METHOD_CHANGED` | warning | `Get-DocsLedgerFinding` | Element entry `analysis_method` differs from the current element (not a coverage or staleness event) |
| `DOCS_LEDGER_LIMIT_UNRECORDED` | error | `Get-DocsLedgerFinding` | Precision-limit diagnostic without an entry; message names analyzer, code, path, diagnostic id and element id |
| `DOCS_LEDGER_LIMIT_MISMATCH` | error | `Get-DocsLedgerFinding` | Entry for a precision-limit id that is not `deferred`, not `scanner`, lacks the marker, or whose marker differs from the diagnostic |
| `DOCS_LEDGER_LIMIT_RESOLVED` | warning | `Get-DocsLedgerFinding` | Entry with a marker whose diagnostic is absent from the snapshot |
| `DOCS_MATRIX_LEDGER_REF` | warning | `Get-DocsMatrixFinding` | `ledger_ref.sha256` differs |
| `DOCS_MATRIX_UNBOUND_ROW`, `DOCS_MATRIX_ROW_MISSING`, `DOCS_MATRIX_DUPLICATE_ROW`, `DOCS_MATRIX_PIN_UNKNOWN`, `DOCS_MATRIX_ACCURACY_UNPINNED`, `DOCS_MATRIX_EXISTS_INCONSISTENT`, `DOCS_MATRIX_OWNER_INCONSISTENT` | error | `Get-DocsMatrixFinding` | Row not bound by a documented entry; documented binding without row; duplicate row; unknown or foreign pin id; `accurate` `pass` without pin; `exists` `pass` for a page outside the page-path set; `owner_assigned` `pass` with no `Get-DocsPageOwner` match |
| `DOCS_PIN_INCONSISTENT` | error | `Get-DocsPinFinding` | Pin identity fields do not reproduce `element_id`, `pin_id` differs from `Get-DocsPinId`, or duplicate `pin_id` |
| `DOCS_PAGE_STALE` | warning in `matrix`; in `docs-complete` error when stale pages exceed `max_stale_pages`, otherwise warning | `Get-DocsStalenessFinding` | One per stale page; message names the page path and, per non-current pin, the declaration, element id and status |
| `DOCS_PAGE_MISSING`, `DOCS_DEFERRED_NOT_ALLOWED`, `DOCS_PARITY_REQUIRED_DIMENSION`, `DOCS_SNAPSHOT_UNPINNED` | error | `Get-DocsCompletionGateFinding` | Bound page outside the page-path set; deferred entry with `allow_deferred` false; required dimension `fail` or `not-assessed`; null snapshot revision |
| `DOCS_REVISION_MISMATCH` | error | `Invoke-DocsValidation` | Non-null snapshot revision differs from `-Revision` |
| `DOCS_UPDATE_TARGET_INVALID` | error | `Invoke-DocsUpdateLedgerCommand` | Named entry, binding, pin, element or precision limit absent |
| `DOCS_CLI_ARGUMENTS` | error (exit 2) | 1020 parser, `Test-DocsUpdateLedgerArgument`, `Test-DocsValidateArgument` | Usage error |
| `DOCS_CLI_RUNTIME` | error (exit 3) | 1020 entry boundary, `DocsLedgerCommands.psm1` | Internal or I/O error, including commit conflict and the receipt defect guard |

### Dispatch rows (`Invoke-DocsCommand.ps1`)

Inserted directly under the existing anchor `# --- 1023: coverage, update-ledger, validate ---` in
the 1020 row form; no other line of the entry script changes, and the bundle copy receives the same
edit:

```powershell
    # --- 1023: coverage, update-ledger, validate ---
    [pscustomobject]@{ Name = 'coverage'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerCommands.psm1'); Function = 'Invoke-DocsCoverageCommand'; Option = @{ Profile = 'value' } }
    [pscustomobject]@{ Name = 'update-ledger'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerCommands.psm1'); Function = 'Invoke-DocsUpdateLedgerCommand'; Option = @{ Profile = 'value'; Operation = 'value'; Element = 'value'; Limit = 'value'; Disposition = 'value'; Page = 'multi'; Rationale = 'value'; Owner = 'value'; Target = 'value'; Dimension = 'value'; State = 'value'; Claim = 'value'; ActorKind = 'value'; ActorId = 'value'; Write = 'switch' } }
    [pscustomobject]@{ Name = 'validate'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerCommands.psm1'); Function = 'Invoke-DocsValidateCommand'; Option = @{ Profile = 'value'; Mode = 'value'; Revision = 'value'; WriteReceipt = 'switch' } }
```

Each row passes `Test-DocsCommandTable`. The literal join lets the existing dependency-closure test
see `DocsLedgerCommands.psm1`.

## Data & State

- Ledger completeness is exact-once accounting over snapshot elements and precision-limit
  diagnostics: each has exactly one entry.
- Element identity is `Get-DocsElementId`; a pin is self-consistent when
  `Get-DocsElementId -Kind element_kind -Path source_path -Declaration symbol` equals its
  `element_id`. `analysis_method` does not participate in any identifier.
- Ordering is deterministic and ordinal: entries and elements by `element_id`, rows by `element_id`
  then `page_path`, pins by `pin_id`, findings by `Get-DocsOrderedFinding`, receipt inputs by
  `artifact_kind` then `path`, plans by `path`.
- Staleness is digest-based only (opaque comparison of `source_sha256`); a `current` pin proves only
  that the pinned declaration lines are unchanged. Prose accuracy is the `accurate` dimension.
- Persistence: ledger, matrix and pin collection at their `artifact_paths`, written only by
  `update-ledger -Write`; receipt at `artifact_paths.validation_receipt`, written only by
  `validate -Mode docs-complete -WriteReceipt`; both through `Invoke-DocsArtifactWrite`.
- No module-scope cache; schemas are read and composed once per invocation. No migration; absent
  documents are created on first write. Framework code contains no consumer identifier.

## Contracts Later Children Must Honor

### 900007 (docs-mcp-tools; TypeScript wrappers)

- Invocation: `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command <name> -Json
  <options>` with the workspace root as working directory; the wrapper parses the envelope and
  returns `exit_code`, `findings` and `result` unchanged; no logic beyond argument mapping.
- `run_docs_coverage` maps to `-Command coverage -Json [-Profile <p>]`; read-only.
- `update_docs_ledger` maps to `-Command update-ledger -Json -Operation <op> -ActorKind <k>
  -ActorId <id> [-Element <id> | -Limit <diagnostic id>] [-Disposition <d>] [-Page <p> ...]
  [-Rationale <t>] [-Owner <id>] [-Target <t>] [-Dimension <d>] [-State <s>] [-Claim <t>]
  [-Write]`; the only mutating tool.
- `validate_docs_artifacts` maps to `-Command validate -Json -Mode <m> -Revision <rev>
  [-Profile <p>]` and never passes `-WriteReceipt`, so it is read-only in every mode.
- Pre-process input validation mirrors the grammars and enumerations of `### Command contract`,
  `### update-ledger` and `### validate`. Jest tests may validate captured envelopes against
  `schemas/docs/v1/docs-command-envelope.schema.json`.

### #1034 (docs-enforcement-and-ci; workflow and opt-in hook)

- Workflow command: `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command validate
  -Mode docs-complete -Revision <revision> -WriteReceipt -Json`; exit 0 means `pass`, exit 1 means
  `fail` (the receipt is still persisted when the profile loads).
- Receipt path: the profile (default `docs/documentation-estate/docs-profile.json`, read through
  `ConvertFrom-DocsProfileText`) field `artifact_paths.validation_receipt`.
- Decision: the hook imports `DocsReceipt.psm1` and `DocsSchema.psm1` with literal joins, composes
  the schema set, and calls `Get-DocsReceiptGateDecision -ReceiptText -HeadRevision
  -ComposedSchemaSet`. It allows only when `Allow` is true. Fields read: `artifact_kind`, `mode`,
  `validation_result`, `revision`, `id`.
- Revision pin: `revision` compared ordinally with the revision the hook supplies; which revision
  that is for a receipt committed to the branch is owner question OQ-4.
- Deny reasons (deny text names one): `receipt-missing` (file absent; decided by the hook),
  `receipt-invalid`, `mode-not-docs-complete`, `result-fail`, `revision-mismatch`.

### #1022 and #1033 (PowerShell scanners) for precision-limit diagnostics

For each construct the scanner cannot classify within its precision limit, the scanner emits a
docs `diagnostic` (1020 `New-DocsDiagnostic`) with:

- `analyzer_id` equal to its registered identifier, whose snapshot `analyzers[]` item carries
  `analysis_method: scanner`;
- `path` the relative path of the input file (never null);
- `code` a stable code per construct class (the scanner's choice);
- `extensions` containing `"docs.precision-limit": {"element_kind": "<element kind>"}`, where the
  kind is the element kind the scanner would have emitted had it classified the construct.

Diagnostics for other conditions (oversize or undecodable input, environment files) do not carry
the key. #1031 (Python-native analyzer) emits elements, not precision-limit diagnostics; when it
classifies a construct, the corresponding entry is reported as `DOCS_LEDGER_LIMIT_RESOLVED`.

### #1024 (docs-reference-generator)

Path matching for `path_or_glob` uses `Test-DocsPathOrGlobMatch` and `Get-DocsPageOwner` from
`DocsParity.psm1` unless OQ-1 moves them into 1020.

## Artifact Classification

Rules: R1 = epic language rule clause (1) (pushed-down skills, helpers, hooks and libs are PowerShell
or bash); D = epic `### Artifact classes for this epic` (schema/config/data, test and documentation
rows). "Avoid new Python" applies to every row. B =
`extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`.

| File | Change | Class | Language | Permitting rule |
|---|---|---|---|---|
| `.claude/lib/docs/DocsLedger.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsParity.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsEvidencePins.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsStaleness.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReceipt.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsValidation.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsLedgerMutation.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsLedgerCommands.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | edit (three rows under the 1023 anchor) | pushed-down helper/lib (entry) | PowerShell | R1 |
| B`DocsLedger.psm1`, B`DocsParity.psm1`, B`DocsEvidencePins.psm1`, B`DocsStaleness.psm1`, B`DocsReceipt.psm1`, B`DocsValidation.psm1`, B`DocsLedgerMutation.psm1`, B`DocsLedgerCommands.psm1` | create (byte-identical) | pushed-down helper/lib (mirror) | PowerShell | R1 |
| B`Invoke-DocsCommand.ps1` | edit (same three rows) | pushed-down helper/lib (mirror) | PowerShell | R1 |
| `.claude/lib/docs/DocsLedgerRules.psm1`, `.claude/lib/docs/DocsCoverageReport.psm1` and their B copies | create only if the pre-approved split is used | pushed-down helper/lib | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | edit (one `paths` line per new `.claude/lib/docs/` file) | schema/config/data | JSON | D |
| `tests/scripts/claude-lib/docs/DocsLedger.Tests.ps1`, `DocsParity.Tests.ps1`, `DocsEvidencePins.Tests.ps1`, `DocsStaleness.Tests.ps1`, `DocsReceipt.Tests.ps1`, `DocsValidation.Tests.ps1`, `DocsLedgerMutation.Tests.ps1`, `DocsLedgerCommands.Tests.ps1`, `DocsWriteBoundary.Tests.ps1`, `DocsCompleteIntegration.Tests.ps1`, property suites, `DocsLedger.TestSupport.psm1` | create | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/**` | create / edit | documentation | Markdown | D |

No hook, skill, agent, MCP tool, extension command, schema, Python or TypeScript file is created or
edited by 1023, and `quality-tiers.yml` is not edited (1020 classifies `.claude/lib/docs` as T3).
Every artifact follows the language rule; no language owner question arises.

## Owner Questions

None is decided beyond its provisional default.

1. **OQ-1 - Ownership of path matching.** `Test-DocsPathOrGlobMatch` and `Get-DocsPageOwner`
   implement the epic rule shared by 1023 and 1024. Provisional default: 1023 owns them in
   `DocsParity.psm1`, and 1024 imports `DocsParity.psm1` (a 1024-on-1023 dependency within the
   existing wave order). Alternative: move both into a 1020 module (a further 1020 amendment) so that
   1024 does not import a 1023 module.
2. **OQ-2 - Precision-limit marker in `extensions`.** The docs common `extensions` definition admits
   the `docs.precision-limit` key structurally, but its `description` annotation states that
   namespaced data is never merged into core identifiers or gates. This design derives the
   precision-limit element id from the marker's `element_kind` and uses the marker to identify
   diagnostics for the completeness rule. Provisional default: proceed (the annotation is not a
   validation keyword, and the 1020 amendment states no further schema change is needed for D3).
   Alternative: a 1020 amendment adds core diagnostic fields (for example `element_kind` and a
   precision-limit flag).
3. **OQ-3 - `FINDINGS_LIMIT` severity (1020 contract).** 1020 `Get-DocsOrderedFinding` appends a
   `FINDINGS_LIMIT` finding with severity `error` when more than 100 findings exist. A passing
   validation with more than 100 warnings (for example many `DOCS_PAGE_STALE` warnings under
   `max_stale_pages`) would then place an `error` finding into a `pass` receipt and an exit-0
   envelope, both of which the 1020 schemas reject. 1023 handling: exit code and
   `validation_result` are computed from the unbounded set. Provisional default: 1020 gives
   `FINDINGS_LIMIT` the highest severity among the dropped findings; until then, 1023 calls
   `Get-DocsOrderedFinding -Limit` with the finding count for the receipt `findings` (no truncation;
   the receipt schema sets no `maxItems`), and the exit-0 envelope case remains a known defect.
4. **OQ-4 - Committed receipt versus head revision (#1034 contract).** A receipt committed to the
   branch changes the head revision it pins, so a hook comparing `revision` with the head after the
   receipt commit always denies. Options: (a) the workflow publishes the receipt as a CI artifact and
   does not commit it; (b) the hook supplies the parent revision when the head commit changes only
   the receipt path; (c) `revision` names the last revision whose surface the receipt covers, and the
   hook accepts descendants that change no source root. 1023 is neutral: `Get-DocsReceiptGateDecision`
   compares with whatever `-HeadRevision` the caller supplies. Provisional default: (a).
5. **OQ-5 - Receipt counts for precision limits.** Provisional default: receipt `counts` are
   unchanged and exclude precision-limit entries; `by_analysis_method` and precision-limit totals
   appear only in the `coverage` result. Alternative: a 1020 receipt-schema amendment adds them.

## Risks

- R1 - 1020 dependency: 1023 relies on the amended 1020 contracts (`analysis_method`, the
  declaration-lines `source_sha256`, the envelope schema and `Test-DocsArtifactText -ArtifactKind
  'docs-command-envelope'`). Execution starts only after 1020 (with its amendment) merges into
  `epic/documentation-estate-tooling-integration`; the plan's first phase re-reads the merged
  modules and schemas and records any renamed symbol before code is written.
- R2 - Finding truncation (OQ-3): with the current 1020 bound, an exit-0 result with more than 100
  non-error findings produces an envelope the schema rejects.
- R3 - Check-then-write window: between the digest re-check and `WriteText 'overwrite'` another
  writer can change the file, and whether `Write-DocsFileText` mode `create` fails on an existing
  file is not yet verified. Accepted for a local single-writer command; 1023 checks `TestFile` before
  `create`.
- R4 - Culture and case defaults: PowerShell comparison and sort defaults are case-insensitive;
  property tests use mixed-case inputs to detect a non-ordinal comparison.
- R5 - Committed receipt and head revision (OQ-4).
- R6 - Deferred gate for precision limits: precision-limit entries follow
  `allow_deferred`. A repository whose scanners report precision limits passes `docs-complete` only
  with `allow_deferred` true, until a native analyzer (#1031 for Python; C# and TypeScript native
  analyzers are later, optional children) classifies those constructs. This is a documented
  consequence of D3, not an open question.
- R7 - Scanner adoption: if #1022 or #1033 omit the `docs.precision-limit` key, unclassified
  constructs are invisible to the ledger and `docs-complete` can pass without recording them. The
  marker is a binding contract on both scanners (see `## Contracts Later Children Must Honor`).
- R8 - CI-only behavior: `Test-Json` evaluation of the composed schemas depends on the
  `windows-latest` runner's PowerShell; tests assert codes, pointers and booleans, never message
  text.
- R9 - File size: `DocsLedgerCommands.psm1`, `DocsValidation.psm1` and `DocsLedger.psm1` are the
  largest candidates; the pre-approved splits apply at the 500-line guidance.
- R10 - Batch budget: the production files and bundle copies exceed the direct-mode cap; execution
  runs in the item worktree under a non-terminal exempt-route checkpoint, never in an isolated
  executor worktree.

## Non-Functional Requirements

- PowerShell 7 built-ins only (epic A8); no new module dependency; `ConvertFrom-Json` is not used
  for artifacts.
- Domain-neutral code; no consumer identifier in source, tests or fixtures.
- Tests create no temporary files and use no API forbidden by
  `.claude/hooks/check-powershell-test-purity.ps1`; every suite uses in-memory contexts and removes
  every `Docs*` module in `AfterAll`.
- One property test per pure function, generated with a seeded `[System.Random]` (fixed seed list,
  seed included in every `-Because` message) or exhaustive enumeration; no new module.
- Pester line coverage >= 85% for each new production file; Pester measures no branch coverage, so
  no branch gate applies; no production file is excluded from coverage.
- File size: guidance 500 lines, advisory 700, hard block above 800.

## Implementation Strategy

- Create the eight modules listed in `### Modules`, their byte-identical bundle copies, and the
  `core.json` lines; insert the three dispatch rows in the entry script and its bundle copy.
- Tests under `tests/scripts/claude-lib/docs/` (layout mirrors `tests/scripts/claude-lib/mermaid/`):
  one suite per module, `DocsWriteBoundary.Tests.ps1`, `DocsCompleteIntegration.Tests.ps1`, the
  property suites, and `DocsLedger.TestSupport.psm1` (in-memory context with a path-to-bytes
  hashtable, recording `WriteText`, `ReadBytes`, `TestFile`, `ListFile`, and a fixed `UtcNow` of
  `Kind` `Utc`). Schemas come from the committed runtime copies through `Read-DocsSchemaSet`.
- Pester suites with coverage run on `windows-latest` in the `poshqc / PowerShell QC shard 1`,
  `shard 2` and `shard 3` jobs, aggregated by the required check `poshqc / PowerShell QC`; format
  and PSScriptAnalyzer run in `poshqc / PowerShell QC static`. The existing Python push-down contract
  tests (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`,
  `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`) run in
  `quality-checks7 / Code Quality & Tests`; they are called, not edited.
- Evidence under `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/evidence/<kind>/`
  (coverage figures under `evidence/qa-gates/`, isolation runs under `evidence/regression-testing/`).
- No change to `config/poshqc-coverage.json`, `config/poshqc-scan.json`, `quality-tiers.yml`, any
  schema, any 1020 module other than the three dispatch rows, or any discovery file.

## Acceptance Criteria

Unless stated otherwise, each Pester criterion is verified by the named suite under
`tests/scripts/claude-lib/docs/`, run with coverage on `windows-latest` in `poshqc / PowerShell QC`
(shards aggregated by that required check).

- [ ] A ledger missing a disposition for any inventoried element yields `DOCS_LEDGER_MISSING_DISPOSITION` (error) whose message names the element's kind, declaration and element id; an `excluded` entry without rationale yields `DOCS_LEDGER_RATIONALE_REQUIRED`; a `deferred` entry without owner or without target yields `DOCS_LEDGER_OWNER_REQUIRED` or `DOCS_LEDGER_TARGET_REQUIRED` (`DocsLedger.Tests.ps1`).
- [ ] `Get-DocsLedgerFinding` reports `DOCS_LEDGER_DUPLICATE_ENTRY`, `DOCS_LEDGER_ORPHAN_ENTRY`, `DOCS_LEDGER_KIND_MISMATCH` and `DOCS_LEDGER_SNAPSHOT_REF` for fixtures exhibiting each condition, and `DOCS_LEDGER_ANALYSIS_METHOD_CHANGED` (warning) when an element entry's `analysis_method` differs from the current element (`DocsLedger.Tests.ps1`).
- [ ] Every ledger entry written by `update-ledger` carries `analysis_method` copied from the current snapshot element (`native` or `scanner`), and `sync-refs` refreshes it after the element's method changes (`DocsLedgerCommands.Tests.ps1`).
- [ ] For a snapshot containing a precision-limit diagnostic (marker `docs.precision-limit` with `element_kind`, non-null `path`, scanner analyzer), `validate -Mode ledger` reports `DOCS_LEDGER_LIMIT_UNRECORDED` naming the analyzer, code, path, diagnostic id and element id; after `update-ledger -Operation set-disposition -Limit <diagnostic id> -Disposition deferred -Owner <id> -Target <text> -Write`, the ledger holds one `deferred` entry with `analysis_method` `scanner`, `element_id` equal to `Get-DocsElementId -Kind <element_kind> -Path <path> -Declaration <diagnostic id>`, and `extensions` `docs.precision-limit` holding `analyzer_id`, `code` and `diagnostic_id`, and the finding is gone (`DocsLedger.Tests.ps1`, `DocsLedgerCommands.Tests.ps1`).
- [ ] `DOCS_SNAPSHOT_LIMIT_INVALID` is reported for a marker whose `element_kind` is not an element kind, a marked diagnostic with null `path`, a marked diagnostic from a `native` analyzer, and a precision-limit element id equal to a snapshot element id; `DOCS_LEDGER_LIMIT_MISMATCH` is reported for a precision-limit entry that is not `deferred` or whose marker differs; `DOCS_LEDGER_LIMIT_RESOLVED` (warning) is reported for a marked entry whose diagnostic is absent (`DocsLedger.Tests.ps1`).
- [ ] In `docs-complete`, a precision-limit entry passes when `allow_deferred` is true and yields `DOCS_DEFERRED_NOT_ALLOWED` when it is false, exactly as an element `deferred` entry does (`DocsValidation.Tests.ps1`).
- [ ] `Get-DocsPinStatus` returns `digest-changed` when the pin's `source_sha256` differs from the current element's, `element-missing` when no current element has the pin's `element_id`, and `current` when the digests are equal; a revision difference alone never changes the status, and a page is stale exactly when at least one of its pins is not `current` (`DocsStaleness.Tests.ps1`).
- [ ] `validate -Mode docs-complete` exits 0 with a `pass` receipt on a complete in-memory fixture; on an in-memory fixture with one undocumented element and one stale page it exits 1, returns a `fail` receipt, and its findings name the undocumented element (declaration and element id) and the stale page path; after the missing entry is added and the stale pin re-pinned through `update-ledger`, it exits 0 with a `pass` receipt (`DocsCompleteIntegration.Tests.ps1`).
- [ ] Every receipt returned by `validate` in each of the modes `profile`, `ledger`, `matrix` and `docs-complete`, on pass and on fail, produces no finding from `Test-DocsArtifactText -ArtifactKind 'docs-validation-receipt'`, and its `revision` equals the `-Revision` argument (`DocsValidation.Tests.ps1`).
- [ ] The receipt `id` equals `Get-DocsStableId -Prefix 'docs-validation-receipt'` over `inputs`, `mode`, `repository`, `revision` and `validation_result`; a property test shows it is unchanged when only `issued_at`, `counts` or `findings` differ and changes when any of those five members differs (`DocsReceipt.Tests.ps1`).
- [ ] The receipt `inputs` hold one `artifact-pin` per artifact read, with `sha256` equal to `Get-DocsBytesSha256Hex` of the raw bytes, sorted by `artifact_kind` then `path`, and no pin for an absent artifact (`DocsReceipt.Tests.ps1`).
- [ ] `validate -Mode docs-complete` with a snapshot whose `revision` is null exits 1 with `DOCS_SNAPSHOT_UNPINNED`; with a non-null snapshot revision different from `-Revision` it reports `DOCS_REVISION_MISMATCH` (`DocsValidation.Tests.ps1`).
- [ ] In `docs-complete`, a required parity dimension in state `fail` or `not-assessed` yields `DOCS_PARITY_REQUIRED_DIMENSION`, a bound page outside the page-path set yields `DOCS_PAGE_MISSING`, and `DOCS_PAGE_STALE` is `error` when the stale-page count exceeds `max_stale_pages` and `warning` otherwise; in `matrix` mode `DOCS_PAGE_STALE` is always `warning` (`DocsValidation.Tests.ps1`).
- [ ] `Get-DocsMatrixFinding` reports each of `DOCS_MATRIX_UNBOUND_ROW`, `DOCS_MATRIX_ROW_MISSING`, `DOCS_MATRIX_DUPLICATE_ROW`, `DOCS_MATRIX_PIN_UNKNOWN`, `DOCS_MATRIX_ACCURACY_UNPINNED`, `DOCS_MATRIX_EXISTS_INCONSISTENT`, `DOCS_MATRIX_OWNER_INCONSISTENT` and `DOCS_MATRIX_LEDGER_REF` for a fixture exhibiting its condition, and `Get-DocsPinFinding` reports `DOCS_PIN_INCONSISTENT` for a tampered pin identity, a wrong `pin_id` and a duplicate `pin_id` (`DocsParity.Tests.ps1`, `DocsEvidencePins.Tests.ps1`).
- [ ] `Test-DocsPathOrGlobMatch` agrees with an enumerated table covering exact match, prefix plus `/`, `*` across `/`, `?`, `[...]`, `[!...]` and case difference (no match), and `Get-DocsPageOwner` returns the first matching `page_owners` entry and is unchanged when non-matching entries are appended (`DocsParity.Tests.ps1`).
- [ ] `Measure-DocsParityScore` returns per dimension integer counts that sum to the row count and `score_basis_points` equal to `floor(10000 * pass / (pass + fail + not_assessed))` or null when that denominator is 0 (`DocsParity.Tests.ps1`).
- [ ] Each `update-ledger` operation `set-disposition`, `remove-entry`, `pin`, `unpin`, `set-dimension` and `sync-refs` produces its documented change on an in-memory fixture; `set-disposition` that drops a binding removes that element-page's matrix rows and pins; re-pinning the same element and page keeps one pin with the same `pin_id`; an option outside the operation's permitted set, `-Element` with `-Limit`, and `-Limit` with a disposition other than `deferred` each exit 2 (`DocsLedgerCommands.Tests.ps1`).
- [ ] `update-ledger` exits 1, returns the new `error` findings, and makes no `WriteText` call when the operation would introduce an `error` finding absent before it (for example `set-disposition -Disposition excluded` without `-Rationale`); it exits 0 when only pre-existing errors for other elements exist, and its exit-0 envelope carries no `error` finding (`DocsLedgerCommands.Tests.ps1`).
- [ ] `update-ledger` without `-Write` makes no `WriteText` call and `Invoke-DocsArtifactWrite -DryRun` invokes none of its scriptblock parameters, and the subcommand reports each changed document as `planned` and each unchanged one as `skipped`; with `-Write` it creates an absent document only after `TestFile` returns false and overwrites an existing document only when its digest equals the digest read at load time; a digest mismatch exits 3 with one `DOCS_CLI_RUNTIME` finding naming the conflicting path, with already-written paths in `related_paths` (`DocsLedgerMutation.Tests.ps1`, `DocsLedgerCommands.Tests.ps1`).
- [ ] With a recording in-memory context, `coverage` makes zero `WriteText` calls, `validate` without `-WriteReceipt` makes zero `WriteText` calls in every mode, `validate -Mode docs-complete -WriteReceipt` writes only the `docs-validation-receipt` document at `artifact_paths.validation_receipt` on both pass and fail, and `-WriteReceipt` with any other mode exits 2 (`DocsLedgerCommands.Tests.ps1`).
- [ ] `DocsWriteBoundary.Tests.ps1` parses every `.ps1` and `.psm1` under `.claude/lib/docs/` with the PowerShell parser and asserts: no filesystem write primitive (`Set-Content`, `Add-Content`, `Out-File`, `New-Item`, `Copy-Item`, `Move-Item`, `Remove-Item`, `Tee-Object`, `Export-Csv`, `Export-Clixml`, member calls on `System.IO.File`, `System.IO.FileStream`, `System.IO.StreamWriter`, file redirection) except `Write-DocsFileText` in `Invoke-DocsCommand.ps1` (allowlist reason "init create-only and explicit overwrite"); a scriptblock named `WriteText` is invoked only inside `Invoke-DocsArtifactWrite`; among 1023 modules only `DocsLedgerCommands.psm1` accesses the member `WriteText`; `Invoke-DocsArtifactWrite` is referenced only from `DocsLedgerCommands.psm1`; and a positive control reports a write call in an in-memory source string.
- [ ] For each of `coverage`, `update-ledger` and `validate`, tests assert exit 0 on success, exit 1 on findings, exit 2 with exactly one `DOCS_CLI_ARGUMENTS` finding and `result` null for an unknown option, a missing required option and an invalid value (including an invalid `-Revision`, `-Element`, `-Limit` and relative path) before any context read, and exit 3 with exactly one `DOCS_CLI_RUNTIME` finding and `result` null for an injected read failure, an injected write failure and a non-UTC clock (`DocsLedgerCommands.Tests.ps1`).
- [ ] Every `-Json` envelope captured by the 1023 suites produces no finding from `Test-DocsArtifactText -ArtifactKind 'docs-command-envelope'`, has `command` equal to the subcommand name and `ok` true exactly when `exit_code` is 0, and two runs with identical inputs, arguments and clock produce byte-identical stdout (`DocsLedgerCommands.Tests.ps1`).
- [ ] Without `-Json`, each subcommand prints one `<severity> <code> <artifact_path><pointer>: <message>` line per finding and ends with `<command>: exit=<n> errors=<n> warnings=<n> infos=<n>` (`DocsLedgerCommands.Tests.ps1`).
- [ ] `coverage -Json` returns `result` with `totals` (including `by_analysis_method`), `undocumented`, `deferred`, `precision_limits` (with `recorded` false for an unrecorded limit), `stale_pages` and `parity`, and with no ledger, matrix or pin collection present it lists every inventoried element as undocumented and exits 0 (`DocsLedgerCommands.Tests.ps1`).
- [ ] `Get-DocsReceiptGateDecision` returns `receipt-invalid` for unparsable or schema-invalid text, `mode-not-docs-complete`, `result-fail`, `revision-mismatch` (including a revision differing only in letter case), and `Allow` true with `pass` for a passing docs-complete receipt pinned to the supplied revision, in that precedence (`DocsReceipt.Tests.ps1`).
- [ ] `Get-DocsCommandTable` (dot-sourced from `Invoke-DocsCommand.ps1`) contains rows named `coverage`, `update-ledger` and `validate` whose `Module` resolves to `DocsLedgerCommands.psm1` and whose `Function` values are `Invoke-DocsCoverageCommand`, `Invoke-DocsUpdateLedgerCommand` and `Invoke-DocsValidateCommand`; `Test-DocsCommandTable` returns no finding (`DocsLedgerCommands.Tests.ps1`).
- [ ] Every pure function exported by the eight 1023 modules has at least one property test using a seeded `[System.Random]` (seed in each `-Because` message) or exhaustive enumeration, including: order invariance of ledger, matrix and pin findings and serialized output under input permutation; ledger completeness over every subset of a fixed snapshot (missing-disposition findings name exactly the complement, `DOCS_LEDGER_LIMIT_UNRECORDED` names exactly the unrecorded limits); the disposition-companion table over all disposition and field-presence combinations; and `Get-DocsArtifactWritePlan` ordering and `skipped` status; the plan's traceability maps each pure function to its property test.
- [ ] Each new file under `.claude/lib/docs/` has a byte-identical copy under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` and one `paths` line in `pack-manifests/core.json`, the bundle `Invoke-DocsCommand.ps1` carries the same three rows, and `Docs.Manifest.Tests.ps1` (1020), `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` and `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py` pass (`poshqc / PowerShell QC` and `quality-checks7 / Code Quality & Tests`).
- [ ] Each new module passes `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` (no `& $Context.<Member>` call) and PSScriptAnalyzer with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` with zero findings (`poshqc / PowerShell QC` and `poshqc / PowerShell QC static`).
- [ ] No 1023 test file uses a token forbidden by `.claude/hooks/check-powershell-test-purity.ps1` (including `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `$env:TEMP`, `$env:TMP`, `Start-Process`, `Start-Sleep`); every suite removes the `Docs*` modules in `AfterAll`; three seeded shuffled file-order runs of the docs suites and one fresh single-process run over `tests/scripts` pass, recorded under `evidence/regression-testing/`.
- [ ] Pester line coverage is >= 85% for each new production file, read per file from the Pester coverage report of `poshqc / PowerShell QC` (`windows-latest`), with no production file excluded from measurement; figures recorded under `evidence/qa-gates/`.
- [ ] No production or test file created or edited by this feature exceeds 800 lines, and the repository file-size gate passes.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests
- [ ] Behavior matches acceptance criteria on `windows-latest` in `poshqc / PowerShell QC`
- [ ] Tests added (unit, property and integration Pester suites)
- [ ] Edge cases and error handling covered (empty file, invalid JSON, duplicate keys, absent artifact, tampered element id, duplicate entry, orphan entry, kind mismatch, duplicate row, unknown pin, non-UTC clock, digest conflict, malformed precision-limit marker)
- [ ] One property test per pure function
- [ ] Toolchain pass completed (format, lint, type check not applicable to PowerShell, architecture, test, contract, integration) in a single clean pass
- [ ] Evidence written under `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/evidence/<kind>/`

## Seeded Test Conditions (from potential)

- [ ] Unit coverage areas: ledger rules (including precision limits), parity rules and scoring, pins and staleness, receipt and gate decision, validation modes, write boundary
- [ ] Integration scenarios: docs-complete validation over an in-memory fixture with one undocumented element and one stale page
- [ ] CLI examples: `Invoke-DocsCommand.ps1 -Command coverage`, `-Command update-ledger`, `-Command validate -Mode docs-complete`
