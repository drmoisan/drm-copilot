# Regression: partial_also removes Protocol stub exit arcs ([P6-T2], AC-17 after-run)

Timestamp: 2026-10-09T21-28
Command: poetry run pytest "tests/scripts/dev_tools/test_new_potential_bug_entry.py" "--cov=scripts.dev_tools.new_potential_bug_entry" --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary: 25 passed in 0.14s. Module 111 statements, 9 missed, 30 branches, 3 partial, 91%. The Missing column contains none of `181->exit`, `183->exit`, `185->exit`, `187->exit`. Stmts (111) and Branch (30) are identical to the before-run, so no line left the denominator; BrPart fell from 7 to 3.

```
Name                                           Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\new_potential_bug_entry.py     111      9     30      3    91%   28, 82-89, 143->145, 147, 416-427
TOTAL                                            111      9     30      3    91%
============================= 25 passed in 0.14s ==============================
```

## Before and after (side by side)

| Run | Stmts | Miss | Branch | BrPart | Cover | Missing |
| --- | --- | --- | --- | --- | --- | --- |
| Before ([P0-T14], py-cov-bug-entry-before.2026-10-09T09-00.md) | 111 | 9 | 30 | 7 | 89% | 28, 82-89, 143->145, 147, 181->exit, 183->exit, 185->exit, 187->exit, 416-427 |
| After (this run) | 111 | 9 | 30 | 3 | 91% | 28, 82-89, 143->145, 147, 416-427 |

Acceptance (AC-17): exit 0; none of the four arcs remains; Stmts identical in both runs. PASS.
