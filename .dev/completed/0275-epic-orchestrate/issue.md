# epic-orchestrate (Issue #275)

- Date captured: 2026-07-02
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-orchestrate/ (Issue #275)

- Issue: #275
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/275
- Last Updated: 2026-07-02
- Work Mode: full-feature

## Problem / Why

The repository has a working single-feature orchestrator (`.claude/skills/orchestrate/SKILL.md`,
`.claude/agents/orchestrator.md`) that runs one feature end-to-end: change-budget routing,
delegation to `atomic-planner`/`atomic-executor`/`feature-review`/`pr-author`, a remediation loop,
and an S9 CI-green gate before DONE. It has no concept of an epic — a set of features with
dependencies, some of which can run concurrently. `config/orchestration-routing.json` has no
`epic` route, and no agent is authorized to spawn a nested full orchestration.

## Proposed Behavior

Build an `epic-orchestrate` capability that schedules a dependency graph of child features across
parallel, isolated git worktrees (using the existing `Agent` tool's `isolation: "worktree"` and
`run_in_background: true` primitives — not reinventing worktree creation or background execution),
and fans results back together via a shared epic integration branch.

Resolved design decision: per-feature orchestration, when run in "epic mode," is extended so that
once its CI-green gate (S9) passes, it merges its own PR into the epic's integration branch (merge
commit — this repository is merge-commit-only) rather than stopping at "PR opened, CI green."
Standalone (non-epic) orchestration is unchanged.

Required capabilities:
1. Delegation authorization for nested orchestration — new `.claude/agents/epic-orchestrator.md`
   whose delegate allowlist includes `Agent(orchestrator)`; `orchestrator.md` does not call itself.
   Reuse the `SubagentStop` hook pattern (`.claude/hooks/validate-orchestrator-output.ps1`, matcher
   `"orchestrator"`) so nested single-feature runs are validated identically to top-level runs.
2. Epic dependency manifest — a deterministic, checkpoint-friendly format for an epic's feature
   list and dependency edges (e.g. `docs/features/epics/<epic>/epic-plan.md` or JSON) listing each
   child feature with a `depends_on` array. Wave assignment (topological sort) is computed from
   this manifest deterministically, not by ad hoc reasoning each run.
3. Epic integration branch lifecycle — create `epic/<epic-slug>-integration` off `main` before wave
   1; each child feature's worktree/branch is created off the current tip of the integration branch
   (fetch/pull before branching); each child feature's PR base branch is the integration branch, not
   `main` (requires a base-branch override in per-feature orchestration — check
   `.claude/skills/pr-base-branch-merge-base/SKILL.md` and feature-review diff/merge-base
   resolution for hardcoded-trunk assumptions); at epic completion, open and drive to green a final
   PR merging the integration branch into `main`.
4. Merge-on-green extension to per-feature orchestration — an epic-mode branch in
   `.claude/skills/orchestrate/SKILL.md`'s S9/PR-Creation-Gate sections: after
   `ci_gate.conclusion == "success"` and head-SHA match, execute `gh pr merge --merge` into the
   integration branch, then record the merge commit SHA in the checkpoint.
5. Merge-conflict handling — a fan-in conflict must not halt silently under the
   Autonomous-Execution Mandate. Preferred approach: treat a conflict as a synthetic Blocking
   finding fed into the standard R1–R5 remediation loop. Feasibility must be confirmed during
   research; if infeasible, it must go through the three permitted responses
   (`scope_change`/`exception`/`halt`) with the halt case explicitly justified.
6. Epic-level checkpoint — new `artifacts/orchestration/epic-orchestrator-state.json`, distinct
   from the per-feature checkpoint. Records per child feature: wave number, worktree path, branch
   name, PR number, merge status — durably re-derivable from git/GitHub on resume (`gh pr view`,
   `git branch`/`git log`), not from in-memory completion notifications. Define the schema, extend
   `scripts/dev_tools/validate_orchestrator_state.py` (or add a sibling validator), and register the
   new artifact type with `mcp__drm-copilot__validate_orchestration_artifacts`.
7. Wave barrier — the epic-orchestrator must not start a dependent wave until the epic-level
   checkpoint shows every feature in the prior wave(s) as merged (verified against durable state),
   even when launched with `run_in_background: true` and one message containing multiple concurrent
   `Agent` calls.
8. Routing and receipts — add an `epic` entry to `config/orchestration-routing.json`
   (`required_agents`, `required_skills`, `required_mcp_tools`) so the existing
   `delegation_receipts[]`/`skill_receipts[]`/`mcp_call_receipts[]` contract extends to epic runs.
