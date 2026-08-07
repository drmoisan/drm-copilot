# Research: F4 `parallel-planner-surface` (Issue #443)

- Date: 2026-08-07
- Feature: `docs/features/active/2026-08-07-parallel-planner-surface-443/`
- Branch context: `worktree-agent-af4f8d879412124a2`, based on
  `epic/parallel-orchestration-integration` at `5a0becb0`
- Design source (§N references): `docs/research/2026-08-07-parallel-orchestration-design-research.md`
- Epic narrative: `docs/features/epics/parallel-orchestration/epic.md`
- Promoted issue: `docs/features/active/2026-08-07-parallel-planner-surface-443/issue.md`

## Upstream Landing Status (verified)

Checked on this worktree at commit base `5a0becb0`:

- `docs/features/active/` contains no `parallel-blast-radius`, `parallel-cohort-scheduler`, or
  `parallel-schema-validators` feature folder (Glob `docs/features/active/*parallel*/**` returns
  only `2026-08-07-parallel-planner-surface-443`).
- `scripts/dev_tools/` contains no `compute_blast_radius.py` and no `parallel_cohort_computation.py`
  (Glob `scripts/dev_tools/*blast*` and `*parallel*` return nothing).
- No `validate_parallel_*` validator exists; the MCP `VALID_ARTIFACT_TYPES` set in
  `extensions/drm-copilot/src/mcp-tool-inputs.ts` (lines 427-436) contains only
  `plan`, `policy-audit`, `code-review`, `feature-audit`, `orchestrator-state`,
  `epic-orchestrator-state`, `epic-planner-state`, `epic-kickoff`.
- No `.claude/skills/*parallel*` or `.claude/agents/parallel-*.md` files exist.
- `quality-tiers.yml` does not exist at the repository root (confirms the F1 known constraint
  recorded in `epic.md` under "F1 — Blast-radius library").

**Consequence:** F1, F2, and F3 have NOT landed. Every F1/F2/F3 interface named in this document
is a **required upstream contract stated from the design sections**, labeled `[ASSUMPTION]` with
the section cited. Confirmation is a re-check of `docs/features/active/` and `scripts/dev_tools/`
at atomic-planning time; if an upstream spec has landed by then, that spec supersedes the
assumption.

## Current State Analysis (verified precedent inventory)

- `.claude/agents/epic-planner.md` (122 lines) — planning agent persona. Tools:
  `Agent(orchestrator)`, `Read`, `Grep`, `Glob`, `Write/Edit(docs/features/epics/**)`,
  `Write/Edit(artifacts/orchestration/**)`, `Bash(git *)`, `Bash(gh *)`,
  `mcp__drm-copilot__validate_orchestration_artifacts`. `model: opus`, `memory: project`, no
  `hooks` block. Preloaded skills: `policy-compliance-order`, `epic-plan`, `epic-orchestrate`,
  `feature-promotion-lifecycle`, `atomic-plan-contract`, `evidence-and-timestamp-conventions`.
- `.claude/skills/epic-plan/SKILL.md` (190 lines) — `context: fork`, `agent: epic-planner`.
  Sections: worthiness gate, decomposition/waves, complexity assessment, integration-branch
  lifecycle, preparation-mode child delegation (with the literal kickoff line at line 99),
  child run contract, fan-in, kickoff prompt artifact template, checkpoint handling,
  completion report.
- `.claude/skills/orchestrate/SKILL.md` `## Preparation Mode` (lines 90-97) — the child
  contract F4 must reuse unchanged. Route selection is **marker-driven**: line 101 states route
  is "marker-driven for `preparation` (the `Preparation mode: true` kickoff line)".
- `config/orchestration-routing.json` `routes.preparation` (lines 79-99) —
  `requires_ci_gate: false`; required agents `task-researcher`, `prd-feature`,
  `atomic-planner`, `atomic-executor`; required skills `orchestrate`,
  `feature-promotion-lifecycle`, `atomic-plan-contract`; required MCP tools
  `new_potential_entry`, `potential_to_issue`, `new_active_feature_folder`,
  `validate_orchestration_artifacts`.
- `scripts/dev_tools/epic_kickoff_contract.py` — kickoff Markdown parser/validator (detailed in Q5).
- `scripts/dev_tools/validate_epic_planner_state.py` — planner checkpoint validator with
  `require_ready_for_execution` gate (detailed in Q6), supported by
  `scripts/dev_tools/epic_planner_readiness.py`, `scripts/dev_tools/epic_planner_git_integrity.py`
  (committed-blob and branch-existence integrity), and
  `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py` (per-feature `branch_name`
  uniqueness and canonical absolute `worktree_path`).
- `scripts/dev_tools/validate_orchestration_artifacts.py` — CLI dispatcher; subcommands
  `epic-planner-state` (`--require-ready-for-execution`, `--workspace-root`) and `epic-kickoff`.
- `.claude/hooks/enforce-epic-invocation-origin.ps1` — gates `$script:GatedSubagentTypes =
  @('epic-planner', 'epic-orchestrator')` (line 36) against caller `agent_type == 'orchestrator'`,
  deny reason `EPIC_INVOCATION_ORIGIN_BLOCKED`.
- `.claude/skills/epic-run/SKILL.md` — shows how a kickoff artifact is discovered and consumed,
  including reading it from a non-checked-out ref via `git cat-file -e` / `git show <ref>:<path>`
  (lines 26-37). This cross-ref read technique is load-bearing for the Q1 recommendation.

---

## Q1 — Artifact home for prepared items (PRIMARY)

### Problem restatement

`epic-plan` fans every prepared child folder and plan into `epic/<slug>-integration`
(`.claude/skills/epic-plan/SKILL.md` "Fan-In", lines 124-137), and
`validate_epic_planner_state.py` readiness integrity verifies plans are committed byte-exact on
that branch (`epic_planner_git_integrity.py::validate_planning_git_integrity`, which fails when
`integration_branch` does not exist as a ref). A parallel run has no integration branch (§4;
epic non-goal "An integration branch for parallel runs"). The preparation-mode child contract's
terminal step is: "Commit the prepared feature folder and plan to the current branch"
(`.claude/skills/orchestrate/SKILL.md` line 97). The question is which durable ref "the current
branch" resolves to and where run-level artifacts live.

### Candidate evaluation

