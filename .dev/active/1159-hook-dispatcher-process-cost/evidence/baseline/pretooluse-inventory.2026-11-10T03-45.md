# PreToolUse inventory derived after the execution-start merge ([P0-T2])

Timestamp: 2026-11-10T03-45
Command: read `.claude/settings.json` (`hooks.PreToolUse`) and `.codex/config.toml` (`[[hooks.PreToolUse]]` tables) at merge base 228e6f8c4606e53f36963dc9aa57d71b4882b49e; `sh SCRATCH/issue-1159-derive-sets.sh` (dot-sources `tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1`, uses `Get-HookRegistration`, `Get-HookDependencyClosure`, `Get-HookScriptEdge`); `grep -rl PreToolUse` over `tests/`, `.claude/lib/`, `.claude/hooks/`, `.codex/hooks/`, `scripts/` filtered to files that also name `settings.json` or `config.toml`
EXIT_CODE: 0
Output Summary: Claude 5 groups / 32 hook commands; Codex 4 groups / 23 hook commands, timeout sum 690. Per-call counts: Claude Bash 12, Write 13, Agent 9, mcp__drm-copilot__run_discovery_repo_inventory 1; Codex Bash 12, apply_patch 15, Agent 2, mcp__drm-copilot__run_discovery_repo_inventory 6. D13 set: 7 hooks. D6 set: 41 files. Arrived consumers: none.

## Claude (`.claude/settings.json`, `hooks.PreToolUse`)

Matcher semantics: a matcher made only of letters, digits, `_`, `-`, space, `,` and `|` is an exact string or exact list; otherwise it is an unanchored regex.

### Group 1 — matcher `Bash` (exact)

1. `pwsh -NoProfile -File .claude/hooks/validate-bash.ps1`
2. `pwsh -NoProfile -File .claude/hooks/enforce-promotion-mcp-only.ps1`
3. `pwsh -NoProfile -File .claude/hooks/enforce-pr-author-skill.ps1`
4. `pwsh -NoProfile -File .claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
5. `pwsh -NoProfile -File .claude/hooks/enforce-epic-merge-gate.ps1`
6. `pwsh -NoProfile -File .claude/hooks/enforce-docs-complete-gate.ps1`
7. `pwsh -NoProfile -File .claude/hooks/enforce-epic-worktree-removal-gate.ps1`
8. `pwsh -NoProfile -File .claude/hooks/enforce-parallel-worktree-removal-gate.ps1`
9. `pwsh -NoProfile -File .claude/hooks/enforce-parallel-abandon-gate.ps1`
10. `pwsh -NoProfile -File .claude/hooks/enforce-worktree-poetry-venv.ps1`

### Group 2 — matcher `Write|Edit` (exact list)

1. `pwsh -NoProfile -File .claude/hooks/check-python-test-purity.ps1`
2. `pwsh -NoProfile -File .claude/hooks/enforce-python-batch-budget.ps1`
3. `pwsh -NoProfile -File .claude/hooks/check-powershell-test-purity.ps1`
4. `pwsh -NoProfile -File .claude/hooks/enforce-powershell-batch-budget.ps1`
5. `pwsh -NoProfile -File .claude/hooks/enforce-evidence-locations.ps1`
6. `pwsh -NoProfile -File .claude/hooks/enforce-file-size-limit.ps1`
7. `pwsh -NoProfile -File .claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
8. `pwsh -NoProfile -File .claude/hooks/enforce-feature-folder-order.ps1`
9. `pwsh -NoProfile -File .claude/hooks/enforce-checkpoint-monotonic.ps1`
10. `pwsh -NoProfile -File .claude/hooks/enforce-completion-consistency.ps1`
11. `pwsh -NoProfile -File .claude/hooks/enforce-mermaid-validation.ps1`

### Group 3 — matcher `Bash|Write|Edit|MultiEdit|NotebookEdit|Agent|Task|WebFetch|WebSearch|mcp__.*` (regex)

1. `pwsh -NoProfile -File .claude/hooks/enforce-discovery-artifact-gate.ps1`

### Group 4 — matcher `Agent` (exact)

