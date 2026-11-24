# Code Review: docs-review-cadence (#1220)

---

**Review Date:** 2026-11-24
**Reviewer:** feature-review agent
**Feature Folder:** `.dev/active/1220-docs-review-cadence`
**Feature Folder Selection Rule:** Named by the coordinator delegation for issue #1220; the canonical issue number matches the folder prefix.
**Base Branch:** `epic/documentation-estate-families-integration` (merge base `095a4ae13b4ecf5c9fa2fd13e206c6a300fe1844`)
**Head Branch:** `feature/docs-review-cadence-1220` (head `63486a5455a60ba62655f47534783ed74fd2a6a5`)
**Review Type:** Initial review

---

## Executive Summary

The branch adds calendar review cadence to the documentation library. A new pure module, `.claude/lib/docs/DocsReviewCadence.psm1` (273 lines), computes a page's effective due date (explicit `review_due`, or `last_reviewed` plus the covering family's `review_interval_days`) and emits `DOCS_REVIEW_OVERDUE` findings against the UTC date of the command instant. `DocsPageMetadata.psm1` adds the `review_due` field code and the calendar and strict-ordering checks. `DocsValidation.psm1` evaluates the overdue findings in docs-complete mode after the family findings, and `DocsValidateCommands.psm1` reads page front matter through the existing `ReadText` seam. Three schemas, 16 page templates, `docs-author-page/SKILL.md`, and `core.json` are updated with their copies in parity. The review covered the full merge-base diff (134 files), the PR context artifacts at head `63486a545`, and the evidence under `evidence/`.

The implementation is consistent with the spec decisions D1 to D10 and the epic shared design: `DocsCompleteGate.psm1` and `DocsStaleness.psm1` are unchanged, the blocking behavior reaches the merge hook through the existing `RECEIPT_FAILING` path, and no tested code reads the wall clock. Code quality is high; the findings below are non-blocking.

**What changed:**
- New `DocsReviewCadence.psm1` with seven exported functions and three private helpers; byte-identical bundle copy and `core.json` entry.
- `DocsPageMetadata.psm1`: `review_due` field code, three next actions, private `Get-DocsPageReviewDateFinding`.
- `DocsValidation.psm1`: optional `-PageFrontMatter` parameter and the docs-complete overdue block.
- `DocsValidateCommands.psm1`: reads `$pageFrontMatter` in docs-complete mode and passes it on.
- `DocsReferenceFrontMatter.psm1`: preserves `review_due` and adds it to the field order.
- Schemas: `review_due` property, `front-matter-field` enum member, `block_overdue_review` boolean.
- Templates and `SKILL.md` step 1 edited in `.agents/skills/docs-author-page/` and propagated by the generator.

**Top 3 risks:**
1. Linux-runner behavior is not verified by CI for this item (per-child CI waived by the owner); mitigated by `InvariantCulture` parsing, UTC-kind dates, and forward-slash relative paths.
2. Calendar-date validation and the ordering comparison are implemented in two modules; a future change to one could diverge from the other.
3. docs-complete now reads every listed `.md` page once; on a large estate this adds one read per page (recorded as an accepted risk in the spec).

