# docs-review-cadence — Spec

- **Issue:** #1220
- **Parent (optional):** epic #1217 (documentation-estate-families), wave 2
- **Branch:** feature/docs-review-cadence-1220
- **Owner:** drmoisan
- **Last Updated:** 2026-11-23
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** full-feature (acceptance criteria sources: this file and `user-story.md`)
- **Design source:** `.dev/active/1220-docs-review-cadence/research/research.2026-11-23T05-53.md` (decisions D1-D8, section 9 Recommended Design, Requirements Mapping); `.dev/epics/documentation-estate-families/epic.md` `## Shared Design` (Family record, Review cadence).

## Overview

The docs library detects staleness only through evidence pins (`DOCS_STALE_PAGE` in `DocsStaleness.psm1`): a page is stale when the source it pins has changed. A production documentation estate also needs calendar review cadence: runbooks, security pages, and service-management pages must be re-reviewed on a schedule whether or not their pinned source changed. Pages carry `last_reviewed` but no review due date, and nothing reports a page whose review is overdue.

This feature adds the `review_due` front-matter field, validates its ordering against `last_reviewed`, derives a default due date from the family `review_interval_days`, reports overdue pages during `validate -Mode docs-complete` against the command's injected clock instant, and adds a profile option that turns the overdue finding from a warning into a blocking error. `DOCS_STALE_PAGE` is not changed.

## Decisions

All decisions were taken in autonomous mode with the recommended option. Each cites the research record `research/research.2026-11-23T05-53.md`.