Criteria: durability across worktree removal; visibility to `parallel-orchestrator` and to each
item's child orchestrator; fan-in reintroduction (§4 forbids; §8 mutable membership relies on its
absence); merge-conflict exposure between concurrently prepared items; compatibility with the
`route_id: preparation` contract UNCHANGED; compatibility with late arrivals (§8.3); auditability.

**(a) Commit prepared artifacts to `main` (planner PR or direct push).**
Durable and universally visible, but structurally poor. Direct push to `main` conflicts with the
repository's PR-mediated merge model (every surface in this repo merges via PR: S9 CI gate,
`enforce-pr-author-skill.ps1`). A planner-authored docs PR serializes planning behind CI and
review latency, and dynamic membership (§8.3) would require a fresh PR to `main` for every
mid-run addition. It also lands planning artifacts for items that may later be `withdrawn`,
leaving orphaned feature folders on `main`. Finally, each item's own execution PR would then
modify a feature folder that already exists on `main` from a different commit line, creating
avoidable conflict exposure on the very files preparation produced. Rejected.

**(b) Per-item feature branch, created at preparation time, pushed, reused at execution time.**
Each preparation-mode child runs in a worktree whose branch is created from `origin/main`
(instead of `origin/epic/<slug>-integration`); the child's unchanged terminal step commits the
prepared feature folder and plan to that branch; the planner (or the child, instructed by the
kickoff prompt) pushes the branch (`git push -u origin <branch>`) before the worktree is removed.
The branch name and worktree path are recorded per item in the planner checkpoint — the exact
fields the epic launch-binding validator already requires per feature
(`_epic_orchestrator_state_launch_binding.py`: unique `branch_name`, canonical absolute
`worktree_path`).

- Durability: the pushed branch survives worktree removal; this is the same durability mechanism
  the epic surface uses for the integration branch.
- Visibility: `parallel-orchestrator` and validators read `plan.<ts>.md` from the branch ref
  without checkout via `git fetch origin <branch>` + `git show <branch>:<path>` — the precise
  technique `.claude/skills/epic-run/SKILL.md` lines 26-37 already documents for reading a
  kickoff from a non-checked-out integration ref.
- No fan-in point: branches never merge into each other or into any shared planning ref. A late
  arrival (§8.3) gets a new branch; no prior work is touched.
- Merge-conflict exposure between concurrently prepared items: zero; branches are disjoint.
- Preparation contract UNCHANGED: "commit ... to the current branch" is satisfied verbatim; only
  the base ref the planner chooses when creating the worktree differs, and the base ref is the
  planner's parameter, not part of the child contract text.
- Execution-time reuse: the item's execution-phase child orchestrator resumes on the same branch
  (recreating a worktree from the pushed branch), so plan and code travel together and the item's
  eventual PR to `main` carries its own planning artifacts — the feature folder reaches `main`
  exactly when the item merges, and never for withdrawn items.

**(c) Dedicated planning branch per run (`parallel/<slug>-planning`) holding all prepared folders.**
Durable and visible, but copying every child's prepared folder onto one shared branch recreates
the epic fan-in merge step (the planner must fetch and merge N child branches), which is the
mechanism §4 removes and §8 relies on being absent. It also creates a second copy of each feature
folder that diverges from the copy on the item's execution branch (and later from `main` after
the item merges, including the `active/` → `completed/` move). Rejected for item-level artifacts.

**(d) Checkpoint/manifest only; no committed folders until execution.**
Violates the preparation contract UNCHANGED (its terminal step commits the folder and plan), and
`artifacts/orchestration/` is gitignored (`.claude/skills/epic-plan/SKILL.md` line 143 records
this for the epic tree), so nothing durable would survive worktree or machine loss. Rejected.

**(e) Hybrid (RECOMMENDED): per-item branches for item artifacts + a run-home branch for
run-level artifacts.**
Item-level artifacts follow (b) exactly. Run-level artifacts — `docs/features/parallel/<slug>/parallel.md`
(the manifest) and the durable kickoff copy `docs/features/parallel/<slug>/parallel-kickoff.md` —
are committed to a dedicated, planner-owned branch `parallel/<slug>-plan`, created off
`origin/main` and pushed. This branch:

- is NOT an integration branch: no item branch ever merges into it, and it never merges into an
  item branch. It holds only the run home `docs/features/parallel/<slug>/**`, which no item's
  blast radius may include, so it cannot conflict with any item and cannot invalidate a late
  arrival. It is the durable home the epic surface gets for free from the integration branch,
  without the fan-in role.
- accepts mutable membership: F6's add/remove/close operations amend the manifest by committing
  to this branch, and `recolor_generation` in the mutation log keeps the history traceable
  (§8.6).
- supports the epic-run-style discovery pattern: `/parallel-run <slug>` resolves the kickoff via
  `git fetch origin parallel/<slug>-plan` + `git cat-file -e` / `git show`, mirroring
  `.claude/skills/epic-run/SKILL.md` step 2.
- reaches `main` (optionally) via one docs-only PR at run close, when the manifest is final —
  this is a historical-record step, not a scheduling dependency.

### Recommendation (state this as a resolution in `spec.md`)

1. Each item's prepared feature folder and approved atomic plan live on the item's own feature
   branch, created from `origin/main` at preparation time, committed by the unchanged
   `route_id: preparation` terminal step, pushed to `origin` before worktree removal, and reused
   as the execution branch. The planner records `branch_name` and `worktree_path` per item in
   `artifacts/orchestration/parallel-planner-state.json`.
2. Run-level artifacts (`docs/features/parallel/<slug>/parallel.md`,
   `docs/features/parallel/<slug>/parallel-kickoff.md`) live on the planner-owned branch
   `parallel/<slug>-plan`, pushed to `origin`. This branch is not a merge target for any item and
   never merges into any item.
3. Readers (validators, `parallel-orchestrator`) access both classes of artifact by ref
   (`git fetch` + `git show <ref>:<path>`) without checking the refs out, per the `epic-run`
   precedent.

Residual risks:

- **Stale base at execution.** An item branch created at preparation time is based on an older
  `main` tip by the time its cohort executes. Mitigation: the execution-phase child merges
  `origin/main` at start; because cohort N+1 starts only after cohort N merged and cohort peers
  are non-conflicting by construction (§6), such merges touch files outside the item's radius,
  and any real overlap is caught by drift detection (F8, §7). This mitigation is F5's procedure
  to state; F4's spec records the branch-reuse contract.
