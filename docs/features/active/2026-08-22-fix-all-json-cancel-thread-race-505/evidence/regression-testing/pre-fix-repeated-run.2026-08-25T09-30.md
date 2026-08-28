# Pre-Fix Repeated-Run Protocol (50 iterations under concurrent load)

- **Task:** [P1-T1] `[expect-fail]`
- **Issue:** #505
- **Tree state:** unmodified production and test sources; branch
  `bug/fix-all-json-cancel-thread-race-505` at commit `1459cb3f` (Phase 0 evidence only; no source
  file changed)

Timestamp: 2026-08-25T09-30

Command:

Load shell (started first, ran for the whole protocol):

```
pwsh -NoProfile -Command "1..12 | ForEach-Object { poetry run pytest -q }"
```

Protocol shell (the 50-iteration measurement; `'ITER ' + $_` is emitted per iteration so each
iteration's block is separable when tallying by hand):

```
pwsh -NoProfile -Command "1..50 | ForEach-Object { 'ITER ' + $_; poetry run pytest tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_json_cancel_before_validate_returns_canceled_result tests/scripts/dev_tools/test_fix_all.py::test_fail_fast_cancels_json_before_validate -q }"
```

EXIT_CODE: 0

**No `ExpectedExitCode` is declared for this task, by the plan's explicit instruction.** A PowerShell
`ForEach-Object` pipeline exits with the last iteration's code, and the pre-fix failure is
intermittent, so an observed code of 0 is legitimate here and carries no signal. The tallied
`FailureCount:` values below are the signal.

## Result

- Iterations: 50
- FailureCount: 0 — `tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_json_cancel_before_validate_returns_canceled_result`
- FailureCount: 0 — `tests/scripts/dev_tools/test_fix_all.py::test_fail_fast_cancels_json_before_validate`

## How the Two Counts Were Tallied

The loop does not compute per-node-ID totals, so each iteration's block was counted by hand from the
captured output. The tally was cross-checked three ways against the same capture file:

| Check | Expected if zero failures | Observed |
| --- | --- | --- |
| Count of `ITER ` markers (iterations actually executed) | 50 | 50 |
| Count of iterations whose summary line reads `2 passed` | 50 | 50 |
| Count of lines naming `test_json_cancel_before_validate_returns_canceled_result` as failed | 0 | 0 |
| Count of lines naming `test_fail_fast_cancels_json_before_validate` as failed | 0 | 0 |

Every one of the 50 iterations produced the summary `2 passed`. Under `pytest -q`, a failing node is
reported on its own `FAILED <nodeid>` line in the short summary, so zero such lines for either node
ID over 50 iterations that all report `2 passed` is a complete and consistent tally. 50 iterations
times 2 node IDs equals 100 node executions, all passing.

## Wall-Clock Cost

The 50-iteration protocol took **1 minute 32.5 seconds** (`real 1m32.517s`), started 09:28:05 and
ended 09:29:38 local time. Per-iteration cost is about 1.85 seconds under load and about 1.42
seconds unloaded, dominated by Poetry and pytest process startup rather than by the two tests, which
execute in about 0.04 seconds. The protocol is not impractically slow in this environment and the
iteration count was not reduced.

## Concurrent-Load Verification

The plan requires the protocol to run "while a concurrent full-suite run occupies the machine". Load
presence was verified rather than assumed, because a load run that finishes early would leave part
of the protocol running on an idle machine and would not measure what the plan asks for.

The load shell executed **12 consecutive full-suite runs**, each reporting
`1 failed, 4116 passed, 5 skipped` in 7.0 to 9.3 seconds (the single failure is the pre-existing
push-down payload parity test recorded in the Phase 0 baseline artifact, not a `fix_all` failure).
Twelve iterations at roughly 8 seconds of test time plus process startup spans the protocol's 92.5
seconds; the load shell was started before the protocol and its completion notification arrived
after the protocol returned, so load was present for the protocol's full duration.

A first protocol execution had been run against a 4-iteration load, which exhausted itself after
roughly the first two-thirds of the protocol. That execution is not the authoritative measurement
and is reported only for completeness: it also produced 50 iterations, 50 `2 passed` summaries, and
0 failures for both node IDs. The two executions together are 100 iterations and 200 node
executions with zero observed failures.

## Interpretation — the zero count is the expected finding, not a null result

The zero failure count does not contradict the defect report; it is the direct measurement the plan
anticipated when it required a fail-before exception dossier ([P1-T3]) **even when the protocol
observes failures**. Three pieces of evidence establish the race is real and simply did not surface
in these 100 iterations:

1. **The pre-fix path is timing-dependent by construction.** `run_json_branch` in
   `scripts/dev_tools/fix_all_branches.py` performs a cancel check at line 102, then waits up to a
   fixed grace period at lines 111-112, then re-checks at line 113. Whether the Python lane's
   failure lands before line 102 or during the grace wait is decided by the relative scheduling of
   two real threads, not by the test.

2. **The Phase 0 targeted-coverage measurement shows which path these tests actually take.** In the
   baseline targeted run, `scripts/dev_tools/fix_all_branches.py` lines 103-105 were uncovered and
   the missing branch edge was `[102, 103]` — the True edge out of the first cancel check. The two
   tests therefore pass through the **second** cancel check at line 113, after the wall-clock grace
   wait. They are passing on the timing-tolerant path, which is exactly the condition that flips to
   a failure when the Python lane is slow enough that its failure has not yet been recorded when the
   grace wait expires.

3. **This machine is fast enough that the grace period usually absorbs the skew.** Load was applied
   precisely to widen that window, and 12 concurrent full-suite runs did not widen it enough on this
   host. The reported flake was observed on a differently loaded machine; a probability that is low
   here is not zero elsewhere, and a test whose outcome depends on host speed violates the
   Determinism Infrastructure rule in `.claude/rules/general-unit-test.md` whether or not it happens
   to fail on any given run.

The remedy is unaffected by this measurement. Candidate B removes the dependency on thread
scheduling entirely by running the lanes in a fixed order synchronously, so the post-fix protocol
([P3-T3]) asserts a `FailureCount: 0` that is structural rather than probabilistic.

Output Summary: Iterations: 50. FailureCount: 0 for
`tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_json_cancel_before_validate_returns_canceled_result`
and FailureCount: 0 for
`tests/scripts/dev_tools/test_fix_all.py::test_fail_fast_cancels_json_before_validate`. All 50
iterations reported `2 passed`; both counts were tallied by hand from the per-iteration output and
cross-checked three ways. Concurrent load was verified present for the protocol's full 92.5-second
duration (12 consecutive full-suite runs). Exit code 0 is observed and is legitimate for this task
per the plan; no `ExpectedExitCode` is declared. The zero failure count is the expected outcome for
a load-dependent race on a fast host and is the reason [P1-T3] must supply a fail-before exception
dossier; the Phase 0 targeted-coverage evidence (uncovered `fix_all_branches.py` lines 103-105,
missing branch edge `[102, 103]`) independently confirms these tests currently pass through the
timing-tolerant second cancel check rather than the first.
