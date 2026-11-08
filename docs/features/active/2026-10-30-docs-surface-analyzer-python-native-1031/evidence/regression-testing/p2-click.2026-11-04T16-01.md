# [P2-T2] PKG/cli_click.py

Timestamp: 2026-11-04T16-01
Command: poetry run python -m pytest --strict-markers --strict-config -q -p no:cacheprovider tests/scripts/claude-lib/docs/python/test_docs_python_native_cli_click.py
EXIT_CODE: 0
Output Summary: 12 passed, 0 failed, 0 errors. Cases: the 1022 default-name and suffix rule; command and group roots with literal name= (bare and called decorators, aliased imports including from click import command and option as opt); tracked group commands and groups with the group closure; add_command with and without name=; option split at '/', argument, required= and help=; CLI_CUSTOM_CLASS (cls= and a constructed CommandCollection), CLI_DECORATOR_INDIRECT (bound decorator name, decorator applied by call), CLI_UNBOUND_REGISTRATION (parameter and unknown receiver), CLI_REGISTRATION_IN_LOOP (loop add_command, looped def) and CLI_DYNAMIC_REGISTRATION (name, starred, option strings, add_command name=).
