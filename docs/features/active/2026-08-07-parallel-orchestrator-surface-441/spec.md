# `2026-08-07-parallel-orchestrator-surface` — Spec

- **Issue:** #441
- **Issue URL:** https://github.com/drmoisan/drm-copilot/issues/441
- **Work Mode:** full-feature
- **Owner:** drmoisan
- **Last Updated:** 2026-08-07
- **Status:** Ready for planning
- **Version:** 1.0
- **Epic:** `parallel-orchestration` (`docs/features/epics/parallel-orchestration/epic.md`), wave 3, feature F5
- **Design authority:** `docs/research/2026-08-07-parallel-orchestration-design-research.md` (all §N references below)
- **Research input:** `docs/features/active/2026-08-07-parallel-orchestrator-surface-441/research/2026-08-07T12-30-parallel-orchestrator-surface-research.md` (cited as "research §X")

## Overview

Deliver the execution half of the `parallel` orchestration surface. The planning half (F4,
`parallel-planner` / `parallel-plan`) produces a manifest, prepared child plans, and seeded
cohorts; this feature delivers the agent and skills that consume them: cohort scheduling, child
fan-out onto isolated worktrees, per-item merge to `main`, the generated
`docs/features/parallel/<slug>/parallel-status.md` projection, and maintenance of the
`artifacts/orchestration/parallel-orchestrator-state.json` checkpoint.

The surface is a structural adaptation of the epic execution surface (`epic-orchestrator` /
`epic-orchestrate` / `epic-run`) with one central delta (§4): there is no integration branch, no
final integration PR, and no fan-in merge-conflict path. Each item opens and merges its own PR
against `main` independently. Reuse is by near-verbatim adaptation into new `parallel`-named
files; the epic files are not modified (epic.md non-goals).

## Deliverables

| # | Path | Kind |
| --- | --- | --- |
| 1 | `.claude/agents/parallel-orchestrator.md` | Agent persona (new) |
| 2 | `.claude/skills/parallel-orchestrate/SKILL.md` | Procedure skill (new); analogue of `epic-orchestrate` |
| 3 | `.claude/skills/parallel-run/SKILL.md` | User-invocable entry point (new); analogue of `epic-run` |
| 4 | `docs/features/templates/parallel/parallel-status.md` | Generated-projection template (new); mirrors `docs/features/templates/epic/epic-status.md` (research B.3) |
| 5 | `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` | Contract tests over the delivered Markdown surface (new); pattern of `test_epic_run_kickoff_discovery_contract.py` |

Explicitly excluded from this feature's diff: every file under `.claude/hooks/`,
`.claude/settings.json`, `.claude/skills/orchestrate/SKILL.md`,
`.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`,
`config/orchestration-routing.json`, all schema and validator modules (F3-owned), and MCP
scaffolding wiring (`new_active_feature_folder` gains no `parallel` type; the agent writes the
projection directly, research B.3).

## Adjudicated Decisions

The following three cross-feature issues were raised by the research and have been adjudicated
by the orchestrator. They are recorded here as settled decisions with rationale. They are not
open questions and must not be re-opened by planning, execution, or review.

### Decision 1 — The parent performs the per-item merge; the child does not

Research C.2 observed that the epic merge-on-green mechanism lives in the shared
`.claude/skills/orchestrate/SKILL.md` (S9 step 6, the `epic_merge` checkpoint object, and PR
Creation Gate condition 7), that a parallel child runs with `epic_mode` `false`/absent so
condition 7 passes vacuously and no merge occurs, and recommended that F5 additively extend
`orchestrate/SKILL.md` with parallel-mode analogues. That recommendation is **rejected**. The
`parallel-orchestrator` (parent) performs each item's merge to `main`. Rationale:

- §12 records `merge_status` per item on the **parent** checkpoint with the enum
  `not_started`, `worktree_created`, `pr_open`, `ci_green`, `merged`, `worktree_removed`,
  `blocked_drift`, `blocked_ci_loop_limit`. The parent is designed to be authoritative for
  per-item merge state.
- §6's cohort barrier requires the parent to know when every cohort-`N` item has merged before
  starting cohort `N+1`. Merge observation is therefore already a parent responsibility.
- §10 directs reuse by adaptation into new `parallel`-named files rather than by generalizing
  shared implementations in place. Keeping the merge in `parallel-orchestrate/SKILL.md` honors
  that.
- The child's existing PR Creation Gate condition 6 already requires
  `ci_gate.conclusion == "success"` before the child writes DONE, so the child independently
  verifies CI green. The parent merges the already-green PR afterward.

Consequences, all binding on this feature:

