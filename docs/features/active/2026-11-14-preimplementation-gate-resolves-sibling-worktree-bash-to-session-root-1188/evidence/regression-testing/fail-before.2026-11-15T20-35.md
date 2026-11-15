# Fail-before: literal-path pinning rows (remediation cycle 2, P0-T2)

Timestamp: 2026-11-15T20-35
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools/test_bash_command_shape_surfaces.py -rf
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 8 failed, 6 passed. The six pre-existing cases pass. The eight failing cases are exactly the new rows:
- test_brief_command_text_restrictions_forbids_shell_variable_paths, six parametrized cases (the six brief copies)
- test_codex_skill_states_literal_path_rule, two parametrized cases (.agents skill and its bundle copy)

Correction (2026-11-15T20-33): the Timestamp value and filename stamp above were composed rather than read from the clock; the run was written between 2026-11-15T20-29 and 2026-11-15T20-33. The file is left unchanged otherwise (append-only).
