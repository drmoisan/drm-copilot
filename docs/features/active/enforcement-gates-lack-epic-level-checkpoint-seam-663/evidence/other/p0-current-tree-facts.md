# Current-Tree Facts ([P0-T5])

Timestamp: 2026-09-25T18-58
Command: sh <SCRATCHPAD>/i663/run.sh p0-facts  (fresh PowerShell 7 process; `Get-Content` line indexing and `@(Get-Content).Count` over repository-relative paths)
EXIT_CODE: 0
Output Summary: 39 cited lines contain their tokens and 17 line counts equal their expected values; MISMATCH_COUNT: 0.

## Line Facts

- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:33 token `$script:UnresolvableCommandCharacters` MATCH: `$script:UnresolvableCommandCharacters = [char[]]@('$', '`', '>', '<')`
- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:382 token `function Test-ExemptOrchestrationStagingCommand` MATCH: `function Test-ExemptOrchestrationStagingCommand {`
- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1:413 token `IndexOfAny($script:UnresolvableCommandCharacters)` MATCH: `if ($CommandText.IndexOfAny($script:UnresolvableCommandCharacters) -ge 0) {`
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:27 token `$script:CheckpointPath =` MATCH: `$script:CheckpointPath = 'artifacts/orchestration/orchestrator-state.json'`
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:267 token `function Get-EpicCheckpointContent` MATCH: `function Get-EpicCheckpointContent {`
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:279 token `function Get-ParallelCheckpointContent` MATCH: `function Get-ParallelCheckpointContent {`
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:378 token `$mode = $script:OrchestrationDelegationDefaultMode` MATCH: `$mode = $script:OrchestrationDelegationDefaultMode`
- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1:442 token `Implementation operations require artifacts/orchestration/orchestrator-state.json` MATCH: `return Get-OrchestrationPreimplementationGateBlockDecision -Reason 'PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.'`
- .claude/hooks/enforce-pr-author-skill-helpers.ps1:46 token `WorktreeItemResolution.psm1` MATCH: `Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeItemResolution.psm1') -Force -ErrorAction Stop`
- .claude/hooks/enforce-pr-author-skill-helpers.ps1:228 token `Test-EpicBaseBranchOverride -CommandText $CommandText -CheckpointPath $CheckpointPath` MATCH: `$epicBaseBranchReason = Test-EpicBaseBranchOverride -CommandText $CommandText -CheckpointPath $CheckpointPath`
- .claude/hooks/enforce-pr-author-skill-helpers.ps1:332 token `Get-PrAuthorTargetCheckpointResolution -CommandText $CommandText` MATCH: `$resolution = Get-PrAuthorTargetCheckpointResolution -CommandText $CommandText`
- .claude/hooks/enforce-pr-author-skill-helpers.ps1:340 token `Invoke-OrchestratorStatePreflight -CheckpointPath $checkpointPath` MATCH: `$preflightResult = Invoke-OrchestratorStatePreflight -CheckpointPath $checkpointPath`
- .claude/hooks/enforce-pr-author-skill-helpers.ps1:353 token `Test-PrAuthorReceiptVerification -CommandText $CommandText -CheckpointPath` MATCH: `$receiptReason = Test-PrAuthorReceiptVerification -CommandText $CommandText -CheckpointPath $script:OrchestratorStateCheckpointPath`
- .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1:101 token `'epic_mode'` MATCH: `if ($checkpointProps -notcontains 'epic_mode' -or -not [bool]$checkpoint.epic_mode) {`
- .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1:120 token `Get-CommandLineFlagValue` MATCH: `$baseValue = Get-CommandLineFlagValue -CommandText $CommandText -CommandWord 'gh' -SubcommandPath @('pr', 'create') -FlagName '--base'`
- .claude/hooks/enforce-model-routing-receipt.ps1:53 token `WorktreeItemResolution.psm1` MATCH: `Import-Module (Join-Path $PSScriptRoot '../lib/worktree-resolution/WorktreeItemResolution.psm1') -Force -ErrorAction Stop`
- .claude/hooks/enforce-model-routing-receipt.ps1:241 token `Get-ModelRoutingTargetCheckpointResolution -PromptText $prompt` MATCH: `$resolution = Get-ModelRoutingTargetCheckpointResolution -PromptText $prompt`
- .claude/hooks/enforce-model-routing-receipt.ps1:253 token `Test-ModelRoutingReceiptPresent -Checkpoint $checkpoint -Subagent $subagent` MATCH: `if (Test-ModelRoutingReceiptPresent -Checkpoint $checkpoint -Subagent $subagent) {`
- .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:164 token `function Find-WorktreeResolutionBranchSignal` MATCH: `function Find-WorktreeResolutionBranchSignal {`
- .claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:311 token `function Join-WorktreeResolutionPath` MATCH: `function Join-WorktreeResolutionPath {`
- .claude/lib/worktree-resolution/WorktreeResolution.psm1:61 token `function Get-WorktreeResolutionGitEntryKind` MATCH: `function Get-WorktreeResolutionGitEntryKind {`
- .claude/lib/worktree-resolution/WorktreeResolution.psm1:84 token `function Get-WorktreeResolutionGitFileText` MATCH: `function Get-WorktreeResolutionGitFileText {`
- .claude/lib/worktree-resolution/WorktreeResolution.psm1:258 token `function Find-WorktreeResolutionRoot` MATCH: `function Find-WorktreeResolutionRoot {`
- .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:365 token `function Get-EpicOrchestrationReadinessFailure` MATCH: `function Get-EpicOrchestrationReadinessFailure {`
- scripts/powershell/PoshQC/settings/pester.runsettings.psd1:235 token `enforce-orchestration-preimplementation-gate-modes.ps1` MATCH: `'.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1'`
- scripts/powershell/PoshQC/settings/pester.runsettings.psd1:297 token `WorktreeItemResolution.psm1` MATCH: `'.claude/lib/worktree-resolution/WorktreeItemResolution.psm1'`
- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:36 token `enforce-orchestration-preimplementation-gate.ps1` MATCH: `".claude/hooks/enforce-orchestration-preimplementation-gate.ps1",`
- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:171 token `WorktreeItemResolution.psm1` MATCH: `".claude/lib/worktree-resolution/WorktreeItemResolution.psm1",`
- tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:133 token `5318b458` MATCH: `"5318b458a8ccfdf5270677a3b90ba130367a0857dea0acbcf4db1a8e68a97dec",`
- tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:137 token `75fb1667` MATCH: `"75fb1667174481091a2437ab67160da9ec1d20232ae1ea77882c450be1d6e2b5",`
- .claude/skills/epic-orchestrate/SKILL.md:285 token `## Epic-Level Checkpoint` MATCH: `## Epic-Level Checkpoint`
- .claude/skills/epic-orchestrate/SKILL.md:308 token `Checkpoint hygiene (issue #673)` MATCH: `**Checkpoint hygiene (issue #673).** The coordinating session never holds a per-feature checkpoint at its own root. Before the first child delegation of a run it moves any `artifacts/orchestration/orchestrator-state.json` at its root to `artifacts/orchestration/handoff/orchestrator-state.issue-<issue-num>.<yyyy-MM-ddTHH-mm>.json`, and writes none there for the rest of the run, because each item's checkpoint lives in that item's worktree. A gated call the coordinator issues on an item's behalf is resolved by the item's issue number and branch, never by the coordinator root.`
- .claude/agents/epic-orchestrator.md:129 token `## Checkpoint Persistence` MATCH: `## Checkpoint Persistence`
- .claude/agents/epic-planner.md:16 token `mcp__drm-copilot__validate_orchestration_artifacts` MATCH: `- "mcp__drm-copilot__validate_orchestration_artifacts"`
- .claude/agents/epic-planner.md:102 token `## Checkpoint Persistence` MATCH: `## Checkpoint Persistence`
- .claude/skills/epic-plan/SKILL.md:69 token `## Complexity Assessment` MATCH: `## Complexity Assessment`
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:197 token `D4 row 4` MATCH: `@{ Label = 'D4 row 4 - a pathless message-only integration invocation'; Command = 'git commit -m "epic scaffold"' }`
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:218 token `D4 row 12c` MATCH: `@{ Label = 'D4 row 12c - an output redirection in the segment'; Command = 'git add docs/features/epics/2026-08-24-sample-epic/epic.md > staged.txt' }`
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1:219 token `D4 row 12d` MATCH: `@{ Label = 'D4 row 12d - an input redirection in the segment'; Command = 'git add docs/features/epics/2026-08-24-sample-epic/epic.md < stage-list.txt' }`

## Line Counts

- .claude/hooks/enforce-orchestration-preimplementation-gate.ps1: 496 (expected 496) MATCH
- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: 441 (expected 441) MATCH
- .claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1: 480 (expected 480) MATCH
- .claude/hooks/enforce-pr-author-skill-helpers.ps1: 360 (expected 360) MATCH
- .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1: 126 (expected 126) MATCH
- .claude/hooks/enforce-model-routing-receipt.ps1: 275 (expected 275) MATCH
- .claude/lib/worktree-resolution/WorktreeResolution.psm1: 500 (expected 500) MATCH
- .claude/lib/orchestrator-state/OrchestratorState.psm1: 499 (expected 499) MATCH
- .claude/lib/worktree-resolution/WorktreeItemResolution.psm1: 392 (expected 392) MATCH
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1: 431 (expected 431) MATCH
- tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1: 438 (expected 438) MATCH
- tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1: 455 (expected 455) MATCH
- tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1: 122 (expected 122) MATCH
- tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1: 155 (expected 155) MATCH
- tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py: 487 (expected 487) MATCH
- tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1: 92 (expected 92) MATCH
- tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py: 346 (expected 346) MATCH

MISMATCH_COUNT: 0
