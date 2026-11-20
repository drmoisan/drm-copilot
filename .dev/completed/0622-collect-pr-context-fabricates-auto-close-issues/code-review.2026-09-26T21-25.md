# Code Review: PR-Context Collector Fabricates Auto-Close Issues (#622)

**Review Date:** 2026-09-26
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/collect-pr-context-fabricates-auto-close-issues-622`
**Feature Folder Selection Rule:** the only active feature folder in the branch diff; its suffix matches issue #622 in the branch name.
**Base Branch:** `main` (merge base `ae8d2ce32c95cf03d55ffb544f2514d83ebfc620`; local `origin/main` is now `b924a9e2`)
**Head Branch:** `bug/collect-pr-context-fabricates-auto-close-issues-622` (`690db2d6`)
**Review Type:** Initial feature review
**Scope:** full branch diff `git diff ae8d2ce3...HEAD` (99 files, +5553/-1122; 30 code, test, and configuration files)

---

## Executive Summary

The change fixes the four root causes recorded in the spec, in both runtimes, and keeps the runtimes at parity:

- **RC1.** `ISSUE_REFERENCE_PATTERN` (`models.py:26`, `models.ts:55`) replaces six copies of `(?<!\w)#\d+|\b[A-Z][A-Z0-9]+-\d+\b`. JIRA-shaped tokens are no longer extracted, so they no longer reach `classify_entity` or the raw-reference fallback.
- **RC2 and RC3.** The promotion `author_asserted = sorted(set(author_asserted + referenced_issues))` is removed from `collector.py` and `collector-core.ts`. The close-candidates builders list only real author assertions (`render_pr_helpers.py:219-220`, `autoclose.ts:209-213`).
- **RC4.** The raw fallback still records unclassified refs when gh is unavailable. Only strict `#<digits>` tokens reach it, and its output appears only in mention sections.
- **D3 and D5.** `select_pending_primary` / `selectPendingPrimary` keep the metadata primary only when it is an open issue. Otherwise the autoclose body reads `None (deterministic pending issue is not an open issue)`, without the excluded number.
- **D4.** A non-empty list rendered with gh unavailable carries the unverified annotation line.

The new modules are small and pure, and they take narrowed client types (`Protocol` / `Pick<GhClient, ...>`). Fetched issue details are reused, so each issue number is fetched at most once per run. The tests are hermetic: in-memory file systems, in-process gh and git doubles, and no remote refs, temporary files, or Windows paths. They fail on the pre-fix production code for every regression case the spec names.

The reviewer ran the fixed Python collector on this branch with gh available. The generated `Close candidates` block reads `None (author has not asserted autoclose issues)`, and none of the prose citations in this item's own feature documents (`#468`, `#584`, `#ISO-8601`, `#CR-1`) appears in any autoclose-labelled output.

No Blocker or Major finding was identified. The findings below are Minor or Info.

**Top 3 risks:**
1. The branch is behind `origin/main` (NB-1). A merge is required before PR creation; `jest.config.cjs` changed on main in a different hunk.
2. Fail-closed exclusion of the pending primary when `classify_entity` returns `None` (for example, an unresolved repository) drops the item's own issue from the autoclose list. The spec accepts this risk and makes it visible through the not-open text.
3. Consumers read an installed extension payload. The TypeScript fix takes effect on the MCP path only after the extension is rebuilt and reinstalled (spec Rollout).

