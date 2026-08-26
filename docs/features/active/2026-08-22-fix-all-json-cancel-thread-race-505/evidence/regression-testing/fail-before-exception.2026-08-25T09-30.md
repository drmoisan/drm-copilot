# Fail-Before Exception Dossier — Candidate B (the two racy tests)

- **Task:** [P1-T3]
- **Issue:** #505
- **Scope of this dossier:** candidate B only, that is the two timing-dependent end-to-end tests. It
  does **not** cover candidate G, which has a clean deterministic fail-before run planned at
  [P5-T2] and therefore needs no exception.

Timestamp: 2026-08-25T09-30

WhyFailingRunImpossible: The pre-fix failure is a load-dependent thread-scheduling race with no
deterministic failing run available. Whether the two tests pass or fail is decided by whether the
Python lane's time-to-failure exceeds a fixed 10 millisecond wall-clock grace period in production
code, which is a property of host speed and instantaneous machine load rather than of the test
inputs. Neither outcome can be forced from the test side without changing the production timing
constant, and no sequence of pre-fix runs can be constructed that fails on demand. A single pre-fix
run is therefore not reliable fail-before evidence in either direction: a pass does not show the
defect is absent and a failure could not be reproduced on request. The plan anticipated this and
required this dossier **unconditionally**, including in the case where the repeated-run protocol
does observe failures, because a probabilistic failure is not a deterministic fail-before artifact
and the audit trail must state that rather than imply a determinism the pre-fix code never had.

## Alternative Proof

The plan specifies the alternative proof as the line-cited static argument recorded in the research
document plus the measured failure count from the [P1-T1] protocol run. Both are supplied below, and
a third independent piece of measured evidence from the Phase 0 baseline is added because it
converts the static argument into an observation.

### Part 1 — Measured failure count from [P1-T1]

Source artifact:
`docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/evidence/regression-testing/pre-fix-repeated-run.2026-08-25T09-30.md`

- Iterations: 50
- FailureCount: 0 — `tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_json_cancel_before_validate_returns_canceled_result`
- FailureCount: 0 — `tests/scripts/dev_tools/test_fix_all.py::test_fail_fast_cancels_json_before_validate`

Concurrent load was verified present for the protocol's full 92.5-second duration by 12 consecutive
full-suite runs. A preliminary execution under lighter load also produced 0 and 0 over 50
iterations, so the total measured pre-fix observation on this host is **zero failures across 100
iterations and 200 node executions**.

The zero count is recorded as measured. It does not establish that the defect is absent; it
establishes that this host, even under sustained full-suite load, is fast enough that the 10
millisecond grace period usually absorbs the inter-thread skew. That is precisely why a failing run
could not be produced to order, and it is the direct empirical basis for the
`WhyFailingRunImpossible:` statement above.

### Part 2 — Line-cited static argument

**Citation 1 — `scripts/dev_tools/fix_all_branches.py` lines 111-112, the 10 ms grace wait.**

```
110:     # cancel event before JSON validation starts.
111:     if not complete_all:
112:         cancel_event.wait(api.CANCEL_CHECK_DELAY_S)
113:     if cancel_event.is_set() and not complete_all:
```

Line 112 is a bounded wall-clock wait inside production code that the tests exercise. Its argument
is a fixed duration, not a synchronization handshake, so it does not wait *for* the Python lane; it
waits *a fixed span* and then re-checks whatever state happens to exist. The correctness of the two
tests depends on the Python lane having recorded its failure before that span elapses.

**Citation 2 — `scripts/dev_tools/fix_all.py` line 360, the delay constant.**

```
358:
359: # Brief delay to allow fail-fast cancellation signals between step boundaries.
360: CANCEL_CHECK_DELAY_S: float = 0.01
361:
```

The span is 0.01 seconds, that is 10 milliseconds. The comment on line 359 states the intent
plainly: the delay exists to *allow* cancellation signals to arrive. An allowance is not a
guarantee. When the Python lane takes longer than 10 milliseconds to reach its failing step and set
the cancel event, the JSON lane's re-check at line 113 observes an unset event, proceeds to
`JSON: validate` at line 120, and the tests' assertion that `JSON: validate` is absent fails.

**Citation 3 — `scripts/dev_tools/fix_all_runtime.py` lines 141-150, the unordered thread launch.**

```
141:     def _runner(name: str, func: Callable[[], BranchResult]) -> None:
142:         result = func()
143:         results[name] = result
144:         if not result.success and not complete_all:
145:             cancel_event.set()
...
147:     for name, func in branch_functions:
148:         thread = threading.Thread(target=_runner, args=(name, func), daemon=True)
149:         threads.append(thread)
150:         thread.start()
```

