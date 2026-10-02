# File-Size Gate (P8-T17, AC-2)

Timestamp: 2026-09-30T15-10
Task: [P8-T17]
Location: worktree root

Command: wc -l scripts/dev_tools/_orchestrator_state_routing.py scripts/dev_tools/_orchestrator_state_route_gates.py scripts/dev_tools/_orchestrator_state_promotion_tools.py scripts/dev_tools/_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_routing_split.py tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1 tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1 tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1 scripts/powershell/PoshQC/settings/pester.runsettings.psd1 extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts extensions/drm-copilot/jest.config.cjs extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption.test.ts extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts
EXIT_CODE: 0

## Output Summary

| Path | Lines | Below 500 | P0-T5 baseline |
| --- | --- | --- | --- |
| scripts/dev_tools/_orchestrator_state_routing.py | 265 | yes | 595 (pre-split) |
| scripts/dev_tools/_orchestrator_state_route_gates.py | 381 | yes | new |
| scripts/dev_tools/_orchestrator_state_promotion_tools.py | 95 | yes | new |
| scripts/dev_tools/_orchestrator_state_issue_adoption.py | 325 | yes | new |
| tests/scripts/dev_tools/test_orchestrator_state_routing_split.py | 104 | yes | new |
| tests/scripts/dev_tools/test_validate_orchestrator_state_issue_adoption.py | 247 | yes | new |
| tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py | 744 | **no** | new |
| tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py | 222 | yes | new |
| .claude/lib/orchestrator-state/OrchestratorStateIssueAdoption.psm1 | 375 | yes | new |
| .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1 | 438 | yes | 430 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | 380 | yes | new |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1 | 111 | yes | new |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1 | 106 | yes | 105 |
| scripts/powershell/PoshQC/settings/pester.runsettings.psd1 | 349 | yes | 347 |
| extensions/drm-copilot/src/lib/validate/orchestrator-state-issue-adoption.ts | 295 | yes | new |
| extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts | 467 | yes | 455 |
| extensions/drm-copilot/jest.config.cjs | 373 | yes | 363 |
| extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption.test.ts | 477 | yes | new |
| extensions/drm-copilot/test/lib/validate/orchestrator-state-issue-adoption-parity.test.ts | 176 | yes | new |

Total: 5930. Nineteen counts listed; eighteen are below 500.

Edited files against their P0-T5 baselines: `_orchestrator_state_routing.py` 595 -> 265; `OrchestratorStateRoutingContract.psm1` 430 -> 438; `orchestrator-state-routing.ts` 455 -> 467.

Finding: `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption.py` has 744 lines. That exceeds the 500-line limit in `.claude/rules/general-code-change.md` and the P3-T4 requirement "under 500 lines". The file was created in P3-T4 (commit 618856f2) and edited in commit ca655902. No task before P8-T17 measured its line count.

Why it was not remediated in this task: the file holds 31 plan-fixed test functions (39 collected node IDs, `PY_UNIT_PASSED` = 39). Getting under 500 lines without changing node IDs needs either (a) a split into a second test file, which is not in the "Scope of the diff" enumeration and would violate AC-19 without a planner revision, or (b) a behavior-preserving rewrite of about 250 lines, which restarts the Python QA loop (P8-T5 to P8-T9) and invalidates P8-T15. Neither is a micro-action within P8-T17, which is a verification task. It is escalated to the orchestrator for a remediation plan.

Result: FAIL (AC-2 not satisfied). P8-T17 is left unchecked.
