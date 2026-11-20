# Main sync, repeat (issue #1157, P6-T1 repeat)

Timestamp: 2026-11-13T17-23
Command: git merge-tree --write-tree --name-only <branch head before the merge> origin/main; git diff --name-status <merge commit>^1 <merge commit>; sh SCRATCH/issue-1157-parity.sh; sha256sum over the six execution-environment copies and the two orchestrator-state rule copies; sh SCRATCH/issue-1157-pytest.sh over the P4-T2 bundle-parity pytest files with --no-cov (non-evidence debugging run)
EXIT_CODE: 0
Output Summary:
- Merged ref: origin/main at the head of PR #1170 (issue #1163). The merge was performed by the orchestrator as a plain merge commit "Merge origin/main into feature/owner-directive-pass-down-1157 (#1157)", already pushed; this task records and verifies it on the merged tree.
- Conflicted paths (reproduced with git merge-tree on the two parents): `.claude/rules/orchestrator-state.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/orchestrator-state.md`.
- Resolution per path: both files, in the Known limitations list of `## Enforcement`, keep this item's owner-directive pass-down bullet (issue #1157) and add main's `Restored-host note (#1163)` bullet after it; no conflict marker remains (0 marker lines) and the two copies hash equal.
- Automatically merged shared files: the six execution-environment SKILL.md copies (all six hash equal after the merge), both `pack-manifests/core.json` files, and `tests/scripts/claude-hooks/validate-orchestrator-output.TargetWorktree.Tests.ps1` (main's #1163 edit and this item's rows both present). `tests/scripts/claude-hooks/validate-orchestrator-output-target.Tests.ps1` was changed by main only.
- Not changed by the merge: `.claude/settings.json`, `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, and every hook and module this item adds or changes.
- Bundle re-copy: the parity script compared 23 source and bundle pairs from the branch diff; 0 unequal, so no re-copy was needed.
- Non-evidence debugging run of the P4-T2 bundle-parity pytest files (push-down claude resource contracts, claude pack-manifest completeness, pack-manifest dependency closure, codex-and-agents resource contracts): 43 passed. The binding results are the P6-T5 and P6-T7 gates of this repeat.
