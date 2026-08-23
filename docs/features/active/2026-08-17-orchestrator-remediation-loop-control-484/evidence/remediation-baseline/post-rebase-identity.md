Timestamp: 2026-08-22T23-31
Command: `poetry run python --version`
EXIT_CODE: 0
Command: `poetry --version`
EXIT_CODE: 0
Command: `node --version`
EXIT_CODE: 0
Command: `npm --version`
EXIT_CODE: 0
Command: Inspect `packages/mcp-server/package.json`, `packages/mcp-server/package-lock.json`, `extensions/drm-copilot/package.json`, `extensions/drm-copilot/package-lock.json`, `.codex/config.toml`, and `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/config.toml`.
EXIT_CODE: 0
Command: Read-only SHA-256, byte-size, and receipt-key snapshot of `artifacts/orchestration/orchestrator-state.json`.
EXIT_CODE: 0
Output Summary:
- Python: `3.13.12`.
- Poetry: `2.3.2`.
- Node: `24.14.0`.
- npm: `11.9.0`.
- `packages/mcp-server/package.json`: `@danmoisan/drm-copilot-mcp` version `1.0.27`.
- `packages/mcp-server/package-lock.json`: root package version `1.0.27`, lockfile version `3`.
- `extensions/drm-copilot/package.json`: `drm-copilot` version `1.0.27`.
- `extensions/drm-copilot/package-lock.json`: root package version `1.0.27`, lockfile version `3`.
- Both inspected Codex config files reference `@danmoisan/drm-copilot-mcp@1.0.27`.
- Immutable published `@danmoisan/drm-copilot-mcp@1.0.24` is classified only as the intentional negative `EXTERNAL_RUNTIME` fixture, not as the positive local runtime identity.
- Checkpoint SHA-256: `3CAFE78895E04C42176717E442D8A4C246EA98D3D8A19E6968963FF1ADD7176F`.
- Checkpoint byte size: `115045`.
- Topology receipts: `47` total and `3` unique by `(languages, production_file_count, test_file_count, execution_context, cross_cutting, root_persona)`.
- Model-routing receipts: `47` total and `5` unique by normalized `(logical_agent, complexity_band, execution_context, orchestration_complexity_ceiling)`.
- Both live totals are above the independently validated pre-planner floor of `42`; unique counts are no lower than the pre-planner values of topology `2` and model routing `5`.
- The third topology key is the monotonic `S9_p6_t26_remediation_execution_post_rebase_1` execution-routing append; no checkpoint content was changed by remediation execution.
- Phase 0 receipt floor for later comparisons: topology `47` total; model routing `47` total.