| ID | Decision | Research reference |
|---|---|---|
| D1 | The overdue option is evaluated in the docs-complete layer of `Invoke-DocsValidation` (`DocsValidation.psm1`), directly after the completion-gate findings produced by `Get-DocsCompletionGateFinding`, which is where the upstream family check lands. `DocsCompleteGate.psm1` is not changed. A blocking overdue finding has severity `error`, so the validation receipt records `validation_result: fail`, and the merge hook `enforce-docs-complete-gate.ps1` denies through the existing `RECEIPT_FAILING` path of `Test-DocsCompleteGateReceipt`. This is the interpretation of the issue wording "the option is evaluated in `DocsCompleteGate.psm1` after the family check": the gate option takes effect at the docs-complete gate through the receipt, not through an edit of the hook predicate module, which never sees page findings. | D1; sections 2 and 9 (Rejected alternatives) |
| D2 | The ordering check (`review_due` later than `last_reviewed`) is part of the page checker (`Test-DocsPageFrontMatter` through `Get-DocsPageValueFinding` in `DocsPageMetadata.psm1`). The overdue check is not added to the `check` command; `Invoke-DocsCheckCommand` continues to never read `Context.UtcNow`. | D2; section 1 |
| D3 | The clock instant is the instant `Invoke-DocsValidateCommand` already reads (`Get-DocsLedgerCommandTimestamp -UtcNow $Context.UtcNow`, passed on as `IssuedAt`). The reference date is the UTC calendar date of `IssuedAt`. No second clock read and no wall-clock read in tested code. | D3; section 3 |
| D4 | Profile key `completion_gates.docs_complete.block_overdue_review`, an optional boolean declared in `docs-profile.schema.json`. Absent or `false` produces severity `warning`; `true` produces severity `error`. `New-DocsStarterProfile` is not changed. | D4; section 2 |
| D5 | Strict ordering: `review_due` must be later than `last_reviewed` (equal is a finding). Strict overdue: a page is overdue when its effective due date is earlier than the reference date; a due date equal to the reference date is not overdue. | D5; section 7 |
| D6 | Family lookup is defensive: when the profile has no `required_families` array, when no family `directory` covers the page, or when the family has no integer `review_interval_days` of at least 1, the page has no derived due date and produces no overdue finding. Pages listed in `legacy_exclusions[].path`, when that list is present, are skipped by the overdue check. | D6; section 4 |
| D7 | The reference generator (`DocsReferenceFrontMatter.psm1`) preserves `review_due` when a reference page is regenerated. | D7 |
| D8 | No TypeScript change. The option is profile data and the clock is read inside `Invoke-DocsCommand.ps1`; the MCP `validate_docs_artifacts` mapping is unchanged. | D8; section 8 |
| D9 | Finding codes are those of research section 9: `DOCS_PAGE_REVIEW_DUE_INVALID`, `DOCS_PAGE_REVIEW_DUE_NOT_A_DATE`, `DOCS_PAGE_REVIEW_DUE_NOT_AFTER_LAST_REVIEWED` (page checker, `error`), `DOCS_REVIEW_OVERDUE` (docs-complete validation, `warning` by default, `error` with `block_overdue_review: true`), and `DOCS_REVIEW_CLOCK_INVALID` (thrown defect guard, exit 3). `DOCS_STALE_PAGE` is unchanged. | Section 9 Finding codes |
| D10 | Parity: page templates and `docs-author-page/SKILL.md` are edited in the `.agents/skills/docs-author-page/` source and propagated by `scripts/harness-generation/Invoke-HarnessGeneration.ps1`; docs lib modules and schema files are copied byte-identically to every copy; the new module is listed in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`. | Section 5 |

## Upstream Dependency

- The family record (`required_families[]` with `directory` and `review_interval_days`), the `legacy_exclusions[]` list, the family check in the docs-complete layer, and the family page templates are added by the upstream features docs-family-profile-model, docs-family-gate-and-ia, and docs-family-page-templates. None of them is on this branch at the time of writing (research header).
- At execution time this branch is based on an integration tip that contains those upstream features. The plan must include a verification task that reads the merged `docs-profile.schema.json` and confirms the `directory` base of a family record (repository-relative versus documentation-root-relative); if it differs from the repository-relative assumption, the family matcher and its tests are adjusted in the same change (research section 4).
- The plan must add `review_due` to the family templates added by docs-family-page-templates as well as to the existing templates, and must update the template contract test row set to the templates present on the integration tip.
- Because of D6, the feature's own tests pass with and without upstream family data in the profile.

## Behavior

- `review_due` is an accepted page front-matter field (`page-metadata.schema.json` property, `$ref` to `common#/$defs/review-date`) and a member of the profile-side `front-matter-field` enum (`common.schema.json`), so a profile may list it in `diataxis_policy.required_front_matter`.
- The page checker validates `review_due` format (`DOCS_PAGE_REVIEW_DUE_INVALID`), calendar validity (`DOCS_PAGE_REVIEW_DUE_NOT_A_DATE`), and, when both dates are valid calendar dates, strict ordering (`DOCS_PAGE_REVIEW_DUE_NOT_AFTER_LAST_REVIEWED` at pointer `/review_due`). All three are `error`.
- The effective due date of a page is its explicit `review_due` when present; otherwise `last_reviewed` plus the `review_interval_days` of the family whose `directory` covers the page path (longest directory match at a `/` boundary, ordinal comparison); otherwise none.
- During `validate -Mode docs-complete`, after the completion-gate findings, the validator reads the front matter of every `.md` page in the page-path set and emits one `DOCS_REVIEW_OVERDUE` finding per page whose effective due date is earlier than the reference date (UTC calendar date of `IssuedAt`). Pages without a due date, pages whose front matter fails to parse, pages whose `review_due` is not later than `last_reviewed`, and pages in `legacy_exclusions[].path` are skipped.
- The severity of `DOCS_REVIEW_OVERDUE` is `warning` unless `completion_gates.docs_complete.block_overdue_review` is the boolean `true`, in which case it is `error`, the receipt records `validation_result: fail`, and the command exits 1.
- `DOCS_STALE_PAGE` and `Get-DocsStalenessFinding` keep their current behavior.

## Inputs / Outputs

- Inputs:
  - Page front matter: `last_reviewed` (existing), `review_due` (new, optional, `YYYY-MM-DD`).
  - Profile: `completion_gates.docs_complete.block_overdue_review` (new, optional boolean); `required_families[].directory` and `required_families[].review_interval_days` (upstream, optional to this feature); `legacy_exclusions[].path` (upstream, optional to this feature).
  - Clock: the command context `UtcNow` member, read once by `Invoke-DocsValidateCommand` into `IssuedAt`.
- Outputs:
  - New findings in the page checker output and the docs-complete validation output and receipt finding list.
  - Receipt `validation_result` reflects a blocking overdue finding. No receipt schema change; receipt counts are unchanged.
- Config keys and defaults: `block_overdue_review` absent = `false` = warning.
- Backward compatibility: the new profile key and front-matter field are optional; every existing profile, example profile, and page remains valid. The starter profile is unchanged.

## API / CLI Surface

