# Remediation Baseline — PoshQC Analyze (issue #671, R1)

Timestamp: 2026-09-17T09-40
Task: [P0-T6]
Command: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6dbf51ad3a3ac686`; then (D3) `sh <scratchpad>/f671-r1/run.sh <scratchpad>/f671-r1/pssa7.ps1`, which runs `Invoke-ScriptAnalyzer -Path <path> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error,Warning,Information` per path and records `@($findings).Count` (PSScriptAnalyzer 1.25.0; script exit code 0).
EXIT_CODE: 0
MCP disposition (D1): `ok: true`; summary `Ran bundled PoshQC analyze against 'C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a6dbf51ad3a3ac686'.` By D3, `ok: true` means `Invoke-PoshQCAnalyze` reached its zero-findings branch (`PSScriptAnalyzer passed: no findings under`).

## Per-path findings (D3)

| Path | `@($findings).Count` |
| --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 0 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 0 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 0 |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` | 0 |

## Finding rows (RuleName | Severity | Line | Message)

None. Each path has zero findings, so zero finding rows are recorded, which matches each count.

Output Summary: all seven paths report 0 findings under the repository PSSA settings; the MCP analyze call returned `ok: true`.