- **Branch accumulation.** Withdrawn or abandoned items leave pushed preparation branches.
  Mitigation: F6's `--disposition abandon` path deletes the branch; `spec.md` should note the
  cleanup expectation so F6 can implement it.
- **F3 validator dependency.** The planner-state readiness gate's git-integrity analogue must
  verify committed plan blobs against **per-item branch refs** plus the `parallel/<slug>-plan`
  ref, instead of the epic's single `integration_branch` ref. This is a required contract on
  F3's `validate_parallel_planner_state.py` `[ASSUMPTION — F3 unlanded; §12 plus the epic
  precedent `epic_planner_git_integrity.py`]`.

---

## Q2 — Preparation fan-out mechanics

### Verified epic mechanics (`.claude/skills/epic-plan/SKILL.md` lines 87-137)

- **Concurrency and isolation.** One `Agent(orchestrator)` delegation per child; ALL launched
  concurrently ("one message, N `Agent` calls, each `isolation: "worktree"` and
  `run_in_background: true`"), each worktree branched from
  `origin/epic/<epic-slug>-integration` (line 92).
- **Kickoff line (literal, line 99):**
  `Preparation mode: true. route_id: preparation. epic_feature_folder: <epic-slug>. integration_branch: epic/<epic-slug>-integration. Perform promotion, research, feature documents (spec.md, user-story.md), atomic planning, and preflight clearance only. Atomic execution, PR authoring, and CI monitoring are out of scope for this run and are executed later by epic-orchestrator. After the atomic-executor preflight returns PREFLIGHT: ALL CLEAR, commit the feature folder and plan to the current branch, set out-of-scope step statuses to not-applicable, set next_step to S5_atomic_execution, and stop, reporting the plan-path and preflight status.`
- **Deliberate marker omission.** The preparation kickoff line omits `Epic mode: true` so the
  `enforce-epic-wave-barrier.ps1` deterrent does not gate preparation delegations (lines 101-105).
- **`model_budget.fable_policy` line.** The epic-plan kickoff line itself does not carry it; the
  marker is defined in `.claude/skills/epic-orchestrate/SKILL.md` `## Model Selection`
  (lines 136-147: `model_budget.fable_policy: <disabled|available|preferred>.`), and
  `.claude/skills/orchestrate/SKILL.md` step 1 (line 112) defaults to `disabled` when the marker
  is absent. The session default in `config/orchestration-routing.json` `model_budget` is
  currently `preferred`.
- **Terminal report collection.** Each child stops reporting `plan-path` and preflight status
  (kickoff line tail); the child's terminal checkpoint has `completed_steps` containing
  `S3_promotion` and `S4_atomic_planning`, `next_step: "S5_atomic_execution"`, out-of-scope steps
  `not-applicable`, `blocked_reason: "none"` (orchestrate SKILL lines 96; epic-plan lines 119-123).
- **Receipts recorded by the planner.** Per-feature checkpoint fields
  (`validate_epic_planner_state.py` `REQUIRED_FEATURE_KEYS` plus readiness checks):
  `preparation_status` (`"prepared"` when done), `research_path`, `plan_path`,
  `preflight_status` (`"PREFLIGHT: ALL CLEAR"`), `model_routing_receipt`
  (`execution_context: "epic_preparation_child"`, `logical_agent: "orchestrator"`),
  `topology_receipt`, and launch bindings `branch_name` (unique) / `worktree_path` (canonical
  absolute) via `_epic_orchestrator_state_launch_binding.py`.
- **Failure / partial preparation.** Preflight iteration happens inside the child (revise plan
  until ALL CLEAR). At fan-in, a merge conflict halts fan-in with blocked state recorded rather
  than ad hoc resolution (epic-plan line 128-131). A child that never reaches `prepared` leaves
  its `features[]` entry non-`prepared`; the readiness gate (`--require-ready-for-execution`)
  then fails (`_validate_ready_features`), so the kickoff cannot be certified.

### What F4 reuses verbatim vs. what differs

Reused verbatim:

- The markers `Preparation mode: true. route_id: preparation.` and the entire behavioral tail of
  the kickoff line (scope sentence, ALL CLEAR / commit / `next_step: S5_atomic_execution` / stop
  and report).
- Concurrent launch shape: one message, N `Agent(orchestrator)` calls, `isolation: "worktree"`,
  `run_in_background: true`.
- The `model_budget.fable_policy: <...>` marker line appended per the `epic-orchestrate`
  `## Model Selection` pattern.
- Terminal-report fields collected (plan-path, preflight status) and the receipt structure
  (preparation status, research/plan paths, model-routing and topology receipts, launch
  bindings).

Differs (because there is no integration branch):

- Worktree base ref: `origin/main`, not an integration branch.
- Kickoff context fields: replace `epic_feature_folder: <slug>. integration_branch: ...` with
  `parallel_slug: <slug>.` (and, per Q1, an explicit instruction to push the branch:
  "push the current branch to origin before stopping" — an addition to the *planner's prompt*,
  not to the child contract text in `orchestrate/SKILL.md`).
- Out-of-scope attribution: "executed later by epic-orchestrator" becomes "executed later by
  parallel-orchestrator" in the parallel kickoff line (the planner authors its own prompt; the
  orchestrate SKILL text is untouched).
- No fan-in merge step. Instead: fetch/record each pushed item branch, back-fill `issue_num`
  from the promotion receipt into the manifest on `parallel/<slug>-plan`, update the checkpoint.
- Preparation prompts must omit the `Parallel mode: true` marker that §9's cohort-barrier hook
  (F7) will match, exactly parallel to the epic's deliberate omission of `Epic mode: true`.

### Does reuse require edits to `orchestrate/SKILL.md` or the `preparation` route?

**No functional edit is required.** Verified basis:

- Route selection is marker-driven (`orchestrate/SKILL.md` line 101: "marker-driven for
  `preparation` (the `Preparation mode: true` kickoff line)"). Nothing in the route mechanism
  keys on the issuer being `epic-planner`.
- The child contract's commit instruction is "the current branch" (line 97); a branch created
  off `origin/main` satisfies it without wording change.
- `config/orchestration-routing.json` `routes.preparation` has no epic-specific required agent,
  skill, or MCP tool; only its free-text `description` (line 80) says "Epic preparation path
  driven by epic-planner". Descriptions are not validated inputs.

Two epic-specific **parentheticals** exist in `orchestrate/SKILL.md` — line 92 "(issued by
`epic-planner` per the `.claude/skills/epic-plan/SKILL.md` kickoff line)" and line 97 "(the
worktree branch created off the epic integration branch)" — and the phrase "are executed later by
`epic-orchestrator`" (line 95). These are descriptive, not gating; a preparation-mode child
receiving a parallel kickoff line behaves identically. F4 must NOT edit them (the acceptance
criterion requires no change to the preparation-mode section). The minimal alternative that avoids
any edit is what Q2 above already specifies: the parallel kickoff line itself names the base
branch, the `parallel_slug`, and the correct downstream agent, so the child never needs the
epic-flavored parentheticals to resolve its behavior. Residual risk (Low): a child could quote the
epic parenthetical in its own report; this is cosmetic and does not alter route, receipts, or the
terminal checkpoint.

---

## Q3 — Blast-radius invocation contract (F1)

`[ASSUMPTION — F1 unlanded]` Everything in this section is a required upstream contract stated
from §5.1-§5.4 and the epic's F1 scope entry; it is precise enough to plan against and must be
reconciled with F1's landed spec at F4 planning time.

Required contract on F1:

- **Module and CLI.** `scripts/dev_tools/compute_blast_radius.py`, importable
  (`from scripts.dev_tools.compute_blast_radius import ...`) and CLI-invocable
  (`poetry run python -m scripts.dev_tools.compute_blast_radius ...`), following the repo's
  reference-implementation pattern (`epic_wave_computation.py`, `compute_complexity_floor.py`,
  `resolve_delegation_model.py`). PowerShell parity module
  `.claude/lib/blast-radius/BlastRadius.psm1` (epic F1 scope).
- **Inputs.** Approved atomic plan path, feature `spec.md` path, feature folder path, and the
  shared-surface configuration truth table (location owned by F1; §5.1 item 3 lists the
  archetypes). Module mapping input is unresolved upstream: §5.1 says "via `quality-tiers.yml`"
  but that file does not exist at repo root (verified; also flagged in `epic.md` F1 "Known
  constraint"). F4 must treat the module-mapping source as F1-defined and opaque.
- **Output.** JSON: `{ "paths": [...], "modules": [...], "shared_surfaces": [...],
  "contracts": [...], "source": "declared", "computed_at": "<iso8601>" }` (§5.1, §5.2, §11
  `blast_radius` shape), plus a findings list where each finding carries
  `{ rule: "V1"|"V2"|"V3", severity: "Blocking"|"Advisory", detail }` (§5.3: V1 and V2
  Blocking, V3 Advisory).
- **Contention relation.** A callable `conflicts(a, b)` (or an edge-derivation entry point over a
  set of radii) returning the conflict verdict with a `reason` in
  `{path_overlap, module_overlap, shared_surface_overlap, contract_dependency}` (§5.4, §12
  `conflict_edges[]` shape). Fails closed.

Call surface recommendation for `parallel-plan`: **CLI subprocess with JSON output**, invoked by
the planner via `Bash(poetry run *)`. Rationale: `parallel-planner` is a Markdown agent persona;
the only in-repo precedent for an agent invoking Python tooling is the Bash allowlist
(`.claude/agents/orchestrator.md` line 13 carries `Bash(poetry run *)`); `epic-planner` carries
only `Bash(git *)`/`Bash(gh *)` because wave computation is judgment-applied and
validator-recomputed, but radius derivation is explicitly "planner-computed ... calling the
upstream derivation" (issue.md AC), so a real invocation surface is required. Therefore
`parallel-planner.md` must add `"Bash(poetry run *)"` to its tools (Q7). An MCP tool surface is
not assumed: F3's scope covers `validate_orchestration_artifacts` `artifact_type` wiring only, not
a compute tool.

Behavior on validation results (recommendation for `spec.md`):

- **V1 or V2 Blocking failure:** the item does NOT transition to `prepared`. The planner records
  the findings in the checkpoint (per-item `radius_validation` entry) and feeds them back as a
  plan-revision instruction to a follow-up preparation-mode delegation for that item (the same
  iterate-until-clear posture the child already applies to preflight). The item is re-planned,
  not rejected; rejection/withdrawal is a caller decision via F6's remove operation, not a
  planner default.
- **V3 Advisory:** recorded in the checkpoint and surfaced in the completion report; no state
  effect (§5.3: "reported, not rejected").
- The readiness gate consequence: `prepared` requires preflight ALL CLEAR **and** a `declared`
  radius with V1/V2 pass. This conjunction is the F3-owned readiness invariant F4's checkpoint
  instances must satisfy `[ASSUMPTION — F3 unlanded]`.

---

## Q4 — Cohort seeding contract (F2)

`[ASSUMPTION — F2 unlanded]` Required upstream contract from §6 and the epic's F2 scope entry:

- **Module.** `scripts/dev_tools/parallel_cohort_computation.py`, importable and CLI-invocable,
  deterministic greedy coloring in Welsh-Powell order: vertices sorted by descending degree, ties
  broken by ascending item key; parity test against a PowerShell counterpart in the manner of
  `epic_wave_computation.py`.
- **Inputs.** The item-key set (item key = `issue_num`, the §11 primary key) and the undirected
  conflict edge set derived by F1's `conflicts(a, b)` over the items' `declared` radii. The
  pinned-set parameter exists in the F2 signature for recoloring (§8.1) but is empty at seeding
  time.
- **Output.** `cohorts[]` of `{ index, generation, item_keys[] }` (§12), with `item_keys[]`
  sorted ascending within each cohort for deterministic serialization.

Planner-side behavior (F4):

- Invoke F2 once, after every item is `prepared` and radius-validated, over the full conflict
  graph. Record `cohorts[]` with `generation: 0`, initialize `recolor_generation: 0` and
  `current_cohort: 0` in the planner checkpoint, and record `conflict_edges[]`
  (`{a, b, reason}`) for auditability (§12).
- `max_concurrency` is NOT an input to coloring. It is a manifest field (default 4, §11) that
  caps execution fan-out within a cohort, slots filled in ascending item key (§6). Enforcement
  is F5's; F4 only records the value.
- **Seeding only.** Recoloring under add/remove/drift mutation is F6's (and F8's) concern (§8.1,
  §8.3 step 4); `parallel-plan` computes the initial coloring exactly once per plan run.

---

## Q5 — Kickoff artifact contract

### Verified epic contract (`scripts/dev_tools/epic_kickoff_contract.py`)