The cancel event is set at line 145, inside a thread started at line 150. The lanes are launched as
concurrent daemon threads with no ordering constraint, so the relative progress of the Python lane
and the JSON lane is determined by the operating system scheduler. Nothing in the test or in the
production code establishes a happens-before relation between the Python lane reaching line 145 and
the JSON lane reaching `fix_all_branches.py` line 113. The tests assert an outcome that requires
that relation to hold.

### Part 3 — Measured confirmation that the tests take the timing-tolerant path

Source artifact:
`docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/evidence/baseline/targeted-module-coverage.2026-08-25T09-17.md`

The Phase 0 targeted-coverage run over
`tests/scripts/dev_tools/test_fix_all.py`,
`tests/scripts/dev_tools/test_fix_all_failure_paths.py`, and
`tests/scripts/dev_tools/test_fix_all_branches.py` reported, for
`scripts/dev_tools/fix_all_branches.py`:

- `missing_lines`: `[103, 104, 105]`
- `missing_branches`: `[[102, 103]]`

Lines 103-105 are the body of the **first** cancel check, whose condition is at line 102, and the
uncovered edge `[102, 103]` is that check's True edge. The measurement therefore shows that no test
in the existing suite reaches the first cancel check in the taken state. The two tests under
discussion pass by way of the **second** cancel check at line 113 — the one that fires only after
the 10 millisecond grace wait at line 112.

This converts the static argument into an observation. The tests do not merely have a theoretical
dependence on the grace period; they are measurably relying on it today. Any condition that delays
the Python lane past 10 milliseconds moves them from passing to failing, and their pass on this host
is a property of the host rather than of the code under test.

### Part 4 — The policy violation is independent of the observed failure count

`.claude/rules/general-unit-test.md`, Determinism Infrastructure, requires that "Given the same
inputs and environment, tests must produce the same results" and bans real wall-clock waits in test
code. `.claude/rules/python.md`, Pytest Rules, states "No sleeps, retries, or timing hacks." A test
whose outcome is decided by a fixed wall-clock span in the code it exercises violates the
determinism requirement whether or not it happened to fail during any particular measurement window.
The 0-of-100 measurement bounds the failure rate on this host; it does not exempt the tests from the
rule, and the reported flake in issue #505 was observed on a differently loaded machine.

## Remedy and the Post-Fix Assertion This Dossier Justifies

Candidate B substitutes an ordered synchronous thread stand-in so the Python lane runs to completion
before the JSON lane starts. The cancel event is then already set when the JSON lane reaches
`fix_all_branches.py` line 102, so the lane returns at the **first** cancel check and never reaches
the grace wait at line 112. The dependence on the 10 millisecond span is removed rather than made
more likely to be satisfied.

Because the repair is structural, the post-fix protocol at [P3-T3] asserts `FailureCount: 0` as a
property of ordering rather than of host speed, and its zero means something the pre-fix zero
recorded here does not.

SearchScope: `docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/evidence/regression-testing/`
and `docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/evidence/` (feature root
fallback; this feature is not versioned, so there is no version subfolder to search).

SearchPatterns: `fail-before-exception.*.md`

SearchResult: `docs/features/active/2026-08-22-fix-all-json-cancel-thread-race-505/evidence/regression-testing/fail-before-exception.2026-08-25T09-30.md`
(this dossier). No prior dossier existed for this feature before this task.

Output Summary: Fail-before exception dossier recorded for candidate B. `WhyFailingRunImpossible:`
is non-empty and states that the pre-fix failure is a load-dependent thread-scheduling race with no
deterministic failing run available. Both required line ranges are cited with verbatim source:
`fix_all_branches.py` lines 111-112 (the bounded `cancel_event.wait(api.CANCEL_CHECK_DELAY_S)` grace
wait) and `fix_all.py` line 360 (`CANCEL_CHECK_DELAY_S: float = 0.01`, the 10 millisecond constant).
The alternative proof carries the measured [P1-T1] counts (Iterations 50, FailureCount 0 and 0; 0
failures across 100 iterations including the preliminary execution), a third citation at
`fix_all_runtime.py` lines 141-150 showing the unordered daemon-thread launch, and the Phase 0
coverage measurement (`missing_lines [103, 104, 105]`, `missing_branches [[102, 103]]`) proving the
two tests currently pass through the timing-tolerant second cancel check. This dossier covers
candidate B only; candidate G has a real failing-then-passing run planned at [P5-T2].
