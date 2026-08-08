# parallel-planner-surface — Spec

- **Issue:** #443
- **Parent:** epic `parallel-orchestration` (`docs/features/epics/parallel-orchestration/epic.md`, feature F4, wave 2)
- **Owner:** drmoisan
- **Last Updated:** 2026-08-07
- **Status:** Approved for planning
- **Version:** 1.0
- **Work Mode:** full-feature (acceptance criteria live in this file and in `user-story.md`)

Primary inputs, in precedence order:

1. `docs/features/active/2026-08-07-parallel-planner-surface-443/research/parallel-planner-surface.2026-08-07T12-30.md` — completed research (Q1-Q10). All resolutions below restate that artifact's recommendations.
2. `docs/features/active/2026-08-07-parallel-planner-surface-443/issue.md` — promoted issue #443.
3. `docs/research/2026-08-07-parallel-orchestration-design-research.md` — accepted design. Section references (§N) refer to this document.
4. `docs/features/epics/parallel-orchestration/epic.md` — epic narrative, shared design, non-goals.

## Overview

The `parallel` orchestration surface (§1-§4) executes multiple thematically unrelated bugs and
features concurrently, scheduled by computed blast-radius contention rather than a human-authored
dependency graph. F4 delivers its planning half: the `parallel-planner` agent persona and the
`parallel-plan` skill, which together perform item intake, preparation fan-out through the
unchanged `route_id: preparation` child contract (§8.3 item 2), blast-radius derivation and V1-V3
validation (§5.3), cohort seeding (§6), manifest and checkpoint authoring (§11, §12), and kickoff
artifact emission mirroring the epic kickoff contract.

The structural precedents are `.claude/agents/epic-planner.md` (122 lines),
`.claude/skills/epic-plan/SKILL.md` (190 lines), and `scripts/dev_tools/epic_kickoff_contract.py`.
The parallel surface is additive: it adapts these precedents into new `parallel`-named files and
modifies none of them.

## Deliverables

1. `.claude/agents/parallel-planner.md` — new agent persona (contract in
   "Deliverable 1" below).
2. `.claude/skills/parallel-plan/SKILL.md` — new planning skill (contract in
   "Deliverable 2" below).
3. `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` — pytest contract test
   (contract in "Testing" below).

No other file is created or modified in the base scope. One contingency can add a Python module;
see "Kickoff parser/validator boundary" below.

## Non-Negotiable Constraints

From the epic's Shared Design section and §3/§4. Each is restated here as a delivery constraint:

1. **Naming.** The surface is named `parallel` throughout: skill `parallel-plan`, agent
   `parallel-planner`, home `docs/features/parallel/<slug>/`, manifest `parallel.md`, checkpoint
   `artifacts/orchestration/parallel-planner-state.json`.
2. **No worthiness gate; no dependency graph.** There is NO epic-worthiness gate analogue and NO
   dependency graph to author. The planner computes blast radii and derives conflicts; it never
   asks a human for `depends_on`. The delivered skill contains no worthiness-gate section and no
   dependency-authoring instruction.
3. **Planner-computed radius.** Blast radius is planner-computed and validated against the
   approved atomic plan (§5.3). V1 (coverage) and V2 (shared-surface enumeration) are Blocking;
   V3 (over-breadth) is Advisory.
4. **No integration branch** (§4). Items PR to `main` independently. The planner creates no
   integration branch, and the delivered skill contains no integration-branch creation
   instruction.
5. **Atomic-plan contract unchanged.** `.claude/skills/atomic-plan-contract/SKILL.md` must NOT
   be changed.
6. **Additive only.** `.claude/agents/epic-planner.md` and `.claude/skills/epic-plan/SKILL.md`
   must NOT be modified or refactored.

## Resolution R1 — Artifact Home for Prepared Items (Decision)

The design document does not fully resolve where prepared items' planning artifacts live given
that there is no shared fan-in branch. The research (Q1) resolves this with hybrid option (e),
adopted here as a decision:

1. **Per-item artifacts.** Each item's prepared feature folder and approved atomic plan live on
   the item's own feature branch, created from `origin/main` at preparation time, committed by
   the unchanged `route_id: preparation` terminal step — whose wording "commit the prepared
   feature folder and plan to the current branch" (`.claude/skills/orchestrate/SKILL.md` line 97)
   is satisfied verbatim — pushed to `origin` before worktree removal, and reused as the item's
   execution branch. The planner records `branch_name` and `worktree_path` per item in
   `artifacts/orchestration/parallel-planner-state.json`.
