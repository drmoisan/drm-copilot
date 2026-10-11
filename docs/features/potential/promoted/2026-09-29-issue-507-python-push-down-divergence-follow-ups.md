# Python push-down divergences left out of scope by issue #507 (Issue #790)

- Date captured: 2026-09-29
- Author: epic-planner (epic #770, `push-down-payload-correctness`)
- Status: Promoted -> docs/features/active/Python_push-down_divergences_left_out_of_scope_by_issue_507/ (Issue #790)
- Related: #507, #621

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #790
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/790
- Last Updated: 2026-09-30
## Summary

The Python push-down (`scripts/dev_tools/push_down_claude_customizations.py`) and the TypeScript push-down leave the destination in different states in two ways that #507 did not address: (F-507-1) Python does not merge the managed `.gitignore` block, and (F-507-2) the Python CLI enumerates gitignored `.claude` runtime subtrees when run from a main checkout. Source: preparation of #507, `docs/features/active/2026-08-22-push-down-root-folders-divergence-507/spec.md` (Rollout & Follow-up) and `research/research.2026-09-29T14-20.md`. #507 AC24 required only that the spec record them.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `scripts/dev_tools/push_down_claude_customizations.py` versus the extension push-down command
- Data source or fixture: a destination checkout, and a source checkout containing `.claude/worktrees/` and `.claude/state/`

## Steps to Reproduce

1. F-507-1: run both push-downs against equivalent destinations and compare the destination `.gitignore`.
2. F-507-2: run the Python push-down from a main checkout that contains `.claude/worktrees/` and `.claude/state/` and list the published files.

## Expected Behavior

Both implementations leave the same managed `.gitignore` block and publish the same file set for the same source revision. Lines outside the managed block are preserved byte for byte.

## Actual Behavior

F-507-1: the TypeScript push-down merges a managed block after the copy (`deliverDestinationGitignore`, `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts:426` call and `:468` definition, with `claude-gitignore-merge.ts`); the Python push-down has no `gitignore` handling (`grep -i gitignore` over `push_down_claude_customizations.py` returns nothing). The original entry cited lines 320 and 346-361; the code has since moved. F-507-2: `RealPushDownFileSystem.list_files` (`scripts/dev_tools/push_down_copilot_customizations_filesystem.py:99-107`) is an unfiltered `root.rglob("*")` and `EXCLUDED_RELATIVE_PATHS` holds only `settings.local.json`, so `.claude/worktrees/**` and `.claude/state/**` (gitignored at `.gitignore:21` and `:68`) are published. The TypeScript push-down reads a curated bundle and never sees them.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: verified by reading main at ae7c7779; the commands were not executed.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

F-507-2 can write a large volume of files, because `.claude/worktrees/**` can hold complete repository checkouts.

## Suspected Cause / Notes

F-507-1 could be folded into #621, which also works on destination state; decide when scheduling.

## Proposed Fix / Validation Ideas

- [ ] Port the managed-block merge to the Python push-down so it runs after the copy, and extend the #507 parity test so it fails if either side drops the merge.
- [ ] Exclude gitignored runtime trees from the Python source enumeration, by honoring `.gitignore` or through an explicit exclusion list that matches the bundle contents.
- [ ] A Python push-down from a checkout containing `.claude/worktrees/` and `.claude/state/` writes neither tree; the Python and TypeScript file sets match for the same revision.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
