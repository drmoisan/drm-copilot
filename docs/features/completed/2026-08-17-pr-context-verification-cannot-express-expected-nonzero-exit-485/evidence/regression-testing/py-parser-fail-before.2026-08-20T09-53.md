# Fail-before — Python parser regression, declared non-zero expectation ignored

Timestamp: 2026-08-20T09-53

Task: [P1-T2] [expect-fail]

Command: poetry run pytest tests/scripts/dev_tools/pr_context/test_verification_evidence.py
EXIT_CODE: 1

## Expected outcome for this task

This task is tagged `[expect-fail]`. A FAILING run is the required outcome: it demonstrates the
defect before the fix. The exit code `1` is the failure signal from pytest, not a tooling problem.
The fixture uses only symbols that exist today
(`parse_verification_evidence_markdown`, `record.normalized_result`, `record.exit_code`), so the
failure is a behavior failure at an assertion rather than a collection or import error.

## Assertion diff quoted from the run

```
        # Assert
>       assert record.normalized_result == "pass"
E       AssertionError: assert 'fail' == 'pass'
E
E         - pass
E         + fail

tests\scripts\dev_tools\pr_context\test_verification_evidence.py:36: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/pr_context/test_verification_evidence.py::test_observed_equal_to_nonzero_expectation_passes
============================== 1 failed in 0.10s ==============================
```

The evidence markdown declared `EXIT_CODE: 1` together with an expectation line whose value was also
`1`. The parser discarded the expectation line (it is not on the accept-list at
`scripts/dev_tools/pr_context/verification_evidence.py:22,107`) and normalized against the literal
`0` at `verification_evidence.py:136`, producing `fail` where `pass` was expected.

Output Summary: 1 failed, 0 passed; exit code 1, which is the expected outcome for this
`[expect-fail]` task. The assertion diff shows `'fail' == 'pass'` failing — the observed code `1`
equalled the declared expectation `1`, yet the record normalized to `fail`. This is the defect of
issue #485 reproduced as a unit-level failure. The pass-after run is recorded at [P2-T9].