- No new command, flag, or MCP parameter.
- `Invoke-DocsCommand.ps1 -Command check`: may now report the three `DOCS_PAGE_REVIEW_DUE_*` codes; still reads no clock.
- `Invoke-DocsCommand.ps1 -Command validate -Mode docs-complete`: may now report `DOCS_REVIEW_OVERDUE`.
- `Invoke-DocsValidation` gains an optional `[AllowNull()] [System.Collections.IDictionary] $PageFrontMatter` parameter; callers that omit it get no overdue evaluation.
- New module `.claude/lib/docs/DocsReviewCadence.psm1` (pure; imports `DocsFinding`, `DocsPageFrontMatter`) exporting:
  - `ConvertFrom-DocsReviewDate -Value [string]` -> UTC-kind `[datetime]` or `$null`.
  - `Get-DocsReviewReferenceDate -IssuedAt [string]` -> UTC date of a `yyyy-MM-ddTHH:mm:ssZ` value; throws `DOCS_REVIEW_CLOCK_INVALID` otherwise.
  - `Get-DocsReviewIntervalDays -PagePath [string] -Family [object[]]` -> interval or `$null`.
  - `Get-DocsPageReviewDue -FrontMatter [IDictionary] -PagePath [string] -Family [object[]]` -> `@{ DueDate; Source }`, `Source` in `review_due`, `interval`, `$null`.
  - `Get-DocsReviewPageFrontMatter -PagePath [string[]] -ReadText [scriptblock]` -> ordinal hashtable of page path to parsed front matter.
  - `Get-DocsReviewOverdueFinding -PageFrontMatter -Family -LegacyExclusion -ReferenceDate -Severity` -> ordered `DOCS_REVIEW_OVERDUE` findings.
  - `Get-DocsReviewOverdueSeverity -Gate [IDictionary]` -> `error` or `warning`.

## Data & State

- `DOCS_REVIEW_OVERDUE` finding: `artifact_path` = page path; `pointer` = `/review_due` when the due date is explicit, `/last_reviewed` when derived; `message` names the due date, its source, and the reference date; `next_action` = "Review the page, then update last_reviewed and review_due."
- Dates are parsed with `ParseExact`/`TryParseExact` (`yyyy-MM-dd`, `InvariantCulture`) and carried as UTC-kind values.
- No persistence, cache, migration, or backfill. Existing pages without `review_due` and without a matching family produce no new finding.
- A passing receipt is not re-evaluated by the merge hook as time passes; a page that becomes overdue after the receipt write is reported on the next `validate` run (research section 9 Risks).

## Implementation Strategy

- Schemas (three copies each: `schemas/docs/v1/`, `.claude/lib/docs/schemas/v1/`, claude bundle): `page-metadata.schema.json`, `common.schema.json`, `docs-profile.schema.json`.
- `DocsPageMetadata.psm1`: field code, next actions, calendar and ordering checks in `Get-DocsPageValueFinding` through a private helper `Get-DocsPageReviewDateFinding`. `DocsPageFrontMatter.psm1`: docstring of `Test-DocsPageFrontMatter` only.
- New `DocsReviewCadence.psm1` (estimated 180-250 lines).
- `DocsValidation.psm1`: docs-complete wiring after the `Get-DocsCompletionGateFinding` loop.
- `DocsValidateCommands.psm1`: build `$pageFrontMatter` in docs-complete mode with `$Context.ReadText`; read failures propagate to the existing catch (exit 3, `DOCS_CLI_RUNTIME`).
- `DocsReferenceFrontMatter.psm1`: preserve `review_due`; key order owner, last_reviewed, review_due, audience, diataxis_mode, surface_refs, title, extensions.
- Templates and `SKILL.md` step 1 in `.agents/skills/docs-author-page/`, then `Invoke-HarnessGeneration.ps1`. Placeholder `review_due: "<review-due-yyyy-mm-dd>"` directly after `last_reviewed`.
- `core.json` and bundle copies for every changed or new docs lib file.
- Unchanged: `DocsCompleteGate.psm1`, `DocsStaleness.psm1`, `DocsPageCheck.psm1`, `Invoke-DocsCommand.ps1`, TypeScript sources.
- Dependency changes: none. Logging: none beyond findings.
- New test cases go into new test files: `DocsReviewCadence.Tests.ps1`, `DocsValidation.ReviewCadence.Tests.ps1`, `DocsValidateCommands.ReviewCadence.Tests.ps1`, and a new page-metadata review-date test file. Existing tests are updated in place only where a pinned contract changes (schema property list, template key set and substitution, reference `FieldOrder`, reference `review_due` preservation), with the reason stated in the plan.

## Non-Functional Requirements

