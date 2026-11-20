# [P2-T4] PKG/cli.py

Timestamp: 2026-11-04T16-02
Command: poetry run python -m pytest --strict-markers --strict-config -q -p no:cacheprovider tests/scripts/claude-lib/docs/python/test_docs_python_native_cli.py
EXIT_CODE: 0
Output Summary: 6 passed, 0 failed, 0 errors. Cases: root-name order (console script, literal, module, none); an attached root replaced by the console script with subcommands and options parented to {cli-command, tool, pyproject.toml} across files; unattached roots (unknown attribute, unknown module, target without a colon, empty module) keeping the literal name with name_source literal and in-file parents; a module-named root and a target module matching two request files (no attachment); a root with no name dropped with its children; recognizer diagnostics reported per path.
