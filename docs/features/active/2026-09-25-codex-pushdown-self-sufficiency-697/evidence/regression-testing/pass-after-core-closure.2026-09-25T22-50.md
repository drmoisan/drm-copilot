# Pass-After: core.json Closure (Issue #697, AC-5.1 to AC-5.5)

Timestamp: 2026-09-25T22-50
Command: poetry run pytest tests/scripts/dev_tools/test_codex_core_manifest_closure.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py "tests/scripts/dev_tools/test_generate_codex_agent_variants.py::test_generator_check_mode_reports_no_drift" -q
EXIT_CODE: 0
Output Summary: `8 passed` (five closure tests, two completeness tests including `test_bundled_codex_files_are_listed_in_some_pack_manifest` and `test_no_bundled_codex_file_is_absent_from_disk_and_exception_list`, and the generator no-drift node), 0 failed. `core.json` now lists 114 paths.
