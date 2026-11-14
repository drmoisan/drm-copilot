# Final QC: pytest Suite (remediation cycle 1, P3-T3)

Timestamp: 2026-11-14T15-28
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1158-r1-final-py.json (through SCRATCH/issue-1158-final-py.sh); totals read from the JSON report (SCRATCH/issue-1158-covjson.ps1)
EXIT_CODE: 0
Output Summary: the launcher exited 0 with no queue timeout and no refusal. 24 xdist workers over 16933 items: "16927 passed, 6 skipped in 205.50s", 0 failed, 0 errors. Repo-wide coverage over the configured source (src, scripts/dev_tools, packages/discovery-runtime/src, .claude/lib/docs/python): line 97.74% (34997/35807), branch 95.13% (12977/13642). The seven Python modules the item changed total 98.83% line (846/856) and 96.41% branch (295/306); each is at or above 85% line and 75% branch. tests/scripts/dev_tools/ (the push-down, pack-manifest completeness and closure, brief, and bundle-parity contracts) ran inside this session.

## Coverage of the Seven Changed Modules (JSON report)

| Module | Line | Branch | Missed lines |
|---|---|---|---|
| scripts/dev_tools/fix_all_runtime.py | 98.80% | 95.45% | 101 (unchanged line) |
| scripts/dev_tools/fix_all_branches.py | 100.00% | 100.00% | none |
| scripts/dev_tools/fix_all_branches_extra.py | 100.00% | 100.00% | none |
| scripts/dev_tools/atomic_executor/qc_runner.py | 93.58% | 81.82% | 157, 200, 305, 306, 493, 525, 580 (unchanged lines) |
| scripts/dev_tools/atomic_executor/qc_runner_expectations.py | 100.00% | 97.14% | none |
| scripts/dev_tools/atomic_executor/cli_preflight.py | 100.00% | 98.78% | none |
| scripts/dev_tools/atomic_executor/cli_task_runtime.py | 98.84% | 94.23% | 211, 212 (unchanged lines) |
| Total (seven modules) | 98.83% | 96.41% | |

This cycle changes no Python file.
