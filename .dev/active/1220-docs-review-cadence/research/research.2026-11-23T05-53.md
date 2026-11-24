# docs-review-cadence (Issue #1220) - Research

- Issue: #1220 (epic #1217, wave 2)
- Branch: feature/docs-review-cadence-1220
- Written: 2026-11-23T05-53 UTC. The task-researcher persona has no shell clock; the value was read from the timeapi.io UTC endpoint immediately before the write. The orchestrator may confirm it against the commit time.
- Inputs read: `issue.md`, `spec.md` (template draft), `plan.2026-11-23T00-39.md` (template draft), `.dev/epics/documentation-estate-families/epic.md` `## Shared Design`, `.dev/potential/promoted/2026-11-23-documentation-estate-families-epic.md`.
- Upstream features docs-family-profile-model, docs-family-gate-and-ia and docs-family-page-templates have no feature folder and no code on this branch (verified: no `.dev/active/*family*` folder; no `required_families`, `review_interval_days` or `legacy_exclusions` in `.claude/`).

## Decision Record (autonomous mode)

| ID | Decision | Reason |
|---|---|---|
| D1 | The overdue check is evaluated in the docs-complete layer of `Invoke-DocsValidation` (`DocsValidation.psm1`), not in `DocsCompleteGate.psm1`. `DocsCompleteGate.psm1` is not changed. | `DocsCompleteGate.psm1` holds only the pure predicates of the merge-gate hook `enforce-docs-complete-gate.ps1` (profile switch, receipt path, integration target, persisted receipt check). It never sees page findings. "docs-complete" findings are produced by `Get-DocsCompletionGateFinding` / `Invoke-DocsValidation`. A blocking overdue finding is an `error`, the receipt records `validation_result: fail`, and the hook then denies with `RECEIPT_FAILING`, so blocking reaches the merge gate without editing the hook module. The epic AC "fails docs-complete" refers to `validate -Mode docs-complete`. |
| D2 | The overdue finding is not added to the `check` command. The ordering validation (`review_due` later than `last_reviewed`) is added to the page checker. | `DocsPageCheck.psm1` documents that `Invoke-DocsCheckCommand` "never reads Context.UtcNow", and `tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1` replaces `UtcNow` with `{ throw 'check must not read the clock' }`. Ordering needs no clock. |
| D3 | The clock instant is the one `Invoke-DocsValidateCommand` already reads (`Get-DocsLedgerCommandTimestamp -UtcNow $Context.UtcNow` -> `IssuedAt`). The reference date is the UTC calendar date of `IssuedAt`. No second clock read. | The receipt `issued_at` and the overdue evaluation then refer to one instant. `ConvertTo-DocsTimestampText` (`DocsReceipt.psm1`) already rejects a non-UTC clock with `DOCS_CLOCK_NOT_UTC`. |
| D4 | Profile key: `completion_gates.docs_complete.block_overdue_review` (optional boolean). Absent or `false` = warning; `true` = error. Not added to `New-DocsStarterProfile`. | Matches the boolean style of `allow_deferred`; optional keeps every existing profile, example and starter-profile test valid. The `docs_complete` object has `additionalProperties: false`, so the key must be declared in `docs-profile.schema.json`. |
| D5 | Overdue is strict: a page is overdue when its effective due date is earlier than the reference date. A due date equal to the reference date is not overdue. Ordering is strict: `review_due` must be later than `last_reviewed`. | Same semantics as the reference implementation (`rgf-forecast` `src/dev_tools/docs_check/frontmatter.py` `_validate_dates`: `review_due <= last_reviewed` is a violation, `review_due < today` is overdue). |
| D6 | Family lookup is defensive and optional: when the profile has no `required_families` array, or no family directory covers the page, or the family has no positive integer `review_interval_days`, the page has no derived due date and produces no overdue finding. | Upstream code is absent; the feature must pass its own tests before and after the upstream merge. |
| D7 | The reference generator preserves `review_due` (`DocsReferenceFrontMatter.psm1`). | Related defect inside the item: `Resolve-DocsReferenceFrontMatterValue` copies only owner, last_reviewed, audience, title and extensions, and `ConvertTo-DocsReferenceFrontMatterText` writes a fixed key list, so regenerating a reference page would silently drop `review_due`. |
| D8 | No TypeScript change. | Verified in section 8. |

