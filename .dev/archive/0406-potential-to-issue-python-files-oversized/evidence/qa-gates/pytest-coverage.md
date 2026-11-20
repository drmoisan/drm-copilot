Timestamp: 2026-09-30T10-22
Command: poetry run pytest "tests/scripts/dev_tools/test_potential_to_issue.py" "tests/scripts/dev_tools/test_potential_to_issue_bug_bodies.py" "tests/scripts/dev_tools/test_potential_to_issue_work_modes.py" "tests/scripts/dev_tools/test_potential_to_issue_cli_and_adapters.py" "tests/scripts/dev_tools/test_potential_to_issue_branches.py" "tests/scripts/dev_tools/test_potential_to_issue_content.py" "tests/scripts/dev_tools/test_potential_to_issue_filesystem.py" "tests/scripts/dev_tools/test_potential_to_issue_missing_label_regression.py" "tests/scripts/dev_tools/test_potential_to_issue_move_verification.py" "--cov=scripts.dev_tools.potential_to_issue" "--cov=scripts.dev_tools.potential_to_issue_adapters" "--cov=scripts.dev_tools.potential_to_issue_content" "--cov=scripts.dev_tools.potential_to_issue_filesystem" --cov-branch --cov-report=term-missing -q
EXIT_CODE: 0
Output Summary: 59 passed, 0 failed (N passed = BASELINE_COLLECTED_COUNT = 59).
Name | Stmts | Miss | Branch | BrPart | Cover | Missing
scripts\dev_tools\potential_to_issue.py | 136 | 1 | 38 | 1 | 99% | 296
scripts\dev_tools\potential_to_issue_adapters.py | 48 | 0 | 16 | 4 | 94% | 44->exit, 46->exit, 48->exit, 50->exit
scripts\dev_tools\potential_to_issue_content.py | 95 | 3 | 28 | 5 | 93% | 46->49, 111, 114, 172, 200->203
scripts\dev_tools\potential_to_issue_filesystem.py | 31 | 0 | 14 | 0 | 100% |
TOTAL | 310 | 4 | 96 | 10 | 97% |
Missing column, scripts\dev_tools\potential_to_issue.py row: 296
Missing column, scripts\dev_tools\potential_to_issue_adapters.py row: 44->exit, 46->exit, 48->exit, 50->exit
(The single missed line 296 corresponds to baseline line 417, shifted by the 121 lines removed above it. The four adapters partial branches are the GhClient Protocol member stubs, formerly 82->exit through 88->exit in the baseline.)
