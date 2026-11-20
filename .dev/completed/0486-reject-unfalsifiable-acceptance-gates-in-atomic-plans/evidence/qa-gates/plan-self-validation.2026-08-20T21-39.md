# Final QC — Remediation Plan Self-Validation via the MCP Tool (Issue #486)

Timestamp: 2026-08-20T21-39
Task: [P4-T10]

## Tool invocation

Tool: `mcp__drm-copilot__validate_orchestration_artifacts`

Arguments:

- `artifact_type: "plan"`
- `artifact_path: docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/remediation-plan.2026-08-20T17-11.md`
- `workspace_root: C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d`

EXIT_CODE: 0 (`"isError": false`, `"ok": true`)

## Invocation mechanism and why it was used

`mcp__drm-copilot__validate_orchestration_artifacts` was not present in this executor session's
available tool list, so it could not be called as a direct tool. Rather than substituting a weaker
in-process TypeScript call, the real MCP server was built and driven over stdio by the Model Context
Protocol SDK's own client, which exercises the identical dispatch path
(`mcp-tools.ts` -> handler -> `RepoAutomationService`) a live MCP client would use:

1. `node esbuild-mcp-server.cjs` from `extensions/drm-copilot` produced `out/mcp-server.js`
   (exit 0; `out/` is gitignored).
2. A throwaway harness `extensions/drm-copilot/tmp-mcp-plan-validate.cjs` spawned that bundle via
   `StdioClientTransport` and issued one `client.callTool` with the snake_case arguments above.
3. The harness was deleted immediately after the call, leaving no untracked residue.

Command: `node tmp-mcp-plan-validate.cjs "docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/remediation-plan.2026-08-20T17-11.md"` (run from `extensions/drm-copilot`)

## Verbatim tool response

```json
{
  "ok": true,
  "tool": "validate_orchestration_artifacts",
  "workspace_root": "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d",
  "summary": "Validated plan artifact at 'docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/remediation-plan.2026-08-20T17-11.md'.",
  "warnings": [
    "[P1-T2] search literal `def _evaluate_cov_value` is absent from the tracked tree and is not quoted in the plan; the search returns zero matches whatever the executor does. Quote the exact literal the task will create, or assert a literal that exists."
  ]
}
```

Output Summary: The verbatim success summary string returned by the tool is

`Validated plan artifact at 'docs/features/active/2026-08-17-reject-unfalsifiable-acceptance-gates-in-atomic-plans-486/remediation-plan.2026-08-20T17-11.md'.`

The tool returned `"ok": true` and `"isError": false` with **zero blocking findings**. One G5
Warning was surfaced on the optional `warnings` field and is dispositioned in [P4-T11]; a Warning
does not affect the validation outcome. The `mcp__drm-copilot__run_poshqc_format` tool was also
invoked once against `scripts/dev_tools` during this phase; it reported `ok: true` and modified no
file (`git status --porcelain scripts/` unchanged), because that folder contains no PowerShell
source.
