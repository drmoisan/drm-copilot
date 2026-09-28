# preimplementation-gate-worktree-selector (Issue #671)

- Date captured: 2026-09-13
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/preimplementation-gate-worktree-selector/ (Issue #671)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #671
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/671
- Last Updated: 2026-09-14
## Summary

The issue #539 orchestration-bookkeeping staging exemption in
`.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` models `git add` and
`git commit` as accepting no repository selector, so `git -C <worktree> add <exempt-pathspec>`
is denied. The exemption is therefore reachable only when the invoking shell's current working
directory is already the target worktree, which makes it unreachable from a coordinating
session in a parallel or epic topology.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: not applicable (the gate is PowerShell only)
- Command/flags used: `git -C <worktree> add docs/features/epics/<epic>/epic.md`
- Data source or fixture: `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`

## Steps to Reproduce

1. Open a coordinating session whose current working directory is the session root worktree.
2. Issue `git add -- docs/features/epics/worktree-scoped-state-resolution/epic.md` as a single
   unchained segment. The gate allows it.
3. Issue the same `git add` chained behind `cd <other-worktree> &&`. The gate denies it with
   `PREIMPLEMENTATION_GATE_BLOCKED`, because the chained `cd` segment is not a recognized
   all-exempt invocation.
4. Issue `git -C <other-worktree> add -- docs/features/active/<folder>/spec.md`. The gate denies
   it, because `Test-ExemptOrchestrationSegmentToken` requires `Token[1]` to be `add` or
   `commit` and `Token[1]` is `-C`.

## Expected Behavior

The exemption bounds *what* may be staged or committed, not *from where*. A repository selector
that names an explicit target directory should be permitted while every other constraint stays
in force: restricted pathspec prefixes, `-m` / `--message` as the only modelled option, a single
unchained segment, and no shell metacharacters.

## Actual Behavior

`git -C <worktree> add <exempt-pathspec>` is denied. `Test-ExemptOrchestrationSegmentToken`
enforces D4 row 14 — the command name leads the segment and the subcommand follows it
immediately — so any token between `git` and the subcommand rejects the segment. The comment on
that branch states the rejection is deliberate for "a relocating option", which is exactly the
`-C` form.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `PREIMPLEMENTATION_GATE_BLOCKED` on a `cd <worktree> && git add -- docs/features/...`
  chain issued 2026-09-13 during epic planning for `worktree-scoped-state-resolution`, alongside
  an allow for the same `git add` issued as a single unchained segment.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

During TaskMaster parallel run `bugs-2026-09-11` a rate limit terminated every agent mid-task.
Seven items' preparation output was uncommitted in child worktrees and the coordinating session
could not stage it, because every route to those worktrees required either a `cd` chain or a
`-C` selector. Recovery required messaging each surviving child individually.

## Suspected Cause / Notes

- `Test-ExemptOrchestrationSegmentToken` (helpers file) rejects any token between the command
  name and the subcommand, per D4 row 14.
- `Test-ExemptOrchestrationOperand` rejects rooted, drive-lettered, and UNC spellings, so a
  `-C` operand naming an absolute worktree directory is not covered by the existing operand
  classifier and needs its own rule.
- The three-file hook set is `enforce-orchestration-preimplementation-gate.ps1` (495 lines),
  `-helpers.ps1` (349 lines), and `-modes.ps1` (480 lines) against a 500-line cap.
- `.codex/hooks/` mirrors all three files; the Codex gate file is 500 lines with zero headroom.
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` carries bundled copies
  that must be updated in the same change, or the push-down publishes stale content.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: table-driven Pester over the cross product of current working
      directory (session root vs item worktree), path form (relative vs absolute), and target
      (own item vs sibling vs absent).
- [x] Integration scenario to retest: a coordinating session stages and commits an exempt
      pathspec in a child worktree using `git -C`.
- [x] Manual verification notes: confirm the option, pathspec, metacharacter, and single-segment
      restrictions are byte-unchanged on every axis other than the selector.

Open design question the specification must settle: whether the `-C` operand must resolve inside
the repository's worktree set, and what the gate does with a selector that points outside it.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
