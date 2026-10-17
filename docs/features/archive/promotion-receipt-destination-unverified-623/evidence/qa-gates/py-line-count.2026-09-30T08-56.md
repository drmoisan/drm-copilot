# Python Module Line Count (AC-10) (#623)

Timestamp: 2026-09-30T08-56
Command: grep -c "" "scripts/dev_tools/potential_to_issue.py"; git diff --numstat 6e6ccd62792e0838bee7459a2b468de83ad5d408 -- "scripts/dev_tools/potential_to_issue.py"
EXIT_CODE: 0
Output Summary: BRANCH_LINES=559; ADDED=5; DELETED=85; BASE_LINES = 559 - 5 + 85 = 639, which equals PY_BASE_LINES (639) from P0-T8. ADDED <= DELETED and BRANCH_LINES <= BASE_LINES, so the module did not grow (it shrank by 80 physical lines).

- BRANCH_LINES: 559
- ADDED: 5
- DELETED: 85
- BASE_LINES: 639
- PY_BASE_LINES (P0-T8): 639

git diff --numstat output (verbatim):

```
5	85	scripts/dev_tools/potential_to_issue.py
```

The spec's PowerShell pair (`(Get-Content ...).Count` and `Measure-Object -Line`) is not executable in the executor toolset; decided under D4.
