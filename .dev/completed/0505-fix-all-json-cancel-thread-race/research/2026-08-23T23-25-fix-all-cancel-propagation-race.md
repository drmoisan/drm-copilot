# Research — fix-all JSON cancel propagation race (Issue #505)

- **Issue:** #505
- **Branch:** `bug/fix-all-json-cancel-thread-race-505`
- **Date:** 2026-08-23T23-25
- **Author:** task-researcher
- **Method:** static reading of the production and test modules. No test, formatter, linter, or type checker was executed; a pre-implementation hook blocks those commands in this session. Every claim below cites file and line numbers.

## Summary

The failing assertion depends on a wall-clock grace period, not on an ordering guarantee. `scripts/dev_tools/fix_all_branches.py:111-112` calls `cancel_event.wait(api.CANCEL_CHECK_DELAY_S)` with `CANCEL_CHECK_DELAY_S = 0.01` (`scripts/dev_tools/fix_all.py:360`). The JSON lane therefore advances to `JSON: validate` whenever the Python lane has not failed within 10 ms of the JSON lane finishing `JSON: format`. Under machine load, thread start-up plus three fake Black calls exceed that window and the lane advances. The test supplies no `JSON: validate` response, so `FakeRunner.run` records the call (`tests/scripts/dev_tools/test_fix_all_failure_paths.py:43`) and then raises (`:44`); the recorded call is what the assertion reports, and the raise is the `PytestUnhandledThreadExceptionWarning`. Both reported symptoms come from one event.

The production guarantee the test assumes — that a lane observes a sibling's failure before advancing — does not exist and cannot be constructed, because a sibling's failure time is not ordered with respect to another lane's step boundary. The guarantee production does make (a lane that finds `cancel_event` set at its boundary does not advance) is implemented and correct at `scripts/dev_tools/fix_all_branches.py:102-118`, reinforced by the runner-level fast path at `scripts/dev_tools/fix_all.py:412-414`. The unfalsifiable part of the test is therefore the interleaving, which is a test-side concern.

**Recommended fix:** make the interleaving deterministic in the tests by substituting an ordered, synchronous `threading.Thread` stand-in (the pattern already used by `_SkipBranchThread`, `tests/scripts/dev_tools/test_fix_all_failure_paths.py:425-461`) so the Python lane runs and fails before the JSON lane starts; add direct, single-threaded unit tests of `run_json_branch` cancel semantics; and harden `fix_all_runtime._runner` so a branch exception is recorded as a branch failure instead of vanishing into an unhandled thread exception. No lane-sequencing or cancel-semantics behavior changes.

---

## 1. Current state — lane and branch execution model (`scripts/dev_tools/fix_all_runtime.py`)

### Construction

| Element | Location | Behavior |
| --- | --- | --- |
| Shared cancel signal | `fix_all_runtime.py:30` | `cancel_event = threading.Event()`, created once per `run_fix_all` call. |
| Status board state | `fix_all_runtime.py:36-44` | `status_lock` plus a per-branch status dict; the board is only rendered when `use_interactive_board` is true (`:32-35`, `:49`). With a `StringIO` logger, `_stream_isatty` returns `False` (`fix_all.py:242-245`), so tests take the plain `print` path at `:71-72`. |
| Runner factory | `fix_all_runtime.py:74-82` | When a `runner_factory` is injected the injected factory is used verbatim (`:75-76`). Otherwise a `SubprocessCommandRunner` is built with `cancel_event=None if complete_all else cancel_event` (`:80`). |
| Branch adapters | `fix_all_runtime.py:89-128` | Five closures forwarding to `fix_all_branches` / `fix_all_branches_extra`. Only the JSON adapter forwards `cancel_event` and `complete_all` (`:93-94`); the comment at `:87-88` states this explicitly. |
| Lane list and order | `fix_all_runtime.py:130-136` | `("json", "shell", "python", "powershell", "typescript")` — JSON is first, Python third. |

### Thread lifecycle