1. `.claude/skills/orchestrate/SKILL.md` is **not modified**. No `parallel_mode` S9 clause, no
   `parallel_merge` child-checkpoint object, no additional PR Creation Gate condition.
2. The child runs unmodified with `epic_mode: false`, finishes at its own DONE with its PR open
   and CI green, and the parent transitions the item `ci_green -> merged`.
3. The parent-side merge-on-green procedure is specified in `parallel-orchestrate/SKILL.md`,
   adapted from the S9 step-6 pattern (R2.8 below).
4. The child kickoff prompt does **not** instruct the child to merge its own PR. This supersedes
   the merge clause in research D.2 item 1, which was drafted under the rejected child-merge
   model.

### Decision 2 — The two fail-closed epic hooks are an F7 dependency, not F5 scope

Two existing project-wide `PreToolUse` Bash-matcher hooks fail closed against commands a live
parallel run must issue (verified; exact conditions in `## Cross-Feature Dependencies`). This is
true whether the parent or the child merges, so it does not affect Decision 1. F5 must **not**
modify any hook or `.claude/settings.json`. §9 assigns
`enforce-parallel-worktree-removal-gate.ps1` and the invocation-origin extension to F7. The
resulting limitation — the parallel surface is not executable end-to-end until F7 lands — is
recorded in `## Cross-Feature Dependencies` and `## Assumptions` as a spec-level assumption and
known limitation. It is deliberately **not** an acceptance criterion for F5.

### Decision 3 — The `merge_status` enum is F3-owned and is not extended by F5

The §12 enum contains no `merge_conflict` or conflict-loop-limit value (research C.3, E.5). F5
does not add one. A non-mergeable per-item PR maps to the existing terminal
`blocked_ci_loop_limit` after the child's bounded remediation loop is exhausted; during
in-flight conflict remediation the item legitimately remains `pr_open` (or `ci_green`). The
value set must be verified against F3's landed validator at execution time; the mapping is
recorded as an assumption to re-verify (`## Assumptions`, item 3).

## Requirements

### R1 — Agent persona: `.claude/agents/parallel-orchestrator.md`

Adapted section-by-section from `.claude/agents/epic-orchestrator.md` per research A.1:

- **Frontmatter.** `name: parallel-orchestrator` exactly (this string is the `subagent_type`
  the F7-extended invocation-origin hook will match; research H). `model: opus`. `tools`
  allowlist adapted from the epic persona **without** `Agent(pr-author)` (per-item PRs are
  authored inside each child by that child's own S8; the parent merges via `gh pr merge`, a
  Bash command). `Write`/`Edit` scopes cover `docs/features/parallel/**` and
  `artifacts/orchestration/**`. `skills` includes `parallel-orchestrate`. `memory: project`.
  `SubagentStop` hook reuses the parameterized `.claude/hooks/validate-orchestrator-output.ps1`
  with `-CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json` and
  `-ArtifactType parallel-orchestrator-state` (the artifact-type dispatch is F3's validator
  wiring; `## Assumptions`, item 5).
- **Persona intro.** Cohort and per-item-merge framing. Claims authorization to delegate
  `Agent(orchestrator)` without claiming exclusivity — the frozen epic persona already makes
  the exclusive claim (research A.1).
- **`## Skill`** — binds to `parallel-orchestrate`.
- **`## Startup Protocol`** — read CLAUDE.md and rules; read
  `artifacts/orchestration/parallel-orchestrator-state.json`; on a `parallel_slug` match, resume
  via durable ground truth re-derived from `git worktree list --porcelain`, `git branch`, and
  `gh pr view --json state,mergedAt,headRefOid` (§12); otherwise begin at manifest parsing from
  `docs/features/parallel/<slug>/parallel.md`.
- **`## Invocation Origin`** — entry points `/parallel-orchestrate` and `/parallel-run`;
  prohibits invocation of `Agent(parallel-orchestrator)` from within an `orchestrator` run;
  notes that hook coverage is delivered by F7's extension of
  `enforce-epic-invocation-origin.ps1` (§9) and is not shipped here.
- **`## Prepared-Run Execution`** — handoff from `parallel-planner`: read F4's committed
  kickoff artifact; each item resumes at atomic execution from its committed `plan-path` rather
  than re-running promotion, research, or planning. The epic integration-ref discovery
  mechanics drop entirely (no integration branch).
- **`## Delegation Model`** — a single channel: `Agent(orchestrator)` per item with
  `isolation: "worktree"`, `run_in_background: true`, branch base `origin/main`, and `model`
  bound to the routing receipt. No `Agent(pr-author)` channel; no upstream-context citation
  lines (no `depends_on`, §4/§11).
