# Issue Update Mirror — Issue #505 (Phase 7, [P7-T6])

Timestamp: 2026-08-25T10-25

Issue: #505
Issue URL: https://github.com/drmoisan/drm-copilot/issues/505

PostedAs: body — applied to the local feature `issue.md` body at `docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/issue.md`, appended as a new `## Outcome (2026-08-25)` section after the existing `## Next Step` section. The pre-existing section headings were left unchanged, because the automation note at the top of that file records that the promotion tooling maps them into the GitHub bug issue template.

NOT POSTED TO GITHUB: no GitHub API call was made. [P7-T6] instructs an update of the local `issue.md` and a mirror of the same text; it does not authorize a `gh` posting step, and no such step exists anywhere in this plan. Posting to the GitHub issue is left to the pull-request flow.

---

## Exact text applied

## Outcome (2026-08-25)

**Fixed.** All 21 acceptance criteria in `spec.md` are satisfied and checked. Delivered on branch `bug/fix-all-json-cancel-thread-race-505`.

### Corrected root cause

The defect was not a cross-thread visibility problem in `scripts/dev_tools/fix_all_runtime.py`, as the Suspected Cause section above hypothesised. The JSON lane's cancel observation is a fixed 10 ms wall-clock grace period (`cancel_event.wait(api.CANCEL_CHECK_DELAY_S)` at `scripts/dev_tools/fix_all_branches.py` lines 111-112, with `CANCEL_CHECK_DELAY_S = 0.01` at `scripts/dev_tools/fix_all.py` line 360), not an ordering barrier. The test asserted an ordering guarantee that production never made and cannot make without serialising the lanes. The primary fix is therefore test-side: establish the precondition deterministically instead of letting it win a timing race.

### Adopted candidates: B, A, and G

- **B (primary, test-side).** An ordered, synchronous `threading.Thread` stand-in was substituted in the two racy end-to-end tests so the Python lane runs and fails before the JSON lane starts. The JSON lane then returns at its **first** cancel check and never reaches the 10 ms grace wait. Two tests were repaired, not one: the reported `test_json_cancel_before_validate_returns_canceled_result` and the identical latent race in `tests/scripts/dev_tools/test_fix_all.py::test_fail_fast_cancels_json_before_validate`. Both keep their node ids and their original assertions. Verified at 50 iterations under concurrent full-suite load with `FailureCount: 0` for both node ids.
- **A (coverage).** Three direct, single-threaded unit tests of `fix_all_branches.run_json_branch` were added, covering all three cancel branches with zero threads and no elapsed-time dependency. Under the full suite `scripts/dev_tools/fix_all_branches.py` now reaches 100 percent line and 100 percent branch coverage with an empty missing-lines list.
- **G (production hardening).** `_runner` in `scripts/dev_tools/fix_all_runtime.py` now records a branch function that raises as a failing `BranchResult` carrying the exception text, and still sets the cancel event under fail-fast. This closed a **silent false pass**: previously a crashed lane left `results[name]` unset, the exit-code expression computed over recorded results only, and `run_fix_all` returned 0 when the other four lanes passed. This was the only production change in the fix and was delivered with a real failing-then-passing regression test.

### Deviation from the spec

`tests/scripts/dev_tools/test_fix_all_json_cancel.py` was listed in the spec as a **conditional** write, required only if the file-size limit forced a split. It was upgraded to an **unconditional** write in the plan and delivered as such. The measured line counts made the split mandatory: `tests/scripts/dev_tools/test_fix_all_failure_paths.py` had only 8 lines of headroom against the 500-line limit at baseline (492 lines), and the candidate A and candidate G tests total well beyond that even after the 37-line `_SkipBranchThread` stand-in was relocated. The new module finished at 396 lines and the host module dropped to 472.

### Verification summary

- Full suite: 4121 passed, 0 failed, 5 skipped.
- Repository line coverage **92.6302414231258** percent, branch coverage **85.21485797523671** percent (read from `totals.percent_statements_covered` and `totals.percent_branches_covered`), against thresholds of 85 and 75. Both improved on the baseline.
- Black, Ruff, and Pyright each clean, and the four-stage toolchain loop closed in a single consecutive iteration with no stage modifying a file.
- Every line added inside `_runner` is covered; no changed line is uncovered.
- All five files written by this change are at or below the 500-line limit: 198, 472, 447, 176, and 396.
- No banned determinism API in any of the four test files: twelve verdicts across four files and three forms, all absent.
- The diff changes neither `scripts/dev_tools/fix_all.py` nor `scripts/dev_tools/fix_all_branches.py`, and touches no file under `.claude/rules/`, no file under `.github/instructions/`, no CI workflow, and not `pyproject.toml`.

### Out-of-scope observations (recorded, not actioned — to be filed separately)

1. **`scripts/dev_tools/fix_all.py` is 628 lines** and already exceeds the 500-line limit in `.claude/rules/general-code-change.md`. It was read-only for this fix and was deliberately not split here.
2. **The repository tier map file named by `.claude/rules/quality-tiers.md` does not exist at this repository root.** That rule states an unclassified project fails CI. This fix must not create the file, and the gap does not change its obligations, since the coverage thresholds are uniform across T1 through T4 regardless of classification.

A third follow-up is recorded in the spec: research candidate E (removing the 10 ms grace period and retiring `CANCEL_CHECK_DELAY_S`) is the preferred follow-up if the team later decides to remove the wall-clock wait from code under test. It is a production behaviour change, must be filed and reviewed on its own, and can only be adopted together with the candidate B repair delivered here.
