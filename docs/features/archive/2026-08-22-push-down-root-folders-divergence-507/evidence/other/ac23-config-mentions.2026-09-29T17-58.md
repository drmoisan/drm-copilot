# AC23 Config Mentions (P7-T5, supplementary)

Timestamp: 2026-09-29T17-58
Command: git grep -n -F "config/" -- README.md scripts/dev_tools/push_down_claude_customizations.py
EXIT_CODE: 0

Output Summary:
- Exit code 0.
- README.md:251: `| Claude Code (`.claude`, `config/`, `CLAUDE.md`) | bundled publisher | ...`
- scripts/dev_tools/push_down_claude_customizations.py:1: module docstring first line "Publish bundled `.claude` and `config/` content into a destination workspace."
- scripts/dev_tools/push_down_claude_customizations.py:223, 225, 226, 289: docstring paragraph and wiring comment describing bundle-sourced `config/`.
- Gating evidence for AC23 is the two tests in tests/scripts/dev_tools/test_push_down_claude_config_carriage.py: `test_module_docstring_and_cli_help_name_config_payload` and `test_readme_claude_row_lists_config_payload` (both passed; see evidence/regression-testing/ac17-push-down-claude-suite.2026-09-29T17-54.md).
