# Python Coverage Artifact Agreement — Issue #614 Remediation

Timestamp: 2026-09-07T02-32
Cycle: 2026-09-06T23-30
Task: [P4-T5]
Command: read of `artifacts/python/lcov.info`, record whose `SF:` line ends with the file name `orchestration_handoff_adapters.py`
EXIT_CODE: 0

`artifacts/python/lcov.info` is written by the `--cov-report=lcov:artifacts/python/lcov.info`
entry of the project `addopts`, so it reflects the P4-T4 run.

## Record

Exactly one `SF:` record in the file ends with the file name
`orchestration_handoff_adapters.py`. Its value is written with the platform path separator:

```
SF:scripts\dev_tools\orchestration_handoff_adapters.py
LF:128
LH:128
```

Ascending list of zero-hit `DA:` line numbers:

```
(empty)
```

The list is empty and therefore contains none of 196, 198, 202, 210, or 215.

## Agreement with the terminal table

The P4-T4 terminal row for this module reads
`scripts\dev_tools\orchestration_handoff_adapters.py                   128      0     22      0   100%`.
Its 128 statements with 0 missed agree with `LF:128` and `LH:128` here, and its empty
`Missing` column agrees with the empty zero-hit list here.

Output Summary: The LCOV artifact and the terminal table agree. All 128 measured lines of
the adapters module are hit, so the five projection-guard rejection lines P0-T7 recorded as
uncovered are covered in both reports.
