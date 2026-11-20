# 2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate (User Story)

- **Issue:** #634
- **Parent (optional):** epic `cleanup-merged-worktrees-hardening`, child G (gap 4)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-06
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** `full-bug`

## Why this file exists in a `full-bug` feature

`full-bug` mode does not normally produce a `user-story.md`. This file is present for a mechanical
reason, not as a mode violation:
`scripts/dev_tools/epic_planner_readiness.py` requires `issue.md`, `spec.md`, and `user-story.md`
in every prepared epic child folder. The orchestrator verified this in this session at line 187 of
that file, where the readiness check iterates the tuple `("issue.md", "spec.md", "user-story.md")`
and records a missing-file error for each name it cannot read. This feature is a prepared child of
the `cleanup-merged-worktrees-hardening` epic, so the readiness check applies to it.

**`spec.md` remains the sole acceptance-criteria source for this feature**, per the `full-bug` row
of the AC-source table in `.claude/skills/acceptance-criteria-tracking/SKILL.md`. This document
therefore carries narrative and value framing only. **It contains no acceptance criteria and no
checkbox items**, and no agent should track delivery against it.

## Story

**As an** operator running a `/cleanup-merged-worktrees` session,
**I want** the skill to state, before the run starts, that the consolidation pull request's merge
is mine to perform and why,
**so that** I plan for the handoff instead of discovering it partway through step 5 as an
unexplained `EPIC_MERGE_GATE_BLOCKED` denial.

## Value

The operator's current experience is that the cleanup workflow reads as fully agent-driven through
step 6. Step 5's heading is "Wait for merge and verify git-natively" and its body is passive
("After the consolidation PR merges"), so the text neither claims the agent performs the merge nor
says who does. The operator learns the answer only when the session reaches step 5 and the merge
command is denied.

That denial is correct behavior, and it is not the problem. The problem is that it arrives without
explanation, at the least convenient point in the run, and it looks like a defect. An operator who
reads it as a defect has two bad options: route around the gate, or stop and investigate a hook
they did not expect to be involved.

After this change the operator knows three things before starting:

1. **Who merges.** The operator does, outside the agent session.
2. **Why.** The merge command is outside the skill's `allowed-tools`, outside
   `.claude/settings.json` `permissions.allow`, and denied by
   `.claude/hooks/enforce-epic-merge-gate.ps1` with `EPIC_MERGE_GATE_BLOCKED`.
3. **What to expect at the boundary.** The agent reports the pull request's URL or number and
   stops. The ruleset on `main` sets `strict_required_status_checks_policy`, so the branch must be
   up to date with `main` before the merge becomes available. The wait is not bounded within a
   session.

The change also protects a second reader: a future agent that hits the denial. The skill's
`## Prohibited Shortcuts` section will state that the skill never issues the merge command and
never writes or edits an orchestration checkpoint in order to satisfy the merge gate. That closes
the specific evasion of writing an `artifacts/orchestration/orchestrator-state.json` carrying
`epic_mode: true` and `step9_status: "passed"`, which the gate's child-feature accept path would
honour for any pull-request number.

## Actors

- **Primary — the operator running a `/cleanup-merged-worktrees` session.** Performs the
  consolidation merge. Needs the handoff disclosed up front.
- **Secondary — the agent executing the skill.** Reports the pull request at the handoff boundary
  and stops. Needs the denial explained so it does not treat the gate as a defect.
- **Secondary — a future maintainer of the merge gate.** Needs the cross-reference explaining why a
  cleanup run satisfies none of the gate's three checkpoint shapes, so the absence of a fourth
  shape reads as a decision rather than an oversight.

## Scenario narrative

1. The operator starts a cleanup session. Reading the skill's End-to-End Workflow before the run,
   they see at step 5 that the consolidation merge is human-performed and why.
2. The run proceeds through detection, editorial triage, consolidation onto
   `documentationandmemories`, and the `Agent(pr-author)` handoff that opens the pull request.
3. At step 5 the agent reports the pull request's URL or number and stops. No merge command is
   issued, so no denial occurs.
4. The operator merges the pull request themselves once the required checks are green and the
   branch is up to date with `main`.
5. The operator resumes the session. The existing git-native verification
   (`git merge-base --is-ancestor documentationandmemories main`) confirms the consolidated commits
   are reachable from `main`, which unlocks step 6's apply-mode deletion.

## Out of scope for this story

Making the merge unattended. That would require widening the skill's `allowed-tools` and granting a
project-level permission for an agent to merge into `main` without supervision. Those are
governance decisions recorded as out of scope in `spec.md`, not part of this story.

## References

- Acceptance criteria and the full decision record: `spec.md` in this folder.
- Skill under change: `.claude/skills/cleanup-merged-worktrees/SKILL.md`, mirrored at
  `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`.
- Gate that produces the denial: `.claude/hooks/enforce-epic-merge-gate.ps1`.
- Epic: `docs/features/epics/cleanup-merged-worktrees-hardening/epic.md`.
