# A1 edit of the Python contract test (P4-T9)

Timestamp: 2026-10-16T23-53
Command: git diff --numstat HEAD -- tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py
EXIT_CODE: 0
Output Summary: A1 applied exactly as section 7 states: the constant `RUN_HEAVY_GATE = "${{ inputs.run-heavy }}"` was added after `CODECOV_ACTION = "codecov/codecov-action"`, and the body of test_threshold_step_runs_on_every_matrix_leg was replaced. numstat prints one line `10	4` for the file, as required.

## Output

```
10	4	tests/scripts/dev_tools/test_quality_checks_workflow_contracts.py
```
