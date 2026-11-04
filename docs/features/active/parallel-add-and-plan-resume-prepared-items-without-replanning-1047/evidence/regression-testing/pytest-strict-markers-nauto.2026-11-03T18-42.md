# Pytest strict-markers and -n auto check after the main merge (issue 1047)

Timestamp: 2026-11-03T18-42
Command: poetry run pytest -n auto -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary: 16063 passed, 6 skipped in 186.80s. The project addopts carry --strict-markers and --strict-config, so an unregistered marker would fail collection; zero PytestUnknownMarkWarning lines. Run on the branch head a86154da3 in the item worktree, CI shape (Linux, xdist workers).

## Serial and reversed-order runs of the affected contract modules

The only Python file in the branch diff is tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py (a test helper), consumed by test_parallel_orchestrator_surface_contracts.py. The mirror and manifest contract modules pin the new bundled PowerShell files.

- Serial: poetry run pytest -q -p no:cacheprovider tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -> EXIT_CODE 0, 72 passed.
- Reversed file order (same four modules, last to first) -> EXIT_CODE 0, 72 passed.

The branch adds no new pytest markers; no marker registration is required.