- PowerShell 7.4 only for library and test code. No new Python file or Python logic. No TypeScript change.
- Tested code reads no wall clock; the only clock read remains `New-DocsCommandContext` in `Invoke-DocsCommand.ps1`. Tests pass fixed UTC `[datetime]` instants through `New-DocsLedgerTestContext -UtcNow` or direct parameters.
- Tests create no temporary files; page text and profiles are supplied in memory through `ReadText` scriptblocks and literal strings.
- Per-file line coverage >= 85% for `DocsReviewCadence.psm1` and every changed PowerShell production file, read from the single parallel gate run.
- Every new or changed file stays at or below 800 lines; production files are expected to stay below 500.
- Test runs are parallel only (`Invoke-PoshQCParallelTest` through the launcher); no serial, single-process, shuffled, or reversed runs.
- Evidence is written under `.dev/active/1220-docs-review-cadence/evidence/<kind>/`, append-only, with clock-read UTC timestamps.

## Constraints & Risks

- Upstream drift in the family record shape or `directory` base; mitigated by D6 and the rebase verification task.
- Merge overlap with docs-family-gate-and-ia in `Invoke-DocsValidation` and with docs-family-page-templates in the templates and `docs-authoring-roles.Templates.Tests.ps1`; the wave ordering serializes them.
- Reading every page in docs-complete adds one read per `.md` file, bounded by the existing page-path listing.
- Culture- or kind-dependent date parsing that passes on Windows and fails on Linux CI; mitigated by `InvariantCulture`, UTC-kind values, and forward-slash relative paths.
- Module state leaking between test files; mitigated by adding `DocsReviewCadence` to the existing `AfterAll` `Remove-Module` lists.

## Acceptance Criteria

