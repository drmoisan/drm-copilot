# Full Python Suite Baseline — [P0-T10]

Timestamp: 2026-08-28T12-46

Command: `poetry run pytest -q`

EXIT_CODE: 0

ExpectedExitCode: 0

## Verbatim Result Line

```
4195 passed, 5 skipped in 9.60s
```

## Recorded Counts

| Category | Count |
| --- | --- |
| passed | 4195 |
| failed | 0 |
| skipped | 5 |

## Failing Node IDs

None. The short test summary contains no `FAILED` row. The complete baseline failing set is the
empty set.

The five skips are recorded for completeness; all five are declared skips in one parametrized bash
parity module, not failures:

```
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_empty_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_missing_opening_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_non_mapping_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_unterminated_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_yaml_parse_failure declares no accessor expectation.
```

## Deviation from Verified Fact 12

The plan's verified fact 12 records that the full Python suite carried one failing node ID in the
push-down Claude resource-contract module, caused by a gitignored state file absent from the bundle
(repository issue #510). That failure is **not** present in this baseline run: the suite is fully
green at exit code 0 with a failed count of 0. The fact is recorded here as no longer reproducing in
this worktree rather than silently dropped, because the plan's downstream tasks are calibrated
against it.

Two consequences follow and are carried forward:

1. [P6-T4] is judged against a baseline failing set that is **empty**. Any failing node ID in the
   final run is therefore a new failing identifier and fails that task; the plan's allowance for a
   pre-existing failure is not exercised.
2. [P5-T8] is expected to take branch (a) of its acceptance — exit code 0 and `1 passed` — because
   the push-down payload contract test passes at baseline. Branch (b), the issue #510 exemption,
   remains available only if the failure reappears and names exactly the default PowerShell
   batch-budget state file under .claude/state.

Output Summary: `EXIT_CODE: 0` with `ExpectedExitCode: 0`. The full Python suite reports 4195 passed,
0 failed, and 5 skipped. The short test summary names no failing node ID, so the baseline failing set
is empty and [P6-T4] is judged against zero failures. The five skips are declared skips in the
parallel-manifest bash parity module, each reporting that a fixture declares no accessor expectation.