**PR readiness recommendation:** **Go** — no Blocker or Major finding, the full parallel gate is green, and coverage of every changed module is at or above 98.8%.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/lib/docs/DocsReviewCadence.psm1` | lines 52-69, 192-207 | Calendar-date validation (`ConvertFrom-DocsReviewDate`) and the review-date ordering test (`Test-DocsReviewOrderingInvalid`) duplicate the logic of `Test-DocsPageReviewDate` and the `CompareOrdinal` ordering check in `DocsPageMetadata.psm1` `Get-DocsPageReviewDateFinding`. | When either module is next changed, consider exposing one shared date-parse helper and using it in both places. No change required for this item. | Two implementations of the same rule can drift; today both are pinned by tests (`DocsPageMetadata.ReviewDate.Tests.ps1`, `DocsReviewCadence.Tests.ps1`) and agree. | Inspection of both modules at head `63486a545`. |
| Nit | `.claude/lib/docs/DocsPageMetadata.psm1` | lines 10-11 (module `.DESCRIPTION`) | The edited description line extends well past the wrap width used by the surrounding comment block. | Rewrap the line when the module is next edited. | Readability only. | `git diff 095a4ae13..HEAD -- .claude/lib/docs/DocsPageMetadata.psm1`. |
| Info | `.claude/lib/docs/DocsReviewCadence.psm1` | `Get-DocsReviewIntervalDays`, lines 120-132 | When the longest covering family has no valid interval, the page gets no derived due date; a shorter covering family with a valid interval is not used as a fallback. | None. This matches the documented rule ("the family with the longest such directory decides") and spec D6. | Recorded so a later reader does not treat it as a defect. | Function description and spec D6. |
| Info | `artifacts/pester/powershell-coverage.xml` | n/a | The local coverage file was rewritten at 2026-11-24T17:34Z by a later 2760-test selection run, so it shows 0% for most changed modules. | None for this item. Per-file figures are read from the final-QC evidence `evidence/qa-gates/pester.2026-11-24T17-21.md`; the line denominators match the local file exactly. | A selection-run file is not a gate figure. | `artifacts/pester/pester-junit.xml` `tests="2760"`; gate evidence per-file table. |
| Info | `.dev/active/1220-docs-review-cadence/spec.md` | `## Definition of Done` | The Definition of Done item "Behavior matches acceptance criteria on Windows and on the Linux CI runner" cannot be confirmed for the Linux runner because per-child CI is not run for this epic. | None for this item; the integration branch CI run covers Linux. | Owner instruction relayed 2026-11-24 waives per-child CI. | Coordinator delegation; `self-review.2026-11-24T17-26.md` records the item as pending CI. |

No Blocker or Major findings. No covered file is at or above 700 logical lines (largest: `tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1`, 696), so no file-size Warning applies.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- `DocsReviewCadence.psm1` is pure: every input arrives through parameters, and page text arrives only through the `ReadText` scriptblock. The single clock read remains in `Invoke-DocsCommand.ps1`; the reference date is derived from the `IssuedAt` string the validate command already produces.
- Strictness is explicit and consistent with D5: `$due.DueDate -ge $reference` skips a page due on the reference date, and `Test-DocsReviewOrderingInvalid` skips pages the page checker already reports.
- Dates are parsed with `TryParseExact`, `InvariantCulture`, `AssumeUniversal | AdjustToUniversal`, and normalized to UTC kind; the `\z` anchors reject trailing newlines that `$` would accept.
- Family matching uses ordinal `StartsWith` with an explicit `/` boundary, so `docs/ops` does not match `docs/operations/...`.
- Output is deterministic: pages are visited in ordinal-sorted order, and the reader uses an ordinal-comparer hashtable.
- The blocking path reuses the receipt: an `error` finding produces `validation_result: fail`, which `Test-DocsCompleteGateReceipt` already denies as `RECEIPT_FAILING`. `DocsCompleteGate.psm1` is untouched, as the shared design requires.

#### API and safety notes

- All functions are advanced functions with `[CmdletBinding()]`, `[OutputType()]`, and explicit `AllowNull` and `AllowEmptyCollection` attributes; `Severity` is constrained by `ValidateSet('warning','error')`.
- The new `Invoke-DocsValidation -PageFrontMatter` parameter is optional with a `$null` default, so existing callers keep their behavior (pinned by the test `reports no DOCS_REVIEW_OVERDUE when -PageFrontMatter is omitted`).
- `Get-DocsReviewOverdueSeverity` returns `error` only for the boolean `$true`, so a string such as `"true"` cannot enable blocking; the schema also rejects non-boolean values.
- Two analyzer suppressions carry specific justifications. PSScriptAnalyzer reports 0 findings over 25 changed files.
- No state-changing action is added, so `ShouldProcess` does not apply.

#### Error handling and logging

