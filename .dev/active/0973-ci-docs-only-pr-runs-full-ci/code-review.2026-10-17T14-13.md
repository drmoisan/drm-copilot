# Code Review: CI change-scope merge-base fallback for docs-only pull requests (#973)

---

**Review Date:** 2026-10-17
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-17-ci-docs-only-pr-runs-full-ci-973`
**Feature Folder Selection Rule:** supplied by the caller; matches the branch issue number 973 and the `- Issue: #973` marker in `issue.md`.
**Base Branch:** `main` (merge base `18d6d1ccd455a280ca3b7a47ce4976f162e8803e`)
**Head Branch:** `bug/ci-docs-only-pr-runs-full-ci-973` @ `e1a6c90eaff39e5da86d46006a1b4459593f8c4f`
**Review Type:** Initial review

---

## Executive Summary

The branch closes the #962 scope gap in which a new docs-only pull request had no earlier full green run and therefore always took a full CI run. When the green-run comparison ends with `NO_FULL_GREEN_RUN`, `BASE_NOT_PRESENT`, or `BASE_NOT_ANCESTOR`, and the pull request base ref is exactly `main`, `scripts/ci/Invoke-CiChangeScope.ps1` now resolves the merge base of the payload base SHA and the head, validates it as one full SHA, and classifies the two-dot diff from that merge base with the existing allowlist logic. The allowlist gains `docs/features/archive/`, `docs/features/epics/`, and `docs/features/parallel/`. The review inspected the full diff, the new and modified Pester suites, the coverage report `artifacts/pester/powershell-coverage.xml`, and the evidence under the feature folder.

**What changed:**
- `scripts/ci/CiChangeScope.psm1`: `Test-CiMergeBaseFallbackApplicable` (trigger set plus case-sensitive `main` check) and `ConvertFrom-CiMergeBaseOutput` (anchored `\A...\z` SHA-1/SHA-256 match after removing at most one LF); both exported, both pure.
- `scripts/ci/Invoke-CiChangeScope.ps1`: context reads `BASE_SHA` and `BASE_REF`; new `Find-CiChangeScopeMergeBase`; diff-and-classify extracted into `Get-CiChangeScopeDiffDecision` and reused by both paths; `Resolve-CiChangeScopeDecision` retains a fallback-eligible primary decision and applies steps 5 to 8 of the spec.
- `.github/workflows/ci.yml`: two env lines passed through `env:` (no `run:` interpolation).
- `config/ci-docs-only-paths.json`, `.github/workflows/README.md`, and six byte-identical brief copies updated.

**Top 3 risks:**
1. The positive skip path (`DOCS_ONLY_SINCE_MERGE_BASE_<sha>`) cannot be observed in live CI before merge, because this pull request itself contains code; it is verified by unit rows and by the post-merge criterion only.
2. The fallback depends on the `changes` job checkout keeping full commit history (`fetch-depth: 0`); a shallower checkout would make every docs-only pull request fall to `MERGE_BASE_UNRESOLVED` (fails closed to a full run, so the cost is CI time, not correctness). S9 criterion (a) detects this.
3. The trust argument assumes the merge-base commit on `main` was validated; under non-strict required checks `main` can contain untested combinations. This predates the change and is documented as residual risk 1 in the spec.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; all new failure paths fail closed and every changed executable line is covered.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Nit | `scripts/ci/Invoke-CiChangeScope.ps1` | `Resolve-CiChangeScopeDecision`, the three `if ($null -eq $primary)` blocks | `$baseSha` is assigned in the second block and read in the third; correctness depends on the reader knowing that `$primary` stays `$null` only when the second block ran. | Optional: fold the presence and ancestry checks into one block, or add a one-line comment on the coupling, in a later change. | Readability of the control flow; behavior is correct and pinned by M6, M8, and the unchanged #962 rows. | Diff inspection; `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1` M6 rows; `Invoke-CiChangeScope.Tests.ps1` unchanged and passing. |
| Info | `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1` | M4 rows (lines 147-158) | The rows read the committed `config/ci-docs-only-paths.json` through the production reader instead of an in-memory config. | None. The read is intentional (it pins the committed allowlist, as AC 5 to 7 require) and touches a tracked file only. | Distinguishes an intentional repository-file read from a prohibited temporary-file pattern. | Spec AC 5 to 7; file header comment lines 5-8. |
| Info | `scripts/ci/Invoke-CiChangeScope.ps1` | green-run path, `NON_ALLOWLISTED_PATH` outcome | A green-run diff that contains a non-allowlisted path stays terminal and does not fall back, so a branch that merged `main` (with code) after its last green run still takes a full run. | None for this item; matches spec D2 and the out-of-scope list. | Records a known boundary of the design so later reports are not misread as a defect. | Spec `## Decision order after the fix` step 4 and D2. |
| Info | `.github/workflows/ci.yml` | step `scope`, env | `BASE_REF` is compared only with the literal `main` and never passed to a process; `BASE_SHA` reaches git only as an argument array element after the event and fork gates, and the merge-base output is validated before use. | None. | Confirms no ref-name or argument injection path. | Diff inspection of `Find-CiChangeScopeMergeBase` and `Test-CiMergeBaseFallbackApplicable`; M11 rows. |

