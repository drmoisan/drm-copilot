# Python Regression, Parity, Back-Compat, and Legacy Suites After the Fix (P3-T7)

Timestamp: 2026-10-01T21-57
Task: P3-T7
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_remediation_accounting.py tests/scripts/dev_tools/test_orchestrator_state_remediation_loop_parity.py tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_backcompat.py tests/scripts/dev_tools/test_validate_orchestrator_state_remediation_loop.py
EXIT_CODE: 0

Output:

```
collected 262 items

tests\scripts\dev_tools\test_orchestrator_state_remediation_accounting.py . [  0%]
........................................................................ [ 27%]
.................................................                        [ 46%]
tests\scripts\dev_tools\test_orchestrator_state_remediation_loop_parity.py . [ 46%]
........................................................................ [ 74%]
............                                                             [ 79%]
tests\scripts\dev_tools\test_validate_orchestrator_state_remediation_backcompat.py . [ 79%]
............................................                             [ 96%]
tests\scripts\dev_tools\test_validate_orchestrator_state_remediation_loop.py . [ 96%]
.........                                                                [100%]

============================= 262 passed in 0.35s =============================
```

Output Summary: 262 passed, 0 failed. The Phase 2 Python suites that failed before the fix (P2-T4 collection error; P2-T5 30 failed corpus cases) now pass: accounting 122 cases, parity 85 cases (minimum count, discovered count, 41 name-equals-stem, 41 per-stem error equality, `test_corpus_covers_every_new_message`), back-compat 45, legacy remediation 10. This run executes after the `TYPE_CHECKING` import change recorded in `evidence/other/python-module-size.md`, so it also re-proves the P3-T5 legacy suites on the final module text.
