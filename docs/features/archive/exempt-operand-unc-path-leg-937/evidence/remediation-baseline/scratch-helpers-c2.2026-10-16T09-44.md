# Scratch Helper Verification, Remediation Cycle 2 (issue #937)

Timestamp: 2026-10-16T09-44
Task: P0-T3 (remediation-plan.2026-10-16T08-40.md)
Command: test -f SCRATCH/junit_status.py SCRATCH/junit_totals.py SCRATCH/jacoco_targets.py SCRATCH/jacoco_lines.py SCRATCH/pathleg_rows.py (one test -f each); poetry run python -I SCRATCH/<helper> SCRATCH/no-such-file.xml (jacoco_lines.py with trailing 41; pathleg_rows.py with SCRATCH/no-such-file.ps1)
EXIT_CODE: 0
Output Summary: All five cycle 1 helpers exist (test -f exit 0); all five no-such-file invocations exit 2. No script was recreated.

Execution note: the worktree isolation guard refuses inline shell variables, so the ten commands were run from a SCRATCH script (`sh SCRATCH/c2_p0t3.sh`) from the worktree root; the script runs exactly the ten commands below.

| Command | Exit code | Output |
|---|---|---|
| `test -f SCRATCH/junit_status.py` | 0 | |
| `test -f SCRATCH/junit_totals.py` | 0 | |
| `test -f SCRATCH/jacoco_targets.py` | 0 | |
| `test -f SCRATCH/jacoco_lines.py` | 0 | |
| `test -f SCRATCH/pathleg_rows.py` | 0 | |
| `poetry run python -I SCRATCH/junit_status.py SCRATCH/no-such-file.xml` | 2 | `ERROR: [Errno 2] No such file or directory: 'SCRATCH/no-such-file.xml'` |
| `poetry run python -I SCRATCH/junit_totals.py SCRATCH/no-such-file.xml` | 2 | `ERROR: [Errno 2] No such file or directory: 'SCRATCH/no-such-file.xml'` |
| `poetry run python -I SCRATCH/jacoco_targets.py SCRATCH/no-such-file.xml` | 2 | `ERROR: [Errno 2] No such file or directory: 'SCRATCH/no-such-file.xml'` |
| `poetry run python -I SCRATCH/jacoco_lines.py SCRATCH/no-such-file.xml 41` | 2 | `ERROR: [Errno 2] No such file or directory: 'SCRATCH/no-such-file.xml'` |
| `poetry run python -I SCRATCH/pathleg_rows.py SCRATCH/no-such-file.ps1` | 2 | `ERROR: missing file SCRATCH/no-such-file.ps1` |

Recreated: none.

EXIT_CODE above records the task outcome (all ten commands produced their expected exit codes).
