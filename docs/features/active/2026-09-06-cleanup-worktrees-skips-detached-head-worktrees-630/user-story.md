# User Story: detached-worktree classification and consolidation-branch ordering (Issue #630)

- Issue: #630 (<https://github.com/drmoisan/drm-copilot/issues/630>)
- Feature folder: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/`
- Work mode: `full-bug`
- Epic: `cleanup-merged-worktrees-hardening`, child A (gaps 1 and 6)

## Why This Document Exists Under `full-bug`

Under the `full-bug` work mode, `.claude/skills/acceptance-criteria-tracking/SKILL.md` names
`spec.md` as the sole acceptance-criteria source, and a `user-story.md` is normally not produced.
This feature carries one anyway, for a preparation-readiness reason rather than a work-mode reason.

`scripts/dev_tools/epic_planner_readiness.py` validates that every prepared epic-child feature
folder contains a fixed set of required files. The required-file loop is at
`scripts/dev_tools/epic_planner_readiness.py:187`:

```python
for name in ("issue.md", "spec.md", "user-story.md"):
    _, file_errors = _read_required(
        context, f"{folder}/{name}", label=f"{prefix} {name}"
    )
    errors.extend(file_errors)
```

Each name in that tuple is passed to `_read_required`, which appends a readiness error when the file
is absent. Because this feature is child A of the `cleanup-merged-worktrees-hardening` epic and is
prepared through the `/epic-plan` route, an absent `user-story.md` would fail epic-planner execution
readiness even though the `full-bug` work mode does not otherwise call for one.

Two consequences follow, and both are stated plainly:

- `spec.md` remains the sole acceptance-criteria source for this feature. Executors and reviewers
  resolve acceptance criteria from `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`
  and from nowhere else.
- **This document carries no acceptance criteria and no acceptance-criteria checkboxes.** Nothing in
  it is to be checked off, counted toward an acceptance-criteria total, or treated as a delivery
  obligation. It exists as an epic-preparation readiness artifact and as operator-facing context.

## Operator Narrative

**Who.** A developer or agent running `/cleanup-merged-worktrees` on a large checkout — one with
tens of registered worktrees accumulated from prior epic runs, parallel sessions, and preparation
branches.

**Current experience.** The operator runs report mode and reads a list of worktree registrations.
Some of those registrations show a branch and a classification; others show only
`WORKTREE|<path>|DETACHED|<flags>` and nothing more. The operator then runs `--apply`, and the
detached registrations are still there afterwards. No error was printed and no line explained the
omission, so there is nothing in the output to distinguish "this worktree was examined and kept" from
"this worktree was never examined". In the 2026-09-06 TaskMaster run recorded at
`research/2026-09-06-cleanup-run-observations-user-context.md`, 30 of 57 registered worktrees fell
into this category — preparation worktrees, epic-child baselines, and agent worktrees whose branch
had been deleted earlier. Clearing them required removing each registration by hand.

A second, narrower experience concerns the consolidation step. When the skill creates the
`documentationandmemories` branch at `main` and the operator runs `--apply` before the first
consolidation commit lands, the branch and its worktree are deleted as `MERGED_CLEAN`. The operator
sees a deletion that looks routine and has no signal that the branch had not yet done its job.

**Experience after this change.** Report mode prints a state for every detached registration, drawn
from the same vocabulary used for branches, so the operator can tell at a glance which detached
worktrees are already represented on `main` and which are not. The `locked` and `prunable` flags stay
visible in the record, so the operator knows before running `--apply` which registrations apply mode
will decline to touch.

Apply mode then removes the detached worktrees that are delete-eligible and clean, using the same
non-forced `git worktree remove` it uses for branch-backed worktrees, and prints one
`ACTION|worktree-remove|<path>|OK` line for each. Anything it declines to remove is reported with the
reason: `BLOCKED-DIRTY` when the working tree has content, `BLOCKED-LOCKED` when the registration is
locked, `BLOCKED-REVERIFY` when the same-process re-check disagrees with the report. Nothing is
removed silently, and nothing eligible is skipped silently.

The consolidation branch is no longer deleted while its tip equals `main`. Apply mode prints
`ACTION|delete|documentationandmemories|BLOCKED-CONSOLIDATION-UNMERGED` and moves on, leaving the
branch and its worktree in place until the consolidation commit exists.

**What the operator must still do by hand.** Two behaviors are unchanged and remain visible:

- A dirty detached worktree still blocks. Classifying the dirt and offering an opt-in clearing path
  is a separate epic child (issue 902) and is not delivered here.
- After this change, a run in which any detached removal is blocked exits non-zero from `--apply`,
  where such a checkout previously exited 0. This is intended and consistent with how a blocked
  branch-backed removal already behaves; it is recorded in `spec.md` under `## Behavioral Contract`
  so it is not later read as a regression.

**Scope boundary the operator will notice.** Report mode still does not list orphan directories,
stale `refs/remotes/child/*` refs, or lost registrations, and there is still no removal manifest.
Those are other children of the same epic. `spec.md` records the full boundary in its `## Non-Goals`
section.

## Reference

- Acceptance criteria: `docs/features/active/2026-09-06-cleanup-worktrees-skips-detached-head-worktrees-630/spec.md`, `## Acceptance Criteria`.
- Defect mechanisms, citations, and design: `research/2026-09-06-detached-worktree-classification-and-consolidation-ordering.md`.
- Verbatim run observations: `research/2026-09-06-cleanup-run-observations-user-context.md`.
- Epic scope and child boundaries: `docs/features/epics/cleanup-merged-worktrees-hardening/epic.md`.
