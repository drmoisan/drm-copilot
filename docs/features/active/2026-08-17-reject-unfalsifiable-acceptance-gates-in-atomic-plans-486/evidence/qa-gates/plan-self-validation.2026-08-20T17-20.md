# Plan Self-Validation via the MCP Tool ([P4-T10])

Timestamp: 2026-08-20T17-20

Command: `mcp__drm-copilot__validate_orchestration_artifacts` with
`artifact_type: "plan"`,
`artifact_path: docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/remediation-plan.2026-08-20T16-10.md`,
`workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d`

EXIT_CODE: 0

Output Summary:

- Verbatim success summary string returned by the tool:

  `Validated plan artifact at 'docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/remediation-plan.2026-08-20T16-10.md'.`

- Full structured result:

```json
{
  "ok": true,
  "tool": "validate_orchestration_artifacts",
  "workspace_root": "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d",
  "summary": "Validated plan artifact at 'docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/remediation-plan.2026-08-20T16-10.md'."
}
```

- `isError: false`, and the optional `warnings` field is **absent**, which per
  `.claude/rules/plan-acceptance-gates.md` means the run produced zero Warning-channel plan-gate
  findings in addition to zero Blocking findings.

## Invocation Method (recorded for auditability)

`mcp__drm-copilot__validate_orchestration_artifacts` was not present in this executor session's
available tool list. Rather than substitute a weaker in-process function call, the real MCP server
was built and driven over stdio through the Model Context Protocol SDK client, which exercises the
same dispatch path a live MCP client uses (tool-input resolution, JSON-RPC framing, handler,
service method):

1. `node esbuild-mcp-server.cjs` from `extensions/drm-copilot`, producing the gitignored
   `out/mcp-server.js`.
2. A throwaway CommonJS script inside `extensions/drm-copilot` (required for `node_modules`
   resolution) spawned that bundle via `StdioClientTransport` and called `client.callTool` with the
   three snake_case arguments named above.
3. The throwaway script was deleted after the run. `git status --porcelain extensions/` returned
   empty output afterwards, so no residue remains in the working tree.
