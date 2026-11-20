# Phase 1 — Bundle Parity (pytest)

Timestamp: 2026-06-27T23-55

Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py -q

EXIT_CODE: 0

Output Summary: 9 passed in 0.10s. Both bundle-parity contract suites pass after the Phase 1 hook edits.

Three-copy byte-identical confirmation for enforce-pr-author-skill.ps1:
- runtime `.claude/hooks/enforce-pr-author-skill.ps1` (440 lines).
- claude mirror `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-pr-author-skill.ps1`: `cmp` reports IDENTICAL to runtime (byte-for-byte).
- codex mirror `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-pr-author-skill.ps1` (443 lines): body below the 3-line `# Converted hook` header is byte-identical to runtime (`tail -n +4 | cmp - runtime` reports identical).

The claude contract test (test_bundled_claude_payload_contains_all_repo_runtime_contracts) enforces the runtime-vs-claude byte parity. The codex contract test does not byte-compare the codex hook (no `.codex/` directory exists at repo root, so list_scoped_files(REPO_ROOT) yields no `.codex` files); the codex body parity above was verified directly with `cmp`.
