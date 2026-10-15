# Bug: Python push-down divergences left out of scope by issue #507 (Issue #790)

- Date captured: 2026-09-29
- Author: epic-planner (epic #770, `push-down-payload-correctness`)
- Issue: #790
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/790
- Related: #507, #510, #621
- Promoted record: `docs/features/potential/promoted/2026-09-29-issue-507-python-push-down-divergence-follow-ups.md`
- Draft potential entry: `docs/features/potential/2026-09-29-issue-507-python-push-down-divergence-follow-ups.md`
- Last Updated: 2026-10-08
- Work Mode: full-bug

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

F-507-1: the TypeScript push-down merges a managed block after the copy (`deliverDestinationGitignore` in `extensions/drm-copilot/src/lib/push-down/claude-customizations.ts`, with `claude-gitignore-merge.ts`); the Python push-down has no `gitignore` handling. F-507-2: `RealPushDownFileSystem.list_files` (`scripts/dev_tools/push_down_copilot_customizations_filesystem.py`) is an unfiltered `root.rglob("*")` and `EXCLUDED_RELATIVE_PATHS` holds only exact files, so `.claude/worktrees/**` and `.claude/state/**` (gitignored) are published. The TypeScript push-down reads a curated bundle and never sees them.

## Impact / Severity

- Medium. F-507-2 can write a large volume of files, because `.claude/worktrees/**` can hold complete repository checkouts.

## Additional Evidence (issue comment, from #510 / PR #834)

#510 fixed only the test-side enumeration and recorded the production defect as out of scope. Its suggested scope additions: add a directory-prefix exclusion for `.claude/state` and `.claude/worktrees` in `ExcludingFileSystem` (`scripts/dev_tools/push_down_claude_filesystem.py`) and the same exclusion in `claude-filesystem-adapter.ts` `listFiles`, with unit tests that use the in-memory filesystem in `tests/scripts/dev_tools/test_push_down_claude_customizations.py`. `tests/scripts/dev_tools/claude_payload_scope_test_support.py` already defines the local-only set (`agent-memory`, `state`, `worktrees`, `settings.local.json`) on the test side. The TypeScript adapter gap is latent: it would copy these files only if they reached its source root.

## Proposed Fix / Validation Ideas

- Port the managed-block merge to the Python push-down so it runs after the copy, and extend the #507 parity test so it fails if either side drops the merge.
- Exclude gitignored runtime trees from the Python source enumeration, by honoring `.gitignore` or through an explicit exclusion list that matches the bundle contents.
- A Python push-down from a checkout containing `.claude/worktrees/` and `.claude/state/` writes neither tree; the Python and TypeScript file sets match for the same revision.

The authoritative acceptance criteria for this full-bug item are in `spec.md`.
