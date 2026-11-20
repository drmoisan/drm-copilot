# Pass-After — Legacy Gate Content Contract Tests (Issue #469)

Timestamp: 2026-08-13T17-28

Command:
```
poetry run pytest \
  tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py \
  tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
```

EXIT_CODE: 0

Output Summary:
- Result: **18 passed, 0 failed** (0.17s) across both resource-contract files.
- This completes the fail-before / pass-after pair with `fail-before-contract-tests.2026-08-13T17-28.md`: the same four tests that failed against the stale content now pass against the Phase 2 corrected content (AC9, AC10, AC11).
- The five Phase 1 tests all pass:
  - `test_claude_legacy_variant_files_contain_corrected_gate_commands`
  - `test_claude_legacy_variant_files_exclude_stale_gate_commands`
  - `test_claude_modern_csharp_profile_retains_modern_gate_commands`
  - `test_codex_legacy_variant_files_contain_corrected_gate_commands`
  - `test_codex_legacy_variant_files_exclude_stale_gate_commands`
- The pre-existing `test_variant_subtree_is_bundle_only_and_non_colliding` also passes, confirming the corrected variant text remains distinct from each modern counterpart.
- Coverage was disabled for this targeted run (`--no-cov`); post-change coverage is recorded by the Phase 4 final-QA full-suite runs.
