# Feature Audit: promotion-receipt-destination-unverified (#623)

---

**Audit Date:** 2026-09-30
**Feature Folder:** `docs/features/active/promotion-receipt-destination-unverified-623`
**Base Branch:** `main`
**Head Branch:** `bug/promotion-receipt-destination-unverified-623`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `6e6ccd62792e0838bee7459a2b468de83ad5d408`; local `main` and `origin/main` both resolve to this SHA)
- **Head branch/commit:** `bug/promotion-receipt-destination-unverified-623` (commit `2597e26d78b11eb03be0ad13c750360bd7793443`, pushed)
- **Merge base:** `6e6ccd62792e0838bee7459a2b468de83ad5d408`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-09-30 13:01:47 UTC at head `2597e26d`; not stale)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`, supplemented by `git diff 6e6ccd62...HEAD` for code hunks (the appendix lists files and stats but not hunks)
  - Feature evidence: `docs/features/active/promotion-receipt-destination-unverified-623/evidence/**` (49 files)
  - Additional evidence: reviewer re-runs of Black check, Ruff, Pyright, Prettier check, ESLint, TSC, targeted Pytest (60 passed) and Jest (118 passed); reviewer parse of `artifacts/python/lcov.info` and `extensions/drm-copilot/coverage/lcov.info`
- **Feature folder used:** `docs/features/active/promotion-receipt-destination-unverified-623`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** explicit marker `- Work Mode: full-bug` in `issue.md`; per the work-mode contract, `spec.md` is the sole AC source. `issue.md` states that AC are authored in `spec.md`.
- **Scope note:** full branch diff (63 files: 10 code/config/test files, 53 Markdown files in the feature folder). No caller narrowing was applied. The executor had already checked off all 15 AC items in commit `2597e26d`; this audit re-verifies each one independently rather than relying on those check marks.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/promotion-receipt-destination-unverified-623/spec.md` — only source (section `## Acceptance Criteria`, 15 checkbox items)

### Acceptance criteria

1. AC-1: `promotion.move-verification.test.ts` test `returns exit code 1 without a destination when the promoted file is missing after the move` passes: with `DroppingMovePotentialFileSystem`, `promotePotential` returns `exitCode` 1, `destination` undefined, last message `Promoted file missing after move: /workspace/docs/features/potential/promoted/sample.md`, messages include the `Created:` issue URL line, and no message starts with `Moved potential file to promoted folder:`.
2. AC-2: The AC-1 test fails when run against the pre-change `promotion.ts`, and the failing run is recorded under `docs/features/active/promotion-receipt-destination-unverified-623/evidence/regression-testing/`.
3. AC-3: TypeScript success path unchanged: `promotion.move-verification.test.ts` test `returns exit code 0 with the destination when the promoted file exists after the move` passes, and the existing `promotion.test.ts` success case, `promotion.matrix.test.ts`, and `promotion-lifecycle-sequence.test.ts` pass without modification.
4. AC-4: `potential-to-issue-service-call.test.ts` test `throws with the exit code, issue URL, and missing-path line when the workflow move check fails` passes: the thrown message contains `Command exited with code 1.`, `https://example.com/issues/123`, and `Promoted file missing after move:`.
5. AC-5: #487 receipt guard remains covered: `potential-to-issue-service-call.test.ts` test `throws when the promoted destination is absent` passes using `LateBlockedPathPotentialFileSystem` with its `toThrow("potential_to_issue")` and `toThrow(DESTINATION)` assertions intact, the positive case `returns the enriched record when the destination exists` passes unmodified, `git diff main -- extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts` is empty, and coverage output shows the guard's true branch (lines 219-226) executed.
6. AC-6: `tests/scripts/dev_tools/test_potential_to_issue_move_verification.py::test_promote_potential_returns_exit_1_when_destination_missing_after_move` passes: `exit_code == 1`, `destination is None`, last message `Promoted file missing after move: <dest>`, and no "Moved" message. The test fails against the pre-change `potential_to_issue.py`, and the failing run is recorded under the feature `evidence/regression-testing/` folder.
7. AC-7: Python success path unchanged: `test_promote_potential_returns_destination_when_move_succeeds` passes, and the existing `test_potential_to_issue.py`, `test_potential_to_issue_branches.py`, and `test_potential_to_issue_missing_label_regression.py` pass without modification.
8. AC-8: The new message text is identical in both languages: `Promoted file missing after move: ` appears in `promotion.ts` and `potential_to_issue.py` (verified by `git grep -n "Promoted file missing after move: "` returning a match in each file).
9. AC-9: `FileSystem` and `RealFileSystem` are defined in `scripts/dev_tools/potential_to_issue_filesystem.py`, are no longer defined in `scripts/dev_tools/potential_to_issue.py`, and remain importable from `scripts.dev_tools.potential_to_issue` as the same objects (`test_filesystem_names_are_reexported` passes).
10. AC-10: The line count of `scripts/dev_tools/potential_to_issue.py` on the branch is less than or equal to its line count at `git merge-base HEAD main`, compared with `(Get-Content scripts/dev_tools/potential_to_issue.py).Count` against `(git show "$(git merge-base HEAD main):scripts/dev_tools/potential_to_issue.py" | Measure-Object -Line).Lines`, with the result recorded in the feature evidence folder.
11. AC-11: Every new or changed file other than `scripts/dev_tools/potential_to_issue.py` is at or below 500 lines, including `promotion.ts`, `potential_to_issue_filesystem.py`, and all new or modified test files.
12. AC-12: `tests/scripts/dev_tools/test_potential_to_issue_filesystem.py` exercises every `RealFileSystem` method using `monkeypatch` only, and no test added or changed by this item creates a temporary file or directory.
13. AC-13: Full TypeScript toolchain passes in a single pass from `extensions/drm-copilot/` (`npm run format`, `npm run lint`, `npm run typecheck`, architecture stage recorded, `npm run test:coverage`), with line coverage >= 85% and branch coverage >= 75% for `promotion.ts` and `potential-to-issue-service-call.ts`, recorded under the feature `evidence/qa-gates/` folder.
14. AC-14: Full Python toolchain passes in a single pass from the repository root (`poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest --cov --cov-branch --cov-report=term-missing`), with line coverage >= 85% and branch coverage >= 75% for `potential_to_issue.py` and `potential_to_issue_filesystem.py`, recorded under the feature `evidence/qa-gates/` folder.
15. AC-15: No changes outside the declared scope: `git diff --name-only main` lists no file under `extensions/drm-copilot/src/lib/new-active-feature-folder/`, `extensions/drm-copilot/resources/`, or `.claude/skills/feature-promotion-lifecycle/`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 TS missing-destination test | PASS | Test body asserts `exitCode` 1, `destination` undefined, exact last message with `/workspace/docs/features/potential/promoted/sample.md`, `Created:` URL present, no "Moved" line. Reviewer run: 118/118 passed in the promotion suites. `evidence/regression-testing/ts-move-verification-pass-after.2026-09-30T08-39.md`. | `npm --prefix extensions/drm-copilot test -- test/lib/potential-to-issue test/lib/promotion-lifecycle-sequence` | Assertions match the criterion text one for one. |
| 2 | AC-2 TS fail-before recorded | PASS | `evidence/regression-testing/ts-move-verification-fail-before.2026-09-30T08-35.md`: `promotion.ts` unchanged versus base (`git diff --quiet` exit 0), test run exit 1 with the AC-1 test failing. Commit order confirms tests (`747df68e`) precede the fix (`3ad57fae`). | `git log --format="%h %s" 6e6ccd62..HEAD` | |
| 3 | AC-3 TS success path unchanged | PASS | Positive-control test present and passing; `git diff --name-only 6e6ccd62...HEAD` over `promotion.test.ts`, `promotion.matrix.test.ts`, `promotion-lifecycle-sequence.test.ts` returns nothing; those suites passed in the reviewer run. | `git diff --name-only 6e6ccd62...HEAD -- <three files>`; Jest command above | |
| 4 | AC-4 service-call surfaces exit code, URL, message | PASS | New test asserts `toContain("Command exited with code 1.")`, the issue URL, and `Promoted file missing after move:`. Passing in reviewer run and `evidence/regression-testing/ts-service-call-pass-after.2026-09-30T08-39.md`. | Jest command above | |
| 5 | AC-5 #487 guard remains covered | PASS | Guard test uses `LateBlockedPathPotentialFileSystem(DESTINATION)` with `toThrow("potential_to_issue")` and `toThrow(DESTINATION)` intact (diff shows only the Arrange lines changed). Positive case unmodified. Reviewer: `git diff 6e6ccd62...HEAD -- .../potential-to-issue-service-call.ts` empty. Reviewer lcov parse: lines 223-226 hit 2 times, `BRDA:222,13,0,2`. | `git diff 6e6ccd62...HEAD -- extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts`; lcov parse of `extensions/drm-copilot/coverage/lcov.info` | The criterion cites lines 219-226; the guard condition is line 222 and its true branch body 223-226, all executed. |
| 6 | AC-6 Python missing-destination test and fail-before | PASS | Test asserts `exit_code == 1`, `destination is None`, exact last message, no "Moved" line. Fail-before: `evidence/regression-testing/py-move-verification-fail-before.2026-09-30T08-35.md` shows `assert 0 == 1` with the module unchanged versus base. Reviewer run: 60 passed. | `poetry run pytest tests/scripts/dev_tools -k "potential_to_issue" -q --no-cov` | |
| 7 | AC-7 Python success path unchanged | PASS | Positive-control test passes; the three existing Python suites are unmodified (reviewer `git diff --name-only` empty) and pass in the reviewer run. | Same pytest command; `git diff --name-only 6e6ccd62...HEAD -- <three files>` | |
| 8 | AC-8 message parity | PASS | Reviewer `git grep -n -F "Promoted file missing after move: " HEAD` returns `promotion.ts:444` and `potential_to_issue.py:470`. | `git grep -n -F "Promoted file missing after move: " HEAD -- <two files>` | |
| 9 | AC-9 filesystem extraction and re-export | PASS | Reviewer `git grep -n -E "^class (FileSystem\|RealFileSystem)\b" HEAD -- scripts/dev_tools/` lists the new module (lines 20, 58) and no match in `potential_to_issue.py`. `test_filesystem_names_are_reexported` passes. | `git grep` as stated; pytest command above | Other `FileSystem` classes in unrelated modules are pre-existing and out of scope. |
| 10 | AC-10 Python line count not increased | PASS | Head 559 lines versus 639 at merge-base (reviewer count via file read and `git show 6e6ccd62:<path>`). Recorded in `evidence/qa-gates/py-line-count.2026-09-30T08-56.md`. | Reviewer read-only script (`git show` base versus working file) | The reviewer used an equivalent line count rather than the PowerShell form in the criterion; the result is unambiguous (-80). |
| 11 | AC-11 other changed files at or below 500 lines | PASS | Head counts: `promotion.ts` 450, `jest.config.cjs` 361, service-call test 434, service-call support 160, promotion support 194, move-verification test 91, `potential_to_issue_filesystem.py` 101, filesystem tests 235, Python move-verification tests 308. Feature-folder Markdown is exempt. | Reviewer read-only script | |
| 12 | AC-12 monkeypatch-only adapter tests, no temp files | PASS | Each of the seven `RealFileSystem` methods has a test that patches only `Path` methods or `filesystem_mod.shutil.move`. The eighth test (Protocol placeholder bodies) uses no patching and no I/O. No `tmp_path`, `tempfile`, `mkdtemp`, `writeFileSync`, or `node:fs` in any of the six new or changed test files (`evidence/qa-gates/test-isolation.2026-09-30T08-56.md`, confirmed by reviewer reading). | File inspection; evidence grep | The eighth test is an executor deviation from plan P5-T3; it does not affect this criterion. See code review. |
| 13 | AC-13 TS toolchain and per-file coverage | PASS | Executor single pass recorded under `evidence/qa-gates/ts-*.2026-09-30T08-46.md` (format hash-unchanged, lint clean, typecheck clean, architecture stage recorded as no config, 3318 tests passed). `promotion.ts` 98.89% lines / 83.82% branches; `potential-to-issue-service-call.ts` 100.00% / 85.00%. Reviewer re-ran Prettier check, ESLint, TSC, targeted Jest (all pass) and parsed lcov (figures match). | `npm --prefix extensions/drm-copilot run lint`; `... run typecheck`; `... exec -- prettier --check <files>`; lcov parse | |
| 14 | AC-14 Python toolchain and per-file coverage | PASS | Executor Phase 8 pass 2 (`evidence/qa-gates/py-*.2026-09-30T08-54.md`): Black unchanged, Ruff clean, Pyright 0 errors, 5708 passed. `potential_to_issue.py` 99.44% / 90.74%; `potential_to_issue_filesystem.py` 100.00% / 100.00%. Reviewer re-ran Black check, Ruff, Pyright, targeted pytest (all pass) and parsed `artifacts/python/lcov.info` (figures match). | `poetry run black --check scripts/dev_tools tests/scripts/dev_tools`; `poetry run ruff check ...`; `poetry run pyright ...`; lcov parse | Pass 1 failed the branch criterion on the new module (7/14) and the phase was restarted from P8-T1 after one test was added; pass 2 is the single clean pass the criterion requires. |
| 15 | AC-15 no out-of-scope changes | PASS | Reviewer filter of `git diff --name-only 6e6ccd62...HEAD` for the three forbidden prefixes returned an empty list. | Reviewer read-only script | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 15 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Confirm the CI run on the PR head is green before merge (CI status for HEAD is not available in the PR context because no PR exists yet).
2. Before opening the PR, fetch `origin/main` and confirm the branch is still up to date; this review did not fetch.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

All 15 items were already checked (`- [x]`) in `spec.md` by the executor in commit `2597e26d`. This audit evaluated each one as PASS on independently inspected evidence, so no check mark was added or removed and `spec.md` was not modified by this review.

### Acceptance Criteria Status

- Source: `docs/features/active/promotion-receipt-destination-unverified-623/spec.md`
- Total AC items: 15
- Checked off (delivered): 15
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/promotion-receipt-destination-unverified-623/spec.md` | 15 | 15 | 0 | Checkbox-backed; all checks confirmed by this audit; no source-file change made |
