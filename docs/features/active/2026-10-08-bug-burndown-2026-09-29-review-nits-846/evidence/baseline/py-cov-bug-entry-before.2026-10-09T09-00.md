# Baseline: new_potential_bug_entry coverage, AC-17 before-run ([P0-T14])

Timestamp: 2026-10-09T20-59
Command: poetry run pytest "tests/scripts/dev_tools/test_new_potential_bug_entry.py" "--cov=scripts.dev_tools.new_potential_bug_entry" --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary: 25 passed in 0.16s. Module 111 statements, 9 missed, 30 branches, 7 partial, 89%. Missing column contains all four one-line Protocol stub arcs `181->exit`, `183->exit`, `185->exit`, `187->exit`, so AC-17 has its before-state.

## Term-missing row (verbatim)

```
Name                                           Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------
scripts\dev_tools\new_potential_bug_entry.py     111      9     30      7    89%   28, 82-89, 143->145, 147, 181->exit, 183->exit, 185->exit, 187->exit, 416-427
------------------------------------------------------------------------------------------
TOTAL                                            111      9     30      7    89%
```

Missing (verbatim): 28, 82-89, 143->145, 147, 181->exit, 183->exit, 185->exit, 187->exit, 416-427
