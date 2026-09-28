# Feature Audit — Issue #505

- **Feature:** `docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505`
- **Branch:** `bug/fix-all-json-cancel-thread-race-505` at `c06cb8fc`
- **Base:** `main` at `0c7469f8`
- **Timestamp:** 2026-08-25T10-40
- **Reviewer:** feature-review

## AC Source Resolution

The work-mode marker at `issue.md` line 13 reads `- Work Mode: full-bug`. Under the resolution table
in `.claude/skills/acceptance-criteria-tracking/SKILL.md`, `full-bug` designates **`spec.md` only**
as the authoritative acceptance-criteria source.

Accordingly:

- `spec.md` `## Acceptance Criteria` (lines 253-274) is the sole AC source. 21 criteria.
- `issue.md` is **not** an AC source in this mode and its checkbox sections were not evaluated as
  acceptance criteria.
- `user-story.md` does not exist. Its absence is **correct** for `full-bug` and is not a gap.

Four unchecked `- [ ]` items remain elsewhere in `spec.md` (lines 215-218). These sit under
`## Test Strategy` and are labelled "Seeded from issue (retained for traceability)". They are the
original issue's proposal notes, not acceptance criteria, and are correctly excluded from the AC set.
The unchecked items at lines 22-25 are the severity radio-button block. Neither group is an
outstanding criterion.

## Verification Method

Every criterion below was verified by the reviewer directly — by reading the diff, executing a
command, or parsing a machine-readable artifact — rather than by accepting an evidence document's
assertion. Where an evidence document is cited, it is cited as corroboration alongside an
independent check.

Commands executed by the reviewer during this audit:

| Command | Result |
|---|---|
| `poetry run black --check .` | 445 files unchanged |
| `poetry run ruff check .` | All checks passed |
| `poetry run pyright` | 0 errors, 0 warnings, 0 informations |
| `poetry run pytest --cov --cov-branch -q` | 4121 passed, 5 skipped, 0 failed |
| 30-iteration stress of the 8 relevant node ids | 30/30 reported `8 passed`; 240 node executions, 0 failures |
| `pytest <2 repaired ids> --cov=scripts.dev_tools.fix_all_branches --cov-branch` | Missing `111-145`; first cancel check taken |
| `pytest <repaired ids + new module> -W always` | 6 passed, no warnings emitted |
| `python` parse of `artifacts/python/coverage.json` | line 92.6302414231258, branch 85.21485797523671 |
| `validate_evidence_locations.py --root .` | exit 0, no output |
| `git diff --name-only` against the forbidden path set | 0 matches |

## Acceptance Criteria Evaluation

