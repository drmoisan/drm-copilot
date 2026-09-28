# completion-consistency-edit-reads-relative-checkpoint (Issue #708)

- Work Mode: full-bug
- Issue: #708
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/708
- Labels: bug
- Source: GitHub issue #708 body, mirrored 2026-09-26. The promoted lifecycle record is not present on this branch; this file was populated from `gh issue view 708`.

## Summary

For an Edit call, `.claude/hooks/enforce-completion-consistency.ps1` reconstructs the post-edit checkpoint by applying `old_string` to `new_string` against the on-disk checkpoint. It reads that file through the literal relative checkpoint path, so when the process working directory differs from the worktree the call targets, it reads the wrong file.

## Environment

- OS/version: any
- Python version: n/a (PowerShell hook)
- Command/flags used: an Edit tool call against `artifacts/orchestration/orchestrator-state.json` from a session whose root is not the target worktree
- Data source or fixture: an isolated-worktree subagent editing its own checkpoint

## Steps to Reproduce

1. Start a session rooted at the main checkout.
2. From a subagent in an isolated worktree, Edit that worktree's `artifacts/orchestration/orchestrator-state.json`.
3. Observe that the hook's on-disk read resolves against the process working directory, not the target worktree.

## Expected Behavior

The Edit-patch branch reads the checkpoint at the path the Edit call targets.

## Actual Behavior

The Edit-patch branch is documented at lines 269-273 and implemented at lines 288-308, and it reads through the checkpoint reader at lines 82-85 using the literal relative path. The consequence was not exercised by #663's plan; it is recorded as out of scope in its section 1.

## Logs / Screenshots

- Snippet: `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/other/follow-ups.md`, item 2.

## Impact / Severity

- Medium

## Acceptance Criteria

- [ ] For an Edit call on the orchestrator checkpoint, the completion-consistency hook reads the on-disk checkpoint content from the path the Edit call targets (the tool input `file_path`), not from the literal relative path resolved against the process working directory.
- [ ] When the process working directory differs from the worktree that contains the targeted checkpoint, the hook's post-edit reconstruction uses the targeted file's content, so its allow/deny decision matches the decision it would make when run from inside that worktree.
- [ ] Existing behavior is preserved when the process working directory is the target worktree (relative and absolute `file_path` spellings), and the hook still fails closed as before when the targeted file cannot be read.
- [ ] Automated Pester tests cover the working-directory-mismatch case, fail against the pre-fix code, and pass after the fix, without depending on gitignored state, `origin/main`, or Windows-only paths.

## Source

From: docs/features/potential/2026-09-26-completion-consistency-edit-reads-relative-checkpoint.md (record not present on this branch)
