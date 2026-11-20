# Scope and Invariant Checks after the self-review fix (issue #1163, P8-T6 re-run)

Timestamp: 2026-11-13T14-11
Command: sh SCRATCH/issue-1163-scope.sh (git diff --exit-code <merge base of origin/main and HEAD> -- <path> for each invariant path; git diff --name-only <merge base> HEAD together with git status --porcelain, filtered for enforce-orchestration-preimplementation-gate and .py paths; sha256sum of each source and mirror pair; wc -l physical line counts of the merge-base blob and the current file)
EXIT_CODE: 0
Output Summary: The merge base of origin/main and HEAD is unchanged (the #1168 merge commit on main). All seven invariant paths are unchanged against it (AC-3, AC-12, AC-22, AC-24). Neither the branch diff (119 paths) nor git status --porcelain (5 entries: this loop's new evidence files) lists an enforce-orchestration-preimplementation-gate path or a .py path (0 matches each; AC-26, AC-31). All 21 source and mirror pairs are byte-identical, including the three files changed by the P8-T8 fix (AgentTargetWorktree.psm1, enforce-docs-complete-gate.ps1, agent-target-worktree.ps1), whose hashes changed with the fix and match their mirrors; the six execution-environment brief copies share one SHA-256 (AC-27, AC-29, AC-30). No changed production file is at or above 700 lines (the largest is 505). The new modules are 206 and 200 lines (at or below 500). WorktreeRunResolution.psm1 (498), the three removal-gate scripts (488, 260, 487), and WorktreeRunResolution.Record.Tests.ps1 (497) are each at or below 500. tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1 is 750 lines (the fix added 12), within the 800-line hard limit and recorded as the non-blocking 700-line advisory Warning. The AC-23 rows passed in pester-parallel-final.2026-11-13T14-09.md. SCRATCH here is the item worktree's gitignored scratch folder for issue 1163.

## Invariant paths (git diff --exit-code against the merge base)

| Check | Exit code |
|---|---|
| `git diff --exit-code <merge base> -- .claude/lib/worktree-resolution/HookTargetWorktree.psm1` | 0 |
| `git diff --exit-code <merge base> -- .codex/hooks/hook-target-worktree.ps1` | 0 |
| `git diff --exit-code <merge base> -- .claude/settings.json` | 0 |
| `git diff --exit-code <merge base> -- .codex/config.toml` | 0 |
| `git diff --exit-code <merge base> -- .claude/hooks/validate-orchestrator-output.ps1` | 0 |
| `git diff --exit-code <merge base> -- .claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | 0 |
| `git diff --exit-code <merge base> -- .claude/hooks/enforce-epic-merge-gate-green-ci.ps1` | 0 |

## Excluded paths in the branch diff and porcelain status

| Check | Matches |
|---|---|
| `git diff --name-only <merge base> HEAD` lines matching enforce-orchestration-preimplementation-gate or .py (119 paths) | 0 |
| `git status --porcelain` lines matching enforce-orchestration-preimplementation-gate or .py (5 entries) | 0 |

## Source and mirror SHA-256 pairs (first 16 hex characters)

| Source | Source SHA-256 | Mirror SHA-256 | Result |
|---|---|---|---|
| `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` | 1a5456b5b8ffc502 | 1a5456b5b8ffc502 | equal |
| `.claude/hooks/subagentstop-target-worktree.ps1` | 1b495fa030666459 | 1b495fa030666459 | equal |
| `.claude/hooks/validate-task-researcher-output.ps1` | e8099c9a4db86bed | e8099c9a4db86bed | equal |
| `.claude/hooks/validate-prd-feature-output.ps1` | 021605f34d1e920f | 021605f34d1e920f | equal |
| `.claude/hooks/validate-required-artifact-output.ps1` | 54ec74f38a154f0e | 54ec74f38a154f0e | equal |
| `.claude/hooks/validate-planner-output.ps1` | ef34e79d9ca22fab | ef34e79d9ca22fab | equal |
| `.claude/hooks/validate-executor-output.ps1` | 82d9de0a5f9b4def | 82d9de0a5f9b4def | equal |
| `.claude/hooks/validate-human-exception-runbook-output.ps1` | 54e5ff89458a61dc | 54e5ff89458a61dc | equal |
| `.claude/hooks/enforce-completion-consistency.ps1` | 6194b9fb74311c9d | 6194b9fb74311c9d | equal |
| `.claude/hooks/enforce-file-size-limit.ps1` | 916cb86d229dd00a | 916cb86d229dd00a | equal |
| `.claude/hooks/validate-docs-role-output.ps1` | d83fa3b6764025e5 | d83fa3b6764025e5 | equal |
| `.claude/hooks/enforce-docs-complete-gate.ps1` | d794d97e2fa34012 | d794d97e2fa34012 | equal |
| `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` | 12c92d17679f420e | 12c92d17679f420e | equal |
| `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | 15d83934604be90f | 15d83934604be90f | equal |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 9980f5c948f3df68 | 9980f5c948f3df68 | equal |
| `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` | 773a44f8c52e9151 | 773a44f8c52e9151 | equal |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 700175ba5f0aa364 | 700175ba5f0aa364 | equal |
| `.claude/rules/orchestrator-state.md` | fbeafc976800cec2 | fbeafc976800cec2 | equal |
| `.codex/hooks/agent-target-worktree.ps1` | bc68f70cd9498c4e | bc68f70cd9498c4e | equal |
| `.codex/hooks/enforce-completion-consistency.ps1` | 30d62c02f6eb5d76 | 30d62c02f6eb5d76 | equal |
| `.codex/hooks/enforce-file-size-limit.ps1` | f4edf61c20cf63cc | f4edf61c20cf63cc | equal |

Pack manifests: `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` is listed once in extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json and `.codex/hooks/agent-target-worktree.ps1` once in extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json.

## Execution-environment brief copies (SHA-256, first 16 hex characters)

| Copy | SHA-256 |
|---|---|
| `.claude/skills/execution-environment/SKILL.md` | 40d971f64f63e6e0 |
| `.agents/skills/execution-environment/SKILL.md` | 40d971f64f63e6e0 |
| `.github/skills/execution-environment/SKILL.md` | 40d971f64f63e6e0 |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` | 40d971f64f63e6e0 |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md` | 40d971f64f63e6e0 |
| `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` | 40d971f64f63e6e0 |

## Physical line counts (merge base, current)

| File | Merge base | Current |
|---|---|---|
| `.claude/hooks/subagentstop-target-worktree.ps1` | 349 | 367 |
| `.claude/hooks/validate-task-researcher-output.ps1` | 337 | 337 |
| `.claude/hooks/validate-prd-feature-output.ps1` | 164 | 164 |
| `.claude/hooks/validate-required-artifact-output.ps1` | 228 | 228 |
| `.claude/hooks/validate-planner-output.ps1` | 470 | 470 |
| `.claude/hooks/validate-executor-output.ps1` | 417 | 417 |
| `.claude/hooks/validate-human-exception-runbook-output.ps1` | 132 | 132 |
| `.claude/hooks/enforce-completion-consistency.ps1` | 489 | 505 |
| `.codex/hooks/enforce-completion-consistency.ps1` | 491 | 500 |
| `.claude/hooks/enforce-file-size-limit.ps1` | 244 | 263 |
| `.codex/hooks/enforce-file-size-limit.ps1` | 282 | 308 |
| `.claude/hooks/validate-docs-role-output.ps1` | 89 | 119 |
| `.claude/hooks/enforce-docs-complete-gate.ps1` | 353 | 396 |
| `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` | 185 | 204 |
| `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | 487 | 498 |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 468 | 488 |
| `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` | 249 | 260 |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 466 | 487 |
| `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` | new | 206 |
| `.codex/hooks/agent-target-worktree.ps1` | new | 200 |
| `tests/scripts/claude-hooks/enforce-docs-complete-gate.Tests.ps1` | 669 | 750 |
| `tests/scripts/claude-lib/worktree-resolution/WorktreeRunResolution.Record.Tests.ps1` | 455 | 497 |

## AC-23 rows (from the P8-T2 gate)

| Test | Suite | Result |
|---|---|---|
| S2-9 returns a rooted runbook path unchanged | tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1 | passed |
| blocks when an exception requirement has no existing runbook (injected FileExistsCheck returns false) | tests/scripts/claude-hooks/validate-orchestrator-output.human-interaction.Tests.ps1 | passed |
