# docs-review-cadence — User Story

- Issue: #1220
- Parent: epic #1217 (documentation-estate-families), wave 2
- Owner: drmoisan
- Status: Ready for planning
- Last Updated: 2026-11-23
- Work Mode: full-feature (acceptance criteria sources: `spec.md` and this file)
- Design source: `research/research.2026-11-23T05-53.md` (decisions D1-D8); decisions recorded in `spec.md` `## Decisions`.

## Story Statement

- As a documentation owner, I want each page to carry a review due date, either explicit or derived from its family's review interval, so that pages are re-reviewed on a schedule even when their pinned source has not changed.
- As a repository maintainer, I want `validate -Mode docs-complete` to report pages whose review is overdue, and a profile option that makes that report block the docs-complete gate, so that I can choose between advisory and enforced review cadence per repository.
- As a page author, I want the page templates and the page checker to know about `review_due`, so that a new page starts with the field and an inconsistent date is reported before merge.

## Problem / Why

The docs library detects staleness only through evidence pins (`DOCS_STALE_PAGE` in `DocsStaleness.psm1`): a page is stale when the source it pins has changed. A production documentation estate also needs calendar review cadence: runbooks, security pages, and service-management pages must be re-reviewed on a schedule whether or not their pinned source changed. Pages carry `last_reviewed` but no review due date, and nothing reports a page whose review is overdue.

## Personas & Scenarios

- Persona: Documentation owner
  - Owns runbooks, security, and service-management pages in a destination repository.
  - Cares that operational pages are re-reviewed on a fixed interval.
  - Constraint: cannot track due dates by hand across many pages.
  - Goal: a single validation run that lists every page whose review is overdue.
- Persona: Repository maintainer
  - Configures the docs profile and the docs-complete merge gate.
  - Cares that the gate is predictable and that existing profiles keep working.
  - Goal: opt in to blocking on overdue reviews without changing the default behavior for other repositories.
- Persona: Page author
  - Creates pages from the `docs-author-page` templates.
  - Goal: fill in the review dates once and have mistakes reported by `check`.

- Scenario: Derived due date reported as a warning
  1. The profile defines a family with `directory: "docs/operations"` and `review_interval_days: 90`.
  2. `docs/operations/runbook.md` has `last_reviewed: "2026-01-10"` and no `review_due`.
  3. The maintainer runs `validate -Mode docs-complete`; the command instant is 2026-04-11T08:00:00Z.
  4. The output contains `DOCS_REVIEW_OVERDUE` (severity `warning`) for the runbook with due date 2026-04-10, source `interval`. The receipt records `pass` when no other error exists.
- Scenario: Maintainer enforces review cadence
  1. The maintainer sets `completion_gates.docs_complete.block_overdue_review: true`.
  2. The same run reports `DOCS_REVIEW_OVERDUE` with severity `error`, exits 1, and writes a receipt with `validation_result: fail`.
  3. The merge hook denies the integration PR with `RECEIPT_FAILING` until the owner reviews the page and updates `last_reviewed` and `review_due`.
- Scenario: Author enters inconsistent dates
  1. An author sets `last_reviewed: "2026-01-10"` and `review_due: "2026-01-10"`.
  2. `check` reports `DOCS_PAGE_REVIEW_DUE_NOT_AFTER_LAST_REVIEWED` at `/review_due`. `check` reads no clock.

## Acceptance Criteria

- [x] A page with `last_reviewed: "2026-01-10"` and `review_due: "2026-04-10"` passes the page checker with no finding for either date field, and a profile may list `review_due` in `diataxis_policy.required_front_matter`.
- [ ] Every `docs-author-page` page template on the integration tip, including the family templates from docs-family-page-templates, contains `review_due: "<review-due-yyyy-mm-dd>"` directly after `last_reviewed`, and passes the page checker after placeholder substitution.
- [x] A page whose `review_due` equals or precedes `last_reviewed` produces `DOCS_PAGE_REVIEW_DUE_NOT_AFTER_LAST_REVIEWED` (severity `error`) from `check`; a malformed or non-existent `review_due` produces `DOCS_PAGE_REVIEW_DUE_INVALID` or `DOCS_PAGE_REVIEW_DUE_NOT_A_DATE` respectively; `check` reads no clock.
- [ ] A page without `review_due` whose path falls under a family `directory` uses `last_reviewed` plus that family's `review_interval_days` as its due date (2026-01-10 plus 90 days yields 2026-04-10); a page with `review_due` uses the explicit value.
- [ ] A page with no covering family, a family without a positive integer `review_interval_days`, a profile without `required_families`, or a page listed in `legacy_exclusions[].path` produces no `DOCS_REVIEW_OVERDUE` finding.
- [ ] `validate -Mode docs-complete` reports `DOCS_REVIEW_OVERDUE` for a page due 2026-04-10 when the injected command instant falls on 2026-04-11 (UTC) and reports none when it falls on 2026-04-10; tests supply these fixed instants and no tested code reads the wall clock.
- [ ] With `completion_gates.docs_complete.block_overdue_review` absent or `false`, `DOCS_REVIEW_OVERDUE` is a `warning` and does not fail the receipt; with `true` it is an `error`, the receipt records `validation_result: fail`, the command exits 1, and `Test-DocsCompleteGateReceipt` returns `Reason = 'RECEIPT_FAILING'`.
- [ ] Existing profiles without `block_overdue_review` and existing pages without `review_due` validate as before, and the starter profile is unchanged.
- [ ] `DOCS_STALE_PAGE` behavior is unchanged: `DocsStaleness.psm1` has no diff and its existing tests pass unmodified.
- [ ] Regenerating a reference page keeps its `review_due` value.
- [ ] Claude, Codex, and bundle copies stay in parity per `config/harness-parity-matrix.json` (the Copilot `docs-author-page` entry is `dropped`): `Invoke-HarnessGeneration.ps1 -Check` reports no drift, docs lib and schema copies are byte-identical, and `core.json` lists `DocsReviewCadence.psm1`.

## Non-Goals

- Adding the overdue check to the `check` command or any clock read outside `Invoke-DocsCommand.ps1`.
- Changing `DocsCompleteGate.psm1`, the merge hook, or the receipt schema.
- Re-evaluating a passing receipt in the merge hook as time passes.
- Changing `DOCS_STALE_PAGE`, `DocsStaleness.psm1`, or `max_stale_pages` semantics.
- Defining the family record, the legacy exclusion list, or the family templates (owned by the upstream features).
- Adding `block_overdue_review` to the starter profile, or any MCP or TypeScript parameter.
