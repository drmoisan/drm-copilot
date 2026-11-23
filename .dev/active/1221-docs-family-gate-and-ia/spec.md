# docs-family-gate-and-ia — Spec

- **Issue:** #1221
- **Parent (optional):** epic #1217 (documentation-estate-families), wave 1, complexity C3
- **Depends on:** #1218 (docs-family-profile-model)
- **Owner:** drmoisan
- **Last Updated:** 2026-11-23
- **Status:** Approved for planning
- **Version:** 1.0
- **Design source:** `.dev/active/1221-docs-family-gate-and-ia/research/research.2026-11-23T05-52.md` (Recommended Decisions D1-D15, Behavior Semantics, Numeric Derivation Evidence)

## Overview

The docs profile gains a `required_families[]` record and a `legacy_exclusions[]` list, owned by the sibling child docs-family-profile-model (#1218). Nothing in the documentation workflow consumes them yet. The docs-complete gate proves only surface-driven reference coverage, so a consumer repository can pass docs-complete while a required documentation family (onboarding, administration, security, operations, service management, architecture, ADRs) has no page, and legacy pages excluded from the estate are never reported.

This feature makes docs-complete validation fail on a missing required family or a missing security root file, report excluded families and every legacy exclusion, add a family section to the docs coverage report, add a family-planning step to the `docs-plan-ia` skill in every surface copy, and expose the new findings and fields through the docs MCP tools.

## Decisions

The run is autonomous. Each decision below is recorded here so that the planner, executor, and reviewer apply the same resolution. Decisions 1-15 adopt the research Recommended Decisions D1-D15; decisions 16-20 record the orchestrator confirmations of the research `[ORCHESTRATOR-CONFIRM]` items.

1. **D1 — Check location.** The family check lives in the docs-complete validation layer: a new pure module `.claude/lib/docs/DocsFamilyCheck.psm1`, called from `Invoke-DocsValidation` (`DocsValidation.psm1`) and fed by `Invoke-DocsValidateCommand` (`DocsValidateCommands.psm1`). `.claude/lib/docs/DocsCompleteGate.psm1` is not edited. A family failure reaches the merge hook `.claude/hooks/enforce-docs-complete-gate.ps1` as a failing receipt (`RECEIPT_FAILING`). This diverges from the epic edge note that both this item and docs-review-cadence edit `DocsCompleteGate.psm1`: docs-review-cadence must expect to edit the validation layer (`DocsValidation.psm1`, `DocsFamilyCheck.psm1`), not the hook module. The dependency edge from docs-review-cadence to this item still holds.
2. **D2 — Reporting channel.** Results are reported through findings only. The receipt schema and the command envelope schema are unchanged. Codes: `DOCS_FAMILY_PAGE_MISSING` (error), `DOCS_FAMILY_ROOT_FILE_MISSING` (error), `DOCS_FAMILY_NOT_APPLICABLE` (info), `DOCS_LEGACY_EXCLUSIONS_REPORTED` (info).
3. **D3 — Mode and guard.** The family check runs only in docs-complete mode and runs outside the existing `if ($null -ne $view -and $null -ne $ledger)` guard, so a missing snapshot or ledger does not hide a missing family.
4. **D4 — Listing.** Each distinct family `directory` is listed through the context `ListFile` seam, not derived from the `documentation_roots` page set, so family directories outside `documentation_roots` are evaluated.
5. **D5 — Family page.** A family page is any listed path that starts with `<directory>/`, ends with `.md` (ordinal comparison), and is not a `legacy_exclusions[].path`. `README.md` and `index.md` count. A page with `surface_refs: []` is accepted with no change to page checks.
6. **D6 — Legacy reporting.** All legacy entries are reported as one info finding whose `related_paths` names every entry path and whose message lists each path with its reason and the entry count. This keeps the command result below the 100-finding limit. The coverage section lists every entry with its reason.
7. **D7 — Root files.** The root-file rule applies to the family whose `id` is `security` when it is not excluded. It probes `SECURITY.md` and `CODEOWNERS` at the repository root only. `.github/CODEOWNERS` and `docs/CODEOWNERS` do not satisfy it.
8. **D8 — Exclusion and `required: false`.** A family with an `exclusion` is `not-applicable` whether `required` is true or false. A `required: false` family without an exclusion produces no finding and appears only in the coverage section.
9. **D9 — Coverage section.** A `families` key (`entries`, `legacy_exclusions`) is always added to the coverage result by `Get-DocsCoverageFamilySection`, assigned in `Invoke-DocsCoverageCommand` after the `Get-DocsCoverageReport` call, and rendered by `ConvertTo-DocsCoverageFamilyLine`, called by one line at the end of `ConvertTo-DocsCoverageReportLine`. `Get-DocsCoverageReport` (signature and return literal) is unchanged, to coexist with the docs-prose-markdown-lint placeholder-count section.
10. **D10 — TypeScript.** No TypeScript logic change and no new TypeScript file. The `run_docs_coverage` and `validate_docs_artifacts` descriptions in `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts` are updated, and Jest pass-through cases are added. `jest.config.cjs` and `jest.docs-coverage.json` are unchanged.
11. **D11 — docs-plan-ia.** The edit is made in the source `.agents/skills/docs-plan-ia/SKILL.md`. A family-planning step is added after the element-assignment steps, and `## Result` gains family lines. The new text contains no runtime-specific path, so the existing substitutions in `scripts/harness-generation/sources/skills/docs-plan-ia.substitutions.json` stay sufficient.
12. **D12 — Sibling data access.** Family and legacy data are read from the validated profile dictionary returned by the existing profile read path. #1218 exports no accessor function. Legacy entries use the keys `path` and `reason`. This item does not re-validate the family schema.
13. **D13 — FINDINGS_LIMIT envelope defect.** Out of scope. The pre-existing defect (a passing command with more than 100 findings exits 0 with an appended `error` `FINDINGS_LIMIT` finding, which violates the envelope exit-0 rule) is independent of families and affects every docs command. D6 keeps this item from reaching it. It is listed under Out of Scope for a separate issue.
14. **D14 — Test file placement.** New test cases go into new files (`DocsFamilyCheck.Tests.ps1`, `DocsValidation.Families.Tests.ps1`, `DocsValidateCommands.Families.Tests.ps1`, and optionally `DocsCoverageReport.Families.Tests.ps1`) so that existing suites stay below 700 lines. `New-DocsLedgerTestProfile` gains opt-in family parameters (Decision 17).
15. **D15 — Engineering documentation.** One bullet describing the family check is added to `.dev/engineering/documentation-estate/architecture.md` under `## Ledger, Parity Matrix, Evidence Pins and Receipt`.
16. **Sibling state.** #1218 is not merged; it is prepared in parallel. This feature branches from an integration tip that contains #1218 at execution time. The #1218 contract used here: family records carry `id`, `directory`, `diataxis_mode`, `template`, `audience`, `review_interval_days`, `required`, and optional `exclusion {reason, recorded_at}`; legacy entries carry `path` and `reason`; `.claude/lib/docs/DocsProfileFamilies.psm1` exports `Get-DocsDefaultFamilySet` and `Test-DocsProfileFamilySemantic` and no accessor; `New-DocsStarterProfile` (and therefore `docs-init`) seeds all ten default families with `required: true` under `<DocumentationRoot>/<id>` and `legacy_exclusions: []`. Execution must confirm the integration tip contains #1218 before the first implementation task.
17. **Risk R1 applies.** Because the starter profile seeds ten required families with no pages, every docs-complete fixture built from `New-DocsStarterProfile` would fail once this feature lands. `New-DocsLedgerTestProfile` (`tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1`) must drop the seeded `required_families` (set to an empty array) and keep `legacy_exclusions` empty unless new opt-in parameters (`-RequiredFamily`, `-LegacyExclusion`) supply them. Every end-to-end docs-complete fixture that does not use that helper must either provide a page in each required family directory plus the root `SECURITY.md` and `CODEOWNERS`, or record an `exclusion` for each family, so that its existing pass assertions keep passing without being weakened.
18. **Bundle writer.** `Invoke-HarnessGeneration.ps1` maps `.agents/` paths to `extensions/drm-copilot/resources/codex-and-agents-customizations/` through `Get-HarnessBundlePath`. This spec requires that all four docs-plan-ia copies equal the generator rendering (the generator `-Check` passes and the parity contract tests pass); it does not prescribe which writer produces the `.agents` bundle copy.
19. **Coverage gate.** `.claude/lib/docs` is tier T3 in `quality-tiers.yml`. The new module requires at least 85% line coverage (the repository default; the root `CLAUDE.md` states no threshold). The owner ruling of 2026-11-07 keeps a 90% new-code target, which the executor aims for; the acceptance gate is 85%. PowerShell has no branch gate. Changed lines in edited modules must not regress. Jest per-file thresholds for the docs TypeScript files stay at 85% line and 75% branch.
20. **Owner directives.** The delegation carried no formal `Owner directives:` block, so no `OWNER-DIRECTIVE-DECISION:` line is recorded. The relayed owner constraints are applied as task constraints in `## Non-Functional Requirements`.

## Behavior

### Family evidence

`Read-DocsFamilyEvidence -Profile <dictionary> -TestFile <scriptblock> -ListFile <scriptblock>`:

- Makes no context call when the profile has an empty or absent `required_families` and an empty or absent `legacy_exclusions`.
- For each distinct `directory` of `required_families[]` (trailing `/` trimmed, duplicates collapsed, ordinal comparison), calls `ListFile` once and keeps the listing.
- When an entry with `id` `security` exists, calls `TestFile` for `SECURITY.md` and `CODEOWNERS` at the repository root.
- Returns `@{ PagePath = <ordinal map directory -> string[]>; RootFile = <ordinal map name -> bool> }`.

### Family status

`Get-DocsFamilyStatus -Profile <dictionary> -Evidence <hashtable or $null>` returns one entry per `required_families[]` item, in profile order:

- `status` is `not-applicable` when the entry carries an `exclusion`; otherwise `present` when at least one family page (Decision 5) exists; otherwise `missing`.
- `missing_root_files` is, for the non-excluded `security` entry, the ordered subset of `SECURITY.md`, `CODEOWNERS` whose `RootFile` value is not `$true`; otherwise empty.
- Entry shape: `{ id, directory, required, template, status, page_count, missing_root_files, exclusion }`, where `exclusion` is `$null` or `{ reason, recorded_at }`.
- When `Evidence` is `$null`, every directory is treated as empty and every root file as absent (fail closed).
- The legacy list is `legacy_exclusions[]` projected to `{ path, reason }` and sorted ordinally by `path`.

### Findings

`Get-DocsFamilyFinding -Profile <dictionary> -Evidence <hashtable or $null> -ProfilePath <string>` emits findings built with `New-DocsFinding`; `artifact_path` is the profile path. `<i>` is the zero-based index of the entry in `required_families`.

| Condition | Code | Severity | Pointer | related_ids | related_paths | Message content |
|---|---|---|---|---|---|---|
| `required: true`, no `exclusion`, status `missing` | `DOCS_FAMILY_PAGE_MISSING` | error | `/required_families/<i>/directory` | family `id` | family `directory` | names the family id and directory |
| `id` `security`, `required: true`, no `exclusion`, root file absent (one finding per absent file) | `DOCS_FAMILY_ROOT_FILE_MISSING` | error | `/required_families/<i>` | `security` | `SECURITY.md` or `CODEOWNERS` | names the file |
| entry carries `exclusion` (any `required` value) | `DOCS_FAMILY_NOT_APPLICABLE` | info | `/required_families/<i>/exclusion` | family `id` | none | names the family id and the exclusion reason |
| `legacy_exclusions` non-empty | `DOCS_LEGACY_EXCLUSIONS_REPORTED` | info | `/legacy_exclusions` | none | every legacy `path`, ordinal order | lists each path with its reason and states the count |

- A `required: false` family without an exclusion produces no finding.
- Findings join the docs-complete finding set and are ordered by `Get-DocsOrderedFinding`. Any `error` finding makes `validation_result` `fail`; `info` findings alone keep `pass`.
- The receipt id rule is unchanged (`Get-DocsReceiptId` excludes findings and counts).
- `next_action` for each error names the remediation: add a page under the directory, add the root file, or record an `exclusion` with a reason.

### Coverage section

`Get-DocsCoverageFamilySection -Profile <dictionary> -Evidence <hashtable>` returns `{ entries = <status entries>, legacy_exclusions = <legacy list> }`. The coverage result always carries the `families` key; both arrays are empty when the profile declares no families and no legacy entries.

`ConvertTo-DocsCoverageFamilyLine -Section <section>` emits, in order:

1. `families: required=<n> present=<n> missing=<n> not_applicable=<n> legacy_exclusions=<n>`, where `required` counts entries with `required: true`.
2. One line per entry: `family <id> <status> pages=<n> <directory>`, followed by ` missing_root_files=<a,b>` when the list is non-empty.
3. One line per legacy entry: `legacy-exclusion <path>: <reason>`.

### Edge cases

- A family directory absent on disk yields an empty listing and status `missing`.
- Nested directories (`architecture` and `architecture/adr`): a page under `architecture/adr/` counts for both families (prefix match on `<directory>/`).
- Prefix-only name overlap: `docs/securityx/a.md` is not a page of `docs/security`.
- Non-`.md` files (for example `.png` and `.txt`) do not count. The suffix comparison is ordinal, so `.MD` does not match.
- A legacy-excluded path inside a family directory is not counted as a family page; a family whose only page is legacy-excluded is `missing`.
- An excluded `security` family skips the root-file check.
- A `.github/CODEOWNERS` file does not satisfy the root-file check.
- Duplicate directories across entries are listed once.
- An empty `legacy_exclusions` produces no `DOCS_LEGACY_EXCLUSIONS_REPORTED` finding.
- A profile without families and legacy entries produces results identical to the current behavior and makes no new context call.
- `FamilyEvidence` `$null` passed to `Invoke-DocsValidation` fails closed (every required, non-excluded family is `missing`).
- A family page with `surface_refs: []` produces no page finding and counts as a family page.

## Inputs / Outputs

- Inputs: the validated docs profile (`required_families[]`, `legacy_exclusions[]` as defined by #1218), the repository file system through the existing command context seams `ListFile` and `TestFile`, and the profile path.
- Outputs: new findings in the `validate -Mode docs-complete` result and receipt; a `families` key in the `coverage` command result; new coverage report lines.
- Config keys and defaults: no new configuration key, CLI option, or environment variable. `Invoke-DocsCommand.ps1` gains no option.
- Backward compatibility: a profile with no `required_families` and no `legacy_exclusions` yields the same validation findings and result as before. The coverage result gains the `families` key with empty arrays and one summary line `families: required=0 present=0 missing=0 not_applicable=0 legacy_exclusions=0`.

## API / CLI Surface

- `DocsFamilyCheck.psm1` exports `Read-DocsFamilyEvidence`, `Get-DocsFamilyStatus`, `Get-DocsFamilyFinding`.
- `DocsCoverageReport.psm1` adds exports `Get-DocsCoverageFamilySection` and `ConvertTo-DocsCoverageFamilyLine`; `Get-DocsCoverageReport` is unchanged.
- `Invoke-DocsValidation` gains an optional `-FamilyEvidence` parameter (default `$null`).
- `Invoke-DocsValidateCommand` reads family evidence through the context and passes it to `Invoke-DocsValidation`.
- `Invoke-DocsCoverageCommand` reads family evidence through the context and assigns `$report['families']`.
- MCP tools `validate_docs_artifacts` and `run_docs_coverage`: envelope unchanged; descriptions name the family findings and the `families` section. `run_docs_check` is unchanged unless it already returns docs-complete findings, in which case the findings pass through unchanged.
- Example: `Invoke-DocsCommand.ps1 -Command validate -Mode docs-complete -Revision <sha>` over a profile whose `operations` family has no page returns exit code 1, `validation_result` `fail`, and a finding `DOCS_FAMILY_PAGE_MISSING` with pointer `/required_families/<i>/directory` and `related_ids` `["operations"]`.

## Data & State

- No persisted state change. No schema change to the receipt, envelope, or profile.
- Invariant: one status entry per `required_families[]` item, in profile order.
- Invariant: the family check reads the file system only through context seams; the status and finding functions are pure.
- No migration or backfill.

## Constraints & Risks

- Consumes the family record and legacy list defined by #1218; does not re-implement the schema or loader.
- Risk R1 (applies): seeded starter families break docs-complete pass fixtures. Mitigation: Decision 17 and the acceptance criterion on fixtures.
- Risk: `DocsLedgerCommands.psm1` is 758 lines (above the 700 advisory tier). The edit there is limited to about three lines and must keep the file at or below 800 lines.
- Risk: coexistence with docs-prose-markdown-lint in `DocsCoverageReport.psm1`, `Invoke-DocsCoverageCommand`, and the coverage key test. Mitigation: Decision 9; expected overlap is adjacent single lines.
- Risk: mirror drift. Every touched `.claude/lib/docs` module needs a byte-identical bundle copy; the new module needs a `core.json` entry; the generated `.claude/skills/docs-plan-ia/SKILL.md` must not be hand edited.
- docs-review-cadence edits after this item; the `review_due` and overdue option is out of scope.

## Non-Functional Requirements

- Autonomous mode: do not halt for decisions; apply the recommended option, record the decision in the feature folder, and continue.
- No new Python. Library and tests are PowerShell 7.4; TypeScript is limited to the MCP description strings and Jest tests.
- Test runs are parallel only, through `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester|pytest|jest`; no serial, single-process, shuffled, or reversed runs.
- Evidence is append-only under `.dev/active/1221-docs-family-gate-and-ia/evidence/<kind>/`; timestamps come from the clock at write time; no evidence is back-dated or deleted.
- Related findings discovered during execution are fixed inside this item through remediation cycles before merge; only completely unrelated findings become new issues.
- Pre-mortem and self-review before every push.
- File size: 800 logical lines hard limit; the new module targets about 250 lines; no temporary files in tests (in-memory scriptblock seams only).
- New module follows `ClaudeLibModuleConvention.Tests.ps1` (strict mode, `$ErrorActionPreference = 'Stop'`, column-0 imports with `-ErrorAction Stop`, convention sentence in help) and `DocsNeutrality.Tests.ps1` (no consumer identifier).
- Relative POSIX paths only; no drive-letter or CRLF assumptions.

## Implementation Strategy

- New: `.claude/lib/docs/DocsFamilyCheck.psm1` with the three exported functions; imports `DocsFinding.psm1`, `DocsSurface.psm1`, and `DocsJson.psm1` if needed. The `security` id and the root file names are module constants.
- Edit: `DocsValidation.psm1` (optional `-FamilyEvidence`; call `Get-DocsFamilyFinding` in docs-complete mode outside the snapshot-and-ledger guard).
- Edit: `DocsValidateCommands.psm1` (read evidence; pass it in).
- Edit: `DocsCoverageReport.psm1` (two new functions; one delegating line in `ConvertTo-DocsCoverageReportLine`).
- Edit: `DocsLedgerCommands.psm1` (`Invoke-DocsCoverageCommand`: read evidence; assign `families`).
- Edit: `.agents/skills/docs-plan-ia/SKILL.md`; regenerate `.claude/skills/docs-plan-ia/SKILL.md`; refresh both bundle copies.
- Edit: `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts` (descriptions only).
- Mirror: bundle copies under `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` for each touched and new module; `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` entry for the new module.
- Tests: new Pester files (Decision 14); `DocsLedger.TestSupport.psm1` opt-in parameters; end-to-end fixture updates (Decision 17); `DocsLedgerCommands.Tests.ps1` expected key list; `docs-authoring-roles.WorkflowText.Tests.ps1` token rows; Jest cases in `docs-handlers.test.ts` and the definitions test.
- Documentation: one bullet in `.dev/engineering/documentation-estate/architecture.md`.
- No dependency change. No logging change. No feature flag; the behavior activates when a profile declares families.

## File Inventory

| File | Change |
|---|---|
| `.claude/lib/docs/DocsFamilyCheck.psm1` | new |
| `.claude/lib/docs/DocsValidation.psm1` | edit |
| `.claude/lib/docs/DocsValidateCommands.psm1` | edit |
| `.claude/lib/docs/DocsCoverageReport.psm1` | edit |
| `.claude/lib/docs/DocsLedgerCommands.psm1` | edit (about three lines) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/docs/` copies of the five files above | mirror |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | add new module |
| `.agents/skills/docs-plan-ia/SKILL.md` | edit (source) |
| `.claude/skills/docs-plan-ia/SKILL.md` | generated |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-plan-ia/SKILL.md` | bundle |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-plan-ia/SKILL.md` | bundle |
| `extensions/drm-copilot/src/mcp-docs-tool-definitions.ts` | description text |
| `extensions/drm-copilot/test/mcp-handlers/docs-handlers.test.ts` | new cases |
| `extensions/drm-copilot/test/` definitions test for `mcp-docs-tool-definitions.ts` | new case |
| `tests/scripts/claude-lib/docs/DocsFamilyCheck.Tests.ps1` | new |
| `tests/scripts/claude-lib/docs/DocsValidation.Families.Tests.ps1` | new |
| `tests/scripts/claude-lib/docs/DocsValidateCommands.Families.Tests.ps1` | new |
| `tests/scripts/claude-lib/docs/DocsCoverageReport.Families.Tests.ps1` | new (optional; cases may live in `DocsFamilyCheck.Tests.ps1`) |
| `tests/scripts/claude-lib/docs/DocsLedger.TestSupport.psm1` | opt-in family parameters; drop seeded families by default |
| `tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1` | expected key list gains `families` |
| `tests/scripts/claude-lib/docs/DocsCompleteIntegration.Tests.ps1` | fixture: family pages and root files, or exclusions |
| `tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1` | fixture: family pages and root files, or exclusions |
| `tests/scripts/claude-hooks/docs-estate-workflow.EndToEnd.Tests.ps1` | fixture: family pages and root files, or exclusions |
| `tests/scripts/claude-lib/docs/DocsHashLineEnding.Tests.ps1` and any other docs-complete fixture found by search | fixture review and update if it builds a seeded profile outside the helper |
| `tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1` | family-step token rows |
| `.dev/engineering/documentation-estate/architecture.md` | one bullet |

Not edited: `DocsCompleteGate.psm1`, `DocsReceipt.psm1`, `DocsReceiptRevision.psm1`, receipt and envelope schemas, `DocsPageMetadata.psm1`, `DocsPageFrontMatter.psm1`, `Invoke-DocsCommand.ps1`, the docs profile schema, `DocsProfile.psm1`, `DocsProfileFamilies.psm1`, `docs-handlers.ts`, `docs-command-envelope.ts`, `jest.config.cjs`, `jest.docs-coverage.json`.

## Out of Scope

- `review_due`, the overdue finding, and the docs-complete review option (docs-review-cadence).
- Page templates and the `docs-author-page` skill (docs-family-page-templates).
- Epic-scale routing guidance in `documentation-workflow` (docs-epic-scale-routing).
- The placeholder-count section and Vale or markdown lint (docs-prose-markdown-lint).
- The profile schema, loader validation, and `docs-init` seeding (docs-family-profile-model, #1218).
- Any change to the rgf-forecast reference repository.
- The pre-existing `FINDINGS_LIMIT` envelope defect in `New-DocsCommandResult` (Decision 13); recorded for a separate issue.
- Any change to `DocsCompleteGate.psm1` or the merge hook.

## Acceptance Criteria

### Family check (validation layer)

- [ ] AC-1: In docs-complete mode, a profile with a `required: true` family that has no `.md` page under its `directory` and no `exclusion` produces `validation_result` `fail` and a finding with code `DOCS_FAMILY_PAGE_MISSING`, severity `error`, pointer `/required_families/<i>/directory`, `related_ids` containing the family `id`, and `related_paths` containing the family `directory`; `validate -Mode docs-complete` exits non-zero.
- [ ] AC-2: The same profile produces no `DOCS_FAMILY_PAGE_MISSING` finding for that family after a `.md` page is added under the family directory, and produces `validation_result` `pass` when no other error exists.
- [ ] AC-3: The same profile with an `exclusion {reason, recorded_at}` recorded on the family produces no error for that family and one `DOCS_FAMILY_NOT_APPLICABLE` finding with severity `info`, pointer `/required_families/<i>/exclusion`, and `related_ids` containing the family `id`; `validation_result` stays `pass` when no other error exists.
- [ ] AC-4: With the `security` family `required: true` and not excluded, an absent repository-root `SECURITY.md` or `CODEOWNERS` produces one `DOCS_FAMILY_ROOT_FILE_MISSING` finding per absent file, severity `error`, pointer `/required_families/<i>`, `related_ids` `["security"]`, and `related_paths` naming the file; a `.github/CODEOWNERS` file does not satisfy the check; an excluded `security` family produces no root-file finding.
- [ ] AC-5: A profile with a non-empty `legacy_exclusions` produces exactly one `DOCS_LEGACY_EXCLUSIONS_REPORTED` finding on every docs-complete run, severity `info`, pointer `/legacy_exclusions`, `related_paths` equal to every legacy `path` in ordinal order, and a message that names each path with its reason; an empty `legacy_exclusions` produces no such finding.
- [ ] AC-6: A family page whose front matter has `surface_refs: []` produces no page finding and counts toward the family `page_count`.
- [ ] AC-7: A `required: false` family without an exclusion produces no finding; a legacy-excluded path inside a family directory does not count as a family page; `docs/securityx/a.md` is not a page of `docs/security`; non-`.md` files are not pages; nested family directories each count a page under the nested directory; duplicate directories are listed once.
- [ ] AC-8: The family check runs in docs-complete mode even when the snapshot or ledger is absent, and does not run in other validation modes.
- [ ] AC-9: `Invoke-DocsValidation` with `-FamilyEvidence $null` and a profile declaring a required, non-excluded family fails closed with `DOCS_FAMILY_PAGE_MISSING`.
- [ ] AC-10: A profile with no `required_families` and no `legacy_exclusions` produces findings and `validation_result` identical to the pre-change behavior, and `Read-DocsFamilyEvidence` makes no `ListFile` or `TestFile` call for it.
- [ ] AC-11: A failing family check produces a receipt with `validation_result` `fail`, which the unchanged `enforce-docs-complete-gate.ps1` hook denies as `RECEIPT_FAILING`; `DocsCompleteGate.psm1`, the receipt schema, and the envelope schema are byte-identical to the base branch.

### Coverage report

- [ ] AC-12: The `coverage` command result always contains a `families` key with members `entries` and `legacy_exclusions`, produced by `Get-DocsCoverageFamilySection`; `Get-DocsCoverageReport` returns the same six keys as before (`totals`, `undocumented`, `deferred`, `precision_limits`, `stale_pages`, `parity`).
- [ ] AC-13: Each `entries` item has the keys `id`, `directory`, `required`, `template`, `status`, `page_count`, `missing_root_files`, `exclusion`, with `status` one of `present`, `missing`, `not-applicable`, in profile order; `legacy_exclusions` items have `path` and `reason`, sorted ordinally by `path`.
- [ ] AC-14: Coverage lines produced by `ConvertTo-DocsCoverageFamilyLine` (called from `ConvertTo-DocsCoverageReportLine`) are `families: required=<n> present=<n> missing=<n> not_applicable=<n> legacy_exclusions=<n>`, then `family <id> <status> pages=<n> <directory>` per entry with ` missing_root_files=<a,b>` appended when non-empty, then `legacy-exclusion <path>: <reason>` per legacy entry.
- [ ] AC-15: `tests/scripts/claude-lib/docs/DocsLedgerCommands.Tests.ps1` expects the sorted coverage result keys `deferred, families, parity, precision_limits, stale_pages, totals, undocumented` and passes.

### Fixtures (Risk R1)

- [x] AC-16: `New-DocsLedgerTestProfile` returns a profile with empty `required_families` and empty `legacy_exclusions` unless the opt-in parameters `-RequiredFamily` or `-LegacyExclusion` supply them, and every suite that uses it keeps its existing pass and fail assertions unchanged.
- [ ] AC-17: Every end-to-end docs-complete fixture built from `New-DocsStarterProfile` or `docs-init` outside that helper (at minimum `DocsCompleteIntegration.Tests.ps1`, `EndToEndDocumentationEstate.Tests.ps1`, and `tests/scripts/claude-hooks/docs-estate-workflow.EndToEnd.Tests.ps1`, plus any other found by a repository search for docs-complete runs, such as `DocsHashLineEnding.Tests.ps1`) either provides a `.md` page in each required family directory together with root `SECURITY.md` and `CODEOWNERS`, or records an `exclusion` per family, and its existing pass assertions keep passing without being removed or weakened. The plan lists each fixture found with its disposition.

### docs-plan-ia skill

- [ ] AC-18: The docs-plan-ia skill text exists in exactly 4 committed copies (`.agents/skills/docs-plan-ia/SKILL.md`, `.claude/skills/docs-plan-ia/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/docs-plan-ia/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/docs-plan-ia/SKILL.md`), and each copy contains, in its `Steps` section, a family-planning step that names `required_families`, the coverage `families` section, `SECURITY.md`, `CODEOWNERS`, `exclusion`, and `legacy_exclusions`, placed after the element-assignment steps; each `## Result` section contains family lines.
- [ ] AC-19: `tests/scripts/claude-runtime/docs-authoring-roles.WorkflowText.Tests.ps1` gains token rows for the family-planning step over all four roots of `Get-DocsAuthoringSkillRoot` and passes; the new skill text contains no runtime-specific path.

### MCP tools

- [ ] AC-20: Jest cases in `docs-handlers.test.ts` show that a `run_docs_coverage` envelope with a `families` result and a `validate_docs_artifacts` envelope with `DOCS_FAMILY_PAGE_MISSING` (error) and `DOCS_FAMILY_NOT_APPLICABLE` (info) pass through unchanged in `docs`, with summary counts reflecting the error and info findings.
- [ ] AC-21: The `run_docs_coverage` description in `mcp-docs-tool-definitions.ts` names the `families` section and the `validate_docs_artifacts` description names the family findings, asserted by a Jest case; no new TypeScript file is added; Jest per-file thresholds for `mcp-docs-tool-definitions.ts` and `docs-handlers.ts` remain 85% line and 75% branch and pass.

### Parity and quality gates

- [ ] AC-22: `scripts/harness-generation/Invoke-HarnessGeneration.ps1 -Check` reports no drift, and `HarnessGeneration.RepoGate.Tests.ps1` passes.
- [ ] AC-23: Each new or edited `.claude/lib/docs` module has a byte-identical bundle copy, the new module is listed in `pack-manifests/core.json`, and `Docs.Manifest.Tests.ps1`, `ClaudeLibModuleConvention.Tests.ps1`, `DocsNeutrality.Tests.ps1`, `FileSizePolicy.RepoGate.Tests.ps1`, and the push-down contract suites (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`) pass.
- [ ] AC-24: `.claude/lib/docs/DocsFamilyCheck.psm1` reaches at least 85% line coverage in `artifacts/pester/powershell-coverage.xml` from the launcher Pester run, and changed lines in `DocsValidation.psm1`, `DocsValidateCommands.psm1`, `DocsCoverageReport.psm1`, and `DocsLedgerCommands.psm1` do not regress against the pre-change baseline.
- [ ] AC-25: Every touched file is at or below 800 logical lines, `DocsLedgerCommands.psm1` grows by no more than about three lines, and no new or edited test creates a temporary file.
- [ ] AC-26: The full toolchain loop (format, lint, type check, architecture, unit, contract, integration in CI) passes in one clean pass through the parallel launcher, and the architecture document `.dev/engineering/documentation-estate/architecture.md` carries one bullet describing the family check.

## Definition of Done

- [ ] All acceptance criteria above checked off with evidence under `.dev/active/1221-docs-family-gate-and-ia/evidence/<kind>/`.
- [ ] Decisions recorded in this spec applied; any deviation recorded in the feature folder.
- [ ] Toolchain pass completed (format, lint, type check, architecture, unit, contract; integration in CI).

## Seeded Test Conditions (from potential)

- [ ] Pester unit coverage for the family check, the security root-file check, exclusion reporting, and legacy reporting.
- [ ] Jest coverage for the MCP tool output shape.
- [ ] Contract and parity tests for mirrored skill text.
