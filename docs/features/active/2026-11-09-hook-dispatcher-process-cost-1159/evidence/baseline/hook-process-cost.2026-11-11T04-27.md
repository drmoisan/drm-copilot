# Hook process cost report (-Source Registration)

Timestamp: 2026-11-11T04-26
Command: pwsh -NoProfile -File scripts/dev-tools/Measure-HookProcessCost.ps1 -Source Registration -Iterations 5
EXIT_CODE: 0
Output Summary: 5 iteration(s) per scenario; hook processes per call: claude bash=12, claude write=13, claude agent=9, claude mcp=1, codex bash=12, codex write=15, codex agent=2, codex mcp=6. CPU and wall seconds are reported as median/mean/max. Grandchild processes (git, gh) started by hooks are excluded from the process count and CPU seconds.

Grandchild processes (git, gh) started by hook scripts are excluded: the process count and CPU seconds cover only the hook processes the runtime starts.

| Runtime | Scenario | Tool name | Processes per call | CPU seconds (median/mean/max) | Wall seconds (median/mean/max) | Max hook exit code |
|---|---|---|---|---|---|---|
| claude | bash | `Bash` | 12 | 18.703/19.622/26.656 | 9.327/11.198/19.704 | 0 |
| claude | write | `Write` | 13 | 11.766/11.813/12.516 | 5.620/5.934/7.033 | 0 |
| claude | agent | `Agent` | 9 | 10.797/10.666/12.563 | 7.132/8.077/13.108 | 0 |
| claude | mcp | `mcp__drm-copilot__run_discovery_repo_inventory` | 1 | 1.516/1.531/1.953 | 7.094/6.651/10.143 | 0 |
| codex | bash | `Bash` | 12 | 15.406/15.131/18.563 | 10.069/9.855/13.815 | 0 |
| codex | write | `apply_patch` | 15 | 15.297/15.728/18.125 | 8.260/9.453/18.807 | 0 |
| codex | agent | `Agent` | 2 | 2.359/2.525/2.938 | 3.493/3.711/4.623 | 0 |
| codex | mcp | `mcp__drm-copilot__run_discovery_repo_inventory` | 6 | 6.906/7.325/9.797 | 8.734/11.051/16.910 | 0 |

## Hooks per scenario

- claude bash: .claude/hooks/validate-bash.ps1, .claude/hooks/enforce-promotion-mcp-only.ps1, .claude/hooks/enforce-pr-author-skill.ps1, .claude/hooks/enforce-orchestration-preimplementation-gate.ps1, .claude/hooks/enforce-epic-merge-gate.ps1, .claude/hooks/enforce-docs-complete-gate.ps1, .claude/hooks/enforce-epic-worktree-removal-gate.ps1, .claude/hooks/enforce-parallel-worktree-removal-gate.ps1, .claude/hooks/enforce-parallel-abandon-gate.ps1, .claude/hooks/enforce-worktree-poetry-venv.ps1, .claude/hooks/enforce-discovery-artifact-gate.ps1, .claude/hooks/enforce-docs-role-write-scope.ps1
- claude write: .claude/hooks/check-python-test-purity.ps1, .claude/hooks/enforce-python-batch-budget.ps1, .claude/hooks/check-powershell-test-purity.ps1, .claude/hooks/enforce-powershell-batch-budget.ps1, .claude/hooks/enforce-evidence-locations.ps1, .claude/hooks/enforce-file-size-limit.ps1, .claude/hooks/enforce-orchestration-preimplementation-gate.ps1, .claude/hooks/enforce-feature-folder-order.ps1, .claude/hooks/enforce-checkpoint-monotonic.ps1, .claude/hooks/enforce-completion-consistency.ps1, .claude/hooks/enforce-mermaid-validation.ps1, .claude/hooks/enforce-discovery-artifact-gate.ps1, .claude/hooks/enforce-docs-role-write-scope.ps1
- claude agent: .claude/hooks/enforce-discovery-artifact-gate.ps1, .claude/hooks/enforce-prd-feature-before-planner.ps1, .claude/hooks/enforce-discovery-planning-gate.ps1, .claude/hooks/enforce-orchestration-preimplementation-gate.ps1, .claude/hooks/enforce-epic-wave-barrier.ps1, .claude/hooks/enforce-model-routing-receipt.ps1, .claude/hooks/enforce-epic-invocation-origin.ps1, .claude/hooks/enforce-parallel-cohort-barrier.ps1, .claude/hooks/enforce-parallel-drift-gate.ps1
- claude mcp: .claude/hooks/enforce-discovery-artifact-gate.ps1
- codex bash: .codex/hooks/validate-bash.ps1, .codex/hooks/enforce-promotion-mcp-only.ps1, .codex/hooks/enforce-orchestration-preimplementation-gate.ps1, .codex/hooks/enforce-epic-merge-gate.ps1, .codex/hooks/enforce-epic-worktree-removal-gate.ps1, .codex/hooks/enforce-worktree-poetry-venv.ps1, .codex/hooks/enforce-discovery-artifact-gate.ps1, .codex/hooks/enforce-epic-root-invocation.ps1, .codex/hooks/enforce-codex-model-routing.ps1, .codex/hooks/enforce-epic-planning-only.ps1, .codex/hooks/enforce-epic-wave-barrier.ps1, .codex/hooks/enforce-epic-child-worktree-binding.ps1
- codex write: .codex/hooks/enforce-discovery-artifact-gate.ps1, .codex/hooks/enforce-epic-root-invocation.ps1, .codex/hooks/enforce-codex-model-routing.ps1, .codex/hooks/enforce-epic-planning-only.ps1, .codex/hooks/enforce-epic-wave-barrier.ps1, .codex/hooks/enforce-epic-child-worktree-binding.ps1, .codex/hooks/check-python-test-purity.ps1, .codex/hooks/enforce-python-batch-budget.ps1, .codex/hooks/check-powershell-test-purity.ps1, .codex/hooks/enforce-powershell-batch-budget.ps1, .codex/hooks/enforce-evidence-locations.ps1, .codex/hooks/enforce-file-size-limit.ps1, .codex/hooks/enforce-orchestration-preimplementation-gate.ps1, .codex/hooks/enforce-checkpoint-monotonic.ps1, .codex/hooks/enforce-completion-consistency.ps1
- codex agent: .codex/hooks/enforce-discovery-artifact-gate.ps1, .codex/hooks/enforce-discovery-planning-gate.ps1
- codex mcp: .codex/hooks/enforce-discovery-artifact-gate.ps1, .codex/hooks/enforce-epic-root-invocation.ps1, .codex/hooks/enforce-codex-model-routing.ps1, .codex/hooks/enforce-epic-planning-only.ps1, .codex/hooks/enforce-epic-wave-barrier.ps1, .codex/hooks/enforce-epic-child-worktree-binding.ps1