- An `IssuedAt` that is not `yyyy-MM-ddTHH:mm:ssZ` throws `DOCS_REVIEW_CLOCK_INVALID` (defect guard, exit 3 through the existing catch).
- A page read failure in docs-complete propagates to the existing `DOCS_CLI_RUNTIME` catch (exit 3), pinned by a test.
- Pages whose front matter fails to parse are omitted from the overdue check rather than failing it; the page checker remains the reporter of parse errors. This matches the spec.
- No logging is added beyond findings, as the spec requires.

---

## Test Quality Audit

The branch adds five test files and updates eight existing test files where a pinned contract changed (template key set, reference field order, schema property list, family test expectations), with reasons recorded in the plan and `decisions.2026-11-24T15-03.md`. Coverage, regression, and parity evidence is present and numeric.

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/docs/DocsReviewCadence.Tests.ps1`: direct tests of all seven exported functions, including boundary instants, longest-prefix selection, invalid intervals, and legacy exclusion.
- `tests/scripts/claude-lib/docs/DocsValidateCommands.ReviewCadence.Tests.ps1`: end-to-end `validate -Mode docs-complete` through `Invoke-DocsCommandCli` with fixed `UtcNow`, covering explicit and derived due dates, both option values, `RECEIPT_FAILING`, and the read-failure exit 3. The family case loads the profile from JSON text, so the integer type of `review_interval_days` after parsing is exercised.
- `tests/scripts/claude-lib/docs/DocsValidation.ReviewCadence.Tests.ps1`: mode isolation (`profile`, `ledger`, `matrix`), omitted parameter, severity by option value, families, legacy exclusions.
- `tests/scripts/claude-lib/docs/DocsPageMetadata.ReviewDate.Tests.ps1`: the three `DOCS_PAGE_REVIEW_DUE_*` codes and the check-reads-no-clock case.
- `tests/scripts/claude-lib/docs/DocsProfile.ReviewCadence.Tests.ps1`: schema acceptance and rejection of `block_overdue_review` and `review_due` in `required_front_matter`.
- `.dev/active/1220-docs-review-cadence/evidence/qa-gates/pester.2026-11-24T17-21.md`: full parallel gate, 30098 tests, 0 failed.
- `.dev/active/1220-docs-review-cadence/evidence/qa-gates/coverage-delta.2026-11-24T17-21.md`: per-file and repo-wide delta, no drop.
- `.dev/active/1220-docs-review-cadence/evidence/qa-gates/parity-scope.2026-11-24T17-24.md`: harness `-Check` no drift, byte-identical copies, scope checks.

### Quality assessment prompts

- **Determinism:** Fixed UTC instants, in-memory file maps, invariant-culture parsing; no clock, network, or disk access in tests.
- **Isolation:** One behavior per `It`; `AfterAll` removes `Docs*` modules.
- **Speed:** The new tests run within the 783.6 s full gate; no sleep or retry.
- **Diagnostics:** Assertions on exact codes, pointers, paths, and severities; `-Because` on receipt presence.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection: no credentials, tokens, or keys. |
| No unsafe subprocess or command construction | ✅ PASS | No process invocation or `Invoke-Expression` in the changed modules. |
| Input validation at boundaries | ✅ PASS | Front-matter values are type-checked (`-is [string]`, `-is [IDictionary]`) before use; schema validates `review_due` and `block_overdue_review`. |
| Error handling remains explicit | ✅ PASS | Invalid clock instant throws; read failures propagate to the runtime catch. |
| Configuration / path handling is safe | ✅ PASS | Page paths come from the existing page-path listing; matching is ordinal and boundary-aware; no path is constructed from front-matter values. |

---

## Research Log

No external research was required. The review used the repository rules, the spec and epic shared design, the branch diff, and the feature evidence.

---

## Verdict

The change is ready for the normal merge flow into the integration branch. The implementation follows the spec decisions, keeps `DocsCompleteGate.psm1` and `DocsStaleness.psm1` unchanged, reads no wall clock in tested code, and is fully covered by deterministic in-memory tests that passed in the full parallel gate.

The findings are one Minor, one Nit, and three Info; none blocks merge, and none is carried into remediation inputs. The Minor duplication of date logic is a candidate for consolidation the next time either module is changed.