9. Worktree cleanup — after a child feature's branch is merged into the integration branch, remove
   its worktree (`git worktree remove`), gated on confirming the merge.
10. Context handoff to dependent features — when kicking off a dependent feature, cite the specific
    upstream artifacts relevant to it (e.g. upstream `spec.md`/`plan.*.md` paths) rather than
    assuming the delegate will rediscover prior design decisions from the diff alone.

Additional hardening requirements from the requester (2026-07-02):
- Critical invariants (base-branch override, merge-on-green gating, wave barrier, worktree-removal
  gating) must be enforced via hooks/validators, not prose the delegate agent might not follow.
- The epic-orchestrator must keep epic documentation (manifest/status) up to date as waves
  complete, not only produce a final report.

Scope confirmed Claude-only for this pass (2026-07-02): no Codex-native (`.codex/`, `.agents/`) or
Copilot-native (`.github/`) equivalents are being built now.

Bundled mirror parity is required for every new/modified file under `.claude/agents/` and
`.claude/skills/` produced by this work:
1. `extensions/drm-copilot/resources/claude-customizations/` — contract-enforced; verify via
   `poetry run pytest tests/scripts/dev_tools/`.
2. `packages/mcp-server/resources/claude-customizations/` — gitignored, no automated gate; verify
   per file with `cmp`.

Explicitly out of scope for this pass:
- Cross-machine or cross-runner parallelism (everything runs in worktrees on the same host).
- Automatic epic decomposition (the manifest in item 2 is assumed to already exist).

## Acceptance Criteria (early draft)

- [ ] `.claude/agents/epic-orchestrator.md` exists, is distinct from `orchestrator.md`, and its
      delegate allowlist includes `Agent(orchestrator)`.
- [ ] A deterministic epic dependency manifest format is defined and the epic-orchestrator computes
      wave assignment from it via topological sort, not ad hoc reasoning.
- [ ] Epic integration branch lifecycle (create, per-wave branching off tip, PR base override, final
      integration-to-main PR) is implemented and documented.
- [ ] Per-feature orchestration supports an epic-mode flag that merges its own PR into the
      integration branch on CI-green and records the merge commit SHA in the checkpoint.
- [ ] Merge-conflict handling during fan-in is resolved (remediation-loop-based, or documented
      scope_change/exception/halt) with feasibility confirmed in research.
- [ ] `artifacts/orchestration/epic-orchestrator-state.json` schema is defined, validated, and
      registered with `mcp__drm-copilot__validate_orchestration_artifacts`.
- [ ] Wave barrier logic is enforced against durable checkpoint state, not in-memory notifications.
- [ ] `config/orchestration-routing.json` has an `epic` route with required agents/skills/mcp tools.
- [ ] Worktree cleanup after confirmed merge is implemented.
- [ ] Dependent-feature kickoff prompts cite specific upstream artifact paths.
- [ ] Critical invariants above are hook/validator-enforced, not prose-only.
- [ ] Epic-orchestrator updates epic status documentation as waves complete.
- [ ] Both bundled mirrors are updated and verified byte-for-byte.

## Constraints & Risks

- This repository is merge-commit-only (squash/rebase disabled repo-wide).
- The Agent tool's `isolation: "worktree"` and `run_in_background` are the only sanctioned
  concurrency primitives; no new worktree/background mechanism should be invented.
- Feasibility of automated merge-conflict remediation must be confirmed before committing to it as
  final design; if infeasible it becomes a documented human-interaction exception/halt.
- Bundle-mirror parity for `extensions/drm-copilot/resources/claude-customizations/` is
  test-enforced; drift blocks CI. The `packages/mcp-server/resources/claude-customizations/` mirror
  has no automated gate and must be manually verified with `cmp`.

## Test Conditions to Consider

- [ ] Unit coverage areas: wave/topological-sort computation, epic checkpoint schema validation,
      merge-conflict-to-remediation-finding conversion, worktree-cleanup gating logic.
- [ ] Integration scenarios: multi-wave epic with a dependency chain, a fan-in merge conflict, a
      resumed epic-orchestrator run after a session restart (durable-state re-derivation).
- [ ] CLI/API examples: `gh pr merge --merge`, `git worktree remove`, `gh pr view --json` re-derivation
      calls used by the wave barrier and checkpoint resume logic.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/epic-orchestrate/` folder from the template

