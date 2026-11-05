# Isolation — CONTRACT_MODULES with pytest -n auto (P2-T4)

Timestamp: 2026-11-03T21-57
Command: sh SCRATCH/issue-1026-contracts.sh parallel "-n auto -v" (poetry run pytest --strict-markers --strict-config -q -n auto -v --junitxml=SCRATCH/issue-1026-pytest-parallel.xml over the ten CONTRACT_MODULES pytest files)
EXIT_CODE: 0
Output Summary: 175 passed, 0 failed, 0 errors (JUnit tests=175 failures=0 errors=0); pytest-xdist reported "created: 16/16 workers" and "16 workers [175 items]".

- Worker count: 16
- A preceding identical run with `-q` only (no `-v`) also passed 175 of 175 with exit 0; it did not print the worker count, so the run was repeated with `-v` to record it.
