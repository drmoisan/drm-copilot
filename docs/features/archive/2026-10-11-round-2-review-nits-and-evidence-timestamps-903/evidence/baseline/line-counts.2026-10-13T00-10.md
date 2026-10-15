# Line-Count Baseline (P0-T14)

Timestamp: 2026-10-13T00-10
Command: wc -l <the 35 files listed below> (run from <worktree>)
EXIT_CODE: 0
BASE: fd81a43b45de65078236da6c1cbfd077c3eb010c (HEAD 606c1d5172db9e2a2174cf2dfbf2e7e3facace34)

| Lines | File |
|---:|---|
| 423 | tests/scripts/dev_tools/test_completion_gate_documentation_contracts.py |
| 219 | tests/scripts/dev_tools/test_validate_epic_orchestrator_state_merge_status.py |
| 218 | scripts/dev_tools/_blast_radius_token_shapes.py |
| 213 | tests/scripts/dev_tools/test_blast_radius_token_shapes.py |
| 497 | tests/scripts/dev_tools/test_workflow_npm_token_guard.py |
| 449 | tests/scripts/dev_tools/test_check_quality_tiers.py |
| 221 | extensions/drm-copilot/test/subagent-tree-command.quick-pick.test.ts |
| 70 | extensions/drm-copilot/test/subagent-tree-command-test-support.ts |
| 267 | .claude/lib/blast-radius/BlastRadiusTokenShape.psm1 |
| 357 | tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 |
| 496 | .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 |
| 493 | .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 |
| 279 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 |
| 276 | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1 |
| 373 | .claude/hooks/feature-folder-resolution.ps1 |
| 274 | tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1 |
| 274 | tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1 |
| 470 | .claude/hooks/enforce-completion-consistency.ps1 |
| 76 | tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1 |
| 328 | .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 |
| 275 | .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 |
| 218 | .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 |
| 306 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 |
| 53 | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1 |
| 197 | tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 |
| 474 | tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 |
| 350 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 |
| 280 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 |
| 197 | tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 |
| 259 | tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 |
| 177 | tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1 |
| 82 | tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.ScanRoots.Helpers.ps1 |
| 256 | tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 |
| 136 | tests/scripts/claude-lib/codex-routing/CodexDeployment.GeneratedFamilies.Parity.Tests.ps1 |
| 247 | tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 |

Files counted: 35 (every file named in P0-T14). `wc -l` total: 9780.

## Budget-critical comparison against plan-time reads

| File | Plan-time | Observed | Match |
|---|---:|---:|---|
| tests/scripts/dev_tools/test_workflow_npm_token_guard.py | 497 | 497 | yes |
| .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 496 | 496 | yes |
| .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 | 493 | 493 | yes |
| tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 | 474 | 474 | yes |
| .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 | 328 | 328 | yes |
| .claude/hooks/enforce-completion-consistency.ps1 | 470 | 470 | yes |

Every other count stated for these files in the plan's Verified Plan-Time Facts or in the three research inputs (423, 219, 218, 213, 449, 221, 70, 267, 357, 279, 276, 373, 274, 274, 76, 275, 218, 306, 53, 197, 197, 259, 177, 82, 256, 136, 247) also matches the observed value. No plan-time count was stated for `enforce-gate-suites.EpicStateIsolation.Tests.ps1` (350) or `enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1` (280). Deviation: none (the operator-directed main merge did not change any counted file).

Output Summary: 35 files counted; all six budget-critical counts match the plan-time reads (497, 496, 493, 474, 328, 470). No mismatch; no file exceeds 500 lines.
