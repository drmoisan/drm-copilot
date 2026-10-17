# Regression: potential_to_issue targeted coverage after the docstring and comment edits ([P6-T10])

Timestamp: 2026-10-09T21-31
Command: poetry run pytest "tests/scripts/dev_tools/test_potential_to_issue.py" "tests/scripts/dev_tools/test_potential_to_issue_branches.py" "tests/scripts/dev_tools/test_potential_to_issue_bug_bodies.py" "tests/scripts/dev_tools/test_potential_to_issue_cli_and_adapters.py" "tests/scripts/dev_tools/test_potential_to_issue_content.py" "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py" "tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py" "tests/scripts/dev_tools/test_potential_to_issue_move_verification.py" "tests/scripts/dev_tools/test_potential_to_issue_work_modes.py" "--cov=scripts.dev_tools.potential_to_issue" --cov-branch --cov-report=term-missing "--cov-report=json:artifacts/python/cov-targeted.json"
EXIT_CODE: 0
Output Summary: 59 passed in 0.81s (baseline [P0-T13]: 59 passed). Module 136 statements, 1 missed, 38 branches, 1 partial, 99%. Missing: 298 (baseline: 296). The missed line is the same statement, `_emit(f"Fallback reason: {fallback_reason}")`; its number moved by +2 because [P6-T7] added two docstring lines above it (confirmed by reading line 298 on the working tree and line 296 at the merge-base 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a).

```
Name                                      Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\potential_to_issue.py     136      1     38      1    99%   298
TOTAL                                       136      1     38      1    99%
============================= 59 passed in 0.81s ==============================
```

## Block 2 (COVJSON)

Command: poetry run python -c "import json,sys;d=json.load(open(sys.argv[1]));[print(k,'line',round(100*s['covered_lines']/s['num_statements'],2),'branch',round(100*s['covered_branches']/s['num_branches'],2) if s['num_branches'] else 'n/a') for k,v in d['files'].items() for s in [v['summary']]]" artifacts/python/cov-targeted.json
EXIT_CODE: 0
Output Summary: line 99.26, branch 97.37; equal to the [P0-T13] values (99.26 / 97.37).

```
scripts\dev_tools\potential_to_issue.py line 99.26 branch 97.37
```

Acceptance: exit 0; pass count 59 equals baseline; line 99.26 >= 85 and branch 97.37 >= 75; both values equal the baseline. PASS.
