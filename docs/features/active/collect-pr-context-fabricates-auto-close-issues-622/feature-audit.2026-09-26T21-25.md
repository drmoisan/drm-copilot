# Feature Audit: PR-Context Collector Fabricates Auto-Close Issues (#622)

**Audit Date:** 2026-09-26
**Feature Folder:** `docs/features/active/collect-pr-context-fabricates-auto-close-issues-622`
**Base Branch:** `main`
**Head Branch:** `bug/collect-pr-context-fabricates-auto-close-issues-622`
**Work Mode:** `full-bug`
**Audit Type:** Initial feature review

---

## Scope and Baseline

- **Base branch:** `main`. The merge base and scope anchor is `ae8d2ce32c95cf03d55ffb544f2514d83ebfc620`. Local `origin/main` has since advanced to `b924a9e2` (code review NB-1).
- **Head branch/commit:** `bug/collect-pr-context-fabricates-auto-close-issues-622` at `690db2d6`.
- **Audit scope:** the full branch diff `git diff ae8d2ce3...HEAD` (99 files, +5553/-1122).
- **Evidence sources:**
  - Primary: the branch diff, read in full for all production and new test files.
  - PR context: the reviewer generated `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` with the fixed Python collector (`--base origin/main`, gh available).
  - Feature evidence: `evidence/baseline/*`, `evidence/regression-testing/*`, `evidence/qa-gates/*`, and `evidence/other/*`, all dated `2026-09-25T23-29`.
  - Reviewer checks:
    - Black check, Ruff, Pyright, and pytest (dev_tools and the four new files)
    - Prettier check, ESLint, tsc, and Jest (pr-context)
    - lcov parses of `artifacts/python/lcov.info` and `extensions/drm-copilot/coverage/lcov.info`
    - `validate_evidence_locations.py --root .` (exit 0)
    - scope, hermeticity, and suppression greps
    - a #588 marker check on local `origin/main` (absent)
- **Feature folder used:** `docs/features/active/collect-pr-context-fabricates-auto-close-issues-622`
- **Requirements source:** `spec.md` only (`## Acceptance Criteria`, lines 518-562).
- **Work mode resolution note:** `issue.md:9` reads `- Work Mode: full-bug`, so `spec.md` is the only AC source.
- **Scope note:** the operator approved all spec decisions (D1-D14, including D1 and D4) on 2026-09-26. They are treated as binding and are not reopened. The executor took branch N588 (`evidence/baseline/588-detection.2026-09-25T23-29.md`). At `b924a9e2` the #588 marker is still absent, so N588 remains correct.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/spec.md` (only source)

### Acceptance criteria

1. (spec.md:519) `ISSUE_REFERENCE_PATTERN` defined in `models.py` (`re.ASCII`) and `models.ts` (`/u` literal); no JIRA character class remains in the pr_context sources.
2. (spec.md:520) All six extractors use the shared pattern; public names, signatures, and exports are kept.
3. (spec.md:521) `test_extractors_reject_non_bare_number_tokens` passes for three Python extractors and fails pre-fix.
4. (spec.md:522) `test_extractors_accept_bare_number_tokens` passes, including `#12-3` and `#12é`.
5. (spec.md:523) `issue-reference-pattern.test.ts` passes with identical matrices for three TypeScript exports.
6. (spec.md:524) Literal parity tests pass.
7. (spec.md:525) JIRA-extraction assertions are inverted and pass.
8. (spec.md:526) Collectors no longer copy referenced issues into author-asserted.
9. (spec.md:527) The rewritten close-candidates tests pass in both runtimes.
10. (spec.md:528) Scraped-token collector test passes in both runtimes and fails pre-fix.
11. (spec.md:532) Prose-cited closed issue collector test passes in both runtimes and fails pre-fix.
12. (spec.md:533) Prose-cited open out-of-scope issue collector test passes in both runtimes and fails pre-fix.
13. (spec.md:534) Open pending primary kept; closed, `(unknown)`, `pull`, and `None` primaries excluded without printing the number.
14. (spec.md:538) Each issue is fetched at most once per run; no fetch for a non-issue.
15. (spec.md:539) Pending-selection and classification unit tests cover the Test Strategy matrix.
16. (spec.md:540) Builder annotation test passes in #622-owned files.
17. (spec.md:541) Builder omits the annotation when gh is available; output is byte-identical to the pre-change output.
18. (spec.md:542) Builder precedence test covers exactly the five D12 rows.
19. (spec.md:543) M588/N588 handling; in N588 no #588-only file is created or edited.
20. (spec.md:544) `gh_available` / `ghAvailable` parameter, call sites, and the N588 empty-list fallback.
21. (spec.md:545) No change outside the defined scope.
22. (spec.md:555) Every new and changed file is at or below 500 lines.
23. (spec.md:556) Added test code uses no temporary files, remote refs, gitignored state, spawned processes, or drive-root paths.
24. (spec.md:557) Jest per-file thresholds are present without duplicates.
25. (spec.md:558) Coverage is at least 85% lines and 75% branches on new and changed modules in both runtimes, with no regression on changed lines.
26. (spec.md:559) Full toolchain passes in a single pass in both runtimes.
27. (spec.md:562) Docstrings and TSDoc describe bare-number-only extraction and the new builder parameters.