**PR readiness recommendation:** **Ready** after `origin/main` is merged in (spec D13) and the toolchain is rerun on the merged tree.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | branch `bug/collect-pr-context-fabricates-auto-close-issues-622` | n/a | NB-1. The branch is behind local `origin/main` (`b924a9e2`), which adds the #697, #528, and #513 merges. `extensions/drm-copilot/jest.config.cjs` changed on main at line 225 (the #697 entry); this branch changed line 42. | Run `git merge --no-edit origin/main` (D13), then rerun both toolchains before pr-author. | The repository requires the branch to be current with main before the PR is opened; the hunks are distinct, so a clean merge is likely. | `git log ae8d2ce3..origin/main`; `git diff ae8d2ce3 origin/main -- extensions/drm-copilot/jest.config.cjs`. |
| Minor | `tests/scripts/dev_tools/pr_context/test_autoclose_builder.py` | lines 28-57, 78-99 | NB-2. Two plan-mandated test names exceed the 88-column limit on a `def` line. They are implemented as private functions bound to the full test name at module level. Pytest collects them under the full names (reviewer `--collect-only`), but tracebacks and `__name__` show the private name. | Accept as recorded, or rename both tests in a later change so the `def` line fits. | Discoverability only; the tests run and pass. | Reviewer `pytest --collect-only`: 8 items, including both full names. |
| Minor | `extensions/drm-copilot/src/lib/pr-context/autoclose.ts` | lines 290-298 | NB-4. `compareCodePoint` is copied into `autoclose.ts`, making seven private or exported copies under `src/lib/pr-context/`. `feature-docs-parsers.ts:305` and `gh-client-details.ts:128` already export one. | In a follow-up, consolidate into one exported helper (for example in `models.ts`) and import it everywhere. | Reusability principle; the duplication pattern predates this branch. | Reviewer grep for `function compareCodePoint`. |
| Minor | `extensions/drm-copilot/test/lib/pr-context/collector-core-autoclose.test.ts` | lines 228-255 | NB-5. The `section` and `linesAfter` helpers do not guard `indexOf(...) === -1`. A missing banner makes them scan from the top of the summary. The Python counterparts (`_section`, `_lines_after`) raise `ValueError` instead. Absence assertions become stricter, not weaker, and positive assertions (`toBe(AUTOCLOSE_UNVERIFIED_ANNOTATION)`, `toContain("- #584")`) still fail when content is absent, so no false pass was identified. | Add `expect(index).toBeGreaterThanOrEqual(0)` in both helpers. | Clearer failure diagnostics and parity with the Python helpers. | Code reading. |
| Info | `scripts/dev_tools/pr_context/render_pr_helpers.py`; `extensions/drm-copilot/src/lib/pr-context/autoclose.ts` | `render_pr_helpers.py:283-284`; `autoclose.ts:272-274` | NB-6. The builder appends the annotation ("come from feature metadata only") whenever the list is non-empty and `gh_available` is false, including a caller-supplied `verified` list. Both collectors pass `verified=[]` when gh is unavailable, so this path cannot be reached from production. | None required. Optionally note in the docstring that `verified` is expected to be empty when gh is unavailable. | Builder-contract clarity only. | `collector.py:212`, `collector-core.ts:207`. |
| Info | `scripts/dev_tools/pr_context/autoclose.py` | lines 43-59 | NB-7. `PendingPrimarySelection` is `frozen=True` but holds a mutable `list` and `dict`, so the immutability is shallow. The TypeScript twin uses `readonly` and `ReadonlyMap`. | Optional: use `tuple[str, ...]` and `Mapping[str, IssueDetails]`. | Minor typing precision. | Code reading. |
| Info | `tests/scripts/dev_tools/pr_context/test_autoclose_collector.py` | lines 444-458 | NB-8. C8 `test_pass_readiness_autoclose_section`, relocated from `test_collect_pr_context_part4.py`, asserts `"#46" in summary_text` over the whole summary. Any mention would satisfy it. C7 in the same file asserts `#46` inside the autoclose section, so the behavior is covered. | Optional: scope the C8 assertion to the autoclose section. | Assertion precision. | Code reading. |
| Info | repository | n/a | NB-9. dependency-cruiser is not configured (no tracked config), so stage 4 of the toolchain has no tool. | Track separately; outside this item. | Pre-existing gap. | `git ls-files` shows no `.dependency-cruiser*`; `qa-gates/ts-dependency-cruiser.2026-09-25T23-29.md`. |
| Info | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` | NB-10. The test fails locally on the gitignored `.claude/state/python-batch-budget.worktree-agent-*.json`. The executor deselected it with a recorded reason. | None for this item (issue #510). | Not caused by this branch; it passes on a fresh CI checkout. | Reviewer pytest run (1 failed, message names the `.claude/state` file). |
| Info | `extensions/drm-copilot/src/lib/pr-context/autoclose.ts`; `scripts/dev_tools/pr_context/render_pr_helpers.py` | module layout | NB-3. The runtimes differ in layout. The TypeScript builders moved to `autoclose.ts` (D7 contingency, re-exported from `render-pr-helpers.ts:310-315`); the Python builders stay in `render_pr_helpers.py`. Behavior and text are identical. | None required. | The plan justifies the difference: `render-pr-helpers.ts` was 481 lines on the base and would exceed 500 with the builder edits, while `render_pr_helpers.py` had room. | `plan.2026-09-25T23-29.md` branch-specific decision 1. |
| Info | `docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/spec.md` | line 7 | NB-12. The spec header still reads `Status: Draft`, version 0.3. | Update the status at close-out. | Document accuracy. | `spec.md:7-8`. |
| Info | `scripts/dev_tools/pr_context/github.py` | whole file | NB-13. 549 lines, above the 500-line cap. It predates this branch and was not changed; the spec excludes it from scope. | Track separately. | Pre-existing. | `wc -l`. |

No Blocker or Major finding. Blocking count for this artifact: 0.

---

## Implementation Audit

### Python implementation audit

#### What changed well
- `autoclose.py` contains the moved classification loop (`classify_references`) and the new `select_pending_primary`. Both are keyword-only, typed against narrow `Protocol`s, and documented with Args, Returns, and Side Effects.
- `collect_and_write` drops the author-asserted promotion (the old lines 239-241). It builds the autoclose section after pending verification and passes `gh_available` and `pending_primary_excluded` at the call site (`collector.py:239-248`).
- The details cache (`collector.py:250-257`) reuses the `IssueDetails` fetched during selection. The keys match because the pending refs and the `referenced_issues` entries both carry the `#` prefix.
- `render_feature_excerpts.py` coverage rose from 83.33% / 69.44% to 86.11% / 75.00%, closing a pre-existing below-floor gap.

