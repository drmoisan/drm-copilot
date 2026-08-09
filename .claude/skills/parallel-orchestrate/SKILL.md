---
name: parallel-orchestrate
description: Execute a prepared parallel run for the parallel-orchestrator agent — cohort scheduling under a max_concurrency cap, per-item fan-out onto isolated worktrees branched from origin/main, per-item merge to main after durably confirming CI green, worktree cleanup, and the generated parallel-status.md projection. There is no integration branch and no final integration pull request.
argument-hint: "[parallel-manifest-path | parallel-slug]"
context: fork
agent: parallel-orchestrator
---

# Parallel Orchestrate Skill

A user invocation (`/parallel-orchestrate <parallel-manifest-path>`) forks the
`parallel-orchestrator` agent with this procedure in context. The parallel manifest path (or
parallel slug) for this run is:

$ARGUMENTS

This skill frames work for the `parallel-orchestrator` agent, parallel to how
`.claude/skills/orchestrate/SKILL.md` frames work for `orchestrator`. It documents manifest
consumption, cohort consumption and ordering, the cohort barrier and `max_concurrency` slot
filling, the per-item branch and worktree lifecycle, the child kickoff parameter, model selection,
per-item merge to `main`, per-item merge-conflict handling, worktree cleanup,
`parallel-status.md` maintenance, checkpoint persistence, and completion, so that the procedure is
not re-derived ad hoc on each parallel run.

Each item on this surface ships independently: an item's pull request targets `main` directly.
There is no integration branch, no final integration pull request, and no fan-in path anywhere in
this procedure. Scheduling order comes only from computed blast-radius contention recorded in the
cohort table; there is no `depends_on` field on this surface.

Every section below is self-contained. A cross-reference names another section by its exact
heading text, never by position or number, so a section can be added or extended without
reflowing, reordering, or renumbering anything else in this file. The sections
`## Mutation Protocol (F6)`, `## Enforcement Hooks (F7)`, and `## Radius Drift Detection (F8)`
are reserved for the wave-4 features named in them: each is appended to by its own feature and
must not be relocated.

## Prerequisites

Before proceeding, `parallel-orchestrator` must:

1. Read `CLAUDE.md` for repository tone policy and architectural context.
2. Read the applicable `.claude/rules/` files for the languages in scope, including
   `.claude/rules/parallel-orchestration.md`, which is the schema authority for this surface.
3. Read the policy files listed in the compliance reading order section of `CLAUDE.md`.

## Parallel Manifest Consumption

The run manifest is the YAML frontmatter of `docs/features/parallel/<slug>/parallel.md`, authored
by `parallel-planner` on the planner-owned branch `parallel/<slug>-plan`. That branch is not an
integration branch: no item branch merges into it, it merges into no item branch, and it holds
only run-level artifacts under `docs/features/parallel/<slug>/`.

**This section is not a schema authority.** The manifest schema, the checkpoint schema, and all
nine parallel enums are defined once as prose invariants in
`.claude/rules/parallel-orchestration.md` (manifest invariants M1 through M7) and are enforced by
the F3-owned validators `scripts/dev_tools/parallel_manifest_contract.py` and
`scripts/dev_tools/validate_parallel_orchestrator_state.py`. This is a deliberate delta from
`.claude/skills/epic-orchestrate/SKILL.md`, whose manifest section carries its schema inline. Read
the schema from the rule file and the validators; consume it here and never redefine or extend it.

Consumption rules:

- `issue_num` is the primary key for every item reference. It is the stable GitHub issue number,
  so it does not drift when an item's folder moves from `docs/features/active/` to
  `docs/features/completed/`.
- Read `mode` (`closed` or `open`, defaulting to `closed`), `max_concurrency` (an integer from 1
  through 8, defaulting to 4), and each item's identity and state: `feature_folder`, `kind`,
  `state`, and `blast_radius`.
- The manifest is read-only to `parallel-orchestrator`. It is static input authored by
  `parallel-planner`: never write it, rewrite it, or back-fill a field into it.
- The manifest carries no `depends_on` key at any level and no top-level `integration_branch` key.
  Presence of either is an explicit rejection, not a tolerated extra field.
