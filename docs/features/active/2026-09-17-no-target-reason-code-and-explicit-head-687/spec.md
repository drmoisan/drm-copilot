# Spec: NoTarget reason code and explicit --head (Issue #687)

- Issue: #687
- Work Mode: full-bug
- Last Updated: 2026-09-18
- Unblocks: #673 (false-approval elimination), and #674 behind it

## Problem

`Resolve-WorktreeCallTarget` (`.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`,
delivered by #669) derives a target worktree from one of three signals in precedence order:
feature-folder path, file path, branch. Its `BranchPattern` already matches `--head`, `--branch`
and `branch:`.

The PR gates cannot consume it, because real payloads carry none of the three signals. Of 62
sampled real `gh pr create` / `gh pr merge` command shapes, 0 derived a target: 61 resolved
`NoTarget` and 1 resolved `Ambiguous`. `gh pr create` infers its head branch from the current
checkout, and `gh pr merge <N>` carries only a PR number.

`ReasonCode` is non-null exactly when `Status` is `Ambiguous`
(`WorktreeTargetResolution.psm1:126`), so a `NoTarget` result carries no code. #673 halted
fail-closed because neither available mapping was permitted by its spec: substituting the session
root is the cwd fallback this epic exists to remove, and an ambiguity denial had no code to emit.

## Design decision: NoTarget is not uniformly a denial

Denying every `NoTarget` would break standalone topology, where exactly one item exists and the
session root genuinely is the correct target. "Epic and standalone topologies must behave exactly
as now when cwd and target coincide" is a must-not-regress constraint of the parent request.

The resolution is to make the target derivable at the call site rather than to guess at the gate:

- `pr-author` always passes `--head <branch>` on its `gh pr create` command, which the existing
  `BranchPattern` resolves. A standalone run therefore resolves to `SessionRoot` and is allowed
  exactly as today.
- A PR-gate call that still resolves `NoTarget` is one where the caller omitted the explicit
  target. That is the case the gate denies, with a distinct, greppable code naming the omission
  and the remedy.

This keeps the gate fail-closed without inferring an item from the session's cwd.

## Required Behavior

### R1 — NoTarget carries a distinct reason code

- `Resolve-WorktreeCallTarget` MUST populate `ReasonCode` for `Status = NoTarget` with a distinct,
  greppable constant, separate from the existing ambiguity code.
- `ReasonCode` MUST remain null for the resolved states `SessionRoot` and `OtherWorktree`.
- The existing ambiguity code and its value MUST be unchanged.
- The `NoTarget` result's `Signal`, `SignalValue` and candidate-list semantics MUST be unchanged;
  only `ReasonCode` becomes non-null.

### R2 — The PR gates deny an unresolvable PR-creation call

- `enforce-pr-author-skill.ps1` MUST resolve the call target through the module rather than
  reading a session-root-relative checkpoint path.

**Scope amendment (2026-09-18).** `enforce-model-routing-receipt.ps1` was in the original scope and
is deferred. It gates `Agent` delegation payloads, not `gh` command payloads, and those carry no
`--head` equivalent. Denying `NoTarget` there would block every delegation whose prompt does not
name a feature folder, which is a different policy question and a far larger blast radius than the
PR-creation path. `enforce-orchestration-preimplementation-gate.ps1` has the same session-root read
(line 27) and the same payload class. Both are tracked in the follow-up issue filed for the
Agent-payload gates. Defect 3.4 therefore remains open after this change; defect 3.2, the priority
case, is closed by it.
- When resolution yields `OtherWorktree`, the gate MUST validate against that worktree's
  checkpoint.
- When resolution yields `SessionRoot`, behaviour MUST be exactly as today.
- When resolution yields `NoTarget` or `Ambiguous` for a `gh pr create` / `gh pr edit --body*` /
  `gh pr merge` call, the gate MUST deny and surface the resolution's `ReasonCode`.
- A gate MUST NOT validate a call against a checkpoint belonging to a different item. This is
  defect 3.2 of the parent request.

### R3 — pr-author passes an explicit head

- The `pr-author` skill and agent contract MUST require `--head <branch>` on `gh pr create`.
- The requirement MUST be stated where the command is specified, so every caller emits it.

## Non-Goals

- Changing child-prompt construction, an explicit epic non-goal.
- Widening the merge gate's `pr_number` matcher.
- Fixing `enforce-orchestration-preimplementation-gate.ps1`, which has the same session-root read
  at line 27 and blocks implementation from a coordinating session. Tracked separately; it is a
  different hook with a different payload class.

## Acceptance Criteria

- [ ] AC-1: A `NoTarget` result carries a distinct, greppable `ReasonCode`.
- [ ] AC-2: `ReasonCode` is null for `SessionRoot` and `OtherWorktree`, and the ambiguity code is
      unchanged for `Ambiguous`.
- [ ] AC-3: `gh pr create --head <branch>` resolves to that branch's worktree and the gate
      validates against that worktree's checkpoint.
- [ ] AC-4: A PR-gate call resolving `NoTarget` denies, naming the `NoTarget` reason code.
- [ ] AC-5: A PR-gate call resolving `Ambiguous` denies, naming the ambiguity reason code.
- [ ] AC-6: The pr-author gate never returns allow on the basis of a checkpoint belonging to a different item. (The Agent-payload gates are deferred per the scope amendment above.)
- [ ] AC-7: Standalone topology, where cwd and target coincide, behaves exactly as today.
- [ ] AC-8: The `pr-author` skill and agent require `--head <branch>`.
- [ ] AC-9: Bundled copies under `extensions/drm-copilot/resources/claude-customizations/.claude/`
      are byte-identical to the repository copies for every changed file.
- [ ] AC-10: Pester coverage for the resolution matrix and both gates, including currently-passing
      cases as regression guards; line coverage >= 85%.

## Test Conditions

- Resolution: NoTarget yields the new code; Ambiguous yields the unchanged code; SessionRoot and
  OtherWorktree yield null.
- Gate: `--head` naming a sibling worktree's branch validates against that worktree's checkpoint,
  not the session root's.
- Gate: sibling's checkpoint is the only state present and the call names no target — deny with the
  NoTarget code (this is the currently-allowing false-approval case).
- Gate: standalone, cwd equals target — allow, unchanged.
- Gate: required document genuinely absent — deny, unchanged.
