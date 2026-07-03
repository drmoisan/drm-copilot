# `epic-orchestrate` — User Story

- Issue: #275
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-02T20-30

## Story Statement

- As the repository's orchestration operator, I want to hand a dependency graph of child features to a single `epic-orchestrator` and have it schedule, parallelize, and fan the results back into a shared integration branch autonomously, so that a multi-feature epic delivers with the same no-human-interaction guarantee that single-feature orchestration already provides.
- As the repository's orchestration operator, I want every epic-mode invariant (base-branch targeting, merge-on-green, wave ordering, worktree cleanup) enforced by hooks and validators rather than by agent-followed prose, so that a delegate's mistake or omission cannot silently corrupt the epic's integration branch or merge a feature before its dependencies are ready.

## Problem / Why

The repository has a working single-feature orchestrator (`.claude/skills/orchestrate/SKILL.md`, `.claude/agents/orchestrator.md`) that runs one feature end-to-end: change-budget routing, delegation to `atomic-planner`/`atomic-executor`/`feature-review`/`pr-author`, a remediation loop, and an S9 CI-green gate before DONE. It has no concept of an epic — a set of features with dependencies, some of which can run concurrently. `config/orchestration-routing.json` has no `epic` route, and no agent is authorized to spawn a nested full orchestration.

Without this capability, delivering an epic (a set of dependent features) requires a human to manually sequence feature branches, manually merge each feature's PR into a shared integration point, manually track which features are safe to start given in-flight dependencies, and manually clean up worktrees — all work the single-feature orchestrator already automates for one feature at a time. This defeats the Autonomous-Execution Mandate at epic scale.

## Personas & Scenarios

- **Persona: Repository orchestration operator (Dan Moisan / drmoisan).**
  - Runs the repository's Claude-native orchestration surface to deliver features and epics without manual babysitting.
  - Cares about: no silent manual blockers reaching the end of a run; every critical invariant (merge gating, wave ordering, worktree cleanup) being structurally enforced, not just documented; durable resumability across session restarts.
  - Constraints: this repository is merge-commit-only; the `Agent` tool's `isolation: "worktree"` and `run_in_background` primitives are the only sanctioned concurrency mechanism; no Codex-native or Copilot-native equivalent is required for this pass.
  - Goals and frustrations: wants to author a small epic manifest once and let the epic run itself; is frustrated by any design that requires babysitting merge order or manually resolving conflicts across concurrent worktrees.

- **Scenario: Diamond-shaped epic with four child features.**
  - Trigger: the operator authors `docs/features/epics/epic-orchestrate-275/epic-plan.md` describing four child features — `child-a` (no dependencies), `child-b` and `child-c` (both depend on `child-a`), and `child-d` (depends on both `child-b` and `child-c`) — and asks the top-level orchestrator to run the epic.
  - Steps: the top-level `orchestrator` detects the epic-shaped objective and delegates to `Agent(epic-orchestrator)` with the manifest path. `epic-orchestrator` parses the manifest, computes waves (`wave 0 = {child-a}`, `wave 1 = {child-b, child-c}`, `wave 2 = {child-d}`) via longest-path layering, creates the integration branch off `main`, and launches `child-a` in its own worktree. Once `child-a`'s PR merges into the integration branch and its worktree is removed, `epic-orchestrator` launches `child-b` and `child-c` concurrently (in one message, two `Agent` calls, both `isolation: "worktree"` and `run_in_background: true`), each citing `child-a`'s spec/plan/PR/commit as upstream context. Once both merge, `child-d` is launched, then the final integration-to-`main` PR is opened, driven green, and merged.
  - Obstacles/decisions: the wave-barrier hook must prevent `child-d` from starting before both `child-b` and `child-c` are durably confirmed merged, even though both were launched together in one background-concurrent batch; the operator expects this to be structurally impossible to violate, not merely discouraged.
  - Expected outcome: `main` receives one merge commit containing all four features' work, `docs/features/epics/epic-orchestrate-275/epic-status.md` shows every feature as `merged`/`worktree_removed`, and every worktree used during the run has been cleaned up.

- **Scenario: Fan-in merge conflict during `child-c`'s merge attempt.**
  - Trigger: `child-c`'s branch, when merged into the integration branch after `child-b` has already merged, conflicts on a file both features touched.
  - Steps: `child-c`'s own `orchestrator` (running in epic mode) reaches S9 step 6, attempts `gh pr merge --merge`, and observes the conflict. Its `atomic-executor` reproduces the conflict locally, captures the conflicted file list and marker content, and the child's own `orchestrator` converts this into a `remediation-inputs.<timestamp>.md` Blocking finding processed by the existing R1–R5 remediation loop — the same loop that already handles CI-check failures.
  - Obstacles/decisions: the operator does not want a second, parallel remediation mechanism to reason about; reusing R1–R5 unmodified is the explicit design choice.
  - Expected outcome: the conflict resolves within the standard 3-pass cap and the merge completes; if it does not resolve within 3 passes, the child's checkpoint records `step9_status: "blocked_conflict_loop_limit"`, the epic checkpoint mirrors `merge_status: "blocked_conflict_loop_limit"` for `child-c`, and the run halts without writing DONE rather than silently abandoning the conflict.