1. `pwsh -NoProfile -File .claude/hooks/enforce-prd-feature-before-planner.ps1`
2. `pwsh -NoProfile -File .claude/hooks/enforce-discovery-planning-gate.ps1`
3. `pwsh -NoProfile -File .claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
4. `pwsh -NoProfile -File .claude/hooks/enforce-epic-wave-barrier.ps1`
5. `pwsh -NoProfile -File .claude/hooks/enforce-model-routing-receipt.ps1`
6. `pwsh -NoProfile -File .claude/hooks/enforce-epic-invocation-origin.ps1`
7. `pwsh -NoProfile -File .claude/hooks/enforce-parallel-cohort-barrier.ps1`
8. `pwsh -NoProfile -File .claude/hooks/enforce-parallel-drift-gate.ps1`

### Group 5 — matcher `Write|Edit|MultiEdit|NotebookEdit|Bash` (exact list)

1. `pwsh -NoProfile -File .claude/hooks/enforce-docs-role-write-scope.ps1`

### Claude per-call hook counts

| Tool name | Groups admitting | Hook processes per call |
|---|---|---|
| `Bash` | 1, 3, 5 | 12 |
| `Write` | 2, 3, 5 | 13 |
| `Agent` | 3, 4 | 9 |
| `mcp__drm-copilot__run_discovery_repo_inventory` | 3 | 1 |

## Codex (`.codex/config.toml`, `[[hooks.PreToolUse]]`)

Matcher semantics: regex as written; `apply_patch` is additionally matched when the matcher admits `Edit` or `Write`. Every hook command is `pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/.codex/hooks/<leaf>"` in both `command` and `command_windows`.

### Group 1 — matcher `^Bash$`

1. `validate-bash.ps1` (timeout 30)
2. `enforce-promotion-mcp-only.ps1` (timeout 30)
3. `enforce-orchestration-preimplementation-gate.ps1` (timeout 30)
4. `enforce-epic-merge-gate.ps1` (timeout 30)
5. `enforce-epic-worktree-removal-gate.ps1` (timeout 30)
6. `enforce-worktree-poetry-venv.ps1` (timeout 30)

### Group 2 — matcher `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$`

1. `enforce-discovery-artifact-gate.ps1` (timeout 30)
2. `enforce-epic-root-invocation.ps1` (timeout 30)
3. `enforce-codex-model-routing.ps1` (timeout 30)
4. `enforce-epic-planning-only.ps1` (timeout 30)
5. `enforce-epic-wave-barrier.ps1` (timeout 30)
6. `enforce-epic-child-worktree-binding.ps1` (timeout 30)

### Group 3 — matcher `^(apply_patch|Edit|Write)$`

1. `check-python-test-purity.ps1` (timeout 30)
2. `enforce-python-batch-budget.ps1` (timeout 30)
3. `check-powershell-test-purity.ps1` (timeout 30)
4. `enforce-powershell-batch-budget.ps1` (timeout 30)
5. `enforce-evidence-locations.ps1` (timeout 30)
6. `enforce-file-size-limit.ps1` (timeout 30)
7. `enforce-orchestration-preimplementation-gate.ps1` (timeout 30)
8. `enforce-checkpoint-monotonic.ps1` (timeout 30)
9. `enforce-completion-consistency.ps1` (timeout 30)

### Group 4 — matcher `^(Agent|Task|spawn_agent|run_subagent|delegate)$`

1. `enforce-discovery-artifact-gate.ps1` (timeout 30)
2. `enforce-discovery-planning-gate.ps1` (timeout 30)

Codex timeout sum: 23 hooks x 30 = 690.

### Codex per-call hook counts

| Tool name | Groups admitting | Hook processes per call |
|---|---|---|
| `Bash` | 1, 2 | 12 |
| `apply_patch` | 2, 3 | 15 |
| `Agent` | 4 | 2 |
| `mcp__drm-copilot__run_discovery_repo_inventory` | 2 | 6 |

## Agent-frontmatter PreToolUse hooks left out (D11)

- `.claude/agents/pr-author.md`: matcher `Bash`, command `pwsh -NoProfile -File .claude/hooks/enforce-pr-author-command-allowlist.ps1`. No other Claude agent frontmatter declares a PreToolUse hook; `.codex/agents/*.toml` files mention PreToolUse only in instruction text and declare no hook table.

## Derived set (a) — D13 (final statement passes an `Invoke-...EntryPoint` call directly to `exit`)

Scope: hooks registered under PreToolUse of either runtime (the dispatched hooks that D2 reproduces). Two non-PreToolUse hooks with the same tail shape (`.claude/hooks/record-discovery-agent-start.ps1`, SubagentStart; `.codex/hooks/validate-discovery-agent-output.ps1`, SubagentStop) are outside D12 scope and are not dispatched.