## Payload templates ({{REPOSITORY_ROOT}} is replaced by the repository root at run time)

- claude bash: `{"session_id":"hook-process-cost","hook_event_name":"PreToolUse","cwd":"{{REPOSITORY_ROOT}}","tool_name":"Bash","tool_input":{"command":"git status --short"}}`
- claude write: `{"session_id":"hook-process-cost","hook_event_name":"PreToolUse","cwd":"{{REPOSITORY_ROOT}}","tool_name":"Write","tool_input":{"file_path":"docs/hook-cost-probe.md","content":"probe\n"}}`
- claude agent: `{"session_id":"hook-process-cost","hook_event_name":"PreToolUse","cwd":"{{REPOSITORY_ROOT}}","tool_name":"Agent","tool_input":{"subagent_type":"task-researcher","description":"hook cost probe","prompt":"hook cost probe"}}`
- claude mcp: `{"session_id":"hook-process-cost","hook_event_name":"PreToolUse","cwd":"{{REPOSITORY_ROOT}}","tool_name":"mcp__drm-copilot__run_discovery_repo_inventory","tool_input":{}}`
- codex bash: `{"session_id":"hook-process-cost","hook_event_name":"PreToolUse","cwd":"{{REPOSITORY_ROOT}}","tool_name":"Bash","tool_input":{"command":"git status --short"}}`
- codex write: `{"session_id":"hook-process-cost","hook_event_name":"PreToolUse","cwd":"{{REPOSITORY_ROOT}}","tool_name":"apply_patch","tool_input":{"command":"*** Begin Patch\n*** Update File: docs/hook-cost-probe.md\n@@\n-old\n+new\n*** End Patch\n"}}`
- codex agent: `{"session_id":"hook-process-cost","hook_event_name":"PreToolUse","cwd":"{{REPOSITORY_ROOT}}","tool_name":"Agent","tool_input":{"subagent_type":"task-researcher","description":"hook cost probe","prompt":"hook cost probe"}}`
- codex mcp: `{"session_id":"hook-process-cost","hook_event_name":"PreToolUse","cwd":"{{REPOSITORY_ROOT}}","tool_name":"mcp__drm-copilot__run_discovery_repo_inventory","tool_input":{}}`

## Verification ([P0-T10])

Launched as `sh SCRATCH/issue-1159-cost.sh Registration SCRATCH/issue-1159-cost-before.md` (exit 0) before any registration edit, on Windows. Every runtime and scenario process count equals the per-call count of `pretooluse-inventory.2026-11-10T03-48.md` (Claude Bash 12, Write 13, Agent 9, mcp 1; Codex Bash 12, apply_patch 15, Agent 2, mcp 6). The payload templates above are the set [P7-T7] reuses. `git status --porcelain` after the run listed no file written by a hook.
