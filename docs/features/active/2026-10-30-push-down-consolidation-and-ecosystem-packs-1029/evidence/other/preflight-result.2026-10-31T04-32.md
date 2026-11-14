# Preflight Result — Issue #1029

Timestamp: 2026-10-31T04-32
Plan: docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/plan.2026-10-30T18-37.md
Command: poetry run python -m scripts.dev_tools.validate_orchestration_artifacts plan docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/plan.2026-10-30T18-37.md
EXIT_CODE: 0
Output Summary: Branch plan validator (G1-G13) passed before and after the in-place fixes. Every `## Citation Inventory` file and symbol was confirmed present at HEAD. Three substantive defects remain.

PREFLIGHT: REVISIONS REQUIRED
CONVERGENCE: NO FURTHER ROUNDS EXPECTED

PREFLIGHT-FIX: ## Pre-Mortem (CI-only behavior) | stale task citation | `(P3-T7)` changed to `(P3-T9)` for CRLF content built in test code
PREFLIGHT-FIX: ## Size Justification | factual wording | "each with its own test and coverage entry" changed to "with their tests and per-file coverage entries" (`push-down-layer.ts` has no dedicated test file)
PREFLIGHT-FIX: ## Existing Test Dispositions | missing test citation | added `mcp-tool-inputs.test.ts` Copilot and Claude resolver describes as Unchanged
PREFLIGHT-FIX: ## Existing Test Dispositions | missing test citation | added `claude-blast-radius-overlay.test.ts` `does not publish a source-side overlay file` as Unchanged
PREFLIGHT-DEFECT: [P0-T2] | missing gate assertion | P0-T2 confirms only that `origin/main` contains each parallel-run merge. It must also confirm that each listed item's merge commit is an ancestor of `HEAD` (reached through the epic integration-branch wave sync), and record `Result: BLOCKED` when one is not. The branch is currently based on a `main` that lacks those merges, so without this check P0-T3 re-checks `DESTINATION_WRITE_DECORATORS` and the other item-1006 citations against the pre-merge shape and later edits land on stale files.
PREFLIGHT-DEFECT: [P5-T5] | unsatisfiable acceptance condition | The clause "with no path under another ecosystem's roots" cannot hold. `config` is a root of both the Claude layer (`ROOT_FOLDERS`) and the Codex layer (`VIRTUAL_ROOT_FOLDERS`), and `.agents` is a root of both the shared layer and the Codex layer, so every Claude run (`config/blast-radius.json`) and every Copilot run (shared `.agents/skills/**` and shared `config/**`) writes under another ecosystem's roots. Restate the exclusion with ecosystem-exclusive roots: no written path outside the shared set lies under `.claude/` for a non-Claude run, under `.codex/` or a non-shared `.agents/` path for a non-Codex run, or under `.github/` for a non-Copilot run.
PREFLIGHT-DEFECT: [P2-T10] | coverage gate without an implementing test | `push-down-layer.ts` gets a `{ lines: 85, branches: 75 }` entry at P2-T12, and P2-T13 requires every new file to meet it, but no task tests `isEcosystemName`. If its rejecting branch is not exercised, branch coverage for the file is 50 percent and P2-T13 cannot pass. Add a case to P2-T10 (or P2-T3) that asserts `isEcosystemName` accepts each member of `ECOSYSTEM_NAMES` and rejects `shared` and an unknown name.

preflight-fix-record: docs/features/active/2026-10-30-push-down-consolidation-and-ecosystem-packs-1029/evidence/other/preflight-fixes.2026-10-31T04-32.md

## Review Notes (no defect)

- Planning decisions D1-D8: consistent with spec.md and the current tree. D1 `shared.json` in the Codex `pack-manifests/` directory is read as a pack named `shared` by `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py` and `test_handoff_runtime_has_root_bundle_resource_and_effective_pack_parity`; each tolerates the extra manifest, and `generate_codex_agent_variants.py` renders only its named manifests.
- Merged-path pattern: `_MERGE_NAME` in `test_push_down_claude_parity.py` matches `^[A-Z_]*MERGE[A-Z_]*_RELATIVE_PATHS?$`; the plan adds only functions (`buildClaudeLayer`) to `claude-customizations.ts` and keeps `MERGED_RELATIVE_PATHS` at two entries.
- Language classification: every planned artifact follows the owner rule. New code is TypeScript in the MCP server and extension host only; data is JSON; one existing Python test is edited in place; no new Python. No `.py`, `.ts` or `.js` file exists under any published bundle root, so no manifest addition pushes TypeScript or Python to destinations. E2 does not apply.
- Phase 0 parallel-run gate (P0-T2) is present and was not removed.
