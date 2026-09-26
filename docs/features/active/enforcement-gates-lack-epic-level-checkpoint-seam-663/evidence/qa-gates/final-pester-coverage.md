# Full Pester with Coverage ([P8-T7])

Pass: 2
Timestamp: 2026-09-25T20-07
Command: sh <SCRATCHPAD>/i663/run.sh p8-test  (fresh PowerShell 7 process: Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root $root -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1; exit code derived from the JUnit root failures and errors); then sh <SCRATCHPAD>/i663/run.sh p8-report  (reads both reports per plan section 5)
EXIT_CODE: 0
Output Summary: Console `Tests Passed: 5049, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0`. Root testsuites tests=5058 failures=0 errors=0 disabled=9, with no exclusion. Every section 4 name (including all 21 EpicScopeResolution names), the two D4 names, and the seven pre-existing hygiene names are Passed within their owning testsuites (NameCheckProblems: 0). All 35 required testsuite rows are present; 214 testsuites, none with failures or errors. Line coverage: all nine measured files at or above 85% (lowest: EpicScopeResolution.psm1 90.38%); overall line coverage 95.83%.

Timestamp note: `Timestamp:` is local time (UTC-4). The run started at 2026-09-26T00:07:36Z (20:07 local) and ended at 2026-09-26T00:11:18Z.

Report last-write times (both at or after `Timestamp:`):
- artifacts/pester/pester-junit.xml: 2026-09-26T00:11:17Z (20:11 local)
- artifacts/pester/powershell-coverage.xml: 2026-09-26T00:10:27Z (20:10 local)

Console line: `Tests Passed: 5049,` begins the sequence `Tests Passed: 5049, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0` (Pester prints these fields on separate lines). Coverage console line: `Covered 95.06% / 0%. 14,193 analyzed Commands in 109 Files.` (command coverage, informational).

Pass history: pass 1 (`final-pester-coverage.pass1.md`) ran green but failed the coverage floor for `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` (66.67%). Five rows were added to `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`; they appear below as the last five names of that testsuite (18 names checked in total: the 13 of section 4 and the 5 remediation rows).

## Nine-file line coverage (raw counters)

| File | Percent | covered | missed |
| --- | --- | --- | --- |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 96.97% | 160 | 5 |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 96.97% | 160 | 5 |
| .claude/hooks/enforce-pr-author-skill-helpers.ps1 | 97.00% | 97 | 3 |
| .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 | 93.55% | 29 | 2 |
| .claude/hooks/enforce-model-routing-receipt.ps1 | 95.52% | 64 | 3 |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 93.42% | 142 | 10 |
| .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 90.38% | 94 | 10 |
| .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 | 95.92% | 47 | 2 |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | 100.00% | 27 | 0 |

Result: PASS

## Report output (verbatim)

Testsuite rows below use the columns `| path | tests | failures | errors | passed |`.

