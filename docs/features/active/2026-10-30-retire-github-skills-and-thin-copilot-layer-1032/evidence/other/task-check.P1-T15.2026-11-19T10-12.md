# Task Check P1-T15

Timestamp: 2026-11-19T10-12
Plan: plan.2026-10-30T18-39.md
Changed files: `README.md` (new `### Copilot collision controls` under `## Requirements`, user-scope case). `.vscode/settings.json` and `tests/scripts/dev_tools/test_vscode_workspace_settings.py` unchanged (WorkspaceScope: no).
Selection rule: `test_vscode_workspace_settings.py` (reads `.vscode/settings.json`); no contract test reads the new README section.

| Command | EXIT_CODE | Result |
| --- | --- | --- |
| `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_vscode_workspace_settings.py -q -p no:cacheprovider` | 0 | 2 passed (`test_workspace_settings_pin_vscode_to_powershell_7`, `test_workspace_settings_contain_no_host_specific_paths`) |
| Fixed-string searches of `README.md` (recorded in `collision-controls.2026-11-19T10-12.md`) | 0 | 1 match per key |
