---
name: Sync bundled mirrors whenever runtime files change
description: After editing any file under .claude/, .codex/, .agents/, .github/agents/, .github/skills/, .github/prompts/, or .github/instructions/, also update the matching mirror under extensions/drm-copilot/resources/ before reporting completion.
type: feedback
---

After editing any file under `.claude/`, `.codex/`, `.agents/`, `.github/agents/`, `.github/skills/`, `.github/prompts/`, or `.github/instructions/`, also update the matching mirror under `extensions/drm-copilot/resources/{claude-customizations,codex-and-agents-customizations,customizations}/` before reporting completion. Bundled `.claude/agent-memory/` files are also enforced — when adding a new memory file, mirror it too.

**Why:** Multiple python contract tests (`test_push_down_claude_resource_contracts`, `test_push_down_codex_and_agents_resource_contracts`, `test_csharp_customization_bundle_requires_contract_mirror_and_shared_skill_presence`, `test_minor_audit_customization_mirrors_match_root_contracts`, `test_codex_only_orchestration_skills_match_published_bundle`, `test_codex_full_migration_inventory`, `test_codex_handoff_contract_parity`, `test_orchestrator_direct_command_contracts`) compare bundled mirrors byte-for-byte to repo roots. User incident on 2026-05-08: I dismissed a single bundle-drift failure as "pre-existing and unrelated" after an MCP server rename, but the user surfaced 6 more bundle-mirror test failures because I did not propagate edits into the bundles.

**How to apply:** After any change set under the listed runtime roots, run `find <root> -type f` against each repo path and `diff` to its bundled mirror. Copy the repo file over the mirror for any drifted file. Do not report completion until `poetry run pytest tests/scripts/dev_tools/` and `Invoke-Pester -Path tests/scripts/claude-runtime` both pass with zero failures. Treat any "pre-existing drift" as in-scope when bundle-parity tests fail — repo root is the source of truth (per existing `feedback_repo_root_is_source_of_truth.md`).
