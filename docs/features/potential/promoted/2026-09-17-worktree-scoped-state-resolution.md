# worktree-scoped-state-resolution (Issue #678)

- Date captured: 2026-09-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/worktree-scoped-state-resolution/ (Issue #678)

- Issue: #678
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/678
- Last Updated: 2026-09-17
## Problem / Why

Hooks and MCP tools resolve feature folders, checkpoints, and diff bases against the invoking
session's current working directory rather than against the worktree the tool call pertains to.
In a parallel or epic topology, where the coordinating session's cwd is a different worktree from
the item being acted on, this produces false denials and false approvals validated against a
sibling item's state. TaskMaster parallel run `bugs-2026-09-11` stalled completely on this defect
class (2026-09-12/13). Because `.claude/**` is pushed down to consumer repositories without
templating, the fix must land in drm-copilot.

This entry is the epic-level issue for the epic manifest at
`docs/features/epics/worktree-scoped-state-resolution/epic.md`. Child features: #669, #670, #671,
#672, #673, #674, #675.

## Proposed Behavior

- Resolve state against the tool call's target worktree; use the session root only when the call
  has no target (#669, #672, #673).
- Accept absolute paths by locating the containing worktree instead of fixed-segment truncation
  (#669, #672).
- Deny with a distinct, greppable reason code when the correct checkpoint cannot be identified;
  never validate against a sibling's checkpoint (#673).
- Make the pre-implementation staging exemption reachable with `git -C <worktree>` while keeping
  every other constraint (#671).
- Permit standalone merge only on an explicit, auditable authorization record without widening
  the `pr_number` matcher (#670).
- Make `collect_pr_context` take an explicit target and fail loudly on an empty diff (#675).
- Push down to TaskMaster and confirm the stalled run resumes (#674).

## Acceptance Criteria (early draft)

- [ ] All seven child features merged into the integration branch with CI green.
- [ ] No gate returns allow on the basis of a checkpoint belonging to a different item.
- [ ] Integration branch merged to `main` with the real `ci.yml` green.

## Constraints & Risks

- Gates must remain fail-closed; epic and standalone behavior is unchanged when cwd and target
  coincide.
- The pre-implementation gate's pathspec, option, and metacharacter restrictions must not weaken.
- The merge gate's matcher must not widen as a side effect.

## Test Conditions to Consider

- [ ] Table-driven Pester matrix: cwd (session root / item worktree) x path form (relative /
      absolute) x target (own / sibling / absent).
- [ ] Jest coverage for `collect_pr_context` explicit target and empty-diff failure.

## Next Step

- [x] Promote to GitHub issue (epic)
