# Feature Audit — Acceptance Criteria Verification (Issue #574)

- Timestamp: 2026-08-28T13-48
- Branch: `bug/collect-pr-context-reports-ok-without-writing-574-r2`
- Base: `main` (`origin/main` = `d8b81f81`), merge base `e546e814`
- Work mode: **`full-bug`** (marker `- Work Mode: full-bug` at `issue.md:12`)
- AC source, per `acceptance-criteria-tracking`: **`spec.md`, `## Acceptance Criteria` section only**
  (lines 333-356) — **23 criteria**
- `user-story.md` is correctly absent; `full-bug` does not use it.

## Method

Every criterion was evaluated against the branch's source and against commands the reviewer executed
in this worktree. Where a criterion names a coverage figure or a toolchain outcome, the reviewer
re-ran the command rather than reading the executor's artifact. Criteria naming a specific test were
verified by reading that test's body, not by matching its title.

---

## Evaluation Table

| # | Criterion (abbreviated) | Verdict | Evidence |
| --- | --- | --- | --- |
| 1 | Set-equality test: written paths == reported `artifacts` == workspace-joined pair | **PASS** | `pr-context-service-call.test.ts:156-175`. Line 172 is one `toEqual` between two observed arrays; line 174 compares that value to `SORTED_WORKSPACE_JOINED_PAIR`. Not two independent literals. |
| 2 | `node:fs` write arguments are exactly the two workspace-joined paths, none repo-relative | **PASS** | `extension.collect-pr-context.test.ts:458-482`, named "collectPrContext passes workspace-joined paths to the node:fs write boundary". Asserts the sorted write keys equal the pair and that filtering for keys not starting `C:/workspace/` yields `[]`. |
| 3 | Dispatch-level test corrected so written key and reported path are the same pair | **PASS** | `repo-automation-dispatch.test.ts:129-134`. Was `writes.has("artifacts/pr_context.summary.txt")`; now `writes.has(summary)` where `summary = "C:/workspace/artifacts/pr_context.summary.txt"`. Passes in the reviewer's 2722-test run. |
| 4 | Discarding-write test raises; fails if read-back verification is removed | **PASS** | `pr-context-service-call.test.ts:177-190`. Mutation proof in `evidence/regression-testing/readback-mutation-check.2026-08-28T12-47.md`: with the two verification calls removed, this test is among three that fail (`EXIT_CODE: 1`, `ExpectedExitCode: 1`). |
| 5 | Stale-file pre-seed + discarding write raises (distinguishes read-back from existence) | **PASS** | `pr-context-service-call.test.ts:192-217`. Seeds both paths with prior-invocation content, asserts `isFile` true for both (so an existence check would pass), asserts the call raises. |
| 6 | Summary write succeeds, appendix fails: raises, message names the appendix path | **PASS** | `pr-context-service-call.test.ts:219-235`. `DiscardingFileSystem((path) => path === appendixPath)`; `.toThrow(appendixPath)`. |
| 7 | Dispatch boundary: service raises -> `ok` false with failure text in the record | **PASS** | `repo-automation-dispatch-pr-context-verification.test.ts:90-106`. Asserts `result.ok === false` and `result.summary` contains `Failed to verify PR context artifact`. |
| 8 | Success -> `ok` true and `artifacts` equal to the paths written in that same run | **PASS** | Same file, lines 108-126. Compares `result.artifacts` sorted against `writes.keys()` sorted from the same run. |
| 9 | Fixed clock + fixed SHA: generated-context is first section of both; timestamp lines byte-identical | **PASS** | `collector-output-freshness.test.ts:135-148`. `firstBannerOf` both equal the banner; `timestampLineOf(summary)` equals `"2026-06-26 10:02:03 UTC"` and equals `timestampLineOf(appendix)`. |
| 10 | Both texts contain the head-SHA line from a concrete 40-char fixture SHA | **PASS** | Same file, lines 150-159. Asserts `FIXTURE_HEAD_SHA` has length 40, then `toContain("Head SHA: " + SHA)` on both texts. |
| 11 | Unknown token renders when no head SHA, no error raised | **PASS** | Same file, lines 161-170. `expect(() => renderPair(null)).not.toThrow()`; both texts contain `Head SHA: (unknown)`. Mirrored in `summary-helpers.test.ts:288-292`. |
| 12 | Section-ordering assertion: generated-context first, prior relative order unchanged | **PASS** | `collector-output.test.ts:100-101` — `"===== Context generated ====="` prepended to the existing ordering array; every previously asserted entry retained in its prior relative order. |
| 13 | The two collector log lines carry the absolute workspace-joined paths | **PASS** | `pr-context-service-call.test.ts:259-275`. `expect(logs).toEqual([...])` with both absolute `/workspace/...` paths. Corroborated at the extension level, `extension.collect-pr-context.test.ts:410-420`. |
| 14 | GitHub CLI unavailable: both artifacts still written, call succeeds | **PASS** | `pr-context-service-call.test.ts:237-257`. Scripted runner fails all `gh` calls; asserts the written pair and that the summary contains `GitHub CLI unavailable`. |
| 15 | pytest `collect_and_write`: both texts open with the generated-context section, block byte-identical | **PASS** | `tests/scripts/dev_tools/test_pr_context_freshness.py:254-270`. Drives the real `collect_and_write` with stubbed runner and an in-memory write seam; asserts `_first_banner` on both and `_generated_block(summary) == _generated_block(appendix)`. |
| 16 | Python head-SHA line: concrete 40-char SHA, and unknown token when absent | **PASS** | Same file, lines 273-285. Asserts `len(FIXTURE_HEAD_SHA) == 40`, the concrete line in `with_sha`, the unknown token in `without_sha`, and that the SHA does not leak into `without_sha`. |
| 17 | pytest parity test reads the TS helper source; section-title and head-SHA-label literals equal | **PASS** | Same file, lines 288-308. Reads `extensions/drm-copilot/src/lib/pr-context/summary-helpers.ts` and asserts each of the three Python constants appears as a quoted literal in it. |
| 18 | Three `coverageThreshold` entries at 85/75; `npm run test:coverage -- --coverageReporters=text` exits 0 with all three at/above threshold | **PASS** | Reviewer executed the exact command from `extensions/drm-copilot`: **EXIT 0**, `Test Suites: 201 passed`, `Tests: 2722 passed`. Per-file rows reproduced: `pr-context-service-call.ts 100 / 87.5`, `collector-output.ts 97.73 / 82.27`, `summary-helpers.ts 93.55 / 87.83`. `jest.config.cjs:26-40` carries the three entries, each `lines: 85, branches: 75`. Gate proved live by the `[P5-T5]` negative probe naming the entry key exactly. |
| 19 | Python targeted coverage: line >= 85 and branch >= 75 for `collector` and `summary_helpers` | **PASS** | Reviewer executed the dotted-module `--cov` command and read the JSON reporter: `collector.py` line **93.54838709677419**, branch **86.36363636363636**; `summary_helpers.py` line **91.30434782608695**, branch **81.42857142857143**. Both above both thresholds. Values match the executor's artifact exactly. |
| 20 | All six SKILL.md copies carry the two-step cross-check; push-down contract tests pass | **PASS** (exemption) | Reviewer hashed the `### Freshness Cross-Check` block in all six copies: each self-hosted/bundled pair byte-identical; added wording identical across all six (the one-byte `.claude` trailing-newline difference pre-dates this change at `origin/main`). `poetry run pytest <the two named files>` -> `1 failed, 18 passed`; the single failure is the pre-authorized `.claude/state/python-batch-budget.default.json` exemption, unrelated to skill-copy parity. |
| 21 | No output-path root join in `collector.py`; no change to either `enforce-pr-author-skill*` hook | **PASS** | `scripts/dev_tools/pr_context/collector.py:152` is `summary_path = out`, unchanged; no `repo_root` join, no `.resolve()`, no absoluteness guard on the write path. `git diff --name-only origin/main...HEAD -- .claude/hooks/` returns empty. |
| 22 | Every file changed by this fix is at or under 500 lines | **PASS** | Reviewer counted all 17 non-Markdown changed files. Maximum **491** (`repo-automation-dispatch.test.ts`). `collector.py` reduced from over 500 at baseline to **474** via extraction into `collector_documents.py` (345). |
| 23 | Full toolchain pass in a single run, both runtimes | **PASS** (exemption) | Reviewer executed every named command: `prettier --check` 0; `npm run lint` 0; `npm run typecheck` 0; `npm run test:unit` (via `test:coverage`) 0 with 2722 passed; `black --check .` 0; `ruff check .` 0; `pyright` 0; `pytest --cov --cov-branch` exit 1 with `1 failed, 4197 passed, 5 skipped` — the single pre-authorized failure. |