- A malformed manifest is rejected before any kickoff, recorded as a synthetic Blocking finding in
  the checkpoint. Do not guess a repair, do not silently skip the offending item, and do not launch
  a partial cohort. Validate by calling `validate_parallel_manifest_text` from
  `scripts/dev_tools/parallel_manifest_contract.py`, which is a library call and deliberately not
  an MCP artifact type. That module exposes no CLI entry point, so the permitted mechanism for the
  call is the granted interpreter invocation
  `poetry run python -c "import pathlib, sys; from scripts.dev_tools.parallel_manifest_contract import validate_parallel_manifest_text; errors = validate_parallel_manifest_text(pathlib.Path(sys.argv[1]).read_text(encoding='utf-8')); print(errors); sys.exit(1 if errors else 0)" docs/features/parallel/<slug>/parallel.md`,
  whose non-zero exit is the rejection signal and whose printed error list is the content of the
  Blocking finding.

## Cohort Consumption and Ordering

`cohorts[]` is an input, not a computation. Each entry has the shape
`{ index, generation, item_keys[] }` and is seeded by `parallel-planner` at `generation: 0` from
the deterministic Welsh-Powell coloring in `scripts/dev_tools/parallel_cohort_computation.py`.

`parallel-orchestrator` consumes the recorded partition and never computes or recolors one:

- Cohort computation belongs to the cohort-scheduler library that `parallel-planner` calls.
- Recoloring after a membership change belongs to F6; recoloring after a drift event belongs to F8.
- Read `recolor_generation` and schedule only from the cohorts whose `generation` equals it.

Items within a cohort are non-conflicting by construction — a cohort is an independent set in the
conflict graph — so they may branch from the same `main` tip and may merge in any order. After one
same-cohort item merges, another same-cohort item's pull request, based on the older tip, remains
mergeable, and GitHub produces a merge commit.

The conflict graph the cohorts project was computed by a contention relation that fails closed.
Since the blast-radius corrections of issue #452 (merged as PR #453), that relation reports more
contention rather than less: separator-free repository-root shared surfaces are reached from plan
and specification text, and path comparison honours listed-directory prefixes on both sides. Build
on that corrected behaviour. Never narrow a radius, re-derive a partition, or reinterpret an edge
in order to combine two cohorts or widen a launch batch.

## Cohort Barrier and Max-Concurrency Slot Filling

Two independent controls govern every launch. The cohort barrier governs when a cohort may start.
`max_concurrency` governs how many items of a started cohort run at once. Neither substitutes for
the other.

**Cohort barrier.** Cohort `N+1` branches from `main` only after every cohort-`N` item is `merged`
or `worktree_removed`. Increment `current_cohort` only on durable confirmation from
`git worktree list --porcelain`, `git branch`, and
`gh pr view --json state,mergedAt,headRefOid` — never from an in-memory completion notification. A
blocked item (`blocked_ci_loop_limit` or `blocked_drift`) is neither `merged` nor
`worktree_removed`, so a blocked item holds the barrier and cohort `N+1` does not start.

**`max_concurrency` slot filling.** `max_concurrency` caps the number of simultaneously in-flight
items independently of cohort size: a cohort of twelve items executes at most `max_concurrency`
items at a time. Fill slots in ascending item-key order, keyed on `issue_num`, and refill each
freed slot with the next unstarted item of the current cohort in that same ascending item-key
order. A cohort larger than `max_concurrency` therefore launches in several batches from the same
recorded `main` tip. The batching is a pure function:
`compute_concurrency_batches(cohort_item_keys, max_concurrency)` in
`scripts/dev_tools/parallel_cohort_computation.py` returns the batches in order and sorts the keys
itself, so determinism does not depend on caller ordering.

**Mechanical enforcement of the barrier is F7 scope, not this feature's.** F7 delivers a two-layer
design, because no single `PreToolUse` hook can validate a batch of concurrent `Agent` calls: hooks
fire per call with no cross-call state visibility.

- Layer 1, per-call deterrent: `.claude/hooks/enforce-parallel-cohort-barrier.ps1`, a `PreToolUse`
  hook on the `Agent` matcher. It fires when `subagent_type == "orchestrator"` and the serialized
  prompt carries the parallel kickoff marker, resolves the target item, reads
  `artifacts/orchestration/parallel-orchestrator-state.json`, and denies with reason
  `PARALLEL_COHORT_BARRIER_BLOCKED` unless every conflicting item in a prior cohort is `merged` or
  `worktree_removed`.
- Layer 2, retrospective backstop: a cohort-ordering invariant inside
  `validate_parallel_orchestrator_state_text`, enforced at `parallel-orchestrator` `SubagentStop`
  time, appending `PARALLEL_COHORT_BARRIER_VIOLATION` when the ordering invariant is violated.

