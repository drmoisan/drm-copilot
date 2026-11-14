# PR cost summary: PreToolUse hook processes before and after the dispatcher ([P7-T7], AC 4)

Timestamp: 2026-11-14T06-35
Command: read of evidence/baseline/hook-process-cost.2026-11-11T04-27.md (before, -Source Registration, [P0-T10]) and evidence/regression-testing/hook-process-cost.2026-11-14T06-35.md (after, -Source Dispatcher, [P7-T7])
EXIT_CODE: 0
Output Summary: every runtime and scenario drops to 1 hook process per tool call (before: 1 to 15). Median CPU seconds per call fall in every scenario except claude mcp (1.516 before, 1.266 after); median wall seconds fall in every scenario. No scenario's after wall time exceeds its before wall time. One hook arrived after the before report: .claude/hooks/enforce-owner-directive-pass-down.ps1 (issue 1157), now dispatched for Claude Bash, Write, Agent and mcp calls.

Sources: evidence/baseline/hook-process-cost.2026-11-11T04-27.md and evidence/regression-testing/hook-process-cost.2026-11-14T06-35.md. Both used 5 iterations and the same payload templates. Grandchild git and gh processes are excluded from the counts and CPU seconds in both reports.

| Runtime | Scenario | Tool name | Processes per call (before -> after) | CPU s median (before -> after) | Wall s median (before -> after) | Wall s mean (before -> after) | Wall s max (before -> after) |
|---|---|---|---|---|---|---|---|
| claude | bash | `Bash` | 12 -> 1 | 18.703 -> 3.250 | 9.327 -> 3.689 | 11.198 -> 3.821 | 19.704 -> 5.114 |
| claude | write | `Write` | 13 -> 1 | 11.766 -> 2.141 | 5.620 -> 2.440 | 5.934 -> 2.505 | 7.033 -> 3.010 |
| claude | agent | `Agent` | 9 -> 1 | 10.797 -> 3.031 | 7.132 -> 3.767 | 8.077 -> 3.702 | 13.108 -> 3.972 |
| claude | mcp | `mcp__drm-copilot__run_discovery_repo_inventory` | 1 -> 1 | 1.516 -> 1.266 | 7.094 -> 1.195 | 6.651 -> 1.300 | 10.143 -> 1.721 |
| codex | bash | `Bash` | 12 -> 1 | 15.406 -> 2.375 | 10.069 -> 2.485 | 9.855 -> 2.681 | 13.815 -> 3.656 |
| codex | write | `apply_patch` | 15 -> 1 | 15.297 -> 2.141 | 8.260 -> 2.271 | 9.453 -> 2.500 | 18.807 -> 3.026 |
| codex | agent | `Agent` | 2 -> 1 | 2.359 -> 1.125 | 3.493 -> 1.114 | 3.711 -> 1.204 | 4.623 -> 1.463 |
| codex | mcp | `mcp__drm-copilot__run_discovery_repo_inventory` | 6 -> 1 | 6.906 -> 1.453 | 8.734 -> 1.914 | 11.051 -> 2.184 | 16.910 -> 3.773 |

## Scenarios whose after wall time exceeds the before wall time
None (median, mean and max wall seconds are lower after for every runtime and scenario).

## Hooks that arrived after the before report (from the [P7-T1] record main-integration.2026-11-14T05-03.md)
- .claude/hooks/enforce-owner-directive-pass-down.ps1 (issue 1157): counted as a dispatched member in the after report (claude bash 13, write 14, agent 10 and mcp 2 dispatched members), and absent from the before report, which reflects the [P0-T1] inventory.
