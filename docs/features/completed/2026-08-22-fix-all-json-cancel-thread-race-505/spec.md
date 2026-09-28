# 2026-08-22-fix-all-json-cancel-thread-race (Spec)

- **Issue:** #505
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-23T23-23
- **Status:** Draft
- **Version:** 0.2

## Context
`tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_json_cancel_before_validate_returns_canceled_result` fails intermittently. It asserts that the JSON lane cancels before its validate step when a sibling lane fails, which depends on a cancel signal propagating across threads before that step is reached. Under machine load the race resolves the other way and the lane runs validate, failing the assertion.

Research (`research/2026-08-23T23-25-fix-all-cancel-propagation-race.md`) superseded the promoted record's initial hypothesis. The defect is not an unforced cross-thread visibility problem in `scripts/dev_tools/fix_all_runtime.py`; it is a test asserting an ordering guarantee that production never made and cannot make. The corrected analysis is recorded under Root Cause Analysis below.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: 3.13.12 (Poetry 2.3.2)
- Command/flags used: `poetry run pytest tests/scripts/dev_tools/test_fix_all_failure_paths.py`
- Data source or fixture: `FakeRunnerFactory` responses built by `base_success_responses()` in the same test module

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. The full Python suite runs unrestricted in CI (`.github/workflows/_quality-checks.yml`), so this test executes on every pull request. A CI runner under load can turn a required check red for a reason unrelated to the change under review, which stalls any orchestration whose completion gate depends on observing CI green, and invites remediation cycles against a defect that is not the author's.


## Repro & Evidence
Steps to Reproduce:
1. Run the whole Python suite, or the single node id, repeatedly on a loaded workstation.
2. Observe that the result alternates between pass and fail with no source change.
3. Measured during issue #500 orchestration: 13 failures in the first 19 iterations of an isolated loop, and 3 of 3 failures when run alone during a period of contention.
4. Immediately afterwards, a full-suite run on a quiet machine returned `4078 passed, 5 skipped, 0 failed`.

Expected:
The test is deterministic. Given the same inputs it produces the same result on every run, regardless of machine load, as `.claude/rules/general-unit-test.md` requires under its determinism rules.

Actual:
The assertion fails with:

```text
AssertionError: assert 'JSON: validate' not in ['JSON: format', 'JSON: validate']
```

The run also emits `PytestUnhandledThreadExceptionWarning`, indicating an exception raised inside a worker thread.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet:

  ```text
  tests\scripts\dev_tools\test_fix_all_failure_paths.py:170: AssertionError
  E       AssertionError: assert 'JSON: validate' not in ['JSON: format', 'JSON: validate']
  PytestUnhandledThreadExceptionWarning: Exception in thread Thread-1 (_runner)
  ```

Evidence basis: the research was conducted by static reading of the production and test modules with file and line citations. No test, formatter, linter, or type checker was executed during research, because a pre-implementation hook blocked those commands in that session. Claims below are therefore marked as **verified by reading** where the citation is the evidence, and as **unconfirmed** where execution is required to establish them.


## Scope & Non-Goals

- In scope:
  1. Make the two racy end-to-end tests deterministic by substituting an ordered, synchronous `threading.Thread` stand-in so the Python lane fails before the JSON lane starts (research candidate B). Both tests are in scope, not only the reported one.
  2. Add direct, single-threaded unit tests of `fix_all_branches.run_json_branch` covering all three cancel branches (research candidate A).
  3. Harden `_runner` in `scripts/dev_tools/fix_all_runtime.py` so a branch function that raises is recorded as a failing `BranchResult` rather than terminating its thread silently (research candidate G). This closes a distinct production defect: a crashed lane currently produces exit code 0 when the other lanes pass.

