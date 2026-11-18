# Final QC static — Python ([P7-T1], re-run after the [P7-T5] fix)

Timestamp: 2026-11-18T02-20
Command: sh SCRATCH/issue-1028-final-static.sh (Python section, over the [P0-T2] scope `scripts/dev_tools/codex_native_converter` and `tests/scripts/dev_tools/codex_native_converter`); PYTHONUTF8=1 env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.format_json --check scripts/harness-generation; PYTHONUTF8=1 env -u VIRTUAL_ENV poetry run python -m scripts.dev_tools.validate_json scripts/harness-generation
EXIT_CODE: 0
Output Summary: Black, Ruff and Pyright pass with zero findings, Black changed no file, and every count equals its [P0-T2] baseline of 0. The repository JSON tools now pass over the generator sources: `format_json --check` reports 0 files that would be reformatted, and `validate_json` exits 0 with no message, so every source is valid against its schema. `PYTHONUTF8=1` is set because, without it, `validate_json` fails to decode UTF-8 files under the Windows code page.

| Step | Command | Exit code | Finding count | Baseline ([P0-T2]) |
| --- | --- | --- | --- | --- |
| Format | `env -u VIRTUAL_ENV poetry run black --check scripts/dev_tools/codex_native_converter tests/scripts/dev_tools/codex_native_converter` | 0 | 0 ("36 files would be left unchanged."); porcelain status unchanged (empty) | 0 |
| Lint | `env -u VIRTUAL_ENV poetry run ruff check scripts/dev_tools/codex_native_converter tests/scripts/dev_tools/codex_native_converter` | 0 | 0 ("All checks passed!") | 0 |
| Type check | `env -u VIRTUAL_ENV poetry run pyright scripts/dev_tools/codex_native_converter tests/scripts/dev_tools/codex_native_converter` | 0 | 0 ("0 errors, 0 warnings, 0 informations") | 0 |
| JSON format (generator sources) | `format_json --check scripts/harness-generation` | 0 | 0 would reformat | not recorded at [P0-T2] (the files are new) |
| JSON schema (generator sources) | `validate_json scripts/harness-generation` | 0 | 0 invalid or missing `$schema` | not recorded at [P0-T2] (the files are new) |
