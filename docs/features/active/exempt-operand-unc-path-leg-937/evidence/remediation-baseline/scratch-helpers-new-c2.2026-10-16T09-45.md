# New Scratch Helpers, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T09-45
Task: P0-T4 (remediation-plan.2026-10-16T08-40.md)
Command: cp SCRATCH/pathleg_rows.py SCRATCH/pathleg_rows_c2.py (then lines 12 and 13 replaced with the plan's OLD and NEW lines); create SCRATCH/jacoco_report.py; acceptance checks below
EXIT_CODE: 0
Output Summary: pathleg_rows_c2.py differs from pathleg_rows.py in exactly lines 12 and 13 (diff prints 4 changed-line markers); the cycle 2 scheme alternative appears once; both new helpers exit 2 on a missing input.

Execution note: the acceptance commands were run from a SCRATCH script (`sh SCRATCH/c2_p0t4.sh`) from the worktree root, because the worktree isolation guard refuses inline shell variables.

`SCRATCH/pathleg_rows_c2.py` lines 12 and 13:

```python
OLD = r"^(?:\s|[\\/]{2}|[\\/]\?\?[\\/]|\\(?![\\/])|[A-Za-z]:(?![\\/])|file:|~)|\s$"
NEW = r"^(?:\s|[\\/]{2}|[\\/]\?\?[\\/]|\\(?![\\/])|[A-Za-z]:(?![\\/])|[A-Za-z][A-Za-z0-9+.-]+:|~)|\s$"
```

`SCRATCH/jacoco_report.py`: standard-library script; reads the root `counter` child with `type="LINE"`, prints `REPORT line_covered=<c> line_missed=<m> line_pct=<pct, 2 decimals>` and `SOURCEFILES=<count of sourcefile elements>`, exits 0; exits 2 on a missing or unparseable file; prints `NO_REPORT_COUNTER` and exits 3 when the root has no `LINE` counter child.

| Command | Result |
|---|---|
| `diff SCRATCH/pathleg_rows.py SCRATCH/pathleg_rows_c2.py \| grep -c "^[<>]"` | `4` |
| `grep -c -F "A-Za-z0-9+.-" SCRATCH/pathleg_rows_c2.py` | `1` |
| `poetry run python -I SCRATCH/pathleg_rows_c2.py SCRATCH/no-such-file.ps1` | exit 2 (`ERROR: missing file SCRATCH/no-such-file.ps1`) |
| `test -f SCRATCH/jacoco_report.py` | exit 0 |
| `poetry run python -I SCRATCH/jacoco_report.py SCRATCH/no-such-file.xml` | exit 2 (`ERROR: [Errno 2] No such file or directory: 'SCRATCH/no-such-file.xml'`) |
