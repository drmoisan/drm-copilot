# Research: docs-family-gate-and-ia (issue #1221)

- Issue: #1221
- Branch: feature/docs-family-gate-and-ia-1221
- Epic: #1217 documentation-estate-families (wave 1, C3), manifest `.dev/epics/documentation-estate-families/epic.md`
- Depends on: docs-family-profile-model (#1218, prepared in parallel, not merged)
- Timestamp: 2026-11-23T05-52 (UTC, read from an external time service because the researcher has no shell clock)
- Researcher tool limits: Read, Grep, Glob, WebFetch, Write only. Facts marked `[ORCHESTRATOR-CONFIRM]` need `git` or a toolchain run.

## Inputs Read

- Epic `## Shared Design` (family record, default family ids, template ids, legacy list, placeholder token, review cadence).
- Feature `spec.md`, `plan.2026-11-23T00-39.md` (template only), sibling spec `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ae395fa886a826aa4\.dev\active\1218-docs-family-profile-model\spec.md` (read-only).
- `.claude/skills/execution-environment/SKILL.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
- Docs library modules, schemas, MCP TypeScript surfaces, harness parity matrix, generator substitutions, tests listed below.
- Reference repository `C:\Users\DanMoisan\repos\rgf-forecast` (read-only).

## Current State Analysis

### Where the docs-complete decision is actually made

The phrase "docs-complete gate" covers two layers, and only one of them is where a family check can live.

1. `.claude/lib/docs/DocsCompleteGate.psm1` (208 logical lines) holds the pure predicates of the opt-in merge hook `.claude/hooks/enforce-docs-complete-gate.ps1`: `Get-DocsCompleteGateEnabled`, `Get-DocsCompleteGateReceiptPath`, `Test-DocsCompleteGateIntegrationTarget`, `Test-DocsCompleteGateReceipt`. It reads only the persisted receipt and denies with `RECEIPT_FAILING` when `validation_result` is not `pass`. It imports only `DocsJson`, `DocsSurface`, `DocsReceiptRevision` so that the hook satisfies the dependency-guard rules. It evaluates no page, profile family, or root file.
2. The decision itself is produced by `validate -Mode docs-complete`:
   - Dispatch: `Get-DocsCommandTable` in `.claude/lib/docs/Invoke-DocsCommand.ps1` maps `validate` to `Invoke-DocsValidateCommand` in `DocsValidateCommands.psm1` and `coverage` to `Invoke-DocsCoverageCommand` in `DocsLedgerCommands.psm1`.
   - `Invoke-DocsValidateCommand` (`DocsValidateCommands.psm1`, 250 lines) reads the profile through `Read-DocsLedgerCommandProfile`, reads inputs through `Read-DocsLedgerInputSet` (context seams `ReadBytes`, `TestFile`, `ListFile`), calls `Invoke-DocsValidation`, then applies the receipt revision rule (`Get-DocsValidateRevisionFinding`) and writes the receipt only under `-WriteReceipt`.
   - `Invoke-DocsValidation` (`DocsValidation.psm1`, 367 lines) is pure over in-memory inputs. In docs-complete mode it calls `Get-DocsCompletionGateFinding` (codes `DOCS_SNAPSHOT_UNPINNED`, `DOCS_DEFERRED_NOT_ALLOWED`, `DOCS_BOUND_PAGE_MISSING`, `DOCS_PARITY_REQUIRED_DIMENSION`, `DOCS_STALE_PAGE`), but only inside `if ($null -ne $view -and $null -ne $ledger)`. `validation_result` is `fail` when any finding has severity `error` (`Test-DocsFindingHasError`). The receipt is built by `New-DocsValidationReceipt` and checked against its schema (`DOCS_RECEIPT_INVALID` throw).

A family failure therefore reaches the merge hook as `RECEIPT_FAILING` with no change to `DocsCompleteGate.psm1`.

### Findings and receipt model

- `New-DocsFinding` (`DocsFinding.psm1`) builds the eight-key finding: `code` (`^[A-Z][A-Z0-9_]*$`), `severity` (`error`, `warning`, `info`), `artifact_path`, `pointer` (RFC 6901), `related_ids` (identifier grammar `^[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*$`), `related_paths` (relative POSIX paths), `message`, `next_action`. Code naming convention: `DOCS_<AREA>_<CONDITION>` in upper snake case.
- Ordering: `Get-DocsOrderedFinding` sorts by artifact path, pointer, code, related ids, related paths, severity, message, next action. Validation uses a limit of 10000; `New-DocsCommandResult` uses the default limit of 100 and appends an `error` `FINDINGS_LIMIT` finding above it.
- Receipt schema `.claude/lib/docs/schemas/v1/docs-validation-receipt.schema.json`: `counts` has `additionalProperties: false` (`elements_total`, `undocumented`, `stale_pages`, `by_disposition`, `by_kind`); a `pass` receipt may carry only `warning` and `info` findings. `Get-DocsReceiptId` excludes findings and counts, so adding findings does not change the receipt id rule.
- Envelope schema `docs-command-envelope.schema.json`: `findings` `maxItems: 101`; exit 0 requires every finding to be `warning` or `info`; `result` is unconstrained.

Latent defect observed (pre-existing, related): a passing command whose finding set exceeds 100 gets an appended `error` `FINDINGS_LIMIT` while `ExitCode` stays 0, which violates the exit-0 rule of the envelope schema. A per-entry legacy finding would make this reachable; the design below avoids it (Decision D6).

### Page front matter and empty `surface_refs`

- `surface_refs` is `{"$ref": "urn:drm-copilot:docs:1.0.0:common#/$defs/element-ids"}` in `page-metadata.schema.json`; `element-ids` is `{"type": "array", "uniqueItems": true, ...}` with no `minItems` (`common.schema.json`). `DocsPageMetadata.psm1` maps failures to `DOCS_PAGE_SURFACE_REFS_INVALID` only for type, pattern, and uniqueness.
- Empty lists are already accepted: `tests/scripts/claude-lib/docs/DocsPageFrontMatter.Tests.ps1` holds accepted fixtures with `surface_refs: []`, and `DocsReferenceWriter.psm1` writes index pages with empty `surface_refs`.
- Conclusion: no change to page checks is needed. A regression test that a family page with `surface_refs: []` produces no page finding and counts as a family page is sufficient.

### Coverage report structure

`DocsCoverageReport.psm1` (163 lines) exports `Get-DocsCoverageReport` (pure; parameters `SnapshotView`, `Ledger`, `Matrix`, `PinSet`; returns ordered keys `totals`, `undocumented`, `deferred`, `precision_limits`, `stale_pages`, `parity`) and `ConvertTo-DocsCoverageReportLine` (one totals line, one line per listed item, one line per parity dimension). It does not receive the profile or the page-path set. The caller `Invoke-DocsCoverageCommand` (`DocsLedgerCommands.psm1`) has the validated profile (`$profileRead.Profile`) and `Read-DocsLedgerCommandDocumentSet` output (including `PagePath`), and passes the report to `New-DocsCommandResult -Result $report -Line (ConvertTo-DocsCoverageReportLine ...)`.

Coexistence with docs-prose-markdown-lint (placeholder count): both children add a section. The conflict-minimizing shape is one section function per child in `DocsCoverageReport.psm1`, one key assignment per child in `Invoke-DocsCoverageCommand` after the `Get-DocsCoverageReport` call, and one delegating line per child at the end of `ConvertTo-DocsCoverageReportLine`, so that neither child edits the signature or return literal of `Get-DocsCoverageReport`. Expected merge overlap: adjacent single lines in the export list, in `Invoke-DocsCoverageCommand`, and in the expected key list of `DocsLedgerCommands.Tests.ps1`.

### Reading primitives

- `ListFile` (`Get-DocsContextFileList` in `Invoke-DocsCommand.ps1`) returns every file (any extension) under a relative directory, recursively, sorted ordinally, as repository-relative POSIX paths; an absent directory returns an empty list.
- `TestFile` (`Test-DocsContextFile`) returns `[System.IO.File]::Exists`.
- `Read-DocsLedgerInputSet` builds the page-path set only from `documentation_roots[].path`.
- Markdown page detection elsewhere in the library is `EndsWith('.md', Ordinal)` (`DocsLedgerBindRefs.psm1`, `DocsPageCheck.psm1`, `DocsReferencePlan.psm1`).

### Profile and sibling contract

- Current `docs-profile.schema.json` has `additionalProperties: false` at the top level, so a profile carrying `required_families` or `legacy_exclusions` is rejected until #1218 merges. Every test of this item that builds such a profile depends on the merged sibling schema.
- `New-DocsStarterProfile` (`DocsProfile.psm1`) is the base of the shared test fixture `New-DocsLedgerTestProfile` (`tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1`), which is used by the validation, validate-command, and coverage suites.
- Sibling spec (read-only): field names match the Shared Design exactly (`id`, `directory`, `diataxis_mode`, `template`, `audience`, `review_interval_days`, `required`, optional `exclusion {reason, recorded_at}`; `legacy_exclusions[]` of repository-relative page paths each with a `reason`). The sibling spec names no loader or accessor function, does not state whether `New-DocsStarterProfile` (as opposed to the `init` command only) seeds families, and does not fix the key name of the legacy path member.
- Divergence record: none in field names. Two open points not fixed by either document: (a) the legacy entry path key (recommended `path`, as the delegation states "path plus reason"); (b) whether the starter profile seeds `required: true` families. The Shared Design governs; the plan confirms both against the merged #1218 schema and `DocsProfile.psm1` in Phase 0 `[ORCHESTRATOR-CONFIRM]`.

### MCP TypeScript surfaces

- `extensions/drm-copilot/src/mcp-handlers/docs-handlers.ts` (`handleDocsTool`) returns `{ ok, tool, workspace_root, summary, docs: envelope, stderr_excerpt? }`; `docs` is the envelope unchanged. `formatDocsSummary` (`docs-command-envelope.ts`) counts `error`, `warning`, and `info` findings. `toEnvelope` validates only the finding key set and treats `result` as opaque.
- Tool descriptions live in `DOCS_TOOL_DEFINITIONS` (`mcp-docs-tool-definitions.ts`, 147 lines). `packages/mcp-server` holds no docs tool (no match for `run_docs_coverage`).
- Consequence: new findings and a new `families` coverage key pass through with no production logic change. Only the descriptions of `run_docs_coverage` and `validate_docs_artifacts` need to name the new section and finding family. No new TypeScript file is needed, so no new `coverageThreshold` entry; the docs modules keep their entries in `extensions/drm-copilot/jest.docs-coverage.json` (spread into `jest.config.cjs`), which already lists `./src/mcp-docs-tool-definitions.ts` and `./src/mcp-handlers/docs-handlers.ts`.

### docs-plan-ia skill copies

- Source: `.agents/skills/docs-plan-ia/SKILL.md` (parity entry `codex:skill:docs-plan-ia`, disposition `shared`).
- Generated: `.claude/skills/docs-plan-ia/SKILL.md` (`claude:skill:docs-plan-ia`, disposition `generated`, generator `harness-generation/skills`) with two substitutions in `scripts/harness-generation/sources/skills/docs-plan-ia.substitutions.json` (the agent link and the Prerequisites sentence).
- Bundles: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-plan-ia/SKILL.md` and `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-plan-ia/SKILL.md`. `Get-HarnessBundlePath` maps `.claude/` and `.agents/` targets to these bundle paths; whether a generator run also refreshes the `.agents` source's bundle copy is `[ORCHESTRATOR-CONFIRM]` (run the generator, then `-Check` and the contract tests).
- Copilot: `copilot:skill:docs-plan-ia` is `dropped` (Copilot reads the `.agents` skill); no `.github/skills/docs-plan-ia/` exists.
- Contract tests reading these copies: `tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1` (section-scoped tokens over the four roots of `Get-DocsAuthoringSkillRoot`), `docs-authoring-roles.Skills.Tests.ps1`, `docs-authoring-roles.Registration.Tests.ps1`, `DocumentationEstateOnboarding.Tests.ps1`, and `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1`.
- The edit file is `.agents/skills/docs-plan-ia/SKILL.md`. New text must contain no runtime-specific path, so that the existing substitutions stay sufficient.

### Reference repository (rgf-forecast, read-only)

- `.docs-check.json` declares `governed_trees` (one directory per family under `docs/production-documentation/`: product, getting-started, user-guides, admin, operations, architecture, security, service-management, reference), `governed_pages`, and `excluded` (exact paths and `/**` subtree patterns, including legacy pages "expected to shrink to empty").
- `src/dev_tools/docs_check/scan.py` (`_discover_governed`, `_is_excluded`) scans `*.md` under governed trees minus exclusions and checks front matter, links, and Diataxis structure. It has no family-presence check, no root-file check, and no legacy reporting; excluded paths are silently skipped.
- `SECURITY.md` and `CODEOWNERS` exist at its repository root. Their presence and sections were proven by one-off evidence (`docs/features/active/security-compliance-docs/evidence/qa-gates/security-md-required-sections-check.2026-07-16T09-20.md`, `codeowners-syntax-check...`), not by tooling.
- The ADR family sits nested at `architecture/adr/`, so family directories can nest; prefix matching counts an `adr` page for `architecture` as well.
- Design value carried over: directory-per-family, `.md` pages, exact-path legacy exclusions. Not carried over: silent exclusion (this item reports every legacy entry), and no Python is ported.

### Line counts (logical lines, ripgrep `^` count) against the 500/700/800 tiers

| File | Lines | Tier note |
|---|---|---|
| `.claude/lib/docs/DocsCompleteGate.psm1` | 208 | not edited |
| `.claude/lib/docs/DocsValidation.psm1` | 367 | +~10 planned |
| `.claude/lib/docs/DocsValidateCommands.psm1` | 250 | +~4 planned |
| `.claude/lib/docs/DocsCoverageReport.psm1` | 163 | +~50 planned |
| `.claude/lib/docs/DocsLedgerCommands.psm1` | 758 | above 700 advisory; +~3 planned, stays below 800 |
| `.claude/lib/docs/DocsReceipt.psm1` | 301 | not edited |
| `.claude/lib/docs/DocsFinding.psm1` | 282 | not edited |
| `.claude/lib/docs/DocsProfile.psm1` | 237 | sibling-owned |
| `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts` | 147 | description text only |
| `tests/.../DocsValidation.Tests.ps1` | 492 | new cases go to a new file |
| `tests/.../DocsValidateCommands.Tests.ps1` | 519 | new cases go to a new file |
| `tests/.../DocsLedgerCommands.Tests.ps1` | 553 | one expected-key line edited |
| `tests/.../DocsCoverageReport.Tests.ps1` | 154 | unchanged (report keys unchanged) |
| `tests/.../DocsCompleteIntegration.Tests.ps1` | 181 | possible fixture edit (Risk R1) |
| `extensions/drm-copilot/test/mcp-handlers/docs-handlers.test.ts` | 305 | +~40 planned |
| `tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1` | 145 | +rows |

## Candidate Approaches

### A. Family check inside the docs-complete validation layer, through a new pure module (recommended)

A new `DocsFamilyCheck.psm1` holds the family evidence reader (seam-based, like `Read-DocsLedgerInputSet`), the pure status function, and the pure finding function. `Invoke-DocsValidation` calls the finding function in docs-complete mode; `Invoke-DocsValidateCommand` reads the evidence and passes it in; the coverage command adds a `families` section built from the same status function. Families are reported through receipt findings (errors for failures, `info` for not-applicable families and legacy entries).

- Advantages: one decision point; the hook and its dependency closure are unchanged; no receipt schema change; existing profiles without families produce byte-identical results; new logic lands in a new file below the 500-line guidance; the coverage section and the gate share one status computation.
- Limitations: four existing production modules gain small edits plus their bundle copies, so the batch budget requires the orchestrated large route.

### B. Family check in `DocsCompleteGate.psm1` (hook layer)

Rejected. The hook reads only the receipt text; a family check there would need the profile, a directory listing, and root-file probes inside a PreToolUse hook, widen the hook dependency closure guarded by `hook-dependency-guard-completeness`, and leave `validate -Mode docs-complete` and `validate_docs_artifacts` reporting `pass` for an estate that the hook then denies.

### C. Family counts in the receipt `counts` object

Rejected. `counts` has `additionalProperties: false`; adding members changes the receipt schema contract in three schema copies (`.claude/lib/docs/schemas/v1/`, `schemas/docs/v1/`, the bundle), and the MCP tool would still need the findings to explain a failure. Findings already carry the information.

Recommendation: Approach A.

## Behavior Semantics

Inputs: the validated profile document, the family evidence, and the profile path.

Family evidence (`Read-DocsFamilyEvidence -Profile -TestFile -ListFile`):

- Reads nothing when the profile has no `required_families` and no `legacy_exclusions` (existing fixtures make no new context call).
- For each distinct `directory` (trailing `/` trimmed) of `required_families[]`, calls `ListFile` once and keeps the listing.
- When an entry with `id` `security` exists, calls `TestFile` for `SECURITY.md` and `CODEOWNERS` at the repository root.
- Returns `@{ PagePath = <ordinal map directory -> string[]>; RootFile = <ordinal map name -> bool> }`.

Family status (`Get-DocsFamilyStatus -Profile -Evidence`), one entry per `required_families[]` item in profile order:

- `not-applicable` when the entry carries an `exclusion` (the Shared Design rule for `required: true`; applied for `required: false` as well).
- Otherwise `present` when at least one family page exists, else `missing`.
- A family page is a listed path that starts with `<directory>/`, ends with `.md` (ordinal), and is not a `legacy_exclusions[].path`. `README.md` and `index.md` count as pages. A page with `surface_refs: []` counts.
- `missing_root_files`: for `id` `security` that is not excluded, the subset of `SECURITY.md`, `CODEOWNERS` whose `RootFile` value is not `$true`; otherwise empty.
- Entry shape: `{ id, directory, required, template, status, page_count, missing_root_files, exclusion }` (`exclusion` is `$null` or `{ reason, recorded_at }`).
- Legacy list: `legacy_exclusions[]` as `{ path, reason }`, sorted ordinally by path.

Findings (`Get-DocsFamilyFinding -Profile -Evidence -ProfilePath`), artifact path = profile path:

| Condition | Code | Severity | Pointer | Related |
|---|---|---|---|---|
| `required: true`, no exclusion, status `missing` | `DOCS_FAMILY_PAGE_MISSING` | error | `/required_families/<i>/directory` | id; path = directory |
| security family required, not excluded, root file absent (one finding per file) | `DOCS_FAMILY_ROOT_FILE_MISSING` | error | `/required_families/<i>` | id `security`; path = `SECURITY.md` or `CODEOWNERS` |
| entry with `exclusion` | `DOCS_FAMILY_NOT_APPLICABLE` | info | `/required_families/<i>/exclusion` | id |
| `legacy_exclusions` non-empty | `DOCS_LEGACY_EXCLUSIONS_REPORTED` | info | `/legacy_exclusions` | paths = every legacy path; message lists each path with its reason and the count |

- `required: false` families produce no finding; they appear only in the coverage section.
- Ordering, success, and failure follow the existing rules: findings join the docs-complete set, ordering is `Get-DocsOrderedFinding`, and any error makes `validation_result` `fail`.
- The check runs only in docs-complete mode and runs independently of the snapshot and ledger guard, so a broken ledger does not hide a missing family.
- When `FamilyEvidence` is `$null` (a caller that passes none), every family directory is treated as empty and every root file as absent (fail closed).
- Edge cases to cover: a family directory absent on disk (empty listing gives `missing`); nested directories (`architecture` and `architecture/adr`); a page whose name only shares a prefix (`docs/securityx/a.md` is not under `docs/security/`); non-`.md` files ignored; a legacy path inside a family directory not counted; an excluded security family skipping the root-file check; duplicate directories listed once; an empty `legacy_exclusions` producing no info finding.

Coverage section: `$report['families'] = Get-DocsCoverageFamilySection ...` returns `{ entries = <status entries>, legacy_exclusions = <legacy list> }` and is always present (empty arrays when the profile declares none). Lines: `families: required=<n> present=<n> missing=<n> not_applicable=<n> legacy_exclusions=<n>`, then `family <id> <status> pages=<n> <directory>` (plus ` missing_root_files=<a,b>` when non-empty), then `legacy-exclusion <path>: <reason>`.

## Requirements Mapping and File Changes

| Spec behavior | Design element | Files |
|---|---|---|
| Fail on required family with no page and no exclusion | `DOCS_FAMILY_PAGE_MISSING` | new `DocsFamilyCheck.psm1`; `DocsValidation.psm1` (new optional `-FamilyEvidence`, call in docs-complete); `DocsValidateCommands.psm1` (read evidence, pass it) |
| Fail on missing root `SECURITY.md`/`CODEOWNERS` when security family required | `DOCS_FAMILY_ROOT_FILE_MISSING` | same |
| Report excluded families | `DOCS_FAMILY_NOT_APPLICABLE` info; coverage `status: not-applicable` | same plus `DocsCoverageReport.psm1` |
| Report every legacy entry on every run | one `DOCS_LEGACY_EXCLUSIONS_REPORTED` info finding naming every path; coverage `legacy_exclusions` list with reasons | same |
| Family pages may carry empty `surface_refs` | already accepted; regression test only | tests |
| Coverage family section in its own function | `Get-DocsCoverageFamilySection`, `ConvertTo-DocsCoverageFamilyLine` | `DocsCoverageReport.psm1`; `DocsLedgerCommands.psm1` (`Invoke-DocsCoverageCommand`: read evidence, assign `families`) |
| docs-plan-ia family-planning step | new step and result line | `.agents/skills/docs-plan-ia/SKILL.md` (source), generated `.claude` copy, two bundle copies |
| MCP tools surface new findings/fields | pass-through verified; descriptions updated | `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts`; tests in `docs-handlers.test.ts` |
| Parity | bundle copies byte-identical; new module in core manifest | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/*` for each touched module; `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` |
| Documentation | one bullet on the family check | `.dev/engineering/documentation-estate/architecture.md` (`## Ledger, Parity Matrix, Evidence Pins and Receipt`) |

Not edited: `DocsCompleteGate.psm1`, `DocsReceipt.psm1`, `DocsReceiptRevision.psm1`, both receipt and envelope schemas, `DocsPageMetadata.psm1`, `DocsPageFrontMatter.psm1`, `Invoke-DocsCommand.ps1` (no new option), the docs profile schema and loader (sibling-owned), `docs-handlers.ts`, `docs-command-envelope.ts`, `jest.config.cjs`, `jest.docs-coverage.json`, the execution-environment brief (no stated fact changes).

New module conventions (enforced by `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`): `Set-StrictMode -Version Latest` followed by `$ErrorActionPreference = 'Stop'`, column-0 imports with `-ErrorAction Stop`, and the convention sentence in the comment-based help. Imports: `DocsFinding.psm1`, `DocsSurface.psm1` (`Test-DocsRelativePath`), `DocsJson.psm1` if needed. No consumer identifier in library text (`DocsNeutrality.Tests.ps1`); the `security` id and the two root file names are the Shared Design contract and are held as module constants.

Accessor of the sibling: if the merged `DocsProfile.psm1` exports a family or legacy accessor, call it; otherwise read the members of the already validated profile dictionary. This item does not re-validate the family schema.

## Existing Tests Affected

| Test | Current assertion | Disposition |
|---|---|---|
| `tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1` (coverage result keys) | sorted keys `deferred, parity, precision_limits, stale_pages, totals, undocumented` | update to add `families` |
| `tests/scripts/claude-lib/docs/DocsCoverageReport.Tests.ps1` (`Get-DocsCoverageReport` keys) | six keys | unchanged (function untouched) |
| `DocsValidation.Tests.ps1`, `DocsValidation.Properties.Tests.ps1`, `DocsValidateCommands.Tests.ps1`, `DocsReceipt*.Tests.ps1`, `DocsLedgerCommands.Properties.Tests.ps1` | docs-complete pass/fail sets over `New-DocsLedgerTestProfile` | unchanged when the fixture profile declares no families; see Risk R1 |
| `DocsCompleteIntegration.Tests.ps1`, `EndToEndDocumentationEstate.Tests.ps1`, `tests/scripts/claude-hooks/docs-estate-workflow.EndToEnd.Tests.ps1` | docs-complete over starter or init profiles | Risk R1: fail if the merged starter or init profile seeds `required: true` families without pages |
| `enforce-docs-complete-gate*.Tests.ps1`, `DocsCompleteGate.Tests.ps1` | receipt text decisions | unaffected |
| `DocsPageFrontMatter.Tests.ps1` | accepts `surface_refs: []` | unaffected; reused as evidence |
| `docs-handlers.test.ts`, `mcp-docs-tool-definitions.test.ts` | envelope pass-through; `operations` description | add cases; descriptions are not asserted verbatim today |
| `docs-authoring-roles.WorkflowText.Tests.ps1` | page-name tokens in the `Steps` of docs-plan-ia (four copies) | add family-step token rows |
| `Docs.Manifest.Tests.ps1` | every `.claude/lib/docs` file is in `core.json` with a byte-identical bundle copy | satisfied by adding the new module to both |

Risk R1 (highest): `New-DocsLedgerTestProfile` starts from `New-DocsStarterProfile`. If #1218 seeds `required_families` into the starter profile, every docs-complete pass fixture gains ten required families with no pages once this item lands. Mitigation: Phase 0 reads the merged `New-DocsStarterProfile` and `Invoke-DocsInitCommand`; if seeding is present, the plan (a) makes `New-DocsLedgerTestProfile` drop `required_families` and `legacy_exclusions` unless a new `-RequiredFamily` / `-LegacyExclusion` parameter supplies them, and (b) gives each end-to-end fixture that runs docs-complete over an init profile either family pages or recorded exclusions. The plan names each affected test with its disposition (preflight defect class "observable behavior change with tests outside the task's file set").

## Testing Implications

- New Pester files under the mirror tree: `tests/scripts/claude-lib/docs/DocsFamilyCheck.Tests.ps1` (reader with in-memory `TestFile`/`ListFile` scriptblocks; status; findings; every edge case above), `DocsValidation.Families.Tests.ps1` (docs-complete pass with all families present; fail per code; independence from the ledger guard; `$null` evidence fail-closed; info findings keep `pass`), `DocsValidateCommands.Families.Tests.ps1` (evidence read through the context; receipt written with info findings; no new context call for a profile without families), and family-section cases for coverage (in `DocsFamilyCheck.Tests.ps1` or a new `DocsCoverageReport.Families.Tests.ps1`). Profiles are built in memory; no temporary file.
- The tier of `.claude/lib/docs` is T3 (`quality-tiers.yml`): no property-test obligation; line coverage at least 85% on `DocsFamilyCheck.psm1` and no regression on changed lines of the edited modules (PowerShell has no branch gate). Owner ruling recorded in session memory (2026-11-07) keeps a 90% new-code rule `[ORCHESTRATOR-CONFIRM]`; target at least 90% on the new module.
- Jest: cases in `docs-handlers.test.ts` for a coverage envelope with a `families` result and a validate envelope with `DOCS_FAMILY_PAGE_MISSING` (error) and `DOCS_FAMILY_NOT_APPLICABLE` (info), asserting pass-through and the summary counts; a definition case asserting the updated descriptions mention the family section. Existing per-file thresholds for both files apply.
- Contract and parity suites after mirror edits: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `HarnessGeneration.RepoGate.Tests.ps1`, `Docs.Manifest.Tests.ps1`, `ClaudeLibModuleConvention.Tests.ps1`, `DocsNeutrality.Tests.ps1`, `FileSizePolicy.RepoGate.Tests.ps1`.
- Gates run through the launcher (`sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester|pytest|jest`); task checks use `pester -TestPath <selection>`; no serial, single-process, shuffled, or reversed runs.

## Numeric Derivation Evidence

- Numeric spec.md acceptance criterion: the docs-plan-ia skill text exists in exactly 4 committed copies, all of which carry the family-planning step.
- Complete Family: .agents/skills/docs-plan-ia/SKILL.md, .claude/skills/docs-plan-ia/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-plan-ia/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-plan-ia/SKILL.md
- Exhaustive Search Scope: the entire repository worktree, every directory, including `.github/` and every bundle root under `extensions/drm-copilot/resources/`.
- Inclusion Rules: a committed file named `SKILL.md` whose parent directory is `docs-plan-ia` under any `skills/` directory.
- Exclusion Rules: `references/standard.md` files beside the skill (not skill text); research and planning documents that quote the skill name.
- Primary Search Strategy or Query Expression: Glob `**/skills/docs-plan-ia/**` over the entire worktree, matching .agents/skills/docs-plan-ia/SKILL.md, .claude/skills/docs-plan-ia/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-plan-ia/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-plan-ia/SKILL.md, filtered to `SKILL.md`.
- Primary Member Set: .agents/skills/docs-plan-ia/SKILL.md, .claude/skills/docs-plan-ia/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-plan-ia/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-plan-ia/SKILL.md
- Primary Count: 4
- Cross-check Search Strategy or Query Expression: derivation from `config/harness-parity-matrix.json` entries `claude:skill:docs-plan-ia` (target .claude/skills/docs-plan-ia/SKILL.md), `codex:skill:docs-plan-ia` (source .agents/skills/docs-plan-ia/SKILL.md), `copilot:skill:docs-plan-ia` (dropped), mapped through `Get-HarnessBundlePath` to extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-plan-ia/SKILL.md and extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-plan-ia/SKILL.md, and compared with the four roots of `Get-DocsAuthoringSkillRoot` in `tests/scripts/claude-runtime/DocsAuthoringRoles.Helpers.ps1`.
- Cross-check Member Set: .claude/skills/docs-plan-ia/SKILL.md, extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-plan-ia/SKILL.md, .agents/skills/docs-plan-ia/SKILL.md, extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-plan-ia/SKILL.md
- Cross-check Count: 4
- Member-set Comparison: the normalized primary and cross-check member sets are equal; the dropped Copilot entry has no file, and a Glob for `.github/skills/docs-plan-ia/` returned no match.

No other numeric acceptance criterion is proposed. The default family count belongs to #1218.

## Automation Feasibility

Fully automatable with no human interaction. Every change is library code, test code, Markdown skill text, a JSON manifest entry, and a TypeScript description string; every verification is a launcher-run test gate, the harness generator `-Check`, and the contract suites. No step needs an owner decision, credential, external service, or manual UI action. Dependencies: #1218 must be merged into the integration branch before this item's tests can build a profile with `required_families` `[ORCHESTRATOR-CONFIRM]`, and the edits need the orchestrated large route because of the batch budget.

## Recommended Decisions

1. D1: Implement the family check in the docs-complete validation layer (`Invoke-DocsValidation`) through a new pure module `DocsFamilyCheck.psm1`; do not edit `DocsCompleteGate.psm1`. A failing family reaches the merge hook as `RECEIPT_FAILING`. Recorded divergence from the epic file-overlap note: docs-review-cadence should expect to edit the validation layer, not the hook module; the dependency edge still holds.
2. D2: Report through findings only; no receipt or envelope schema change. Codes `DOCS_FAMILY_PAGE_MISSING` (error), `DOCS_FAMILY_ROOT_FILE_MISSING` (error), `DOCS_FAMILY_NOT_APPLICABLE` (info), `DOCS_LEGACY_EXCLUSIONS_REPORTED` (info).
3. D3: Run the family check only in docs-complete mode, outside the snapshot-and-ledger guard.
4. D4: List each family directory with `ListFile` rather than relying on the documentation-root page set, so that family directories outside `documentation_roots` are still evaluated.
5. D5: A family page is any `.md` file (ordinal suffix) under `<directory>/`, including `README.md` and `index.md`, excluding legacy-excluded paths; empty `surface_refs` is accepted with no code change.
6. D6: Report legacy exclusions as one info finding whose `related_paths` names every entry and whose message lists each path with its reason, which keeps the command result below the 100-finding limit; the coverage section lists every entry with its reason.
7. D7: The root-file rule applies to the family whose `id` is `security` when it is not excluded; it probes `SECURITY.md` and `CODEOWNERS` at the repository root only, as the Shared Design states. `.github/CODEOWNERS` does not satisfy it.
8. D8: A family with an `exclusion` is `not-applicable` whether `required` is true or false; `required: false` families produce no finding.
9. D9: Coverage: always add a `families` key (`entries`, `legacy_exclusions`) through `Get-DocsCoverageFamilySection`, assigned in `Invoke-DocsCoverageCommand`; render through `ConvertTo-DocsCoverageFamilyLine` called by one line at the end of `ConvertTo-DocsCoverageReportLine`; leave `Get-DocsCoverageReport` unchanged for coexistence with docs-prose-markdown-lint.
10. D10: TypeScript: no logic change and no new file; update the `run_docs_coverage` and `validate_docs_artifacts` descriptions in `mcp-docs-tool-definitions.ts` and add Jest pass-through cases; no `jest.config.cjs` change.
11. D11: docs-plan-ia: edit `.agents/skills/docs-plan-ia/SKILL.md`; add a step after the element-assignment steps that reads `required_families` and the coverage `families` section, plans at least one page in `directory` with the family `template`, `diataxis_mode`, and `audience` (with `surface_refs: []` when the page covers no element) for each `missing` family, plans `SECURITY.md` and `CODEOWNERS` for the security family, proposes an `exclusion` with `reason` for a family that does not apply (the root records it in the profile), and plans the migration of each `legacy_exclusions` entry; extend `## Result` with family lines. Use no runtime-specific path; run the generator; copy the `.agents` bundle; add token rows to `docs-authoring-roles.WorkflowText.Tests.ps1`.
12. D12: Read sibling data from the validated profile dictionary, or through an accessor if the merged #1218 exports one; use `path` and `reason` for legacy entries unless the merged schema names a different key, in which case follow the merged schema.
13. D13: Do not change `New-DocsCommandResult` in this item. The pre-existing defect (a passing command with more than 100 findings exits 0 with an appended `error` `FINDINGS_LIMIT`, which violates the envelope schema) is independent of families and affects every docs command; D6 keeps this item from reaching it. Record it for a separate issue.
14. D14: Put new test cases in new files (`DocsFamilyCheck.Tests.ps1`, `DocsValidation.Families.Tests.ps1`, `DocsValidateCommands.Families.Tests.ps1`) to keep existing suites below 700 lines; extend `New-DocsLedgerTestProfile` with opt-in family parameters if Risk R1 applies.
15. D15: Add one bullet on the family check to `.dev/engineering/documentation-estate/architecture.md`.

## Out of Scope (Boundaries)

- `review_due`, the overdue finding, and the docs-complete review option (docs-review-cadence, which edits after this item).
- Page templates and the `docs-author-page` skill (docs-family-page-templates).
- Epic-scale routing guidance in `documentation-workflow` (docs-epic-scale-routing).
- The placeholder-count section and Vale/markdown lint (docs-prose-markdown-lint).
- The profile schema, loader validation, and `docs-init` seeding (docs-family-profile-model).
- Any change to rgf-forecast.

## Owner Constraints and How the Design Honors Them

- Autonomous mode: every open question has a recorded decision above; the planner records them in the feature folder.
- No new Python: PowerShell 7.4 library module and tests; TypeScript limited to an MCP description string and Jest tests.
- Parallel-only test runs: gates and task checks run through the test-execution launcher only.
- Append-only evidence with clock timestamps: evidence under `.dev/active/1221-docs-family-gate-and-ia/evidence/<kind>/`, filenames stamped at write time.
- Related findings fixed inside the item: Risk R1 fixture fallout and the docs-plan-ia contract rows are in scope; the pre-existing `FINDINGS_LIMIT` exit-code defect is independent of families and is recorded for a separate issue (D13).
- Forethought: the Pre-Mortem below lists each review and CI failure mode with its mitigation.
- File size and test files: new logic in a new module; no temporary files in tests; coverage per repository rules.

## Pre-Mortem

- Review checklists: a reviewer can flag the 758-line `DocsLedgerCommands.psm1` growing inside the 700 advisory tier, or a test that asserts behavior outside its task's file set. Mitigation: limit the coverage-command edit to about three lines, move all logic to `DocsFamilyCheck.psm1`, and have each task name every test that asserts changed behavior (coverage key list, Risk R1 fixtures) with its disposition.
- Coverage: `DocsFamilyCheck.psm1` can fall below 85% line coverage if the reader branches (no families, security absent, duplicate directory, absent directory) are not driven, and edited lines in the four existing modules can regress. Mitigation: one test per branch with in-memory scriptblock seams; compare per-file figures in `artifacts/pester/powershell-coverage.xml` from the single gate run with the Phase 0 baseline; Jest thresholds for the two docs TypeScript files stay at 85/75.
- Mirror parity: a missed bundle copy of a touched `.claude/lib/docs` module, a missing `core.json` entry for the new module, a hand edit of the generated `.claude/skills/docs-plan-ia/SKILL.md`, or a stale `.agents` bundle copy fails the push-down contract tests, `Docs.Manifest.Tests.ps1`, or `HarnessGeneration.RepoGate.Tests.ps1`. Mitigation: a dedicated mirror task copies each touched module, adds the manifest entry, edits only the `.agents` source, runs `Invoke-HarnessGeneration.ps1` and its `-Check`, and runs the contract suites; no execution-environment brief fact changes, so no brief task is needed.
- File size: the new module could exceed 500 lines if status, findings, and section rendering are combined with verbose help; `DocsValidation.Tests.ps1` (492) and `DocsValidateCommands.Tests.ps1` (519) would pass 700 if extended. Mitigation: keep rendering in `DocsCoverageReport.psm1`, keep the new module near 250 lines, and put new cases in new test files.
- Test isolation: in-memory context fakes that read module-scope state, or new tests that change `$global:` state, are caught by `Invoke-PoshQCLeakScan` and shard co-location. Mitigation: build each context and profile inside the test, use `BeforeAll`/`AfterAll` pairs for imports, and create no temporary file.
- CI-only behavior: the Linux hook-suite job and `.gitattributes` `eol=lf` can expose drive-letter paths or CRLF assumptions; tests that need the merged #1218 schema fail if the branch is not based on the integration branch that holds it. Mitigation: forward-slash relative paths only; confirm the base contains #1218 before Phase 1 `[ORCHESTRATOR-CONFIRM]`; dispatch CI for the epic-child PR if none runs.
- Evidence: an evidence file stamped at plan time, a coverage figure taken from an MCP PoshQC result (which carries no output), or an MCP Pester run used as gate evidence would fail review. Mitigation: stamp each evidence file at write time from the clock, take counts from `artifacts/pester/pester-junit.xml` and coverage from `artifacts/pester/powershell-coverage.xml` of the launcher run, and keep all evidence append-only under `<FEATURE>/evidence/<kind>/`.

## Orchestrator Notes

- `[ORCHESTRATOR-CONFIRM]` #1218 merge state and the base of `feature/docs-family-gate-and-ia-1221`; the merged legacy-entry key name; whether `New-DocsStarterProfile` or `init` seeds `required: true` families (Risk R1); whether the harness generator writes the `.agents` bundle copy.
- Batch budget: five production PowerShell files plus five bundle copies exceed the direct-mode cap of three; the executor needs the `large` route checkpoint in the item worktree (an isolated subagent worktree has no checkpoint and stays in direct mode).
- No formal `Owner directives:` block was present in the delegation, so no `OWNER-DIRECTIVE-DECISION:` line is recorded; the relayed owner constraints are honored as task constraints above.
