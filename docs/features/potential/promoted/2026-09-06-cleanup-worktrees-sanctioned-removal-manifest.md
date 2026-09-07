# cleanup-worktrees-sanctioned-removal-manifest (Issue #635)

- Date captured: 2026-09-06
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/cleanup-worktrees-sanctioned-removal-manifest/ (Issue #635)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #635
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/635
- Last Updated: 2026-09-07
## Summary

The `cleanup-merged-worktrees` skill has no sanctioned way to run `git worktree remove` from a
Bash tool call. Two PreToolUse hooks deny the command unconditionally unless an epic or parallel
orchestrator checkpoint already records the exact target path with `merge_status` in
`{merged, worktree_removed}`, and the skill's own `allowed-tools` list does not grant
`Bash(git worktree remove*)` at all. During the 2026-09-06 `/cleanup-merged-worktrees` run the
only way to complete the removals was to write them into a script file and invoke `bash <file>`,
which neither hook inspects. That is a hook bypass in all but name. Separately, the skill
hard-codes `<N> = 396` for the `pr-author` body-file and receipt contract, so every run reuses one
run's PR number.

## Environment

- OS/version: Windows 11 Pro 10.0.26200, PowerShell 7+ (`pwsh`), Git Bash for the Bash tool
- Python version: n/a (the enforcement surface is PowerShell; `.claude/rules/general-code-change.md`
  and the epic's shared constraints prohibit a Python leg in enforcement hooks)
- Command/flags used: `bash scripts/bash/cleanup-worktrees.sh`, then
  `bash scripts/bash/cleanup-worktrees.sh --apply`, then per-worktree `git worktree remove <path>`
- Data source or fixture: the 2026-09-06 `/cleanup-merged-worktrees` run on the TaskMaster checkout
  (45 branches classified, 7 worktrees removed, 30 detached worktrees invisible to apply mode,
  14 dirty worktrees blocked)

## Steps to Reproduce

1. Run `bash scripts/bash/cleanup-worktrees.sh` in report mode and complete the Dirty Worktree
   Triage Procedure in `.claude/skills/cleanup-merged-worktrees/SKILL.md` until one or more
   worktrees carry a `SAFE_TO_DELETE` verdict with recorded justification.
2. Issue the removal the verdict authorizes as a single Bash tool call:
   `git worktree remove <path>`.
3. Observe the PreToolUse denial. `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` denies
   with `EPIC_WORKTREE_REMOVAL_BLOCKED` and `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`
   denies with `PARALLEL_WORKTREE_REMOVAL_BLOCKED`. PreToolUse denials are conjunctive, so both
   gates must allow for the command to proceed and either one alone is sufficient to block it.
4. Write the same removals into a shell script file and run `bash <file>`. Both hooks inspect only
   `tool_input.command`, so neither sees the removal and both allow the invocation.

## Expected Behavior

The skill has a sanctioned, auditable path for a removal it has already justified, and that path is
narrower than "any removal at all", not wider. A removal that a recorded verdict and its evidence
cover is allowed; a removal that no record covers is still denied with the existing reason code.
The skill's `allowed-tools` grant matches whatever command the sanctioned path actually uses. The
`pr-author` body-file number is derived rather than hard-coded, or the fixed value is justified in
the skill text.

## Actual Behavior

- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1:147` matches
  `'(?i)\bgit\s+worktree\s+remove\s+(?<path>\S+)'` against the Bash command text and then requires
  a checkpoint record. `Invoke-EpicWorktreeRemovalGateDecision` reaches
  `Get-EpicWorktreeGateBlockDecision` for every path that neither
  `artifacts/orchestration/epic-orchestrator-state.json` nor
  `artifacts/orchestration/parallel-orchestrator-state.json` authorizes. There is no third branch.
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1:70` carries a byte-identical copy of
  that regex and denies independently through `Test-ParallelWorktreeRemovalAllowed`.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` lines 1-23 grant
  `Bash(bash scripts/bash/cleanup-worktrees.sh *)` and `Bash(git worktree list*)` but do not grant
  `Bash(git worktree remove*)`. The removal is therefore blocked twice over: by the missing tool
  grant and by the two hooks.
- `.claude/skills/cleanup-merged-worktrees/SKILL.md:104` reads
  "using `<N> = 396` for the body-file and receipt contract". This is the single occurrence of the
  literal in the file. Every subsequent run therefore writes `artifacts/pr_body_396.md` and
  `artifacts/pr_body_396.receipt.json` regardless of the PR the run actually opens, and the
  `enforce-pr-author-skill.ps1` receipt check compares `number` against that stale value.

## Logs / Screenshots

- [x] Attached minimal logs or snippet
- Snippet (the deny reason emitted by the epic gate):

  ```text
  EPIC_WORKTREE_REMOVAL_BLOCKED: git worktree remove for '<path>' requires either an epic
  checkpoint features[] record with merge_status in {merged, worktree_removed}, or a
  parallel-orchestrator checkpoint with route_id == "parallel" whose matching items[] record
  (matched by worktree_path) has merge_status in {merged, worktree_removed}. No checkpoint
  authorized this removal.
  ```

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The enforcement outcome is worse than either a clean allow or a clean deny. The operator who needs
the removal reaches for the file-indirection workaround, which suppresses the gate for every
removal in the file including ones no verdict covers, so the gate's protective value is lost
precisely in the runs where it was intended to apply. A run that ends with an incorrect
`pr_body_396` pairing additionally fails the `enforce-pr-author-skill.ps1` receipt `number` check
or, worse, passes it against the wrong PR.

## Suspected Cause / Notes

The gates were written for the epic and parallel orchestration surfaces, where every legitimate
removal target is already recorded in a checkpoint. The `cleanup-merged-worktrees` skill removes
worktrees that no orchestration checkpoint ever recorded, so it falls into the gates' fail-closed
default with no route out.

Files to inspect:

- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` (418 lines; 82 lines of headroom against
  the 500-line cap in `.claude/rules/general-code-change.md`)
- `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` (280 lines)
- `.claude/skills/cleanup-merged-worktrees/SKILL.md` (264 lines)
- `.claude/lib/hook-payload/HookPayload.psm1` (496 lines; 4 lines of headroom, so it cannot absorb
  new helpers)
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` (428 lines)
- `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` (392 lines)

Interaction with issue #545: that issue replaces the substring command matching in the gate hooks —
including the regex at `enforce-epic-worktree-removal-gate.ps1:147` — with a shared, tested
command-word parser under `.claude/lib/`. This fix must confine itself to the hooks'
manifest-acceptance policy and must read the extracted removal path from whatever detection
function is in place after #545 lands, rather than reimplementing or re-anchoring the detection.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: a new manifest-parsing PowerShell module and both gate hooks' decision
      functions, driven through their existing injectable read seams with no temporary files;
      Pester line coverage >= 85% per `.claude/rules/quality-tiers.md`
- [x] Integration scenario to retest: a bare `git worktree remove` targeting an epic or parallel
      item worktree that no manifest covers must still be denied with its existing reason code —
      pinned by a test that fails if the manifest acceptance is written too broadly
- [x] Manual verification notes: the `.claude/**` edits must be mirrored byte-identically into
      `extensions/drm-copilot/resources/claude-customizations/.claude/**`, enforced by
      `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`

Two candidate designs were named in the run observations and exactly one must be chosen and
specified completely:

- **(a) Manifest-aware hooks.** The skill writes a cleanup manifest at
  `artifacts/orchestration/cleanup-worktrees-manifest.json` recording each path with its verdict
  and the evidence that produced it; the gates gain a third authorization branch that allows a
  removal whose target the manifest covers with a removal-authorizing verdict.
- **(b) Script-routed removal.** All skill removals go through
  `bash scripts/bash/cleanup-worktrees.sh --apply --manifest <path>` and the hooks recognize that
  invocation.

Under either design the hooks must keep denying a bare `git worktree remove` for an epic or
parallel item worktree that no manifest covers. The chosen design's manifest record shape is a
cross-module contract: a sibling change (the `PRESERVE`-file consolidation work) reads
`PRESERVE`-marked untracked and modified files out of the same manifest, so the record shape must
accommodate per-file `PRESERVE` entries alongside per-worktree removal entries, or must state
explicitly where those entries live and how the consumer reads them.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
