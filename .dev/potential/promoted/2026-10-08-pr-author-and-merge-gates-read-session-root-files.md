# pr-author-and-merge-gates-read-session-root-files (Issue #850)

- Date captured: 2026-10-08
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pr-author-and-merge-gates-read-session-root-files/ (Issue #850)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #850
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/850
- Last Updated: 2026-10-08
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

Step 3 is denied with `PR_CONTEXT_MISSING: artifacts/pr_context.summary.txt is absent` because the summary is looked up under B. Step 4 is denied with `EPIC_MERGE_GATE_BLOCKED: ... STANDALONE_MERGE_AUTHORIZATION_ABSENT` because the gate reads B's per-feature checkpoint, not A's. Both were observed on 2026-10-07 for #543 / PR #829 and #830 / PR #831. The coordinator worked around them by copying the item's `pr_context.*`, `pr_body_<N>.md`, receipt and checkpoint into B (run notes `standing_rules.pr_context_missing` and `standing_rules.blocked_merge`). The copies are still present: `artifacts/pr_body_543.*`, `artifacts/pr_body_830.*`, `artifacts/pr_context.summary.txt` (last write 2026-10-07 10:23 local) and `artifacts/orchestration/handoff/orchestrator-state.issue-830.2026-10-07T14-47.json` in the session-root worktree. The deny texts were observed in the run; the code paths below were confirmed by reading main at fb413fce.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: pr-author gate, `.claude/hooks/enforce-pr-author-skill.ps1:48` sets `$script:PrContextArtifactPath = 'artifacts/pr_context.summary.txt'`; it is read with `Test-Path` at `:66` and `Get-Item ... LastWriteTimeUtc` at `:139-143`. `.claude/hooks/enforce-pr-author-skill-helpers.ps1:20-21` documents that the path "is a process-directory-relative artifact path and stays one". Body and receipt paths are built as relative strings at helpers `:176-177` and read at `:180` and `:203`; the freshness comparison is at `:231-233`. Check 1 at helpers `:171` accepts only the literal relative form `--body-file artifacts/pr_body_<N>.md`, so a caller cannot point the gate at another worktree with an absolute path. The checkpoint, by contrast, is resolved per target at helpers `:356-362` (#673/#687). Merge gate: `.claude/hooks/enforce-epic-merge-gate.ps1:358-362` reads the child checkpoint at `Get-EpicMergeGateSessionWorktreeRoot` (`enforce-epic-merge-gate-resolution.ps1:128`, `Resolve-WorktreeOperandTarget -Path '' -SessionRoot (Get-Location).Path`). The standalone branch at `enforce-epic-merge-gate.ps1:393-402` consults only that child checkpoint plus the epic and parallel checkpoints; no item checkpoint outside the session worktree is ever read for `standalone_merge_authorizations`.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Any child that does not run with its cwd inside the item worktree cannot open or merge its PR without manual file copies into the session root. The copies are gitignored, persist after the run, and can satisfy the gate for a later call: a stale `pr_context.summary.txt` from one item is compared against another item's receipt, so the copy procedure has to preserve original timestamps (`standing_rules.blocked_merge`) to avoid a false `PR_AUTHOR_RECEIPT_STALE` or a false pass.

## Suspected Cause / Notes

#690 (spec `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/spec.md:298-303`) kept the merge gate's child branch on the session-root read on the assumption that "the child merges from its own isolated worktree", and the pr-author artifact paths were left process-relative. Both assumptions fail for non-isolated children, which the run used for #543 because the operator required it to resume in its existing worktree. Related open issues: #787 (`validate-orchestrator-output.ps1` session-relative read at SubagentStop) and #788 (merge-gate child branch without `pr_gate`); neither covers these files.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: in the pr-author gate, derive one worktree root from `Get-PrAuthorTargetCheckpointResolution` and compose the summary, body and receipt paths beneath it; keep the canonical `artifacts/pr_body_<N>.md` form as a repo-relative path resolved against that root. Pester rows: files present only in a non-session worktree (allow), absent there but present at the session root (deny), and a freshness comparison that uses the target worktree's summary.
- [ ] Integration scenario to retest: in the merge gate, resolve the child checkpoint by record when the command names a PR number (`Resolve-WorktreeRunTargetByRecord` accepts only `-Kind epic|parallel` today, `WorktreeRunResolution.psm1:381-382`, so an `item` kind or an equivalent lookup by `pr_gate.pr_number` / branch is needed), and evaluate `standalone_merge_authorizations` from that checkpoint; Pester rows for authorization present only in another worktree (allow) and in none (deny with `STANDALONE_MERGE_AUTHORIZATION_ABSENT`).
- [ ] Manual verification notes: repeat the #543 topology (non-isolated child, existing worktree) and confirm `gh pr create` and `gh pr merge` pass without copying files into the session root.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