- [x] `page-metadata.schema.json` declares a `review_due` property that references `urn:drm-copilot:docs:1.0.0:common#/$defs/review-date`, and `Test-DocsPageFrontMatter` returns no `DOCS_PAGE_FIELD_UNKNOWN` finding for a page that carries `last_reviewed: "2026-01-10"` and `review_due: "2026-04-10"`.
- [x] `common.schema.json` `$defs/front-matter-field` includes `review_due`, and a profile listing `review_due` in `diataxis_policy.required_front_matter` loads through `ConvertFrom-DocsProfileText` without a schema finding.
- [x] `Test-DocsPageFrontMatter` reports `DOCS_PAGE_REVIEW_DUE_INVALID` (severity `error`, pointer `/review_due`) for `review_due: "2026/04/10"` and `DOCS_PAGE_REVIEW_DUE_NOT_A_DATE` (severity `error`, pointer `/review_due`) for `review_due: "2026-02-30"`.
- [x] With `last_reviewed: "2026-01-10"`, `Test-DocsPageFrontMatter` reports `DOCS_PAGE_REVIEW_DUE_NOT_AFTER_LAST_REVIEWED` (severity `error`, pointer `/review_due`) for `review_due` values `2026-01-10` and `2026-01-09`, and reports no `DOCS_PAGE_REVIEW_DUE_*` finding for `2026-01-11`; no ordering finding is emitted when either date is not a valid calendar date.
- [x] `Invoke-DocsCheckCommand` reports the `DOCS_PAGE_REVIEW_DUE_*` codes for affected pages, and the existing `DocsPageCheck.Tests.ps1` context whose `UtcNow` throws `check must not read the clock` still passes.
- [x] `Get-DocsPageReviewDue` returns `Source = 'review_due'` and the explicit date when `review_due` is present, even when a matching family defines `review_interval_days`.
- [x] `Get-DocsPageReviewDue` returns `DueDate = 2026-04-10` and `Source = 'interval'` for a page `docs/operations/runbook.md` with `last_reviewed: "2026-01-10"`, no `review_due`, and a family with `directory: "docs/operations"` and `review_interval_days: 90`.
- [x] `Get-DocsReviewIntervalDays` selects the family with the longest `directory` that prefixes the page path at a `/` boundary using ordinal comparison, and does not match `docs/ops` against `docs/operations/runbook.md`.
- [x] `Get-DocsPageReviewDue` returns `DueDate = $null` and `Get-DocsReviewOverdueFinding` emits no finding when the family list is empty, when no family directory covers the page, or when `review_interval_days` is absent, non-integer, or less than 1; a page listed in `legacy_exclusions[].path` produces no `DOCS_REVIEW_OVERDUE` finding.
- [x] `Get-DocsReviewReferenceDate -IssuedAt '2026-04-11T23:59:59Z'` returns the UTC date 2026-04-11, and a value that is not `yyyy-MM-ddTHH:mm:ssZ` throws an error whose text contains `DOCS_REVIEW_CLOCK_INVALID`.
- [x] `Get-DocsReviewOverdueFinding` emits exactly one `DOCS_REVIEW_OVERDUE` finding for a page due 2026-04-10 at reference date 2026-04-11 and no finding at reference date 2026-04-10; the finding pointer is `/review_due` for an explicit due date and `/last_reviewed` for a derived due date, and the message names the due date, its source, and the reference date.
- [x] `Invoke-DocsValidateCommand -Mode docs-complete`, run with `New-DocsLedgerTestContext -UtcNow` set to a fixed UTC instant and in-memory page text, reports `DOCS_REVIEW_OVERDUE` for an overdue page and none when the same page is evaluated at its due date.
- [x] `DOCS_REVIEW_OVERDUE` is not emitted in `profile`, `ledger`, or `matrix` modes, and `Invoke-DocsValidation` called without `-PageFrontMatter` emits no `DOCS_REVIEW_OVERDUE` finding.
- [x] `docs-profile.schema.json` declares `completion_gates.docs_complete.block_overdue_review` as an optional boolean: a profile without the key and a profile with `false` or `true` load without a schema finding, and a profile with a non-boolean value is rejected with a schema finding.
- [x] In `validate -Mode docs-complete`, `DOCS_REVIEW_OVERDUE` has severity `warning` and the receipt `validation_result` is `pass` (when no other error exists) for `block_overdue_review` absent and `false`; with `block_overdue_review: true` the finding has severity `error`, the receipt `validation_result` is `fail`, and the command exits 1.
- [x] A receipt whose `validation_result` is `fail` because of a blocking `DOCS_REVIEW_OVERDUE` finding causes `Test-DocsCompleteGateReceipt` to return `Allow = $false` with `Reason = 'RECEIPT_FAILING'`, and `DocsCompleteGate.psm1` has no diff against the integration base.
- [x] `DocsStaleness.psm1` has no diff against the integration base, `DOCS_STALE_PAGE` severity rules (error above `max_stale_pages`, warning otherwise) are unchanged, and the existing `DocsStaleness.Tests.ps1`, `DocsStaleness.Properties.Tests.ps1`, and `DocsValidation.Tests.ps1` pass without modification.
- [x] Regenerating a reference page through `DocsReferenceFrontMatter.psm1` preserves an existing `review_due` value and writes keys in the order owner, last_reviewed, review_due, audience, diataxis_mode, surface_refs, title, extensions; a page without `review_due` is written without the key.
- [x] Every template file under `.agents/skills/docs-author-page/templates/` on the integration tip, including the family templates added by docs-family-page-templates, contains `review_due: "<review-due-yyyy-mm-dd>"` on the line directly after `last_reviewed`, and `docs-authoring-roles.Templates.Tests.ps1` asserts the key set includes `review_due` and that each template passes the page checker after placeholder substitution.
- [x] `docs-author-page/SKILL.md` step 1 names `review_due` and states that it may be omitted when the page's family defines `review_interval_days`.
- [x] Parity holds: `Invoke-HarnessGeneration.ps1 -Check` reports no drift; every changed docs lib and schema file is byte-identical across its copies; `core.json` lists `DocsReviewCadence.psm1`; `Docs.Manifest.Tests.ps1`, `DocsSchemaContract.Tests.ps1`, `HarnessGeneration.RepoGate.Tests.ps1`, and the push-down resource and pack-manifest contract tests pass.
- [x] No file under `extensions/drm-copilot/src/` changes and no new Python file is added.
- [x] No wall-clock read (`Get-Date`, `[datetime]::Now`, `[datetime]::UtcNow`, `DateTimeOffset.Now`, `DateTimeOffset.UtcNow`) appears in `DocsReviewCadence.psm1` or any changed docs lib module, and the new tests create no temporary files.
- [x] Per-file line coverage is at least 85% for `DocsReviewCadence.psm1` and each changed PowerShell production file in the parallel gate run, and every new or changed file is at or below 800 lines.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests
- [ ] Behavior matches acceptance criteria on Windows and on the Linux CI runner
- [ ] Tests added in new test files; existing pinned-contract tests updated with stated reasons
- [ ] Edge cases (boundary instants, absent families, invalid intervals, legacy exclusions) covered by tests
- [ ] `docs-author-page/SKILL.md` updated through the generator
- [ ] Toolchain pass completed (format, lint, test) with parallel test runs only

## Seeded Test Conditions (from potential)

- [ ] Unit coverage of due-date derivation, ordering validation, overdue detection at boundary instants.
- [ ] docs-complete gate behavior under both option values.
- [ ] Template front-matter contract tests.
