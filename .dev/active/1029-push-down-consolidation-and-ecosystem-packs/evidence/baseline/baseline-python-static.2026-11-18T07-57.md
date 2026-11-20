# Baseline: Python Static Checks (one in-scope test file)

Timestamp: 2026-11-18T07-57
Command: env -u VIRTUAL_ENV poetry run black --check tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py; env -u VIRTUAL_ENV poetry run ruff check <same file>; env -u VIRTUAL_ENV poetry run pyright <same file>
EXIT_CODE: 0
Output Summary: Black exit 0, "1 file would be left unchanged." (finding count 0). Ruff exit 0, "All checks passed!" (finding count 0). Pyright exit 0, "0 errors, 0 warnings, 0 informations" (finding count 0).
