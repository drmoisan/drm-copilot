Timestamp: 2026-09-30T09-59
Command: poetry run pytest "tests/scripts/dev_tools/test_potential_to_issue.py" "tests/scripts/dev_tools/test_potential_to_issue_branches.py" "tests/scripts/dev_tools/test_potential_to_issue_content.py" "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py" "tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py" "tests/scripts/dev_tools/test_potential_to_issue_move_verification.py" "--cov=scripts.dev_tools.potential_to_issue" "--cov=scripts.dev_tools.potential_to_issue_content" "--cov=scripts.dev_tools.potential_to_issue_filesystem" --cov-branch --cov-report=term-missing -q
EXIT_CODE: 0
Output Summary: 59 passed, 0 failed (N passed = BASELINE_COLLECTED_COUNT = 59).
Name | Stmts | Miss | Branch | BrPart | Cover | Missing
scripts\dev_tools\potential_to_issue.py | 178 | 1 | 54 | 5 | 97% | 82->exit, 84->exit, 86->exit, 88->exit, 417
scripts\dev_tools\potential_to_issue_content.py | 95 | 3 | 28 | 5 | 93% | 46->49, 111, 114, 172, 200->203
scripts\dev_tools\potential_to_issue_filesystem.py | 31 | 0 | 14 | 0 | 100% |
TOTAL | 304 | 4 | 96 | 10 | 96% |
Missing column of scripts\dev_tools\potential_to_issue.py row (full text): 82->exit, 84->exit, 86->exit, 88->exit, 417
Baseline family: Stmts 304, Miss 4, BrPart sum 10. Pre-#623 reference values superseded (deviation D3).
