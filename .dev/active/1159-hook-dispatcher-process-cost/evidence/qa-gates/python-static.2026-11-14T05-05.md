# Python final-QC static loop ([P7-T3])

Timestamp: 2026-11-14T05-05
Command: sh SCRATCH/issue-1159-pystatic.sh -- env -u VIRTUAL_ENV poetry run black --check; poetry run ruff check; poetry run pyright; each over tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py, tests/scripts/dev_tools/test_codex_core_manifest_closure.py, tests/scripts/dev_tools/test_discovery_publication_contracts.py
EXIT_CODE: 0
Output Summary: Black "3 files would be left unchanged." (exit 0); Ruff "All checks passed!" (exit 0, 0 findings); Pyright "0 errors, 0 warnings, 0 informations" (0 findings). One pass; no restart.

| Step | Command | Exit code | Finding count |
|---|---|---|---|
| Format | poetry run black --check <3 files> | 0 | 0 (3 files unchanged) |
| Lint | poetry run ruff check <3 files> | 0 | 0 |
| Type check | poetry run pyright <3 files> | 0 | 0 errors, 0 warnings |
