# R1 Projection-Integrity Tests — Issue #614 Remediation

Timestamp: 2026-09-07T01-42
Cycle: 2026-09-06T23-30
Task: [P1-T1]
Command: `poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_adapters.py -v`; `(Get-Content -LiteralPath tests/scripts/dev_tools/test_orchestration_handoff_adapters.py).Count`
EXIT_CODE: 0

The `-v` form is used because the acceptance reads node identifiers, which the quiet form
does not print for passing tests.

## 1. Section 3.1 overflow rule

The rule did not apply. The file stands at 496 lines after the addition, against the hard
limit of 500, so `tests/scripts/dev_tools/test_orchestration_handoff_projection_integrity.py`
was not created and does not exist. No conditional path is added to any later task.

## 2. `PASSED` lines for the new parametrized test

```
tests/scripts/dev_tools/test_orchestration_handoff_adapters.py::test_projection_facts_diverging_from_the_envelope_are_rejected[plan] PASSED [  3%]
tests/scripts/dev_tools/test_orchestration_handoff_adapters.py::test_projection_facts_diverging_from_the_envelope_are_rejected[lifecycle] PASSED [  6%]
tests/scripts/dev_tools/test_orchestration_handoff_adapters.py::test_projection_facts_diverging_from_the_envelope_are_rejected[scheduler_context] PASSED [  9%]
tests/scripts/dev_tools/test_orchestration_handoff_adapters.py::test_projection_facts_diverging_from_the_envelope_are_rejected[envelope_sha256] PASSED [ 12%]
tests/scripts/dev_tools/test_orchestration_handoff_adapters.py::test_projection_facts_diverging_from_the_envelope_are_rejected[history_entry_sha256] PASSED [ 15%]
```

Five `PASSED` lines, each with a node identifier beginning
`tests/scripts/dev_tools/test_orchestration_handoff_adapters.py::test_projection_facts_diverging_from_the_envelope_are_rejected`.

## 3. Suite summary

```
============================= 33 passed in 0.13s ==============================
```

33 passed, 0 failed. The file held 28 tests before this change.

## 4. Line count

```
496
```

496 is at most 500.

Output Summary: The parametrized test covering the five `_validate_projection_facts`
rejection branches passes in all five parametrizations. The module suite exits 0 with 33
passed and 0 failed, and the file stands at 496 lines, inside the 500-line cap, so the
section 3.1 overflow rule does not apply.