- `fix_all_runtime.py:141-145` defines the thread target `_runner(name, func)`. It calls `func()`, assigns `results[name] = result` **after** the call returns (`:143`), and sets the cancel event when the lane failed and `complete_all` is off (`:144-145`).
- `fix_all_runtime.py:147-150` constructs one daemon `threading.Thread` per lane in list order and starts it immediately.
- `fix_all_runtime.py:152-153` joins every thread.
- `fix_all_runtime.py:155-181` aggregates: the per-branch log loop skips a `None` result (`:156-158`), and the summary emits `Branch {name} did not produce a result.` for a missing result (`:171`).
- `fix_all_runtime.py:183` returns `0 if all(res.success for res in results.values()) else 1` — computed over **recorded** results only.

There is no exception handling anywhere in `_runner`. An exception raised by a branch function terminates that thread, leaves `results[name]` unset, and is surfaced only by `threading.excepthook`.

### Where `complete_all` changes behavior

Three places, all consistent:

1. `fix_all_runtime.py:80` — the real runner receives no cancel event under `complete_all`, disabling the runner-level fast path.
2. `fix_all_runtime.py:144` — a lane failure does not set the cancel event under `complete_all`.
3. `fix_all_branches.py:102`, `:111`, `:113` — the JSON lane skips both cancel checks and the grace wait under `complete_all`.

### The JSON lane step sequence (`scripts/dev_tools/fix_all_branches.py:47-145`)

1. `:73-75` — private `StringIO` branch stream, branch logger, branch runner from the factory.
2. `:77-98` — `emit_status_transition("json", "JSON: format")` then `run_simple_step` for `JSON: format`; on failure returns `failed_step="JSON: format"`.
3. `:100-107` — **first cancel check**: `if cancel_event.is_set() and not complete_all:` return `failed_step="Canceled"`.
4. `:109-112` — **wall-clock grace period**: `if not complete_all: cancel_event.wait(api.CANCEL_CHECK_DELAY_S)`. The module docstring at `:24-27` records this as a required invariant of the extraction.
5. `:113-118` — **second cancel check**, same shape as the first.
6. `:120-141` — `emit_status_transition("json", "JSON: validate")` then `run_simple_step` for `JSON: validate`.
7. `:143-145` — success result.

`CANCEL_CHECK_DELAY_S: float = 0.01` is defined at `fix_all.py:360` with the comment "Brief delay to allow fail-fast cancellation signals between step boundaries." It is the only tunable in the mechanism and is not injectable.

The JSON lane is the only lane that reads the cancel event. `fix_all_branches.py:148-248` (shell), `:251-366` (powershell), `fix_all_branches_extra.py:41-190` (python), and `:216-359` (typescript) never reference it.

### Second cancel layer, in production only

`SubprocessCommandRunner.run` (`fix_all.py:385-429`) checks the event before spawning anything:

```python
if self.cancel_event is not None and self.cancel_event.is_set():
    return CommandResult(returncode=-1, output="Canceled")
```

(`fix_all.py:412-414`.) The comment at `:416-419` states the design: "the cancel_event is checked between steps, not during. The fail-fast behavior works by preventing the *next* step from starting when cancel_event is set." This layer applies to **every** lane, not just JSON, and is the mechanism that actually prevents external tools from launching after a sibling failure. The `FakeRunner` used by the tests does not implement it (`test_fix_all_failure_paths.py:40-45`), so the tests exercise only the lane-boundary layer.

The Python lane's failure path in the failing test is `run_black_with_retry` (`fix_all.py:493-521`): it loops `max_retries` times, and with `max_black_retries=3` and three queued non-zero results it performs three runner calls before returning `False`.

---

## 2. The failing test and the exact interleaving (`tests/scripts/dev_tools/test_fix_all_failure_paths.py`)

### What the test drives

`test_json_cancel_before_validate_returns_canceled_result` (`:144-170`):

- `:148` — starts from `base_success_responses()` (`:80-113`), which gives every lane a full set of zero-exit responses, including `"JSON: validate": [make_result(0)]`.
- `:149-153` — replaces the Python lane's `Black: format` queue with three non-zero results, so the Python lane fails after three runner calls.
- `:154` — **replaces the whole JSON response map with `{"JSON: format": [make_result(0)]}`**, deliberately removing the `JSON: validate` entry so that reaching that step is detectable.
- `:159-165` — calls `run_fix_all` without `complete_all`, so fail-fast is active.
- `:168-170` — asserts `exit_code == 1` and `"JSON: validate" not in json_calls`.