Neither layer is shipped by this feature; both are named here so the obligation is legible to an
operator and to the F7 planner. Until F7 lands, the barrier is enforced by this procedure alone.

## Per-Item Branch and Worktree Lifecycle

1. Run one `git fetch origin main` immediately before each cohort launch, so every item in that
   cohort branches from the same current remote `main` tip rather than from a stale local ref.
   Record the fetched tip.
2. Each item's worktree is created by that item's delegation spawn,
   `Agent(orchestrator, isolation: "worktree", run_in_background: true)`, branched from
   `origin/main`. Do not create or check out item worktrees by hand.
3. `parallel-planner` created and pushed each item's feature branch from `origin/main` at
   preparation time, and that branch is reused unchanged as the item's execution branch, so the
   spawn checks out an existing branch whose base is `origin/main`. Because that base may be older
   than the fetched tip, the item's own run reconciles its branch against the fetched `origin/main`
   tip at execution start. Real path overlap that survives that reconciliation is drift; the
   conflict outcome is handled per `## Per-Item Merge-Conflict Handling`, and drift recording
   itself belongs to F8.
4. Each item's pull request base branch is `main`. Record `worktree_path`, `branch_name`,
   `pr_number`, and `pr_url` for the item, and set `merge_status: worktree_created` at spawn.
5. Worktree removal is the terminal step of this lifecycle and is specified in
   `## Worktree Cleanup`.

No integration branch is created, fetched, pushed, or referenced at any point in this lifecycle.
There is no final integration pull request and no fan-in path: the epic surface's
integration-branch lifecycle has no counterpart on this surface, and its absence is structural
rather than an omission.

## Parallel-Mode Kickoff Parameter

When `parallel-orchestrator` delegates an item to `Agent(orchestrator)`, the delegation prompt
carries exactly these five elements.

1. The literal marker line:

   > `Parallel mode: true. parallel_slug: <slug>. parallel_checkpoint_path: artifacts/orchestration/parallel-orchestrator-state.json. cohort_index: <n>. PR base branch MUST be main; pass --base main to gh pr create.`

   The token `Parallel mode: true` must appear exactly: it is the marker F7's Layer 1 barrier hook
   matches on. The clause `PR base branch MUST be main` is the child's explicit base-branch
   instruction, recorded as prompt text rather than left to a base-branch ancestry heuristic.
2. The item's active feature folder path, written literally as `docs/features/active/<basename>`.
   The child needs it for its own operation, and F7's Layer 1 hook resolves the target item by
   scanning the prompt for exactly that path shape, so the path is emitted as a bare path token.
3. The canonical issue number line, which is the item key.
4. The item's committed `plan-path`, together with the resume instruction: resume at atomic
   execution from that plan rather than re-running promotion, research, or planning. The item's
   prepared feature folder and approved atomic plan are already committed and preflight-clear on the
   item's own pushed feature branch.
5. The model-budget marker line `model_budget.fable_policy: <disabled|available|preferred>.`

Spawn parameters, passed on the `Agent` call and never written into the prompt text:
`isolation: "worktree"`, `run_in_background: true`, branch base `origin/main`, and `model` equal to
that item's model routing receipt's resolved model.

Negative obligations on the prompt:

- It never carries `Preparation mode: true`. Preparation fan-out belongs to `parallel-planner` and
  to F6's admission path; an item that reaches this procedure is already prepared.
- It never carries the epic-mode marker line that `.claude/skills/epic-orchestrate/SKILL.md`
  emits — the marker whose text is `Epic mode` followed by the value `true` — so the epic
  wave-barrier hook does not fire on a parallel child. That marker's value is deliberately not
  written out anywhere in this file, so no file this feature delivers carries an epic-mode marker
  string.
- It contains no instruction for the child to merge its own pull request. The parent performs each
  item's merge, as specified in `## Per-Item Merge to Main (Merge-on-Green)`.

Excluded from the prompt as parent-side concerns: the item's declared blast radius,
`max_concurrency`, and `mode`. Keeping the prompt minimal preserves the child contract unchanged.

## Model Selection

When `parallel-orchestrator` delegates an item to `Agent(orchestrator)`, the prompt appends the
session model-budget kickoff marker line, following the existing kickoff-marker pattern:

> `model_budget.fable_policy: <disabled|available|preferred>.`