- First line must fullmatch `# Epic Kickoff: <slug>` (`KICKOFF_HEADING_RE`, slug
  `[a-z0-9][a-z0-9-]*`).
- Required level-two sections, duplicates rejected: `## Invocation Prompt` and
  `## Feature Summary` (`_split_sections`).
- Invocation Prompt must contain: `` Run `/epic-run <slug>` `` (`EPIC_RUN_RE`); a manifest path
  matching `docs/features/epics/<slug>/epic.md` (`MANIFEST_RE`); an integration branch matching
  `epic/<slug>-integration` (`INTEGRATION_BRANCH_RE`); and the resume-boundary sentence matching
  `RESUME_RE` ("child features resume at atomic execution from their committed plan-path").
- Feature Summary is a strict pipe table with exact ordered headers
  `issue_num | feature_folder | wave | complexity | plan-path`, >= 1 row, `issue_num` and `wave`
  integers, `complexity` in C1-C4.
- Optional `## Integrity` section: `planning_commit: <7-64 hex>` line plus a two-column
  `plan-path | plan-hash` table (40-64 hex per row, no repeated paths).
- Validation is `validate_epic_kickoff_text`, re-exported through
  `validate_epic_planner_state.py` and wired as CLI subcommand `epic-kickoff`
  (`validate_orchestration_artifacts.py` lines 170-176, 287-288) and MCP `artifact_type`
  `epic-kickoff` (`mcp-tool-inputs.ts` line 435). The artifact is written to
  `artifacts/orchestration/epic-kickoff-<slug>.md` (gitignored) with a committed durable copy at
  `docs/features/epics/<slug>/epic-kickoff.md` (`epic-plan/SKILL.md` lines 139-144; the exact
  `kickoff_prompt_path` is enforced by `validate_epic_planner_state.py` lines 333-339).

### Parallel counterpart (specification for `spec.md`)

- Paths: `artifacts/orchestration/parallel-kickoff-<slug>.md` (working copy) and
  `docs/features/parallel/<slug>/parallel-kickoff.md` (durable copy, committed to
  `parallel/<slug>-plan` per Q1).
- Heading: `# Parallel Kickoff: <slug>`.
- `## Invocation Prompt` must structurally name: `` Run `/parallel-run <slug>` `` (F5's skill);
  the manifest path `docs/features/parallel/<slug>/parallel.md`; and a resume-boundary sentence
  stating that each item resumes at atomic execution from its committed plan-path **on its own
  pushed feature branch** (the branch replaces the epic's integration-branch mention — there is
  no single branch to cite, so the per-item branch column below carries the refs).
- `## Item Summary` strict table, exact ordered headers:
  `issue_num | feature_folder | cohort | complexity | branch | plan-path`. `cohort` replaces the
  epic's `wave`; `branch` is added because plan-paths are only resolvable against a named per-item
  ref (Q1). >= 1 row; `issue_num` and `cohort` integers; `complexity` C1-C4.
- Optional `## Integrity`: per-item `plan-path | plan-hash` table (same 40-64 hex rule); the
  single `planning_commit` field generalizes to the head commit of `parallel/<slug>-plan`
  (run-level provenance), with per-item plan blobs verified against the per-item branch refs by
  the F3 readiness gate.

### Ownership boundary: who writes `parallel_kickoff_contract.py`?

Recommendation: **F3**, with F4 as the consumer. Justification from the epic decomposition table
(`epic.md` "Decomposition Rationale"): F3's role is to serialize cross-feature shapes into schemas
and validators and to own the MCP `artifact_type` wiring; F5's row consumes "the prepared plan the
planner emits (F4)" — the kickoff is precisely that producer/consumer contract, so its *parser and
validator* belong with the other schema validators, exactly as `epic_kickoff_contract.py` is
consumed by `validate_epic_planner_state.py` (an F3-analogue module). F4 owns authoring the
artifact instances and the skill text that emits them. F4's `spec.md` must therefore state a
required F3 deliverable: `scripts/dev_tools/parallel_kickoff_contract.py` +
`artifact_type: "parallel-kickoff"` wiring `[ASSUMPTION — F3 unlanded]`. Contingency: if F3 lands
without it, F4 delivers the module and the minimal additive `artifact_type` wiring itself and
records the boundary deviation in its spec — the kickoff cannot ship unvalidatable, and the epic's
wave-4 confinement discipline (distinct named additions, no reflow) applies to the wiring edit.

---

## Q6 — Planner checkpoint contract

### Verified epic planner-state artifact (`scripts/dev_tools/validate_epic_planner_state.py`)

- Top-level `REQUIRED_KEYS` (lines 34-46): `objective`, `epic_feature_folder`,
  `epic_manifest_path`, `integration_branch`, `max_parallel_features` (int 1-8),
  `epic_worthiness` (`{verdict: epic|non_epic, rationale}`), `features`, `kickoff_prompt_path`,
  `completed_steps`, `next_step`, `last_updated`.
- `REQUIRED_FEATURE_KEYS` (lines 47-57): `issue_num`, `feature_folder`, `depends_on`, `wave`,
  `complexity_band`, `preparation_status`, `research_path`, `plan_path`, `preflight_status`.
- Wave/dependency consistency is recomputed against `epic_wave_computation.compute_wave_numbers`.
- `require_ready_for_execution` mode (`_validate_ready_features`, lines 222-276, plus lines
  320-347): >= 2 features; positive-int `issue_num`; non-empty `feature_folder`/`research_path`/
  `plan_path`; `preparation_status == "prepared"`; `preflight_status == "PREFLIGHT: ALL CLEAR"`;
  per-feature `model_routing_receipt` (`execution_context: "epic_preparation_child"`,
  `logical_agent: "orchestrator"`, band match) and `topology_receipt`; launch bindings (unique
  `branch_name`, canonical absolute `worktree_path` via
  `validate_epic_planner_child_launch_bindings`); planner-level forced `topology_receipt`;
  `next_step == "EPIC_EXECUTION_READY"`; exact
  `kickoff_prompt_path == artifacts/orchestration/epic-kickoff-<slug>.md`; and repository-context
  integrity via `epic_planner_readiness.py` / `epic_planner_git_integrity.py` (integration branch
  ref exists; plan files byte-exact against committed blobs; kickoff/state cross-checks).
- MCP/CLI wiring: `artifact_type: "epic-planner-state"` with `--require-ready-for-execution` and
  `--workspace-root` (`validate_orchestration_artifacts.py` lines 240-252, 309-319;
  `mcp-tool-inputs.ts` `requireReadyForExecution`).

### Parallel planner checkpoint (`artifacts/orchestration/parallel-planner-state.json`)

Schema is **owned by F3** (`validate_parallel_planner_state.py`, MCP `artifact_type`
`parallel-planner-state`); F4 writes conforming instances only. Required contract, stated by
analogy plus §11/§12 `[ASSUMPTION — F3 unlanded]`:

- Top level: `objective`, `parallel_slug`, `parallel_manifest_path`
  (`docs/features/parallel/<slug>/parallel.md`), `mode` (`closed|open`, default `closed`),
  `max_concurrency` (int, default 4), `plan_home_branch` (`parallel/<slug>-plan`, per Q1),
  `items[]`, `cohorts[]`, `conflict_edges[]`, `recolor_generation` (0 at seeding),
  `kickoff_prompt_path` (`artifacts/orchestration/parallel-kickoff-<slug>.md`),
  `completed_steps`, `next_step`, `last_updated`. **Deliberately absent:** any
  `epic_worthiness` analogue (constraint 2: no worthiness gate) and any `depends_on`/`wave`
  fields (constraint 2: no dependency graph).
- Per item: `issue_num`, `feature_folder`, `kind` (`feature|bug`), `state` (§8.2 lifecycle enum),
  `complexity_band`, `preparation_status`, `research_path`, `plan_path`, `preflight_status`,
  `branch_name`, `worktree_path`, `blast_radius` (§11 shape, `source: "declared"`,
  `computed_at`), `radius_validation` (`{v1, v2, v3}` results with severities),
  `model_routing_receipt`, `topology_receipt`.
- Readiness gate (`require_ready_for_execution` analogue): every non-withdrawn item has
  `state == "prepared"`, `preflight_status == "PREFLIGHT: ALL CLEAR"`, a `declared` radius with
  V1/V2 pass, unique pushed `branch_name`; `cohorts[]` present at `generation 0` covering exactly
  the prepared item keys; exact `kickoff_prompt_path`; ready sentinel
  `next_step: "PARALLEL_EXECUTION_READY"`; git integrity against per-item branch refs and
  `parallel/<slug>-plan` (Q1 residual risk 3). Note: the epic's ">= 2 features" floor should NOT
  carry over as written — a parallel run of one item is degenerate but coherent (one cohort of
  one); whether to permit it is an F3 schema decision F4's spec should flag rather than decide.

F4's obligations: write the checkpoint after every completed step (mirroring `epic-planner.md`
`## Checkpoint Persistence`), re-derive durable ground truth on resume from
`git branch`/`git worktree list --porcelain`/pushed refs (§12: checkpoint is a cache), and
validate through F3's validator via `mcp__drm-copilot__validate_orchestration_artifacts` before
reporting completion.