#### Typing and API notes
- `build_issues_to_autoclose_section` is keyword-only (`*` at `render_pr_helpers.py:238`), with `gh_available: bool = True` and `pending_primary_excluded: bool = False`. The defaults reproduce the pre-#622 output (asserted by `test_build_issues_to_autoclose_section_omits_annotation_when_gh_available`).
- `field(default_factory=dict[str, IssueDetails])` calls a parameterized alias. It is valid at runtime and satisfies Pyright strict.

#### Error handling and logging
- No new exception paths. A `None` classification excludes the ref, `issue_details` is called only after an `"issue"` classification, and its existing error propagation is unchanged (spec).

### TypeScript implementation audit

#### What changed well
- `autoclose.ts` moves `classifyReferences`, `classifyOne`, and `formatRef` verbatim from `collector-core.ts`. It adds `selectPendingPrimary` and receives both builders. `render-pr-helpers.ts` re-exports the builders, so `index.ts`, `render.ts`, `collector-output.ts`, and the existing tests resolve unchanged.
- `Pick<GhClient, "classifyEntity" | "issueDetails">` narrows the dependency, and the type-only import avoids a runtime import cycle.
- Extractors build a fresh global regex per call (`new RegExp(ISSUE_REFERENCE_PATTERN, "gu")`), so the shared literal carries no `lastIndex` state.

#### API notes
- `buildIssuesToAutocloseSection` gains the optional `ghAvailable` (default `true`) and `pendingPrimaryExcluded` (default `false`) parameters. #588's empty-list literal is not present (N588 branch), as the spec requires.

---

## Test Quality Audit

