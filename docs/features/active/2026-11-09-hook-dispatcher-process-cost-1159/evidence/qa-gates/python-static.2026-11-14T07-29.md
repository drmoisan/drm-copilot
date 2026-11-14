# Python final-QC static loop — main-sync cycle 1 ([P1-T8])

Timestamp: 2026-11-14T07-29
Command: sh SCRATCH/issue-1159-c1-pystatic.sh -- env -u VIRTUAL_ENV poetry run black --check, poetry run ruff check, and poetry run pyright over tests/scripts/dev_tools/test_discovery_publication_contracts.py, tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py and tests/scripts/dev_tools/test_codex_core_manifest_closure.py, run from the worktree root
EXIT_CODE: 0
Output Summary: Black: exit 0, "3 files would be left unchanged." Ruff: exit 0, "All checks passed!" Pyright: exit 0, "0 errors, 0 warnings, 0 informations". Pass 1 is clean, so no restart. This cycle changed no Python file.

| Step | Command | Exit code | Finding count |
|---|---|---|---|
| Format | poetry run black --check <3 files> | 0 | 0 (3 files unchanged) |
| Lint | poetry run ruff check <3 files> | 0 | 0 |
| Type check | poetry run pyright <3 files> | 0 | 0 errors, 0 warnings |
