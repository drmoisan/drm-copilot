# Acceptance Criteria Coverage Mapping

Timestamp: 2026-06-24T22-58
Source: docs/features/active/2026-06-24-push-down-language-packs-csharp-variant-226/issue.md (## Acceptance Criteria)

Each of the 13 issue acceptance criteria plus the two toolchain ACs is mapped to the
implementing task(s) and the verifying test(s) or gate evidence.

- AC1 (no-arg backward compatibility, full tree + memory overwrite): P2-T6 implementation;
  verified by test_push_down_no_arguments_publishes_full_tree
  (tests/scripts/dev_tools/test_push_down_claude_pack_end_to_end.py) and the existing
  test_bundled_module_imports_without_repo_root_scripts_package. Service backward compat:
  "spawns exactly the destination args for a no-field input"
  (test/repo-automation-service.push-down-claude.test.ts).
- AC2 (core always included): P2-T2; verified by
  test_compute_published_paths_always_includes_core
  (tests/scripts/dev_tools/test_push_down_claude_pack_selection.py).
- AC3 (--packs core,typescript excludes other languages): P2-T6; verified by
  test_push_down_packs_core_typescript_excludes_other_languages (end_to_end).
- AC4 (legacy variant only under .claude-variants/csharp-legacy/, never at root): P1-T2,
  P1-T4; verified by test_variant_subtree_is_bundle_only_and_non_colliding and
  test_bundled_claude_payload_excludes_variant_subtree_from_parity
  (tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py).
- AC5 (exactly one C# toolchain; legacy at canonical paths, modern not also written):
  P2-T3, P2-T4, P2-T6; verified by
  test_push_down_legacy_variant_writes_legacy_content_to_canonical_paths and
  test_push_down_single_csharp_toolchain_written_once (end_to_end), plus
  test_push_down_both_csharp_variants_raises.
- AC6 (memory mode overwrite): P2-T5; verified by
  test_memory_mode_overwrite_writes_general_memory
  (tests/scripts/dev_tools/test_push_down_claude_pack_memory_modes.py).
- AC7 (memory mode merge, destination-existence check): P2-T5; verified by
  test_memory_mode_merge_preserves_existing_destination_memory and
  test_memory_mode_merge_writes_absent_destination_memory.
- AC8 (memory mode skip excludes .claude/agent-memory/**): P2-T5; verified by
  test_memory_mode_skip_excludes_all_agent_memory.
- AC9 (VS Code QuickPick flow maps to CLI args): P6-T2, P6-T3; verified by the
  command-registration tests in test/extension.push-down-claude-customizations.test.ts
  (mapping, conditional C# step, cancellation at each step) and the service arg-mapping
  tests in test/repo-automation-service.push-down-claude.test.ts.
- AC10 (MCP schema gains optional fields; workspace_root-only stays valid): P6-T6, P6-T7,
  P6-T8; verified by the handler/dispatch tests
  (test/push-down-claude-handler.test.ts, test/mcp-tools.push-down-claude.test.ts)
  including the schema and definition-file-parity tests.
- AC11 (parity test excludes variant subtree): P5-T2; verified by
  test_bundled_claude_payload_excludes_variant_subtree_from_parity and
  test_pack_manifests_are_outside_the_parity_scope.
- AC12 (variant never collides + exactly one C# toolchain): P5-T2, P5-T3; verified by
  test_variant_subtree_is_bundle_only_and_non_colliding and
  test_push_down_single_csharp_toolchain_written_once.
- AC13 (Python toolchain green, coverage thresholds): P7-T2..P7-T5; verified by the
  qa-gates artifacts python-black/ruff/pyright/pytest.2026-06-24T22-58.md (all exit 0;
  feature modules 89-91% line, exceeding >=85% line / >=75% branch).
- AC (TypeScript toolchain green, coverage thresholds): P7-T6..P7-T9; verified by the
  qa-gates artifacts ts-format/lint/typecheck/test.2026-06-24T22-58.md (all exit 0; all
  files 95.86% line / 88.05% branch, touched files exceeding thresholds).

Test Conditions to Consider (issue.md):
- Unit coverage (manifest parsing, pack filtering, variant selection, memory-mode
  filtering, CLI parsing/defaults): covered by test_push_down_claude_pack_selection.py and
  test_push_down_claude_pack_memory_modes.py.
- Integration scenarios (end-to-end with packs+variant, parity adaptation,
  conflict-prevention): covered by test_push_down_claude_pack_end_to_end.py and
  test_push_down_claude_resource_contracts.py.
- CLI/API examples (arg combinations, MCP schema with/without optional fields, VS Code
  mapping): covered by the service, handler, dispatch, and command-registration tests.

Result: every one of the 13 issue acceptance criteria plus both toolchain ACs is mapped
to at least one passing test or recorded gate evidence. No AC is unmapped.