2. **Run-level artifacts.** `docs/features/parallel/<slug>/parallel.md` (manifest) and
   `docs/features/parallel/<slug>/parallel-kickoff.md` (durable kickoff copy) live on a
   planner-owned branch `parallel/<slug>-plan`, created off `origin/main` and pushed. This branch
   is not an integration branch: no item branch ever merges into it and it never merges into any
   item branch. It holds only the run home `docs/features/parallel/<slug>/**`, which no item's
   blast radius may include.
3. **Read access.** Readers (validators, `parallel-orchestrator`) access both artifact classes by
   ref — `git fetch origin <branch>` plus `git show <branch>:<path>` — without checking the refs
   out, per the technique documented in `.claude/skills/epic-run/SKILL.md` lines 26-37.

Rationale: no fan-in point is reintroduced (§4 forbids one; §8 mutable membership relies on its
absence); inter-item merge-conflict exposure during preparation is zero because branches are
disjoint; late arrivals under §8.3 dynamic membership get a new branch without touching prior
work. Rejected alternatives (commit to `main`; a single shared planning branch holding all
prepared folders; checkpoint-only storage) are recorded in the research artifact's Q1 and
"Rejected alternatives" sections.

Residual risks (recorded, not eliminated):

- **Stale execution base.** An item branch created at preparation time is based on an older
  `main` tip by the time its cohort executes. Mitigation is F5's procedure (execution-phase child
  merges `origin/main` at start; cohort construction per §6 keeps peers non-conflicting; real
  overlap is caught by F8 drift detection per §7). F4 records the branch-reuse contract only.
- **Branch accumulation on withdrawal.** Withdrawn or abandoned items leave pushed preparation
  branches. F6's `--disposition abandon` path is expected to delete the branch; this spec records
  the cleanup expectation so F6 can implement it.
- **F3 per-branch git-integrity requirement.** The planner-state readiness gate's git-integrity
  analogue must verify committed plan blobs against per-item branch refs plus the
  `parallel/<slug>-plan` ref, instead of the epic's single `integration_branch` ref.
  `[ASSUMPTION — F3 unlanded; contract source §12 plus the epic precedent
  `scripts/dev_tools/epic_planner_git_integrity.py`]`

## Upstream Dependency Status and Assumptions

Verified by the research at commit base `5a0becb0`: F1 (`parallel-blast-radius`), F2
(`parallel-cohort-scheduler`), and F3 (`parallel-schema-validators`) have NOT landed on
`epic/parallel-orchestration-integration`. No `parallel` feature folder other than this one
exists under `docs/features/active/`; `scripts/dev_tools/` contains no `compute_blast_radius.py`,
no `parallel_cohort_computation.py`, and no `validate_parallel_*` validator; the MCP
`VALID_ARTIFACT_TYPES` set in `extensions/drm-copilot/src/mcp-tool-inputs.ts` contains no
`parallel` artifact type.

Consequence: every F1/F2/F3 interface below is a required upstream contract stated from the
design sections, labeled `[ASSUMPTION]` with the section cited. Confirmation is a re-check of
`docs/features/active/` and `scripts/dev_tools/` at atomic-planning time; a landed upstream spec
supersedes the corresponding assumption. F4 CALLS the F1 and F2 implementations and does NOT
reimplement either.

### R3 — F1 blast-radius invocation contract `[ASSUMPTION — F1 unlanded; §5.1-§5.4]`

- **Call surface.** `scripts/dev_tools/compute_blast_radius.py`, importable and CLI-invocable
  (`poetry run python -m scripts.dev_tools.compute_blast_radius ...`), following the repository's
  reference-implementation pattern (`epic_wave_computation.py`, `compute_complexity_floor.py`,
  `resolve_delegation_model.py`). The planner invokes it as a CLI subprocess with JSON output via
  `Bash(poetry run *)`; an MCP compute tool is not assumed (F3's scope covers validator wiring
  only).
- **Inputs.** Approved atomic plan path, feature `spec.md` path, feature folder path, and the
  F1-owned shared-surface configuration truth table (§5.1 item 3). The module-mapping source is
  F1-defined and opaque to F4: §5.1 names `quality-tiers.yml`, but that file does not exist at
  the repository root (verified; also recorded in `epic.md` under "F1 — Known constraint").
- **Output.** JSON `{ "paths": [...], "modules": [...], "shared_surfaces": [...],
  "contracts": [...], "source": "declared", "computed_at": "<iso8601>" }` (§5.1, §5.2, §11), plus
  a findings list where each finding carries
  `{ rule: "V1"|"V2"|"V3", severity: "Blocking"|"Advisory", detail }` (§5.3).
- **Contention relation.** A callable `conflicts(a, b)` (or an edge-derivation entry point over a
  set of radii) returning the conflict verdict with a `reason` in
  `{path_overlap, module_overlap, shared_surface_overlap, contract_dependency}` (§5.4, §12).
  Fails closed.

**Validation-result behavior (F4 procedure):**

