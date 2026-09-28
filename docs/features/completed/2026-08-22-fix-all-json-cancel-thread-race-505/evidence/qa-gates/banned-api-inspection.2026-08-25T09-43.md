# Banned Determinism-API Inspection — Phase 2 and Phase 3 Tracked-File Modifications

- **Task:** [P3-T5]
- **Issue:** #505
- **Rule inspected against:** `.claude/rules/general-unit-test.md`, section Determinism
  Infrastructure ("Banned APIs in test code" — real wall-clock waits), and `.claude/rules/python.md`,
  Pytest Rules ("No sleeps, retries, or timing hacks").

Timestamp: 2026-08-25T09-43

Command: `git diff -- tests/scripts/dev_tools`

Because Phase 2 was committed before Phase 3 began, that command shows the Phase 3 hunks only. To
cover both phases as the task requires, the diff was also taken against the Phase 1 commit:

```
git diff 360eea47 -- tests/scripts/dev_tools
```

Supplementary whole-file scans of the two modified tracked files:

```
pwsh -NoProfile -Command "Select-String -SimpleMatch -Pattern 'time.sleep' -Path tests/scripts/dev_tools/test_fix_all_failure_paths.py,tests/scripts/dev_tools/test_fix_all.py"
```

EXIT_CODE: 0

## Scope

This inspection is deliberately scoped to the **tracked test files modified** by Phases 2 and 3:

- `tests/scripts/dev_tools/test_fix_all_failure_paths.py`
- `tests/scripts/dev_tools/test_fix_all.py`

It does **not** cover the files created by this change. `tests/scripts/dev_tools/fix_all_thread_stubs.py`
(created in Phase 2) and `tests/scripts/dev_tools/test_fix_all_json_cancel.py` (to be created in
Phase 4) are covered by the wider final inspection at [P7-T4], which the plan designates as the sole
authoritative support for the corresponding acceptance criterion. That division is intentional and is
restated here so the narrower scope of this artifact is not mistaken for complete coverage of the
write set.

## The Three Banned Forms — Verdicts

| # | Banned form | Verdict | Basis |
| --- | --- | --- | --- |
| 1 | `time.sleep` | **absent** | `Select-String -SimpleMatch -Pattern 'time.sleep'` over both files returned no matches. The combined Phase 2 plus Phase 3 diff contains zero added lines matching `time.sleep`. |
| 2 | A bounded `Event.wait` used as a synchronization delay | **absent** | A search for `.wait(` over both whole files returned no matches (grep exit status 1, no output). No added line in the combined diff matches `.wait(`. |
| 3 | An assertion whose outcome depends on elapsed time | **absent** | Established by reading each added hunk, and corroborated by a search for `time.time`, `perf_counter`, `monotonic`, `elapsed`, and `datetime.now` over both whole files, which returned no matches. |

## Reading of the Added Hunks (basis for verdict 3)

Phases 2 and 3 added exactly four hunks across the two files. Every added line falls into one of
three categories, none of which can carry a timing dependency:

1. **Import statements.** `from tests.scripts.dev_tools.fix_all_thread_stubs import make_ordered_thread_class`
   in both files, plus the aliased `SkipBranchThread` import in
   `test_fix_all_failure_paths.py`, plus the function-local
   `import scripts.dev_tools.fix_all_runtime as runtime` in each modified test.
2. **A signature change and a `monkeypatch.setattr` call.** Each of the two tests gained a
   `monkeypatch: MonkeyPatch` parameter and a single call substituting
   `make_ordered_thread_class(order=("python", "json"))` for `runtime.threading.Thread`.
3. **Explanatory comments.** The comment block naming issue #505 and the 10 millisecond grace
   period. These describe the wall-clock dependency being *removed*; they contain no executable
   code. A textual scan for the phrase "10 ms" therefore matches a comment, not an assertion, and
   the distinction is noted here so a future reader does not misread the comment as a timing
   construct.

**No assertion was added, removed, or altered by either phase.** The pre-existing assertions in both
tests (`exit_code == 1`, and `"JSON: validate" not in json_calls`) are unchanged and are byte-identical
to their pre-change form. Their outcomes depend on the recorded call list and the returned exit code,
both of which are pure data.

## Direction of the Change

The purpose of these modifications is to *remove* a timing dependency rather than to add one. Before
the change the two tests reached their assertion by way of the grace wait at
`scripts/dev_tools/fix_all_branches.py` line 112 — a real bounded wall-clock wait inside the
production code they exercise, which is banned form 2 in effect if not in location. The ordered
stand-in makes the python branch complete before the json branch starts, so the cancel event is
already set at the first check on line 102 and line 112 is never reached. The measurement supporting
this is recorded in `post-fix-repeated-run.2026-08-25T09-43.md`: lines 103-105 are now covered and
lines 113-118 are not, the inverse of the Phase 0 baseline.

Output Summary: All three banned forms are **absent** from the Phase 2 and Phase 3 modifications to
the two tracked test files. (1) `time.sleep`: absent. (2) A bounded `Event.wait` used as a
synchronization delay: absent. (3) An assertion whose outcome depends on elapsed time: absent — no
assertion was added or altered by either phase, and the pre-existing assertions test the recorded
call list and the exit code only. Verdicts rest on the combined `git diff 360eea47 -- tests/scripts/dev_tools`,
a `Select-String -SimpleMatch` scan for `time.sleep`, a whole-file search for `.wait(`, and a
whole-file search for five elapsed-time identifiers, all returning no matches. Scope is the two
modified tracked files only; the two created files are covered by [P7-T4].