```
JUnitLastWriteUtc: 2026-09-26T00:11:17.9681248Z
CoverageLastWriteUtc: 2026-09-26T00:10:27.9483132Z
Root: tests=5058 failures=0 errors=0 disabled=9
## Section 4 names
### tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1 (21 names)
  Passed | resolves epic scope when the --head branch equals integration_branch
  Passed | resolves epic scope when a branch: label equals integration_branch
  Passed | resolves epic scope for a command leg whose -C selector worktree HEAD equals integration_branch
  Passed | resolves epic scope for a command leg without a selector when the session-root HEAD equals integration_branch
  Passed | reports a merge in progress for a head-matched command leg when MERGE_HEAD exists
  Passed | is not epic scope when the epic checkpoint is absent
  Passed | is not epic scope when the epic checkpoint is unparseable
  Passed | is not epic scope when route_id is not epic
  Passed | is not epic scope when integration_branch is empty
  Passed | is not epic scope when the branch signal does not equal integration_branch
  Passed | is not epic scope when the worktree HEAD does not equal integration_branch
  Passed | is not epic scope and reads no checkpoint when there is no branch signal and head matching is off
  Passed | is not epic scope when the session root is not inside a worktree
  Passed | returns an absolute checkpoint path composed from the session worktree root
  Passed | never takes the checkpoint path from text that names another epic checkpoint
  Passed | reads the epic checkpoint through the seam exactly once per resolution
  Passed | returns null checkpoint text when the checkpoint file is absent
  Passed | reads the HEAD branch of a linked worktree through its gitdir file
  Passed | reads the HEAD branch of a main checkout through its git directory
  Passed | returns no HEAD branch for a detached HEAD
  Passed | probes MERGE_HEAD in the worktree git directory
### tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1 (14 names)
  Passed | PR-creation readiness passes when every feature is merged or worktree_removed
  Passed | PR-creation readiness names checkpoint-absent for a null checkpoint
  Passed | PR-creation readiness names route_id for a route_id other than epic
  Passed | PR-creation readiness names integration_branch for a --head branch that differs from integration_branch
  Passed | PR-creation readiness names features for an empty features array
  Passed | PR-creation readiness names merge_status for a feature whose merge_status is pr_open
  Passed | command-leg readiness passes for a ready epic checkpoint while a merge is in progress
  Passed | command-leg readiness names checkpoint-absent for a null checkpoint
  Passed | command-leg readiness names route_id for a route_id other than epic
  Passed | command-leg readiness names epic_feature_folder for a missing epic_feature_folder
  Passed | command-leg readiness names epic_manifest_path for an epic_manifest_path outside docs/features/epics/
  Passed | command-leg readiness names integration_branch for a missing integration_branch
  Passed | command-leg readiness names features for an empty features array
  Passed | command-leg readiness names merge-in-progress for no merge in progress
### tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 (5 names)
  Passed | epic scope allows gh pr create --head integration_branch --base main when every feature is merged or worktree_removed
  Passed | epic scope denies when a feature has a non-terminal merge_status and names the epic checkpoint and merge_status
  Passed | epic scope denies when features is empty and names the epic checkpoint and features
  Passed | without an epic checkpoint the call takes the unchanged per-feature path and is denied by its resolution
  Passed | a per-feature pull request whose --head differs from integration_branch gets the same decision and reason as with no epic checkpoint
### tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 (5 names)
  Passed | issue #663 epic scope allows --base main end-to-end
  Passed | issue #663 epic scope denies --base development with EPIC_BASE_BRANCH_MISMATCH
  Passed | issue #663 epic scope denies --base epic/sample-epic-integration with EPIC_BASE_BRANCH_MISMATCH
  Passed | issue #663 epic scope denies a missing --base with EPIC_BASE_BRANCH_MISMATCH
  Passed | issue #663 epic scope reads the epic checkpoint once per gh pr create call
### tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 (4 names)
  Passed | epic scope allows Agent(pr-author) when the epic checkpoint records a pr-author receipt
  Passed | epic scope denies Agent(pr-author) with MODEL_ROUTING_RECEIPT_BLOCKED when the epic checkpoint has no pr-author receipt
  Passed | a per-feature delegation is denied with the unchanged per-feature reason when its checkpoint lacks the receipt
  Passed | a per-feature delegation is allowed from the per-feature checkpoint when the epic branch does not match
### tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 (18 names)
  Passed | epic scope allows git add of a production path while a merge is in progress
  Passed | epic scope denies git add of a production path when no merge is in progress and names the epic checkpoint
  Passed | epic scope denies git add of a production path when epic_feature_folder is missing and names it
  Passed | epic scope denies git add of a production path when epic_manifest_path is missing and names it
  Passed | epic scope denies git add of a production path when features is missing and names it
  Passed | a checkpoint missing route_id is not epic scope and the command leg denies through the single-feature path
  Passed | a checkpoint missing integration_branch is not epic scope and the command leg denies through the single-feature path
  Passed | epic scope resolves the -C selector worktree for the command leg
  Passed | epic scope allows an Edit of a production path while a merge is in progress
  Passed | epic scope denies a Write of a production path when no merge is in progress
  Passed | without an epic checkpoint the command leg returns the unchanged single-feature decision and reason
  Passed | without an epic checkpoint the path leg returns the unchanged single-feature decision and reason
  Passed | an epic checkpoint whose integration_branch differs from HEAD leaves the command leg on the single-feature path
  Passed | issue #663 the relocated epic read seam returns an empty string when the epic checkpoint file is absent
  Passed | issue #663 the relocated epic read seam returns the raw epic checkpoint text when the file exists
  Passed | issue #663 the relocated parallel read seam returns an empty string when the parallel checkpoint file is absent
  Passed | issue #663 the relocated parallel read seam returns the raw parallel checkpoint text when the file exists
  Passed | issue #663 the epic-scope decision returns null without resolving when the call carries neither a command nor a path
### tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 (10 names)
  Passed | issue #663 exempts a double-quoted message carrying a Co-Authored-By trailer and an apostrophe
  Passed | issue #663 exempts a single-quoted message carrying angle brackets
  Passed | issue #663 denies the single-quoted apostrophe idiom
  Passed | issue #663 denies a command substitution inside a double-quoted message
  Passed | issue #663 denies a variable expansion inside a double-quoted message
  Passed | issue #663 denies a backtick substitution inside a double-quoted message
  Passed | issue #663 denies a pathless commit whose message carries angle brackets
  Passed | issue #663 denies an unquoted output redirection after a quoted message carrying angle brackets
  Passed | denies D4 row 12c - an output redirection in the segment
  Passed | denies D4 row 12d - an input redirection in the segment
### tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 (8 names)
  Passed | issue #663 exempts a double-quoted message carrying a Co-Authored-By trailer and an apostrophe
  Passed | issue #663 exempts a single-quoted message carrying angle brackets
  Passed | issue #663 denies the single-quoted apostrophe idiom
  Passed | issue #663 denies a command substitution inside a double-quoted message
  Passed | issue #663 denies a variable expansion inside a double-quoted message
  Passed | issue #663 denies a backtick substitution inside a double-quoted message
  Passed | issue #663 denies a pathless commit whose message carries angle brackets
  Passed | issue #663 denies an unquoted output redirection after a quoted message carrying angle brackets
### tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 (2 names)
  Passed | issue #663 does not intercept a completion-asserting Write to epic-orchestrator-state.json
  Passed | issue #663 still denies a per-feature checkpoint whose feature-folder is under docs/features/epics/
### tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1 (11 names)
  Passed | epic-plan skill promotes an epic-level issue and records epic_issue_num (issue #663)
  Passed | epic-planner agent lists the promotion tool and records epic_issue_num (issue #663)
  Passed | epic-orchestrate skill states the integration-PR checkpoint shape and receipt location (issue #663)
  Passed | epic-orchestrator agent lists epic_issue_num and model_routing_receipts in its checkpoint fields (issue #663)
  Passed | orchestrate skill archives a foreign per-feature checkpoint to the handoff folder
  Passed | parallel-orchestrate skill keeps the coordinator root free of a per-feature checkpoint
  Passed | epic-orchestrate skill keeps the coordinator root free of a per-feature checkpoint
  Passed | orchestrate skill requires the canonical issue line on every receipt-gated delegation
  Passed | orchestrate skill requires a branch label on every receipt-gated delegation
  Passed | orchestrate skill names every subagent type the model-routing gate receipt-gates
  Passed | orchestrate skill names both gates that identify the item from the delegation prompt
NameCheckProblems: 0
## Required testsuite rows
  present (1) | tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1
  present (1) | tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1
  present (1) | tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1
  present (1) | tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1
  present (1) | tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1
  present (1) | tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1
  present (1) | tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1
  present (1) | tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1
  present (1) | tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1
  present (1) | tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1
RequiredRowsMissing: 0
## All testsuite rows
| tests/scripts/claude-hooks/check-powershell-test-purity.Tests.ps1 | 12 | 0 | 0 | 12 |
| tests/scripts/claude-hooks/check-python-test-purity.Tests.ps1 | 11 | 0 | 0 | 11 |
| tests/scripts/claude-hooks/CleanupWorktreeManifestGateMatrix.Tests.ps1 | 82 | 0 | 0 | 82 |
| tests/scripts/claude-hooks/enforce-checkpoint-monotonic.Tests.ps1 | 24 | 0 | 0 | 24 |
| tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1 | 4 | 0 | 0 | 4 |
| tests/scripts/claude-hooks/enforce-completion-consistency.Payload.Tests.ps1 | 7 | 0 | 0 | 7 |
| tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1 | 47 | 0 | 0 | 47 |
| tests/scripts/claude-hooks/enforce-discovery-artifact-gate.Tests.ps1 | 19 | 0 | 0 | 19 |
| tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | 4 | 0 | 0 | 4 |
| tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1 | 30 | 0 | 0 | 30 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1 | 15 | 0 | 0 | 15 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.AuthorizationFields.Tests.ps1 | 37 | 0 | 0 | 37 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1 | 56 | 0 | 0 | 56 |
| tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1 | 12 | 0 | 0 | 12 |
| tests/scripts/claude-hooks/enforce-epic-wave-barrier.Tests.ps1 | 30 | 0 | 0 | 30 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 | 50 | 0 | 0 | 50 |
| tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1 | 5 | 0 | 0 | 5 |
| tests/scripts/claude-hooks/enforce-evidence-locations.Tests.ps1 | 18 | 0 | 0 | 18 |
| tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1 | 22 | 0 | 0 | 22 |
| tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1 | 30 | 0 | 0 | 30 |
| tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1 | 4 | 0 | 0 | 4 |
| tests/scripts/claude-hooks/enforce-model-routing-receipt.Tests.ps1 | 15 | 0 | 0 | 15 |
| tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1 | 20 | 0 | 0 | 20 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1 | 33 | 0 | 0 | 33 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1 | 7 | 0 | 0 | 7 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1 | 2 | 0 | 0 | 2 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | 87 | 0 | 0 | 87 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1 | 113 | 0 | 0 | 113 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1 | 18 | 0 | 0 | 18 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1 | 35 | 0 | 0 | 35 |
| tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TriggerScoping.Tests.ps1 | 19 | 0 | 0 | 19 |
| tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 | 24 | 0 | 0 | 24 |
| tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 | 7 | 0 | 0 | 7 |
| tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Payload.Tests.ps1 | 7 | 0 | 0 | 7 |
| tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1 | 52 | 0 | 0 | 52 |
| tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1 | 26 | 0 | 0 | 26 |
| tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 | 48 | 0 | 0 | 48 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.EpicAuthorization.Tests.ps1 | 11 | 0 | 0 | 11 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1 | 49 | 0 | 0 | 49 |
| tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1 | 3 | 0 | 0 | 3 |
| tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1 | 36 | 0 | 0 | 36 |
| tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1 | 14 | 0 | 0 | 14 |
| tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.TriggerScoping.Tests.ps1 | 2 | 0 | 0 | 2 |
| tests/scripts/claude-hooks/enforce-pr-author-skill.EpicScope.Tests.ps1 | 5 | 0 | 0 | 5 |
| tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1 | 3 | 0 | 0 | 3 |
| tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1 | 9 | 0 | 0 | 9 |
| tests/scripts/claude-hooks/enforce-pr-author-skill.TargetResolution.Tests.ps1 | 5 | 0 | 0 | 5 |
| tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 | 43 | 0 | 0 | 43 |
| tests/scripts/claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1 | 22 | 0 | 0 | 22 |
| tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1 | 18 | 0 | 0 | 18 |
| tests/scripts/claude-hooks/enforce-prd-feature-before-planner.FolderResolution.Tests.ps1 | 25 | 0 | 0 | 25 |
| tests/scripts/claude-hooks/enforce-prd-feature-before-planner.IdentityResolution.Tests.ps1 | 13 | 0 | 0 | 13 |
| tests/scripts/claude-hooks/enforce-prd-feature-before-planner.TargetResolution.Tests.ps1 | 24 | 0 | 0 | 24 |
| tests/scripts/claude-hooks/enforce-prd-feature-before-planner.Tests.ps1 | 47 | 0 | 0 | 47 |
| tests/scripts/claude-hooks/enforce-promotion-mcp-only.Tests.ps1 | 29 | 0 | 0 | 29 |
| tests/scripts/claude-hooks/enforce-promotion-mcp-only.TriggerScoping.Tests.ps1 | 8 | 0 | 0 | 8 |
| tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1 | 35 | 0 | 0 | 35 |
| tests/scripts/claude-hooks/hook-command-invocation.Tests.ps1 | 44 | 0 | 0 | 44 |
| tests/scripts/claude-hooks/hook-command-parser.AcceptanceCases.Tests.ps1 | 11 | 0 | 0 | 11 |
| tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1 | 47 | 0 | 0 | 47 |
| tests/scripts/claude-hooks/persist-session-id.Tests.ps1 | 16 | 0 | 0 | 16 |
| tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1 | 77 | 0 | 0 | 77 |
| tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1 | 15 | 0 | 0 | 15 |
| tests/scripts/claude-hooks/validate-bash.Tests.ps1 | 26 | 0 | 0 | 26 |
| tests/scripts/claude-hooks/validate-bash.TriggerScoping.Tests.ps1 | 16 | 0 | 0 | 16 |
| tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1 | 16 | 0 | 0 | 16 |
| tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1 | 4 | 0 | 0 | 4 |
| tests/scripts/claude-hooks/validate-executor-output.Tests.ps1 | 13 | 0 | 0 | 13 |
| tests/scripts/claude-hooks/validate-feature-review-coverage.Tests.ps1 | 4 | 0 | 0 | 4 |
| tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1 | 17 | 0 | 0 | 17 |
| tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | 7 | 0 | 0 | 7 |
| tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1 | 6 | 0 | 0 | 6 |
| tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1 | 27 | 0 | 0 | 27 |
| tests/scripts/claude-hooks/validate-planner-output.Tests.ps1 | 24 | 0 | 0 | 24 |
| tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1 | 15 | 0 | 0 | 15 |
| tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1 | 13 | 0 | 0 | 13 |
| tests/scripts/claude-hooks/validate-required-artifact-output.Tests.ps1 | 3 | 0 | 0 | 3 |
| tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1 | 34 | 0 | 0 | 34 |
| tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 | 6 | 0 | 0 | 6 |
| tests/scripts/claude-lib/blast-radius/BlastRadius.Conflict.Tests.ps1 | 32 | 0 | 0 | 32 |
| tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1 | 5 | 0 | 0 | 5 |
| tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1 | 4 | 0 | 0 | 4 |
| tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1 | 80 | 0 | 0 | 80 |
| tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1 | 39 | 0 | 0 | 39 |
| tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 | 17 | 0 | 0 | 17 |
| tests/scripts/claude-lib/blast-radius/BlastRadius.Validation.Tests.ps1 | 31 | 0 | 0 | 31 |
| tests/scripts/claude-lib/blast-radius/BlastRadiusConfig.Tests.ps1 | 49 | 0 | 0 | 49 |
| tests/scripts/claude-lib/blast-radius/BlastRadiusConflict.Tests.ps1 | 13 | 0 | 0 | 13 |
| tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1 | 61 | 0 | 0 | 61 |
| tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Tests.ps1 | 21 | 0 | 0 | 21 |
| tests/scripts/claude-lib/blast-radius/BlastRadiusGlob.Tests.ps1 | 49 | 0 | 0 | 49 |
| tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1 | 15 | 0 | 0 | 15 |
| tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1 | 16 | 0 | 0 | 16 |
| tests/scripts/claude-lib/cleanup-manifest/CleanupWorktreeManifest.Tests.ps1 | 7 | 0 | 0 | 7 |
| tests/scripts/claude-lib/codex-routing/CodexDeployment.Parity.Tests.ps1 | 27 | 0 | 0 | 27 |
| tests/scripts/claude-lib/codex-routing/CodexRouting.Manifest.Tests.ps1 | 5 | 0 | 0 | 5 |
| tests/scripts/claude-lib/codex-routing/CodexTopology.Parity.Tests.ps1 | 36 | 0 | 0 | 36 |
| tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Manifest.Tests.ps1 | 4 | 0 | 0 | 4 |
| tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.Tests.ps1 | 40 | 0 | 0 | 40 |
| tests/scripts/claude-lib/discovery-validation/DiscoveryValidation.VersionFloor.Tests.ps1 | 13 | 0 | 0 | 13 |
| tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1 | 53 | 0 | 0 | 53 |
| tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1 | 100 | 0 | 0 | 100 |
| tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1 | 70 | 0 | 0 | 70 |
| tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1 | 36 | 0 | 0 | 36 |
| tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1 | 43 | 0 | 0 | 43 |
| tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1 | 22 | 0 | 0 | 22 |
| tests/scripts/claude-lib/model-routing/Get-ComplexityFloor.Tests.ps1 | 19 | 0 | 0 | 19 |
| tests/scripts/claude-lib/model-routing/ModelRouting.Manifest.Tests.ps1 | 2 | 0 | 0 | 2 |
| tests/scripts/claude-lib/model-routing/ModelRouting.Parity.Tests.ps1 | 12 | 0 | 0 | 12 |
| tests/scripts/claude-lib/model-routing/Resolve-DelegationModel.Tests.ps1 | 20 | 0 | 0 | 20 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1 | 6 | 0 | 0 | 6 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1 | 46 | 0 | 0 | 46 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1 | 2 | 0 | 0 | 2 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCheckpointValue.Tests.ps1 | 47 | 0 | 0 | 47 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1 | 29 | 0 | 0 | 29 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.Tests.ps1 | 31 | 0 | 0 | 31 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1 | 20 | 0 | 0 | 20 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1 | 41 | 0 | 0 | 41 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateModelReceipts.Tests.ps1 | 31 | 0 | 0 | 31 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1 | 40 | 0 | 0 | 40 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1 | 37 | 0 | 0 | 37 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingMatrix.Tests.ps1 | 31 | 0 | 0 | 31 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1 | 19 | 0 | 0 | 19 |
| tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Manifest.Tests.ps1 | 3 | 0 | 0 | 3 |
| tests/scripts/claude-lib/project-file-merge/ProjectFileMerge.Tests.ps1 | 26 | 0 | 0 | 26 |
| tests/scripts/claude-lib/project-file-merge/ProjectFileMergeGrammar.Tests.ps1 | 17 | 0 | 0 | 17 |
| tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1 | 10 | 0 | 0 | 10 |
| tests/scripts/claude-lib/requirements/GeneratedDocumentCounters.Tests.ps1 | 1 | 0 | 0 | 1 |
| tests/scripts/claude-lib/worktree-resolution/EpicScopeReadiness.Tests.ps1 | 14 | 0 | 0 | 14 |
| tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1 | 21 | 0 | 0 | 21 |
| tests/scripts/claude-lib/worktree-resolution/WorktreeItemResolution.Tests.ps1 | 27 | 0 | 0 | 27 |
| tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1 | 16 | 0 | 0 | 16 |
| tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Tests.ps1 | 48 | 0 | 0 | 48 |
| tests/scripts/claude-lib/worktree-resolution/WorktreeTargetResolution.Tests.ps1 | 51 | 0 | 0 | 51 |
| tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1 | 11 | 0 | 0 | 11 |
| tests/scripts/claude-runtime/claude-architecture-doc.Tests.ps1 | 6 | 0 | 0 | 6 |
| tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1 | 6 | 0 | 0 | 6 |
| tests/scripts/claude-runtime/claude-settings.Tests.ps1 | 5 | 0 | 0 | 5 |
| tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1 | 8 | 0 | 0 | 8 |
| tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 | 27 | 0 | 0 | 27 |
| tests/scripts/claude-runtime/legacy-discovery-agent-roles.Tests.ps1 | 15 | 0 | 0 | 15 |
| tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1 | 5 | 0 | 0 | 5 |
| tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1 | 48 | 0 | 0 | 48 |
| tests/scripts/codex-hooks/codex-completion-consistency-hook.Tests.ps1 | 9 | 0 | 0 | 9 |
| tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1 | 12 | 0 | 0 | 12 |
| tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 | 10 | 0 | 0 | 10 |
| tests/scripts/codex-hooks/codex-evidence-and-checkpoint-hooks.Tests.ps1 | 50 | 0 | 0 | 50 |
| tests/scripts/codex-hooks/codex-planning-only-hook.Tests.ps1 | 10 | 0 | 0 | 10 |
| tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1 | 35 | 0 | 0 | 35 |
| tests/scripts/codex-hooks/codex-pretooluse-file-mapping.Tests.ps1 | 37 | 0 | 0 | 37 |
| tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 | 6 | 0 | 0 | 6 |
| tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1 | 56 | 0 | 0 | 56 |
| tests/scripts/codex-hooks/codex-test-purity-hooks.Tests.ps1 | 36 | 0 | 0 | 36 |
| tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1 | 21 | 0 | 0 | 21 |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1 | 28 | 0 | 0 | 28 |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-decision-surface.Tests.ps1 | 13 | 0 | 0 | 13 |
| tests/scripts/codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1 | 7 | 0 | 0 | 7 |
| tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | 20 | 0 | 0 | 20 |
| tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1 | 5 | 0 | 0 | 5 |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1 | 113 | 0 | 0 | 113 |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1 | 55 | 0 | 0 | 55 |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1 | 11 | 0 | 0 | 11 |
| tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1 | 23 | 0 | 0 | 23 |
| tests/scripts/codex-hooks/enforce-promotion-mcp-only-decision-surface.Tests.ps1 | 18 | 0 | 0 | 18 |
| tests/scripts/codex-hooks/enforce-promotion-mcp-only-trigger-scoping.Tests.ps1 | 8 | 0 | 0 | 8 |
| tests/scripts/codex-hooks/epic-child-launch-attestation.Tests.ps1 | 12 | 0 | 0 | 12 |
| tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | 19 | 0 | 0 | 19 |
| tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | 22 | 0 | 0 | 22 |
| tests/scripts/codex-hooks/epic-execution-gates.Tests.ps1 | 50 | 0 | 0 | 50 |
| tests/scripts/codex-hooks/epic-provenance.Tests.ps1 | 29 | 0 | 0 | 29 |
| tests/scripts/codex-hooks/epic-wave-launch-binding.Tests.ps1 | 10 | 0 | 0 | 10 |
| tests/scripts/codex-hooks/hook-command-invocation.Tests.ps1 | 39 | 0 | 0 | 39 |
| tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1 | 46 | 0 | 0 | 46 |
| tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1 | 43 | 0 | 0 | 43 |
| tests/scripts/codex-hooks/model-profile-attestation.Tests.ps1 | 9 | 0 | 0 | 9 |
| tests/scripts/codex-hooks/validate-bash-decision-surface.Tests.ps1 | 37 | 0 | 0 | 37 |
| tests/scripts/codex-hooks/validate-bash-trigger-scoping.Tests.ps1 | 8 | 0 | 0 | 8 |
| tests/scripts/dev-tools/activate.Tests.ps1 | 53 | 0 | 0 | 53 |
| tests/scripts/dev-tools/agents-attribution.Tests.ps1 | 1 | 0 | 0 | 1 |
| tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1 | 5 | 0 | 0 | 5 |
| tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1 | 25 | 0 | 0 | 25 |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1 | 11 | 0 | 0 | 11 |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.ChecksWait.Tests.ps1 | 6 | 0 | 0 | 6 |
| tests/scripts/dev-tools/Invoke-FullReleaseFlow.Tests.ps1 | 15 | 0 | 0 | 15 |
| tests/scripts/dev-tools/Invoke-MarketplacePublish.Tests.ps1 | 18 | 0 | 0 | 18 |
| tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1 | 8 | 0 | 0 | 8 |
| tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1 | 21 | 0 | 0 | 21 |
| tests/scripts/dev-tools/Invoke-ReleaseTagPushCallSiteBudgets.Tests.ps1 | 3 | 0 | 0 | 3 |
| tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1 | 29 | 0 | 0 | 29 |
| tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1 | 10 | 0 | 0 | 10 |
| tests/scripts/dev-tools/link-feature-docs.Tests.ps1 | 21 | 0 | 0 | 21 |
| tests/scripts/dev-tools/link-parent-child.Tests.ps1 | 22 | 0 | 0 | 22 |
| tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1 | 35 | 0 | 0 | 33 |
| tests/scripts/dev-tools/new-potential-entry.TemplateRoot.Tests.ps1 | 2 | 0 | 0 | 2 |
| tests/scripts/dev-tools/new-potential-entry.Tests.ps1 | 44 | 0 | 0 | 44 |
| tests/scripts/dev-tools/post-codex-worktree-session.Tests.ps1 | 13 | 0 | 0 | 13 |
| tests/scripts/dev-tools/publish-sideloaded-extension.Tests.ps1 | 7 | 0 | 0 | 7 |
| tests/scripts/dev-tools/run-actionlint.Tests.ps1 | 35 | 0 | 0 | 35 |
| tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1 | 20 | 0 | 0 | 20 |
| tests/scripts/dev-tools/tree.Tests.ps1 | 29 | 0 | 0 | 29 |
| tests/scripts/orchestration/Invoke-CiGateParser.Tests.ps1 | 15 | 0 | 0 | 15 |
| tests/scripts/powershell/Publish-DrmCopilotExtension.Tests.ps1 | 15 | 0 | 0 | 15 |
| tests/scripts/powershell/PoshQC/Get-PoshQCFileList.Excludes.Tests.ps1 | 1 | 0 | 0 | 1 |
| tests/scripts/powershell/PoshQC/PoshQC.Comprehensive.Tests.ps1 | 33 | 0 | 0 | 26 |
| tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1 | 5 | 0 | 0 | 5 |
| tests/scripts/powershell/PoshQC/PoshQC.ScanConfig.Tests.ps1 | 12 | 0 | 0 | 12 |
| tests/scripts/powershell/PoshQC/PoshQC.ScanFolders.Tests.ps1 | 17 | 0 | 0 | 17 |
| tests/scripts/powershell/PoshQC/PoshQC.TestingCoveragePruning.Tests.ps1 | 4 | 0 | 0 | 4 |
| tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1 | 5 | 0 | 0 | 5 |
| tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeSummary.Tests.ps1 | 3 | 0 | 0 | 3 |
| tests/scripts/powershell/PoshQC/PoshQC.TestingSeamDefaults.Tests.ps1 | 4 | 0 | 0 | 4 |
| tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1 | 34 | 0 | 0 | 34 |
| tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1 | 6 | 0 | 0 | 6 |
| tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1 | 4 | 0 | 0 | 4 |
TestsuiteCount: 214
TestsuitesWithFailuresOrErrors: 0
OverallLine: 95.83% covered=9828 missed=428
File .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: 96.97% covered=160 missed=5 lineElements=165
File .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: 96.97% covered=160 missed=5 lineElements=165
File .claude/hooks/enforce-pr-author-skill-helpers.ps1: 97.00% covered=97 missed=3 lineElements=100
File .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1: 93.55% covered=29 missed=2 lineElements=31
File .claude/hooks/enforce-model-routing-receipt.ps1: 95.52% covered=64 missed=3 lineElements=67
File .claude/hooks/enforce-orchestration-preimplementation-gate.ps1: 93.42% covered=142 missed=10 lineElements=152
File .claude/lib/worktree-resolution/EpicScopeResolution.psm1: 90.38% covered=94 missed=10 lineElements=104
File .claude/lib/worktree-resolution/EpicScopeReadiness.psm1: 95.92% covered=47 missed=2 lineElements=49
File .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1: 100.00% covered=27 missed=0 lineElements=27
CoverageFilesBelow85OrUnmeasured: 0
REPORT_EXIT_CODE: 0
PROCESS_EXIT_CODE: 0
```
