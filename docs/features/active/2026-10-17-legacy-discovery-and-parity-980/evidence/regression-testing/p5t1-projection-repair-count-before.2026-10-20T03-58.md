# p5t1-projection-repair-count-before

Timestamp: 2026-10-20T03-58
Command: poetry run python SCRATCH/count_before.py
EXIT_CODE: 1
Output Summary: scoped count-probe; duration 2.132 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
{"complete_calls": {"validate_coverage": 2, "validate_dimensions": 2, "validate_acceptance": 2}, "expected_after_repair": 1, "before_repair": 2}

Traceback (most recent call last):
  File "SCRATCH\count_before.py", line 22, in <module>
    assert set(counts.values()) == {1}, 'Existing duplicate complete-source assessments: expected each once.'
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: Existing duplicate complete-source assessments: expected each once.
```