- **Scenario: Resuming an epic run after a session restart.**
  - Trigger: the session running `epic-orchestrator` is interrupted mid-epic (for example, after wave 1 has merged but before wave 2 is launched).
  - Steps: on restart, `epic-orchestrator` reads `artifacts/orchestration/epic-orchestrator-state.json`, re-derives durable ground truth via `git worktree list --porcelain`, `git branch`, and `gh pr view --json state,mergedAt,headRefOid` rather than trusting only in-memory completion notifications, confirms wave 1's features are truly merged, and resumes at wave 2.
  - Expected outcome: no wave is re-launched, no already-merged feature is re-processed, and the wave barrier is verified against durable state rather than assumed from the last recorded checkpoint write alone.

## Acceptance Criteria

- [x] `.claude/agents/epic-orchestrator.md` exists, is distinct from `orchestrator.md`, and its delegate allowlist includes `Agent(orchestrator)`.
- [x] A deterministic epic dependency manifest format (Markdown with YAML frontmatter at `docs/features/epics/<epic-slug>/epic-plan.md`) is defined, and the epic-orchestrator computes wave assignment from it via longest-path-layering topological sort, not ad hoc reasoning, rejecting cyclic or unresolved `depends_on` references before kickoff.
- [x] The epic integration branch lifecycle (create off `main`, per-wave branching off the current tip, PR base override to the integration branch, final integration-to-`main` PR) is implemented and documented.
- [x] Per-feature orchestration supports an `epic_mode` checkpoint flag that, on CI-green, merges its own PR into the integration branch and records the merge commit SHA in the checkpoint (S9 step 6 and PR Creation Gate condition 7).
- [x] Merge-conflict handling during fan-in is resolved by converting the conflict into a synthetic Blocking finding processed by the existing, unmodified R1–R5 remediation loop, sharing the same `remediation_pass` cap of 3.
- [x] `artifacts/orchestration/epic-orchestrator-state.json`'s schema is defined, validated by a new `scripts/dev_tools/validate_epic_orchestrator_state.py`, and registered as `epic-orchestrator-state` with `mcp__drm-copilot__validate_orchestration_artifacts`.
- [x] Wave-barrier logic is enforced by both a per-call `PreToolUse` deterrent hook and a retrospective `SubagentStop`-time validator, checked against durable checkpoint state, not in-memory notifications.
- [x] `config/orchestration-routing.json` (and its byte-identical mirror) has an `epic` route with `required_agents: [orchestrator, pr-author]`, the required skills, and the required MCP tools.
- [x] Worktree cleanup after confirmed merge is implemented and gated by a dedicated `PreToolUse` hook (`enforce-epic-worktree-removal-gate.ps1`) that denies removal unless the epic checkpoint shows the feature as merged.
- [x] Dependent-feature kickoff prompts cite specific upstream artifact paths (spec, plan, PR number, merge commit) for every `depends_on` entry.
- [x] All critical invariants (base-branch override, merge-on-green gating, wave barrier, worktree-removal gating) are hook/validator-enforced, named explicitly by file, not prose the delegate agent might not follow.
- [x] `epic-orchestrator` updates `docs/features/epics/<epic-slug>/epic-status.md` at every wave boundary and merge-status transition, not only at final completion.
- [x] Both bundled mirrors (`extensions/drm-copilot/resources/claude-customizations/`, test-enforced; `packages/mcp-server/resources/claude-customizations/`, manually `cmp`-verified) are updated and verified byte-for-byte for every new/modified file under the entire `.claude/` tree, not only `.claude/agents/**`/`.claude/skills/**`.

## Non-Goals

- No Codex-native (`.codex/`, `.agents/`) or Copilot-native (`.github/`) equivalent of `epic-orchestrate` is built in this pass.
- No cross-machine or cross-runner parallelism; every child worktree runs on the same host as the epic-orchestrator.
- No automatic epic decomposition: `epic-plan.md`'s feature list and `depends_on` edges are assumed to already exist and are authored before an epic run starts, not generated by this feature.
- No change to standalone (non-epic) single-feature orchestration behavior; `epic_mode` absence preserves today's behavior exactly.
- No new git worktree or background-execution mechanism; only the existing `Agent` tool's `isolation: "worktree"` and `run_in_background` primitives are used.
