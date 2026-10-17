Timestamp: 2026-10-08T02-49
Command: poetry run pytest tests/scripts/dev_tools/test_new_potential_bug_entry.py tests/scripts/dev_tools/test_new_active_feature_folder.py tests/scripts/dev_tools/test_new_active_feature_folder_part2.py tests/scripts/dev_tools/test_new_active_feature_folder_part3.py tests/scripts/dev_tools/test_new_active_feature_folder_part4.py tests/scripts/dev_tools/test_new_active_feature_folder_part5.py tests/scripts/dev_tools/test_new_active_feature_folder_bug_template_preserved.py tests/scripts/dev_tools/test_new_active_feature_folder_markdown_escape.py tests/scripts/dev_tools/test_new_active_feature_folder_models_coverage.py tests/scripts/dev_tools/test_new_active_feature_folder_launcher.py --cov=scripts.dev_tools.new_potential_bug_entry --cov=scripts.dev_tools.new_active_feature_folder_io --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/launcher-coverage.json
(paths and --cov arguments were double-quoted at invocation to satisfy the promotion-name hook; argument values are unchanged)
EXIT_CODE: 0
Output Summary: 109 passed in 0.97s (baseline at P0-T10 was 89; 89 + 20 = 109).
Coverage rows (Stmts Miss Branch BrPart Cover Missing):
scripts\dev_tools\new_active_feature_folder_io.py  110  3  50  4  94%  101->exit, 103->101, 112->110, 129-131
scripts\dev_tools\new_potential_bug_entry.py       111  9  30  7  89%  28, 82-89, 143->145, 147, 181->exit, 183->exit, 185->exit, 187->exit, 416-427
TOTAL                                              221 12  80 11  92%
(The term-missing Cover column is the combined line+branch figure; separate values are in python-coverage-values.)