- **V1 or V2 Blocking failure:** the item does NOT transition to `prepared`. The planner records
  the findings in the checkpoint (per-item `radius_validation` entry) and issues a follow-up
  preparation-mode delegation for that item carrying the findings as plan-revision instructions —
  the same iterate-until-clear posture the child already applies to preflight. The item is
  re-planned, not rejected; rejection or withdrawal is a caller decision via F6's remove
  operation, never a planner default.
- **V3 Advisory:** recorded in the checkpoint and surfaced in the completion report; no state
  effect (§5.3: "reported, not rejected").
- Readiness consequence: `prepared` requires preflight `PREFLIGHT: ALL CLEAR` AND a `declared`
  radius with V1/V2 pass. This conjunction is the F3-owned readiness invariant F4's checkpoint
  instances must satisfy `[ASSUMPTION — F3 unlanded; §12]`.

### R4 — F2 cohort-seeding contract `[ASSUMPTION — F2 unlanded; §6]`

- **Call surface.** `scripts/dev_tools/parallel_cohort_computation.py`, importable and
  CLI-invocable, deterministic greedy coloring in Welsh-Powell order: vertices sorted by
  descending degree, ties broken by ascending item key.
- **Inputs.** The item-key set (item key = `issue_num`, the §11 primary key) and the undirected
  conflict edge set derived by F1's `conflicts(a, b)` over the items' `declared` radii. The
  pinned-set parameter exists for recoloring (§8.1) and is empty at seeding time.
- **Output.** `cohorts[]` of `{ index, generation, item_keys[] }` (§12), `item_keys[]` sorted
  ascending within each cohort.

**F4 procedure:** invoke F2 exactly once per plan run, after every item is `prepared` and
radius-validated, over the full conflict graph. Record `cohorts[]` with `generation: 0`,
initialize `recolor_generation: 0` and `current_cohort: 0`, and record `conflict_edges[]`
(`{a, b, reason}`) for auditability (§12). `max_concurrency` is NOT a coloring input: it is a
manifest field (default 4, §11) capping execution fan-out within a cohort, slots filled in
ascending item-key order (§6); enforcement is F5's, F4 only records the value. Recoloring under
add/remove/drift mutation is F6/F8 scope (§8.1, §8.3 step 4); `parallel-plan` performs seeding
only.

### F3 ownership boundary `[ASSUMPTION — F3 unlanded; §11, §12, epic F3 scope entry]`

F3 owns: the §11 manifest schema, the §12 checkpoint schema,
`scripts/dev_tools/validate_parallel_planner_state.py`, the MCP `artifact_type` wiring in
`validate_orchestration_artifacts`, `.claude/rules/parallel-orchestration.md`, and
`route_id: parallel` in `config/orchestration-routing.json`. F4 only writes conforming instances
and validates them through F3's validators via
`mcp__drm-copilot__validate_orchestration_artifacts`. F4 defines no schema and adds no validator
in the base scope.

### Kickoff parser/validator boundary (research Q5 finding)

`scripts/dev_tools/parallel_kickoff_contract.py` and the MCP
`artifact_type: "parallel-kickoff"` wiring are recommended F3 deliverables by the
schema-ownership principle (F3 serializes cross-feature shapes into schemas and validators, per
the epic "Decomposition Rationale" table; the epic analogue `epic_kickoff_contract.py` is
consumed by `validate_epic_planner_state.py`, an F3-analogue module). F4 owns authoring the
kickoff artifact instances and the skill text that emits them. `[ASSUMPTION — F3 unlanded]`

**Contingency (explicit):** if F3 lands without `parallel_kickoff_contract.py`, F4 delivers that
module and the minimal additive `artifact_type: "parallel-kickoff"` wiring itself and records the
boundary deviation in this spec — the kickoff cannot ship unvalidatable. The epic's wave-4
confinement discipline (distinct named additions, no reflow) applies to the wiring edit. If this
contingency fires, the module is production Python carrying the full toolchain loop and uniform
coverage thresholds; see "Testing" below.

### Invocation-origin hook extension (F7-owned; research Q7 finding)

§9 requires extending `.claude/hooks/enforce-epic-invocation-origin.ps1` to deny
`Agent(parallel-planner)` and `Agent(parallel-orchestrator)` calls originating from
`orchestrator`. The epic decomposition assigns this to F7 (`epic.md`, "F7 — Enforcement hooks");
F4 does not modify the hook. What F4 must document so F7 can implement it — the exact extension
point identified in the research:

