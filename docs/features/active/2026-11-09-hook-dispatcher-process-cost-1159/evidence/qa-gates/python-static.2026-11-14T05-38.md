# Python final-QC static loop, pass 2 ([P7-T3], restart after the [P7-T4] run 1 fix)

Timestamp: 2026-11-14T05-38
Command: sh SCRATCH/issue-1159-pystatic.sh -- env -u VIRTUAL_ENV poetry run black --check; ruff check; pyright; over the three [P4-T4] files
EXIT_CODE: 0
Output Summary: Black "3 files would be left unchanged." (exit 0); Ruff "All checks passed!" (exit 0, 0 findings); Pyright "0 errors, 0 warnings, 0 informations".

| Step | Command | Exit code | Finding count |
|---|---|---|---|
| Format | poetry run black --check <3 files> | 0 | 0 |
| Lint | poetry run ruff check <3 files> | 0 | 0 |
| Type check | poetry run pyright <3 files> | 0 | 0 |
