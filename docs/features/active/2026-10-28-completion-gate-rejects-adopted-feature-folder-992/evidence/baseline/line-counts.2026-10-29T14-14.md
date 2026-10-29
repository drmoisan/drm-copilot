# Pre-Change Physical Line Counts (P0-T2)

Timestamp: 2026-10-29T14-14
Command: wc -l <path> for each path below (from the worktree root)
EXIT_CODE: 0

| Path | Lines |
| --- | --- |
| `scripts/dev_tools/_orchestrator_state_issue_adoption.py` | 352 |
| `tests/scripts/dev_tools/orchestrator_state_issue_adoption_test_support.py` | 187 |
| `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_waivers.py` | 338 |
| `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py` | 222 |
| `extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts` | 324 |
| `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption.test.ts` | 477 |
| `extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts` | 176 |
| `extensions/drm-copilot/jest.config.cjs` | 493 |
| `.claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1` | 396 |
| `.claude/hooks/validate-orchestrator-output.ps1` | 346 |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1` | 437 |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1` | 111 |
| `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1` | 108 |
| `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` (near-limit, unchanged) | 462 |
| `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` (near-limit, unchanged) | 454 |

Output Summary: 15 files counted; maximum 493 (`jest.config.cjs`), all at or below 500. The plan's new files do not exist yet.