| # | Criterion (abbreviated) | Verdict | Evidence |
|---|---|---|---|
| 1 | `test_json_cancel_before_validate_returns_canceled_result` passes 50 consecutive runs under load | **PASS** | Executor: 50 iterations, FailureCount 0 under 12 concurrent full-suite runs. Reviewer: 30 further iterations, 0 failures. Structurally guaranteed — see AC 1/2 note below. |
| 2 | `test_fail_fast_cancels_json_before_validate` passes 50 consecutive runs under load | **PASS** | Same protocol and same reviewer stress; both node ids included in all 30 reviewer iterations. |
| 3 | Both repaired tests keep node ids, assert `exit_code == 1` and `JSON: validate` absent | **PASS** | `test_fix_all_failure_paths.py` lines 148, 187-189; `test_fix_all.py` lines 383, 410-412. Node ids unchanged in the diff; only a `monkeypatch` fixture parameter was added. |
| 4 | No `time.sleep`, bounded `Event.wait` as a delay, or elapsed-time assertion in any added or modified test | **PASS** | Reviewer grep across all four files for 10 banned forms returned one hit, at `test_fix_all_json_cancel.py` line 20, inside a docstring as a negated claim. No `import time` in any file. Full reasoning in the code review, scrutiny point 3. |
| 5 | A run of both repaired node ids emits no `PytestUnhandledThreadExceptionWarning` | **PASS** | Reviewer ran both ids plus the new module with `-W always`: `6 passed`, no warnings block emitted. |
| 6 | Ordered synchronous `Thread` stand-in exists in `fix_all_thread_stubs.py`, consumed by both modules, with per-test state isolation via a factory | **PASS** | `fix_all_thread_stubs.py` lines 116-137 (`make_ordered_thread_class`). Imported at `test_fix_all.py` line 9 and `test_fix_all_failure_paths.py` line 21. Isolation verified: a fresh class body executes per call, each binding its own `ThreadRegistry`; base class holds only a bare `ClassVar` annotation. |
| 7 | Direct single-threaded test: event pre-set, `complete_all=False`, asserts `calls == ["JSON: format"]` and `failed_step == "Canceled"` | **PASS** | `test_fix_all_json_cancel.py` lines 255-278. Asserts `runner.calls == ["JSON: format"]` (line 275) and `result.failed_step == "Canceled"` (line 277). |
| 8 | Direct test with an event stand-in whose `wait` transitions to set and returns `True`; asserts `Canceled` without calling validate | **PASS** | `test_fix_all_json_cancel.py` lines 281-304, using `GraceWaitCancelEvent` (lines 121-147). Asserts `failed_step == "Canceled"` (line 303) and `"JSON: validate" not in runner.calls` (line 304). |
| 9 | Direct test with event set and `complete_all=True`; asserts both steps called | **PASS** | `test_fix_all_json_cancel.py` lines 307-336. Asserts both `"JSON: format"` and `"JSON: validate"` in `runner.calls` (lines 332-333) plus `result.success is True`. |
| 10 | `_runner` records a failing `BranchResult` on a raise and still sets `cancel_event` when `complete_all` is off | **PASS** | `fix_all_runtime.py` lines 142-160: the `except` block builds the result, line 158 assigns it unconditionally, lines 159-160 retain the cancel set. Cancel behavior asserted at `test_fix_all_json_cancel.py` lines 393-396. See N2 — this half has no fail-before of its own. |
| 11 | A named regression test asserts exit code 1, lane reported FAIL, and exception text in the branch output | **PASS** | `test_runner_records_failing_result_when_branch_raises`, `test_fix_all_json_cancel.py` lines 342-372: asserts `exit_code == 1`, `"Branch json: FAIL" in log`, `"Branch json did not produce a result." not in log`, and `message in log`. Deterministic fail-before recorded (`assert 0 == 1`). |
| 12 | `test_runtime_reports_missing_result_when_branch_absent` passes unmodified, including `exit_code == 0` | **PASS** | Diff shows only the relocation of the `_SkipBranchThread` class out of the module; the test body is untouched. Assertion at line 469 still reads `assert exit_code == 0`. Passed in all 30 reviewer iterations. |
| 13 | `test_complete_all_allows_json_validate_after_python_failure` passes unmodified | **PASS** | Not present in the diff for `test_fix_all.py` (which shows only the import and the one repaired test). Included in the reviewer's 30-iteration stress; passed every time. |
| 14 | `fix_all_branches.py` and `fix_all.py` unchanged by the diff | **PASS** | `git diff --name-only main...HEAD` against both paths returns 0 entries. |
| 15 | No `.claude/rules/`, `.github/instructions/`, CI workflow, or `pyproject.toml` change | **PASS** | Same command against all four path sets plus `fix_all_branches_extra.py` returns a combined count of 0. |
| 16 | No file written by the change exceeds 500 lines | **PASS** | `wc -l`: 198, 176, 447, 472, 396. All at or below the limit. |
| 17 | `poetry run black .` reports no reformatting needed | **PASS** | Reviewer re-ran `black --check .`: `445 files would be left unchanged`. |
| 18 | `poetry run ruff check .` reports zero findings | **PASS** | Reviewer re-ran: `All checks passed!` |
| 19 | `poetry run pyright` reports zero errors | **PASS** | Reviewer re-ran: `0 errors, 0 warnings, 0 informations`. |
| 20 | `pytest --cov --cov-branch` passes with line >= 85 and branch >= 75 | **PASS** | Reviewer re-ran: `4121 passed, 5 skipped`. Coverage parsed from `coverage.json`: line 92.6302414231258, branch 85.21485797523671. |
| 21 | The four stages complete in a single consecutive pass with no stage auto-fixing a file | **PASS** | Reviewer executed all four in order; none modified a file (`black --check` is non-mutating and reported zero candidates). Corroborated by `evidence/qa-gates/final-loop-closure.2026-08-25T10-15.md`. |