---

## Bounded-Exemption Verification (AC 20 and AC 23)

The plan grants a bounded exemption for one pre-existing repo-wide pytest failure. The review
directive requires the reviewer to verify the exemption's three conditions actually hold in the
recorded artifacts, and to report if they do not. The reviewer verified them against **its own live
run** rather than against the artifacts alone:

| Condition | Required | Observed in the reviewer's run | Holds |
| --- | --- | --- | --- |
| Exactly one failure | 1 | `1 failed, 4197 passed, 5 skipped` | yes |
| That exact node ID | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` | identical | yes |
| Assertion names a path under `.claude/state/` | yes | `AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json` | yes |

All three conditions hold. The exemption is validly invoked. The failure is not counted against this
feature.

## Authorized Deviations Confirmed

1. **Scope item 18** — `extensions/drm-copilot/test/lib/pr-context/collector-integration.test.ts` is
   in the plan's Scope enumeration but absent from the changed-file set. Confirmed absent from the
   diff. The enumeration bounds the diff rather than compelling every listed path to change, and this
   file needed no edit because the `Context generated` section title was reused rather than replaced,
   so its existing substring assertion still passes. It passes in the reviewer's 2722-test run. Not a
   gap.
2. **Branch `-r2` suffix** relative to the plan's P0-T3 text. Recorded as an authorized deviation.
   Confirmed: the branch is `bug/collect-pr-context-reports-ok-without-writing-574-r2`. Not a gap.

## Behaviour Semantics (spec section, six conditions)

| # | Condition | Verdict | Evidence |
| --- | --- | --- | --- |
| 1 | Path identity: reported set equals written set, always | **PASS** | Single evaluation at `pr-context-service-call.ts:114-119`; asserted by AC 1, 2, 3, 8. |
| 2 | `ok: true` iff both written and read back equal what was rendered | **PASS** | `verifyWrittenArtifact` compares content; AC 4, 5, 6, 7. |
| 3 | Summary before appendix; verification after both writes; record built last | **PASS** | `collector-output.ts:386-387` write order; `pr-context-service-call.ts:133-141` verify then return. |
| 4 | Pair atomicity not claimed | **PASS** | No temp-then-rename introduced. Partial-write failure is loud (AC 6) and the shared timestamp lets a consumer detect a mismatched pair. |
| 5 | Degradation is not failure | **PASS** | AC 14; `render.ts` catch-all untouched (recorded as Follow-up A). |
| 6 | No hook change required; hook begins working | **PASS** | AC 21; `.claude/hooks/` absent from the diff. |

---

## Regression Check Relative to Baseline

- No previously passing test was removed. Suite counts: 2722 TypeScript tests passing (201 suites);
  4197 Python tests passing.
- No assertion was deleted rather than corrected. The reviewer read the full diff of all five
  modified test files; every removed assertion is replaced in place by a stronger one.
- No production file was excluded from coverage measurement.
- No coverage regression on any changed file. The only per-file metric that moved down is
  `pr-context-service-call.ts` branch coverage (100 -> 87.5), which is a denominator change caused by
  adding genuinely branching verification code to a file that previously had almost none. The changed
  lines are covered; 87.5 is above the uniform 75 floor. Analysed in
  `policy-audit.2026-08-28T13-48.md`.
- The one intra-run regression that did occur — `collector.py` branch coverage 0.035 points below
  baseline — was treated as a task failure and repaired by extending a test stub, verified by the
  reviewer against `git show --stat 4f179480` (one test file, no production file).

---

### Acceptance Criteria Status

- Source: `docs/features/active/2026-08-28-collect-pr-context-reports-ok-without-writing-574/spec.md`
  (`## Acceptance Criteria`, lines 333-356)
- Total AC items: **23**
- Checked off (delivered): **23**
- Remaining (unchecked): **0**
- Items remaining: none
- Newly checked off by this review: **none** — all 23 were already checked by the executor, and the
  reviewer independently verified each as PASS. No box required correcting, and no box required
  unchecking.

## Verdict

**PASS.** All 23 acceptance criteria are met and independently verified. Two of them (20 and 23)
invoke the pre-authorized bounded exemption, whose three conditions the reviewer confirmed hold in a
live run. Zero criteria are PARTIAL, FAIL, or UNVERIFIED. No remediation is required.
