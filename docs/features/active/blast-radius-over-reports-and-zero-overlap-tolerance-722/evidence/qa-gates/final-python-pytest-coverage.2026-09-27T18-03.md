# Final Python Tests and Coverage (P15-T4)

Timestamp: 2026-09-27T18-03
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/coverage-722-final.json ; poetry run python SCRATCH/py-cov-files.py SCRATCH/coverage-722-final.json <the six block B38 files>
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: PASS. The CMD-PY-COV run printed "1 failed, 5272 passed, 5 skipped" and exited 1. The single FAILED node is the KL-510 node test_bundled_claude_payload_contains_all_repo_runtime_contracts, and its failure satisfies KL-510 case (b): the assertion message is "Repo file missing from bundle:" followed by a path under .claude\state\, and no output line contains "Bundle content differs from repo for:". The P0-T18 baseline failure set is empty, so no other failure exists. Terminal-table TOTAL: 91% (16109 statements, 1115 missed, 5842 branches, 574 partial). Every new test named in B10, B11, B13, B14, B16, B18, and B32 passed (67 names, 0 not passed). Script py-cov-files (A7) exited 0; every B38 file prints LinePercent >= 85 and BranchPercent >= 75 (lowest: _blast_radius_write_intent.py at 97.98 line and 95.24 branch).

KL-510: STATE-ONLY

## Counts

| Metric | Value |
| --- | --- |
| passed | 5272 |
| failed | 1 (KL-510 node, case (b)) |
| skipped | 5 (the same five baseline skips) |
| TOTAL line (terminal table) | 91% |

## TOTAL line and summary (verbatim)

```text
TOTAL                                                               16109   1115   5842    574    91%
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
============ 1 failed, 5272 passed, 5 skipped in 62.56s (0:01:02) =============
```

## KL-510 assessment

Assertion message (verbatim):

```text
E           AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-a7614a4e8c3c79cff-ef7479b3.json
```

- The message begins with the literal "Repo file missing from bundle:".
- The path's first two components are .claude and state (printed as .claude\state\ on Windows); the file is a gitignored batch-budget state file written by the hook during execution.
- A search of the complete output for "Bundle content differs from repo for:" returned no line.

Result: KL-510 case (b) (STATE-ONLY). The P0-T18 baseline failure set is empty; no other FAILED or ERROR line exists.

## Per-file coverage (script A7 output, exit 0)

```text
COVERAGE file=scripts/dev_tools/_blast_radius_scheduling.py LinePercent=100.00 BranchPercent=100.00
COVERAGE file=scripts/dev_tools/_parallel_drift_scheduling.py LinePercent=100.00 BranchPercent=100.00
COVERAGE file=scripts/dev_tools/_blast_radius_write_intent.py LinePercent=97.98 BranchPercent=95.24
COVERAGE file=scripts/dev_tools/compute_blast_radius.py LinePercent=100.00 BranchPercent=100.00
COVERAGE file=scripts/dev_tools/_blast_radius_validation.py LinePercent=100.00 BranchPercent=100.00
COVERAGE file=scripts/dev_tools/parallel_drift_detection.py LinePercent=100.00 BranchPercent=100.00
```

py-cov-files exit code: 0.

## Named new tests (B10, B11, B13, B14, B16, B18, B32)

The CMD-PY-COV run does not print per-node lines, so the seven new test modules were also run
verbosely to attribute a result to each named test:

Command: poetry run pytest -v tests/scripts/dev_tools/test_blast_radius_scheduling.py tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py tests/scripts/dev_tools/test_parallel_drift_scheduling.py tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py tests/scripts/dev_tools/test_blast_radius_historical_runs.py tests/scripts/dev_tools/test_blast_radius_write_intent.py
EXIT_CODE: 0 ("122 passed")

A scratch checker (SCRATCH/p15-named-check.py) matched each of the 67 named tests against the PASSED
lines of that run, counting parametrized cases: every name has at least one PASSED case and no
non-passing case (NAMED-SUMMARY Names=67 NotOk=0). Parametrized counts: reader rejections 14,
scheduling fixtures 5, each B11 property 3, each B16 [self-hosted]/[bundled] pair 2, each B18 test 3,
write-intent fixtures 8, write-intent reader rejections 4.

SCRATCH denotes the executor session scratchpad directory (outside the repository).
