# Merge Conflicts: Cycle 2 Merge of origin/main (Issue #1096)

Timestamp: 2026-11-07T17-44
Command: git -C <item worktree> fetch origin; git -C <item worktree> merge --no-ff --no-commit origin/main; git -C <item worktree> ls-files -u
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: the merge of `origin/main` (carrying PR #1110, issue #1097) stopped with one content conflict, in `docs/engineering/process-reductions/0001-parallel-only-test-gates.md`, one hunk in step 1 of `## Revert Steps`. Seven other paths changed on both sides and auto-merged. The resolution keeps both sides.

## Conflicted path: docs/engineering/process-reductions/0001-parallel-only-test-gates.md

One conflicted hunk, step 1 of `## Revert Steps`.

### Branch side (stage 2)

```text
1. Apply the blocks: run `git apply -R` of the patch when its check passes. Otherwise replace each `Current` with its `Prior`, which restores the core rule, and restore the other paths from the patch text. The blocks of the #1096 landing apply whether or not the patch check passes, because the patch does not hold them: replace each of their `Current` texts with its `Prior`.
```

### Main side (stage 3)

```text
1. Apply the blocks: revert entry `0006` (`0006-test-suite-baseline-restored.md`) first, because it restores baseline text inside hunks of this entry's patch, so this patch does not reverse-apply while `0006` is in place. Then run `git apply -R` of the patch when its check passes. Otherwise replace each `Current` with its `Prior`, which restores the core rule, and restore the other paths from the patch text.
```

### Resolved text

Main's step 1 is kept in full, and the branch's #1096 sentence is appended to it.

```text
1. Apply the blocks: revert entry `0006` (`0006-test-suite-baseline-restored.md`) first, because it restores baseline text inside hunks of this entry's patch, so this patch does not reverse-apply while `0006` is in place. Then run `git apply -R` of the patch when its check passes. Otherwise replace each `Current` with its `Prior`, which restores the core rule, and restore the other paths from the patch text. The blocks of the #1096 landing apply whether or not the patch check passes, because the patch does not hold them: replace each of their `Current` texts with its `Prior`.
```

Branch-side elements that auto-merged and are kept unchanged: the two-part opening sentence and the second list of `## Files Changed`, the `## Stored Patch` sentence that the patch does not hold the #1096 edits, the `## Prior Text` paragraph and every `### Revert Block:` of the #1096 landing, the #1096 additions to steps 5 and 6 of `## Revert Steps`, the `Merge commit:` line, and the `## Revert Signals` bullet that replaced `Before #1096 lands`. Main-side elements that auto-merged and are kept unchanged: the rebased sections over PR #1108, its `## Stored Patch` patch handling, its other `## Revert Steps` text, and the `## Partial Revert` section.

## Auto-merged paths (changed on both sides, no conflict)

- `.agents/skills/execution-environment/SKILL.md`
- `.claude/skills/execution-environment/SKILL.md`
- `.github/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`
- `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`

Entries 0002 to 0006, their README index rows, and every other path changed only on `main` arrive unchanged.
