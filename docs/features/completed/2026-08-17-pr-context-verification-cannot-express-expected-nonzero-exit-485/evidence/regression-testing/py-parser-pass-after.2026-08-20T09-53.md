# Pass-after — Python parser regression now passes

Timestamp: 2026-08-20T09-53

Task: [P2-T9]

Command: poetry run pytest tests/scripts/dev_tools/pr_context/test_verification_evidence.py
EXIT_CODE: 0

## Result

```
collected 1 item

tests\scripts\dev_tools\pr_context\test_verification_evidence.py .       [100%]

============================== 1 passed in 0.06s ==============================
```

- Passed: 1
- Failed: 0

The test `test_observed_equal_to_nonzero_expectation_passes`, which failed at [P1-T2] with
`AssertionError: assert 'fail' == 'pass'`, now passes. The same fixture — an artifact declaring an
observed code of `1` and an expectation of `1` — normalizes to `pass` and retains
`exit_code == 1`.

Fail-before evidence: `evidence/regression-testing/py-parser-fail-before.2026-08-20T09-53.md`
(EXIT_CODE 1). Pass-after evidence: this artifact (EXIT_CODE 0).

Output Summary: 1 passed, 0 failed; exit code 0. The Phase 1 Python parser regression is closed by
the Phase 2 fix. The paired fail-before run is recorded at
`evidence/regression-testing/py-parser-fail-before.2026-08-20T09-53.md`.
