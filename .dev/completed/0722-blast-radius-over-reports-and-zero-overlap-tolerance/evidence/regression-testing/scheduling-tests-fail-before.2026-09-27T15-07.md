# Scheduling Tests Fail Before the Module Exists (P1-T9, expect-fail)

Timestamp: 2026-09-27T15-07
Command: poetry run pytest -v tests/scripts/dev_tools/test_blast_radius_scheduling.py tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary: pytest exited 2 with "collected 0 items / 2 errors". Both collection errors are ModuleNotFoundError naming the missing module scripts.dev_tools._blast_radius_scheduling. This is the expected fail-before state: the production module is created by P1-T10.

## Printed output (tail)

```text
collecting ... collected 0 items / 2 errors

=================================== ERRORS ====================================
__ ERROR collecting tests/scripts/dev_tools/test_blast_radius_scheduling.py ___
tests\scripts\dev_tools\test_blast_radius_scheduling.py:27: in <module>
    from scripts.dev_tools._blast_radius_scheduling import (
E   ModuleNotFoundError: No module named 'scripts.dev_tools._blast_radius_scheduling'
_ ERROR collecting tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py _
tests\scripts\dev_tools\test_blast_radius_scheduling_properties.py:27: in <module>
    from scripts.dev_tools._blast_radius_scheduling import PairDecision, decide_pair
E   ModuleNotFoundError: No module named 'scripts.dev_tools._blast_radius_scheduling'
=========================== short test summary info ===========================
ERROR tests/scripts/dev_tools/test_blast_radius_scheduling.py
ERROR tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py
!!!!!!!!!!!!!!!!!!! Interrupted: 2 errors during collection !!!!!!!!!!!!!!!!!!!
============================== 2 errors in 0.17s ==============================
```

The absolute interpreter and worktree paths printed in the traceback header lines are omitted.