The item's own `orchestrator` reads that line and applies the two-axis model-selection mechanism
documented in `.claude/skills/orchestrate/SKILL.md` (`## Model Selection`): it assesses a
judgment-based `complexity_band`, records `complexity_assessments[]` and
`model_routing_receipts[]`, and resolves each of its own delegations' model tier under the given
`fable_policy`. The canonical, tested reference implementations are `Get-ComplexityFloor` and
`Resolve-DelegationModel` in `.claude/lib/model-routing/ModelRouting.psm1`. Default `fable_policy`
is `disabled` when the marker is absent.

`parallel-orchestrator` spawns exactly one delegation channel, `Agent(orchestrator)`, one
delegation per item. It applies the same per-delegation resolution to that channel and passes
`model` equal to the routing receipt's `model` on the spawn call. It MUST NOT omit `model` — an
omitted `model` falls back to the delegate's frontmatter default, `opus`, which suppresses a
`fable` resolution — and MUST NOT hard-code `model=opus` in a way that overrides the resolved
routing model.

`route` is never an input to model selection. `route` remains file-count driven and governs only
agents, skills, and MCP tools. A skill whose frontmatter `context` field holds the value `fork`
inherits the parent model and ignores a model override, so model selection applies to agent
delegations, not to fork-routed skill invocations.

## Per-Item Merge to Main (Merge-on-Green)

The parent — `parallel-orchestrator` — performs each item's merge to `main`. The child contract is
unchanged: `.claude/skills/orchestrate/SKILL.md` is **not modified by this feature**. There is no
`parallel_mode` clause in its step 9, no `parallel_merge` object in the child checkpoint, and no
additional condition on the child's PR Creation Gate.

Procedure, per item:

1. The item's child orchestration runs unmodified, with `epic_mode` `false` or absent, and finishes
   at its own DONE. The child's PR Creation Gate condition 6 already requires
   `ci_gate.conclusion == "success"`, so at child DONE the item's pull request is open against
   `main` and its checks are green. The child is never instructed to merge its own pull request.
2. On child completion, durably confirm pull-request state and check conclusion with
   `gh pr view --json state,mergedAt,headRefOid`, and with `gh pr checks` when the check conclusion
   must be re-read — never from an in-memory completion notification — then record
   `merge_status: ci_green`.
3. Execute `gh pr merge --merge <PR>` for that item's pull request, whose base is `main`.
4. On success, record `merge_commit_sha`, `merged_at`, and `merge_status: merged`, then regenerate
   `docs/features/parallel/<slug>/parallel-status.md`.
5. On a merge failure caused by a conflict, follow `## Per-Item Merge-Conflict Handling`.

**F7 dependency.** `.claude/hooks/enforce-epic-merge-gate.ps1` is a project-wide `PreToolUse`
Bash-matcher hook that denies any `gh pr merge --merge` unless an epic-shaped checkpoint satisfies
its allow conditions; its block reason is `EPIC_MERGE_GATE_BLOCKED`. A parallel run has no
epic-shaped checkpoint, so step 3 above is denied until F7 scopes or extends that gate's allow
conditions for the parallel case. This feature modifies no file under `.claude/hooks/` and does not
change `.claude/settings.json`, so the parallel surface is not executable end-to-end before F7
lands. That limitation is documented, not worked around.

Branch protection on `main` affects only the pacing of step 3, not its ownership: if `main`
requires branches to be up to date, an automated `gh pr update-branch` plus re-green cycle is
inserted between same-cohort merges, which serializes those merges in practice while remaining
unattended.

## Per-Item Merge-Conflict Handling

Remediation is child-owned and parent-initiated. The conflict is always between one item's own
branch and `origin/main`; there is no integration branch and therefore no fan-in conflict path on
this surface.

1. On a conflicted `gh pr merge --merge`, the parent detects the failure and re-delegates that item's
   child orchestration, passing the conflict signal and the instruction to resolve against
   `origin/main`. The conflict capture and the finding write both belong to the child's
   `atomic-executor`, which works inside the item's own worktree, the only working tree holding the
   item's branch. It runs `git fetch origin main`, then `git merge --no-commit origin/main`, and on
   non-zero exit captures `git diff --name-only --diff-filter=U` for the conflicted-file list
   together with the raw conflict-marker content of each conflicted file. The child's
   `atomic-executor` then writes that evidence as a synthetic Blocking finding to the item's own
   `remediation-inputs.<timestamp>.md` in the item's active feature folder under
   `docs/features/active/`, not to the run's parallel folder. Assigning both the capture and the
   finding write to the child's chain matches `.claude/skills/epic-orchestrate/SKILL.md`, whose
   equivalent capture and finding write also belong to the child's `atomic-executor`.
