---
name: epic-run
description: Execute a previously planned epic by replaying the committed epic-kickoff artifact through the epic-orchestrator agent. Use after /epic-plan has prepared the epic (issues, folders, research, specs, atomic plans, preflight clearance) and the user is ready to execute end-to-end.
argument-hint: "[epic-slug]"
context: fork
agent: epic-orchestrator
---

# Epic Run Skill

A user invocation (`/epic-run <epic-slug>`) forks the `epic-orchestrator` agent to execute an
epic that `epic-planner` has already prepared. The epic slug (or a path under
`docs/features/epics/`) for this run is:

$ARGUMENTS

## Procedure

1. Resolve the epic home. A bare slug resolves to `docs/features/epics/<epic-slug>/`; a path
   argument resolves to its containing epic folder.
2. Resolve the committed kickoff artifact `docs/features/epics/<epic-slug>/epic-kickoff.md`. It
   may exist only on the epic integration branch: `epic-plan` commits it to
   `epic/<epic-slug>-integration` (worked in a separate integration worktree), so the worktree
   that invokes `/epic-run` is not guaranteed to have it checked out. Discover it across both
   locations before concluding it is missing:
   - Attempt `git fetch origin epic/<epic-slug>-integration`. A failure because the remote
     branch does not exist is the genuine "epic not planned" case; tolerate it and continue to
     the local check rather than treating the fetch failure as fatal.
   - Treat the artifact as present when EITHER the plain local path exists in the invoking
     worktree, OR it exists on the fetched integration ref, tested with
     `git cat-file -e epic/<epic-slug>-integration:docs/features/epics/<epic-slug>/epic-kickoff.md`
     (equivalently `origin/epic/<epic-slug>-integration:<path>`).
   - When the artifact is present only on the integration ref, read its content with
     `git show <ref>:<path>`. That is sufficient to extract the `## Invocation Prompt` text
     needed to proceed; do NOT check the integration branch out into the invoking worktree — the
     session worktree must never be checked out onto the integration branch (worktree-isolation
     convention).
   - STOP without delegating anything only when the artifact is absent BOTH locally and on the
     fetched integration branch (the branch does not exist, or exists but lacks the file). In
     that case report that the epic has no committed kickoff artifact: the user must run
     `/epic-plan` first (or, for an epic that was authored manually, invoke
     `/epic-orchestrate <epic-manifest-path>` directly).
3. Execute the kickoff artifact's `## Invocation Prompt` section as the epic objective, applying
   the `epic-orchestrate` skill procedure and the `## Prepared-Epic Execution (epic-planner
   Handoff)` section of `.claude/agents/epic-orchestrator.md`: reuse the existing integration
   branch, and have each child `Agent(orchestrator)` delegation resume at atomic execution from
   its committed `plan-path` rather than re-running promotion, research, or planning.
4. Honor existing checkpoint state: if `artifacts/orchestration/epic-orchestrator-state.json`
   already tracks this epic, resume per the `epic-orchestrate` skill's resume procedure instead
   of restarting.

## Scope

This skill adds no procedure of its own beyond kickoff-artifact resolution; wave scheduling,
the wave barrier, merge-on-green fan-in, worktree cleanup, `epic-status.md` maintenance, and
the final integration-to-`main` PR are governed entirely by the `epic-orchestrate` skill. A child
merge into the integration branch requires a green `CI` run on the child head SHA; see
`Epic-child CI verification (issue #1130)` under `## Merge-on-Green Kickoff Parameter` in that skill.

An early dependent start (manifest field `early_start_on`) is governed by
`## Early Dependent Starts (early_start)` of the `epic-orchestrate` skill; a manifest without that
field runs exactly as described above. A cross-epic dependency (manifest key `cross_epic_depends_on`)
is governed by `## Cross-Epic Dependencies (cross_epic_depends_on)` of the same skill, and a run
halted with `blocked_reason: "external_dependency"` resumes by running this skill again on the
same epic slug.

## Nesting Depth

This chain runs three levels of subagents below the main session: the coordinator at depth 1, each per-feature `orchestrator` at depth 2, and the specialists that orchestrator delegates to at depth 3. Only the depth-2 orchestrator needs the `Agent` tool below the coordinator; specialists do not delegate.

Requirement: Claude Code 2.1.219 or later, `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` unset or at least 3, and the skill invoked from the main session. A run started inside a subagent or fork adds one layer, and a lower limit withholds the `Agent` tool from the per-feature orchestrators.

Outcome when the depth is insufficient: an agent that starts without the `Agent` tool records `blocked_reason: "spawn_agent_unavailable"`, does no specialist work, and returns a line beginning `AGENT_TOOL_UNAVAILABLE`; a coordinator that receives that line from a child halts with the same reason instead of doing the child's work. The `enforce-epic-invocation-origin.ps1` hook also denies a chain delegation with `NESTING_DEPTH_INSUFFICIENT:` when the configured limit is below 3.

Fallback: when the depth cannot be raised, the main session itself launches each per-feature `Agent(orchestrator)` with the same delegation prompt the coordinator would have sent, including `Preparation mode: true` on the preparation path, so each orchestrator runs at depth 1 and its specialists at depth 2.