No Blocker or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The duplicated diff-and-classify block was extracted into `Get-CiChangeScopeDiffDecision`, so both comparison paths use the identical `git diff --name-only -z --no-renames --no-color --no-ext-diff --no-relative` argument list; M10 pins that list on the merge-base path.
- The new pure helpers keep the module free of I/O; the module-structure row was updated from eight to ten functions with the banned-command list unchanged.
- `ConvertFrom-CiMergeBaseOutput` uses `\A` and `\z` with `-cmatch`, which rejects upper-case hex, padded output, and a second trailing newline; the comment explains why `$` is not used.
- `code=false` can still only be produced with a `DOCS_ONLY_SINCE_` prefix, and the new `DOCS_ONLY_SINCE_MERGE_BASE_` reason satisfies the existing guard in `New-CiChangeScopeDecision`.
- `BaseSha` and `BaseRef` are not added to the required-context list, so blank values on non-PR events cannot produce `UNEXPECTED_ERROR` on the primary path.

#### API and safety notes

- All four new functions use `[CmdletBinding()]`, `[OutputType()]`, approved verbs, and comment-based help.
- `AllowEmptyString` is applied where a blank value is a legitimate input (`BaseRef`, `PrimaryReason`, `Text`, optional `BaseSha`).
- PSScriptAnalyzer reports 0 findings and the formatter reports 0 differences across the seven PowerShell files (`evidence/qa-gates/ps-analyze.2026-10-17T13-37.md`, `ps-format.2026-10-17T13-37.md`).

#### Error handling and logging

- Every merge-base resolution failure (blank SHA, `cat-file` non-zero, `merge-base` non-zero, invalid output) returns `MERGE_BASE_UNRESOLVED` with a blank base, giving summary `base=none`.
- Merge-base diff outcomes carry the merge base in the summary (`base=<mb>`), pinned by M1 and M9.
- The outer envelope (`UNEXPECTED_ERROR` plus `::warning::`) and the `continue-on-error: true` contract are unchanged.

---

## Test Quality Audit

The new suite covers the twelve row groups listed in the spec test strategy with 28 cases, and `CiChangeScope.Tests.ps1` adds 26 cases for the pure helpers, the three new prefixes, and two-sided rename classification on the green-run path. Changed-line coverage is 100% in both production files.

### Reviewed test and QA artifacts

- `tests/scripts/ci/Invoke-CiChangeScopeMergeBase.Tests.ps1` — closure fakes for gh, git, and the writer; the git fake distinguishes `merge-base --is-ancestor` from the bare two-SHA form; assertions use exact log text and call records.
- `tests/scripts/ci/CiChangeScope.Tests.ps1` — truth table for `Test-CiMergeBaseFallbackApplicable`, 3 accepted and 8 rejected forms for `ConvertFrom-CiMergeBaseOutput`, prefix and rename rows using a local seven-prefix config.
- `tests/scripts/ci/CiDocsOnlyPathsConfig.Tests.ps1`, `tests/scripts/workflows/CiWorkflow.Tests.ps1`, `tests/scripts/workflows/CiChangeScopeWorkflow.Tests.ps1` — exact-string pins of the committed config and the two env lines.
- `evidence/regression-testing/fail-before.2026-10-17T13-27.md` and `pass-after.2026-10-17T13-33.md` — new rows failed before the production change and passed after it; `Invoke-CiChangeScope.Tests.ps1` unchanged.
- `evidence/regression-testing/isolation-shuffle-seed-{973,9731,97301}` — 208/208 in three seeded orders.
- `evidence/regression-testing/ps-tests-full-run.2026-10-17T13-56.md` — 11271 passed, 0 failed, 10 skipped over `tests/scripts`.
- `artifacts/pester/powershell-coverage.xml` — class counters verified by this review: 131/140 and 103/113 lines.

### Quality assessment prompts

- **Determinism:** fixed SHA literals, no clock, no randomness, injected environment reader.
- **Isolation:** each row changes one scenario element from a shared default built per row.
- **Speed:** in-memory only; no process or network.
- **Diagnostics:** full-line `-BeExactly` assertions with `-Because` text naming the case.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No tokens or credentials added; `GH_TOKEN` handling unchanged. |
| No unsafe subprocess or command construction | ✅ PASS | git arguments are passed as discrete array elements through the existing invoker; no string-built command. |
| Input validation at boundaries | ✅ PASS | `BASE_REF` compared with `-ceq 'main'`; merge-base output validated by `ConvertFrom-CiMergeBaseOutput`; `BASE_SHA` checked with `cat-file -e` before use. |
| Error handling remains explicit | ✅ PASS | Every new failure maps to a named `code=true` reason. |
| Configuration / path handling is safe | ✅ PASS | The allowlist file itself stays outside every include prefix, so a pull request editing it always runs in full (existing row). |
| Workflow expression safety | ✅ PASS | New expressions are in `env:`; actionlint reports 0 findings. |

---

## Research Log

No external research was required. Behavior of `git diff --no-renames` (both rename sides listed) and of `github.event.pull_request.base.sha` is documented in the branch research artifact `research/research.2026-10-17T12-25.md` and pinned by rows in the new suite.

---

## Verdict

The change is ready for normal pull-request flow. The implementation matches the spec decision order, keeps the pure-module boundary, reuses one diff helper for both comparisons, and fails closed on every new error path. The one Nit and three Info items do not require action before merge. The remaining verification is the S9 CI evidence on the pull request (first run logs `NON_ALLOWLISTED_PATH:` with a merge-base summary; a later docs-only commit logs `DOCS_ONLY_SINCE_<green head sha>`) and the post-merge archive-move criterion.