2. The parent re-delegates that item's child orchestration. The child processes the finding through
   its unmodified R1 through R5 remediation loop exactly as it processes any local Blocking
   finding. No new remediation loop is introduced by this procedure.
3. The child's `remediation_pass` counter is shared with its local-finding and CI-failure passes,
   with the cap of 3, unmodified.
4. Each remediated pass ends again at child DONE with the pull request open and CI green, after
   which the parent retries the merge per `## Per-Item Merge to Main (Merge-on-Green)`. During
   remediation the item's `merge_status` legitimately remains `pr_open` or `ci_green`: the
   `merge_status` enum is F3-owned, carries no conflict member, and is not extended by this
   feature.
5. On loop exhaustion, the parent records the terminal `merge_status: blocked_ci_loop_limit` for the
   item; the child's own checkpoint retains its precise blocked status. A blocked item is neither
   `merged` nor `worktree_removed`, so it holds the cohort barrier defined in
   `## Cohort Barrier and Max-Concurrency Slot Filling`.

Boundary with F8: a merge conflict between two same-cohort items is evidence that the declared
blast radius under-reported, and this feature records the child's blocked or remediated outcome
only, leaving drift recording in `drift_events[]`, quiesce of admission, conflict recomputation
against the observed radius, and requeue of the later-started item to F8.

## Worktree Cleanup

After an item reaches `merge_status: merged` and that state is durably confirmed by
`gh pr view --json state,mergedAt,headRefOid`, the parent — running from the main repository
checkout, never from inside a child worktree — issues `git worktree remove <worktree_path>`. On
success it records `merge_status: worktree_removed` and `worktree_removed_at`, then regenerates
`docs/features/parallel/<slug>/parallel-status.md`.

Mechanical gating of this command for parallel worktrees is F7 scope.
`.claude/hooks/enforce-epic-worktree-removal-gate.ps1` is a project-wide `PreToolUse` Bash-matcher
hook that denies any `git worktree remove` unless the epic checkpoint carries a matching
`features[]` record whose `merge_status` is `merged` or `worktree_removed`; an unreadable checkpoint
or an absent record also denies. Its block reason is `EPIC_WORKTREE_REMOVAL_BLOCKED`. A parallel run
has no epic checkpoint record for its worktrees, so removal is denied until F7 both delivers
`enforce-parallel-worktree-removal-gate.ps1` and coordinates the epic gate's allow conditions:
`PreToolUse` denials are conjunctive, so a new allow-hook alone cannot override the existing deny.
This feature ships no hook file and makes no `.claude/settings.json` change.

## Documentation Maintenance Boundaries

`docs/features/parallel/<slug>/parallel-status.md` is a generated projection of
`artifacts/orchestration/parallel-orchestrator-state.json`. It is regenerated in full, is never
hand-authored, and is never treated as an input. It is never the source of the cohort table and
never the source of the schedule: the run manifest and the checkpoint are authoritative. Generate it
from the template `docs/features/templates/parallel/parallel-status.md`.

Header block fields: `parallel_slug`, `mode`, `max_concurrency`, `current_cohort`,
`recolor_generation`, `last_updated`.

Item table: one row per `items[]` entry, carrying `issue_num`, `feature_folder`, cohort index,
lifecycle `state`, `merge_status`, `pr_url`, `merge_commit_sha`, and the item's lifecycle
timestamps. The cohort column takes the place of the epic status document's wave column.

Cohort table: a projection of `cohorts[] { index, generation, item_keys[] }`, so a recolored
schedule stays traceable by `generation`.

Read-only projections of F3-owned arrays, rendered by this feature but never written by it: section
`## Conflict Edges` projects `conflict_edges[]`; section `## Mutations` projects `mutations[]`,
whose rows appear only once F6 populates that array; section `## Drift Events` projects
`drift_events[]`, which only F8 populates. An empty array renders an empty section rather than an
omitted one.

Regeneration boundaries — regenerate at each of the following, not only at final completion:

