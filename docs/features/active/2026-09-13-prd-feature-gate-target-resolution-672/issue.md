# prd-feature-gate-target-resolution (Issue #672)

- Date captured: 2026-09-13
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/prd-feature-gate-target-resolution/ (Issue #672)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #672
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/672
- Last Updated: 2026-09-14
- Work Mode: full-bug

## Summary

`.claude/hooks/enforce-prd-feature-before-planner.ps1` resolves the feature folder it gates against the invoking session's current working directory rather than against the worktree the tool call pertains to, and truncates prompt path tokens to a fixed segment count. As a result the hook denies every `Agent(atomic-planner)` delegation issued from a coordinating (parallel or epic) session, even when the required document exists and is committed.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: not applicable (PowerShell PreToolUse hook)
- Command/flags used: `Agent(atomic-planner)` delegation from a coordinating orchestration session
- Data source or fixture: TaskMaster parallel run `bugs-2026-09-11`, item 839 (both `spec.md` and `user-story.md` present and committed)

## Steps to Reproduce

1. Create a parallel or epic orchestration topology in which the coordinating session's current working directory is the session root and each child item occupies its own git worktree.
2. Ensure a child item's active feature folder contains the document its work-mode marker requires (for item 839, `spec.md` and `user-story.md` both exist and are committed).
3. From the coordinating session, issue an `Agent(atomic-planner)` delegation whose prompt names that item's feature folder, first in repo-relative form and then in absolute form.

## Expected Behavior

The hook resolves the feature folder named in the tool-call payload against the worktree that folder belongs to, finds the required document, and allows the delegation. When the target cannot be identified, the hook denies with a distinct, greppable ambiguity reason code rather than falling back to whatever checkpoint occupies the session root.

## Actual Behavior

Verified decision matrix, tested directly during run `bugs-2026-09-11` for item 839:

| envelope | cwd | result |
| --- | --- | --- |
| names its own feature folder | orchestrator session root | DENY |
| identical envelope | the item's own worktree | ALLOW |
| names an absolute path to the same folder | either | DENY |

No remediation cycle can run from a coordinating session, which brought the run to a complete standstill.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: the denial is the hook's existing missing-required-document reason, which is misleading: the document is present, but the hook tested for it under the wrong root.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

Two distinct causes, both in the hook's resolution logic rather than in its callers:

- Absolute-path denial: `Find-PrdFeatureFolderFromPrompt` (line 219) scans the prompt for `docs/features/active/<...>` tokens and truncates each match to a fixed segment count (documented at lines 16-18, applied at line 265). The truncation discards a valid absolute-path prefix.
- Relative-path denial: the truncated relative candidate is tested with `Test-Path -LiteralPath` (lines 91, 108, 201) against the session root rather than against the target worktree. Only when zero prompt candidates are found does the hook fall back to `Get-PrdFeatureCheckpointFolder` (line 189), which reads the checkpoint's `feature-folder` field at the session root.

No worktree resolution exists anywhere in the file. Re-verified against this tree 2026-09-13: the file is 448 lines against the repository's 500-line cap, and `.codex/hooks/` contains no mirror of it.

Anti-pattern (recorded so it is not re-proposed): the initial hypothesis during the originating run was that child prompts omitted the folder path. That was wrong. Every child prompt in the run named its own feature folder. Do not change prompt construction.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: table-driven Pester over the cross product of cwd (session root vs item worktree), path form (relative vs absolute), and target (own item vs sibling item vs absent), with currently-passing rows retained as regression guards.
- [x] Integration scenario to retest: a coordinating session delegating `Agent(atomic-planner)` for an item whose required document exists.
- [x] Manual verification notes: the gate must still deny when the required document is genuinely absent. A fix that resolves the target correctly but stops checking the document converts a false denial into a false approval, which is the more serious failure mode.

Fix direction (fixes 1 and 2 of the parent epic's five):

1. Resolve against the call's target, not the session's cwd. Derive the target worktree from the tool-call payload. Use the session root only when the call genuinely has no target.
2. Accept absolute paths. Normalise to repo-relative by locating the containing worktree instead of truncating to a fixed segment count.

Upstream dependency: the target-derivation, path-normalisation, and ambiguity-reason-code contract is delivered by the parent epic's F1 module under `.claude/lib/`. Consume that contract; do not re-implement any of its three parts locally.

Bundled-payload mirroring: every edit under `.claude/**` must also be applied at `extensions/drm-copilot/resources/claude-customizations/.claude/**`. The two copies of this hook are byte-identical today (verified 2026-09-13).

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
