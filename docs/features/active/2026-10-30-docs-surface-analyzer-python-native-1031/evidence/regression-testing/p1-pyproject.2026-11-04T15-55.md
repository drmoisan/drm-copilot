# [P1-T1] pyproject.toml additive edits

Timestamp: 2026-11-04T15-55
Command: poetry run python -m pytest --strict-markers --strict-config -q -p no:cacheprovider tests/scripts/dev_tools/test_pyright_config_alignment.py tests/scripts/dev_tools/test_ruff_config_alignment.py tests/discovery_runtime/test_package_contract.py
EXIT_CODE: 0
Output Summary: 155 passed, 0 failed, 0 errors; none of the three modules edited.

Edits: [tool.pyright] include gains .claude/lib/docs/python and extraPaths = [".claude/lib/docs/python"] is added; [tool.pytest.ini_options] pythonpath = [".claude/lib/docs/python"] is added; [tool.coverage.run] source gains .claude/lib/docs/python. PYTESTS/conftest.py created (sys.dont_write_bytecode = True at import).

Command: git diff --numstat MERGE_BASE -- pyproject.toml
EXIT_CODE: 0
Output: 5 added, 2 deleted, pyproject.toml (the two changed lines are the include tail and the coverage source list).
