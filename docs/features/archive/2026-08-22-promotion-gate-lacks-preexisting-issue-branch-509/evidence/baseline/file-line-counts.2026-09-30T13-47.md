# Baseline File Line Counts (P0-T5)

Timestamp: 2026-09-30T13-47
Task: [P0-T5]
Location: worktree root

Command: wc -l scripts/dev_tools/_orchestrator_state_routing.py .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1 extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts extensions/drm-copilot/jest.config.cjs tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1
EXIT_CODE: 0
Output Summary:

| Path | Observed | Planner value | Match |
| --- | --- | --- | --- |
| `scripts/dev_tools/_orchestrator_state_routing.py` | 595 | 595 | yes |
| `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` | 430 | 430 | yes |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts` | 455 | 451 before #405, "a few lines" added by #405 | consistent (451 + 4 lines from the #405 import and wrapped declaration) |
| `extensions/drm-copilot/jest.config.cjs` | 363 | 325 (pre-#405 tree) | no — 38 lines more than the planner's pre-#405 read; the file now carries the #405 `orchestrator-state-promotion-tools.ts` entry and other entries added on the integration base since the planner's read |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` | 105 | 105 | yes |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 347 | not stated | n/a |

Total: 2295 lines. Every file is below 500 lines except the Python routing module (595), which the plan splits in Phase 1. The `jest.config.cjs` mismatch does not affect the plan's size gate (363 is below 500); later tasks that edit it locate entries by content.