- Out of scope / non-goals, with the reason each was rejected:
  1. **Extending cancel checks to every lane** (research candidate C). Rejected because it does not fix the race. It changes which lanes can cancel, not whether the cancel signal arrives before a given step boundary. The boundary logic at `scripts/dev_tools/fix_all_branches.py` lines 102-118 would be untouched, and the runner-level fast path at `scripts/dev_tools/fix_all.py` lines 412-414 already short-circuits every lane's next command in real runs.
  2. **A blocking fake runner gated on a synchronization primitive** (research candidate D). Rejected because a timeout-free wait deadlocks the suite if the expected signal never arrives, and a bounded wait reintroduces a wall-clock dependency that `.claude/rules/general-unit-test.md` prohibits in test code. It also keeps five real threads for no assertion-level benefit.
  3. **Deleting the wall-clock grace period** at `scripts/dev_tools/fix_all_branches.py` lines 111-112 and retiring `CANCEL_CHECK_DELAY_S` (research candidate E). Rejected as in-scope work because it is a production behavior change that the flake does not require: a sibling failing inside the 10 ms window would be reported as `failed_step="JSON: validate"` with a minus-one result instead of `failed_step="Canceled"`. Recorded under Rollout and Follow-up as the **preferred follow-up** if the team later decides to remove the wall-clock wait from code under test. It can only be adopted together with the candidate B test repair.
  4. **An injectable cancel-observation seam** in production, for example a patchable `api.await_cancel_signal` helper (research candidate F). Rejected because it adds a production surface whose only consumer is a test while leaving the wall-clock default in place. `.claude/rules/general-code-change.md` ranks simplicity first and warns against indirection; candidate B obtains the same determinism with no production surface. Noted as the fallback only if reviewers require the invariant to be expressed production-side.
  5. **Creating `quality-tiers.yml`.** The file does not exist at this repository root. That gap is recorded under Assumptions, Constraints, Dependencies as an observation and is out of scope for this fix.
  6. **Changing `pyproject.toml`.** No coverage, pytest, or lint configuration change is required.
  7. **Changing lane sequencing, cancel semantics, or the value of `CANCEL_CHECK_DELAY_S`.**

- Explicitly excluded systems, integrations, or datasets:
  - No file under `.claude/rules/` may be modified. The fix conforms to the existing determinism rules rather than amending them.
  - No file under `.github/instructions/` may be modified.
  - No CI workflow file is modified.
  - `scripts/dev_tools/fix_all.py`, `scripts/dev_tools/fix_all_branches.py`, and `scripts/dev_tools/fix_all_branches_extra.py` are read-only for this fix.

## Root Cause Analysis

