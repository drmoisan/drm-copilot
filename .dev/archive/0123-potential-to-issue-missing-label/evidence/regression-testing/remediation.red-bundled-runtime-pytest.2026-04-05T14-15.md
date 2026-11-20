Timestamp: 2026-04-05T14-15
Command: poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q -k "bundled_runtime_feature_missing_label or bundled_runtime_feature_existing_label" --cov=dev_tools.potential_to_issue --cov-report=term-missing
EXIT_CODE: 1
Output Summary: 1 failed, 1 passed, 4 deselected; Coverage Total: 65%; Coverage File: extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py = 65%
Failure: test_bundled_runtime_feature_missing_label_recovers_and_moves_file failed because the bundled runtime returned exit_code=1 after `could not add label: 'feature' not found`.

Captured Output:
F.                                                                       [100%]
================================== FAILURES ===================================
_____ test_bundled_runtime_feature_missing_label_recovers_and_moves_file ______

AssertionError: assert 1 == 0
Captured stdout:
Selected mode: full-feature
Creating issue: Feature: Missing Feature Label (label: feature)
could not add label: 'feature' not found

Coverage Summary:
Name                                                                       Stmts   Miss  Cover
extensions\drm-copilot\resources\scripts\dev_tools\potential_to_issue.py     184     64    65%
TOTAL                                                                        184     64    65%
