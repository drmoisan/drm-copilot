# Push-Down Suite Regression Run (Issue #469)

Timestamp: 2026-08-13T17-28

Command:
```
poetry run pytest \
  tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py \
  tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py \
  tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py \
  tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py \
  tests/scripts/dev_tools/test_push_down_claude_pack_selection.py \
  tests/scripts/dev_tools/test_push_down_codex_pack_selection.py
```

EXIT_CODE: 0

Output Summary:
- Result: **68 passed, 0 failed** (0.29s) across all six push-down test files.
- AC12 determinism is covered by the two new repeated-generation tests:
  - `test_push_down_claude_repeated_generation_is_deterministic` (Claude engine, `packs={"core","csharp-legacy"}`, `csharp_variant="legacy"`)
  - `test_push_down_codex_repeated_generation_is_deterministic` (Codex engine, `packs={"core","csharp"}` with `csharp_variant="legacy"`, because the Codex engine rejects variant-specific pack names)
- Existing mutual-exclusion and routing tests in the pack-selection files remain green; no new mutual-exclusivity tests were added because both `assert_single_csharp_toolchain` branches are already covered.
- File-size compliance after the additions: `test_push_down_claude_pack_end_to_end.py` 390 lines; `test_push_down_codex_and_agents_customizations.py` 495 lines (was 497 before the behavior-preserving compaction, 470 immediately after it). Both are at or under the 500-line limit.
- Coverage was disabled for this targeted run (`--no-cov`); post-change coverage is recorded by the Phase 4 final-QA full-suite runs.