- Run kickoff, seeding the initial projection from the manifest and the seeded cohorts.
- Every item `state` or `merge_status` transition.
- Every cohort transition, meaning every `current_cohort` increment.
- Every `recolor_generation` increment.
- Every append to `mutations[]`.
- Every append to `drift_events[]`.
- Run completion in `closed` mode, or run close in `open` mode.

Defining the `mutations[]` and `drift_events[]` appends as regeneration boundaries here means F6 and
F8 need no amendment to these projection rules.

## Parallel-Level Checkpoint

This section is consumption documentation only. The checkpoint schema is owned by F3, defined once
as prose invariants in `.claude/rules/parallel-orchestration.md`, and enforced by
`scripts/dev_tools/validate_parallel_orchestrator_state.py`. Consume that schema; add no field to it
and extend no enum in it.

Fields `parallel-orchestrator` writes to `artifacts/orchestration/parallel-orchestrator-state.json`:
`objective`, `route_id: "parallel"`, `parallel_slug`, `parallel_manifest_path`,
`parallel_status_doc_path`, `mode`, `max_concurrency`, `completed_steps`, `next_step`,
`last_updated`, `current_cohort`, `recolor_generation`, `cohorts[]`, `items[]` — each item entry
carrying `issue_num`, `feature_folder`, `state`, `blast_radius`, `worktree_path`, `branch_name`,
`pr_number`, `pr_url`, `merge_status`, `merge_commit_sha`, and the lifecycle timestamps — and the
three receipt arrays `delegation_receipts[]`, `skill_receipts[]`, and `mcp_call_receipts[]`,
populated with the `parallel` route's required names from `config/orchestration-routing.json`.

The `merge_status` enum has exactly eight members: `not_started`, `worktree_created`, `pr_open`,
`ci_green`, `merged`, `worktree_removed`, `blocked_drift`, and `blocked_ci_loop_limit`. An absent
`merge_status` is treated as `not_started`.

The transition chain this feature writes: `not_started` to `worktree_created` at the item's
delegation spawn; `worktree_created` to `pr_open` when the child reports its pull request open;
`pr_open` to `ci_green` on durable confirmation after child DONE; `ci_green` to `merged` when the
parent's merge succeeds; and `merged` to `worktree_removed` after gated removal.
`blocked_ci_loop_limit` is the mapped terminal for an exhausted remediation loop.

Never written by this feature: `blocked_drift`, which only F8 writes; `conflict_edges[]`, seeded by
`parallel-planner` and recomputed only by F8; `mutations[]`, which only F6 appends to; and
`drift_events[]`, which only F8 appends to. These are read for projection and for scheduling context
and are otherwise untouched.

The checkpoint is a cache of durable state, not the source of truth. Every recorded field is
re-derivable on resume from `git worktree list --porcelain` for worktree existence and path,
`git branch` for branch existence and name, and `gh pr view --json state,mergedAt,headRefOid` for
pull-request state, merge time, and merge commit. Where the checkpoint disagrees with those three
commands, the commands win and the checkpoint is rewritten from them.

Validate through `mcp__drm-copilot__validate_orchestration_artifacts` with
`artifact_type: "parallel-orchestrator-state"`, or the equivalent CLI invocation
`poetry run python -m scripts.dev_tools.validate_orchestration_artifacts parallel-orchestrator-state <path>`,
adding `--require-complete` at the completion gate.

## Completion Requirements

Completion is mode-dependent. Read `mode` from the manifest: it is `closed` or `open` and defaults
to `closed`.

In `closed` mode, `parallel-orchestrator` must not report completion until all of the following
hold:

1. Every non-withdrawn item has `merge_status` of `merged` or `worktree_removed`, each durably
   confirmed by `git` and `gh` rather than by an in-memory completion notification.
2. `docs/features/parallel/<slug>/parallel-status.md` has been regenerated a final time and reflects
   the completed state.
3. The parallel checkpoint passes validation with `require_complete` for
   `artifact_type: "parallel-orchestrator-state"`.
4. Each item's acceptance criteria have been checked off in that item's own acceptance-criteria
   source files by that item's own run, per the `acceptance-criteria-tracking` skill.

In `open` mode there is no automatic completion. The run is a standing queue and terminates only via
`/parallel-close`, which is owned by F6 and is neither specified nor shipped by this feature. Do not
synthesize a completion condition for an `open`-mode run.

No completion condition involves a run-level pull request. There is no final integration pull
request on this surface, so completion keys on the per-item terminal states above and on nothing
else.

