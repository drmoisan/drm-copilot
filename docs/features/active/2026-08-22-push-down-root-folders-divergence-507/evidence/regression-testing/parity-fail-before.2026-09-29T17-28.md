# Parity Fail-Before (P1-T5) [expect-fail]

Timestamp: 2026-09-29T17-28
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_parity.py -q -rf
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:
- Exit code 1; `4 failed, 6 passed in 0.18s`.
- Failed node IDs (exactly four):
  - tests/scripts/dev_tools/test_push_down_claude_parity.py::test_root_folders_match_typescript_in_order
    (AssertionError: Python/TypeScript push-down divergence: extensions/drm-copilot/src/lib/push-down/claude-customizations.ts declares ('.claude', 'config') but scripts/dev_tools/push_down_claude_customizations.py declares ('.claude',))
  - tests/scripts/dev_tools/test_push_down_claude_parity.py::test_merged_relative_paths_match_typescript
    (FileNotFoundError: scripts/dev_tools/push_down_claude_destination_writes.py does not exist yet)
  - tests/scripts/dev_tools/test_push_down_claude_parity.py::test_derived_relative_paths_match_typescript
    (FileNotFoundError: scripts/dev_tools/push_down_claude_blast_radius_derive_core.py does not exist yet)
  - tests/scripts/dev_tools/test_push_down_claude_parity.py::test_routing_merge_fixture_parity
    (ModuleNotFoundError: No module named 'scripts.dev_tools.push_down_claude_routing_merge')
- Passed (six): the synthetic-divergence, zero-declaration, set-comparison, and comment-stripping tests.
