# Final QA — PoshQC Analyze (issue #671)

Timestamp: 2026-09-17T08-23
Task: [P6-T2]
Command: mcp__drm-copilot__run_poshqc_analyze (workspace_root = worktree root) as the route-compliance step; then, per path, `Invoke-ScriptAnalyzer -Path <path> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information` (PSScriptAnalyzer 1.25.0, pwsh 7.6.6, scratchpad `sh` wrapper at the worktree root)
EXIT_CODE: 0

Output Summary:
- MCP call disposition: 0 (`ok: true`; fixed-template summary). Under `Invoke-PoshQCAnalyze`, a non-zero finding count throws, so the zero-count claim is anchored to the zero-findings branch at `PoshQC.Analyzer.psm1` line 185; the counts below come from the direct runs.
- Direct analyzer: `@($findings).Count` = 0 for each of the seven paths; no finding rows.
- No divergence between the MCP disposition and the direct runs.

| Path | @($findings).Count | Finding rows |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 0 | none |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 0 | none |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 0 | none |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 0 | none |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 0 | none |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 0 | none |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` | 0 | none |