## 1. Front Matter Today

- Parser: `ConvertFrom-DocsPageFrontMatter` (`DocsPageFrontMatter.psm1`) returns `@{ Present; Terminated; Value; FieldLine; BodyStartLine; Findings }`; `Value` is an ordinal hashtable. It accepts any key name (`$script:DocsPageKeyPattern`); it has no field list. Parse codes: `DOCS_PAGE_FRONT_MATTER_UNTERMINATED`, `_SYNTAX`, `_UNSUPPORTED`, `_DUPLICATE_KEY`, all `error`.
- Field enum (the closed set of page fields): `.claude/lib/docs/schemas/v1/page-metadata.schema.json` `properties` (`owner`, `last_reviewed`, `audience`, `diataxis_mode`, `surface_refs`, `title`, `extensions`) with `additionalProperties: false`. An unlisted key becomes `DOCS_SCHEMA_PROPERTY_UNKNOWN`, mapped to `DOCS_PAGE_FIELD_UNKNOWN` by `ConvertTo-DocsPageFieldFinding`. Adding `review_due` therefore requires a schema property; without it every page carrying `review_due` fails.
- Profile-side field enum: `common.schema.json` `$defs/front-matter-field` (`enum: owner, last_reviewed, audience, diataxis_mode, surface_refs`), used by `docs-profile.schema.json` `diataxis_policy.required_front_matter`. Adding `review_due` lets a profile require the field.
- `last_reviewed`: schema `$ref` `common#/$defs/review-date` = `{"type":"string","pattern":"^[0-9]{4}-[0-9]{2}-[0-9]{2}$"}`. Pattern mismatch maps through `$script:DocsPageFieldCode['last_reviewed']` to `DOCS_PAGE_LAST_REVIEWED_INVALID`. Calendar check: `Get-DocsPageValueFinding` reads the pattern from the composed schema (`Get-DocsPageFieldPattern`) and calls `Test-DocsPageReviewDate` (`[datetime]::TryParseExact(..., 'yyyy-MM-dd', InvariantCulture)`), emitting `DOCS_PAGE_LAST_REVIEWED_NOT_A_DATE`. Next actions live in `$script:DocsPageFieldNextAction`.
- Validation order (`Test-DocsPageFrontMatter`): required fields (`DOCS_PAGE_FIELD_MISSING`), schema gate `Test-DocsArtifactText -ArtifactKind 'page-metadata'`, `Get-DocsPageConstraintFinding` (pattern/minLength/uniqueItems), `Get-DocsPageValueFinding` (calendar + audience), field mapping, fail-closed `DOCS_PAGE_FRONT_MATTER_SCHEMA_INVALID`; result ordered by `Get-DocsOrderedFinding`.
- Finding shape: `New-DocsFinding` (`DocsFinding.psm1`) returns an ordered dictionary with exactly `code` (`^[A-Z][A-Z0-9_]*$`), `severity` (`error|warning|info`), `artifact_path` (relative POSIX or null), `pointer` (RFC 6901), `related_ids`, `related_paths`, `message`, `next_action`. Severity model: any `error` makes `Test-DocsFindingHasError` true -> exit 1 / receipt `fail`; `warning` and `info` never fail.
- How page checks are reached: `Invoke-DocsCheckCommand` (`DocsPageCheck.psm1`) -> `Get-DocsPageCheckFinding` -> per page `Get-DocsPageFieldRuleFinding` -> `Test-DocsPageFrontMatter`. The reference generator reaches `Test-DocsPageFrontMatter` through `ConvertFrom-DocsReferencePageText` (`DocsReferenceFrontMatter.psm1`), mapping every code to `REFERENCE_FRONT_MATTER_INVALID`. `Get-DocsLedgerPageReference` (`DocsLedgerBindRefs.psm1`) parses front matter (no validation) for `surface_refs`.
- `validate` does not read page text today: `Read-DocsLedgerInputSet` returns only the page-path list (`page-path-set`).

## 2. Docs-Complete Evaluation and the Profile