**Corrected root cause (supersedes the promoted record's hypothesis).** The JSON lane's cancel observation is a fixed 10 ms wall-clock grace period, not an ordering barrier. `scripts/dev_tools/fix_all_branches.py` lines 111-112 call `cancel_event.wait(api.CANCEL_CHECK_DELAY_S)`, and `CANCEL_CHECK_DELAY_S = 0.01` is defined at `scripts/dev_tools/fix_all.py` line 360. Verified by reading.

The failing interleaving is therefore:

1. The JSON lane completes `JSON: format` and finds `cancel_event` clear at the first check (`scripts/dev_tools/fix_all_branches.py` line 102).
2. The Python lane has not yet completed its three fake `Black: format` calls within the 10 ms window, so `cancel_event.wait(0.01)` times out at line 112 and the second check at line 113 also finds the event clear.
3. The JSON lane advances to `JSON: validate`. The test deliberately removed that response, so the fake runner records the call and then raises.

**Both reported symptoms are one event, not two defects.** `FakeRunner.run` appends the call to `self.calls` before raising `AssertionError("No response configured for JSON: validate")`. The recorded call is exactly what the failed assertion reports, and the raise is exactly the `PytestUnhandledThreadExceptionWarning` in `Thread-1 (_runner)`. A recorded `JSON: validate` call in this test necessarily implies the raise. Verified by reading.

**Production does not guarantee the property the test asserts, and the guarantee is not constructible.** A sibling lane's failure time is determined by that lane's own workload and is genuinely unordered with respect to another lane's step boundary. A sibling that fails at 11 ms is not observed; a sibling that fails at 9 ms is. The only ways to force the ordering are to serialize the lanes or to make the JSON lane block until every other lane has reported, both of which defeat the parallel pipeline.

**The invariant production does guarantee is implemented correctly.** If `cancel_event` is set at the instant a lane reaches its boundary check and `complete_all` is off, the lane returns a `Canceled` result and does not run the next step. That conditional invariant is implemented at `scripts/dev_tools/fix_all_branches.py` lines 102-118, and it is reinforced for **all** lanes in real runs by the runner fast path at `scripts/dev_tools/fix_all.py` lines 412-414, which returns a minus-one `Canceled` result without spawning a process once the event is set. Verified by reading. Losing the 10 ms race in production therefore costs at most one no-op runner call and a differently-labelled failed step, in a run that is already failing; the process exit code is unchanged either way.

**Conclusion:** the unfalsifiable part of the test is the interleaving, which is a test-side concern. The primary fix belongs in the tests, which must establish the precondition (`cancel_event` already set) deterministically instead of relying on it winning a timing race.

**A distinct production defect was found and is in scope.** `_runner` at `scripts/dev_tools/fix_all_runtime.py` lines 141-145 has no exception handling. A branch function that raises for any reason terminates its thread, leaves `results[name]` unset, and is surfaced only through `threading.excepthook`. `scripts/dev_tools/fix_all_runtime.py` line 183 computes `0 if all(res.success for res in results.values()) else 1` over recorded results only, so if the four other lanes succeed, `run_fix_all` returns **0 even though a lane crashed**. This is a silent false pass. Verified by reading.

**Not caused by the issue #500 branch.** That branch touches nothing under `scripts/`, and the same test fails identically at the merge base in a detached worktree with the loaded module verified through `__file__`.


## Proposed Fix

### Design summary (what changes where):

Adopt research candidates **B + A + G**.

- **B (primary, test-side):** substitute an ordered, synchronous `threading.Thread` stand-in in the two racy tests. The stand-in registers each lane target at `start()` and executes the registered targets in a configured priority order (Python first, then JSON, then the remainder) on the first `join()`. The Python lane's failure therefore calls `cancel_event.set()` at `scripts/dev_tools/fix_all_runtime.py` lines 144-145 before the JSON lane starts, so the JSON lane returns at its **first** cancel check (`scripts/dev_tools/fix_all_branches.py` line 102) and never reaches the wall-clock wait at line 112. Precedent already in the repository: `_SkipBranchThread` at `tests/scripts/dev_tools/test_fix_all_failure_paths.py` lines 425-461 already replaces `runtime.threading.Thread` with a synchronous stand-in for the same class of reason.
- **A (coverage):** add direct, single-threaded unit tests of `fix_all_branches.run_json_branch` with an explicit `threading.Event` and a `FakeRunner`, with no threads at all.
- **G (production hardening):** wrap the body of `_runner` so a branch exception is recorded as a failing `BranchResult` carrying the exception text as output, and still triggers the cancel set under fail-fast.

No lane-sequencing change, no cancel-semantics change, and no change to `CANCEL_CHECK_DELAY_S`.

### Boundaries and invariants to preserve:

- The conditional invariant at `scripts/dev_tools/fix_all_branches.py` lines 102-118 stays exactly as written: event set at a boundary with `complete_all` off means the lane returns `Canceled` and does not advance.
- `complete_all=True` must continue to short-circuit both cancel checks and the grace wait, so `JSON: validate` still runs after a sibling failure.
- Both racy tests keep their existing node ids and their `"JSON: validate" not in json_calls` assertion. Only the precondition establishment changes.
- `test_runtime_reports_missing_result_when_branch_absent` must keep asserting `exit_code == 0`. Research verified by reading that candidate G does not break it: its stand-in's `start()` returns without ever invoking the target for the skipped branch, so `_runner` never executes and the missing-result aggregation path at `scripts/dev_tools/fix_all_runtime.py` lines 156-158 and 171 is preserved.
- The runner-level fast path at `scripts/dev_tools/fix_all.py` lines 412-414 is untouched.

### Dependencies or blocked work:

None. This fix depends on no other in-flight work item and blocks none.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

- `scripts/dev_tools/fix_all_runtime.py` — candidate G only.
- `tests/scripts/dev_tools/test_fix_all_failure_paths.py` — repair the reported racy test; host or consume the candidate G branch-exception test.
- `tests/scripts/dev_tools/test_fix_all.py` — repair `test_fail_fast_cancels_json_before_validate`, which carries the identical latent race.
- `tests/scripts/dev_tools/fix_all_thread_stubs.py` — new shared test-support module holding the ordered `Thread` stand-in factory used by both test modules. `.claude/rules/general-code-change.md` (Reusability) favors the shared module over inlining the stand-in twice. Relocating the existing `_SkipBranchThread` into this module is permitted and recommended, since it reduces `test_fix_all_failure_paths.py` toward the file-size limit discussed under Risks.

#### Functions/classes/CLI commands impacted:

- `scripts.dev_tools.fix_all_runtime.run_fix_all._runner` — gains exception handling.
- `tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_json_cancel_before_validate_returns_canceled_result` — repaired.
- `tests/scripts/dev_tools/test_fix_all.py::test_fail_fast_cancels_json_before_validate` — repaired.
- New: an ordered `Thread` stand-in factory in `tests/scripts/dev_tools/fix_all_thread_stubs.py`.
- New: direct unit tests of `scripts.dev_tools.fix_all_branches.run_json_branch`.
- New: a regression test for the `_runner` branch-exception path.

No CLI command, flag, or public function signature changes.

#### Data flow and validation changes:

None. The `BranchResult` shape, the lane list, the status board, and the aggregation loop are unchanged. The only data-flow change is that `results[name]` is now always assigned when `_runner` executes, instead of being left unset on an exception.

#### Error handling and logging updates:

`_runner` catches an exception raised by a branch function and records `BranchResult(name=..., success=False, output=<the exception text>, failed_step=...)` instead of letting the thread terminate. Under fail-fast (`complete_all` off) it must still set `cancel_event`, matching the existing failure path at `scripts/dev_tools/fix_all_runtime.py` lines 144-145. The existing aggregation loop then renders the lane as `FAIL` through the normal path at lines 174-180, and `scripts/dev_tools/fix_all_runtime.py` line 183 returns 1.

The exception must not be swallowed silently: its text is carried into the branch output so the operator still sees the cause in the per-branch log section.

#### Rollback/feature-flag considerations (if applicable):

None. No feature flag is added. Rollback is a revert of the commit.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

Unchanged. `run_fix_all` keeps its signature and its integer exit code. `BranchResult` keeps its fields. The one observable contract change is that a lane whose branch function raises now yields a recorded failing `BranchResult` and a non-zero process exit code, where it previously yielded no result, an unhandled thread exception on stderr, and potentially exit code 0.

#### Required configuration keys and defaults:

None added. `CANCEL_CHECK_DELAY_S` retains its value of 0.01 at `scripts/dev_tools/fix_all.py` line 360.

#### Backward-compatibility expectations:

- No public API changes.
- The exit-code change described above is a bug fix, not a compatibility break: the prior behavior reported success for a crashed lane.
- `test_runtime_reports_missing_result_when_branch_absent` documents the missing-result aggregation path and continues to pass unmodified.

#### Performance constraints (latency/throughput/memory):

No production performance change. The 10 ms grace period is retained, so real `fix-all` run latency is unaffected. The repaired tests run with zero threads instead of five, which reduces test-suite wall-clock time by an amount that is not measured here and is not a requirement.

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access):
  - Python 3.13.12 under Poetry 2.3.2 on Windows 11; the full toolchain is runnable in the implementation session. The research session could not execute any toolchain command because of a pre-implementation hook, so every runtime claim in this spec is **unconfirmed until executed**.
  - `tests/scripts/dev_tools/conftest.py` continues to provide the `stub_npm_resolution` autouse fixture that keeps the typescript lane off the machine PATH. The new direct `run_json_branch` tests do not depend on it.
  - CPython `threading.Event.set` and `is_set` are internally lock-protected, so there is no cross-thread visibility hazard in the boundary read.