### The fake runner

`FakeRunner.run` (`:40-45`):

```python
self.calls.append((step_name, list(command)))
if step_name not in self.responses or not self.responses[step_name]:
    raise AssertionError(f"No response configured for {step_name}")
```

The call is recorded **before** the raise. `FakeRunnerFactory.__call__` (`:60-67`) builds one `FakeRunner` per lane and stores it in `self.runners`, which is how the test reads `json_calls`.

### Passing interleaving

1. Main thread starts the JSON thread (`fix_all_runtime.py:147-150`, first iteration), then the shell thread, then the Python thread.
2. The JSON lane runs `JSON: format` (one fake call) and reaches the first cancel check (`fix_all_branches.py:102`).
3. The Python lane completes three fake `Black: format` calls, returns a failure `BranchResult`, and `_runner` sets the cancel event (`fix_all_runtime.py:144-145`).
4. Whether at `:102` or after the 10 ms wait at `:112-113`, the JSON lane observes the set event and returns `failed_step="Canceled"` without calling the runner again.
5. `json_calls == ["JSON: format"]`; the assertion holds.

### Failing interleaving

1. Same start. The JSON lane finishes `JSON: format` and finds the event clear at `:102`.
2. `cancel_event.wait(0.01)` at `:112` times out because the Python thread has not yet been scheduled far enough to finish its three calls. On a loaded workstation, thread start-up latency alone can exceed 10 ms.
3. The second check at `:113` also finds the event clear.
4. `:120` emits the status transition; `:121` calls `run_simple_step` for `JSON: validate`; `FakeRunner.run` appends `("JSON: validate", [...])` to `calls` and raises `AssertionError("No response configured for JSON: validate")`.
5. The exception propagates out of `run_json_branch`, out of the adapter, out of `_runner` (`fix_all_runtime.py:142`), and terminates the JSON thread. `results["json"]` is never assigned.
6. The main thread joins all threads, prints `Branch json did not produce a result.` (`:171`), and returns `1` because the Python lane's recorded result is a failure (`:183`).
7. `assert exit_code == 1` passes. `json_calls` is `['JSON: format', 'JSON: validate']`, so the second assertion fails with exactly the reported message.

The window is bounded by a single constant: the outcome flips when the Python lane's time-to-failure exceeds 10 ms measured from the JSON lane's first cancel check. Nothing else in the test or the production code influences it.

---

## 3. Source of `PytestUnhandledThreadExceptionWarning`

**Finding:** the warning is a downstream consequence of the same race, not an independent failure. It also exposes a distinct, separately-characterizable production defect that the race merely made visible.

### Evidence that it is the same event

- The only exception reachable on this path is `AssertionError: No response configured for JSON: validate` from `test_fix_all_failure_paths.py:44`, raised because `:154` removed the `JSON: validate` entry.
- The thread target named in the warning is `_runner`, which is the target function defined at `fix_all_runtime.py:141` and passed at `:148`.
- The reported assertion list `['JSON: format', 'JSON: validate']` proves the runner call was recorded at `:43`, which is the line immediately preceding the raise at `:44`. A recorded `JSON: validate` call in this test necessarily implies the raise.
- The thread number in `Thread-1 (_runner)` is a process-global counter, so it is not itself decisive in a full-suite run; the identification rests on the target name plus the recorded call.

### The distinct defect it exposes

`_runner` (`fix_all_runtime.py:141-145`) has no exception handling. Consequences, independent of this issue:

