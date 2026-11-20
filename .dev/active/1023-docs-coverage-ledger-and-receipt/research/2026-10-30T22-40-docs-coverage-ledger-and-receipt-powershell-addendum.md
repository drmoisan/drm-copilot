# docs-coverage-ledger-and-receipt (Issue #1023) - PowerShell Design Addendum

- Issue: #1023 (epic #1019 documentation-estate-tooling, wave 1, band C4, depends on 1020)
- Branch: `feature/docs-coverage-ledger-and-receipt-1023`
- Planning cycle: new cycle under owner decision D1 (one planner revision, single-pass preflight)
- Supersedes for design purposes: `research/2026-10-30T20-59-docs-coverage-ledger-and-receipt-research.md`
  (withdrawn Python design). That file is kept unmodified; its language-independent semantics
  (staleness statuses, receipt identity rule, validation-mode layering, update semantics, finding
  vocabulary) are carried forward here in PowerShell terms, and only this file is a design source.
- Consumers of this addendum: `prd-feature` (revises `spec.md` and `user-story.md` in place) and
  `atomic-planner` (revises `plan.2026-10-30T16-51.md` in place).
- Evidence basis: files read in this worktree. The researcher has no Bash, `git` or `gh`; facts that
  need them are listed under `## Items for the Orchestrator to Confirm` and marked UNVERIFIED in the
  text.

## 0. Decisions in One Line Each

1. Eight production modules under `.claude/lib/docs/`, exactly the epic file list; no Python,
   no TypeScript, no hook, no schema file owned by 1023.
2. Every write of a ledger, matrix, pin collection or receipt goes through one function,
   `Invoke-DocsArtifactWrite` in `DocsLedgerMutation.psm1`, which calls the 1020 command-context
   member `WriteText` (backed by `Write-DocsFileText`) through a `[scriptblock]` parameter.
3. Three dispatch rows under the existing 1020 anchor `# --- 1023: coverage, update-ledger, validate ---`.
4. Command contract: exit codes 0/1/2/3, `-Json` envelope `{command, exit_code, findings, ok, result}`
   validated in tests against `schemas/docs/v1/docs-command-envelope.schema.json` (1020 amendment).
5. Every ledger entry records `analysis_method` (`native` or `scanner`) copied from the current
   snapshot element; a method change is a warning, never an identity or staleness event.
6. The scanner precision limit is recorded as a ledger `precision_limits` record keyed by the
   snapshot diagnostic `id`, with disposition const `deferred`, an owner and a target; it requires a
   1020 schema amendment (Owner Question OQ-A).
7. `docs-complete` treats deferred element entries and precision-limit records by one rule,
   `completion_gates.docs_complete.allow_deferred`: allowed means pass with report; not allowed
   means one `DOCS_DEFERRED_NOT_ALLOWED` error per record.
8. `-WriteReceipt` is accepted only with `-Mode docs-complete`, so the persisted receipt that 900008
   reads is always a docs-complete receipt.
9. `DocsReceipt.psm1` exports a pure gate function, `Get-DocsReceiptGateDecision`, which 900008's
   hook calls, so receipt semantics live in one module.
10. One property test per pure function from the start, using seeded `[System.Random]` generation or
    exhaustive enumeration; no new module.

## 1. Requirements Sources Read

- `docs/features/epics/documentation-estate-tooling/epic.md`, all of it. Binding headings used:
  `## Owner Directive: Implementation Language (2026-10-30, refined)`, `### Artifact classes for this
  epic`, `## Owner Decisions (2026-10-30, received through the coordinator)`, `### Amendment of 1020
  required by D3 and D5`, `### PowerShell contracts from the re-preparation of 1020 (binding; ...)`,
  `### Command contract decisions from the first preparation of 1023 (language-independent)`,
  `### Generator decisions from the first preparation of 1024 (language-independent)`,
  `### 1023 - docs-coverage-ledger-and-receipt (wave 1, C4)`, `### 900007 - docs-mcp-tools (wave 3, C3)`,
  `### 900008 - docs-enforcement-and-ci (wave 2, C3)`, `### 900011 - docs-surface-analyzer-python-native (wave 2, C3)`.
- `docs/features/active/2026-10-30-docs-profile-and-artifact-schemas-1020/spec.md` (version 0.3,
  PowerShell design), its plan `plan.2026-10-30T16-08.md` (`## Design Constraints From Existing
  Tests`), its addendum research `research/2026-10-30T21-45-docs-profile-powershell-design-addendum-research.md`
  (section 13 `Contracts 1023 Assumes That 1020 Must Provide`) and
  `evidence/other/preflight-fixes.2026-10-30T22-23.md`.
- `docs/features/active/2026-10-30-docs-surface-analyzers-python-config-1022/` (`spec.md`,
  research): still the withdrawn Python design in this worktree; no `analysis_method` field and no
  PowerShell diagnostic code list exist there yet.
- `docs/features/active/2026-10-30-docs-reference-generator-1024/` (`spec.md` decision D2,
  research gap G3): path-matching rule stated in Python terms (`fnmatch.fnmatchcase`).
- No 900011 feature folder exists under `docs/features/active/` in this worktree (verified by glob).
- 1023 folder: `issue.md`, `spec.md` (version 0.2, Python), `user-story.md`,
  `plan.2026-10-30T16-51.md`, the earlier research, `evidence/other/preflight-fixes.2026-10-30T21-29.md`.

### 1.1 Discrepancies between 1020 `spec.md` and the epic

| Topic | 1020 `spec.md` (version 0.3) | Epic (binding, newer) | Treatment here |
|---|---|---|---|
| Envelope schema | "The envelope has no schema file; Pester and 900007 Jest tests pin it." | D5 and `### Amendment of 1020 required by D3 and D5`: `schemas/docs/v1/docs-command-envelope.schema.json` | Use the amended contract. Validation entry point is UNVERIFIED (section 9). |
| `analysis_method` | Absent from the snapshot `element` and the ledger `entry` shapes | Required on inventory elements and ledger entries | Use the amended contract; field position UNVERIFIED. |
| Element digest | `source_sha256` (meaning not fixed) | Declaration-lines digest (D5) | 1023 compares opaque values; field name after amendment UNVERIFIED. |
| Child anchors | `900003` (inventory) and `900006` (generate-reference) | Children are 1022 and 1024 | Not 1023's concern; the 1023 anchor text `# --- 1023: coverage, update-ledger, validate ---` is identical in both. |
| `Get-DocsSchemaName` order and `docs-artifact-kind` enum | Six artifact kinds plus `common` | Envelope schema added | Whether the envelope joins the schema table is UNVERIFIED. |

## 2. Current State (verified in this worktree)

- `.claude/lib/docs/` does not exist (glob returns no file): 1020 is planned, not executed. Every
  1020 symbol cited below is a contract from 1020 `spec.md`, not code.
- `.claude/lib/discovery-validation/DiscoveryEncoding.psm1` exports exactly
  `Get-DiscoverySha256Hex`, `Get-DiscoveryBytesSha256Hex` and `ConvertTo-DiscoveryCanonicalJson`
  (`Export-ModuleMember`). 1023 does not import it directly; it reaches it through 1020
  `DocsJson.psm1` (`ConvertTo-DocsCanonicalJson`, `Get-DocsSha256Hex`, `Get-DocsBytesSha256Hex`).
  No other discovery-validation module is relevant (`DiscoveryPayload.psm1` handles host payloads).
- `schemas/discovery/v2/` holds `common.schema.json`, `validation-receipt.schema.json`,
  `coverage-ledger.schema.json`, `parity-matrix.schema.json`, `evidence-reference.schema.json`,
  `inventory-snapshot.schema.json` and others. They are design references only: 1020 copies the
  needed `common` definitions into docs common, and no docs schema references a discovery URN
  (1020 `### Schema identity and reference conventions`). 1023 reads no discovery schema.
