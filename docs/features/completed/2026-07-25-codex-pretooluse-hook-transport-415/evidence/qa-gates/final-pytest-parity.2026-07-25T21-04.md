# Final QA Gate — pytest Parity Contracts (Issue #415)

Timestamp: 2026-07-25T21-04

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py -q`
EXIT_CODE: 0

```
........                                                                 [100%]
8 passed in 0.21s
```

Output Summary: **Exit 0 for both modules. 8 passed, 0 failed.**

All eight parity contracts pass, including the three this feature directly affects:

- `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` — every repo-side `.codex` file, including the new `codex-pretooluse-file-mapping.ps1`, exists in the bundle. This also confirms no transient `.codex/state/` runtime file was left behind by the roughly 130 process spawns in the new Pester suites.
- `test_bundled_codex_files_are_listed_in_some_pack_manifest` — the new shared module is listed in `pack-manifests/core.json`, added by `[P2-T3](b)`.
- `test_no_bundled_codex_file_is_absent_from_disk_and_exception_list` — the `PRE_EXISTING_UNRELATED_HOOK_EXCEPTIONS` entry for the deleted `enforce-pr-author-skill.ps1` was removed by `[P1-T4]`, so no exception entry names a file that is absent from disk.

Scope justification (restated from `[P0-T6]`): the full `--cov --cov-branch` pytest suite is out of scope because no Python production file changed. The only Python edit in this feature is one removed line in a test module, and the Python gate for it is format, lint, type-check, plus these two targeted parity contracts.