1. A branch function that raises for any reason leaves `results[name]` unset.
2. `fix_all_runtime.py:183` computes `all(res.success for res in results.values())` over recorded results only. If the four other lanes succeed, `run_fix_all` returns **0** even though one lane crashed.
3. The existing test `test_runtime_reports_missing_result_when_branch_absent` (`:464-493`) documents exactly this exit-code behavior: it asserts `exit_code == 0` with the JSON result missing, with the comment at `:487-488` acknowledging that "the exit code reflects only recorded results".
4. The crash is reported only through `threading.excepthook`, so in a real `fix-all` run the operator sees a traceback on stderr and a `Branch json did not produce a result.` line, followed by a zero exit code.

This is a genuine production defect (a crashed lane reports success) with the same blast radius as the flake fix, and addressing it removes the unhandled-thread-exception class of symptom permanently rather than only for this test. See item 5, candidate G.

---

## 4. Is production non-deterministic, or only the test?

### Question A — does `fix_all_runtime` guarantee that a lane observes a sibling's failure before advancing to its next step?

**No, and the guarantee is not constructible.** The cancel signal is produced by a concurrent lane at a time determined by that lane's own workload (`fix_all_runtime.py:144-145`). The JSON lane's boundary checks (`fix_all_branches.py:102`, `:113`) are point-in-time reads. Between them sits a fixed 10 ms wall-clock grace period (`:112`, constant at `fix_all.py:360`). A sibling that fails at 11 ms is not observed; a sibling that fails at 9 ms is. No scheduling discipline changes that, because the sibling's failure time is genuinely unordered with respect to the JSON lane's boundary. The only ways to force the ordering are to serialize the lanes or to make the JSON lane block until every other lane has reported, both of which defeat the purpose of the parallel pipeline (`fix_all_runtime.py:147-153`).

### Question B — what does production actually guarantee?

**The conditional invariant, and it is implemented correctly.** If `cancel_event` is set at the instant a lane reaches its boundary check and `complete_all` is off, the lane returns a `Canceled` result and does not run the next step (`fix_all_branches.py:102-107` and `:113-118`). `threading.Event.set` and `is_set` are internally lock-protected in CPython, so there is no cross-thread visibility hazard; the read is a correct observation of the event's state at that moment.

A second, stronger production guarantee applies to **every** lane in real runs: once the event is set, `SubprocessCommandRunner.run` returns `CommandResult(returncode=-1, output="Canceled")` without spawning anything (`fix_all.py:412-414`). So losing the 10 ms race in production costs at most one no-op runner call and a differently-labelled failed step (`failed_step="JSON: validate"` with a `-1` result instead of `failed_step="Canceled"`), in a run that is already failing because a sibling failed. The process exit code is unaffected in either case: `fix_all_runtime.py:183` returns 1 as soon as any recorded lane failed.

### Conclusion

Production is timing-dependent by design and correct under that design; fail-fast is a latency optimization, not a correctness invariant. The test asserts a stronger property (a specific interleaving) than production ever promised. **The primary fix belongs in the tests**, which must establish the precondition (`cancel_event` already set) deterministically instead of hoping for it.

Two secondary observations qualify this conclusion and are carried into item 5:

- `.claude/rules/general-unit-test.md` (Determinism Infrastructure) says production code under test should not read wall-clock time directly. `cancel_event.wait(CANCEL_CHECK_DELAY_S)` at `fix_all_branches.py:112` is a wall-clock-dependent operation in code under test. That is an argument for eventually removing or injecting it (candidates E and F), not for keeping the flaky assertion.
- The unhandled-thread-exception path (item 3) is a real production defect and is production-side work.

---

## 5. Candidate fixes

Determinism constraint applied to every candidate: `.claude/rules/general-unit-test.md` bans real wall-clock waits in test code (`setTimeout`, `Thread.Sleep`, `Task.Delay`, wall-clock waits, unmanaged clock reads). In Python terms this rules out `time.sleep`, `Event.wait(timeout)`, and any assertion whose outcome depends on elapsed time.

### Candidate A — direct single-threaded unit tests of `run_json_branch`

Call `fix_all_branches.run_json_branch` directly with an explicit `threading.Event` and a `FakeRunner`, with no threads at all.