### Note on AC 1 and 2 — the nature of the passing evidence

Both criteria are satisfied, but the strength of the evidence deserves a precise statement rather
than a bare PASS.

The 50-iteration protocol is **confirmatory, not probabilistic**, because after the repair the
outcome no longer depends on scheduling at all. The reviewer established this independently by
measuring `fix_all_branches.py` coverage under the two repaired node ids in isolation: lines
**111-145 are unexecuted**, meaning the grace wait at lines 111-112 and the second cancel check at
lines 113-118 are never reached. The lanes return at the *first* cancel check, which is decided by
the ordered stand-in rather than by the clock. A 50-iteration pass of a structurally deterministic
test is a sanity check on the structure, and that is the correct way to read it.

The corresponding pre-fix protocol observed **0 failures in 50 iterations** and therefore did not
reproduce the reported flake on this host. That does not undermine these two criteria, which concern
post-fix behavior, but it does mean the flake's fail-before is documentary (the issue #500
observation of 13 failures in 19 iterations) plus structural (the coverage-path inversion) rather
than reproduced in-session. This is assessed in full at scrutiny point 4 of
`code-review.2026-08-25T10-40.md` and is judged adequate.

## Deviation From Spec — Assessed

`spec.md` line 290 lists `tests/scripts/dev_tools/test_fix_all_json_cancel.py` as a **conditional**
write, required only if the file-size limit forced a split. It was delivered as an unconditional
write.

**Assessment: justified, correctly disclosed, and not a scope violation.** The condition the spec
named was actually met. `test_fix_all_failure_paths.py` stood at 492 lines against a 500-line limit,
leaving 8 lines of headroom for roughly 90 lines of planned additions. Even after relocating the
37-line `_SkipBranchThread`, the additions could not fit. The split is the remedy the spec itself
recommended in the same sentence, and the resulting files (472 and 396 lines) are both comfortably
within the limit. The deviation is disclosed at `issue.md` lines 99-101.

## Behavioral Verification Beyond the Criteria

Three behaviors were verified because they are adjacent to the change and easy to break silently.

1. **The candidate G fix and the missing-result path are independent.** Candidate G guards an
   exception raised *inside* `_runner`; the missing-result path arises when `_runner` is never
   invoked. Both were exercised in the same test session and both behave as specified — exit code 1
   and exit code 0 respectively.
2. **The `complete_all` override still runs `JSON: validate` after a sibling failure.** Verified
   through both the unmodified end-to-end test (AC 13) and the new direct unit test (AC 9).
3. **No unhandled thread exception is emitted anywhere in the affected modules.** Verified with
   `-W always` across the repaired tests and the new module.

## Out-of-Scope Items — Confirmed Present, Correctly Not Actioned

| Item | Confirmed | Assessment |
|---|---|---|
| `scripts/dev_tools/fix_all.py` is 628 lines, over the 500-line limit | Yes, by `wc -l` | Pre-existing; unchanged by this diff. Splitting a 628-line module inside a targeted bug fix would have widened the blast radius substantially. Correctly deferred; should be filed. |
| `quality-tiers.yml` absent at repository root | Yes, by `ls` | Pre-existing gap against `.claude/rules/quality-tiers.md`. Does not affect this fix's obligations, since coverage thresholds are uniform across T1-T4 and do not depend on a tier assignment. Correctly deferred; should be filed. |
| Research candidate E (remove the 10 ms grace period) | Deferred per `spec.md` line 321 | A production behavior change the flake does not require. Correctly excluded from a bug fix and correctly recorded as the preferred follow-up. |

These are observations only. None is a finding against this change.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/spec.md
- Total AC items: 21
- Checked off (delivered): 21
- Remaining (unchecked): 0
- Items remaining: none
```

All 21 criteria were already checked in `spec.md` by the executor. The reviewer verified each
independently and confirmed every check-off is supported by evidence. **No checkbox was changed by
this review**, because none was found to be checked without support and none was found unchecked
despite being satisfied.

## Verdict

**ACCEPT.** All 21 acceptance criteria PASS. Zero Blocking findings. Eight Non-blocking findings are
recorded in `code-review.2026-08-25T10-40.md`; none blocks merge. No remediation-inputs artifact is
produced.
