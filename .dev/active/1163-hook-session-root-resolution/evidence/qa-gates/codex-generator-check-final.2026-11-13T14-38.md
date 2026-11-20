# Codex Generator Check, remediation cycle 1 (issue #1163, [P0-T1], finding F1)

Timestamp: 2026-11-13T14-38
Command: env -u VIRTUAL_ENV poetry -C <item worktree> run python -m scripts.dev_tools.generate_codex_agent_variants --check
EXIT_CODE: 0
Output Summary: Exit 0 on the head carrying "fix(1163): name the full stale branch in the repair detail (F1)". No generated variant, bundle copy, or Codex core.json is out of date. This matches the Phase 0 baseline (baseline/codex-generator-check.2026-11-10T04-10.md, exit 0) and codex-generator-check-final.2026-11-13T14-11.md.

## Source and mirror byte identity (same time)

Command: sha256sum over each source and its bundle mirror.

| File | SHA-256 | Mirror equal |
|---|---|---|
| `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` | 66e7023c6c02100a1d268210fe231ffd94d7d97ba61dc0fde231e3ba99401cba | yes (`extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/AgentTargetWorktree.psm1`) |
| `.codex/hooks/agent-target-worktree.ps1` | 865ce3272e356e1b6e03077dbcfb8bcf3bcfe7820c3a31c6299a03883d12035f | yes (`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/agent-target-worktree.ps1`) |

The function text of `Resolve-AgentTargetWorktree` in the module and the Codex twin is held equal by `tests/scripts/codex-hooks/agent-target-worktree.Tests.ps1`, which passed in the task check (evidence/other/task-check.P0-T1.2026-11-13T14-36.md).

## Scope invariants (same time)

- `git diff --exit-code <merge base of origin/main and HEAD> HEAD -- .claude/lib/worktree-resolution/HookTargetWorktree.psm1 .codex/hooks/hook-target-worktree.ps1 .claude/settings.json .codex/config.toml config/poshqc-leak-allowlist.json`: exit 0 (unchanged).
- `git diff --name-only <merge base> HEAD -- '*.py'`: 0 paths.
- Cycle diff (`git diff --name-only` from the review-inputs commit to HEAD): the four F1 production files (module, Codex twin, two mirrors), the rows helper, and two evidence files; no other path.
