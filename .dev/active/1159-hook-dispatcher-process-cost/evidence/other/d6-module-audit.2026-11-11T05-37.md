# D6 module audit and -Force removal ([P3-T2])

Timestamp: 2026-11-11T05-37
Command: pwsh -NoProfile -File SCRATCH/issue-1159-d6audit.ps1 (dot-sources tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1; for each D6-set file of evidence/baseline/pretooluse-inventory.2026-11-10T03-48.md, Get-HookScriptEdge lists the guarded Import-Module edges; each imported .psm1 is parsed and every function body is searched for an assignment to a $script: or $global: variable, a mutating method call (Add, Remove, Clear, Insert, Set, TryAdd, Enqueue, Push, Pop, Sort, Reverse and similar) on a $script: variable, and Set-, New-, Clear- or Remove-Variable with -Scope Script, Global or 1); then pwsh -NoProfile -File SCRATCH/issue-1159-d6edit.ps1 removes -Force from every guarded import of a stateless module and copies each edited hook to its bundle hooks folder
EXIT_CODE: 0
Output Summary: 35 D6-set files, 113 guarded Import-Module edges (all carried -Force), 26 distinct in-repository modules audited: 0 stateful, so -Force was removed from all 113 edges in the 35 files and their 35 bundle mirrors, and no registry notes entry for a kept module was added. The 11 .codex/lib/discovery-validation paths (the destination layout of the two Codex discovery gates) do not exist in this repository; they are published from extensions/drm-copilot/resources/lib/discovery-validation, whose files are byte-identical to the audited .claude/lib/discovery-validation modules, so they are recorded as stateless.

## Modules

