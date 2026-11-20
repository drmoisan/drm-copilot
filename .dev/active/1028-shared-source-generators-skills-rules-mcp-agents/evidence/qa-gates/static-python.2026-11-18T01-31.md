# Final QC static — Python ([P7-T1])

Timestamp: 2026-11-18T01-31
Command: sh SCRATCH/issue-1028-final-static.sh (Python section), over the [P0-T2] scope `scripts/dev_tools/codex_native_converter` and `tests/scripts/dev_tools/codex_native_converter`
EXIT_CODE: 0
Output Summary: Black, Ruff and Pyright pass with zero findings. Black changed no file: the porcelain status was empty after the step. Every count equals its [P0-T2] baseline of 0.

| Step | Command | Exit code | Finding count | Baseline ([P0-T2]) |
| --- | --- | --- | --- | --- |
| Format | `env -u VIRTUAL_ENV poetry run black --check scripts/dev_tools/codex_native_converter tests/scripts/dev_tools/codex_native_converter` | 0 | 0 ("36 files would be left unchanged."); porcelain status unchanged (empty) | 0 |
| Lint | `env -u VIRTUAL_ENV poetry run ruff check scripts/dev_tools/codex_native_converter tests/scripts/dev_tools/codex_native_converter` | 0 | 0 ("All checks passed!") | 0 |
| Type check | `env -u VIRTUAL_ENV poetry run pyright scripts/dev_tools/codex_native_converter tests/scripts/dev_tools/codex_native_converter` | 0 | 0 ("0 errors, 0 warnings, 0 informations") | 0 |