| Runtime | Hook | Tail |
|---|---|---|
| claude | `.claude/hooks/enforce-epic-wave-barrier.ps1` | `exit (Invoke-EpicWaveBarrierEntryPoint)` |
| claude | `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | `exit (Invoke-ParallelCohortBarrierEntryPoint)` |
| claude | `.claude/hooks/enforce-parallel-drift-gate.ps1` | `exit (Invoke-ParallelDriftGateEntryPoint)` |
| codex | `.codex/hooks/enforce-discovery-artifact-gate.ps1` | `exit (Invoke-DiscoveryArtifactGateEntryPoint -PayloadRaw ([Console]::In.ReadToEnd()))` |
| codex | `.codex/hooks/enforce-discovery-planning-gate.ps1` | `exit (Invoke-DiscoveryPlanningGateEntryPoint -PayloadRaw ([Console]::In.ReadToEnd()))` |
| codex | `.codex/hooks/enforce-evidence-locations.ps1` | `exit (Invoke-EvidenceLocationEntryPoint -PayloadRaw ([Console]::In.ReadToEnd()))` |
| codex | `.codex/hooks/enforce-file-size-limit.ps1` | `exit (Invoke-CodexFileSizeLimitEntryPoint -PayloadRaw ([Console]::In.ReadToEnd()))` |

## Derived set (b) — D6 (guarded `Import-Module ... -Force` in a PreToolUse hook or a `.ps1` helper it dot-sources)

Scope: PreToolUse-registered hooks of either runtime and the `.ps1` helpers reached by dot-source edges of `Get-HookDependencyClosure`. Format: file — imported module leaves.

- `.claude/hooks/validate-bash.ps1` — HookPayload
- `.claude/hooks/enforce-promotion-mcp-only.ps1` — HookPayload
- `.claude/hooks/enforce-pr-author-skill.ps1` — HookPayload, OrchestratorState, OrchestratorStateUnconditional
- `.claude/hooks/enforce-pr-author-skill.cleanup.ps1` — CleanupWorktreeManifest
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` — HookPayload
- `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` — WorktreeResolution, WorktreeItemResolution, WorktreeRunResolution, EpicScopeResolution, EpicScopeReadiness, HookTargetWorktree
- `.claude/hooks/enforce-epic-merge-gate.ps1` — HookPayload
- `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` — WorktreeRunResolution, WorktreeItemResolution
- `.claude/hooks/enforce-docs-complete-gate.ps1` — HookPayload, DocsCompleteGate
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` — HookPayload, CleanupWorktreeManifest
- `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` — WorktreeRunRecordPath, WorktreeRunResolution
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` — HookPayload, CleanupWorktreeManifest, WorktreeRunRecordPath, WorktreeRunResolution
- `.claude/hooks/enforce-parallel-abandon-gate.ps1` — HookPayload
- `.claude/hooks/enforce-worktree-poetry-venv.ps1` — HookPayload
- `.claude/hooks/check-python-test-purity.ps1` — HookPayload
- `.claude/hooks/enforce-python-batch-budget.ps1` — HookPayload, HookTargetWorktree
- `.claude/hooks/check-powershell-test-purity.ps1` — HookPayload
- `.claude/hooks/enforce-powershell-batch-budget.ps1` — HookPayload, HookTargetWorktree
- `.claude/hooks/enforce-evidence-locations.ps1` — HookPayload
- `.claude/hooks/enforce-file-size-limit.ps1` — HookPayload, FileSizePolicy
- `.claude/hooks/enforce-feature-folder-order.ps1` — HookPayload
- `.claude/hooks/enforce-checkpoint-monotonic.ps1` — HookPayload
- `.claude/hooks/enforce-completion-consistency.ps1` — HookPayload
- `.claude/hooks/enforce-mermaid-validation.ps1` — HookPayload; MermaidValidation (runtime import inside a function)
- `.claude/hooks/enforce-discovery-artifact-gate.ps1` — HookPayload, DiscoveryEncoding, DiscoveryAuthority, DiscoveryPayload, DiscoveryToolRouting, DiscoveryStartRecord, DiscoveryRootGrant, DiscoveryObservation, DiscoveryStart, DiscoveryAuthorization
- `.claude/hooks/enforce-prd-feature-before-planner.ps1` — HookPayload, WorktreeTargetResolution, WorktreeItemResolution
- `.claude/hooks/enforce-discovery-planning-gate.ps1` — HookPayload, DiscoveryEncoding, DiscoveryAuthority, DiscoveryManifest, DiscoveryPayload, DiscoveryToolRouting, DiscoveryAuthorization, DiscoveryStartRecord, DiscoveryPlanning
- `.claude/hooks/enforce-epic-wave-barrier.ps1` — HookPayload, WorktreeRunResolution
- `.claude/hooks/enforce-model-routing-receipt.ps1` — HookPayload, WorktreeItemResolution, EpicScopeResolution, CleanupWorktreeManifest
- `.claude/hooks/enforce-epic-invocation-origin.ps1` — HookPayload
- `.claude/hooks/enforce-parallel-cohort-barrier.ps1` — HookPayload, WorktreeItemResolution, WorktreeRunResolution
- `.claude/hooks/enforce-parallel-drift-gate.ps1` — HookPayload, WorktreeItemResolution, WorktreeRunResolution
- `.claude/hooks/enforce-docs-role-write-scope.ps1` — HookPayload
- `.codex/hooks/enforce-discovery-artifact-gate.ps1` — DiscoveryEncoding, DiscoveryAuthority, DiscoveryPayload, DiscoveryToolRouting, DiscoveryStartRecord, DiscoveryRootGrant, DiscoveryObservation, DiscoveryStart, DiscoveryAuthorization (`-Force -Global`, module path resolved to `.codex/lib` or `.claude/lib`)
- `.codex/hooks/enforce-discovery-planning-gate.ps1` — DiscoveryEncoding, DiscoveryAuthority, DiscoveryManifest, DiscoveryPayload, DiscoveryToolRouting, DiscoveryAuthorization, DiscoveryStartRecord, DiscoveryPlanning (`-Force -Global`)