- Constraints (budget, performance, compatibility):
  - **Determinism.** `.claude/rules/general-unit-test.md` bans `setTimeout`, `Thread.Sleep`, `Task.Delay`, real wall-clock waits, and `Date.now()` outside a clock interface in test code. In Python terms the fix must not introduce `time.sleep`, a bounded `Event.wait(timeout)`, or any assertion whose outcome depends on elapsed time, into any added or modified test.
  - **Coverage thresholds are uniform across T1 through T4:** line coverage at least 85 percent, and branch coverage at least 75 percent for Python because `coverage.py` measures branch coverage. Branch data is produced only when `--cov-branch` is passed: `pyproject.toml` `[tool.coverage.run]` (lines 119-127) does **not** set `branch = true`. The coverage command must therefore pass `--cov-branch` explicitly, and `pyproject.toml` must not be changed to add it.
  - **Coverage scope** is `source = ["src", "scripts/dev_tools"]` with `tests/*` omitted, so the new test-support module under `tests/` is outside the denominator. This complies with the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md`: test infrastructure is a permitted exclusion and no production path is excluded.
  - **No regression on changed lines.** The lines added inside `_runner` must be covered by the added branch-exception test.
  - **File size limit:** no production, test, or reusable script file may exceed 500 lines. See Risks for the measured headroom.
  - **Tier classification:** applying the tier descriptions in `.claude/rules/quality-tiers.md` directly, `scripts/dev_tools/` is developer tooling and maps to **T4 (Scaffolding)**. T4 imposes no property-test density, no mutation-score floor, and no golden-test requirement.
  - **Observation, out of scope:** `quality-tiers.yml` does **not** exist at this repository root, even though `.claude/rules/quality-tiers.md` names it as the tier map and states that an unclassified project fails CI. A glob for that filename returned no file at the root; the only name matches are the rule document, its published copy under `extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md`, and two evidence documents under `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/`. This gap is recorded here as an observation only. It is out of scope for issue #505 and this fix must not create the file. The uniform coverage thresholds apply regardless of the classification gap, so the gap does not affect this fix's obligations.
  - No file under `.claude/rules/` or `.github/instructions/` may be modified.

- External dependencies (services, libraries, releases):
  - None added. No new package, no new dependency on a test-parallelism plugin, and no change to `pyproject.toml`.

## Data / API / Config Impact
- User-facing or API changes: none, other than the corrected exit code for a crashed lane described under Backward-compatibility expectations.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): a crashed lane's exception text is now carried into that branch's output and rendered by the existing per-branch log section, instead of appearing only as a `threading.excepthook` traceback on stderr.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag added or changed; no config schema touched; no version bump required.

## Test Strategy

Seeded from issue (retained for traceability; item 1 is answered by the corrected root cause, which places the fix test-side rather than adding a production barrier):

- [ ] Make the cancel observation deterministic rather than timing dependent, for example by having each lane check the cancel event at a defined barrier the test can drive, instead of relying on the signal winning a race against thread start-up.
- [ ] Unit coverage areas: `fix_all_runtime` lane sequencing and cancel propagation.
- [ ] Integration scenario to retest: a sibling failure with `complete_all` off must skip the dependent step on every run.
- [ ] Manual verification notes: run the node id in a loop of at least 50 iterations under artificial load and require zero failures.

- Regression tests to add or update:
  1. `tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_json_cancel_before_validate_returns_canceled_result` — repaired with the ordered `Thread` stand-in. Node id and assertions unchanged.
  2. `tests/scripts/dev_tools/test_fix_all.py::test_fail_fast_cancels_json_before_validate` — repaired identically. Its sibling failure is at `Pyright: type-check`, the third Python step, so its race window is at least as tight as the reported one.
  3. A new regression test for the `_runner` branch-exception path: a lane whose branch function raises is recorded as a failing `BranchResult`, `run_fix_all` returns 1, the exception text appears in the branch output, and no unhandled thread exception is emitted.

- Unit tests (pytest) for the fixed behavior and boundaries — three direct, single-threaded `run_json_branch` cases with no threads:
  1. Event pre-set with `complete_all=False`: expect `calls == ["JSON: format"]` and `failed_step == "Canceled"`. Covers `scripts/dev_tools/fix_all_branches.py` lines 102-107.
  2. An event stand-in whose `wait(timeout)` transitions the flag to set and returns `True`, modelling a sibling failing during the grace observation: covers lines 111-118 with no elapsed-time dependency.
  3. `complete_all=True` with the event set: expect both steps to run. Covers the `complete_all` short-circuits at lines 102, 111, and 113.

- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - `complete_all=True` must continue to run `JSON: validate` after a sibling failure. `tests/scripts/dev_tools/test_fix_all.py::test_complete_all_allows_json_validate_after_python_failure` already asserts this and must keep passing unmodified.
  - `tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_runtime_reports_missing_result_when_branch_absent` must keep passing unmodified, including its `exit_code == 0` assertion.
  - `tests/scripts/dev_tools/test_fix_all_branches.py::test_subprocess_runner_returns_immediately_when_already_cancelled` and `::test_subprocess_runner_runs_normally_with_cancel_event_not_set` cover the runner-level fast path in isolation and must keep passing unmodified.

- Error handling and logging verification: the branch-exception regression test asserts that the exception text reaches the branch output rendered by the aggregation loop, and that the run's exit code is 1.

- Coverage impact and targets for changed lines/modules:
  - Line coverage at least 85 percent and branch coverage at least 75 percent, repository-wide, measured with `--cov-branch` passed explicitly.
  - Every line added inside `_runner` is covered by the branch-exception regression test.
  - `scripts/dev_tools/fix_all_branches.py` lines 100-118 gain direct coverage from the three new unit tests. No test currently calls `run_json_branch` directly, so this is new coverage rather than duplicated coverage.

- Toolchain commands to run (format, lint, type-check, test), repeated from stage 1 until all stages pass in a single pass:
  1. `poetry run black .`
  2. `poetry run ruff check .`
  3. `poetry run pyright`
  4. `poetry run pytest --cov --cov-branch --cov-report=term-missing`

- Manual validation steps (if required):
  - Run both repaired node ids in a loop of at least 50 iterations, ideally under artificial machine load, and require zero failures. The assertion no longer depends on load once the stand-in is in place, so this loop is confirmatory rather than probabilistic.
  - Banned APIs check: confirm by inspection that no added or modified test contains `time.sleep`, a bounded `Event.wait(timeout)` used as a synchronization delay, or an elapsed-time assertion.


## Acceptance Criteria
- [x] `tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_json_cancel_before_validate_returns_canceled_result` passes on 50 consecutive runs, including runs executed while the machine is under artificial load, with zero failures.
- [x] `tests/scripts/dev_tools/test_fix_all.py::test_fail_fast_cancels_json_before_validate` passes on 50 consecutive runs, including runs executed while the machine is under artificial load, with zero failures.
- [x] Both repaired tests keep their existing node ids and keep asserting `exit_code == 1` and that `JSON: validate` is absent from the JSON lane's recorded calls.
- [x] Neither repaired test, nor any test added by this change, contains `time.sleep`, a bounded `Event.wait` used as a synchronization delay, or any assertion whose outcome depends on elapsed time. Confirmed by inspection of the diff.
- [x] A pytest run of both repaired node ids emits no `PytestUnhandledThreadExceptionWarning`, verified by running with warnings visible and inspecting the run output.
- [x] An ordered, synchronous `threading.Thread` stand-in exists in `tests/scripts/dev_tools/fix_all_thread_stubs.py` and is consumed by both `tests/scripts/dev_tools/test_fix_all_failure_paths.py` and `tests/scripts/dev_tools/test_fix_all.py`. Its per-test state is isolated (for example by a factory returning a fresh class) rather than held as class-level mutable state shared across tests.
- [x] A direct, single-threaded unit test calls `scripts.dev_tools.fix_all_branches.run_json_branch` with the cancel event pre-set and `complete_all=False`, and asserts the recorded calls equal `["JSON: format"]` and `failed_step == "Canceled"`.
- [x] A direct, single-threaded unit test calls `run_json_branch` with an event stand-in whose `wait` transitions the flag to set and returns `True`, and asserts the lane returns `failed_step == "Canceled"` without calling `JSON: validate`.
- [x] A direct, single-threaded unit test calls `run_json_branch` with the event set and `complete_all=True`, and asserts both `JSON: format` and `JSON: validate` are called.
- [x] `_runner` in `scripts/dev_tools/fix_all_runtime.py` records a failing `BranchResult` when a branch function raises, and still sets `cancel_event` when `complete_all` is off.
- [x] A named regression test asserts that when one lane's branch function raises, `run_fix_all` returns exit code 1, that lane is reported as `FAIL` in the branch-results summary, and the exception text appears in that branch's logged output.
- [x] `tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_runtime_reports_missing_result_when_branch_absent` passes unmodified, including its `exit_code == 0` assertion.
- [x] `tests/scripts/dev_tools/test_fix_all.py::test_complete_all_allows_json_validate_after_python_failure` passes unmodified.
- [x] `scripts/dev_tools/fix_all_branches.py` and `scripts/dev_tools/fix_all.py` are unchanged by the diff, confirmed by inspecting the changed-file list.
- [x] No file under `.claude/rules/`, no file under `.github/instructions/`, no CI workflow file, and `pyproject.toml` are changed by the diff, confirmed by inspecting the changed-file list.
- [x] No file written by this change exceeds 500 lines, confirmed by a line count of every file in the diff.
- [x] `poetry run black .` reports no reformatting needed.
- [x] `poetry run ruff check .` reports zero findings.
- [x] `poetry run pyright` reports zero errors.
- [x] `poetry run pytest --cov --cov-branch --cov-report=term-missing` passes with zero failures, reports line coverage of at least 85 percent, and reports branch coverage of at least 75 percent.
- [x] The four toolchain stages above complete in a single consecutive pass with no stage auto-fixing a file, per the mandatory toolchain loop in `.claude/rules/general-code-change.md`.

## Blast Radius — files the implementation diff will write

Exact repo-relative paths. This list feeds a blast-radius contention computation, so it is stated precisely in both directions: no glob, no placeholder, no padding, no understatement.

WRITE:

- `scripts/dev_tools/fix_all_runtime.py`
- `tests/scripts/dev_tools/test_fix_all_failure_paths.py`
- `tests/scripts/dev_tools/test_fix_all.py`
- `tests/scripts/dev_tools/fix_all_thread_stubs.py`
- `docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/spec.md`
- `docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/plan.2026-08-23T23-23.md`
- `docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/issue.md`

Conditional additional write, required only if the file-size limit forces a split (see Risks):

- `tests/scripts/dev_tools/test_fix_all_json_cancel.py`

READ-ONLY — read during implementation but not modified. These enter the write set only if a rejected candidate (E or F) is later adopted:

- `scripts/dev_tools/fix_all.py`
- `scripts/dev_tools/fix_all_branches.py`

Also read but not modified: `scripts/dev_tools/fix_all_branches_extra.py`, `tests/scripts/dev_tools/conftest.py`, `tests/scripts/dev_tools/test_fix_all_branches.py`, and `pyproject.toml`.

Evidence artifacts land under this feature's canonical evidence directory as defined in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Their filenames carry run timestamps that are not knowable in advance, so they are deliberately not enumerated as path tokens here.

## Risks & Mitigations

- Technical or operational risks:
  1. **File-size limit on `tests/scripts/dev_tools/test_fix_all_failure_paths.py`.** The file is currently **492 lines**, leaving 8 lines of headroom against the 500-line limit in `.claude/rules/general-code-change.md`. The planned additions (three `run_json_branch` unit tests plus one branch-exception regression test, roughly 80 to 90 lines) will exceed the limit even after the roughly 37 lines of `_SkipBranchThread` are relocated to `tests/scripts/dev_tools/fix_all_thread_stubs.py`. **The plan must account for a split.** The recommended split is to place the three direct `run_json_branch` unit tests in a new module `tests/scripts/dev_tools/test_fix_all_json_cancel.py`, which is why that path is listed as a conditional write above. `tests/scripts/dev_tools/test_fix_all.py` is currently **434 lines**, leaving 66 lines of headroom, which is sufficient for the stand-in substitution alone but not for additional tests. Line counts were measured in this worktree at spec time.
  2. **Pre-existing file-size violation, out of scope.** `scripts/dev_tools/fix_all.py` is currently **628 lines**, already over the 500-line limit. It is read-only for this fix and must not be split as part of this change. Recorded as an observation for a separate work item.
  3. **Loss of real-concurrency exercise in the two end-to-end tests.** Substituting a synchronous stand-in means those tests no longer run five real threads. Mitigation: concurrency is not what the assertions are about, the property they assert is the conditional cancel invariant rather than the interleaving, and `_SkipBranchThread` already establishes this trade as accepted in this module. The three new direct unit tests assert the invariant explicitly.
  4. **Shared mutable state in the ordered stand-in.** A stand-in that registers targets in class-level state would leak between tests and reintroduce order dependence. Mitigation: build the stand-in from a factory that returns a fresh class per test, as required by the acceptance criteria.
  5. **The `_runner` hardening could mask a genuine crash.** Recording an exception as a failing result rather than re-raising means the traceback no longer reaches `threading.excepthook`. Mitigation: the exception text is carried into the branch output and rendered by the existing per-branch log section, and the exit code becomes 1 where it was previously 0, so the crash becomes more visible, not less.
  6. **Every runtime claim is unconfirmed until the toolchain runs.** The research was static-only. Mitigation: the toolchain acceptance criteria above require actual execution before this fix is accepted.
  7. **Branch-coverage measurement depends on a command-line flag.** Omitting `--cov-branch` produces no branch data and the 75 percent gate would be silently unevaluated. Mitigation: the flag is named explicitly in the toolchain acceptance criterion, and `pyproject.toml` must not be changed to add it.

- Mitigations and rollbacks:
  - Rollback is a revert of the single commit. No migration, no feature flag, no config change to unwind.
  - If the `_runner` hardening proves controversial in review, it is separable: dropping it leaves the flake fix intact, at the cost of leaving the silent false-pass defect open. In that case it must be filed as its own issue rather than dropped without a record.

## Rollout & Follow-up
- Release/rollout steps: merge to `main` through the normal pull-request flow. No release artifact, no publish step, no deployment.
- Post-fix monitoring or clean-up tasks:
  1. **Preferred follow-up (research candidate E):** remove the wall-clock grace period at `scripts/dev_tools/fix_all_branches.py` lines 111-112 and retire `CANCEL_CHECK_DELAY_S` from `scripts/dev_tools/fix_all.py` line 360, relying on the runner-level fast path at `scripts/dev_tools/fix_all.py` lines 412-414 for fail-fast in real runs. This removes the wall-clock dependency from production code under test, which is what `.claude/rules/general-unit-test.md` asks for, and removes an asymmetry that exists only in the JSON lane. It is a narrow production behavior change and must be filed and reviewed on its own, not folded into this fix. It can only be adopted together with the test repair delivered here.
  2. **File separately:** `quality-tiers.yml` does not exist at this repository root although `.claude/rules/quality-tiers.md` requires it. Out of scope here.
  3. **File separately:** `scripts/dev_tools/fix_all.py` exceeds the 500-line file-size limit at 628 lines.
  4. After merge, observe the next several CI runs of the full Python suite for any recurrence of the two node ids or of `PytestUnhandledThreadExceptionWarning`.
- Links: issue, PRs, related docs
  - Issue: https://github.com/drmoisan/drm-copilot/issues/505
  - Research: `docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/research/2026-08-23T23-25-fix-all-cancel-propagation-race.md`
  - Promoted record: `docs/features/potential/promoted/2026-08-22-fix-all-json-cancel-thread-race.md`
  - Policy: `.claude/rules/general-unit-test.md`, `.claude/rules/general-code-change.md`, `.claude/rules/quality-tiers.md`