## Mutation Protocol (F6)

A parallel run is mutable while it executes. Three slash commands mutate it, and each one appends
exactly one `mutations[]` entry to the parallel-orchestrator checkpoint on success:

- `/parallel-add <issue|potential-entry>` — `.claude/skills/parallel-add/SKILL.md`. Admits one new
  item: the item enters `proposed`, is prepared through a preparation-mode child
  `Agent(orchestrator)` run reusing the `route_id: preparation` contract unchanged, its conflict
  edges are computed against ALL items including in-flight ones, and the admission decision either
  places it in the current cohort or defers it and recolors the unstarted subgraph.
- `/parallel-remove <item> [--disposition detach|abandon]` —
  `.claude/skills/parallel-remove/SKILL.md`. Removes one item per the state-dependent behavior
  table: an unstarted item is withdrawn and the unstarted subgraph is recolored; an in-flight item
  requires an explicit disposition and is rejected without one; a merged item is rejected.
- `/parallel-close <parallel-slug>` — `.claude/skills/parallel-close/SKILL.md`. Terminates an
  `open`-mode run. Rejected while any item is `in_flight`.

Every mutation re-derives durable state (`git worktree list --porcelain`, `git branch`,
`gh pr view`) before it is applied, because the checkpoint is a cache of durable state and not the
source of truth. A rejected mutation appends no entry and changes no state.

The decision logic for all three commands is the pure engine
`scripts/dev_tools/parallel_mutation_protocol.py`. It decides; it never applies. Item keys are
integers (`items[].issue_num`) everywhere on this surface.

### Pinning invariant

**In-flight items are pinned. Scheduling is recomputed only over the not-yet-started subgraph, and
recoloring is a pure function of `(remaining subgraph, pinned set)`.**

The recolor function takes the induced subgraph of unstarted items (states `proposed`, `admitted`,
`prepared`, `scheduled`), the pinned set (state `in_flight`), and the current generation. It returns
cohort assignments for unstarted items ONLY: the returned mapping's key set equals the unstarted set
exactly and contains no pinned key. A pinned item is therefore absent from the result rather than
reassigned, and that absence IS the guarantee that a mutation never moves work already running.

Coloring is delegated in full to the Welsh-Powell entry point `compute_cohorts` in
`scripts/dev_tools/parallel_cohort_computation.py`. No part of the coloring, the vertex ordering, or
the tie-break is reimplemented by the mutation engine.

### Recompute boundary

`recolor_generation` increments by exactly one on a recompute and is stamped unchanged on every
other operation. The boundary is normative:

Operations that RECOMPUTE (`recolor_generation` increments by exactly one):

1. **Deferred add** — the candidate conflicts with an in-flight item, so the unstarted subgraph,
   including the new item, is recolored.
2. **Remove of an unstarted item** — the vertex is dropped and the remaining unstarted subgraph is
   recolored.
3. **Drift-induced requeue** — the later-started item of a newly conflicting pair is halted and
   requeued into a future cohort.

Operations that DO NOT recompute (generation stamped unchanged):

1. **Admission into the current cohort with no in-flight conflict** — no cohort assignment changes.
2. **`detach`** — the detached item was pinned and was never a vertex of the unstarted subgraph, so
   its departure cannot change the induced subgraph.
3. **`abandon`** — same rationale as `detach`. An unstarted item previously deferred because of a
   conflict with the now-abandoned item keeps its deferred cohort assignment: the assignment remains
   valid and is at most conservative, and no opportunistic recompute is performed. This keeps
   generation accounting minimal and deterministic.
4. **`close`** — run termination changes no cohort assignment.

A non-recompute operation still appends exactly one `mutations[]` entry, stamping the current,
unchanged `recolor_generation`. A sequence of N operations from generation `g` therefore ends at
exactly `g` plus the number of recompute operations.

### Per-op mutation-log entry contents

| Op case | `op` | `item_key` | `prior_state` | `new_state` | `disposition` | `recolor_generation` |
| --- | --- | --- | --- | --- | --- | --- |
| Add, no-conflict admit | `add` | item key | null | `scheduled` | null | `g` (unchanged) |
| Add, deferred | `add` | item key | null | `scheduled` | null | `g` + 1 |
| Remove, unstarted | `remove` | item key | prior state (`proposed`/`admitted`/`prepared`/`scheduled`) | `withdrawn` | null | `g` + 1 |
| Remove, `detach` | `remove` | item key | `in_flight` | `withdrawn` | `detach` | `g` (unchanged) |
| Remove, `abandon` | `remove` | item key | `in_flight` | `withdrawn` | `abandon` | `g` (unchanged) |
| Close | `close` | null (run-scoped) | null | null | null | `g` (unchanged) |
| Drift-induced requeue | `requeue` | item key | `in_flight` | `blocked` | null | `g` + 1 |