Files: 35 (33 Claude, 2 Codex).

## Derived set (c) — registration consumers

Files under `tests/`, `.claude/lib/`, `.claude/hooks/`, `.codex/hooks/`, `scripts/` that read a PreToolUse block of `.claude/settings.json` or `.codex/config.toml`:

- `.claude/lib/discovery-validation/DiscoveryCapability.psm1` ([P3-T4]; consumed by both `discovery-capability-probe.ps1` hooks)
- `tests/scripts/claude-lib/discovery-validation/DiscoveryCapability.Tests.ps1` ([P3-T4])
- `tests/scripts/claude-runtime/claude-settings.Tests.ps1` ([P4-T1])
- `tests/scripts/claude-runtime/docs-authoring-roles.Registration.Tests.ps1` ([P4-T1])
- `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` ([P4-T1])
- `tests/scripts/claude-hooks/enforce-worktree-poetry-venv.Tests.ps1` ([P4-T1])
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` ([P4-T1])
- `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` ([P4-T1])
- `tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1` ([P4-T1])
- `tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1` and its consumers `hook-dependency-guard-completeness.Tests.ps1`, `hook-imported-modules-no-stdout.Tests.ps1`, `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`, `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`, `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` ([P4-T2])
- `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`, `codex-bundle-hook-probe.Tests.ps1`, `discovery-capability.Tests.ps1`, `enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`, `codex-epic-runtime-contracts.Tests.ps1` ([P4-T3])
- `tests/scripts/claude-hooks/discovery-capability.Tests.ps1` ([P3-T4] / [P4-T3], unchanged)
- `tests/scripts/dev_tools/test_codex_core_manifest_closure.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_discovery_publication_contracts.py`, `test_pack_manifest_dependency_scan.py` ([P4-T4])

Files matched by the search that do not read a PreToolUse block (text or path mention only): `.claude/hooks/validate-bash.ps1`, `.claude/hooks/discovery-capability-probe.ps1`, `.codex/hooks/discovery-capability-probe.ps1` (through `DiscoveryCapability.psm1`), `.codex/hooks/codex-pretooluse-file-mapping.ps1`, `.codex/hooks/enforce-epic-child-worktree-binding.ps1`, `tests/scripts/codex-hooks/codex-worktree-binding-hook.Tests.ps1`, `tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1`, `tests/fixtures/blast_radius/historical-runs/*.json`, `scripts/dev_tools/_orchestrator_state_model_routing_gate.py`, `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py`, `scripts/dev_tools/_parallel_orchestrator_state_drift.py`.

Arrived consumers (in (c) and not named in [P3-T4] or Phase 4): none.
