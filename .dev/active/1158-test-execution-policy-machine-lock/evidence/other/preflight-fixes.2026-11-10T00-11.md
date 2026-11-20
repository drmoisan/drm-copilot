# Preflight Fixes

Timestamp: 2026-11-10T00-11
Plan: docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/plan.2026-11-09T16-31.md
Pass: single preflight after the permitted planner revision (plan version 1.3, spec version 0.5)

## Fixes

1. `## Acceptance Traceability` | literal formatting | The `## Caller Dispositions` section had been inserted between the AC2 and AC3 rows, so the AC3, AC4, and AC5 rows sat under `## Caller Dispositions` with no table header. The three rows were moved back into the traceability table unchanged. No mapping changed.
2. `## Caller Dispositions` (Output parsers) | citation completeness | Added the disposition for `check_jest_skipped_tests` in `scripts/dev_tools/atomic_executor/qc_runner_process.py`. It parses `FULL_TS_TEST` output only when called without test files, and its only caller, `cli_execute_one_task.py`, passes the changed test files. Unchanged; no task changes.
3. [P5-T1] no-overlap test | determinism clarification | The alternation assertion now names the filtered record (`acquire`, `release`, and launcher-step `run:` entries). Format, lint, and type-check `run:` entries from other branch threads can interleave in the shared record, so a contiguity check over the unfiltered record would depend on thread timing. The asserted property (no two launcher test steps overlap) is unchanged.
4. [P5-T1] unchanged-test disposition reason | disposition reason correction | The tests listed as unchanged also assert the failure messages `Jest failed` (`test_pipeline_stops_on_jest_failure`), `Pytest failed` (`test_fix_all.py`), and `PowerShell tests failed` (`test_fix_all_failure_paths.py`). The task replaces `run_simple_step` with a direct `branch_runner.run` call so that it can read the return code. The stated reason now records that each test step keeps its existing step log line and its success and failure messages. Without that, the unchanged disposition would not hold.
