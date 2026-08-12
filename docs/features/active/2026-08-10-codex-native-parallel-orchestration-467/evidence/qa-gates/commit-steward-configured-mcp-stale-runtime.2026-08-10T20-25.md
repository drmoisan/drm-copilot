# P6-T35 Configured MCP Stale-Runtime Attribution

Timestamp: 2026-08-11T23:32:04-04:00

## Current-source Python strict validator

Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state artifacts/orchestration/orchestrator-state.json --require-codex-topology --require-codex-model-routing`

EXIT_CODE: 0

Output Summary: The current Python validator accepted the orchestrator checkpoint with strict Codex topology and model-routing requirements.

## Current-source TypeScript focused validators

Command: `npm --prefix extensions/drm-copilot run test:unit -- --runTestsByPath test/lib/validate/orchestrator-state-codex-model-routing.test.ts test/lib/validate/orchestrator-state-codex-topology.test.ts`

EXIT_CODE: 0

Output Summary: 2/2 suites and 48/48 tests passed; 0 snapshots were present.

## Configured process identity

Command: `parse .codex/config.toml and packages/mcp-server/package.json read-only with Python tomllib/json`

EXIT_CODE: 0

Output Summary: `.codex/config.toml` resolves the configured process exactly to command `npx` with arguments `-y @danmoisan/drm-copilot-mcp@1.0.23`; `validate_orchestration_artifacts` remains enabled and approved. The repository-local MCP package version remains `1.0.23`.

Configured process identity: `npx -y @danmoisan/drm-copilot-mcp@1.0.23`

## Configured MCP public call `[expect-fail]`

Command: `mcp__drm-copilot__validate_orchestration_artifacts`

Tool input:

```json
{
  "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25",
  "artifact_type": "orchestrator-state",
  "artifact_path": "artifacts/orchestration/orchestrator-state.json",
  "require_codex_topology": true,
  "require_codex_model_routing": true
}
```

EXIT_CODE: 1

Output Summary: The configured published MCP runtime returned `ok=false` only because its generated-family view rejected logical agent `commit-steward`. No parse, path, topology, or unrelated checkpoint diagnostic was returned. This non-passing result is retained as the required stale-runtime attribution and is not validator success.

Complete tool result:

```json
{
  "ok": false,
  "tool": "validate_orchestration_artifacts",
  "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-10T19-25",
  "summary": "Validation failed for orchestrator-state artifact at 'artifacts/orchestration/orchestrator-state.json':\nCheckpoint codex_model_routing_receipts[161] has invalid routing inputs: Unsupported Codex logical agent: 'commit-steward'.\nCheckpoint codex_model_routing_receipts[161] has invalid routing inputs: Unsupported Codex logical agent: 'commit-steward'."
}
```

## Immutability

Command: `git diff --name-only -- .codex/config.toml packages/mcp-server/package.json; git status --short -- artifacts/orchestration/orchestrator-state.json; git diff --cached --name-only`

EXIT_CODE: 0

Output Summary: Configuration diff count 0; package-manifest diff count 0; tracked checkpoint status count 0; index remains 783 paths with 0 `.claude/` paths. No source, configuration, package, checkpoint, index, dependency, or `.claude/` write was made by P6-T35.

Result: PASS `[expect-fail]` — current-source validators pass and only the configured published MCP runtime demonstrates the required stale logical-agent diagnostic.
