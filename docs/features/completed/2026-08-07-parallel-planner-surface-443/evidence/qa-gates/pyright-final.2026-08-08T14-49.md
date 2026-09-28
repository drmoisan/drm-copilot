# Final QA Gate — Python Type Checking ([P10-T3])

Timestamp: 2026-08-08T14-49

Command: `poetry run pyright`

EXIT_CODE: 0

Output Summary: `0 errors, 0 warnings, 0 informations`. No file was modified by this stage, so no
loop restart was triggered.

## Coverage-of-Analysis Confirmation

The plain invocation does not print the analyzed-file count, so a confirming run was executed,
matching the method used for the Phase 0 baseline.

Command: `poetry run pyright --stats`

EXIT_CODE: 0

Output Summary:

```
Found 368 source files
0 errors, 0 warnings, 0 informations
Total files parsed and bound: 618
Total files checked: 368
```

Baseline comparison: the Phase 0 baseline
(`evidence/baseline/pyright-baseline.2026-08-08T13-53.md`) recorded 362 source files checked with
0 errors. The post-change count of 368 is +6, matching exactly the six Python files this feature
adds: `scripts/dev_tools/parallel_kickoff_contract.py`,
`scripts/dev_tools/_parallel_kickoff_tables.py`,
`tests/scripts/dev_tools/test_parallel_kickoff_contract.py`,
`tests/scripts/dev_tools/test_parallel_kickoff_contract_tables.py`,
`tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`, and
`tests/scripts/dev_tools/test_parallel_planner_surface_contracts_landed.py`. The error count is
unchanged at zero.

## Environment Notes (pre-existing, not remediated)

- Pyright emits `venv .venv subdirectory not found in venv path <worktree root>` because the
  Poetry virtual environment is not materialized as a `.venv` subdirectory inside this worktree.
  The message is informational; the run resolved imports (618 files parsed and bound), checked all
  368 source files, and exited 0. The identical message is recorded in the Phase 0 baseline.
- Pyright reports that a newer version (v1.1.411) is available; the pinned version 1.1.409 was
  used. Version pinning is out of scope for this plan.