### Reviewed test and QA artifacts
- New: `test_issue_reference_pattern.py`, `test_autoclose.py`, `test_autoclose_builder.py`, `test_autoclose_collector.py`, `issue-reference-pattern.test.ts`, `autoclose.test.ts`, `collector-core-autoclose.test.ts`.
- Modified: the JIRA inversions in `test_feature_docs.py`, `test_render.py`, `test_collect_pr_context.py`, and `feature-docs.test.ts`; the D2 rewrites in `test_collect_pr_context.py` and `render-pr-helpers.test.ts`; `ABC-10` dropped from `test_collect_pr_context_part2.py:245`; `collector-core.test.ts` double now returns `state: "open"` so the PASS-readiness primary survives D3.
- Split files keep collection counts (`other/relocation-counts-p2`, `relocation-counts-p6`). `test_collect_pr_context_part4.py` went from 1026 lines on the base to 497.
- Fail-first evidence: Python 37 failures and TypeScript 34 failures on the pre-fix production code (`regression-testing/py-fail-first`, `ts-fail-first`). In TypeScript, `#١٢` passes pre-fix because JavaScript `\d` is ASCII-only. The evidence records this correctly, and the spec does not require it to fail.

### CI portability review
- No `tmp_path`, `tempfile`, `mkdtemp`, `os.tmpdir`, `origin/`, `child_process`, `spawnSync`, `execSync`, or drive-root path in any added test line (reviewer grep; the executor's `qa-gates/ac23-hermeticity-scan` gives the same result).
- The only filesystem read of a real file is `TYPESCRIPT_MODELS_PATH` (`test_issue_reference_pattern.py:38-41`). It reads the tracked `models.ts` through `Path(__file__).resolve().parents[4]`, which is portable and follows the existing `test_pr_context_freshness.py` pattern that the spec names.
- The TypeScript fixtures use POSIX roots (`/repo`, `/usr/bin/gh`) against `TreeFileSystem`, and the clock is injected.

### Quality assessment prompts
- Do the tests pin the reported defect? Yes. C1/T1 reproduce the `#ISO-8601` / `#CR-1` / `#468` case, C2/T2 the closed prose-cited issue, and C3/T3 the open out-of-scope `#584`.
- Do the tests over-specify? No. The builder precedence test pins exactly the five D12 rows and leaves the #588-owned (unavailable, empty) row unasserted.
- Are the doubles faithful? `_gh_double` returns `(unknown)` state and a `None` classification for unlisted numbers, which matches the production client's failure modes.

---

## Security / Correctness Checks

- **Closing-keyword safety.** After the fix, only verified `closingIssuesReferences` and an open, issue-classified metadata primary can reach `Issues to autoclose`. With gh unavailable, the metadata primary is shown with an explicit unverified line that contains `GitHub CLI unavailable`, which a consumer applying `SKILL.md:78` can detect.
- **Parity.** The pattern text and the two literals are pinned across runtimes by `test_issue_reference_pattern_matches_typescript_literal` and `test_autoclose_literals_match_typescript_source`. `re.ASCII` (D6) aligns `\w` and `\d` semantics with the TypeScript `u`-flag regex.
- **API calls.** JIRA-shaped tokens no longer trigger `classify_entity`. The pending primary adds at most one `classify_entity` call and no extra `issue_details` call (C6/T6).
- **Scope.** `github.py`, `gh-client-*.ts`, `executable-resolver.ts`, `pr-context-service-call.ts`, `render.*`, `collector-output.ts`, the pr-author contract files, and `resources/**` are unchanged (reviewer `git diff --stat`, empty).

---

## Research Log

- Read `issue.md`, `spec.md` (all 588 lines), and the plan's branch-specific decisions and budget table.
- Read the full production diff for both runtimes and the new test files. Read the modified-test diffs.
- Ran the Python and TypeScript format, lint, type, and test checks listed in the policy audit Appendix B.
- Parsed both lcov artifacts with a scratchpad script.
- Ran the fixed collector on this branch and inspected the `Issues to autoclose` and `Close candidates` sections.
- Checked local `origin/main` for #588's marker: absent at `b924a9e2`, so N588 still applies.

---

## Verdict

**APPROVE (with Minor follow-ups).** Blocker 0, Major 0, Minor 4 (NB-1, NB-2, NB-4, NB-5), Info 8. Before PR authoring, merge `origin/main` (NB-1) and rerun the toolchain.
