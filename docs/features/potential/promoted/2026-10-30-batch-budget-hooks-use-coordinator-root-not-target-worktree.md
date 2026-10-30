# batch-budget-hooks-use-coordinator-root-not-target-worktree (Issue #1009)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/batch-budget-hooks-use-coordinator-root-not-target-worktree/ (Issue #1009)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #1009
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1009
- Last Updated: 2026-10-30
## Summary

The batch-budget hooks cap and pool edits by the coordinator session root instead of the worktree being edited. A non-isolated child resuming an item in its own worktree is denied on its 4th distinct production file even though that worktree's checkpoint selects `large`. This is one of four bugs (batch-budget, preimplementation gate, PR authoring, completion stop hook) that share one root cause and one fix: a target-worktree resolver.

## Environment

- OS/version: not recorded
- Python version: not applicable
- Command/flags used: a coordinating session (`parallel-orchestrator`, `epic-orchestrator`, or a main session acting as coordinator) driving child orchestrators whose items live in separate git worktrees
- Data source or fixture: hooks `enforce-python-batch-budget.ps1`, `enforce-powershell-batch-budget.ps1`, and shared `enforce-batch-budget-route.ps1`

## Steps to Reproduce

1. Run a coordinating session whose own checkout holds no per-item checkpoint (coordinator-root checkpoint hygiene).
2. Relaunch a child without isolation so it resumes an existing item worktree whose checkpoint selects `large` (or `remediation` / `preparation`) and is non-terminal.
3. Have the child edit a 4th distinct production `.py` or `.ps1` file in that worktree.

## Expected Behavior

- The route is read from the checkpoint of the resolved target worktree.
- Budget state is keyed per resolved worktree root.
- Paths under gitignored `artifacts/` are never counted as production files.
- A file outside every registered worktree keeps today's behavior.

## Actual Behavior

The child is denied `PYTHON_LARGE_PATH_REQUIRED` / `POWERSHELL_LARGE_PATH_REQUIRED`. The budget state file is keyed to the session and stored under the coordinator root, so all items in the session share one counter. Gitignored scratch files under any worktree's `artifacts/` are counted as production files.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `PYTHON_LARGE_PATH_REQUIRED`, `POWERSHELL_LARGE_PATH_REQUIRED`

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The only agent-side workarounds are fabricating a checkpoint at the coordinator root (prohibited by checkpoint hygiene), deleting hook state, or asking the human to start one Claude Code session per item worktree. Agents correctly refuse the first two.

## Suspected Cause / Notes

Several hooks derive the repository root from their own script location (`Split-Path (Split-Path $PSScriptRoot)`) and read `<root>/artifacts/orchestration/orchestrator-state.json`. Claude Code loads hook scripts from the session's project directory, so in a coordinating session that root is the coordinator checkout. Worktree isolation hides the defect because an isolated child gets its own session root; it surfaces for non-isolated resumed children, coordinators writing into an item worktree, and subagents (pr-author, atomic-executor) that inherit the coordinator root.

Shared fix (also covers the three sibling bugs): add one pure helper, for example `Resolve-HookTargetWorktree` in `.claude/lib/worktree-resolution/` (PowerShell), with Codex and Python counterparts where a Python port exists. It returns the worktree root for a tool call from, in order: (1) the target path of a file tool (`file_path` for Write/Edit/MultiEdit/NotebookEdit); (2) for Bash, the path a command operates on (`git -C <path>`, an absolute file argument the hook already parses, or a `--body-file` / `--head` worktree the existing PR hook resolves); (3) the delegation-prompt identity (`branch:` label plus canonical issue line) for `Agent(...)` calls; (4) the session root, only as the final fallback. It uses `git worktree list --porcelain` through an injectable invoker seam, picks the nearest enclosing registered worktree, returns `{ WorktreeRoot, Source, Ambiguous }`, and never reads files itself. `TARGET_WORKTREE_NOT_DERIVABLE` and `TARGET_WORKTREE_AMBIGUOUS` are kept for genuinely ambiguous cases.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: worktree checkpoint large → uncapped; worktree with no checkpoint → capped; two worktrees in one session → independent counters; an `artifacts/` scratch `.py` / `.ps1` → not counted; a session-root file → unchanged behavior. Tests in every runtime carrying the hook or helper (Claude `.claude/hooks/`, Codex `.codex/hooks/`, and the bundled copies the push-down publishes).
- [ ] Integration scenario to retest
- [ ] Manual verification notes

Documentation and parity: update the execution-environment brief (Batch Budget, Hook Execution Context, Command-Text Restrictions) in all byte-identical copies in the same change; update `.claude/rules/orchestrator-state.md` (hooks now resolve the target worktree, so no coordinator-root checkpoint is ever needed). Contract tests for mirrored and bundled files, pack-manifest completeness, and dependency closure for the new helper module must pass. Enforcement hooks still do not invoke Python.

Out of scope: no relaxation of any gate's intent (the budget cap stays as strict as today; only the checkpoint and root evaluated change); no change to worktree-isolation behavior or checkpoint schemas.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
