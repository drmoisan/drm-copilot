Timestamp: 2026-10-08T02-41
Command: poetry run pytest tests/scripts/dev_tools/test_new_potential_bug_entry.py tests/scripts/dev_tools/test_new_active_feature_folder.py tests/scripts/dev_tools/test_new_active_feature_folder_part2.py tests/scripts/dev_tools/test_new_active_feature_folder_part3.py tests/scripts/dev_tools/test_new_active_feature_folder_part4.py tests/scripts/dev_tools/test_new_active_feature_folder_part5.py tests/scripts/dev_tools/test_new_active_feature_folder_bug_template_preserved.py tests/scripts/dev_tools/test_new_active_feature_folder_markdown_escape.py tests/scripts/dev_tools/test_new_active_feature_folder_models_coverage.py --cov=scripts.dev_tools.new_potential_bug_entry --cov=scripts.dev_tools.new_active_feature_folder_io --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/launcher-coverage.json (test paths and --cov arguments double-quoted when run, per hook constraint)
EXIT_CODE: 0
Output Summary: 89 passed in 0.90s. BASELINE PYTHON PASS COUNT N = 89.
Coverage rows (combined line+branch Cover column):
- scripts\dev_tools\new_active_feature_folder_io.py: Stmts 110, Miss 3, Branch 50, BrPart 4, Cover 94%, Missing: 101->exit, 103->101, 112->110, 129-131
- scripts\dev_tools\new_potential_bug_entry.py: Stmts 111, Miss 9, Branch 30, BrPart 7, Cover 89%, Missing: 28, 82-89, 143->145, 147, 181->exit, 183->exit, 185->exit, 187->exit, 416-427
- TOTAL: Cover 92%