- A1: event pre-set, `complete_all=False`. Expect `calls == ["JSON: format"]`, `failed_step == "Canceled"`. Covers `fix_all_branches.py:102-107`.
- A2: an event stand-in whose `wait(timeout)` transitions the flag to set and returns `True`, modelling a sibling failing during the grace period. Covers `:111-118` with no elapsed-time dependency.
- A3: `complete_all=True` with the event set. Expect both steps to run. Covers the `complete_all` short-circuits at `:102`, `:111`, `:113`.
- Writes: test files only. Production behavior: unchanged. Deterministic: yes, no concurrency. Policy: compliant.
- Limitation: does not by itself repair the two racy end-to-end tests.

### Candidate B — deterministic ordered `Thread` stand-in for the end-to-end tests (recommended core)

Monkeypatch `fix_all_runtime.threading.Thread` with a stand-in that defers each lane target and executes all of them synchronously in a configured order (Python first, then JSON), so the Python lane's failure has already called `cancel_event.set()` (`fix_all_runtime.py:144-145`) before the JSON lane starts. The JSON lane then returns at the **first** check (`fix_all_branches.py:102`) and never reaches the grace wait at `:112`.

- Precedent: `_SkipBranchThread` (`test_fix_all_failure_paths.py:425-461`) already replaces `runtime.threading.Thread` with a synchronous stand-in and is an accepted pattern in this module. Its docstring states the same motivation: obtain a deterministic outcome "without raising an exception in a worker thread".
- A naive synchronous stand-in that runs at `start()` in list order would run JSON **first** (`fix_all_runtime.py:130-136`) and fail deterministically, so the stand-in must control ordering — for example by registering targets at `start()` and running them in a configured priority order on the first `join()`. Isolate the registry per test by constructing a fresh class from a factory function rather than using class-level mutable state.
- Writes: test files (plus one shared test-support module if the stand-in is shared). Production behavior: unchanged. Deterministic: yes; zero threads, zero elapsed-time dependence. Policy: compliant.
- Trade-off: the end-to-end test no longer exercises real concurrency. Concurrency itself is not what the assertion is about, and `_SkipBranchThread` already establishes that this trade is acceptable here.

### Candidate C — check `cancel_event` at every step boundary in every lane

Extend the JSON lane's boundary-check pattern to the shell, python, powershell, and typescript lanes.

- Writes: `scripts/dev_tools/fix_all_branches.py`, `scripts/dev_tools/fix_all_branches_extra.py`, `scripts/dev_tools/fix_all_runtime.py` (to forward the event to every adapter), and multiple test modules whose per-lane call expectations would change.
- **Does not fix the flake.** It changes which lanes can cancel, not whether the signal arrives before a given boundary. The race at `fix_all_branches.py:102-118` is untouched.
- Marginal production benefit is small because `fix_all.py:412-414` already short-circuits every lane's next command at the runner level.
- Rejected as a fix for this issue.

### Candidate D — make the fake runner block at a controllable point

Gate the JSON `FakeRunner` on a synchronization primitive released only after the Python lane's failure sets the cancel event.

- Requires a blocking wait inside a worker thread. A timeout-free wait deadlocks the suite if the expected signal never arrives (for example after an unrelated change to the Python lane); a bounded wait reintroduces a wall-clock dependency, which the determinism rule prohibits in test code.
- Keeps five real threads for no assertion-level benefit over candidate B.
- Rejected.

### Candidate E — delete the wall-clock grace period

Remove `fix_all_branches.py:111-112` so the boundary is a pure `is_set()` read, relying on `fix_all.py:412-414` for fail-fast in real runs.

- Writes: `scripts/dev_tools/fix_all_branches.py`, `scripts/dev_tools/fix_all.py` (retire `CANCEL_CHECK_DELAY_S`), and the tests.
- Removes the wall-clock dependency from production code under test, which is what `.claude/rules/general-unit-test.md` asks for, and removes an asymmetry that exists only in the JSON lane.
- Changes production behavior in a narrow window: a sibling failing within 10 ms would now be reported as `failed_step="JSON: validate"` with a `-1` result rather than `failed_step="Canceled"`. The exit code is unchanged (`fix_all_runtime.py:183`).
- Makes the two existing racy tests fail **deterministically** rather than intermittently, so it can only be adopted together with candidate B.
- Not recommended for this bug fix: it is a production behavior change that the flake does not require. Recorded as the preferred follow-up if the team decides to eliminate the wall-clock wait.