- `Invoke-DocsValidation` (`DocsValidation.psm1`) runs layered modes (`profile`, `ledger`, `matrix`, `docs-complete`). In `docs-complete` it reads `completion_gates.docs_complete` and calls `Get-DocsCompletionGateFinding`: `DOCS_SNAPSHOT_UNPINNED`, `DOCS_DEFERRED_NOT_ALLOWED` (unless `allow_deferred`), `DOCS_PARITY_REQUIRED_DIMENSION`, `DOCS_BOUND_PAGE_MISSING`, and `DOCS_STALE_PAGE` (error when count > `max_stale_pages`, else warning). Pass/fail = no `error` in the unbounded finding set; the receipt is built by `New-DocsValidationReceipt` and schema-guarded (`DOCS_RECEIPT_INVALID`).
- The option is read at the same place `allow_deferred` and `max_stale_pages` are read: the `$Gate` dictionary (`completion_gates.docs_complete`), through `Get-DocsValidationMember`.
- `DocsCompleteGate.psm1` (`Get-DocsCompleteGateEnabled`, `Get-DocsCompleteGateReceiptPath`, `Test-DocsCompleteGateIntegrationTarget`, `Test-DocsCompleteGateReceipt`) is imported only by `.claude/hooks/enforce-docs-complete-gate.ps1`; it reads `completion_gates.integration_pr_gate.enabled` and the receipt `validation_result`. It must keep importing only `DocsJson`, `DocsSurface`, `DocsReceiptRevision` (hook dependency-guard rule in its header).
- Profile load: `ConvertFrom-DocsProfileText` (`DocsProfile.psm1`) -> `Test-DocsArtifactText -ArtifactKind 'docs-profile'` against the composed `docs-profile.schema.json`, then `Test-DocsProfileSemantic`. Unknown keys are rejected by the schema (`additionalProperties: false` on the root, `completion-gates`, and `docs_complete`), reported as `DOCS_SCHEMA_PROPERTY_UNKNOWN` by the schema walk; a schema finding returns `Profile = $null`.
- Upstream note: the epic Shared Design says docs-family-gate-and-ia "Consumes the family record and legacy list in DocsCompleteGate, receipt, coverage report". If that feature puts its family check into `Get-DocsCompletionGateFinding`, the overdue call placed directly after the `Get-DocsCompletionGateFinding` loop in `Invoke-DocsValidation` satisfies "after the family check". If it instead edits `DocsCompleteGate.psm1`, D1 still holds because the overdue outcome reaches the hook through the receipt.

## 3. Clock Reads and Seams

- Only wall-clock read in the docs lib: `New-DocsCommandContext` in `Invoke-DocsCommand.ps1` (`$utcNow = { [datetime]::UtcNow }`, member `UtcNow`). No `Get-Date`, `[datetime]::Now` or `DateTimeOffset` elsewhere under `.claude/lib/docs` (Grep over the folder).
- Consumers of the seam: `DocsInventory.psm1` (`Invoke-DocsContextMember -Member $Context.UtcNow`), `DocsLedgerCommands.psm1` `Get-DocsLedgerCommandTimestamp` (used by update-ledger and by `Invoke-DocsValidateCommand`), `ConvertTo-DocsTimestampText` in `DocsReceipt.psm1` (UTC-kind guard, `yyyy-MM-dd'T'HH:mm:ss'Z'`).
- Test seams: `New-DocsLedgerTestContext -UtcNow <datetime>` (`tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1`, default 2026-03-01T12:00:00Z) and `Docs.TestSupport.psm1` (default 2026-01-01T00:00:00Z) build in-memory contexts with a fixed clock. `DocsReferenceBoundary.Tests.ps1` forbids `Get-Date` in reference modules. Reuse these; no new seam is needed.

## 4. Page-to-Family Resolution

- Current branch: no family concept exists. `documentation_roots[]` (`id`, `path`, `audience_ids`) and `diataxis_policy.directory_modes[]` (`path_or_glob`, `mode`) are the only path mappings.
- Shared Design: a family record carries `directory` and `review_interval_days`; the page template id is the family `template`. No front-matter family field is defined, so the family is resolved from the page path against `directory`.
- Safe design: `Get-DocsReviewIntervalDays -PagePath -Family` selects the family whose `directory` (trailing `/` trimmed) equals the page's directory prefix at a `/` boundary (`page.StartsWith("$dir/", Ordinal)`), longest directory wins, ordinal comparison; returns the family's `review_interval_days` when it is an integer >= 1, otherwise `$null`. `directory` is assumed repository-relative, like `documentation_roots[].path`. The family list is read with `Get-DocsValidationMember -Table $profileDocument -Name 'required_families'`; absent -> empty list -> no derived due dates. A page listed in `legacy_exclusions[].path` (when present) is skipped.
- Risk to verify at the upstream rebase: if docs-family-profile-model defines `directory` relative to a documentation root, the matcher joins it with each root path. The plan carries a rebase task that reads the merged `docs-profile.schema.json` and adjusts the matcher and its tests in the same change.

