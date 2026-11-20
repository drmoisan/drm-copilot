Timestamp: 2026-08-25T22-28
Command: `mcp__drm-copilot__validate_orchestration_artifacts` with `artifact_type: "orchestrator-state"`, `artifact_path: "artifacts/orchestration/orchestrator-state.json"`, `require_codex_model_routing: true`, and `workspace_root: "C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-25T14-48"`.
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Expected failure. The installed MCP validator rejected `codex_model_routing_receipts[39]` with `Unsupported Codex logical agent: 'commit-steward'`. The diagnostic was reported twice by the validator summary. The installed package/runtime identity was not reported by this invocation.

Validator diagnostic:
`Checkpoint codex_model_routing_receipts[39] has invalid routing inputs: Unsupported Codex logical agent: 'commit-steward'.`

Runtime limitation: this invocation used the currently installed MCP runtime as fail-before diagnostic evidence only. It neither updates nor proves an update to `@danmoisan/drm-copilot-mcp@1.1.2`; source-level Jest verification is required for pass-after evidence.