---

## Acceptance Criteria Evaluation

| # | Criterion (short) | Verdict | Evidence |
|---|---|---|---|
| 1 | Shared pattern defined; no JIRA class | PASS | `models.py:26` `re.compile(r"(?<!\w)#\d+(?!\w)", re.ASCII)`; `models.ts:55` `/(?<!\w)#\d+(?!\w)/u`. The reviewer grep for `\[A-Z\]\[A-Z0-9\]\+-` over the pr_context `.py` and `.ts` sources matched only `render.py,cover`, an untracked coverage-annotation artifact that the spec lists as out of scope (spec.md:73). `qa-gates/ac01-*`. |
| 2 | Extractors use the pattern; names kept | PASS | Reviewer grep: `ISSUE_REFERENCE_PATTERN` is used at `feature_docs.py:43`, `render_pr_helpers.py:111`, `render_feature_excerpts.py:33`, `feature-docs-parsers.ts:83`, `render-pr-helpers.ts:170`, and `render-feature-excerpts.ts:76`. `collector.py:87` `__all__` and `index.ts:51` still export the extractor. `qa-gates/ac02-extractors`. |
| 3 | Python reject matrix | PASS | Reviewer run: 39 of 39 cases passed. `regression-testing/py-fail-first`: 30 reject cases failed pre-fix, including `#ISO-8601` and `#CR-1` for each extractor. |
| 4 | Python accept matrix | PASS | Reviewer run: 18 of 18 passed, including `#12-3` -> `["#12"]` and `#12é` -> `["#12"]`. |
| 5 | TypeScript matrices | PASS | `issue-reference-pattern.test.ts:21-44` has the same 13 rejection and 6 acceptance inputs and outputs as the Python file. The reviewer's Jest run passed 362 of 362 pr-context tests. |
| 6 | Literal parity tests | PASS | Reviewer run: `test_issue_reference_pattern_matches_typescript_literal` and `test_autoclose_literals_match_typescript_source` passed. They read the tracked `models.ts` (`test_issue_reference_pattern.py:38-41, 108, 121`). |
| 7 | JIRA assertions inverted | PASS | Diffs of `test_feature_docs.py` (`ignores_jira`, `mixed` -> `["#42"]`, `"ABC-456" not in`), `test_render.py` (`ignores_jira`), `test_collect_pr_context.py` (`["#12"]`, `["#77"]`), `feature-docs.test.ts` (`ignores JIRA-style references`, `not.toContain("ABC-456")`), and `test_collect_pr_context_part2.py:245` (`ABC-10` dropped). `qa-gates/ac07-jira-assertions` (grep exit 1). The reviewer runs of those files passed. |
| 8 | No author-asserted promotion | PASS | Reviewer grep for `Detected issue references` in `scripts/dev_tools/pr_context/` and `extensions/drm-copilot/src/lib/pr-context/` found no match. The promotion lines were removed (`collector.py`, `collector-core.ts` diffs). |
| 9 | Close-candidates tests rewritten | PASS | `test_build_close_candidates_section_lists_referenced_issues_as_detected_only` asserts the author line equals the not-asserted reason and the detected line equals `- #3`. `render-pr-helpers.test.ts:193-206` asserts `- #1` under author and `- #2` under detected. Both pass. |
| 10 | Scraped tokens (C1/T1) | PASS | `test_autoclose_collector.py:301-323` and `collector-core-autoclose.test.ts:278-300` pass in reviewer runs. They assert no `ISO-8601`, `CR-1`, or `#468` on the three autoclose surfaces; `- #622` followed by `AUTOCLOSE_UNVERIFIED_ANNOTATION`; and `#468` with the `NOTE: Unverified (GitHub unavailable)` suffix under `Referenced issues (classified)`. Both failed pre-fix (`py-fail-first`, `ts-fail-first`). |
| 11 | Closed prose issue (C2/T2) | PASS | `test_autoclose_collector.py:326-339` and `collector-core-autoclose.test.ts:302-318` pass. Both failed pre-fix. |
| 12 | Open out-of-scope issue (C3/T3) | PASS | `test_autoclose_collector.py:342-356` and `collector-core-autoclose.test.ts:320-337` pass. They assert `#584` is absent from the autoclose surfaces and that `- #584` appears under `Referenced issues (detected):`. Both failed pre-fix. |
| 13 | Pending primary keep/exclude | PASS | C4/T4 are parametrized over closed, `(unknown)`, `pull`, and `None`/`null`. They assert that the last section line equals `AUTOCLOSE_PENDING_NOT_OPEN_TEXT` and that `#622` does not appear. C5/T5 cover `open` and `OPEN`. All pass. |
| 14 | Fetch once | PASS | C6/T6 assert that the recorded `issue_details` calls sorted equal `["468", "584", "622"]` with `#7` classified `pull`: one fetch per issue and none for the PR. Both pass. |
| 15 | Selection and classification unit tests | PASS | `test_autoclose.py` has 12 tests (open, OPEN, closed, unknown, pull, None, gh unavailable, at-most-once, mixed outcomes, and three classification tests). `autoclose.test.ts:96-287` mirrors them. All pass. |
| 16 | Annotation builder test | PASS | `test_autoclose_builder.py:28-57` (collected under the full spec name; code review NB-2) and `autoclose.test.ts:290`. Both assert the exact annotation text after `- #7` and that it does not start with `- `. Both pass. |
| 17 | Omit annotation when available | PASS | `test_autoclose_builder.py:60-75` asserts equality with `header + "\n- #7"`, which is the pre-#622 rendering. `autoclose.test.ts:312` is the counterpart. Both pass. |
| 18 | Five-row precedence | PASS | `test_autoclose_builder.py:102-175` has exactly five parametrized ids (available-non-empty, available-empty-excluded, available-empty-pass, available-empty-non-pass, unavailable-non-empty). `autoclose.test.ts:348-386` is the counterpart. No test asserts the (unavailable, empty) row. |
| 19 | M588/N588 file set | PASS | `evidence/baseline/588-detection` records `Branch: N588`. The reviewer confirmed that `tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py` and `extensions/drm-copilot/src/lib/executable-resolver.ts` are absent from the diff, and that the diff of `pr-context-service-call.ts` is empty. `qa-gates/ac19-588-file-set`. |
| 20 | Availability parameter | PASS | `render_pr_helpers.py:237-244` (keyword-only `gh_available: bool = True`) and `autoclose.ts` `ghAvailable = true` default. Call sites: `collector.py:246` (`gh_available=gh_available`) and `collector-core.ts` (`ghAvailable`). With N588 and an empty list with gh unavailable, the body falls through to the PASS / non-PASS fallback (code reading). The #588 literal is absent from all production and test files (reviewer grep exit 1). `qa-gates/ac20-*`. |
| 21 | Scope boundary | PASS | The reviewer's `git diff --stat ae8d2ce3...HEAD` over `github.py`, `gh-client-*.ts`, `executable-resolver.ts`, `pr-context-service-call.ts`, the four pr-author contract files, `.agents/`, `.github/`, and `extensions/drm-copilot/resources/` is empty. `qa-gates/ac21-*`. |
| 22 | 500-line cap | PASS | Reviewer `wc -l`: the largest changed production files are `collector-output.ts` 494 (unchanged), `collector.py` 461, `render-pr-helpers.ts` 417, and `collector-core.ts` 396. The largest test files are `test_collect_pr_context_part4.py` 497, `test_collect_pr_context.py` 480, and `test_autoclose_collector.py` 458. `qa-gates/ac22-line-caps`. |
| 23 | Test hermeticity | PASS | Reviewer grep over the added test lines found no temporary-file API, `origin/`, process-spawning API, or drive-root path. The three benign hits are explained in the policy audit section 1.4. `qa-gates/ac23-*`. |
| 24 | Jest thresholds | PASS | `jest.config.cjs:45-66` adds `lines: 85, branches: 75` for `autoclose.ts`, `models.ts`, `feature-docs-parsers.ts`, `render-feature-excerpts.ts`, and `render-pr-helpers.ts`. The existing `collector-core.ts` entry is not duplicated. `qa-gates/ac24-jest-thresholds`. |
| 25 | Coverage | PASS | Reviewer lcov parse: Python changed files have minimums of 86.11% lines and 75.00% branches (`render_feature_excerpts.py`); `autoclose.py` is 100% / 100%. TypeScript changed files have minimums of 87.53% lines (`render-pr-helpers.ts`) and 87.10% branches; `autoclose.ts` is 98.66% / 95.56%. All added executable lines are covered (`qa-gates/python-coverage-delta`, `typescript-coverage-delta`). The file-level decreases in `collector.py` and `render-pr-helpers.ts` come from relocating covered code, not from uncovered changed lines. |
| 26 | Toolchain single pass | PASS | Executor: `qa-gates/py-black`, `py-ruff`, `py-pyright`, `py-pytest-coverage` (4508 passed), `ts-prettier`, `ts-eslint`, `ts-tsc`, `ts-dependency-cruiser` (no tool configured in the repository), and `ts-jest-coverage` (3098 passed, thresholds met). The reviewer re-ran format, lint, and type checks clean in both runtimes. The single local pytest failure (#510, gitignored `.claude/state`) is environmental and unrelated to the diff (policy audit NB-10). |
| 27 | Docstrings describe bare-number extraction | PASS | The changed extractor and builder docstrings read "Extract bare-number issue references (for example #123)" and document `gh_available` / `pending_primary_excluded` (`render_pr_helpers.py:256-261`) and `ghAvailable` / `pendingPrimaryExcluded` (`autoclose.ts` builder TSDoc). The `feature-docs-parsers.ts` comment formerly at line 73 was rewritten. A grep for `ABC-123` in these modules found no match. |

---

## Summary

- **PASS:** 27 of 27
- **PARTIAL:** 0
- **FAIL:** 0
- **UNVERIFIED:** 0

Blocking count for this artifact: 0.

The reported defect is fixed in both runtimes, and the regression tests pin it. The reviewer's run of the fixed Python collector on this branch confirms the change in live output with gh available. The author-asserted block now reads `None (author has not asserted autoclose issues)`. The autoclose section reads the non-PASS fallback, because this folder had no readiness signal before this audit. The citations in this item's own documents (`#468`, `#584`, `#588`, `#ISO-8601`, `#CR-1`) appear only in the mention sections.

The TypeScript runtime was not exercised live through the MCP tool. The MCP path serves the installed extension payload, which does not contain this change until the extension is rebuilt and reinstalled. Its behavior is verified by the Jest collector-level tests (T1-T6).

Non-blocking follow-ups (details in the code review):

- NB-1: merge `origin/main` (D13) before PR creation.
- NB-2: two aliased Python test names.
- NB-4: duplicated `compareCodePoint`.
- NB-5: missing-banner guard in the TypeScript test helpers.
- NB-12: spec status still `Draft`.

**Overall feature readiness:** **PASS**

---

## Acceptance Criteria Check-off

All 27 criteria in `spec.md` were already checked (`- [x]`) by the executor. This review verified each one as PASS, so no checkbox was changed. No criterion was unchecked, and no criterion was newly checked by the reviewer.

### AC Status Summary

- Source: `docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/spec.md`
- Total AC items: 27
- Checked off (delivered): 27
- Remaining (unchecked): 0
- Items remaining: none
