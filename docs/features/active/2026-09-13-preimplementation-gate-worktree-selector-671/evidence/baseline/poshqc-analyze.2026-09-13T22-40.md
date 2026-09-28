# Baseline — PoshQC Analyze (issue #671)

Timestamp: 2026-09-17T07-55
Task: [P0-T7]
Command: mcp__drm-copilot__run_poshqc_analyze (workspace_root = worktree root) as the route-compliance step; then, per path, `Invoke-ScriptAnalyzer -Path <path> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information` (PSScriptAnalyzer 1.25.0, pwsh 7.6.6, launched from a scratchpad `sh` wrapper at the worktree root)
EXIT_CODE: 0

Output Summary:
- MCP call disposition: 0 (returned `ok: true`; fixed-template summary, no findings or count carried).
- Direct analyzer results: all six paths report `@($findings).Count` = 0 with no finding rows.
- No divergence between the MCP disposition and the direct runs.

## Per-path direct results

| Path | @($findings).Count | Finding rows (RuleName / Severity / Line / Message) |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 0 | none |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 0 | none |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 0 | none |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 0 | none |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 0 | none |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 0 | none |