### Candidate F — injectable cancel-observation seam

Replace `fix_all_branches.py:111-112` with a call to a named, patchable helper (for example `api.await_cancel_signal(...)`) that tests substitute. This is the promoted record's "defined barrier the test can drive".

- Writes: `scripts/dev_tools/fix_all.py`, `scripts/dev_tools/fix_all_branches.py`, plus tests.
- Adds a production seam whose only consumer is a test, while leaving the wall-clock default in place. `.claude/rules/general-code-change.md` ranks simplicity first and warns against indirection; candidate B obtains the same determinism with no production surface.
- Rejected, but noted as the fallback if reviewers require the invariant to be expressed production-side.

### Candidate G — harden `_runner` against branch exceptions (recommended secondary)

Wrap the body of `_runner` (`fix_all_runtime.py:141-145`) so an exception raised by a branch function is recorded as a failing `BranchResult` (with the exception text as output) and still triggers the cancel set under fail-fast, instead of terminating the thread silently.

- Writes: `scripts/dev_tools/fix_all_runtime.py`, plus one added test.
- Fixes the distinct defect in item 3: a crashed lane currently yields exit code 0 when the other lanes pass.
- Does **not** break `test_runtime_reports_missing_result_when_branch_absent` (`:464-493`): that test's `_SkipBranchThread.start` returns without ever calling the target (`:450-457`), so `_runner` does not execute and the missing-result aggregation path at `fix_all_runtime.py:156-158` and `:171` is preserved along with its `exit_code == 0` assertion.
- Scope note: this is separable from the flake fix. If the orchestrator wants strictly minimal scope, drop candidate G and file it as its own issue; the consequence is that any future branch exception remains a silent success.

### Recommendation

Adopt **B + A + G**.

1. **B** repairs both racy tests at the point where the defect actually lives (an unestablished precondition), preserves the existing node ids and their intent, and introduces no production behavior change.
2. **A** replaces a probabilistic end-to-end observation with direct, exhaustive coverage of the three cancel branches in `run_json_branch`, which is what the issue's "unit coverage areas: lane sequencing and cancel propagation" asks for.
3. **G** removes the second reported symptom at its source and closes a real production defect that the flake exposed.

C, D, E, and F are rejected for the reasons recorded above; E is the recommended follow-up if the wall-clock wait is to be removed later.

---

## 6. File set a fix would write

Repo-relative, concrete paths, recommended scope (B + A + G).

**WRITE — production**

- `scripts/dev_tools/fix_all_runtime.py` — candidate G only (`_runner` exception handling). Drops out entirely under minimal scope.

**WRITE — tests**

- `tests/scripts/dev_tools/test_fix_all_failure_paths.py` — repair `test_json_cancel_before_validate_returns_canceled_result` with the ordered stand-in; add the candidate A unit tests; add the candidate G branch-exception test.
- `tests/scripts/dev_tools/test_fix_all.py` — repair `test_fail_fast_cancels_json_before_validate`, which carries the identical latent race (see item 7).
- `tests/scripts/dev_tools/fix_all_thread_stubs.py` — new shared test-support module holding the ordered `Thread` stand-in factory used by both test modules. Alternative: inline the stand-in in each test module and drop this path; the two modules already duplicate `FakeRunner`, `FakeRunnerFactory`, and `base_success_responses`, so either choice has precedent. `.claude/rules/general-code-change.md` (Reusability) favors the shared module.

