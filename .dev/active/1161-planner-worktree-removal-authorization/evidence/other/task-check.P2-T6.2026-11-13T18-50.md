# Task Check - P2-T6 (post-merge line-cap fix and related order-dependence fix)

Timestamp: 2026-11-13T18-50
Command: sh SCRATCH/issue-1161-tc-p2t6.sh (Invoke-Formatter and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the changed files; New-PesterConfiguration with Run.Path set to the selection and PassThru)
EXIT_CODE: 0
Output Summary: format drift 0, PSScriptAnalyzer findings 0; Pester selection of 30 files: 1028 tests, 1028 passed, 0 failed, 0 skipped. Bundle parity: 23 passed. This is a task check, not a gate; it measures no coverage.

## Changed files

- .claude/hooks/enforce-epic-worktree-removal-gate.ps1 (help reflow, one blank line removed)
- .claude/hooks/enforce-parallel-worktree-removal-gate.ps1 (help reflow, one blank line removed)
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-worktree-removal-gate.ps1 (byte copy)
- extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-worktree-removal-gate.ps1 (byte copy)
- tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1 (leaker fix: file-level AfterAll calling Reset-EpicStateProbeModuleBinding)
- tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1 (victim fix: Reset-EpicStateProbeModuleBinding before Register-EpicStateBaselineMock in the promotion-gate Describe)

## Selection and rule

Rule (Test Cadence): every test file under tests/ whose text names a changed gate file (enforce-epic-worktree-removal-gate.ps1 or enforce-parallel-worktree-removal-gate.ps1), plus the wording contract suite that reads the gates' .DESCRIPTION help. The selection includes the #1163 tests and both PlannerWorktree suites. The two edited test files are in the selection.

- tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1
- tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Diagnostics.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Issue824.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.PlannerWorktree.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.RelativeRecord.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1
- tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.WorktreeResolution.Tests.ps1
- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1
- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Issue824.Tests.ps1
- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.PlannerWorktree.Tests.ps1
- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.RelativeRecord.Tests.ps1
- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
- tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.WorktreeResolution.Tests.ps1
- tests/scripts/claude-hooks/enforce-worktree-removal-gate-planner.Tests.ps1
- tests/scripts/claude-hooks/hook-command-invocation.Issue824Regression.Tests.ps1
- tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1
- tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1
- tests/scripts/claude-hooks/session-root-reads-850.Constraints.Tests.ps1
- tests/scripts/claude-runtime/planner-worktree-removal-contract.Tests.ps1
- tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1
- tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1
- tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-issue824.Tests.ps1
- tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-planner-worktree.Tests.ps1
- tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1
- tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1
- tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1

For the mirror copies: tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py and tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py (env -u VIRTUAL_ENV poetry run pytest -n auto -q --no-cov), EXIT_CODE 0, 23 passed.

## Commands and exit codes

| Step | Command | EXIT_CODE | Result |
| --- | --- | --- | --- |
| First run | sh SCRATCH/issue-1161-tc-p2t6.sh (gates only in the changed list) | 1 | 1026 passed, 2 failed: `Issue #824 regression: promotion gate (claude).baseline mock interception probe` and the codex row of the same name |
| Isolation | the victim file alone | 0 | 25 passed |
| Pair bisect | each of the 18 selection files before the victim, one pair per process | n/a | only cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1 reproduces (victim failed 2); the other 17 pairs pass |
| Merge-base check | the same pair on a `git archive` copy of the merge base of origin/main and HEAD in SCRATCH | n/a | 35 passed, 2 failed: the order dependence is pre-existing on main |
| Victim fix only (merge base) | pair with only the victim fix applied | n/a | 37 passed, 0 failed |
| Leaker fix only (merge base) | pair with only the leaker fix applied | n/a | 37 passed, 0 failed |
| Final run | sh SCRATCH/issue-1161-tc-p2t6.sh (all four PowerShell files in the changed list) | 0 | format drift 0, PSSA 0; 1028 passed, 0 failed |
| Bundle parity | sh SCRATCH/issue-1161-pyparity.sh | 0 | 23 passed |

## Order-dependence finding (related, fixed inside this item)

Mechanism: the EndToEnd suite dot-sources gates that re-import WorktreeRunResolution with -Force, leaving EpicScopeResolution bound to a replaced WorktreeRunResolution instance. The next suite's epic-scope interception probe then mocks the current run module, Resolve-WorktreeEpicTarget runs in the stale instance, and Get-EpicScopeCheckpointText is invoked zero times. Both sides now use the existing Reset-EpicStateProbeModuleBinding helper, as enforce-parallel-cohort-barrier.Tests.ps1, validate-orchestrator-output.Envelope.Tests.ps1, and the hook-dependency-failure suites already do. No assertion changed.