- **`## Cohort Scheduling`** — consumes `cohorts[]` (seeded by F4); enforces the cohort barrier
  and `max_concurrency` slot filling; never computes or recolors cohorts.
- **`## Checkpoint Persistence`** — the §12 field list F5 writes (R2.12).
- **`## Documentation Maintenance`** — `parallel-status.md` regeneration boundaries (R2.11);
  generated, never hand-authored.
- **`## Completion Requirements`** — mode-dependent per §8.7 (R2.13); no integration-PR
  condition.

### R2 — Procedure skill: `.claude/skills/parallel-orchestrate/SKILL.md`

Frontmatter: `context: fork`, `agent: parallel-orchestrator`, argument hint accepting the
parallel manifest path or slug.

#### R2.1 — Section layout (binding; wave-4 sectioning)

F6 (mutation protocol), F7 (enforcement hooks), and F8 (drift detection) all execute after F5
and all three will extend this file. Per the epic's wave-4 contention constraint (epic.md,
"Wave-4 Contention Note"), the skill file is structured with clearly delimited, separately
named top-level sections so that none of the three needs to reflow or reorder F5's content.
The required layout, per research F:

F5-authored elements, in this order:

1. YAML frontmatter
2. `# Parallel Orchestrate Skill` (intro)
3. `## Prerequisites`
4. `## Parallel Manifest Consumption`
5. `## Cohort Consumption and Ordering`
6. `## Cohort Barrier and Max-Concurrency Slot Filling`
7. `## Per-Item Branch and Worktree Lifecycle`
8. `## Parallel-Mode Kickoff Parameter`
9. `## Model Selection`
10. `## Per-Item Merge to Main (Merge-on-Green)`
11. `## Per-Item Merge-Conflict Handling`
12. `## Worktree Cleanup`
13. `## Documentation Maintenance Boundaries`
14. `## Parallel-Level Checkpoint`
15. `## Completion Requirements`

Reserved placeholder sections, authored by F5 as trailing `##` headings after
`## Completion Requirements`, one distinct section per wave-4 feature, each containing a single
one-line body of the form "Reserved for F<N>; content is appended by that feature and must not
be relocated.":

16. `## Mutation Protocol (F6)`
17. `## Enforcement Hooks (F7)`
18. `## Radius Drift Detection (F8)`

Placing the reserved sections last lets each wave-4 feature append `###` subsections inside its
own uniquely named `##` section without touching any F5 line. The presence and exact naming of
these three reserved sections is an acceptance criterion.

#### R2.2 — Parallel Manifest Consumption

References F3's schema authority (`.claude/rules/parallel-orchestration.md` and the F3
validators) and defines consumption behavior only: `issue_num` is the primary key; F5 reads
`mode`, `max_concurrency`, and per-item identity and state; F5 never writes the manifest; a
malformed manifest is rejected as a synthetic Blocking finding before any kickoff. This section
is not a schema authority — a deliberate delta from the epic skill, whose manifest section is
(research A.2).

#### R2.3 — Cohort Consumption and Ordering

Cohorts are an input (`cohorts[] { index, generation, item_keys[] }`), seeded by F4 from F2's
deterministic Welsh-Powell coloring (§6). F5 consumes; it never computes or recolors
(recoloring is F6/F8 scope). Items within a cohort are non-conflicting by construction, may
branch from the same `main` tip, and may merge in any order.

#### R2.4 — Cohort Barrier and Max-Concurrency Slot Filling

- **Barrier predicate (new; no epic precedent).** Cohort `N+1` branches from `main` only after
  every cohort-`N` item is `merged` or `worktree_removed` (§6). `current_cohort` increments
  only on durable confirmation via `git`/`gh` commands, never from in-memory notifications. A
  blocked item (`blocked_ci_loop_limit`, `blocked_drift`) is not `merged`, so it holds the
  barrier.
- **Slot filling (new; no epic precedent).** `max_concurrency` caps fan-out independently of
  cohort size; slots are filled in ascending item-key (`issue_num`) order; a freed slot is
  refilled with the next item in ascending item-key order. A cohort may therefore launch in
  several batches from the same recorded `main` tip.
- The section names, without shipping, the F7 deliverables that enforce the barrier
  mechanically: `enforce-parallel-cohort-barrier.ps1` (Layer 1,
  `PARALLEL_COHORT_BARRIER_BLOCKED`) and the Layer 2 validator invariant
  (`PARALLEL_COHORT_BARRIER_VIOLATION`), per §9.

#### R2.5 — Per-Item Branch and Worktree Lifecycle