- `Test-Json` cross-file `$ref`: resolved by 1020 (orchestrator probe, PowerShell 7.6.9): rejected
  by default; 1020 composes the docs common `$defs` inline (`Join-DocsSchemaText`,
  `Get-DocsComposedSchemaSet`). 1023 validates every artifact with `Test-DocsArtifactText` over a
  composed set and never relies on `Test-Json` message text.
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` with
  `EnforcementHooksNoPythonInvocation.Helpers.ps1` (`Get-PythonInvocationFinding`) and
  `EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1` (`$script:ScanRoot`: `.claude/hooks`,
  `.claude/lib`, `.codex/hooks`; the bundle mirror is excluded). Detection classes: (1) constant
  `python`, `python3`, `py`, `poetry` commands; (2) `Start-Process` targeting them; (3) any command
  position that is not a literal constant, fail-closed, except carve-out (a) a variable whose name
  matches a `[scriptblock]`-typed parameter declared in the same file and carve-out (b) dot-sourcing
  a path variable or an inline `Join-Path $PSScriptRoot '<sibling>.ps1'`; (4) `Invoke-Expression`
  and `iex`. Consequence (also recorded in 1020 `preflight-fixes.2026-10-30T22-23.md` fix 1):
  `& $Context.WriteText` is a member expression in command position and is reported as
  `DynamicInvocation`. A context member must be passed to a `[scriptblock]` parameter and invoked
  as `& $WriteText`. The allowlist is empty and may change only by owner decision.
- `.claude/hooks/check-powershell-test-purity.ps1` forbids in Pester tests: `New-TemporaryFile`,
  `[System.IO.Path]::GetTempFileName`, `[System.IO.Path]::GetTempPath`, `$env:TEMP`, `$env:TMP`,
  network APIs, `Start-Process`, `Start-Sleep`, and direct `Mock git`/`Mock gh`.
- `scripts/powershell/PoshQC/settings/pssa.settings.psd1` enables all default rules at every
  severity plus `PSUseShouldProcessForStateChangingFunctions`, `PSUseConsistentIndentation`,
  `PSAlignAssignmentStatement` and `PSUseConsistentWhitespace`. Precedent for a pure factory with a
  `New-` verb: `New-EpicScopeResult` in `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`
  carries `[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory factory that changes no system state.')]`.
- `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` discovers `*.psm1` under
  `.claude/lib` recursively and requires the token `imports its siblings with -ErrorAction Stop`
  (`$script:ConventionToken`), the strict-mode pair, and `-ErrorAction Stop` on column-0
  `Import-Module`.
- Pack manifest: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
  (`paths`; lists `.claude/lib/<area>/*.psm1` entries such as
  `.claude/lib/discovery-validation/DiscoveryValidation.psm1`). Sibling manifests: `python.json`,
  `powershell.json`, `typescript.json`, `csharp-legacy.json`, `csharp-modern.json`.
- `config/poshqc-coverage.json` `roots` includes `.claude/lib`; `config/poshqc-scan.json`
  `test.scanFolders` includes `tests/scripts`. Neither needs an edit.
- `quality-tiers.yml` has no `.claude/lib/docs` entry yet; 1020 adds it at T3. 1023 does not edit
  it. Every existing `.claude/lib/*` entry is T3.
- Test layout precedent: `tests/scripts/claude-lib/mermaid/<Module>.Tests.ps1` for
  `.claude/lib/mermaid/<Module>.psm1`.
- Hook precedent for importing a lib module (relevant to 900008):
  `Import-Module (Join-Path $PSScriptRoot '../lib/hook-payload/HookPayload.psm1') -Force -ErrorAction Stop`
  inside a `try` with `Add-HookDependencyFailure` (for example `.claude/hooks/enforce-discovery-artifact-gate.ps1`).

## 3. Candidate Approaches

### 3.1 Precision-limit representation in the ledger

| Option | Description | Assessment |
|---|---|---|
| A (selected) | A second ledger array `precision_limits`, one record per precision-limit diagnostic, keyed by the snapshot diagnostic `id`, with `disposition` const `deferred`, `owner`, `target`, `rationale`, `analysis_method` const `scanner`, `analyzer_id`, `code`, `path`, `updated_by`, `extensions` | Keeps `entries[].element_id` on the `element-id` grammar; exact-once accounting mirrors element completeness; the disposition is literally `deferred` with an owner, as D3 requires. Needs a 1020 schema amendment. |
| B | Generalize `entries[]` to a subject identifier that is either an element id or a diagnostic id | Breaks the `element-id` pattern and the `kind` field of entries; every element rule needs a subject-type branch. Rejected. |
| C | Store the records in ledger `extensions` | Not validated by schema; not visible to the structural walk. Rejected. |
| D | One record per scanner analyzer instead of per diagnostic | Fewer records, but a new unclassified construct in a new file would be silently covered; docs-complete would lose its exact-once property. Kept as owner alternative in OQ-A. |

### 3.2 Identifying a precision-limit diagnostic

| Option | Description | Assessment |
|---|---|---|
| A (selected) | The amended 1020 `diagnostic` shape carries `analysis_method` and a boolean `precision_limit`; 1023 selects diagnostics with `analysis_method == 'scanner'` and `precision_limit == true` | Self-describing snapshot; 1023 needs no knowledge of 1022 or 900004 code names. Needs the amendment and 1022/900004 to set the flag. |
| B | Registry rows declare `PrecisionLimitCodes`; 1023 matches (`analyzer_id`, `code`) through `Get-DocsAnalyzerRegistration` | Works without a snapshot schema change, but couples 1023 to registry contents and to the registry version present when validating a snapshot captured earlier. Fallback only. |

### 3.3 Path matching for `page_owners[].path_or_glob`

| Option | Description | Assessment |
|---|---|---|
| A (selected) | One pure function pair `Test-DocsPathOrGlobMatch -Path -PathOrGlob` and `Get-DocsPageOwner -PagePath -PageOwner` in a 1020 module (amendment), used by 1023 and 1024 | One implementation of the epic rule; no duplication across wave-1 and wave-2 children. |
| B | 1023 implements it in `DocsParity.psm1` and 1024 imports it from there | 1024 does not depend on 1023 in the manifest; adding the edge changes the wave plan. |
| C | Each child implements its own copy | Two implementations of one rule drift. Rejected. |

Glob semantics required by the epic rule (exact, or prefix plus `/`, or case-sensitive glob, first
match wins) follow Python `fnmatch.fnmatchcase` as 1024 stated it: `*` matches any run including
`/`, `?` one character, `[...]` a class with `[!...]` negation, no escape character. PowerShell
`-like`, `-clike` and `[WildcardPattern]` differ (backtick escaping, no `[!...]` negation), so the
function translates the glob to an anchored .NET regex built character by character
(`[regex]::Escape` for literals, `RegexOptions.CultureInvariant`, no `IgnoreCase`). Profile entries
are evaluated in array order; the first matching entry gives the owner.

### 3.4 Receipt persistence scope

Selected: `-WriteReceipt` only with `-Mode docs-complete` (any other mode with `-WriteReceipt` is
exit 2). Rejected: persisting any mode's receipt to the single `artifact_paths.validation_receipt`
path, because a later `ledger`-mode run would overwrite the docs-complete receipt that 900008 reads.

### 3.5 Write boundary

Selected: a 1023-owned boundary module that plans writes purely and commits them through the
context `WriteText` scriptblock with a digest re-check before overwrite. Rejected: calling
`[System.IO.File]` or `Set-Content` in 1023 (adds a second filesystem primitive and breaks the 1020
rule that `Write-DocsFileText` is the only write primitive); reusing the Python discovery
`mutation_io` (withdrawn by the language rule and absent from destinations).

## 4. Module Design (`.claude/lib/docs/`)

Conventions inherited from 1020 `### Module conventions`: `[CmdletBinding()]` advanced functions;
the help sentence `imports its siblings with -ErrorAction Stop`; `Set-StrictMode -Version Latest`
followed by `$ErrorActionPreference = 'Stop'`; literal `Join-Path -Path $PSScriptRoot -ChildPath
'<literal>'` for every sibling import; pure means no filesystem, clock, process, environment or
module-scope mutable state; command modules never print and never call `exit`. Additional rules
for 1023:

- Naming: pure functions avoid the verbs `New`, `Set`, `Remove`, `Update`, `Reset`, `Start`, `Stop`
  and `Restart`, or carry the `PSUseShouldProcessForStateChangingFunctions` suppression with the
  justification wording of the `New-EpicScopeResult` precedent. The names below follow that rule:
  constructors keep `New-` with the suppression; transformations use `Merge-`, `Get-`, `Measure-`,
  `Test-` or `ConvertTo-`.
- Ordinal semantics: PowerShell `-eq`, `-like`, `-match`, `-contains`, `Sort-Object` and
  `Group-Object` are case-insensitive or culture-sensitive by default. All identifier and path
  comparisons use `-ceq`/`-cne` or `[string]::Equals(a, b, [StringComparison]::Ordinal)`, and every
  sort uses `[System.Array]::Sort(<string[]>, [System.StringComparer]::Ordinal)` or a keyed
  ordinal comparer, so ordering matches `ConvertTo-DocsCanonicalJson` and `Get-DocsOrderedFinding`.
- Integer arithmetic only for scores: `[System.Math]::DivRem([int64]$numerator, [int64]$denominator, [ref]$remainder)`.
- Timestamps: `ConvertTo-DocsTimestampText` (section 4.5) is the only formatter; it refuses a
  `DateTime` whose `Kind` is not `Utc`.

### 4.1 Import graph

| Module | Role | Imports (literal joins) |
|---|---|---|
| `DocsLedger.psm1` | Snapshot view, ledger entries, precision-limit records, ledger rules, ledger operations | `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSurface.psm1` |
| `DocsParity.psm1` | Matrix rows, matrix rules, dimension operations, scoring | `DocsFinding.psm1`, `DocsSurface.psm1`, `DocsJson.psm1`, plus the module that owns `Get-DocsPageOwner` (section 3.3) |
| `DocsEvidencePins.psm1` | Pin identity, construction, consistency, pin operations | `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSurface.psm1` |
| `DocsStaleness.psm1` | Pin status, stale pages, staleness findings | `DocsFinding.psm1`, `DocsEvidencePins.psm1` |
| `DocsReceipt.psm1` | Receipt identity, counts, construction, gate decision, timestamp formatting | `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSchema.psm1`, `DocsSurface.psm1` |
| `DocsValidation.psm1` | Mode layering and the docs-complete gate | `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSchema.psm1`, `DocsProfile.psm1`, `DocsLedger.psm1`, `DocsParity.psm1`, `DocsEvidencePins.psm1`, `DocsStaleness.psm1`, `DocsReceipt.psm1` |
| `DocsLedgerMutation.psm1` | Write planning (pure) and the single commit function | `DocsJson.psm1`, `DocsFinding.psm1`, `DocsSurface.psm1` |
| `DocsLedgerCommands.psm1` | `coverage`, `update-ledger`, `validate` command functions, input loading, argument rules, coverage report | every module above plus `DocsProfile.psm1`, `DocsSchema.psm1` |

No cycle: `DocsLedgerCommands` is the only importer of `DocsLedgerMutation`, and
`DocsLedgerMutation` imports no 1023 module.

### 4.2 `DocsLedger.psm1`

| Function | Pure | Contract |
|---|---|---|
| `ConvertTo-DocsSnapshotView -Snapshot <IDictionary> -SnapshotSha256 <string> [-ArtifactPath <string>]` | yes | Rebuilds every element with `ConvertFrom-DocsSurfaceElement` (1020); returns `@{ Repository; Revision; Sha256; Element (ordinal dictionary element_id -> element); PrecisionLimit (ordinal dictionary diagnostic id -> diagnostic); Findings }`. A rebuild failure yields `DOCS_SNAPSHOT_ELEMENT_INVALID` with pointer `/elements/<n>`. |
| `Test-DocsPrecisionLimitDiagnostic -Diagnostic <IDictionary>` | yes | `$true` exactly when the selected identification rule (section 3.2 A) holds. |
| `New-DocsLedgerEntry -Element <IDictionary> -Disposition <string> [-PageBinding <object[]>] [-Rationale] [-Owner] [-Target] -Actor <IDictionary>` | yes | Ordered entry with `element_id`, `kind` and `analysis_method` copied from the element; bindings sorted by `page_path` then `anchor` (ordinal, null anchor first). |
| `New-DocsPrecisionLimitRecord -Diagnostic <IDictionary> -Owner -Target [-Rationale] -Actor` | yes | Ordered record per section 5.3. |
| `New-DocsLedgerDocument -RepositoryId <string> -SnapshotPin <IDictionary>` | yes | Empty ledger with the 1020 header; `id` = `Get-DocsStableId -Prefix 'docs-coverage-ledger' -Value @{ repository = <id> }`. |
| `Get-DocsLedgerEntryCompanionFinding -Entry <IDictionary> -Pointer <string> [-ArtifactPath]` | yes | Companion table of 1020 `### Artifact schema: docs-coverage-ledger`; codes in section 6. |
| `Get-DocsLedgerFinding -Ledger <IDictionary> -SnapshotView <object> [-ArtifactPath]` | yes | Completeness, duplicates, orphans, kind mismatch, companions, snapshot reference, analysis method, precision-limit accounting. |
| `Merge-DocsLedgerEntry -Ledger -Entry` | yes | Replace-or-insert by `element_id`; returns a new ledger (input not mutated); entries sorted by `element_id`. |
| `Get-DocsLedgerWithoutEntry -Ledger -ElementId` | yes | Copy without that entry. |
| `Merge-DocsPrecisionLimitRecord -Ledger -Record` and `Get-DocsLedgerWithoutPrecisionLimit -Ledger -DiagnosticId` | yes | Same for `precision_limits`, sorted by `diagnostic_id`. |
| `Merge-DocsLedgerSnapshotRef -Ledger -SnapshotPin -SnapshotView` | yes | `sync-refs` for the ledger: sets `snapshot_ref` and refreshes each entry's `analysis_method` from the current element. |

### 4.3 `DocsParity.psm1`

| Function | Pure | Contract |
|---|---|---|
| `Get-DocsParityDimension` | yes | `exists`, `accurate`, `example_present`, `owner_assigned`, `diataxis_mode` in contract order. |
| `New-DocsParityRow -ElementId -Kind -PagePath` | yes | Every dimension `not-assessed`, `rationale` null, `evidence_pin_ids` empty. |
| `New-DocsParityMatrixDocument -RepositoryId -SnapshotPin -LedgerPin` | yes | Empty matrix with header; stable `id` as for the ledger. |
| `Get-DocsMatrixFinding -Matrix -Ledger -PinSet -PagePath <string[]> -PageOwner <object[]> -LedgerSha256 [-ArtifactPath]` | yes | Unbound row, missing row, duplicate row, unknown pin, accuracy without pin, `exists` and `owner_assigned` consistency, ledger reference. |
| `Merge-DocsParityDimension -Matrix -ElementId -Kind -PagePath -Dimension -State [-Rationale] -PinId <string[]>` | yes | Creates the row when absent; sets one dimension; `evidence_pin_ids` = sorted pin ids for that element and page. |
| `Get-DocsMatrixWithoutBinding -Matrix -ElementId [-PagePath]` | yes | Removes rows for an element, or for one element and page. |
| `Merge-DocsMatrixPinRemoval -Matrix -PinId` | yes | Removes one pin id from every `evidence_pin_ids`. |
| `Merge-DocsMatrixRef -Matrix -SnapshotPin -LedgerPin` | yes | `sync-refs` for the matrix. |
| `Get-DocsScoreBasisPoint -Pass <int64> -Fail <int64> -NotAssessed <int64>` | yes | `floor(10000 * pass / (pass + fail + not_assessed))`, `$null` when the denominator is 0; integer only. |
| `Measure-DocsParityScore -Matrix` | yes | Per dimension `{pass, fail, not_assessed, not_applicable, score_basis_points}`. |

### 4.4 `DocsEvidencePins.psm1` and `DocsStaleness.psm1`

| Function | Pure | Contract |
|---|---|---|
| `Get-DocsPinId -ElementId -PagePath -Symbol` | yes | `Get-DocsStableId -Prefix 'pin' -Value [ordered]@{ element_id; page_path; symbol }`. |
| `New-DocsEvidencePin -Element -PagePath [-Claim] -Revision -PinnedAt <string> -Actor` | yes | Fields of 1020 `$defs/pin`; `source_sha256` copied from the element's declaration digest field (opaque). |
| `New-DocsPinCollectionDocument -RepositoryId` | yes | Empty collection with header. |
| `Get-DocsPinFinding -PinSet [-ArtifactPath]` | yes | `DOCS_PIN_INCONSISTENT` when `Get-DocsElementId -Kind element_kind -Path source_path -Declaration symbol` differs from `element_id`, or `pin_id` differs from `Get-DocsPinId`; duplicate `pin_id`. |
| `Merge-DocsEvidencePin -PinSet -Pin` and `Get-DocsPinSetWithoutPin -PinSet -ElementId [-PagePath]` | yes | Replace-or-insert by `pin_id`; removal; pins sorted by `pin_id`. |
| `Get-DocsPinStatus -Pin -Element <IDictionary>` (DocsStaleness) | yes | `element-missing` when no current element has `element_id`; `digest-changed` when present and digests differ (ordinal string comparison); `current` otherwise. A revision difference never changes the status. |
| `Get-DocsStalePage -PinSet -Element` (DocsStaleness) | yes | One record per page with at least one non-current pin: `{page_path, pins: [{pin_id, element_id, status}]}`, sorted by `page_path` then `pin_id`. |
| `Get-DocsStalenessFinding -StalePage -Element -Severity <warning|error> [-ArtifactPath]` (DocsStaleness) | yes | One `DOCS_STALE_PAGE` per stale page; message names the page path and, per non-current pin, the declaration, element id and status; `related_paths` the page; `related_ids` the element and pin ids. |

### 4.5 `DocsReceipt.psm1`

| Function | Pure | Contract |
|---|---|---|
| `ConvertTo-DocsTimestampText -UtcNow <DateTime>` | yes | `ToString("yyyy-MM-dd'T'HH:mm:ss'Z'", [cultureinfo]::InvariantCulture)`; throws `DOCS_CLOCK_NOT_UTC` when `Kind` is not `Utc` (mapped to exit 3). |
| `Get-DocsWriterVersion` | yes | Constant `1.0.0` for `writer.version`. |
| `Get-DocsArtifactPin -ArtifactKind -Path -Bytes <byte[]>` | yes | `{artifact_kind, path, sha256}` with `Get-DocsBytesSha256Hex` of the raw bytes read. |
| `Get-DocsReceiptId -Mode -Repository -Revision -InputPin <object[]> -ValidationResult` | yes | `Get-DocsStableId -Prefix 'docs-validation-receipt' -Value [ordered]@{ inputs; mode; repository; revision; validation_result }`; excludes `issued_at`, `counts`, `findings` and `writer`. The prefix and hex satisfy the docs `identifier` grammar. |
| `Measure-DocsReceiptCount -Mode -SnapshotView -Ledger -StalePageCount` | yes | `elements_total`, `undocumented`, `stale_pages`, `by_disposition` (exactly the three dispositions, entries matching current elements), `by_kind` (exactly the six kinds); zeros where the mode reads no such input. |
| `New-DocsValidationReceipt -Mode -Repository -Revision -InputPin -Count -Finding -IssuedAt -ValidationResult` | yes | Every field of 1020 `### Artifact schema: docs-validation-receipt`; `inputs` sorted by `artifact_kind` then `path`. |
| `Get-DocsReceiptGateDecision -ReceiptText <string> -HeadRevision <string> -ComposedSchemaSet <IDictionary>` | yes, apart from `Test-Json` | Returns `@{ Allow; Reason; ReceiptId }`. Reasons in fixed precedence: `receipt-invalid` (parse or schema finding), `mode-not-docs-complete`, `result-fail`, `revision-mismatch` (ordinal), else `Allow = $true`, `Reason = 'pass'`. A missing receipt is the caller's `receipt-missing`. Consumed by 900008. |

### 4.6 `DocsValidation.psm1`

| Function | Pure | Contract |
|---|---|---|
| `Get-DocsValidationMode` | yes | `profile`, `ledger`, `matrix`, `docs-complete` (each includes the checks of the modes before it). |
| `Get-DocsValidationInputKind -Mode` | yes | `profile`: profile; `ledger`: plus snapshot and ledger; `matrix` and `docs-complete`: plus matrix, pin collection and the page-path set. |
| `Get-DocsCompletionGateFinding -Gate <IDictionary> -SnapshotView -Ledger -Matrix -StalePage -PagePath -SnapshotRevision` | yes | `DOCS_SNAPSHOT_UNPINNED`, `DOCS_DEFERRED_NOT_ALLOWED` (entries and precision-limit records), `DOCS_PARITY_REQUIRED_DIMENSION`, `DOCS_BOUND_PAGE_MISSING`, and the `DOCS_STALE_PAGE` severity rule. |
| `Invoke-DocsValidation -Mode -Revision -IssuedAt <string> -ProfileText -ProfilePath -Artifact <IDictionary> -PagePath <string[]> -ComposedSchemaSet <IDictionary> [-AnalyzerId <string[]>]` | yes, apart from `Test-Json` | `Artifact` maps an artifact kind to `@{ Path; Bytes }` or `$null` (absent). Returns `@{ Receipt; Findings; Ok }`; `Receipt` is `$null` only when the profile does not load. Every built receipt is validated with `Test-DocsArtifactText -ArtifactKind 'docs-validation-receipt'`; a failure throws `DOCS_RECEIPT_INVALID` (defect guard, exit 3). |

### 4.7 `DocsLedgerMutation.psm1` (single write boundary)

| Function | Pure | Contract |
|---|---|---|
| `Get-DocsArtifactWritePlan -Document <object[]>` | yes | Each input `@{ Path; ArtifactKind; ArtifactId; Text; BeforeSha256 }` (`BeforeSha256` null when absent before). Returns plans sorted by `Path` (ordinal) with `Sha256` of the UTF-8 bytes of `Text` and status `planned`, or `skipped` when `Sha256 == BeforeSha256`. |
| `Invoke-DocsArtifactWrite -Plan <object[]> -ReadBytes <scriptblock> -TestFile <scriptblock> -WriteText <scriptblock> [-DryRun]` | no (I/O only through the three scriptblock parameters) | Dry run: no scriptblock call; statuses stay `planned`/`skipped`. Write: in ascending path order, skip `skipped`; for `BeforeSha256` null, `& $TestFile` must be false, then `& $WriteText <path> <text> 'create'` and status `created`; otherwise `& $ReadBytes` and compare `Get-DocsBytesSha256Hex` with `BeforeSha256`; equal: `& $WriteText <path> <text> 'overwrite'`, status `updated`; different or present-when-expected-absent: status `conflict` and stop. Returns `@{ Write; Failed; WrittenPath }`. |

Text written: `ConvertTo-DocsJsonText -Value <document> -Indented` (1020 section 3.9: files a person
reads); digests and identifiers use canonical JSON. This is the only 1023 function that invokes a
write scriptblock, and the only 1023 module that receives `WriteText`.

### 4.8 `DocsLedgerCommands.psm1`

| Function | Pure | Contract |
|---|---|---|
| `Invoke-DocsCoverageCommand -Argument <IDictionary> -Context <object>` | I/O via context | Read-only; never passes `WriteText` anywhere. |
| `Invoke-DocsUpdateLedgerCommand -Argument -Context` | I/O via context | The only command that passes `$Context.WriteText` (to `Invoke-DocsArtifactWrite`) for ledger, matrix and pins. |
| `Invoke-DocsValidateCommand -Argument -Context` | I/O via context | Passes `$Context.WriteText` only when `WriteReceipt` is present and the mode is `docs-complete`, and only the receipt document. |
| `Read-DocsLedgerInputSet -Profile -Need <string[]> -ReadBytes <scriptblock> -TestFile <scriptblock> -ListFile <scriptblock>` | I/O via parameters | Absent artifact -> `$null`; a read failure other than absence propagates (exit 3); page-path set = sorted union of `ListFile` over each `documentation_roots[].path`. |
| `Test-DocsUpdateLedgerArgument -Argument` and `Test-DocsValidateArgument -Argument` | yes | Value grammar and per-operation rules (section 5.2); return one `DOCS_CLI_ARGUMENTS` finding or `$null`, before any read. |
| `Get-DocsCoverageReport -SnapshotView -Ledger -Matrix -PinSet` | yes | Section 5.4 `result`. |
| `ConvertTo-DocsCoverageReportLine -Report` | yes | Text result lines. |

The command functions obtain composed schemas through 1020 `Read-DocsSchemaSet` and
`Get-DocsComposedSchemaSet`; how 1020 commands do this is UNVERIFIED (section 9 item 4).
Command-context members are passed to `[scriptblock]` parameters and never invoked as
`& $Context.<Member>`.

## 5. Command Contract

### 5.1 Shared rules (every 1023 subcommand)

| Exit | Meaning |
|---|---|
| 0 | Success or `-Help`; no `error` finding. `validate`: receipt `validation_result` `pass`. `update-ledger`: no newly introduced `error` finding and, with `-Write`, every planned write committed. `coverage`: report built. |
| 1 | Findings. `validate`: at least one `error` finding (receipt `fail`) or the profile does not load (`result` null). `update-ledger`: the operation would introduce a new `error` finding, or names a target that does not exist (`DOCS_UPDATE_TARGET_INVALID`); nothing written. `coverage`: snapshot absent (`DOCS_INPUT_UNREADABLE`) or an input fails schema or element rebuild; `result` null. |
| 2 | Usage or input error before any read: exactly one `DOCS_CLI_ARGUMENTS`; `result` null. |
| 3 | Internal or I/O error: exactly one finding, `DOCS_MUTATION_FAILED` for a commit conflict or write failure (conflicting path and already-written paths in `related_paths`), otherwise `DOCS_CLI_RUNTIME` (including a non-UTC clock and the receipt defect guard); `result` null; one stderr line. |

- `-Json`: one canonical JSON document `{command, exit_code, findings, ok, result}`; `command` is the
  subcommand name (`coverage`, `update-ledger`, `validate`); `ok` true exactly when `exit_code` is 0;
  findings in `Get-DocsOrderedFinding` order; identical inputs, arguments and clock give identical
  bytes. Every envelope a 1023 test captures is validated against
  `schemas/docs/v1/docs-command-envelope.schema.json`.
- The exit code and the receipt `validation_result` are computed from the unbounded finding set,
  before `Get-DocsOrderedFinding` truncates at 100 (see risk R2).
- Without `-Json`: `ConvertTo-DocsReportText` (finding lines, command lines, summary line
  `<command>: exit=<n> errors=<n> warnings=<n> infos=<n>`).
- Common option: `-Profile <relative path>` (default `Get-DocsDefaultProfilePath`,
  `docs/documentation-estate/docs-profile.json`). No environment variable is read.
- Value grammars checked before any read: relative paths with `Test-DocsRelativePath`; `-Element`
  with `Test-DocsElementId`; `-Revision` with `Test-DocsFullRevision`; `-ActorId` and `-Owner` with
  the docs `identifier` grammar; `-Limit` with the docs `identifier` grammar and the `diagnostic-`
  prefix; enumerations exactly as listed below.

### 5.2 `update-ledger`

| Operation | Required | Optional | Changes |
|---|---|---|---|
| `set-disposition` | `-Element` xor `-Limit`, `-Disposition` | `-Page` (multi; `<path>[#<anchor>]`), `-Rationale`, `-Owner`, `-Target` | ledger entry (or precision-limit record); matrix rows and pins of a dropped binding |
| `remove-entry` | `-Element` xor `-Limit` | none | ledger entry and that element's rows and pins, or the precision-limit record |
| `pin` | `-Element`, one `-Page` without anchor | `-Claim` | pin collection |
| `unpin` | `-Element`, one `-Page` without anchor | none | pin collection; matrix `evidence_pin_ids` |
| `set-dimension` | `-Element`, one `-Page` without anchor, `-Dimension`, `-State` | `-Rationale` | matrix |
| `sync-refs` | none | none | ledger `snapshot_ref` and entry `analysis_method`; matrix `snapshot_ref` and `ledger_ref` |

- Every operation requires `-ActorKind` (`human`, `agent`, `tool`) and `-ActorId`.
- Any option outside the operation's sets, `-Element` together with `-Limit`, or `-Limit` with a
  `-Disposition` other than `deferred`, is exit 2.
- Dry run is the default; `-Write` commits through `Invoke-DocsArtifactWrite`. `result`:
  `{dry_run, writes: [{path, artifact_kind, artifact_id, sha256, status}]}` sorted by `path`,
  `status` in `planned`, `created`, `updated`, `skipped`, `conflict`.
- Newly-introduced rule (carried from the Python design): the operation fails (exit 1, nothing
  written) when the resulting `error` findings contain a finding absent before it, compared on every
  field except `pointer`; pre-existing errors for other elements do not block it.
- Semantics carried unchanged: `set-disposition` replaces the whole entry and removes rows and pins
  for a dropped binding; `pin` re-pins the same element and page under the same `pin_id`;
  `set-dimension` creates the row when absent and derives `evidence_pin_ids` from existing pins;
  created documents carry the 1020 header with a stable `id` from the repository identifier;
  `sync-refs` pins the ledger bytes as they will be written.

### 5.3 Ledger additions (D3), requiring the 1020 amendment

- `entries[].analysis_method`: `native` | `scanner`, required, copied from the current snapshot
  element by `set-disposition` and refreshed by `sync-refs`. A difference from the current element
  is `DOCS_LEDGER_ANALYSIS_METHOD_CHANGED` (warning): 900011 guarantees identical identifiers and
  declaration-lines digests across methods, so a method change is not a coverage or staleness event.
- `precision_limits[]` (closed): `diagnostic_id` (identifier, the snapshot diagnostic `id`),
  `analyzer_id`, `code`, `path` (relative-path), `analysis_method` const `scanner`, `disposition`
  const `deferred`, `owner` (identifier), `target` (text), `rationale` (text or null), `updated_by`
  (`actor`), `extensions`. Sorted by `diagnostic_id`; `uniqueItems`. Because the diagnostic `id` is
  `Get-DocsStableId -Prefix 'diagnostic' -Value @{ analyzer; code; path }` (1020
  `New-DocsDiagnostic`), one record covers every construct with that code in that file.
- Rules: a precision-limit diagnostic in the snapshot without a record is
  `DOCS_LEDGER_LIMIT_UNRECORDED` (error, in `ledger` mode and above; message names analyzer, code,
  path and diagnostic id); two records for one id is `DOCS_LEDGER_LIMIT_DUPLICATE` (error); a record
  whose diagnostic is absent from the snapshot is `DOCS_LEDGER_LIMIT_RESOLVED` (warning; the
  replacement element, if any, needs its own disposition, so the gate still sees the new surface);
  missing owner or target reuse `DOCS_LEDGER_OWNER_REQUIRED` and `DOCS_LEDGER_TARGET_REQUIRED` with
  a pointer into `/precision_limits/<n>`.
- `docs-complete`: `allow_deferred` true -> deferred entries and precision-limit records pass and
  are listed in the coverage report; `allow_deferred` false -> one `DOCS_DEFERRED_NOT_ALLOWED` error
  per deferred entry and per precision-limit record.
- Receipt counts are unchanged unless the amendment adds a count (OQ-C).

### 5.4 `coverage` (read-only)

`result`: `totals` (the receipt `counts` object plus `by_analysis_method` `{native, scanner}` over
ledger entries matching current elements), `undocumented` `[{element_id, kind, declaration, path}]`,
`deferred` `[{element_id, owner, target}]`, `precision_limits` `[{diagnostic_id, analyzer_id, code,
path, owner, target, recorded}]` (`recorded` false for an unrecorded limit), `stale_pages`
`[{page_path, pins: [{pin_id, element_id, status}]}]`, `parity` (per dimension counts and
`score_basis_points`). An absent ledger, matrix or pin collection is treated as empty.

### 5.5 `validate`

- Options: `-Mode` (required), `-Revision` (required in every mode), `-WriteReceipt` (switch,
  `docs-complete` only), `-Profile`.
- `result`: the receipt on exit 0 and on exit 1 with a loaded profile; null otherwise.
- `DOCS_REVISION_MISMATCH` when the snapshot revision is non-null and differs from `-Revision`;
  `DOCS_SNAPSHOT_UNPINNED` (error) in `docs-complete` when the snapshot revision is null (D5).
- Persistence: with `-WriteReceipt` the receipt (pass or fail) is written to
  `artifact_paths.validation_receipt` through `Invoke-DocsArtifactWrite` (create when absent,
  digest-checked overwrite when present). Without it, no write scriptblock is passed in any mode.

### 5.6 Dispatch rows (`Invoke-DocsCommand.ps1`, under the 1023 anchor only)

```powershell
    # --- 1023: coverage, update-ledger, validate ---
    [pscustomobject]@{ Name = 'coverage'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerCommands.psm1'); Function = 'Invoke-DocsCoverageCommand'; Option = @{ Profile = 'value' } }
    [pscustomobject]@{ Name = 'update-ledger'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerCommands.psm1'); Function = 'Invoke-DocsUpdateLedgerCommand'; Option = @{ Profile = 'value'; Operation = 'value'; Element = 'value'; Limit = 'value'; Disposition = 'value'; Page = 'multi'; Rationale = 'value'; Owner = 'value'; Target = 'value'; Dimension = 'value'; State = 'value'; Claim = 'value'; ActorKind = 'value'; ActorId = 'value'; Write = 'switch' } }
    [pscustomobject]@{ Name = 'validate'; Module = (Join-Path -Path $PSScriptRoot -ChildPath 'DocsLedgerCommands.psm1'); Function = 'Invoke-DocsValidateCommand'; Option = @{ Profile = 'value'; Mode = 'value'; Revision = 'value'; WriteReceipt = 'switch' } }
```

- Each row passes `Test-DocsCommandTable`: unique names, no reserved option (`Command`, `Json`,
  `Help`, `RepositoryRoot`), kinds within `value`/`multi`/`switch`, functions matching
  `^Invoke-Docs[A-Za-z]+Command$`.
- The literal join lets `test_push_down_pack_manifest_dependency_closure.py` see
  `DocsLedgerCommands.psm1`; the entry script invokes the selected function through its
  `[scriptblock] $CommandFunction` seam (1020 plan), so the rows add no dynamic invocation.
- Only these three lines are inserted, directly under the anchor; no other line of the entry script
  changes. The bundle copy receives the same edit.

## 6. Finding Codes

| Code | Severity | Owner function | Condition |
|---|---|---|---|
| `DOCS_JSON_*`, `DOCS_SCHEMA_*` | error | 1020 | Parse and schema findings (1020 codes replace the Python `SCHEMA_INVALID`) |
| `DOCS_INPUT_UNREADABLE` | error | `Invoke-DocsValidation`, `Invoke-DocsCoverageCommand` | An artifact the mode needs is absent |
| `DOCS_SNAPSHOT_ELEMENT_INVALID` | error | `ConvertTo-DocsSnapshotView` | Element rebuild fails |
| `DOCS_LEDGER_MISSING_DISPOSITION` | error | `Get-DocsLedgerFinding` | Element without entry; message names kind, declaration, element id |
| `DOCS_LEDGER_DUPLICATE_ENTRY`, `DOCS_LEDGER_ORPHAN_ENTRY`, `DOCS_LEDGER_KIND_MISMATCH` | error | `Get-DocsLedgerFinding` | As named |
| `DOCS_LEDGER_BINDING_REQUIRED`, `DOCS_LEDGER_RATIONALE_REQUIRED`, `DOCS_LEDGER_OWNER_REQUIRED`, `DOCS_LEDGER_TARGET_REQUIRED` | error | `Get-DocsLedgerEntryCompanionFinding` | Companion rules (entries and precision-limit records) |
| `DOCS_LEDGER_SNAPSHOT_REF` | warning | `Get-DocsLedgerFinding` | `snapshot_ref.sha256` differs from the current snapshot bytes digest |
| `DOCS_LEDGER_ANALYSIS_METHOD_CHANGED` | warning | `Get-DocsLedgerFinding` | New (D3) |
| `DOCS_LEDGER_LIMIT_UNRECORDED` / `_DUPLICATE` / `_RESOLVED` | error / error / warning | `Get-DocsLedgerFinding` | New (D3) |
| `DOCS_MATRIX_LEDGER_REF` | warning | `Get-DocsMatrixFinding` | Ledger digest differs |
| `DOCS_MATRIX_UNBOUND_ROW`, `DOCS_MATRIX_ROW_MISSING`, `DOCS_MATRIX_DUPLICATE_ROW`, `DOCS_MATRIX_PIN_UNKNOWN`, `DOCS_MATRIX_ACCURACY_UNPINNED`, `DOCS_MATRIX_EXISTS_INCONSISTENT`, `DOCS_MATRIX_OWNER_INCONSISTENT` | error | `Get-DocsMatrixFinding` | Carried from the Python design; owner check uses the section 3.3 rule |
| `DOCS_PIN_INCONSISTENT` | error | `Get-DocsPinFinding` | Pin identity or `pin_id` derivation mismatch, duplicate `pin_id` |
| `DOCS_STALE_PAGE` | warning in `matrix`; in `docs-complete` error when stale pages exceed `max_stale_pages`, else warning | `Get-DocsStalenessFinding` | One per stale page |
| `DOCS_BOUND_PAGE_MISSING`, `DOCS_DEFERRED_NOT_ALLOWED`, `DOCS_PARITY_REQUIRED_DIMENSION`, `DOCS_SNAPSHOT_UNPINNED` | error | `Get-DocsCompletionGateFinding` | docs-complete gate |
| `DOCS_REVISION_MISMATCH` | error | `Invoke-DocsValidation` | Non-null snapshot revision differs from `-Revision` |
| `DOCS_UPDATE_TARGET_INVALID` | error | `Invoke-DocsUpdateLedgerCommand` | Target entry, binding, pin, element or limit absent |
| `DOCS_CLI_ARGUMENTS` | error (exit 2) | `Test-DocsUpdateLedgerArgument`, `Test-DocsValidateArgument`, 1020 parser | Usage error |
| `DOCS_CLI_RUNTIME` | error (exit 3) | entry boundary | Including `DOCS_CLOCK_NOT_UTC` and `DOCS_RECEIPT_INVALID` throws |
| `DOCS_MUTATION_FAILED` | error (exit 3) | `Invoke-DocsUpdateLedgerCommand`, `Invoke-DocsValidateCommand` | `conflict` or write failure |

## 7. Downstream Contracts

### 7.1 900007 (MCP wrappers)

- Invocation: `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command <name> -Json
  <options>` with the workspace root as working directory (1020 `## Decisions Later Children Must
  Honor`).
- `run_docs_coverage` -> `-Command coverage -Json [-Profile <p>]`.
- `update_docs_ledger` -> `-Command update-ledger -Json -Operation <op> -ActorKind <k> -ActorId <id>
  [-Element <id> | -Limit <id>] [-Disposition] [-Page <p> ...] [-Rationale] [-Owner] [-Target]
  [-Dimension] [-State] [-Claim] [-Write]`. Repeated `-Page` tokens form the `multi` value
  (UNVERIFIED in 1020 parser, section 9 item 3). It is the only mutating tool.
- `validate_docs_artifacts` -> `-Command validate -Json -Mode <m> -Revision <rev> [-Profile <p>]`;
  it never passes `-WriteReceipt`, so it is read-only in every mode.
- Pre-process input validation in TypeScript mirrors the section 5.1 grammars: `element-id`
  pattern, 40 or 64 lowercase hex revision, relative path, identifier, and the enumerations of
  operations, dispositions, dimensions, states, modes and actor kinds. The wrappers parse the
  envelope and surface `exit_code`, `findings` and `result` unchanged.

### 7.2 900008 (workflow and hook)

- Workflow: `pwsh -NoProfile -File .claude/lib/docs/Invoke-DocsCommand.ps1 -Command validate -Mode
  docs-complete -Revision <head> -WriteReceipt -Json`.
- Hook: reads the profile (default path), takes `artifact_paths.validation_receipt`, reads that
  file, and calls `Get-DocsReceiptGateDecision -ReceiptText -HeadRevision -ComposedSchemaSet`.
  Allow only when `Allow` is true; the deny text uses `Reason` (`receipt-missing` when the file is
  absent, `receipt-invalid`, `mode-not-docs-complete`, `result-fail`, `revision-mismatch`). Fields
  read: `artifact_kind`, `mode`, `validation_result`, `revision`, `id`.
- Head-revision note for 900008 (risk R5): a receipt committed to the branch changes the head
  revision it pins. 900008 must define which revision the hook compares (for example the revision
  validated before the receipt commit, or a receipt kept out of version control).

## 8. Testing Implications

### 8.1 Suites (`tests/scripts/claude-lib/docs/`, mirroring `tests/scripts/claude-lib/mermaid/`)

| Suite | Covers |
|---|---|
| `DocsLedger.Tests.ps1` | Snapshot view, entry and limit constructors, companion table, completeness, duplicates, orphans, kind mismatch, analysis-method warning, limit accounting, merge and removal |
| `DocsParity.Tests.ps1` | Row rules, owner consistency with the path rule, dimension merge, pin-id derivation, scoring |
| `DocsEvidencePins.Tests.ps1` | Pin identity, construction, consistency, merge, removal |
| `DocsStaleness.Tests.ps1` | Status table, stale pages, severity |
| `DocsReceipt.Tests.ps1` | Identifier, counts, construction validated by schema, timestamp formatter, gate decision reasons |
| `DocsValidation.Tests.ps1` | Mode layering, gate findings, revision rules, defect guard |
| `DocsLedgerMutation.Tests.ps1` | Plan statuses, dry run makes no scriptblock call, create, digest-checked overwrite, conflict stops, ascending order, partial-write reporting |
| `DocsLedgerCommands.Tests.ps1` | Each command with an in-memory context: exits 0/1/2/3, `-Json` envelope validated against the envelope schema, byte determinism, text summary line, per-operation argument rules, recording context proves zero writes for `coverage` and `validate` without `-WriteReceipt` |
| `DocsLedger.Properties.Tests.ps1` | Section 8.2 |
| `DocsWriteBoundary.Tests.ps1` | Section 8.3 |
| `DocsCompleteIntegration.Tests.ps1` | In-memory fixture with one undocumented element and one stale page: exit 1 naming both; after the entry is added and the pin re-pinned, exit 0 with a `pass` receipt |
| `DocsLedger.TestSupport.psm1` | In-memory context (path-to-bytes hashtable, recording `WriteText`, fixed `UtcNow` of `Kind` `Utc`), fixture builders |

Each suite imports modules with `-Force`, removes every `Docs*` module in `AfterAll`, and dot-sources
`Invoke-DocsCommand.ps1` only where the entry is exercised. Schemas come from the committed runtime
copies through 1020 `Read-DocsSchemaSet` (a read of committed files, not a temporary file). No
suite uses any token forbidden by `check-powershell-test-purity.ps1`.

### 8.2 Property tests (one per pure function)

Generation without new modules: `[System.Random]::new(<seed>)` with a fixed seed list (at least
three seeds) and the seed in every `-Because` message, or exhaustive enumeration of small domains
with nested loops. Each pure function in section 4 gets one property, for example:

- `Get-DocsPinStatus`: exhaustive {element present, absent} x {digest equal, different} x {revision
  equal, different} yields exactly the three statuses, revision never matters.
- `Get-DocsStalePage`: for seeded pin sets, a page is listed exactly when one of its pins is not
  `current`; output order is ordinal and invariant under input permutation.
- `Get-DocsLedgerEntryCompanionFinding`: exhaustive dispositions x presence of bindings, rationale,
  owner and target equals the companion table.
- `Get-DocsLedgerFinding`: for every subset of a fixed snapshot, missing-disposition findings name
  exactly the complement; permuting entries leaves findings and canonical JSON unchanged; for
  every subset of precision-limit diagnostics, `DOCS_LEDGER_LIMIT_UNRECORDED` names exactly the
  unrecorded ones.
- `Get-DocsReceiptId`: unchanged when only `issued_at`, `counts` or `findings` differ; changes when
  any of the five identity members differs.
- `Get-DocsScoreBasisPoint` and `Measure-DocsParityScore`: for seeded state assignments, counts sum
  to the row count and the score is an integer in [0, 10000] or null.
- `Get-DocsArtifactWritePlan`: output sorted ordinally and `skipped` exactly when the digest is
  unchanged, for seeded document sets.
- `Test-DocsPathOrGlobMatch` (if owned here): agreement with an enumerated table of exact, prefix,
  `*`, `?`, `[...]` and `[!...]` cases; first-match owner selection invariant under appending
  non-matching entries.
- Constructors (`New-*`): the result validates against its schema `$defs` for seeded valid inputs.

The planner enumerates every function marked pure in section 4 and maps each to one property; the
1024 preflight halt (epic `### Generator decisions from the first preparation of 1024`) is the
precedent this avoids.

### 8.3 Write-boundary proof

`DocsWriteBoundary.Tests.ps1` parses every `.ps1` and `.psm1` under `.claude/lib/docs/` with
`[System.Management.Automation.Language.Parser]::ParseFile` (read-only) and asserts:

- No filesystem write primitive (command names `Set-Content`, `Add-Content`, `Out-File`,
  `New-Item`, `Copy-Item`, `Move-Item`, `Remove-Item`, `Tee-Object`, `Export-Csv`, `Export-Clixml`;
  member calls on `System.IO.File`, `System.IO.FileStream`, `System.IO.StreamWriter`; file
  redirection) occurs anywhere except `Write-DocsFileText` in `Invoke-DocsCommand.ps1` (allowlist
  entry with reason "init create-only and explicit overwrite").
- The member name `WriteText` is accessed only in `Invoke-DocsCommand.ps1` (context construction),
  `DocsProfileCommands.psm1` (init, 1020) and, among 1023 modules, `DocsLedgerCommands.psm1`; a
  scriptblock named `WriteText` is invoked only inside `Invoke-DocsArtifactWrite`.
- `Invoke-DocsArtifactWrite` is referenced only from `DocsLedgerCommands.psm1`.
- A positive control: the scan helper reports a write call in an in-memory source string.

### 8.4 Coverage, isolation and CI

- Pester line coverage >= 85% per new production file, read from
  `artifacts/pester/powershell-coverage.xml` written by `Invoke-PoshQCTest`; no branch gate; no
  file excluded. Evidence under `<FEATURE>/evidence/qa-gates/` (the canonical kind 1020's plan
  also uses for coverage figures).
- Isolation: three seeded shuffled file-order runs of the docs suites in one process plus a fresh
  single-process run over `tests/scripts`, recorded under `<FEATURE>/evidence/regression-testing/`.
- CI: the suites run in `poshqc / PowerShell QC shard 1`, `shard 2` or `shard 3` on
  `windows-latest`, merged by the required `poshqc / PowerShell QC`; `poshqc / PowerShell QC static`
  runs format and PSScriptAnalyzer. `poshqc / PowerShell hook suites (Linux)` does not run them.
  Python contract tests (`test_push_down_claude_resource_contracts.py`,
  `test_push_down_pack_manifest_dependency_closure.py`) run in
  `quality-checks7 / Code Quality & Tests (3.10)` through `(3.13)`.

## 9. Infrastructure Facts for the Plan

- Pack manifest: append the eight module paths to
  `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` `paths`.
- Mirror: byte-identical copies under
  `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`, plus the same three-row
  edit in the bundle copy of `Invoke-DocsCommand.ps1`. Pinned by
  `test_push_down_claude_resource_contracts.py`, `test_push_down_pack_manifest_dependency_closure.py`
  (including `test_every_psscriptroot_occurrence_is_recognized`) and 1020's
  `Docs.Manifest.Tests.ps1`. `test_push_down_claude_pack_manifest_completeness.py` enumerates agents,
  hooks and skills only (1020 addendum section 6), so it does not cover lib files.
- No Codex mirror (1020 OQ-2 default: Claude bundle only).
- `quality-tiers.yml`: no edit (1020 adds `.claude/lib/docs` at T3). T3 carries no property-test
  density obligation; the property tests in section 8.2 are required by D1 and the 1024 precedent,
  not by the tier.
- File size: `DocsLedgerCommands.psm1`, `DocsValidation.psm1` and `DocsLedger.psm1` are the largest
  candidates. Pre-approved splits at the 500-line guidance: `DocsCoverageReport.psm1` (coverage
  report from `DocsLedgerCommands.psm1`) and `DocsLedgerRules.psm1` (rules from `DocsLedger.psm1`),
  each with its own suite, bundle copy and core entry.
- Batch budget: eight new production modules plus eight bundle copies plus the entry script and its
  bundle copy are well above the direct-mode cap of three; execution runs in the item worktree under
  a non-terminal `large`, `remediation` or `preparation` checkpoint, never in an isolated executor
  worktree.
- Execution starts after 1020 (including its D3/D5 amendment) merges into
  `epic/documentation-estate-tooling-integration`; the plan's first phase re-reads the merged 1020
  modules and schemas and records any renamed symbol before code is written.

## 10. Artifact Classification

Rules: R1 = language rule clause (1) (pushed-down skills, helpers, hooks and libs are PowerShell or
bash); R2 = clause (2) (TypeScript only for MCP and extension commands; no row uses it); D = epic
`### Artifact classes for this epic` (schema, configuration, data, test and documentation rows).
"Avoid new Python" applies to every row. B = `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/`.

| File | Change | Class | Language | Rule |
|---|---|---|---|---|
| `.claude/lib/docs/DocsLedger.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsParity.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsEvidencePins.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsStaleness.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsReceipt.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsValidation.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsLedgerMutation.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/DocsLedgerCommands.psm1` | create | pushed-down helper/lib | PowerShell | R1 |
| `.claude/lib/docs/Invoke-DocsCommand.ps1` | edit (three rows) | pushed-down helper/lib (entry) | PowerShell | R1 |
| B (eight module copies and the entry-script copy) | create / edit | pushed-down helper/lib (mirror) | PowerShell | R1 |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | edit | schema/config/data | JSON | D |
| `tests/scripts/claude-lib/docs/*.Tests.ps1` (section 8.1) and `DocsLedger.TestSupport.psm1` | create | test | PowerShell (Pester) | D |
| `docs/features/active/2026-10-30-docs-coverage-ledger-and-receipt-1023/**` | create / edit | documentation | Markdown | D |
| Pre-approved split modules (section 9), if used, and their copies | create | pushed-down helper/lib | PowerShell | R1 |

No hook, skill, agent, MCP tool, extension command, Python file, TypeScript file or schema file is
created or edited by 1023. Every artifact follows the language rule; no language owner question
arises. The schema changes 1023 depends on (sections 5.3, 3.2 and 3.3) belong to the 1020
amendment; if they are not made there, 1023 would edit `schemas/docs/v1/docs-coverage-ledger.schema.json`
and its runtime copies (data, rule D), which is a cross-child decision for the orchestrator (OQ-A).

## 11. Delta Versus the Withdrawn Python Design

| Python design (spec 0.2, plan `plan.2026-10-30T16-51.md`) | PowerShell design |
|---|---|
| `packages/docs-runtime/src/drm_copilot_docs/` modules (`ledger_models.py`, `ledger_rules.py`, `parity_*.py`, `evidence_pins.py`, `staleness.py`, `receipt.py`, `validation.py`, `mutation.py`, `coverage_report.py`, `snapshot_view.py`, `cli_support.py`, `cli_*.py`) | Eight `.claude/lib/docs/Docs*.psm1` modules; snapshot view in `DocsLedger`, coverage report in `DocsLedgerCommands`, CLI support in 1020 `DocsFinding` and the entry script |
| Console scripts `dev.docs.coverage`, `dev.docs.update-ledger`, `dev.docs.validate`; `pyproject.toml` edits | `Invoke-DocsCommand.ps1 -Command coverage|update-ledger|validate`; three dispatch rows; no `pyproject.toml` or `poetry.lock` change |
| `--format json`, `--write`, `--write-receipt`, `--operation` | `-Json`, `-Write`, `-WriteReceipt`, `-Operation` (PascalCase options) |
| Envelope `command` = console name; no envelope schema (Q4) | `command` = subcommand name; envelope validated against `docs-command-envelope.schema.json` (D5) |
| `drm_copilot_discovery` primitives imported (`Finding`, `FindingCollector`, `canonical_json`, `parse_document`, `stable_id`) | 1020 `DocsJson`, `DocsFinding`, `DocsSurface`, `DocsSchema` (which delegate to `DiscoveryEncoding.psm1`); no Python discovery runtime |
| `ArtifactStore` protocol, `LocalArtifactStore` with `O_EXCL` and `os.replace` | `Invoke-DocsArtifactWrite` over context `ReadBytes`, `TestFile`, `WriteText` (`create`/`overwrite`); digest re-check before overwrite |
| AST scan of Python modules for the write boundary | PowerShell AST scan of `.claude/lib/docs/` (section 8.3) |
| Property tests with `itertools`; line 85% and branch 75% | Seeded `[System.Random]` or enumeration in Pester; line 85%, no branch gate (Pester) |
| YAML profile accepted | JSON only (1020) |
| Written bytes `canonical_json` | Files `ConvertTo-DocsJsonText -Indented`; canonical JSON for digests, identifiers and the envelope |
| `fnmatch.fnmatchcase` owner match | Section 3.3 translator with the epic first-match rule |
| Receipt persisted in any mode | `-WriteReceipt` only with `docs-complete` |
| No `analysis_method`; no precision-limit concept | `entries[].analysis_method`; `precision_limits[]` deferred records; four new finding codes |
| Element digest open question (Q1) | Declaration-lines digest (D5), compared as opaque |
| `DOCS_SNAPSHOT_UNPINNED` as assumption A-1 | Owner decision D5 |
| T2 classification and property-test density | T3 (1020); property tests kept by D1 |
| Tests under `tests/docs_runtime/` | `tests/scripts/claude-lib/docs/` |
| Hook consumption described only as field checks | Pure `Get-DocsReceiptGateDecision` for 900008 |

## 12. Risks

- R1: the 1020 amendment may not add `precision_limits`, the diagnostic flag, or `analysis_method`
  in the shapes proposed; 1023 cannot meet D3 without them. Mitigation: confirm before the 1023 plan
  is written (Items to Confirm).
- R2: 1020 appends a `FINDINGS_LIMIT` finding with severity `error` when truncating. More than 100
  warnings (for example many `DOCS_STALE_PAGE` warnings) would then put an `error` finding into a
  `pass` receipt, which the receipt schema rejects (defect guard, exit 3). Mitigation requested from
  1020: give `FINDINGS_LIMIT` the highest severity among the dropped findings; 1023 computes the exit
  code and `validation_result` from the unbounded set.
- R3: check-then-write window between the digest re-check and `WriteText 'overwrite'`; and whether
  `create` fails when the file exists depends on `Write-DocsFileText` (UNVERIFIED). Accepted for a
  local single-writer command; recorded in the spec.
- R4: case-insensitive PowerShell defaults (section 4 ordinal rule) can reorder output or match
  paths across case; property tests over mixed-case inputs catch it.
- R5: 900008 head-revision semantics for a committed receipt (section 7.2).
- R6: with `allow_deferred` false and no native analyzer for TypeScript or C# in the first release,
  any scanner precision-limit diagnostic blocks `docs-complete` permanently for those stacks (OQ-B).

## Numeric Derivation Evidence

Record 1 - new production modules (spec narrative and classification count).

- Complete Family: DocsLedger.psm1, DocsParity.psm1, DocsEvidencePins.psm1, DocsStaleness.psm1, DocsReceipt.psm1, DocsValidation.psm1, DocsLedgerMutation.psm1, DocsLedgerCommands.psm1
- Exhaustive Search Scope: every production PowerShell file 1023 creates under `.claude/lib/docs/`, excluding the conditional split modules of section 9
- Inclusion Rules: `.psm1` files created by 1023 under `.claude/lib/docs/`
- Exclusion Rules: the edited entry script, bundle copies, test files and test-support modules, conditional split modules, 1020 modules
- Primary Search Strategy or Query Expression: the epic `### 1023 - docs-coverage-ledger-and-receipt (wave 1, C4)` Files (create) list
- Primary Member Set: DocsLedger.psm1, DocsParity.psm1, DocsEvidencePins.psm1, DocsStaleness.psm1, DocsReceipt.psm1, DocsValidation.psm1, DocsLedgerMutation.psm1, DocsLedgerCommands.psm1
- Primary Count: 8
- Cross-check Search Strategy or Query Expression: the module rows of this addendum's section 4.1 import-graph table
- Cross-check Member Set: DocsLedger.psm1, DocsParity.psm1, DocsEvidencePins.psm1, DocsStaleness.psm1, DocsReceipt.psm1, DocsValidation.psm1, DocsLedgerMutation.psm1, DocsLedgerCommands.psm1
- Cross-check Count: 8
- Member-set Comparison: the normalized sets are equal (same eight file names).

Record 2 - dispatch rows added to `Invoke-DocsCommand.ps1`.

- Complete Family: subcommands owned by 1023
- Exhaustive Search Scope: the epic `### Naming contract (fixed for all children)` subcommand-owner list and the 1020 `spec.md` dispatch-table anchors
- Inclusion Rules: subcommands assigned to 1023
- Exclusion Rules: subcommands of 1020, 1021, 1022, 1024 and 900008
- Primary Search Strategy or Query Expression: epic text "`coverage`, `update-ledger`, `validate` (1023)" in `### Naming contract (fixed for all children)`
- Primary Member Set: coverage, update-ledger, validate
- Primary Count: 3
- Cross-check Search Strategy or Query Expression: the 1020 `spec.md` anchor comment `# --- 1023: coverage, update-ledger, validate ---` in `#### Dispatch table`
- Cross-check Member Set: coverage, update-ledger, validate
- Cross-check Count: 3
- Member-set Comparison: equal.

Record 3 - `update-ledger` operations.

- Complete Family: operations of the `update-ledger` subcommand
- Exhaustive Search Scope: epic `### Command contract decisions from the first preparation of 1023` and the 1023 `spec.md` (version 0.2) `--operation` table
- Inclusion Rules: operation names
- Exclusion Rules: option names
- Primary Search Strategy or Query Expression: epic list "(`set-disposition`, `remove-entry`, `pin`, `unpin`, `set-dimension`, `sync-refs`)"
- Primary Member Set: set-disposition, remove-entry, pin, unpin, set-dimension, sync-refs
- Primary Count: 6
- Cross-check Search Strategy or Query Expression: rows of the per-operation table in 1023 `spec.md` `### dev.docs.update-ledger`
- Cross-check Member Set: set-disposition, remove-entry, pin, unpin, set-dimension, sync-refs
- Cross-check Count: 6
- Member-set Comparison: equal.

Record 4 - `validate` modes.

- Complete Family: modes of the `validate` subcommand
- Exhaustive Search Scope: epic `### 1023` and `### Command contract decisions ...`; 1020 receipt schema `mode` enum
- Inclusion Rules: mode values
- Exclusion Rules: none
- Primary Search Strategy or Query Expression: epic text "modes `profile`, `ledger`, `matrix`, `docs-complete`"
- Primary Member Set: profile, ledger, matrix, docs-complete
- Primary Count: 4
- Cross-check Search Strategy or Query Expression: 1020 `spec.md` `### Artifact schema: docs-validation-receipt` `mode` enum
- Cross-check Member Set: profile, ledger, matrix, docs-complete
- Cross-check Count: 4
- Member-set Comparison: equal.

Record 5 - pin states.

- Complete Family: statuses returned by `Get-DocsPinStatus`
- Exhaustive Search Scope: epic `### Command contract decisions ...` and 1023 `spec.md` (version 0.2) `### Staleness`
- Inclusion Rules: status values
- Exclusion Rules: page-level stale flag
- Primary Search Strategy or Query Expression: epic text "Pin states: `current`, `digest-changed`, `element-missing`"
- Primary Member Set: current, digest-changed, element-missing
- Primary Count: 3
- Cross-check Search Strategy or Query Expression: the three bullets under `staleness.assess_pin` in 1023 `spec.md` `### Staleness`
- Cross-check Member Set: element-missing, digest-changed, current
- Cross-check Count: 3
- Member-set Comparison: equal after ordinal sorting.

## Pre-Mortem

- Review checklists: a reviewer can flag `& $Context.<Member>` in a command module, a pure function with a state-changing verb and no suppression, a culture-sensitive sort, or a production file excluded from coverage; the plan must carry the dynamic-invocation constraint, the verb rule, the ordinal rule, `DocsWriteBoundary.Tests.ps1`, and a self-review row per spec and user-story criterion.
- Coverage: `DocsLedgerCommands.psm1` I/O paths and `Invoke-DocsArtifactWrite` failure branches could fall below 85% line coverage; the plan must drive every exit code and every write status through the in-memory context, inject a throwing `WriteText` and `ReadBytes`, and read per-file figures from `artifacts/pester/powershell-coverage.xml` (no branch gate for Pester).
- Mirror parity: each new module and the edited entry script must be in `core.json` and byte-identical in the bundle; the plan must run `test_push_down_claude_resource_contracts.py`, `test_push_down_pack_manifest_dependency_closure.py` and `Docs.Manifest.Tests.ps1`; no execution-environment brief fact changes (no CI job, required context, tool route or batch-budget rule), so no brief-update task is needed.
- File size: `DocsLedgerCommands.psm1`, `DocsValidation.psm1` and `DocsLedger.psm1` can pass the 500-line guidance; the plan must use the pre-approved splits in section 9 with their own suites, bundle copies and core entries, and record logical line counts.
- Test isolation: dot-sourcing the entry script and `-Force` imports leave `Docs*` and `DiscoveryEncoding` modules in the session; the plan must remove them in `AfterAll`, keep no module-scope state, use only in-memory contexts, and record three seeded shuffled file-order runs plus a fresh single-process run over `tests/scripts`.
- CI-only behavior: `Test-Json` behavior on the `windows-latest` PowerShell version, and the envelope schema validation path, are proven only in `poshqc / PowerShell QC`; tests must assert finding codes and pointers rather than `Test-Json` message text, must not read gitignored `artifacts/` state, and must use forward-slash relative paths with `Join-Path`.
- Evidence: artifacts outside `<FEATURE>/evidence/<kind>/` (including a spec reference to `evidence/coverage/`), plan-time stamps, host paths or the restricted consumer tokens fail review; the plan must use write-time UTC stamps, record `SCRATCH`, place coverage figures under `evidence/qa-gates/`, and run the forbidden-token scan with bracket-class patterns over every changed file.

## Rejected Alternatives (summary)

- Generalized ledger subject identifiers, precision limits in `extensions`, and per-analyzer limit
  records as the default (section 3.1).
- Registry-declared precision-limit codes as the primary rule (section 3.2; kept as fallback).
- Duplicated or 1023-owned path matching (section 3.3).
- Persisting receipts of every mode (section 3.4).
- A second filesystem write primitive in 1023 or reuse of Python discovery mutation code
  (section 3.5).
- `-like`/`[WildcardPattern]` for globs (escaping and negation differ from the epic rule).

## Owner Questions

- OQ-A - Precision-limit records. Option A (selected): ledger `precision_limits[]` keyed by
  diagnostic `id` (per analyzer, code and file), added by the 1020 amendment. Alternative: one
  record per scanner analyzer. If the 1020 amendment is not reopened, 1023 would edit the ledger
  schema and its runtime copies itself.
- OQ-B - Deferred gate for precision limits. Provisional default: the same `allow_deferred` flag
  governs deferred entries and precision-limit records (epic "per the deferred rules"). Consequence:
  with `allow_deferred` false, TypeScript and .NET repositories cannot pass `docs-complete` while the
  baseline scanner reports precision limits. Alternative: a separate profile flag (1020 schema
  change).
- OQ-C - Receipt counts. Provisional default: receipt `counts` unchanged; `by_analysis_method` and
  precision-limit totals appear only in the `coverage` report. Alternative: the amendment adds them
  to the receipt `counts`.
- OQ-D - `-WriteReceipt` restricted to `docs-complete` (section 3.4). Provisional default: yes.
- OQ-E - Ownership of `Test-DocsPathOrGlobMatch` and `Get-DocsPageOwner`. Provisional default: 1020
  amendment; fallback: 1023 owns them in `DocsParity.psm1`, and 1024 gains a dependency on 1023.

No language owner question arises: every 1023 artifact is PowerShell, JSON or Markdown in its
permitted class.

## Items for the Orchestrator to Confirm (UNVERIFIED)

1. The content of the 1020 D3/D5 amendment, which is not visible in this worktree: the field name
   and position of `analysis_method` on snapshot elements and ledger entries; whether the
   declaration-lines digest keeps the name `source_sha256`; the `docs-command-envelope.schema.json`
   shape (whether `command` is an enum or a pattern, and whether `result` is unconstrained); and how
   a test validates an envelope (a `Test-DocsArtifactText` kind, a separate function, or a schema
   table entry outside `docs-artifact-kind`).
2. Whether the amendment adds the diagnostic precision-limit flag (section 3.2 A) and the ledger
   `precision_limits` array (section 5.3), or OQ-A falls back to a 1023 schema edit.
3. 1020 `ConvertFrom-DocsCommandArgument` behavior for a `multi` option given as repeated tokens,
   and whether value-grammar errors detected inside a command function before any read may return
   exit 2 through `New-DocsCommandResult` (1020 `spec.md` allows `ExitCode` 2; the parser itself
   knows only option kinds).
4. How 1020 command functions obtain the composed schema set (`Read-DocsSchemaSet` defaults or a
   context member), so 1023 uses the same route.
5. Whether `Write-DocsFileText` mode `create` fails when the file exists (for example
   `FileMode.CreateNew`), and whether `overwrite` is atomic.
6. 1020 `Get-DocsOrderedFinding` `FINDINGS_LIMIT` severity (risk R2) and whether 1020 will change it.
7. The 1022 and 900004 re-preparations: the scanner diagnostic codes for unclassified constructs,
   and that they set the precision-limit flag and `analysis_method: scanner`. The 1022 folder in this
   worktree still describes the Python design; no 900011 folder exists here.
8. Ownership of the path-matching functions (OQ-E) and alignment with the 1024 re-preparation.
9. The PowerShell version on the `windows-latest` runner used by the `poshqc` shards (carried from
   1020's items).
10. That 1020 (with the amendment) has merged into `epic/documentation-estate-tooling-integration`
    before 1023 execution; `.claude/lib/docs/` is absent in this worktree.
11. The delegated file name ends in `-powershell-addendum.md`, not `-research.md`; if
    `.claude/hooks/validate-task-researcher-output.ps1` requires the `-research.md` suffix, the file
    may need renaming, and `spec.md` should cite the final path.