`prior_state` is null on BOTH add rows. The accompanying `prepared` -> `scheduled` transition is not
lost and is not recorded in the mutation entry: it is recorded as an item-state update in `items[]`
with the checkpoint's lifecycle timestamps, the same mechanism that records
`proposed` -> `admitted` -> `prepared` during preparation. `new_state` is null for `close` only, and
`item_key` is null for `close` only. `disposition` is non-null only on a `remove` entry whose
`prior_state` is `in_flight`. Every `at` timestamp comes from the engine's injected clock seam; the
engine never reads the wall clock. No field and no enum member is added to `mutations[]`; the nine
parallel enums of `.claude/rules/parallel-orchestration.md` are consumed, never extended.

Retrospective validation of the log is the helper
`scripts/dev_tools/_parallel_orchestrator_state_mutations.py`, wired into
`scripts/dev_tools/validate_parallel_orchestrator_state.py`. It requires every entry to carry all
seven fields and no eighth, and requires `recolor_generation` to be monotonically non-decreasing in
append order, which is what makes a lost update detectable after the fact.

### Mode-dependent completion semantics

- **`closed` mode (the default).** The completion gate fires when every non-withdrawn item is
  `merged` or `worktree_removed`, evaluated over per-item `merge_status`. Mid-execution mutation
  remains permitted. The predicate is `is_closed_mode_complete` in the mutation engine.
- **`open` mode.** The run NEVER auto-completes. It is a standing queue and terminates only via
  `/parallel-close`. The close record is the run's final mutation; nothing may be appended to
  `mutations[]` after it. Do not synthesize a completion condition for an `open`-mode run.

A withdrawn item is exempt from the predicate in both modes: it left the run before reaching a merge
outcome, so requiring a terminal merge status of it would make every run that dropped an item
permanently incompletable. This is also why `detach` records `withdrawn` — the run does not wait for
a detached item.

### Abandon confirmation-marker contract

The `abandon` disposition is destructive: it closes the item's pull request and removes its
worktree. Both side effects run through ONE deterministic CLI invocation of
`scripts/dev_tools/parallel_mutation_abandon_cli.py`, documented in full in
`.claude/skills/parallel-remove/SKILL.md`. Executing the abandon disposition through ad hoc `gh` or
`git` commands is prohibited, because an ad hoc command is not matchable and would bypass the
confirmation contract.

The contract is enforced by the PreToolUse hook
`.claude/hooks/enforce-parallel-abandon-gate.ps1` on the `Bash` matcher:

- A Bash command carrying the abandon disposition token MUST also carry the explicit confirmation
  marker `--confirm-abandon` in the SAME command.
- Without the marker, the command is DENIED with a deny reason prefixed
  `PARALLEL_ABANDON_BLOCKED`.
- With the marker, the command is allowed.
- A command carrying no abandon disposition token is out of scope and is allowed unchanged.

When the gate denies a command, add the confirmation marker deliberately. Do not reformulate the
command to evade the match: that defeats the only mechanism protecting a destructive operation.

### Drift-requeue append contract

Radius drift detection consumes this protocol rather than reimplementing it. When drift halts the
later-started item of a newly conflicting pair, the requeue is recorded through the mutation
engine's `build_requeue_entry` constructor and the recolor through `recolor_unstarted`:

- Item state becomes `blocked` and per-item `merge_status` becomes `blocked_drift`.
- Exactly one `mutations[]` entry is appended with `op: requeue`, `prior_state: in_flight`,
  `new_state: blocked`, `disposition: null`, and `recolor_generation` equal to `g` + 1 — the requeue
  is a recompute.
- The recolor runs over the unstarted subgraph only, so no other in-flight item moves.

The drift event itself is recorded in `drift_events[]`, which this protocol does not write. See
`## Radius Drift Detection (F8)`.

## Enforcement Hooks (F7)

Reserved for F7; content is appended by that feature and must not be relocated.

## Radius Drift Detection (F8)

Reserved for F8; content is appended by that feature and must not be relocated.
