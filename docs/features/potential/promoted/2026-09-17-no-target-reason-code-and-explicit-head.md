# no-target-reason-code-and-explicit-head (Issue #687)

- Date captured: 2026-09-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/no-target-reason-code-and-explicit-head/ (Issue #687)

- Issue: #687
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/687
- Last Updated: 2026-09-17
## Problem / Why

Child #673 of epic #678 (false-approval elimination) halted fail-closed at its plan gate before
editing any hook file, and #674 is blocked behind it.

`Resolve-WorktreeCallTarget` in `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`
(delivered by #669) derives a target worktree from one of three signals, in precedence order:
a feature-folder path, a file path, or a branch. Its `BranchPattern` already matches `--head`,
`--branch`, and `branch:`.

The PR gates cannot use it, because real payloads carry none of the three signals. Of 62 sampled
real `gh pr create` / `gh pr merge` command shapes, 0 derived a target: 61 resolved `NoTarget` and
1 resolved `Ambiguous` (a relative `artifacts/pr_body_1.md` matching 12 worktrees). `gh pr create`
infers its head branch from the current checkout and `gh pr merge <N>` carries only a PR number.

Neither available mapping for `NoTarget` is permitted by #673's spec:

- Substituting the session root is the cwd fallback epic #678 exists to remove. In a parallel
  topology the session root is a sibling item's checkpoint, which is defect 3.2 itself.
- Emitting an ambiguity denial has no code to emit: `ReasonCode` is non-null exactly when
  `Status` is `Ambiguous`, so `NoTarget` carries none.

## Proposed Behavior

User ruling of 2026-09-17, recorded here as the approved approach:

1. Add a distinct, greppable `NoTarget` reason code to the resolution module, so the state is
   nameable rather than silent. `ReasonCode` stops being exclusive to `Ambiguous`.
2. Make the PR gates (`enforce-pr-author-skill.ps1`, `enforce-model-routing-receipt.ps1`) deny on
   `NoTarget` with that code rather than falling back to the session root. This satisfies the
   original requirement that a gate never report success on the strength of unrelated state.
3. Require `pr-author` to pass `--head <branch>` on its `gh pr create` command, which the existing
   `BranchPattern` already resolves. This is a command-argument change in the pr-author contract,
   not child-prompt construction (an explicit epic non-goal).

This closes defect 3.2 without dropping any of #673's user-stated acceptance criteria
(AC-9, AC-10, AC-13, AC-16, AC-17), which was why amending them was rejected.

## Acceptance Criteria (early draft)

- [ ] `NoTarget` carries a distinct, greppable reason code.
- [ ] The PR gates deny on `NoTarget` with that code; no session-root fallback remains on that path.
- [ ] A `gh pr create` command carrying `--head <branch>` resolves to that branch's worktree.
- [ ] #673 can resume and satisfy AC-9, AC-10, AC-13, AC-16 and AC-17 unchanged.

## Constraints & Risks

- Gates must stay fail-closed; epic and standalone topologies unchanged when cwd and target coincide.
- The merge gate's `pr_number` matcher must not widen.
- Requiring `--head` changes a command contract; every pr-author caller must be updated together,
  or PR creation denies on the new reason code.

## Test Conditions to Consider

- [ ] Pester: the 62 sampled payload shapes, asserting a named `NoTarget` rather than a silent one.
- [ ] Pester: `gh pr create --head <branch>` resolves; a sibling's checkpoint is never consulted.

## Next Step

- [x] Promote to GitHub issue