**WRITE — feature documents (this item's own folder)**

- `docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/spec.md`
- `docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/plan.2026-08-23T23-23.md`
- `docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/issue.md`

**Not written — stated explicitly so the list is not misread as incomplete**

- No file under `.claude/rules/` is written. The fix conforms to the existing determinism rules rather than amending them.
- `quality-tiers.yml` is not written. It does not exist anywhere in the repository (see item 8).
- No file under `.github/instructions/` is written.
- `pyproject.toml` is not written. No coverage, pytest, or lint configuration change is required.
- `scripts/dev_tools/fix_all.py` and `scripts/dev_tools/fix_all_branches.py` are not written under the recommended scope. They enter the write set only if candidate E or F is adopted instead.
- Evidence artifacts land under this feature's canonical `evidence` directory per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. Their filenames carry run timestamps that are not knowable in advance, so they are deliberately not enumerated as path tokens here.

**READ-ONLY — read but not modified**

- `scripts/dev_tools/fix_all.py`
- `scripts/dev_tools/fix_all_branches.py`
- `scripts/dev_tools/fix_all_branches_extra.py`
- `tests/scripts/dev_tools/conftest.py`
- `tests/scripts/dev_tools/test_fix_all_branches.py`
- `pyproject.toml`
- `.claude/rules/general-unit-test.md`
- `.claude/rules/general-code-change.md`
- `.claude/rules/quality-tiers.md`
- `.claude/rules/python.md`
- `docs/features/potential/promoted/2026-08-22-fix-all-json-cancel-thread-race.md`
- `.github/workflows/_quality-checks.yml`

---

## 7. Other tests on the same cancel path

Searched `tests/` for `cancel_event`, `complete_all`, `run_json_branch`, `CANCEL_CHECK_DELAY_S`, and `run_fix_all`. Four files match: the two `fix_all` test modules, `test_fix_all_branches.py`, and `conftest.py`.

| Test | Location | Status |
| --- | --- | --- |
| `test_fail_fast_cancels_json_before_validate` | `tests/scripts/dev_tools/test_fix_all.py:382-399` | **Carries the identical latent race and must be fixed in the same change.** It omits the `JSON: validate` response (`:386-388`), runs without `complete_all` (`:391-396`), and asserts `"JSON: validate" not in json_calls` (`:399`). Its sibling failure is at `Pyright: type-check` (`:385`), which is the third Python step, so its race window is at least as tight as the reported one. |
| `test_json_cancel_before_validate_returns_canceled_result` | `tests/scripts/dev_tools/test_fix_all_failure_paths.py:144-170` | The reported flake. Fixed by candidate B. |
| `test_complete_all_allows_json_validate_after_python_failure` | `tests/scripts/dev_tools/test_fix_all.py:402-420` | Unaffected. `complete_all=True` short-circuits both cancel checks and the grace wait (`fix_all_branches.py:102`, `:111`, `:113`), so the outcome is timing-independent. |
| `test_json_format_failure_returns_fail_result` | `tests/scripts/dev_tools/test_fix_all_failure_paths.py:119-141` | Unaffected. `complete_all=True`; the JSON lane stops at its own format failure. |
| `test_json_validate_failure_returns_fail_result` | `tests/scripts/dev_tools/test_fix_all_failure_paths.py:173-197` | Unaffected. `complete_all=True`. |
| `test_python_ruff_logs_command_output_when_present` | `tests/scripts/dev_tools/test_fix_all_failure_paths.py:286-311` | Not a correctness risk, but it runs with `complete_all` off and all lanes passing, so the JSON lane executes the full 10 ms wait at `fix_all_branches.py:112`. No sibling fails, so no outcome depends on it; it is pure added latency. |
| `test_runtime_emits_no_output_for_empty_branch_output` | `tests/scripts/dev_tools/test_fix_all_failure_paths.py:397-422` | Unaffected. The JSON branch function is replaced wholesale (`:408`), so no cancel logic runs. |
| `test_runtime_reports_missing_result_when_branch_absent` | `tests/scripts/dev_tools/test_fix_all_failure_paths.py:464-493` | Unaffected by candidates A, B, and G. Its stand-in never invokes the target (`:450-457`), so `_runner` does not execute and its `exit_code == 0` assertion continues to hold under candidate G. |
| `test_subprocess_runner_returns_immediately_when_already_cancelled` | `tests/scripts/dev_tools/test_fix_all_branches.py:392-426` | Unaffected. Covers the runner-level fast path at `fix_all.py:412-414` in isolation, single-threaded and deterministic. |
| `test_subprocess_runner_runs_normally_with_cancel_event_not_set` | `tests/scripts/dev_tools/test_fix_all_branches.py:429-455` | Unaffected, same reasoning. |
| `stub_npm_resolution` autouse fixture | `tests/scripts/dev_tools/conftest.py:19-38` | Unaffected, but load-bearing: every `run_fix_all` test depends on it to keep the typescript lane off the machine PATH. Candidate A's direct `run_json_branch` tests do not need it. |

No test currently calls `fix_all_branches.run_json_branch` directly; the only reference outside production code is the monkeypatch at `test_fix_all_failure_paths.py:408`. Candidate A therefore adds new coverage rather than duplicating existing coverage.

---

## 8. Tier classification and coverage obligations

**`quality-tiers.yml` does not exist in this repository.** A glob for `**/quality-tiers.yml` returned no files; the only matches for the name are `.claude/rules/quality-tiers.md` and its published copy under `extensions/drm-copilot/resources/claude-customizations/.claude/rules/quality-tiers.md`, plus two evidence documents under `docs/features/active/2026-08-07-parallel-schema-validators-444/evidence/`. `.claude/rules/quality-tiers.md` states that the file must exist at repo root and that an unclassified project fails CI. This gap is recorded as an observation; it is out of scope for issue #505 and this fix must not create the file.

Applying the tier descriptions in `.claude/rules/quality-tiers.md` directly, `scripts/dev_tools/` is developer tooling and maps to **T4 — Scaffolding**.

Coverage obligations, which are uniform across T1–T4 and therefore unaffected by the classification gap:

- **Line coverage >= 85%** (`.claude/rules/quality-tiers.md`, Uniform section; `.claude/rules/general-unit-test.md`, Coverage Requirements; `.claude/rules/python.md:88`).
- **Branch coverage >= 75%** for Python, since `coverage.py` measures branch coverage (`.claude/rules/python.md:89`). Measurement requires `--cov-branch`, which `.claude/rules/python.md:16` includes in the canonical command; `pyproject.toml` `[tool.coverage.run]` at lines 119-127 does **not** set `branch = true`, so branch data is produced only when the flag is passed on the command line. This fix should not change that configuration.
- **No regression on changed lines.** The lines added by candidate G inside `_runner` must be covered by the added branch-exception test; the tests added under candidate A cover `fix_all_branches.py:100-118` directly.
- Coverage scope is `source = ["src", "scripts/dev_tools"]` with `tests/*` omitted (`pyproject.toml:119-127`), so the new test-support module under `tests/` is outside the denominator and complies with the Coverage Exclusion Policy (test infrastructure is a permitted exclusion; no production path is excluded).
- T4 imposes no property-test density, no mutation-score floor, and no golden-test requirement.

---

## Testing implications (strategy only, no test code)

1. **Deterministic end-to-end regression.** Both racy tests keep their node ids and their `"JSON: validate" not in json_calls` assertion, but establish the precondition by ordering the lanes explicitly through the substituted `Thread` stand-in. The regression must fail before the fix (the current form is the failure) and pass on every run afterwards. A useful acceptance check, consistent with the issue's validation note, is repeated execution of the node ids under artificial load with zero failures; the assertion itself no longer depends on load, so the loop is confirmatory rather than probabilistic.
2. **Unit coverage of the invariant.** Three direct `run_json_branch` cases (event pre-set, event set during the grace observation, `complete_all=True` with the event set) assert the conditional invariant production actually guarantees, in a single thread, with no elapsed-time dependency.
3. **Branch-exception coverage.** One test asserting that a lane whose branch function raises is recorded as a failing `BranchResult`, that the run's exit code is 1, and that no unhandled thread exception is emitted.
4. **Negative and boundary cases.** `complete_all=True` must continue to run `JSON: validate` after a sibling failure (`test_fix_all.py:402-420` already asserts this and must keep passing unmodified).
5. **Banned APIs.** No `time.sleep`, no bounded `Event.wait`, no elapsed-time assertion in any added or modified test. All added synchronization is either absent (single-threaded) or replaced by explicit ordering.
