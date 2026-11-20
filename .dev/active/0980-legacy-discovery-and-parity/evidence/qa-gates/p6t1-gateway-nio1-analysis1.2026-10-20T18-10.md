Timestamp: 2026-10-20T18-10
Command: `.venv/Scripts/python.exe SCRATCH/issue-980-p6t1-gateway-nio1-proof.py`
EXIT_CODE: 1
Output Summary: nio1-analysis1; 0 retained test IDs; elapsed 0.176 seconds.

```text
Traceback (most recent call last):
  File "SCRATCH\issue-980-p6t1-gateway-nio1-proof.py", line 163, in <module>
    old_start, new_start = executable_start(prior), executable_start(now)
                           ~~~~~~~~~~~~~~~~^^^^^^^
  File "SCRATCH\issue-980-p6t1-gateway-nio1-proof.py", line 70, in executable_start
    return body[0].lineno
           ~~~~^^^
IndexError: list index out of range

```