- Add `'parallel-planner'` and `'parallel-orchestrator'` to `$script:GatedSubagentTypes` in
  `.claude/hooks/enforce-epic-invocation-origin.ps1` (line 36), gated against caller
  `agent_type == 'orchestrator'`, with the existing deny-reason pattern
  `EPIC_INVOCATION_ORIGIN_BLOCKED` (or a renamed shared reason — F7's choice).
- Until F7 lands, the constraint is documented-but-unenforced. This spec states that gap
  explicitly so it is a known, tracked condition rather than an omission; the agent persona's
  `## Invocation Origin` section (Deliverable 1) carries the same statement.

## Deliverable 1 — `.claude/agents/parallel-planner.md` (Resolution R7)

Frontmatter contract, mirroring `.claude/agents/epic-planner.md` with the minimal deltas:

- `name: parallel-planner`; `model: opus`; `memory: project`; no `hooks` block (matching
  `epic-planner.md`, which declares none).
- `tools`:
  - `"Agent(orchestrator)"` — preparation fan-out.
  - `Read`, `Grep`, `Glob`.
  - `"Write(docs/features/parallel/**)"`, `"Edit(docs/features/parallel/**)"` — the run home;
    the parallel counterpart of epic-planner's `docs/features/epics/**` scoping. The persona
    declares NO `docs/features/epics/**` write scope and NO `docs/features/active/**` write
    scope: prepared item folders are authored by the preparation-mode children in their own
    worktrees (R1/R2), keeping the write surface as narrow as `epic-planner`'s.
  - `"Write(artifacts/orchestration/**)"`, `"Edit(artifacts/orchestration/**)"`.
  - `"Bash(git *)"`, `"Bash(gh *)"`.
  - `"Bash(poetry run *)"` — delta from `epic-planner`, required to invoke F1's radius CLI and
    F2's cohort CLI (R3/R4); precedent: `.claude/agents/orchestrator.md` line 13.
  - `"mcp__drm-copilot__validate_orchestration_artifacts"`.
- `skills`: `policy-compliance-order`, `parallel-plan`, `feature-promotion-lifecycle`,
  `atomic-plan-contract`, `evidence-and-timestamp-conventions`. No `parallel-orchestrate`
  preload: F5's skill does not exist in wave 2; the parallel schema authority is F3's rules file
  and validators, which need no skill preload. F5 may add the preload when it lands (F5 depends
  on F4).

Body sections: role statement (planning half only, no execution; distinct from the future
`parallel-orchestrator`), `## Skill` (defers procedure to `parallel-plan`), `## Invocation
Origin` (per the F7 section above: main-session invocation only; delegates to
`Agent(orchestrator)`; enforcement is the F7-owned hook extension; documented-but-unenforced
until F7 lands), `## Startup Protocol` (checkpoint read and resume), `## Delegation Model`
(exclusively `Agent(orchestrator)` preparation-mode children), `## Checkpoint Persistence`, and
`## Completion Requirements`.

## Deliverable 2 — `.claude/skills/parallel-plan/SKILL.md`

Frontmatter: `name: parallel-plan`; `context: fork`; `agent: parallel-planner`;
`argument-hint: "[items: issue numbers and/or potential-entry paths]"`. Mirrors
`.claude/skills/epic-plan/SKILL.md` structurally, with the worthiness-gate and
dependency/wave-design sections omitted entirely (constraint 2) and radius validation, cohort
seeding, and item intake sections added.

### Item intake (Resolution R8)

- Invocation shape: `/parallel-plan <slug> <item> [<item> ...]` where each `<item>` is a GitHub
  issue number (promoted work) or a potential-entry path (unpromoted work) — the same intake
  domain as §8.3's `/parallel-add`, so F6's add operation and F4's initial intake accept the same
  forms. Unpromoted items are promoted by their own preparation-mode child; the `preparation`
  route already carries the promotion MCP tools (`new_potential_entry`, `potential_to_issue`,
  `new_active_feature_folder`; `config/orchestration-routing.json` lines 93-98).
- `issue_num` resolution: known at intake for issue-number items; for potential-entry items, the
  planner records negative placeholders in intake order (-1, -2, ...) and back-fills from each
  child's promotion receipt as preparation completes — the epic manifest's verified convention.
  The manifest is committed in fully resolved form (no negative keys) before the kickoff artifact
  is written. Ordering is safe by construction: cohort seeding requires declared radii, radii
  require approved plans, plans require promotion, so every `issue_num` resolves before F2 is
  invoked.
- `feature_folder` recorded as a resolvable-hint basename (§11), resolved to a concrete
  `docs/features/active/<basename>` path after promotion with lifecycle-prefix stripping, per the
  `epic-orchestrate` convention; the concrete location is additionally pinned by the recorded
  per-item `branch_name` (R1).
- `kind: feature | bug` (§11) recorded at intake from the item source (issue labels or the
  potential entry's declared kind); when indeterminate, default `feature` and note it
  `[recommendation, not upstream-constrained]`.

### Preparation fan-out (Resolution R2)

One preparation-mode `Agent(orchestrator)` run per item, launched concurrently (one message, N
`Agent` calls, each `isolation: "worktree"` and `run_in_background: true`), each worktree's
branch created from `origin/main` (delta from the epic, which branches from the integration
ref). The delegation prompt includes this literal kickoff line:

> `Preparation mode: true. route_id: preparation. parallel_slug: <slug>. Perform promotion, research, feature documents (spec.md, user-story.md), atomic planning, and preflight clearance only. Atomic execution, PR authoring, and CI monitoring are out of scope for this run and are executed later by parallel-orchestrator. After the atomic-executor preflight returns PREFLIGHT: ALL CLEAR, commit the feature folder and plan to the current branch, push the current branch to origin, set out-of-scope step statuses to not-applicable, set next_step to S5_atomic_execution, and stop, reporting the plan-path and preflight status.`

Properties of this line, each individually load-bearing:

- The markers `Preparation mode: true.` and `route_id: preparation.` are reused verbatim; route
  selection is marker-driven (`.claude/skills/orchestrate/SKILL.md` line 101), so no issuer
  identity is required.
- `parallel_slug: <slug>.` replaces the epic context fields
  (`epic_feature_folder: ... integration_branch: ...`).
- The push instruction ("push the current branch to origin") is an addition to the planner's own
  prompt, not to the child contract text in `orchestrate/SKILL.md` — required by R1 for
  durability before worktree removal.
- Downstream attribution reads "executed later by parallel-orchestrator" (the planner authors its
  own prompt; the orchestrate SKILL text is untouched).
- The `model_budget.fable_policy: <disabled|available|preferred>.` marker line is appended per
  the pattern in `.claude/skills/epic-orchestrate/SKILL.md` `## Model Selection`.
- The line contains NO `Epic mode: true` (so `enforce-epic-wave-barrier.ps1` does not gate
  preparation, per the epic's deliberate omission) and NO `Parallel mode: true` (so F7's future
  cohort-barrier hook, which matches that marker per §9, will not gate preparation either).

**No edit is made to `.claude/skills/orchestrate/SKILL.md` or to
`config/orchestration-routing.json`.** The research verified no functional edit is required: the
route mechanism is marker-driven; the child contract's "commit ... to the current branch" wording
is satisfied by a branch created off `origin/main`; and `routes.preparation` has no epic-specific
required agent, skill, or MCP tool (only its free-text `description` mentions `epic-planner`,
and descriptions are not validated inputs). The epic-flavored parentheticals at
`orchestrate/SKILL.md` lines 92, 95, and 97 are descriptive, not gating, and remain untouched;
the parallel kickoff line itself supplies base branch, slug, and downstream agent, so the child
never needs them. Residual risk (Low, cosmetic): a child could quote an epic parenthetical in its
report; this alters no route, receipt, or terminal checkpoint.

Collected per child at termination: `plan-path`, preflight status, promotion receipt
(`issue_num` back-fill source), model-routing receipt
(`execution_context` analogue of the epic's `epic_preparation_child`,
`logical_agent: "orchestrator"`), topology receipt, and launch bindings (`branch_name`,
`worktree_path`). There is no fan-in merge step: the planner fetches and records each pushed item
branch, back-fills `issue_num` into the manifest on `parallel/<slug>-plan`, and updates the
checkpoint.

### Radius computation and validation

Per R3: after each item's plan is approved and preflight-clear, invoke F1's derivation and V1-V3
validation against the approved atomic plan; record the `declared` radius and `radius_validation`
per item; apply the V1/V2 re-plan loop and V3 Advisory recording defined in R3. The `declared`
radius is authoritative for scheduling (§5.2).

### Cohort seeding

Per R4: one invocation over the full conflict graph after all items are `prepared`; record
`cohorts[]` (`generation: 0`), `conflict_edges[]`, `recolor_generation: 0`, `current_cohort: 0`;
record `max_concurrency` without enforcing it.

### Manifest authoring

Write `docs/features/parallel/<slug>/parallel.md` conforming to the §11 frontmatter schema
(F3-owned): `parallel`, `mode` (`closed | open`, default `closed`), `max_concurrency` (default
4), `created_at`, `items[]` with per-item `issue_num`, `feature_folder`, `kind`, `state`, and
`blast_radius` (`paths`, `modules`, `shared_surfaces`, `contracts`, `source: "declared"`,
`computed_at`). The manifest carries **no `depends_on` field** (§11, constraint 2). Committed in
fully resolved form to `parallel/<slug>-plan` before the kickoff artifact is written.

### Checkpoint instances (Resolution R6)

`artifacts/orchestration/parallel-planner-state.json`. Schema and validator are F3-owned
(`validate_parallel_planner_state.py`, MCP `artifact_type: "parallel-planner-state"`); F4 writes
conforming instances only. Field set F4 writes, stated by analogy to
`validate_epic_planner_state.py` plus §11/§12 `[ASSUMPTION — F3 unlanded]`:

- Top level: `objective`, `parallel_slug`, `parallel_manifest_path`, `mode`, `max_concurrency`,
  `plan_home_branch` (`parallel/<slug>-plan`, per R1), `items[]`, `cohorts[]`,
  `conflict_edges[]`, `recolor_generation`, `kickoff_prompt_path`
  (`artifacts/orchestration/parallel-kickoff-<slug>.md`), `completed_steps`, `next_step`,
  `last_updated`. **Deliberately absent:** any `epic_worthiness` analogue and any
  `depends_on`/`wave` fields (constraint 2).
- Per item: `issue_num`, `feature_folder`, `kind`, `state` (§8.2 lifecycle enum),
  `complexity_band`, `preparation_status`, `research_path`, `plan_path`, `preflight_status`,
  `branch_name`, `worktree_path`, `blast_radius` (§11 shape, `source: "declared"`),
  `radius_validation` (`{v1, v2, v3}` results with severities), `model_routing_receipt`,
  `topology_receipt`.
- Readiness (F3's `require_ready_for_execution` analogue): every non-withdrawn item
  `state == "prepared"` with `preflight_status == "PREFLIGHT: ALL CLEAR"`, a `declared` radius
  with V1/V2 pass, and a unique pushed `branch_name`; `cohorts[]` present at `generation 0`
  covering exactly the prepared item keys; exact `kickoff_prompt_path`; ready sentinel
  `next_step: "PARALLEL_EXECUTION_READY"`; git integrity against per-item branch refs plus
  `parallel/<slug>-plan` (R1 residual risk 3).
- **Flagged for F3, not decided here:** whether the epic's ">= 2 features" floor carries over. A
  parallel run of one item is degenerate but coherent (one cohort of one); the single-item-run
  question is an F3 schema decision.

Obligations: write the checkpoint after every completed step (mirroring `epic-planner.md`
`## Checkpoint Persistence`); on resume, re-derive durable ground truth from
`git branch` / `git worktree list --porcelain` / pushed refs (§12: the checkpoint is a cache,
not the source of truth); validate through F3's validator via
`mcp__drm-copilot__validate_orchestration_artifacts` before reporting completion.

### Kickoff artifact (Resolution R5)

Mirrors `scripts/dev_tools/epic_kickoff_contract.py` with the parallel deltas:

- **Paths.** Working copy `artifacts/orchestration/parallel-kickoff-<slug>.md` (gitignored
  tree); durable copy `docs/features/parallel/<slug>/parallel-kickoff.md`, committed to
  `parallel/<slug>-plan` (R1).
- **Heading.** First line `# Parallel Kickoff: <slug>`.
- **`## Invocation Prompt`** must structurally name: `` Run `/parallel-run <slug>` `` (F5's
  skill); the manifest path `docs/features/parallel/<slug>/parallel.md`; and a resume-boundary
  sentence stating that each item resumes at atomic execution from its committed plan-path **on
  its own pushed feature branch**. The per-item branch column below carries the refs; there is no
  single integration branch to cite.
- **`## Item Summary`** strict pipe table, exact ordered headers:
  `issue_num | feature_folder | cohort | complexity | branch | plan-path`. `cohort` replaces the
  epic's `wave`; `branch` is added because plan-paths are only resolvable against a named
  per-item ref (R1). At least one row; `issue_num` and `cohort` integers; `complexity` in C1-C4.
- **Optional `## Integrity`.** Per-item `plan-path | plan-hash` table (40-64 hex per row, no
  repeated paths); the epic's single `planning_commit` field generalizes to the head commit of
  `parallel/<slug>-plan` (run-level provenance); per-item plan blobs are verified against the
  per-item branch refs by the F3 readiness gate `[ASSUMPTION — F3 unlanded]`.
- **Validation.** Through `parallel_kickoff_contract.py` / `artifact_type: "parallel-kickoff"`
  per the F3 boundary and contingency stated above.

### Completion report

The skill's final report lists: the manifest path and `parallel/<slug>-plan` branch; one
`plan-path:` line, branch name, preflight status, and radius-validation result (including any V3
Advisory findings) per item; the cohort table (`generation 0`); and both kickoff artifact paths.
It ends with the statement that execution has NOT started and begins only when the user runs
`/parallel-run <slug>` or replays the kickoff prompt from the main session.

## Testing (Resolution R9)

**Coverage position.** In the base scope F4 delivers two Markdown runtime surfaces plus tests:
no executable production code is introduced. Markdown files are in no coverage denominator and
test files are excluded from coverage by policy (`.claude/rules/general-unit-test.md`,
"Coverage Requirements"), so the >= 85% line / >= 75% branch thresholds impose no new obligation
beyond not regressing existing suites. The actual test obligation is the contract test below.

**Required test.** `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`,
following the `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py` precedent
(read the surface file, assert exact fragments), asserting at minimum:

Positive assertions:

- `.claude/agents/parallel-planner.md` and `.claude/skills/parallel-plan/SKILL.md` exist.
- Agent frontmatter declares `Agent(orchestrator)`, the `docs/features/parallel/**` write scope,
  `Bash(poetry run *)`, and `mcp__drm-copilot__validate_orchestration_artifacts`.
- Skill frontmatter declares `context: fork` and `agent: parallel-planner`.
- The skill contains the literal reused markers `Preparation mode: true` and
  `route_id: preparation`, and instructs branching preparation worktrees from `origin/main`.
- The skill names `artifacts/orchestration/parallel-planner-state.json`, the manifest path
  pattern `docs/features/parallel/<slug>/parallel.md`, and both kickoff paths from R5.

Negative assertions (encoding constraints 2 and 4):

- Agent frontmatter declares NO `docs/features/epics/**` scope.
- The skill contains NO `Epic mode: true` and NO `Parallel mode: true` in the preparation
  kickoff line, NO `depends_on` authoring instruction, and NO integration-branch creation
  instruction.
- `.claude/skills/atomic-plan-contract/SKILL.md`, `.claude/agents/epic-planner.md`, and
  `.claude/skills/epic-plan/SKILL.md` still contain their pre-existing identifying lines
  (content-level unmodified-surface guard; the byte-level guarantee is the diff itself).

**Conditional obligation.** If the R5 contingency fires and F4 ships
`parallel_kickoff_contract.py`, that module is production Python carrying the full toolchain loop
(Black / Ruff / Pyright / pytest per `.claude/rules/python.md`) and the uniform coverage
thresholds; its tests belong at `tests/scripts/dev_tools/test_parallel_kickoff_contract.py`.

## File-Size Constraint (Resolution R10)

Measured precedent surfaces: `.claude/agents/epic-planner.md` 122 lines,
`.claude/skills/epic-plan/SKILL.md` 190 lines, `.claude/skills/orchestrate/SKILL.md` 368 lines.
Both F4 deliverables must target well under the 500-line limit of
`.claude/rules/general-code-change.md` without relying on the Markdown documentation exception:
`.claude/agents/parallel-planner.md` approximately 120-150 lines,
`.claude/skills/parallel-plan/SKILL.md` approximately 200-280 lines. The parallel skill omits two
epic-plan sections (worthiness gate, dependency/wave design) and adds three (radius validation,
cohort seeding, item intake), so the epic-plan length is a realistic envelope.

## Non-Modification Guarantees (Resolution R11)

Acceptance-verifiable facts about the F4 diff: no change to

- `.claude/skills/atomic-plan-contract/SKILL.md`
- `.claude/agents/epic-planner.md`
- `.claude/skills/epic-plan/SKILL.md`
- `.claude/skills/orchestrate/SKILL.md`
- `config/orchestration-routing.json`

## Acceptance Criteria

Technical and contract criteria. Outcome and behavioral criteria from the operator's perspective
are in `user-story.md`; together the two files are the authoritative acceptance-criteria source
for this `full-feature` work mode.

- [x] `.claude/agents/parallel-planner.md` exists with frontmatter `name: parallel-planner`,
      `model: opus`, `memory: project`, no `hooks` block, and the exact tool allowlist in
      Deliverable 1, including `"Bash(poetry run *)"` and the
      `docs/features/parallel/**` write/edit scoping; it declares no `docs/features/epics/**`
      and no `docs/features/active/**` write scope.
- [x] `.claude/agents/parallel-planner.md` preloads exactly the skills `policy-compliance-order`,
      `parallel-plan`, `feature-promotion-lifecycle`, `atomic-plan-contract`, and
      `evidence-and-timestamp-conventions`, and does not preload `parallel-orchestrate`.
- [x] `.claude/agents/parallel-planner.md` contains an `## Invocation Origin` section that
      documents the F7-owned extension of `.claude/hooks/enforce-epic-invocation-origin.ps1`
      (adding `'parallel-planner'` and `'parallel-orchestrator'` to
      `$script:GatedSubagentTypes`) and states that the constraint is documented-but-unenforced
      until F7 lands.
- [x] `.claude/skills/parallel-plan/SKILL.md` exists with frontmatter `context: fork`,
      `agent: parallel-planner`, and an argument hint accepting issue numbers and/or
      potential-entry paths.
- [x] The skill's preparation kickoff line contains the verbatim markers
      `Preparation mode: true.` and `route_id: preparation.`, the field
      `parallel_slug: <slug>`, an explicit push-to-origin instruction, downstream attribution to
      `parallel-orchestrator`, and the appended `model_budget.fable_policy` marker line; it
      contains no `Epic mode: true` and no `Parallel mode: true`.
- [x] The skill instructs creating each preparation worktree's branch from `origin/main`, and the
      F4 diff contains no change to `.claude/skills/orchestrate/SKILL.md` and no change to
      `config/orchestration-routing.json` (including the `preparation` route).
- [x] The skill states the R1 artifact-home decision: per-item prepared artifacts on the item's
      own feature branch created from `origin/main`, pushed before worktree removal, and reused
      at execution; run-level artifacts (`parallel.md`, `parallel-kickoff.md`) on the
      planner-owned, never-merged-into branch `parallel/<slug>-plan`; readers use
      `git fetch` + `git show <ref>:<path>` per the `.claude/skills/epic-run/SKILL.md`
      precedent. The three residual risks (stale execution base, branch accumulation on
      withdrawal, F3 per-branch git-integrity requirement) are recorded.
- [ ] The skill documents invoking F1's radius derivation and V1-V3 validation via
      `Bash(poetry run *)` against each item's approved atomic plan, labelled as an upstream
      contract (§5.1-§5.4) pending F1; it contains no reimplementation of derivation, V1-V3, or
      `conflicts(a, b)`.
- [x] The skill documents V1/V2 Blocking semantics (item stays un-`prepared`; findings recorded
      in `radius_validation`; item re-planned via a follow-up preparation delegation, not
      rejected) and V3 Advisory semantics (recorded and surfaced, no state effect).
- [ ] The skill documents one cohort-seeding invocation of F2's Welsh-Powell reference over the
      full conflict graph after all items are `prepared`, labelled as an upstream contract (§6)
      pending F2, recording `cohorts[]` at `generation: 0`, `conflict_edges[]`,
      `recolor_generation: 0`, and `current_cohort: 0`; it states that `max_concurrency`
      (default 4, slots filled in ascending item key) is recorded but not enforced by F4, and
      that recoloring is F6/F8 scope.
- [x] The skill specifies the kickoff artifact per R5: heading `# Parallel Kickoff: <slug>`;
      `## Invocation Prompt` naming `/parallel-run <slug>`, the manifest path, and the
      per-item-branch resume-boundary sentence; `## Item Summary` with exact ordered headers
      `issue_num | feature_folder | cohort | complexity | branch | plan-path`; optional
      `## Integrity`; working copy at `artifacts/orchestration/parallel-kickoff-<slug>.md` and
      durable copy at `docs/features/parallel/<slug>/parallel-kickoff.md`.
- [ ] The spec's F3 boundary is stated in the delivered skill: manifest and checkpoint schemas,
      `validate_parallel_planner_state.py`, MCP `artifact_type` wiring,
      `.claude/rules/parallel-orchestration.md`, and `route_id: parallel` are F3-owned; F4
      writes conforming instances and validates via
      `mcp__drm-copilot__validate_orchestration_artifacts`; the
      `parallel_kickoff_contract.py` / `artifact_type: "parallel-kickoff"` recommendation and
      its contingency are recorded; the single-item-run floor question is flagged for F3, not
      decided.
- [x] The skill documents the checkpoint instance contract per R6, including the
      `PARALLEL_EXECUTION_READY` ready sentinel and the deliberate absence of any
      `epic_worthiness`, `depends_on`, or `wave` field; the manifest section documents that
      `parallel.md` carries no `depends_on` field and is committed fully resolved (no negative
      `issue_num`) before kickoff emission.
- [x] The skill documents item intake per R8: mixed issue-number / potential-entry intake,
      negative-placeholder `issue_num` values back-filled from promotion receipts, and the
      `kind` default-to-`feature` rule.
- [x] The delivered skill contains no epic-worthiness gate analogue, no dependency-graph
      authoring instruction, and no integration-branch creation instruction.
- [ ] `tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py` exists, follows the
      `test_epic_run_kickoff_discovery_contract.py` precedent, contains the positive and
      negative assertions listed under "Testing", and passes.
- [ ] The F4 diff contains no change to `.claude/skills/atomic-plan-contract/SKILL.md`,
      `.claude/agents/epic-planner.md`, or `.claude/skills/epic-plan/SKILL.md`.
- [x] `.claude/agents/parallel-planner.md` and `.claude/skills/parallel-plan/SKILL.md` are each
      under 500 lines.
- [ ] The atomic plan re-verifies the F1/F2/F3 landing status recorded in this spec at planning
      time and reconciles any landed upstream spec against the corresponding `[ASSUMPTION]`
      entries before execution.
