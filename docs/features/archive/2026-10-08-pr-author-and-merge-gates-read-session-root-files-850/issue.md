# pr-author-and-merge-gates-read-session-root-files (Issue #850)

- Date captured: 2026-10-08
- Author: Dan Moisan
- Status: Active -> docs/features/active/2026-10-08-pr-author-and-merge-gates-read-session-root-files-850/ (Issue #850)
- Issue: #850
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/850
- Epic: #852 (enforcement-hook-precision), child C3 (residual session-root reads)
- Integration branch: epic/enforcement-hook-precision-integration
- Last Updated: 2026-10-08
- Work Mode: full-bug

> Work-mode note: the GitHub issue body records `minor-audit`. This child bundles four issues (#850, #788, #789, #851) across three hooks, one shared module, their Codex copies and their bundled mirrors, so the selected mode is `full-bug`. `spec.md` is the acceptance-criteria source; `user-story.md` is absent by design.

## Summary

Two PreToolUse gates still read PR-authoring and merge-authorization files relative to the session root instead of the worktree that owns the pull request. `enforce-pr-author-skill.ps1` reads `artifacts/pr_context.summary.txt`, `artifacts/pr_body_<N>.md` and `artifacts/pr_body_<N>.receipt.json` (including the receipt-freshness timestamp comparison) from the hook process directory, and the standalone-merge branch of `enforce-epic-merge-gate.ps1` reads its per-feature checkpoint from the session worktree. A child orchestrator working in a different worktree is denied with `PR_CONTEXT_MISSING` and `STANDALONE_MERGE_AUTHORIZATION_ABSENT`. This is the remainder of closed #690, which converted the checkpoint reads but kept these paths session-relative.

## Environment

- OS/version: Windows 11 Pro; Claude Code 2.1.284
- Python version: n/a (PowerShell PreToolUse hooks)
- Command/flags used: `gh pr create --body-file artifacts/pr_body_<N>.md --head <item-branch>` and `gh pr merge <N> --merge` issued by a non-isolated child orchestrator whose cwd is the coordinator session root, while the item's files live in another worktree
- Data source or fixture: parallel run bug-burndown-2026-09-29; items #543 (PR #829, merged 2026-10-07T14:59:00Z as 869c4fad) and #830 (PR #831, merged 2026-10-07T14:47:44Z as db608485); main at fb413fce

## Steps to Reproduce

1. Run an item in worktree A (for example `.claude/worktrees/agent-a97e4dd100a2bb82e` for #543) through a child orchestrator spawned without `isolation`, so the child's cwd is the coordinator session root B.
2. In worktree A, run `mcp__drm-copilot__collect_pr_context` and let pr-author write `artifacts/pr_body_<N>.md` and its receipt.
3. Issue `gh pr create --body-file artifacts/pr_body_<N>.md --head <item-branch>` from the child.
4. After CI is green, record a `standalone_merge_authorizations` entry in worktree A's `artifacts/orchestration/orchestrator-state.json` and issue `gh pr merge <N> --merge`.

## Expected Behavior

Both gates resolve the item's worktree once (the pr-author gate already does so for the checkpoint, through `Get-PrAuthorTargetCheckpointResolution`) and read the PR context summary, body file, receipt and merge-authorization checkpoint beneath that worktree. The receipt-freshness check compares the receipt with the summary from the same worktree. An unresolvable or ambiguous target denies with the `WorktreeRunResolution.psm1` reason codes.

## Actual Behavior

Step 3 is denied with `PR_CONTEXT_MISSING: artifacts/pr_context.summary.txt is absent` because the summary is looked up under B. Step 4 is denied with `EPIC_MERGE_GATE_BLOCKED: ... STANDALONE_MERGE_AUTHORIZATION_ABSENT` because the gate reads B's per-feature checkpoint, not A's. Both were observed on 2026-10-07 for #543 / PR #829 and #830 / PR #831. The coordinator worked around them by copying the item's `pr_context.*`, `pr_body_<N>.md`, receipt and checkpoint into B. The copies remain in the session-root worktree and are out of scope for this child; they must not be touched.

## Logs / Screenshots

- Snippet (code locations as of main fb413fce; re-derive against the integration branch before editing): pr-author gate, `.claude/hooks/enforce-pr-author-skill.ps1:48` sets `$script:PrContextArtifactPath = 'artifacts/pr_context.summary.txt'`; it is read with `Test-Path` at `:66` and `Get-Item ... LastWriteTimeUtc` at `:139-143`. `.claude/hooks/enforce-pr-author-skill-helpers.ps1:20-21` documents that the path "is a process-directory-relative artifact path and stays one". Body and receipt paths are built as relative strings at helpers `:176-177` and read at `:180` and `:203`; the freshness comparison is at `:231-233`. Check 1 at helpers `:171` accepts only the literal relative form `--body-file artifacts/pr_body_<N>.md`. The checkpoint is resolved per target at helpers `:356-362` (#673/#687). Merge gate: `.claude/hooks/enforce-epic-merge-gate.ps1:358-362` reads the child checkpoint at `Get-EpicMergeGateSessionWorktreeRoot` (`enforce-epic-merge-gate-resolution.ps1:128`). The standalone branch at `enforce-epic-merge-gate.ps1:393-402` consults only that child checkpoint plus the epic and parallel checkpoints.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Any child that does not run with its cwd inside the item worktree cannot open or merge its PR without manual file copies into the session root. The copies are gitignored, persist after the run, and can satisfy the gate for a later call: a stale `pr_context.summary.txt` from one item is compared against another item's receipt.

## Bundled Issues

This child (C3 of epic #852) delivers the following existing issues in the same pull request. No new issue is created. Acceptance criteria are authored in `spec.md`; the conditions below state what each bundled issue requires.

### #788 — merge gate child branch binds the PR number only when `pr_gate` exists

- Problem: `.claude/hooks/enforce-epic-merge-gate-resolution.ps1` (lines 177-185 at the time of filing) returns without binding the merge command's pull request number when the per-feature checkpoint has no `pr_gate` object or no `pr_gate.pr_number`. Routes that do not record `pr_gate` (for example `small`) therefore leave the decision unbound, and a merge command can be authorized by a checkpoint that belongs to a different item.
- Acceptance condition: the child branch binds the command's pull request number for every route (or resolves the child checkpoint by record through `WorktreeRunResolution.psm1`), and a merge command whose pull request number does not match the governing checkpoint's item is denied. A test covers a checkpoint with no `pr_gate` object and a mismatched pull request number.

### #789 — WorktreeRunResolution review nits CR-4 and CR-5

- CR-4 problem: `Test-WorktreeRunPathEqual` in `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` selects `OrdinalIgnoreCase` only when a side matches `^[A-Za-z]:`; UNC paths compare with `Ordinal`.
- CR-4 acceptance condition: UNC roots recorded with different casing (for example `//Server/Share/x` and `//server/share/X`) compare equal, proven by a Pester test.
- CR-5 problem: the final deny of `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` (lines 418-420 at the time of filing) builds a prefix that begins `PARALLEL_WORKTREE_REMOVAL_BLOCKED:` and then appends a second string that also begins with the token.
- CR-5 acceptance condition: the deny carries exactly one leading `PARALLEL_WORKTREE_REMOVAL_BLOCKED:` token when both run kinds resolve `NoTarget`, proven by a Pester test that counts occurrences.

### #851 — epic worktree removal gate denied a merged parallel item's worktree (diagnostics only)

- Problem: `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` denied `git worktree remove` for merged item #623's worktree although the parallel checkpoint recorded `merge_status: merged`. Re-evaluation on main fb413fce returns allow; there is no reproduction, and the deny text does not record enough to classify a recurrence.
- Scope: diagnostics only. The allow/deny decision is unchanged.
- Acceptance condition: when the epic worktree removal gate denies, the deny text names the run kind(s) that resolved, the checkpoint path read for each, and the `merge_status` found for the matching record (or that no record matched). The existing leading token `EPIC_WORKTREE_REMOVAL_BLOCKED:` is preserved. Tests prove the decision is unchanged for the existing allow and deny cases and that the new diagnostic fields appear in the deny text.

## Source

From: GitHub issue #850 (potential record `docs/features/potential/2026-10-08-pr-author-and-merge-gates-read-session-root-files.md` is not present on the integration branch).
