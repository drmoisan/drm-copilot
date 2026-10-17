# Dependabot contract red run (P1-T4, expect-fail)

Timestamp: 2026-10-16T00-18
Command: poetry run pytest tests/scripts/dev_tools/test_dependabot_config_contract.py --no-cov -p no:cacheprovider
ExpectedExitCode: 1
EXIT_CODE: 1
Output Summary: Final line `2 failed, 3 passed in 0.31s` against the unmodified `.github/dependabot.yml`. Failed node IDs are exactly:
- test_npm_entry_ignores_types_vscode_for_all_update_types[root]
- test_npm_entry_ignores_types_vscode_for_all_update_types[extension]
Failure messages: `npm entry for directory / lacks an ignore item for @types/vscode` and `npm entry for directory /extensions/drm-copilot lacks an ignore item for @types/vscode`, which shows the failure is the missing ignore item and not an import or collection error.
Note: `--no-cov -p no:cacheprovider` were added to the plan command so the run writes no coverage or cache files.