Replaces the epic `## Epic Integration Branch Lifecycle` (dropped in full). One
`git fetch origin main` before each cohort launch; each item worktree is created by the
`Agent(orchestrator, isolation: "worktree", run_in_background: true)` spawn, branched from
`origin/main`; PR base is `main`. No integration branch is created or fetched; no final PR; no
fan-in path.

#### R2.6 — Parallel-Mode Kickoff Parameter (child kickoff contract)

The child kickoff prompt carries, per research D.2 as amended by Decision 1:

1. The literal marker line:
   `Parallel mode: true. parallel_slug: <slug>. parallel_checkpoint_path: artifacts/orchestration/parallel-orchestrator-state.json. cohort_index: <n>. PR base branch MUST be main; pass --base main to gh pr create.`
   The literal token `Parallel mode: true` is the string F7's Layer 1 barrier hook matches on
   (§9); it must appear exactly.
2. The item's active feature folder path, written literally as
   `docs/features/active/<basename>` — required for the child's own operation and because the
   F7 hook resolves the target item by scanning the prompt for that path shape (research D.1).
3. The canonical issue number line (the item key).
4. The committed `plan-path` plus the resume instruction: resume at atomic execution from this
   plan rather than re-running promotion, research, or planning.
5. The model-budget marker line `model_budget.fable_policy: <disabled|available|preferred>.`
6. Spawn parameters (not prompt text): `isolation: "worktree"`, `run_in_background: true`,
   branch base `origin/main`, `model` bound to the routing receipt.

Marker separation (negative obligations): the kickoff prompt never carries
`Preparation mode: true` (preparation fan-out is F4/F6 scope; research C.1) and never carries
`Epic mode: true` (so the epic wave-barrier hook does not fire). The kickoff prompt does not
instruct the child to merge its own PR (Decision 1). Not included in the prompt: the declared
blast radius, `max_concurrency`, and `mode` — parent-side concerns (research D.2).

#### R2.7 — Model Selection

Adapted from the epic skill with name substitution only: the `model_budget.fable_policy`
kickoff marker, per-delegation resolution via `ModelRouting.psm1`, and the rule that `route` is
never a model input. The delegation-channel sentence narrows to `Agent(orchestrator)` only.

#### R2.8 — Per-Item Merge to Main (Merge-on-Green) — parent-side procedure

Adapted from the S9 step-6 pattern and relocated to the parent (Decision 1):

1. The child orchestration runs unmodified (`epic_mode` `false`/absent) and finishes at its own
   DONE. The child's PR Creation Gate condition 6 guarantees the PR is open and
   `ci_gate.conclusion == "success"` at child DONE.
2. On child completion, the parent durably confirms PR state and CI conclusion via
   `gh pr view --json state,mergedAt,headRefOid` (and `gh pr checks` as needed) — never from
   in-memory notifications — and records `merge_status: ci_green`.
3. The parent executes `gh pr merge --merge <PR>` (base `main`).
4. On success, the parent records `merge_commit_sha`, `merged_at`, and `merge_status: merged`,
   then regenerates `parallel-status.md`.
5. On failure due to merge conflict, the parent follows R2.9.

The section states explicitly that `.claude/skills/orchestrate/SKILL.md` is not modified by
this feature and that no `parallel_merge` object or additional PR Creation Gate condition
exists in the child contract.

#### R2.9 — Per-Item Merge-Conflict Handling

Child-owned remediation, parent-initiated — adapted from the epic fan-in section with
`origin/main` substituted for the integration branch (research C.3):

1. On a conflicted `gh pr merge --merge`, the parent converts the conflict into a synthetic
   Blocking finding written to the item's own `remediation-inputs.<timestamp>.md` (in the
   item's active feature folder), instructing conflict resolution against `origin/main`
   (`git fetch origin main`; `git merge --no-commit origin/main`; capture
   `git diff --name-only --diff-filter=U` plus conflict markers).
2. The parent re-delegates the child orchestration, which processes the finding through its
   unmodified R1–R5 remediation loop (shared `remediation_pass` cap of 3).
3. Each remediated pass ends again at child DONE with CI green; the parent then retries the
   merge (R2.8 steps 2–4). During remediation the item's `merge_status` legitimately remains
   `pr_open` or `ci_green` (Decision 3).