---

## Q7 — Agent persona and invocation-origin constraints

Proposed `.claude/agents/parallel-planner.md` frontmatter, mirroring `epic-planner.md` with the
minimal deltas:

- `name: parallel-planner`; `model: opus`; `memory: project`; no `hooks` block (verified:
  `epic-planner.md` declares none; only `epic-orchestrator.md` carries a `SubagentStop` hook).
- `tools`:
  - `"Agent(orchestrator)"` (preparation fan-out),
  - `Read`, `Grep`, `Glob`,
  - `"Write(docs/features/parallel/**)"`, `"Edit(docs/features/parallel/**)"` (run home; the
    parallel counterpart of epic-planner's `docs/features/epics/**` scoping),
  - `"Write(artifacts/orchestration/**)"`, `"Edit(artifacts/orchestration/**)"`,
  - `"Bash(git *)"`, `"Bash(gh *)"`,
  - `"Bash(poetry run *)"` — **delta from epic-planner**, required to invoke F1's radius CLI and
    F2's cohort CLI (Q3/Q4); precedent: `.claude/agents/orchestrator.md` line 13,
  - `"mcp__drm-copilot__validate_orchestration_artifacts"`.
- `skills`: `policy-compliance-order`, `parallel-plan`, `feature-promotion-lifecycle`,
  `atomic-plan-contract`, `evidence-and-timestamp-conventions`. **Omit** a
  `parallel-orchestrate` preload: `epic-planner` preloads `epic-orchestrate` (the schema
  authority for its manifest), but F5's `parallel-orchestrate` skill does not exist in wave 2;
  the parallel manifest/checkpoint schema authority is F3's rules file
  (`.claude/rules/parallel-orchestration.md`) and validators, which need no skill preload. F5 may
  add the preload when it lands (F5 depends on F4, so that later edit is orderly).
- Note: the planner does not `Write` under `docs/features/active/**` — prepared item folders are
  authored by the preparation-mode children in their own worktrees (Q1/Q2), so no such write
  scope is needed; this keeps the persona's write surface as narrow as `epic-planner`'s.

`.claude/skills/parallel-plan/SKILL.md` frontmatter mirrors `epic-plan/SKILL.md`:
`context: fork`, `agent: parallel-planner`, `argument-hint: "[items: issue numbers and/or
potential-entry paths]"`.

**Invocation origin.** §9 requires extending `.claude/hooks/enforce-epic-invocation-origin.ps1`
to deny `Agent(parallel-planner)` (and `Agent(parallel-orchestrator)`) calls originating from
`orchestrator`. The epic decomposition assigns this to **F7** (`epic.md` "F7 — Enforcement
hooks": "...and the extension of `.claude/hooks/enforce-epic-invocation-origin.ps1` to deny
`Agent(parallel-orchestrator)` and `Agent(parallel-planner)` calls originating from
`orchestrator`"), confirmed not-F4. What F4 must document so F7 can implement it:

- The agent body carries an `## Invocation Origin` section (mirroring `epic-planner.md` lines
  47-53) stating: invoked from the main session only; delegates to `Agent(orchestrator)`, so an
  orchestrator-originated invocation would nest `orchestrator` inside its own delegation chain;
  enforcement is the extension of `enforce-epic-invocation-origin.ps1` (adding
  `'parallel-planner'` and `'parallel-orchestrator'` to `$script:GatedSubagentTypes`, line 36),
  delivered by the `parallel-enforcement-hooks` feature (F7), with the existing deny reason
  pattern `EPIC_INVOCATION_ORIGIN_BLOCKED` (or a renamed shared reason — F7's choice).
- Until F7 lands, the constraint is documented-but-unenforced; F4's spec should state this
  explicitly so the gap is a known, tracked condition rather than an omission.

---

## Q8 — Item intake

- **Invocation shape.** `/parallel-plan <slug> <item> [<item> ...]` where each `<item>` is either
  a GitHub issue number (promoted work) or a potential-entry path (unpromoted work). This matches
  the §8.3 `/parallel-add <issue|potential-entry>` intake domain, so F6's add operation and F4's
  initial intake accept the same forms. The `preparation` route already carries the promotion MCP
  tools (`new_potential_entry`, `potential_to_issue`, `new_active_feature_folder` —
  `config/orchestration-routing.json` lines 93-98), so an unpromoted item is promoted by its own
  preparation-mode child, exactly as epic children are.
- **`issue_num` resolution.** For an issue-number item, `issue_num` is known at intake. For a
  potential-entry item, `issue_num` does not exist until the child's promotion step; the planner
  records a placeholder and back-fills from the child's promotion receipt at collection time —
  the epic manifest's verified convention (`docs/features/epics/parallel-orchestration/epic.md`
  frontmatter comment: "issue_num values -1 through -8 are placeholders that are back-filled with
  the real GitHub issue numbers from each child's promotion receipt as preparation completes").
- **Placeholder analogue: yes, required.** Because `issue_num` is the §11 primary key and cohort
  `item_keys[]` reference it, the parallel manifest needs the same negative-placeholder
  convention: placeholders assigned in intake order (-1, -2, ...), back-filled as each
  preparation completes, and the manifest committed in fully resolved form (no negative keys)
  before the kickoff artifact is written — mirroring `epic-plan/SKILL.md` lines 65-67. Ordering
  is naturally safe: cohort seeding requires declared radii, radii require approved plans, plans
  require promotion, so every `issue_num` is resolved before F2 is invoked.
- **`feature_folder` hints.** Recorded as resolvable-hint basenames (§11), resolved to concrete
  `docs/features/active/<basename>` paths after promotion, with lifecycle-prefix stripping at
  resolution time — the same convention `epic-orchestrate/SKILL.md` lines 64-66 defines. The
  concrete resolution is additionally pinned by the recorded per-item `branch_name` (Q1), which
  is where the folder actually lives until the item merges.
- **`kind: feature | bug`** (§11) is recorded at intake from the item source (issue labels or
  the potential entry's declared kind); when indeterminate, default `feature` and note it — a
  minor convention F4's spec should state `[recommendation, not upstream-constrained]`.

---

## Q9 — Testing strategy

### Verified precedent for testing `.claude/` Markdown surfaces

Two established families:

1. **Pester structural tests** — `tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1`:
   asserts skill/agent files exist (`Test-Path`), and asserts content properties via regex
   (`Should -Match 'Agent\([^)]*prd-feature'`, `Should -Not -Match 'context:\s*fork'`). Sibling
   files: `claude-architecture-doc.Tests.ps1`, `legacy-discovery-agent-roles.Tests.ps1`.
2. **Pytest contract tests** — `tests/scripts/dev_tools/test_orchestration_guardrail_contracts.py`
   (asserts required literal fragments in runtime surface files),
   `test_legacy_discovery_skills_contracts.py`, `test_epic_run_kickoff_discovery_contract.py`
   (kickoff/discovery wording contracts). Pattern: read the file, assert exact fragments.

Both satisfy the `tests/` mirroring rule in `.claude/rules/general-unit-test.md` ("Test File
Location").

### What F4 must add

Primary recommendation: one pytest contract test,
`tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`, following the
`test_epic_run_kickoff_discovery_contract.py` style, asserting at minimum:

- `.claude/agents/parallel-planner.md` and `.claude/skills/parallel-plan/SKILL.md` exist.
- Agent frontmatter declares `Agent(orchestrator)`, the `docs/features/parallel/**` write scope,
  `Bash(poetry run *)`, and the validator MCP tool; declares NO `docs/features/epics/**` scope.
- Skill frontmatter declares `context: fork` and `agent: parallel-planner`.
- The skill contains the literal reused markers `Preparation mode: true` and
  `route_id: preparation`, and instructs branching preparation worktrees from `origin/main`.
- The skill contains NO `Epic mode: true`, NO `Parallel mode: true` in the preparation kickoff
  line, NO `depends_on` authoring instruction, and NO integration-branch creation instruction
  (negative assertions encoding constraints 2 and 4).
- The skill names the checkpoint path `artifacts/orchestration/parallel-planner-state.json`, the
  manifest path pattern `docs/features/parallel/<slug>/parallel.md`, and the kickoff paths from
  Q5.
- `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/agents/epic-planner.md`, and
  `.claude/skills/epic-plan/SKILL.md` still contain their pre-existing identifying lines
  (unmodified-surface guard at the content level; the byte-level guarantee is the diff itself).

A parallel Pester file (`tests/scripts/claude-runtime/parallel-planner-surface.Tests.ps1`) is an
acceptable alternative or supplement; pytest is preferred because most asserted properties are
literal string contracts shared with the Python-validated artifacts, and the dev_tools test
family already hosts the epic kickoff analogue.

### Coverage obligation

If F4 delivers only the two Markdown surfaces plus tests, **F4 introduces no executable
production code**: Markdown files are in no coverage denominator, and test files are excluded
from coverage by policy (`.claude/rules/general-unit-test.md` "Coverage Requirements"). The
>= 85% line / >= 75% branch thresholds then impose no new obligation beyond not regressing
existing suites. If the Q5 contingency fires and F4 ships `parallel_kickoff_contract.py`, that
module is production Python and carries the full toolchain loop (Black/Ruff/Pyright/pytest per
`.claude/rules/python.md`) and the uniform coverage thresholds; its tests belong at
`tests/scripts/dev_tools/test_parallel_kickoff_contract.py`.

---

## Q10 — File-size compliance

`.claude/rules/general-code-change.md` caps production/test/reusable-script files at 500 lines
and exempts "Markdown documentation files". Measured precedents (verified by read/line count):

- `.claude/agents/epic-planner.md` — 122 lines.
- `.claude/skills/epic-plan/SKILL.md` — 190 lines.
- `.claude/skills/orchestrate/SKILL.md` — 368 lines (the largest closely comparable surface).

Whether runtime-surface Markdown is "documentation" for the exception is not explicitly settled
in the rule text, but observed practice keeps every comparable surface under 500 lines. Finding
for the plan: size `.claude/agents/parallel-planner.md` at roughly 120-150 lines and
`.claude/skills/parallel-plan/SKILL.md` at roughly 200-280 lines, staying under 500 without
relying on the exception. The parallel skill omits two epic-plan sections entirely (worthiness
gate, dependency/wave design) and adds three (radius validation, cohort seeding, item intake), so
the epic-plan length is a realistic envelope.

---

## Automation Feasibility

Every step of delivering F4 is automatable with the tool surfaces already present in this
repository. Evidence by step:

- **GitHub issue promotion** (for items prepared during any F4 verification run, and for F4's own
  lifecycle): performed by MCP tools `new_potential_entry`, `potential_to_issue`,
  `new_active_feature_folder`, all required by the `preparation` route
  (`config/orchestration-routing.json` lines 93-98) and exercised routinely by preparation-mode
  children. No web UI required.
- **Branch and worktree operations:** `git worktree`, `git checkout -b`, `git push`, `git fetch`,
  `git show`/`git cat-file` — all within `Bash(git *)`, with the epic surfaces as working
  precedent (`epic-plan/SKILL.md` lines 79-92; `epic-run/SKILL.md` lines 26-37).
- **Authoring the deliverables:** `Write`/`Edit` of Markdown and Python test files; toolchain via
  `Bash(poetry run *)` / Pester MCP tools.
- **PR authoring and merge for F4 itself:** `Agent(pr-author)` + `gh` per the standard S9 flow.
- **Third-party UI:** none is involved at any step.

No `scope_change`, `exception`, or `halt` response is required. The only human-shaped events in
scope are downstream design intents (the user replays the kickoff artifact to start execution),
which are outside F4's delivery boundary.

---

## Rejected alternatives (summary)

- **Q1(a) commit prepared artifacts to `main`:** serializes planning behind PR/CI latency, leaves
  orphaned folders for withdrawn items, and creates conflict exposure with items' own execution
  PRs.
- **Q1(c) single planning branch holding all prepared folders:** recreates the fan-in merge §4
  removes and duplicates every feature folder across two diverging refs. (Retained only in the
  restricted run-level form inside the recommended hybrid.)
- **Q1(d) checkpoint-only storage:** violates the unchanged preparation contract's commit step
  and is not durable (`artifacts/` is gitignored).
- **Q3 alternative call surfaces (MCP compute tool, PowerShell module as primary):** no F3 scope
  exists for an MCP compute tool; the PowerShell module is the parity artifact, not the planner's
  primary surface; CLI-over-`Bash(poetry run *)` has direct precedent.
- **Q9 Pester-only testing:** viable, but the string-contract assertions align better with the
  existing dev_tools pytest family that already tests the epic kickoff wording.

---

## Recommendations for `spec.md`

`spec.md` must state the following resolutions explicitly:

1. **Artifact home (Q1, the primary resolution).** Per-item prepared artifacts live on the
   item's own feature branch created from `origin/main` at preparation time, committed by the
   unchanged `route_id: preparation` terminal step, pushed to `origin` before worktree removal,
   and reused as the execution branch; run-level artifacts (`parallel.md`,
   `parallel-kickoff.md`) live on the planner-owned, never-merged-into branch
   `parallel/<slug>-plan`; readers access both by ref (`git fetch` + `git show`) without
   checkout. Record the three residual risks (stale base at execution, branch accumulation on
   withdrawal, F3 per-branch git-integrity requirement).
2. **Preparation kickoff line (Q2).** The exact parallel kickoff line: markers
   `Preparation mode: true. route_id: preparation.` verbatim; `parallel_slug: <slug>` replacing
   the epic context fields; base ref `origin/main`; an explicit push instruction; downstream
   attribution to `parallel-orchestrator`; the `model_budget.fable_policy` marker appended; no
   `Epic mode: true` and no `Parallel mode: true`. State that no edit is made to
   `.claude/skills/orchestrate/SKILL.md` or to `config/orchestration-routing.json`.
3. **F1 invocation contract (Q3).** The required `compute_blast_radius` CLI/JSON contract, the
   V1/V2-Blocking re-plan loop (item stays un-`prepared`; re-planned, not rejected), V3
   Advisory recording, and the `[ASSUMPTION]` flag pending F1's landed spec.
4. **F2 seeding contract (Q4).** One seeding invocation over the full conflict graph after all
   items are prepared; `cohorts[]` `{index, generation: 0, item_keys[]}`;
   `recolor_generation: 0`; `max_concurrency` recorded but not enforced by F4; recoloring is
   F6/F8 scope.
5. **Kickoff artifact (Q5).** Paths, heading, required sections, and the
   `issue_num | feature_folder | cohort | complexity | branch | plan-path` item table; the
   required F3 deliverable `parallel_kickoff_contract.py` + `artifact_type: "parallel-kickoff"`,
   with the stated contingency if F3 lands without it.
6. **Checkpoint instances (Q6).** The field set F4 writes, the absence of any worthiness or
   dependency fields, the `PARALLEL_EXECUTION_READY` sentinel, and the statement that the schema
   and validator are F3-owned; flag the single-item-run question for F3 rather than deciding it.
7. **Agent persona (Q7).** The frontmatter above, including the `Bash(poetry run *)` delta and
   the `docs/features/parallel/**` write scoping; the `## Invocation Origin` section documenting
   the F7-owned hook extension (`$script:GatedSubagentTypes` + `'parallel-planner'`,
   `'parallel-orchestrator'`) and the documented-but-unenforced window until F7 lands.
8. **Item intake (Q8).** Mixed issue-number / potential-entry intake; negative-placeholder
   `issue_num` convention with back-fill from promotion receipts; manifest committed in fully
   resolved form before kickoff; `kind` defaulting rule.
9. **Tests (Q9).** `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` with the
   positive and negative assertions listed above; the no-executable-code coverage position, and
   the conditional obligation if the Q5 contingency adds a Python module.
10. **Sizing (Q10).** Both Markdown deliverables target well under 500 lines.
11. **Non-modification guarantees.** Restate as acceptance-verifiable facts: no change to
    `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/agents/epic-planner.md`,
    `.claude/skills/epic-plan/SKILL.md`, `.claude/skills/orchestrate/SKILL.md`, or
    `config/orchestration-routing.json`.