## 5. Copies, Mirrors and Contract Tests

| File | Copies | Owner |
|---|---|---|
| `.claude/lib/docs/*.psm1` (DocsPageMetadata, DocsPageFrontMatter, DocsValidation, DocsValidateCommands, DocsReferenceFrontMatter, new DocsReviewCadence) | source + `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` | hand-edited, byte-identical; not generated; no `.codex/lib` or `.agents` copy |
| `page-metadata.schema.json`, `common.schema.json`, `docs-profile.schema.json` | `schemas/docs/v1/` (canonical), `.claude/lib/docs/schemas/v1/` (runtime), claude bundle copy | hand-edited, byte-identical |
| `docs-author-page/templates/*.md` | `.agents/skills/` (source), `.claude/skills/` (generated), both bundle copies | `scripts/harness-generation/HarnessSkillMirror.psm1` renders every file of `.agents/skills/docs-author-page/` to `.claude/skills/docs-author-page/` and the bundle (matrix entry `claude:skill:docs-author-page`, `generated`, `owner_child` 3). Edit the `.agents` source and run `Invoke-HarnessGeneration.ps1`. Copilot copy is `dropped`. |
| `docs-author-page/SKILL.md` (step 1 placeholder list) | same four locations; `scripts/harness-generation/sources/skills/docs-author-page.substitutions.json` substitutes three SKILL.md strings, none in step 1 | generator |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | lists every docs lib file | hand-edited |