4. On loop exhaustion, the parent records the terminal `merge_status: blocked_ci_loop_limit`
   (Decision 3 mapping; the child's own checkpoint retains its precise blocked `step9_status`).
   The blocked item holds the cohort barrier.
5. §13.1 boundary statement (one sentence): a merge conflict between two same-cohort items is
   evidence of blast-radius under-report; F5 records the child's blocked or remediated outcome
   only and leaves drift recording, quiesce, recompute, and requeue to F8.

#### R2.10 — Worktree Cleanup

After an item reaches `merge_status: merged` (durably confirmed), the parent runs
`git worktree remove <path>` from the main checkout and records
`merge_status: worktree_removed` plus `worktree_removed_at`. The section notes that mechanical
gating of this command for parallel worktrees is F7 scope (`## Cross-Feature Dependencies`).

#### R2.11 — Documentation Maintenance Boundaries (`parallel-status.md`)

`docs/features/parallel/<slug>/parallel-status.md` is a generated projection of
`artifacts/orchestration/parallel-orchestrator-state.json`. It is regenerated, never
hand-authored, and never the source of the schedule: the manifest and checkpoint JSON are
authoritative, and the status document is never the source of the cohort table. Structure and
boundaries per research B.3:

- **Header block:** `parallel_slug`, `mode`, `max_concurrency`, `current_cohort`,
  `recolor_generation`, `last_updated`.
- **Item table:** one row per `items[]` entry: `issue_num`, `feature_folder`, cohort index,
  lifecycle `state` (§8.2), `merge_status` (§12 enum), `pr_url`, `merge_commit_sha`, lifecycle
  timestamps. The cohort column replaces the epic wave column.
- **Cohort table:** projection of `cohorts[] { index, generation, item_keys[] }` so a recolored
  schedule is traceable by `generation` (§8.6).
- **Read-only projections of F3-owned arrays** (F5 renders, never writes the underlying data):
  `## Conflict Edges` (`conflict_edges[]`), `## Mutations` (`mutations[]`; rows appear only
  after F6 populates the array — an empty array renders an empty section), `## Drift Events`
  (`drift_events[]`; populated only by F8).
- **Regeneration boundaries:** run kickoff; every item `state`/`merge_status` transition; every
  cohort transition (`current_cohort` increments); every `recolor_generation` increment; every
  append to `mutations[]` or `drift_events[]`; run completion (`closed` mode) or close (`open`
  mode). Defining the mutation and drift appends as boundaries now means F6/F8 need no
  amendment to the projection rules.

The template deliverable (`docs/features/templates/parallel/parallel-status.md`) carries the
same generated-file HTML-comment banner pattern as the epic template.

#### R2.12 — Parallel-Level Checkpoint

Enumerates what F5 writes to `artifacts/orchestration/parallel-orchestrator-state.json` per §12
(F3 owns the schema; this section is consumption documentation only): `objective`,
`route_id: "parallel"`, `parallel_slug`, `parallel_manifest_path`, `parallel_status_doc_path`,
`mode`, `max_concurrency`, `completed_steps`, `next_step`, `last_updated`, `current_cohort`,
`recolor_generation`, `cohorts[]`, `items[]` (with `worktree_path`, `branch_name`,
`pr_number`, `pr_url`, `merge_status`, `merge_commit_sha`, lifecycle timestamps), and the three
receipt arrays.

`merge_status` transitions written by F5: `not_started` -> `worktree_created` (spawn) ->
`pr_open` (child reports S8) -> `ci_green` (durably confirmed after child DONE) -> `merged`
(parent merge succeeds) -> `worktree_removed` (after gated removal). `blocked_ci_loop_limit` is
the mapped terminal for an exhausted remediation loop (Decision 3). Read-only to F5:
`conflict_edges[]`, `mutations[]` (F6), `drift_events[]` (F8); `blocked_drift` is written only
by F8. Every field is re-derivable on resume from `git worktree list --porcelain`,
`git branch`, and `gh pr view --json state,mergedAt,headRefOid`; the checkpoint is a cache of
durable state, not the source of truth. Validation via the F3 validator
(`artifact_type: "parallel-orchestrator-state"`).

#### R2.13 — Completion Requirements

Mode-dependent per §8.7:

- `closed` (default): the completion gate fires when every non-withdrawn item is `merged` or
  `worktree_removed`. Completion additionally requires the final `parallel-status.md`
  regeneration and a passing `require_complete` validation of the checkpoint.
- `open`: no automatic completion; the run terminates only via `/parallel-close` (F6). The
  section names `/parallel-close` as F6-owned and does not specify it.

No integration-PR condition exists.

### R3 — Entry-point skill: `.claude/skills/parallel-run/SKILL.md`

Adapted from `epic-run` per research A.3. Frontmatter: `context: fork`,
`agent: parallel-orchestrator`, argument hint `[parallel-slug]`. Procedure:

1. Resolve the parallel home `docs/features/parallel/<slug>/` from the slug or path argument.
2. Kickoff-artifact discovery collapses to the local path only — there is no integration branch
   and therefore no `git cat-file`/`git show` integration-ref fallback. Expected location:
   `docs/features/parallel/<slug>/parallel-kickoff.md` (F4-owned; `## Assumptions`, item 4).
   When absent, STOP with the instruction to run `/parallel-plan` first (or invoke
   `/parallel-orchestrate <manifest-path>` directly).
3. Execute the kickoff artifact's `## Invocation Prompt`; items resume at atomic execution from
   their committed `plan-path` rather than re-planning.
4. Honor existing checkpoint state; resume instead of restart.

Scope statement: this skill adds only kickoff resolution; cohort scheduling, the cohort
barrier, per-item merge-on-green, worktree cleanup, and `parallel-status.md` maintenance are
governed by `parallel-orchestrate/SKILL.md`. No final integration PR exists.

### R4 — Contract tests

`tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` asserts the
structural acceptance criteria below: existence and required frontmatter of deliverables 1–4;
the literal `Parallel mode: true` marker in the kickoff-parameter section; presence,
uniqueness, and ordering of the three reserved wave-4 headings; the prescriptive-text negative
assertions; and epic-surface immutability via content-hash pinning of
`.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` (research
Testing Implications). Negative assertions target prescriptive text (`Epic mode: true`,
`--base epic/`, `integration-to-main`) rather than all mentions of epic files, because the
delivered surface legitimately names epic files when documenting deltas and dependencies.

## Cross-Feature Dependencies

**Known limitation: the parallel surface delivered by F5 is not executable end-to-end until F7
lands.** Two existing project-wide `PreToolUse` Bash-matcher hooks fail closed against commands
the parent must issue during a live run. F5 modifies neither hook nor `.claude/settings.json`
(Decision 2). This is a spec-level assumption and known limitation, not an F5 acceptance
criterion.

1. **`.claude/hooks/enforce-epic-merge-gate.ps1`** (registered at `.claude/settings.json:112`).
   Gate condition: denies any `gh pr merge --merge` unless a per-feature checkpoint has
   `epic_mode == true` and `step9_status == "passed"`, or an epic checkpoint has
   `epic_merge_pr.ci_gate.conclusion == "success"` with a matching `pr_number`. Block reason:
   `EPIC_MERGE_GATE_BLOCKED`. A parallel run satisfies neither condition, so the parent's
   per-item merge command (R2.8 step 3) is denied until F7 scopes or extends the gate's allow
   conditions for the parallel case.
2. **`.claude/hooks/enforce-epic-worktree-removal-gate.ps1`** (registered at
   `.claude/settings.json:116`). Gate condition: denies any `git worktree remove` unless the
   epic checkpoint has a matching `features[]` record with `merge_status` in
   `{merged, worktree_removed}`; an unreadable checkpoint or absent record denies. Block
   reason: `EPIC_WORKTREE_REMOVAL_BLOCKED`. A parallel run has no epic checkpoint record for
   its worktrees, so worktree removal (R2.10) is denied until F7 delivers
   `enforce-parallel-worktree-removal-gate.ps1` **and** coordinates the epic gate's conditions —
   `PreToolUse` denials are conjunctive, so a new allow-hook alone cannot override the existing
   deny (research E.4).

F7 additionally owns the cohort-barrier enforcement (Layer 1 hook and Layer 2 validator
invariant) and the invocation-origin extension for `parallel-orchestrator` and
`parallel-planner` (§9). The delivered skill text must state this F7 dependency explicitly,
naming both hooks and both block reasons, so that an operator reading the skill understands why
a live run blocks before F7. The F5 atomic plan must carry a coordination note for the F7
planner covering both epic-hook interactions (research E.4; Open Items 2).

## Assumptions

Neither F3 (`parallel-schema-validators`) nor F4 (`parallel-planner-surface`) has landed on
this branch; the research verified this by search (research G: the only `parallel`-named
artifacts are the design document and one unrelated completed feature). Each assumption below
is re-verified at execution time against the landed upstream artifacts (waves 0–2 merge before
F5's wave-3 execution).

1. **Contract stand-ins.** The design document's §11 (manifest schema), §12 (checkpoint
   schema), §6 (cohort/coloring output), and `route_id: parallel` are used as the contract in
   place of F3's landed artifacts. F5 **reads and writes** artifacts conforming to F3's schemas
   but does **not define or alter** them.
2. **F4 ownership.** F4 owns radius computation, V1–V3 validation, cohort seeding, and the
   kickoff artifact. F5 consumes the prepared plan and seeded cohorts; items resume at atomic
   execution from their committed plan-path rather than re-planning.
3. **`merge_status` enum mapping (Decision 3).** The exhausted-conflict-loop terminal maps to
   `blocked_ci_loop_limit`. Re-verify the value set against F3's landed validator at execution
   time and use exactly what F3 shipped.
4. **Kickoff-artifact location.** Expected at
   `docs/features/parallel/<slug>/parallel-kickoff.md`; the design does not specify where F4
   commits it or the prepared child folders. Pin `parallel-run`'s discovery step against F4's
   landed behavior. Children branch from `origin/main` and must find their committed
   `plan-path` reachable from that tip (research G.5).
5. **Validator wiring.** The `SubagentStop` artifact type `parallel-orchestrator-state`
   dispatches through F3's MCP/validator wiring; re-verify the exact artifact-type string when
   F3 lands.
6. **Branch protection on `main`.** Evidence indicates automated `gh pr merge --merge`
   succeeds once required checks are green (epic integration PR #388 precedent). Residual
   unknowns, verifiable unattended via `gh api repos/<owner>/<repo>/branches/main/protection`:
   whether "require branches to be up to date" is enabled (if so, any-order merging within a
   cohort requires an automated `gh pr update-branch` plus re-green cycle between merges, which
   serializes same-cohort merges in practice but remains unattended), and required-review
   settings (research, Automation Feasibility).
7. **F7 availability (Decision 2).** End-to-end executability depends on F7; see
   `## Cross-Feature Dependencies`.

## Constraints (non-negotiable)

1. **Naming.** The surface is `parallel` throughout. The child kickoff marker is the literal
   `Parallel mode: true` — the exact string F7's Layer 1 barrier hook matches on.
2. **No integration branch, no final integration PR, no fan-in merge-conflict path** (§4).
   There is no parallel analogue of `enforce-epic-merge-gate.ps1`.
3. **Same-tip branching, any-order merge.** Items within a cohort are non-conflicting by
   construction, branch from the same `main` tip, and merge in any order.
4. **`max_concurrency`** caps fan-out independently of cohort size; slots fill in ascending
   item-key order.
5. **`mode: closed | open`, default `closed`.** Completion semantics are mode-dependent
   (§8.7): `closed` fires the completion gate when every non-withdrawn item is `merged` or
   `worktree_removed`; `open` never completes automatically and terminates only via
   `/parallel-close`.
6. **`parallel-status.md` is a generated projection only**, never the source of the schedule;
   regeneration boundaries and section structure per R2.11.
7. **Additive only.** `.claude/agents/epic-orchestrator.md` and
   `.claude/skills/epic-orchestrate/SKILL.md` remain unmodified. Under Decision 1,
   `.claude/skills/orchestrate/SKILL.md` also remains unmodified. No hook files and no
   `.claude/settings.json` changes (Decision 2).
8. **File size limit.** No test or script file may exceed 500 lines. Markdown documentation is
   exempt, but the skill file should stay navigable.

## Out of Scope

- Cohort computation, recoloring, and the pinning invariant (F2 reference implementation, F4
  seeding, F6/F8 recoloring).
- `/parallel-add`, `/parallel-remove`, `/parallel-close`, admission control, and mutation-log
  writes (F6).
- All enforcement hooks and any `.claude/settings.json` change (F7).
- Drift detection, `drift_events[]` writes, `blocked_drift` transitions, quiesce, and requeue
  (F8).
- Schemas, validators, `.claude/rules/parallel-orchestration.md`, `route_id: parallel` in
  `config/orchestration-routing.json`, and MCP `artifact_type` wiring (F3).
- Any modification of the epic surface or of `.claude/skills/orchestrate/SKILL.md`.
- MCP scaffolding support for a `parallel` folder type.

## Testability Note

This feature delivers Markdown surface files. Every acceptance criterion below is verifiable by
a concrete, automatable check: file existence, frontmatter field presence, a grep-style
assertion over delivered content, an ordered-heading assertion, or a git-diff or content-hash
comparison. The contract-test deliverable (R4) is the vehicle for the structural assertions.

## Acceptance Criteria

- [ ] `.claude/agents/parallel-orchestrator.md` exists and its YAML frontmatter declares
      `name: parallel-orchestrator` (exact string), a `model`, a `tools` allowlist, a `skills`
      list containing `parallel-orchestrate`, and a `SubagentStop` hook invoking
      `validate-orchestrator-output.ps1` with
      `-CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json` and
      `-ArtifactType parallel-orchestrator-state`.
- [ ] The agent frontmatter `tools` allowlist does not contain `Agent(pr-author)`.
- [ ] The agent body contains the headings `## Skill`, `## Startup Protocol`,
      `## Invocation Origin`, `## Prepared-Run Execution`, `## Delegation Model`,
      `## Cohort Scheduling`, `## Checkpoint Persistence`, `## Documentation Maintenance`, and
      `## Completion Requirements`.
- [ ] The agent's `## Invocation Origin` section names `/parallel-orchestrate` and
      `/parallel-run` as entry points and contains a prohibition on invoking
      `Agent(parallel-orchestrator)` from within an `orchestrator` run.
- [ ] `.claude/skills/parallel-orchestrate/SKILL.md` exists and its frontmatter declares
      `context: fork` and `agent: parallel-orchestrator`.
- [ ] The skill contains the F5-authored elements of R2.1 (the `# Parallel Orchestrate Skill`
      intro heading and the thirteen named `##` sections, items 2–15) in the exact order
      listed, verifiable by an ordered-heading assertion.
- [ ] The skill's final three top-level headings are exactly `## Mutation Protocol (F6)`,
      `## Enforcement Hooks (F7)`, and `## Radius Drift Detection (F8)`, in that order, each
      appearing exactly once, each followed by a one-line reserved body stating that content is
      appended by that feature and must not be relocated.
- [ ] The `## Parallel-Mode Kickoff Parameter` section contains the literal string
      `Parallel mode: true` and the literal string `PR base branch MUST be main`, states that
      the kickoff prompt never carries `Preparation mode: true` or `Epic mode: true`, and
      contains no instruction for the child to merge its own PR (no occurrence of
      `gh pr merge` within that section).
- [ ] The `## Cohort Barrier and Max-Concurrency Slot Filling` section states that cohort
      `N+1` launches only after every cohort-`N` item is `merged` or `worktree_removed`, and
      contains the token `max_concurrency` and the phrase `ascending item-key order`.
- [ ] The `## Per-Item Merge to Main (Merge-on-Green)` section states that the
      `parallel-orchestrator` executes `gh pr merge --merge` against `main` after durably
      confirming CI green, and states that `.claude/skills/orchestrate/SKILL.md` is not
      modified by this feature.
- [ ] The `## Per-Item Merge-Conflict Handling` section maps the exhausted remediation loop to
      `blocked_ci_loop_limit`, states the shared remediation cap of 3, and contains a hand-off
      sentence naming F8 for drift recording, quiesce, recompute, and requeue.
- [ ] The `## Documentation Maintenance Boundaries` section states that `parallel-status.md`
      is generated and never hand-authored, states it is never the source of the cohort table,
      and lists regeneration boundaries including item transitions, cohort transitions,
      `recolor_generation` increments, `mutations[]` appends, and `drift_events[]` appends.
- [ ] The `## Parallel-Level Checkpoint` section enumerates all eight §12 `merge_status`
      values (`not_started`, `worktree_created`, `pr_open`, `ci_green`, `merged`,
      `worktree_removed`, `blocked_drift`, `blocked_ci_loop_limit`) and states that F5 never
      writes `blocked_drift`, `conflict_edges[]`, `mutations[]`, or `drift_events[]`.
- [ ] The `## Completion Requirements` section defines mode-dependent completion: `closed`
      fires when every non-withdrawn item is `merged` or `worktree_removed`; `open` terminates
      only via `/parallel-close`.
- [ ] The delivered skill text names both `EPIC_MERGE_GATE_BLOCKED` and
      `EPIC_WORKTREE_REMOVAL_BLOCKED` as F7-dependency block conditions that prevent
      end-to-end execution until F7 lands.
- [ ] `.claude/skills/parallel-run/SKILL.md` exists, its frontmatter declares `context: fork`
      and `agent: parallel-orchestrator`, its discovery step STOPs with an instruction naming
      `/parallel-plan` when no kickoff artifact is found, and it states that items resume at
      atomic execution from their committed `plan-path`.
- [ ] `docs/features/templates/parallel/parallel-status.md` exists and begins with an
      HTML-comment generated-file banner stating the file is generated and must not be
      hand-authored.
- [ ] `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` exists and
      passes, asserting the structural conditions above including content-hash pinning of
      `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`.
- [ ] None of the three delivered runtime files (`parallel-orchestrator.md`,
      `parallel-orchestrate/SKILL.md`, `parallel-run/SKILL.md`) contains any of the
      prescriptive literals `Epic mode: true`, `--base epic/`, or `integration-to-main`.
- [ ] `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md` are
      byte-identical to their pre-feature state (empty `git diff` for both paths over the
      feature branch).
- [ ] `.claude/skills/orchestrate/SKILL.md` is byte-identical to its pre-feature state (empty
      `git diff` for that path over the feature branch).
- [ ] The feature branch diff contains no changes under `.claude/hooks/` and no change to
      `.claude/settings.json`.
