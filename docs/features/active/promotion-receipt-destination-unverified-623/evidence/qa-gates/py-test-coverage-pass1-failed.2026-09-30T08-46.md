# Python Test and Coverage Gate, Pass 1 (FAILED criterion) (#623)

Timestamp: 2026-09-30T08-46
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json; then NODE-PYCOV with no trailing arguments
EXIT_CODE: 0
Output Summary: pytest case (a) (`5707 passed, 6 skipped`; KL-510: PASSED), but the NODE-PYCOV criterion for scripts/dev_tools/potential_to_issue_filesystem.py is not met: branches=7/14 (50.00%) < 75. Per P8-T5, this is a failure; the cause is fixed and Phase 8 restarts from P8-T1.

## Rows (verbatim)

```
scripts\dev_tools\potential_to_issue.py                                 178      1     54      5    97%   82->exit, 84->exit, 86->exit, 88->exit, 417
scripts\dev_tools\potential_to_issue_filesystem.py                       31      0     14      7    84%   42->exit, 44->exit, 46->exit, 48->exit, 50->exit, 52->exit, 54->exit
TOTAL                                                                 16946   1117   6108    584    92%
================= 5707 passed, 6 skipped in 81.51s (0:01:21) ==================
```

## NODE-PYCOV (verbatim)

```
scripts/dev_tools/potential_to_issue.py lines=177/178 branches=49/54
scripts/dev_tools/potential_to_issue_filesystem.py lines=31/31 branches=7/14
TOTAL lines=15829/16946 branches=5272/6108
```

## Cause

The seven missing arcs are the one-line `FileSystem` Protocol member stubs (`def name(...) -> T: ...`, lines 42-54). coverage.py records two exits for each one-line stub: one to the next line when the class body is executed, and one to function exit when the stub body runs. No code calls the stub bodies, so the `->exit` arcs are never taken. The same arcs were uncovered in the original module (baseline term-missing `216->exit` through `228->exit`) and were diluted by that module's other branches; after the P4 extraction they make up half of the new module's 14 branch arcs.

## Fix applied (remediation within P8-T5 "fix and restart Phase 8")

- Black collapses `...` bodies onto the def line, so moving the body to its own line (which the `exclude_lines` pattern `^\s*\.\.\.\s*$` would exclude) does not persist.
- `pyproject.toml` coverage configuration is outside the plan's blast radius.
- Fix: one test, `test_file_system_protocol_members_declare_no_behavior`, added to blast-radius row 9 (`tests/scripts/dev_tools/test_potential_to_issue_filesystem.py`). It calls each protocol member through the protocol class and asserts that each returns None. The file then holds eight tests instead of the seven P5-T3 specified; this deviation is reported in the final execution report.