Pinning tests: `tests/scripts/claude-lib/docs/Docs.Manifest.Tests.ps1` (every docs lib file in `core.json`, bundled byte-identically), `DocsSchemaContract.Tests.ps1` (runtime schema set byte-identical to `schemas/docs/v1`), `DocsPageMetadataSchema.Tests.ps1` (runtime copy hash; "defines exactly the seven page-metadata properties" -> must become eight with `review_due`), `tests/scripts/claude-runtime/docs-authoring-roles.Templates.Tests.ps1` (32 rows; exact key set `audience, diataxis_mode, last_reviewed, owner, surface_refs`; checker pass after placeholder substitution), `DocsReferenceFrontMatter.Tests.ps1` and `.Properties.Tests.ps1` (`$script:FieldOrder`), `DocsWriteBoundary.Tests.ps1` (scans every lib file for write primitives; a pure new module passes), `HarnessGeneration.RepoGate.Tests.ps1`, the push-down Python contract tests (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`).

## 6. Tests and File Sizes

Line counts below are the physical line totals the Read tool reported (logical counts are equal or one lower); the orchestrator may confirm with `wc -l`. None is in `config/file-size-baseline.json`.

| Production file | Lines | Tier | Existing tests (lines) |
|---|---|---|---|
| `DocsPageFrontMatter.psm1` | 426 | < 500 | `DocsPageFrontMatter.Tests.ps1` (543) |
| `DocsPageMetadata.psm1` | 303 | < 500 | `DocsPageMetadata.Tests.ps1` (201), `DocsPageMetadataSchema.Tests.ps1` (150) |
| `DocsPageCheck.psm1` | 434 | < 500 | `DocsPageCheck.Tests.ps1` (697, near the 700 advisory tier), `.LinkMap`, `.MalformedLink` |
| `DocsValidation.psm1` | 367 | < 500 | `DocsValidation.Tests.ps1` (493), `DocsValidation.Properties.Tests.ps1` |
| `DocsValidateCommands.psm1` | 250 | < 500 | `DocsValidateCommands.Tests.ps1` (520) |
| `DocsProfile.psm1` | 237 | < 500 | `DocsProfile.Tests.ps1` (185) |
| `DocsCompleteGate.psm1` | 208 | < 500 | `DocsCompleteGate.Tests.ps1` (241) |
| `DocsReferenceFrontMatter.psm1` | 291 | < 500 | `DocsReferenceFrontMatter.Tests.ps1` (364), `.Properties.Tests.ps1` |
| `DocsStaleness.psm1` | 151 | < 500 | `DocsStaleness.Tests.ps1`, `.Properties.Tests.ps1` (unchanged) |
| `Invoke-DocsCommand.ps1` | 625 | 500-700 guidance | not changed |
| `DocsSchemaContract.Tests.ps1` | 316 | - | - |

New tests go into new files (`DocsReviewCadence.Tests.ps1`, `DocsValidation.ReviewCadence.Tests.ps1`, `DocsValidateCommands.ReviewCadence.Tests.ps1`) so `DocsPageFrontMatter.Tests.ps1`, `DocsValidateCommands.Tests.ps1` and `DocsPageCheck.Tests.ps1` do not grow toward 700.

## 7. Reference Behavior (rgf-forecast, read-only)

- Templates (`docs/production-documentation/_templates/*.md`) carry `last_reviewed: <last-reviewed-date>` on line 3 and `review_due: <review-due-date>` on line 4: distinct placeholders, `review_due` directly after `last_reviewed`. Pages carry both (for example `admin/README.md`: 2026-07-16 / 2026-10-16).
- `frontmatter.py` `_validate_dates`: both fields strict `YYYY-MM-DD` calendar dates; `review_due <= last_reviewed` is a blocking violation; `review_due < today` is a report-level finding that never fails the check; no finding when `today` is `None`. The module reads no clock; `cli.py` supplies `today` (`date.today()` only at the CLI entry, injectable), and `scan.py` passes it through.
- `.docs-check.json` holds governed trees and an excluded list (templates, legacy pages); excluded paths are outside every docs gate.
- Emulate: strict ordering, strict overdue, overdue as warning by default, injected date at the entry point, distinct template placeholders. Differences by design: drm-copilot derives a default due date from the family interval and allows a profile switch to blocking.

## 8. MCP TypeScript

`extensions/drm-copilot/src/repo-automation-execute-docs.ts` `invokeDocsCommand` runs the workspace `.claude/lib/docs/Invoke-DocsCommand.ps1 -Command <sub> -Json <options>`; `mcp-tool-inputs-docs.ts` maps `validate_docs_artifacts` to `validate` with only `profile`, `mode`, `revision`. The option is profile data and the clock is read inside `Invoke-DocsCommand.ps1`, so no TypeScript parameter, table row or jest threshold changes. `packages/mcp-server/src` does not exist in this worktree. Branch edits to the docs lib apply through MCP immediately (execution-environment brief, MCP section).

## 9. Recommended Design

### Schema

- `page-metadata.schema.json`: add `"review_due": {"$ref": "urn:drm-copilot:docs:1.0.0:common#/$defs/review-date"}` after `last_reviewed`.
- `common.schema.json`: `front-matter-field` enum adds `review_due` after `last_reviewed`.
- `docs-profile.schema.json`: `completion-gates.docs_complete.properties` adds `"block_overdue_review": {"type": "boolean"}` (not in `required`).
- Each change in all three copies (`schemas/docs/v1`, runtime, bundle).

### `DocsPageMetadata.psm1` (ordering and calendar)

- `$script:DocsPageFieldCode['review_due'] = 'DOCS_PAGE_REVIEW_DUE_INVALID'`.
- Next actions: `DOCS_PAGE_REVIEW_DUE_INVALID` ("Set review_due to a YYYY-MM-DD date string."), `DOCS_PAGE_REVIEW_DUE_NOT_A_DATE` ("Set review_due to a calendar date that exists."), `DOCS_PAGE_REVIEW_DUE_NOT_AFTER_LAST_REVIEWED` ("Set review_due to a date later than last_reviewed.").
- `Get-DocsPageValueFinding`: add the `review_due` calendar check (same pattern read from the schema) and, when both dates are valid calendar dates, emit `DOCS_PAGE_REVIEW_DUE_NOT_AFTER_LAST_REVIEWED` at `/review_due` when `review_due <= last_reviewed`. Extract a private helper `Get-DocsPageReviewDateFinding` to keep the function short. All `error`.
- `DocsPageFrontMatter.psm1`: docstring of `Test-DocsPageFrontMatter` updated ("the review-date calendar and ordering checks"); no code change.

### New module `DocsReviewCadence.psm1` (pure; imports DocsFinding, DocsPageFrontMatter)

- `ConvertFrom-DocsReviewDate -Value [string]` -> `[Nullable[datetime]]` (UTC-kind date from `yyyy-MM-dd`, `$null` when invalid).
- `Get-DocsReviewReferenceDate -IssuedAt [string]` -> `[datetime]` (date part of `yyyy-MM-ddTHH:mm:ssZ`; throws `DOCS_REVIEW_CLOCK_INVALID` otherwise).
- `Get-DocsReviewIntervalDays -PagePath [string] -Family [object[]]` -> `[Nullable[long]]` (section 4).
- `Get-DocsPageReviewDue -FrontMatter [IDictionary] -PagePath [string] -Family [object[]]` -> `@{ DueDate; Source }`, `Source` in `review_due`, `interval`, `$null`; explicit `review_due` wins; the interval applies only with a valid `last_reviewed` (`AddDays`).
- `Get-DocsReviewPageFrontMatter -PagePath [string[]] -ReadText [scriptblock]` -> ordinal hashtable page -> parsed front matter (only `.md` paths; pages whose parse yields findings or no block are omitted; pattern of `Get-DocsLedgerPageReference`).
- `Get-DocsReviewOverdueFinding -PageFrontMatter [IDictionary] -Family [object[]] -LegacyExclusion [string[]] -ReferenceDate [datetime] -Severity ('warning'|'error')` -> ordered findings: one `DOCS_REVIEW_OVERDUE` per page whose due date < reference date; `artifact_path` = page, pointer `/review_due` (explicit) or `/last_reviewed` (derived), message names the due date, its source and the reference date; next action "Review the page, then update last_reviewed and review_due." Pages without a due date or whose front matter has ordering errors are skipped (the page checker reports those).
- `Get-DocsReviewOverdueSeverity -Gate [IDictionary]` -> `error` when `block_overdue_review` is the boolean `true`, else `warning`.
- Estimated size 180-250 lines.

### Wiring

- `DocsValidation.psm1` `Invoke-DocsValidation`: new optional `[AllowNull()] [System.Collections.IDictionary] $PageFrontMatter`. In the `docs-complete` branch, directly after the `Get-DocsCompletionGateFinding` loop: when `$PageFrontMatter` is not `$null`, add `Get-DocsReviewOverdueFinding` with `required_families`, `legacy_exclusions[].path` (both optional), `Get-DocsReviewReferenceDate -IssuedAt $IssuedAt` and `Get-DocsReviewOverdueSeverity -Gate $gate`. Matrix and lower modes are unchanged; `DOCS_STALE_PAGE` and `Get-DocsStalenessFinding` are untouched. Receipt counts are unchanged (no receipt schema change).
- `DocsValidateCommands.psm1` `Invoke-DocsValidateCommand`: when `$mode -ceq 'docs-complete'` and the profile loaded, build `$pageFrontMatter = Get-DocsReviewPageFrontMatter -PagePath $pagePath -ReadText $Context.ReadText` and pass it; an absent or failing read propagates to the existing catch (exit 3, `DOCS_CLI_RUNTIME`), as other reads do.
- `DocsReferenceFrontMatter.psm1`: `Resolve-DocsReferenceFrontMatterValue` preserves `review_due` when present; `ConvertTo-DocsReferenceFrontMatterText` key order becomes owner, last_reviewed, review_due, audience, diataxis_mode, surface_refs, title, extensions (docstrings updated).
- Templates (8 now; the 8 family templates after the upstream merge), `.agents` source only, then the generator: insert `review_due: "<review-due-yyyy-mm-dd>"` directly after `last_reviewed`. SKILL.md step 1 names `review_due` and states that it may be omitted when the page's family defines `review_interval_days`. The template test adds the substitution `'<review-due-yyyy-mm-dd>' = '2027-05-14'` (later than the `last_reviewed` substitute 2026-11-14; `'<yyyy-mm-dd>'` does not occur inside the new placeholder because `<` precedes `review`) and the six-key set.
- `core.json` and the bundle gain `DocsReviewCadence.psm1`.

### Finding codes (no collision: Grep for `REVIEW_DUE`, `REVIEW_OVERDUE`, `DOCS_PAGE_REVIEW`, `DOCS_REVIEW`, `OVERDUE` outside `.dev/` returned no match)

`DOCS_PAGE_REVIEW_DUE_INVALID`, `DOCS_PAGE_REVIEW_DUE_NOT_A_DATE`, `DOCS_PAGE_REVIEW_DUE_NOT_AFTER_LAST_REVIEWED` (page checker, error), `DOCS_REVIEW_OVERDUE` (docs-complete validation, warning by default, error with `block_overdue_review: true`), `DOCS_REVIEW_CLOCK_INVALID` (thrown defect guard -> exit 3).

### Rejected alternatives

- Overdue in the `check` command with a clock read: contradicts the documented and tested no-clock contract of `Invoke-DocsCheckCommand`.
- Option and evaluation inside `DocsCompleteGate.psm1`: that module sees only the receipt and the profile text in the merge hook; page dates would require a page read inside a hook, which the hook dependency-guard rule and the receipt-based design exclude.
- A string enum (`overdue_review: warn|block`): equivalent behavior, inconsistent with `allow_deferred`.

### Risks

- Upstream drift: the family record shape or directory base may differ from the Shared Design; mitigated by D6 and a rebase verification task.
- Merge overlap with docs-family-gate-and-ia in `Invoke-DocsValidation` / `Get-DocsCompletionGateFinding` and with docs-family-page-templates in the template files and `docs-authoring-roles.Templates.Tests.ps1` (row count 32 -> 64); the wave-2 ordering already serializes them.
- A passing receipt is not re-evaluated by the merge hook as time passes; an overdue date after the receipt write is reported only on the next `validate` run. Record this in the docs-complete skill text if it describes the option.
- Reading every page in docs-complete adds one read per `.md` file; bounded by the existing page-path listing.

## Numeric Derivation Evidence

Claim: the template family on this branch has 32 files (8 templates in 4 locations), each of which must gain `review_due`.

- Complete Family: every `*.md` file in any `docs-author-page/templates/` directory of the worktree.
- Exhaustive Search Scope: the whole worktree, all surfaces (`.agents`, `.claude`, `.github`, both bundles).
- Inclusion Rules: path matches `**/docs-author-page/templates/*.md`.
- Exclusion Rules: none (no `.github/skills/docs-author-page` copy exists; the Copilot entry is `dropped`).
- Primary Search Strategy or Query Expression: Glob `**/docs-author-page/templates/*.md`.
- Primary Member Set: {api-reference, architecture-overview, cli-reference, config-reference, explanation, how-to, http-reference, tutorial} x {`.agents/skills`, `.claude/skills`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills`}.
- Primary Count: 32.
- Cross-check Search Strategy or Query Expression: Grep `front-matter-field|last_reviewed` with `files_with_matches` over the worktree, filtered to template paths.
- Cross-check Member Set: the same 8 template names under the same 4 roots.
- Cross-check Count: 32.
- Member-set Comparison: identical normalized sets; also consistent with the existing assertion `covers 32 template files` in `docs-authoring-roles.Templates.Tests.ps1`.
- Withheld: the post-upstream count (16 templates, 64 files) cannot be enumerated on this branch and must not be asserted until the upstream templates are merged.

## Requirements Mapping

| AC | Design element | Proof |
|---|---|---|
| review_due accepted and in every template | schema property + enum; template edit via generator | `DocsPageMetadataSchema.Tests.ps1` eight properties; template test six keys and checker pass |
| review_due not later than last_reviewed -> finding | `DOCS_PAGE_REVIEW_DUE_NOT_AFTER_LAST_REVIEWED` | `DocsPageMetadata` tests: equal, earlier, later, invalid-date cases |
| absent review_due -> last_reviewed + interval | `Get-DocsPageReviewDue` | `DocsReviewCadence.Tests.ps1`: family match, longest prefix, no family, invalid interval |
| overdue vs injected instant | `Get-DocsReviewOverdueFinding` + `IssuedAt` | fixed instants: due = reference (none), due = reference - 1 day (finding), validate command with `New-DocsLedgerTestContext -UtcNow` |
| option blocks, default warns | `block_overdue_review` | `DocsValidation.ReviewCadence.Tests.ps1`: absent, false, true; receipt `pass`/`fail` |
| DOCS_STALE_PAGE unchanged | no edit to `DocsStaleness.psm1` or its call sites | existing `DocsStaleness*.Tests.ps1` and `DocsValidation.Tests.ps1` pass unchanged |
| parity | generator for templates/SKILL.md; byte copies for lib/schemas; `core.json` | contract tests in section 5 |

## Testing Implications

- New Pester files under `tests/scripts/claude-lib/docs/`, in-memory only (no temp files), fixed `[datetime]` UTC instants, property tests for `ConvertFrom-DocsReviewDate` and due-date derivation (date arithmetic over seeded inputs, seed printed on failure).
- Update in place, with stated reason: `DocsPageMetadataSchema.Tests.ps1` (property list), `docs-authoring-roles.Templates.Tests.ps1` (key set, substitution), `DocsReferenceFrontMatter.Properties.Tests.ps1` (`FieldOrder`), plus new `review_due` preservation cases in `DocsReferenceFrontMatter.Tests.ps1`.
- Unaffected and expected to stay green: `DocsPageCheck.Tests.ps1` (clock-throw context), `DocsCompleteGate.Tests.ps1`, `DocsStaleness*.Tests.ps1`, `DocsProfile.Tests.ps1` (starter profile unchanged).
- Gates: one `Invoke-PoshQCParallelTest` run through the launcher; per-file line coverage >= 85% for `DocsReviewCadence.psm1` and changed files from `artifacts/pester/powershell-coverage.xml`; the Python contract tests through `run-test-suite.sh pytest`.

## Pre-Mortem

- Review checklists: a reviewer may flag that the issue text names `DocsCompleteGate.psm1` while the change leaves it untouched. Mitigation: the plan cites D1 and includes an AC row showing a blocking overdue finding producing `RECEIPT_FAILING` through `Test-DocsCompleteGateReceipt` with an existing-function test.
- Coverage: the new module's defensive branches (absent families, non-integer interval, legacy exclusion) can be left unexecuted. Mitigation: one test per branch; read per-file line coverage from the single parallel gate run and compare with the Phase 0 baseline.
- Mirror parity: hand-editing `.claude/skills/docs-author-page/templates/*` or missing the bundle copy of a lib or schema file fails `HarnessGeneration.RepoGate.Tests.ps1`, `Docs.Manifest.Tests.ps1`, `DocsSchemaContract.Tests.ps1` or the push-down contract tests. Mitigation: edit `.agents` templates and SKILL.md then run `Invoke-HarnessGeneration.ps1`; copy lib and schema files byte-identically to all copies; add `DocsReviewCadence.psm1` to `core.json`; no fact in the execution-environment brief changes, so no brief task is needed.
- File size: `DocsPageCheck.Tests.ps1` is at 697 lines and `DocsPageFrontMatter.Tests.ps1` at 543. Mitigation: all new cases go into new test files; production files stay below 500 (largest after change: `DocsPageCheck.psm1` unchanged at 434, `DocsValidation.psm1` about 380).
- Test isolation: tests that import the docs modules with `-Force` can leak module state between files in a shard. Mitigation: follow the existing `AfterAll` `Remove-Module` lists and add `DocsReviewCadence`; the leak scan must stay clean with no allowlist entry.
- CI-only behavior: date parsing with the current culture or a local `DateTimeKind` passes locally and fails on Linux runners. Mitigation: `ParseExact` with `InvariantCulture`, UTC-kind values, forward-slash relative paths and exact file-name case in fixtures.
- Evidence: evidence files go under `.dev/active/1220-docs-review-cadence/evidence/<kind>/` with clock-read UTC stamps, append-only. Mitigation: the plan names each artifact as `<name>.<timestamp>.md` and states that the executor reads the clock before each write.

## Automation Feasibility

No human interaction is required. Every change is a file edit, a generator run (`Invoke-HarnessGeneration.ps1`) and test runs through the launcher; no credential, external service or owner decision is needed. Upstream dependency handling is a rebase on the merged wave-0/1 branches followed by the verification task in section 4.
