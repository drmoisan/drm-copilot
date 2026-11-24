# Feature Audit: docs-review-cadence (#1220)

---

**Audit Date:** 2026-11-24
**Feature Folder:** `.dev/active/1220-docs-review-cadence`
**Base Branch:** `epic/documentation-estate-families-integration`
**Head Branch:** `feature/docs-review-cadence-1220`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/epic/documentation-estate-families-integration` (commit `095a4ae13b4ecf5c9fa2fd13e206c6a300fe1844`)
- **Head branch/commit:** `feature/docs-review-cadence-1220` (commit `63486a5455a60ba62655f47534783ed74fd2a6a5`)
- **Merge base:** `095a4ae13b4ecf5c9fa2fd13e206c6a300fe1844`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-24 17:33:28 UTC, Head SHA `63486a545`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `.dev/active/1220-docs-review-cadence/evidence/**` (baseline, qa-gates, other)
  - Additional evidence: direct inspection of the branch diff and of the test files at head
- **Feature folder used:** `.dev/active/1220-docs-review-cadence`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-feature`; AC sources are `spec.md` `## Acceptance Criteria` and `user-story.md` `## Acceptance Criteria`.
- **Scope note:** The merge base equals the integration tip, so the #1223 files brought in by the merge commit `63486a545` are not part of the diff. Final-QC runs executed at `cf8268013`; between `cf8268013` and `63486a545` the docs paths gained only the #1223 test file `documentation-workflow.EpicRouting.Tests.ps1`. Per-child CI is not run for this epic child (owner instruction relayed 2026-11-24).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `.dev/active/1220-docs-review-cadence/spec.md`: primary source (24 criteria)
- `.dev/active/1220-docs-review-cadence/user-story.md`: secondary source (11 criteria)

### From spec.md

1. `page-metadata.schema.json` declares a `review_due` property that references `urn:drm-copilot:docs:1.0.0:common#/$defs/review-date`, and `Test-DocsPageFrontMatter` returns no `DOCS_PAGE_FIELD_UNKNOWN` finding for a page that carries `last_reviewed: "2026-01-10"` and `review_due: "2026-04-10"`.
2. `common.schema.json` `$defs/front-matter-field` includes `review_due`, and a profile listing `review_due` in `diataxis_policy.required_front_matter` loads through `ConvertFrom-DocsProfileText` without a schema finding.
3. `Test-DocsPageFrontMatter` reports `DOCS_PAGE_REVIEW_DUE_INVALID` (severity `error`, pointer `/review_due`) for `review_due: "2026/04/10"` and `DOCS_PAGE_REVIEW_DUE_NOT_A_DATE` (severity `error`, pointer `/review_due`) for `review_due: "2026-02-30"`.
4. With `last_reviewed: "2026-01-10"`, `Test-DocsPageFrontMatter` reports `DOCS_PAGE_REVIEW_DUE_NOT_AFTER_LAST_REVIEWED` (severity `error`, pointer `/review_due`) for `review_due` values `2026-01-10` and `2026-01-09`, and reports no `DOCS_PAGE_REVIEW_DUE_*` finding for `2026-01-11`; no ordering finding is emitted when either date is not a valid calendar date.
5. `Invoke-DocsCheckCommand` reports the `DOCS_PAGE_REVIEW_DUE_*` codes for affected pages, and the existing `DocsPageCheck.Tests.ps1` context whose `UtcNow` throws `check must not read the clock` still passes.
6. `Get-DocsPageReviewDue` returns `Source = 'review_due'` and the explicit date when `review_due` is present, even when a matching family defines `review_interval_days`.
7. `Get-DocsPageReviewDue` returns `DueDate = 2026-04-10` and `Source = 'interval'` for a page `docs/operations/runbook.md` with `last_reviewed: "2026-01-10"`, no `review_due`, and a family with `directory: "docs/operations"` and `review_interval_days: 90`.
8. `Get-DocsReviewIntervalDays` selects the family with the longest `directory` that prefixes the page path at a `/` boundary using ordinal comparison, and does not match `docs/ops` against `docs/operations/runbook.md`.
9. `Get-DocsPageReviewDue` returns `DueDate = $null` and `Get-DocsReviewOverdueFinding` emits no finding when the family list is empty, when no family directory covers the page, or when `review_interval_days` is absent, non-integer, or less than 1; a page listed in `legacy_exclusions[].path` produces no `DOCS_REVIEW_OVERDUE` finding.
10. `Get-DocsReviewReferenceDate -IssuedAt '2026-04-11T23:59:59Z'` returns the UTC date 2026-04-11, and a value that is not `yyyy-MM-ddTHH:mm:ssZ` throws an error whose text contains `DOCS_REVIEW_CLOCK_INVALID`.
11. `Get-DocsReviewOverdueFinding` emits exactly one `DOCS_REVIEW_OVERDUE` finding for a page due 2026-04-10 at reference date 2026-04-11 and no finding at reference date 2026-04-10; the finding pointer is `/review_due` for an explicit due date and `/last_reviewed` for a derived due date, and the message names the due date, its source, and the reference date.
12. `Invoke-DocsValidateCommand -Mode docs-complete`, run with `New-DocsLedgerTestContext -UtcNow` set to a fixed UTC instant and in-memory page text, reports `DOCS_REVIEW_OVERDUE` for an overdue page and none when the same page is evaluated at its due date.
13. `DOCS_REVIEW_OVERDUE` is not emitted in `profile`, `ledger`, or `matrix` modes, and `Invoke-DocsValidation` called without `-PageFrontMatter` emits no `DOCS_REVIEW_OVERDUE` finding.
14. `docs-profile.schema.json` declares `completion_gates.docs_complete.block_overdue_review` as an optional boolean: a profile without the key and a profile with `false` or `true` load without a schema finding, and a profile with a non-boolean value is rejected with a schema finding.
15. In `validate -Mode docs-complete`, `DOCS_REVIEW_OVERDUE` has severity `warning` and the receipt `validation_result` is `pass` (when no other error exists) for `block_overdue_review` absent and `false`; with `block_overdue_review: true` the finding has severity `error`, the receipt `validation_result` is `fail`, and the command exits 1.
16. A receipt whose `validation_result` is `fail` because of a blocking `DOCS_REVIEW_OVERDUE` finding causes `Test-DocsCompleteGateReceipt` to return `Allow = $false` with `Reason = 'RECEIPT_FAILING'`, and `DocsCompleteGate.psm1` has no diff against the integration base.
17. `DocsStaleness.psm1` has no diff against the integration base, `DOCS_STALE_PAGE` severity rules (error above `max_stale_pages`, warning otherwise) are unchanged, and the existing `DocsStaleness.Tests.ps1`, `DocsStaleness.Properties.Tests.ps1`, and `DocsValidation.Tests.ps1` pass without modification.
18. Regenerating a reference page through `DocsReferenceFrontMatter.psm1` preserves an existing `review_due` value and writes keys in the order owner, last_reviewed, review_due, audience, diataxis_mode, surface_refs, title, extensions; a page without `review_due` is written without the key.
19. Every template file under `.agents/skills/docs-author-page/templates/` on the integration tip, including the family templates added by docs-family-page-templates, contains `review_due: "<review-due-yyyy-mm-dd>"` on the line directly after `last_reviewed`, and `docs-authoring-roles.Templates.Tests.ps1` asserts the key set includes `review_due` and that each template passes the page checker after placeholder substitution.
20. `docs-author-page/SKILL.md` step 1 names `review_due` and states that it may be omitted when the page's family defines `review_interval_days`.
21. Parity holds: `Invoke-HarnessGeneration.ps1 -Check` reports no drift; every changed docs lib and schema file is byte-identical across its copies; `core.json` lists `DocsReviewCadence.psm1`; `Docs.Manifest.Tests.ps1`, `DocsSchemaContract.Tests.ps1`, `HarnessGeneration.RepoGate.Tests.ps1`, and the push-down resource and pack-manifest contract tests pass.
22. No file under `extensions/drm-copilot/src/` changes and no new Python file is added.
23. No wall-clock read (`Get-Date`, `[datetime]::Now`, `[datetime]::UtcNow`, `DateTimeOffset.Now`, `DateTimeOffset.UtcNow`) appears in `DocsReviewCadence.psm1` or any changed docs lib module, and the new tests create no temporary files.
24. Per-file line coverage is at least 85% for `DocsReviewCadence.psm1` and each changed PowerShell production file in the parallel gate run, and every new or changed file is at or below 800 lines.

### From user-story.md

25. A page with `last_reviewed: "2026-01-10"` and `review_due: "2026-04-10"` passes the page checker with no finding for either date field, and a profile may list `review_due` in `diataxis_policy.required_front_matter`.
26. Every `docs-author-page` page template on the integration tip, including the family templates from docs-family-page-templates, contains `review_due: "<review-due-yyyy-mm-dd>"` directly after `last_reviewed`, and passes the page checker after placeholder substitution.
27. A page whose `review_due` equals or precedes `last_reviewed` produces `DOCS_PAGE_REVIEW_DUE_NOT_AFTER_LAST_REVIEWED` (severity `error`) from `check`; a malformed or non-existent `review_due` produces `DOCS_PAGE_REVIEW_DUE_INVALID` or `DOCS_PAGE_REVIEW_DUE_NOT_A_DATE` respectively; `check` reads no clock.
28. A page without `review_due` whose path falls under a family `directory` uses `last_reviewed` plus that family's `review_interval_days` as its due date (2026-01-10 plus 90 days yields 2026-04-10); a page with `review_due` uses the explicit value.
29. A page with no covering family, a family without a positive integer `review_interval_days`, a profile without `required_families`, or a page listed in `legacy_exclusions[].path` produces no `DOCS_REVIEW_OVERDUE` finding.
30. `validate -Mode docs-complete` reports `DOCS_REVIEW_OVERDUE` for a page due 2026-04-10 when the injected command instant falls on 2026-04-11 (UTC) and reports none when it falls on 2026-04-10; tests supply these fixed instants and no tested code reads the wall clock.
31. With `completion_gates.docs_complete.block_overdue_review` absent or `false`, `DOCS_REVIEW_OVERDUE` is a `warning` and does not fail the receipt; with `true` it is an `error`, the receipt records `validation_result: fail`, the command exits 1, and `Test-DocsCompleteGateReceipt` returns `Reason = 'RECEIPT_FAILING'`.
32. Existing profiles without `block_overdue_review` and existing pages without `review_due` validate as before, and the starter profile is unchanged.
33. `DOCS_STALE_PAGE` behavior is unchanged: `DocsStaleness.psm1` has no diff and its existing tests pass unmodified.
34. Regenerating a reference page keeps its `review_due` value.
35. Claude, Codex, and bundle copies stay in parity per `config/harness-parity-matrix.json` (the Copilot `docs-author-page` entry is `dropped`): `Invoke-HarnessGeneration.ps1 -Check` reports no drift, docs lib and schema copies are byte-identical, and `core.json` lists `DocsReviewCadence.psm1`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | `review_due` schema property; no `DOCS_PAGE_FIELD_UNKNOWN` | PASS | Diff of `page-metadata.schema.json` adds `review_due` with the `review-date` `$ref`; `DocsPageMetadata.ReviewDate.Tests.ps1` `It 'accepts last_reviewed 2026-01-10 with review_due 2026-04-10'` | `git diff 095a4ae13..HEAD -- .claude/lib/docs/schemas/v1/page-metadata.schema.json` | Full gate 0 failures |
| 2 | `front-matter-field` enum and profile load | PASS | `common.schema.json` diff adds the enum member; `DocsProfile.ReviewCadence.Tests.ps1` line 37 | `git diff ... -- common.schema.json` | |
| 3 | INVALID and NOT_A_DATE codes | PASS | `DocsPageMetadata.ReviewDate.Tests.ps1` line 60 (`-ForEach` over both values, asserts severity and pointer) | inspection of test file | |
| 4 | Strict ordering and no ordering finding on invalid dates | PASS | `DocsPageMetadata.ReviewDate.Tests.ps1` lines 60, 77, 82; implementation `Get-DocsPageReviewDateFinding` | inspection | |
| 5 | `check` reports codes; clock-throwing context still passes | PASS | `DocsPageCheck.Tests.ps1` line 119 `UtcNow = { throw 'check must not read the clock' }` and line 340 code list including the three codes | `grep -n "must not read the clock" tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1` | |
| 6 | Explicit `review_due` wins | PASS | `Get-DocsPageReviewDue` lines 153-158 return before family lookup; `DocsReviewCadence.Tests.ps1` | inspection | |
| 7 | Derived 2026-04-10 with source `interval` | PASS | `DocsReviewCadence.Tests.ps1`; end-to-end `DocsValidateCommands.ReviewCadence.Tests.ps1` line 191 | inspection | Profile loaded from JSON text |
| 8 | Longest `/`-boundary ordinal prefix; `docs/ops` no match | PASS | `Get-DocsReviewIntervalDays` lines 120-132 (`StartsWith($directory + '/', Ordinal)`); `DocsReviewCadence.Tests.ps1` | inspection | |
| 9 | No due date or finding for absent families, uncovered page, invalid interval, legacy exclusion | PASS | `DocsReviewCadence.Tests.ps1`; `DocsValidation.ReviewCadence.Tests.ps1` lines 178, 207 | inspection | |
| 10 | Reference date and `DOCS_REVIEW_CLOCK_INVALID` | PASS | `Get-DocsReviewReferenceDate` lines 83-87; `DocsReviewCadence.Tests.ps1` | inspection | |
| 11 | One finding at 2026-04-11, none at 2026-04-10; pointer by source; message content | PASS | `Get-DocsReviewOverdueFinding` lines 242-247; command-level tests lines 106, 123, 191 assert pointer and message | inspection | |
| 12 | Command with fixed `UtcNow` reports overdue and none at due date | PASS | `DocsValidateCommands.ReviewCadence.Tests.ps1` lines 106 and 123 | inspection | |
| 13 | Not in other modes; not without `-PageFrontMatter` | PASS | `DocsValidation.ReviewCadence.Tests.ps1` lines 121 and 130 | inspection | |
| 14 | `block_overdue_review` optional boolean | PASS | `docs-profile.schema.json` diff; `DocsProfile.ReviewCadence.Tests.ps1` lines 50 and 67 | inspection | |
| 15 | Warning/pass by default; error/fail/exit 1 with `true` | PASS | `DocsValidateCommands.ReviewCadence.Tests.ps1` lines 136 and 156 | inspection | |
| 16 | `RECEIPT_FAILING`; `DocsCompleteGate.psm1` unchanged | PASS | Test line 136 asserts `Allow` false and `RECEIPT_FAILING`; `DocsCompleteGate.psm1` absent from the merge-base diff | `git diff --stat 095a4ae13..HEAD` | |
| 17 | `DocsStaleness.psm1` unchanged; staleness tests unmodified and passing | PASS | `DocsStaleness.psm1`, `DocsStaleness.Tests.ps1`, `DocsStaleness.Properties.Tests.ps1`, `DocsValidation.Tests.ps1` absent from the diff; full gate 0 failures | `git diff --stat 095a4ae13..HEAD` | |
| 18 | Reference regeneration preserves `review_due` and key order | PASS | `DocsReferenceFrontMatter.psm1` diff (field order list and preserve line); `DocsReferenceFrontMatter.Tests.ps1` +30 lines | inspection | |
| 19 | All templates carry the placeholder after `last_reviewed`; template test asserts | PASS | 16 of 16 templates in `.agents` and `.claude` roots have the line directly after `last_reviewed`; `docs-authoring-roles.Templates.Tests.ps1` updated (+61 lines) | awk check over `templates/*.md` | Family templates included |
| 20 | SKILL.md step 1 names `review_due` and omission rule | PASS | `.agents/skills/docs-author-page/SKILL.md` lines 49-54 | `grep -n review_due .agents/skills/docs-author-page/SKILL.md` | |
| 21 | Parity and contract tests | PASS | `parity-scope.2026-11-24T17-24.md` (no drift; 6 of 6 modules, 3 of 3 schemas, 16 of 16 templates identical); `core.json` line 437; pytest gate (push-down contract tests) and Pester gate green | `grep -n DocsReviewCadence .../core.json` | |
| 22 | No `extensions/drm-copilot/src/` change; no new Python | PASS | Merge-base diff contains no such path and no `.py` file | `git diff --name-only 095a4ae13..HEAD` | |
| 23 | No wall-clock read; no temp files in new tests | PASS | Pattern scans of changed lib modules and new tests returned no match | `grep -nE "Get-Date|\[datetime\]::(Now|UtcNow)|..."` | |
| 24 | Per-file coverage >= 85%; files <= 800 lines | PASS | Gate: 98.8% to 100% per file, new module 100%; largest file 696 logical lines | `pester.2026-11-24T17-21.md`; awk line counts | |
| 25 | Page with both dates passes; profile may list `review_due` | PASS | Same evidence as rows 1 and 2 | inspection | |
| 26 | All templates carry the line and pass the checker after substitution | PASS | Same evidence as row 19 | awk check | |
| 27 | Ordering, format, calendar codes from `check`; no clock read | PASS | Same evidence as rows 3 to 5 | inspection | |
| 28 | Derived and explicit due dates | PASS | Same evidence as rows 6 and 7 | inspection | |
| 29 | No finding without covering family, valid interval, `required_families`, or for legacy exclusion | PASS | Same evidence as row 9 | inspection | |
| 30 | Overdue at 2026-04-11, none at 2026-04-10; fixed instants | PASS | Same evidence as rows 11, 12, 23 | inspection | |
| 31 | Severity by option; exit 1; `RECEIPT_FAILING` | PASS | Same evidence as rows 15 and 16 | inspection | |
| 32 | Existing profiles and pages validate as before; starter profile unchanged | PASS | New key and field optional; `DocsProfile.psm1` and `DocsProfileCommands.psm1` (home of `New-DocsStarterProfile`) absent from the diff; full gate 0 failures with only pinned-contract test edits | `git diff --stat 095a4ae13..HEAD` | |
| 33 | `DOCS_STALE_PAGE` unchanged | PASS | Same evidence as row 17 | inspection | |
| 34 | Reference regeneration keeps `review_due` | PASS | Same evidence as row 18 | inspection | |
| 35 | Parity across Claude, Codex, bundle | PASS | Same evidence as row 21 | inspection | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 35 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Confirm Linux behavior through the CI run of the integration branch `epic/documentation-estate-families-integration` after the coordinator merges this branch (per-child CI is waived for this epic).
2. When either `DocsReviewCadence.psm1` or `DocsPageMetadata.psm1` is next changed, consider consolidating the duplicated calendar-date logic (non-blocking Minor finding in `code-review.2026-11-24T17-39.md`).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `.dev/active/1220-docs-review-cadence/spec.md`, `.dev/active/1220-docs-review-cadence/user-story.md`
- Total AC items: 35
- Checked off (delivered): 35
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `.dev/active/1220-docs-review-cadence/spec.md` | 24 | 24 | 0 | Checkbox-backed |
| `.dev/active/1220-docs-review-cadence/user-story.md` | 11 | 11 | 0 | Checkbox-backed |

No source-file checkbox change was made by this review: the executor had already checked all 35 criteria, and the word-level diff of both files against the merge base shows only 35 `[ ]` to `[x]` changes with no criterion text altered. The `## Definition of Done` and `## Seeded Test Conditions` checklists in `spec.md` are not acceptance criteria and were left as they are.