| Module | Classification | Evidence |
|---|---|---|
| `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/discovery-validation/DiscoveryAuthority.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/discovery-validation/DiscoveryAuthorization.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/discovery-validation/DiscoveryEncoding.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/discovery-validation/DiscoveryManifest.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/discovery-validation/DiscoveryObservation.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/discovery-validation/DiscoveryPayload.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/discovery-validation/DiscoveryPlanning.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/discovery-validation/DiscoveryRootGrant.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/discovery-validation/DiscoveryStart.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/discovery-validation/DiscoveryStartRecord.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/discovery-validation/DiscoveryToolRouting.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/docs/DocsCompleteGate.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/file-size-policy/FileSizePolicy.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/hook-payload/HookPayload.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/mermaid/MermaidValidation.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/worktree-resolution/EpicScopeReadiness.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/worktree-resolution/WorktreeResolution.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | stateless | no function mutates module-scope state |
| `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` | stateless | no function mutates module-scope state |
| `.codex/lib/discovery-validation/DiscoveryAuthority.psm1` | stateless (published copy of the .claude/lib module of the same name) | path absent in this repository; byte-identical bundle source |
| `.codex/lib/discovery-validation/DiscoveryAuthorization.psm1` | stateless (published copy of the .claude/lib module of the same name) | path absent in this repository; byte-identical bundle source |
| `.codex/lib/discovery-validation/DiscoveryEncoding.psm1` | stateless (published copy of the .claude/lib module of the same name) | path absent in this repository; byte-identical bundle source |
| `.codex/lib/discovery-validation/DiscoveryManifest.psm1` | stateless (published copy of the .claude/lib module of the same name) | path absent in this repository; byte-identical bundle source |
| `.codex/lib/discovery-validation/DiscoveryObservation.psm1` | stateless (published copy of the .claude/lib module of the same name) | path absent in this repository; byte-identical bundle source |
| `.codex/lib/discovery-validation/DiscoveryPayload.psm1` | stateless (published copy of the .claude/lib module of the same name) | path absent in this repository; byte-identical bundle source |
| `.codex/lib/discovery-validation/DiscoveryPlanning.psm1` | stateless (published copy of the .claude/lib module of the same name) | path absent in this repository; byte-identical bundle source |
| `.codex/lib/discovery-validation/DiscoveryRootGrant.psm1` | stateless (published copy of the .claude/lib module of the same name) | path absent in this repository; byte-identical bundle source |
| `.codex/lib/discovery-validation/DiscoveryStart.psm1` | stateless (published copy of the .claude/lib module of the same name) | path absent in this repository; byte-identical bundle source |
| `.codex/lib/discovery-validation/DiscoveryStartRecord.psm1` | stateless (published copy of the .claude/lib module of the same name) | path absent in this repository; byte-identical bundle source |
| `.codex/lib/discovery-validation/DiscoveryToolRouting.psm1` | stateless (published copy of the .claude/lib module of the same name) | path absent in this repository; byte-identical bundle source |

## Edited files (guarded imports changed)

- `.claude/hooks/check-powershell-test-purity.ps1`: 1 imports (HookPayload.psm1)
- `.claude/hooks/check-python-test-purity.ps1`: 1 imports (HookPayload.psm1)
- `.claude/hooks/enforce-checkpoint-monotonic.ps1`: 1 imports (HookPayload.psm1)
- `.claude/hooks/enforce-completion-consistency.ps1`: 1 imports (HookPayload.psm1)
- `.claude/hooks/enforce-discovery-artifact-gate.ps1`: 10 imports (DiscoveryAuthority.psm1, DiscoveryAuthorization.psm1, DiscoveryEncoding.psm1, DiscoveryObservation.psm1, DiscoveryPayload.psm1, DiscoveryRootGrant.psm1, DiscoveryStart.psm1, DiscoveryStartRecord.psm1, DiscoveryToolRouting.psm1, HookPayload.psm1)
- `.claude/hooks/enforce-discovery-planning-gate.ps1`: 9 imports (DiscoveryAuthority.psm1, DiscoveryAuthorization.psm1, DiscoveryEncoding.psm1, DiscoveryManifest.psm1, DiscoveryPayload.psm1, DiscoveryPlanning.psm1, DiscoveryStartRecord.psm1, DiscoveryToolRouting.psm1, HookPayload.psm1)
- `.claude/hooks/enforce-docs-complete-gate.ps1`: 2 imports (DocsCompleteGate.psm1, HookPayload.psm1)
- `.claude/hooks/enforce-docs-role-write-scope.ps1`: 1 imports (HookPayload.psm1)
- `.claude/hooks/enforce-epic-invocation-origin.ps1`: 1 imports (HookPayload.psm1)
- `.claude/hooks/enforce-epic-merge-gate-resolution.ps1`: 2 imports (WorktreeItemResolution.psm1, WorktreeRunResolution.psm1)
- `.claude/hooks/enforce-epic-merge-gate.ps1`: 1 imports (HookPayload.psm1)
- `.claude/hooks/enforce-epic-wave-barrier.ps1`: 2 imports (HookPayload.psm1, WorktreeRunResolution.psm1)
- `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1`: 2 imports (WorktreeRunRecordPath.psm1, WorktreeRunResolution.psm1)
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`: 2 imports (CleanupWorktreeManifest.psm1, HookPayload.psm1)
- `.claude/hooks/enforce-evidence-locations.ps1`: 1 imports (HookPayload.psm1)
- `.claude/hooks/enforce-feature-folder-order.ps1`: 1 imports (HookPayload.psm1)
- `.claude/hooks/enforce-file-size-limit.ps1`: 2 imports (FileSizePolicy.psm1, HookPayload.psm1)
- `.claude/hooks/enforce-mermaid-validation.ps1`: 2 imports (HookPayload.psm1, MermaidValidation.psm1)
- `.claude/hooks/enforce-model-routing-receipt.ps1`: 4 imports (CleanupWorktreeManifest.psm1, EpicScopeResolution.psm1, HookPayload.psm1, WorktreeItemResolution.psm1)
- `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`: 6 imports (EpicScopeReadiness.psm1, EpicScopeResolution.psm1, HookTargetWorktree.psm1, WorktreeItemResolution.psm1, WorktreeResolution.psm1, WorktreeRunResolution.psm1)
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`: 1 imports (HookPayload.psm1)
- `.claude/hooks/enforce-parallel-abandon-gate.ps1`: 1 imports (HookPayload.psm1)
- `.claude/hooks/enforce-parallel-cohort-barrier.ps1`: 3 imports (HookPayload.psm1, WorktreeItemResolution.psm1, WorktreeRunResolution.psm1)
- `.claude/hooks/enforce-parallel-drift-gate.ps1`: 3 imports (HookPayload.psm1, WorktreeItemResolution.psm1, WorktreeRunResolution.psm1)
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`: 4 imports (CleanupWorktreeManifest.psm1, HookPayload.psm1, WorktreeRunRecordPath.psm1, WorktreeRunResolution.psm1)
- `.claude/hooks/enforce-powershell-batch-budget.ps1`: 2 imports (HookPayload.psm1, HookTargetWorktree.psm1)
- `.claude/hooks/enforce-pr-author-skill.cleanup.ps1`: 1 imports (CleanupWorktreeManifest.psm1)
- `.claude/hooks/enforce-pr-author-skill.ps1`: 4 imports (HookPayload.psm1, OrchestratorState.psm1, OrchestratorStateUnconditional.psm1)
- `.claude/hooks/enforce-prd-feature-before-planner.ps1`: 3 imports (HookPayload.psm1, WorktreeItemResolution.psm1, WorktreeTargetResolution.psm1)
- `.claude/hooks/enforce-promotion-mcp-only.ps1`: 1 imports (HookPayload.psm1)
- `.claude/hooks/enforce-python-batch-budget.ps1`: 2 imports (HookPayload.psm1, HookTargetWorktree.psm1)
- `.claude/hooks/enforce-worktree-poetry-venv.ps1`: 1 imports (HookPayload.psm1)
- `.claude/hooks/validate-bash.ps1`: 1 imports (HookPayload.psm1)
- `.codex/hooks/enforce-discovery-artifact-gate.ps1`: 18 imports (DiscoveryAuthority.psm1, DiscoveryAuthorization.psm1, DiscoveryEncoding.psm1, DiscoveryObservation.psm1, DiscoveryPayload.psm1, DiscoveryRootGrant.psm1, DiscoveryStart.psm1, DiscoveryStartRecord.psm1, DiscoveryToolRouting.psm1)
- `.codex/hooks/enforce-discovery-planning-gate.ps1`: 16 imports (DiscoveryAuthority.psm1, DiscoveryAuthorization.psm1, DiscoveryEncoding.psm1, DiscoveryManifest.psm1, DiscoveryPayload.psm1, DiscoveryPlanning.psm1, DiscoveryStartRecord.psm1, DiscoveryToolRouting.psm1)
