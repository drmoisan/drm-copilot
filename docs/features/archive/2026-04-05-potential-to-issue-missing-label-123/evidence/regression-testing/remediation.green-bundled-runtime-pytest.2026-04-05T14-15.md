Timestamp: 2026-04-05T14-15
Command: poetry run pytest tests/extensions/drm_copilot/resources/templates/test_potential_to_issue.py -q -k "bundled_runtime_feature_missing_label or bundled_runtime_feature_existing_label" --cov=dev_tools.potential_to_issue --cov-report=term-missing
EXIT_CODE: 0
Output Summary: 2 passed, 4 deselected; Coverage Total: 65%; Coverage File: extensions/drm-copilot/resources/scripts/dev_tools/potential_to_issue.py = 65%
Verified Tests:
- test_bundled_runtime_feature_missing_label_recovers_and_moves_file
- test_bundled_runtime_feature_existing_label_uses_single_issue_create_attempt

Captured Output:
..                                                                       [100%]
=============================== tests coverage ================================
Name                                                                       Stmts   Miss  Cover
extensions\drm-copilot\resources\scripts\dev_tools\potential_to_issue.py     200     70    65%
TOTAL                                                                        200     70    65%
2 passed, 4 deselected in 0.06s
