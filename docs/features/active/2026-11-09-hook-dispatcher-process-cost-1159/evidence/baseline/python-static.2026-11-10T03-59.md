# Python static baseline ([P0-T4])

Timestamp: 2026-11-10T03-59
Command: env -u VIRTUAL_ENV poetry run black --check <files>; env -u VIRTUAL_ENV poetry run ruff check <files>; env -u VIRTUAL_ENV poetry run pyright <files>
EXIT_CODE: 0
Output Summary: Black check exit 0, "3 files would be left unchanged."; Ruff exit 0, "All checks passed!" (0 findings); Pyright exit 0, "0 errors, 0 warnings, 0 informations".

Files: `tests/scripts/dev_tools/test_discovery_publication_contracts.py`, `tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py`, `tests/scripts/dev_tools/test_codex_core_manifest_closure.py`.

| Step | Command | Exit code | Finding count |
|---|---|---|---|
| Format | `poetry run black --check <files>` | 0 | 0 (3 files would be left unchanged) |
| Lint | `poetry run ruff check <files>` | 0 | 0 |
| Type check | `poetry run pyright <files>` | 0 | 0 errors, 0 warnings |
