# F5 `parallel-orchestrator-surface` — Research

- **Issue:** #441
- **Date:** 2026-08-07T12-30
- **Epic:** `parallel-orchestration` (`docs/features/epics/parallel-orchestration/epic.md`)
- **Design authority:** `docs/research/2026-08-07-parallel-orchestration-design-research.md` (all §N references below)
- **Working directory:** worktree on `epic/parallel-orchestration-integration`

All file paths are worktree-root-relative unless stated otherwise. Line ranges were verified by
reading the files in this session.

---

## A. Structural Precedent Inventory

Verdict legend: `adapt-verbatim` (name substitution only), `adapt-modified` (changes forced by the
per-item-merge / no-integration-branch delta), `drop` (no parallel counterpart), `new` (no epic
precedent).

### A.1 `.claude/agents/epic-orchestrator.md` (163 lines)

| Section | Lines | Purpose | Verdict | Notes for `parallel-orchestrator.md` |
| --- | --- | --- | --- | --- |
| YAML frontmatter | 1–33 | `name`, `model: opus`, `description`, `tools` allowlist, `skills`, `memory: project`, `SubagentStop` hook | adapt-modified | Drop `Agent(pr-author)` from `tools` (no final integration PR; per-item PRs are authored inside each child by that child's own S8). `Write`/`Edit` scopes become `docs/features/parallel/**` plus `artifacts/orchestration/**`. `SubagentStop` hook reuses the parameterized `validate-orchestrator-output.ps1` with `-CheckpointPath artifacts/orchestration/parallel-orchestrator-state.json -ArtifactType parallel-orchestrator-state` (mirror of line 32; the artifact type is F3's validator wiring). |
| Persona intro | 35–44 | Role framing; sole authorization to delegate `Agent(orchestrator)`; no deep implementation | adapt-modified | Replace wave/integration-branch/final-PR framing with cohort/per-item-merge framing. Do not claim exclusive authorization to delegate `Agent(orchestrator)` — `epic-orchestrator`'s description (line 4) makes that claim and the epic files are frozen; the parallel persona should claim authorization without exclusivity. |
| `## Skill` | 46–51 | Binds the agent to the `epic-orchestrate` procedure skill | adapt-verbatim | Names only (`parallel-orchestrate`). |
| `## Startup Protocol` | 53–66 | CLAUDE.md/rules read; checkpoint read; resume via durable ground truth; else begin at manifest parsing | adapt-modified | Checkpoint path `artifacts/orchestration/parallel-orchestrator-state.json`; match key `parallel_slug`; begin from `docs/features/parallel/<slug>/parallel.md`. Resume re-derivation commands (`git worktree list --porcelain`, `git branch`, `gh pr view --json state,mergedAt,headRefOid`) carry over unchanged (§12, design lines 293–295). |
| `## Invocation Origin` | 68–76 | Invocation entry points; prohibition on `orchestrator`-originated invocation; names the origin hook | adapt-modified | Entry points become `/parallel-orchestrate` and `/parallel-run`. The section should state the same nesting prohibition and note that hook coverage for `parallel-orchestrator`/`parallel-planner` is delivered by F7's extension of `.claude/hooks/enforce-epic-invocation-origin.ps1` (§9, design lines 224–225). F5 must not modify the hook (see H). |
| `## Prepared-Epic Execution` | 78–99 | Handoff from `epic-planner`: fetch integration branch, read kickoff artifact from the ref, resume children at committed `plan-path` | adapt-modified | The integration-ref discovery mechanics (lines 84–92) drop entirely. The resume-at-plan-path contract (numbered item 2, lines 95–97) carries over: each child kickoff cites the committed `plan-path` and resumes at atomic execution. Where F4 lands the prepared folders/kickoff artifact is an open upstream contract (see G.5). |
| `## Delegation Model` | 101–118 | Two channels: `Agent(orchestrator)` per child with kickoff + upstream-context lines; `Agent(pr-author)` for the final PR | adapt-modified | Single channel: `Agent(orchestrator)` per item (`isolation: "worktree"`, `run_in_background: true`). Drop the `Agent(pr-author)` channel (lines 112–115) and drop upstream-context citation lines (no `depends_on`, §4/§11). |
| `## Wave Scheduling` | 120–131 | Longest-path layering; concurrent launch within a wave; barrier before wave N+1 | adapt-modified | Becomes cohort consumption: F5 does not compute cohorts (F4 seeds them via F2, §6); it consumes `cohorts[]`, enforces the cohort barrier (cohort N+1 branches from `main` only after every cohort-N item is `merged`/`worktree_removed`), and applies `max_concurrency` slot filling in ascending item-key order — the slot-filling rule is `new` (no epic precedent; epics launch a whole wave at once). |
| `## Checkpoint Persistence` | 133–141 | Field list for the epic checkpoint | adapt-modified | Replace with the §12 field list (design lines 276–295). F3 owns the schema; this section only enumerates what F5 writes. |
| `## Documentation Maintenance` | 143–150 | `epic-status.md` regeneration boundaries; generated-never-hand-authored | adapt-modified | `parallel-status.md`; boundaries and added sections per B.3 below. |
| `## Completion Requirements` | 152–163 | Five completion conditions incl. final integration PR merged | adapt-modified | Mode-dependent per §8.7: `closed` — every non-withdrawn item `merged` or `worktree_removed`; `open` — no automatic completion, terminates only via `/parallel-close` (F6). Drop the integration-PR condition (item 2, line 157). Keep status-doc, validator `require_complete`, and AC-checkoff conditions. |

### A.2 `.claude/skills/epic-orchestrate/SKILL.md` (293 lines)

| Section | Lines | Purpose | Verdict | Notes for `parallel-orchestrate/SKILL.md` |
| --- | --- | --- | --- | --- |
| YAML frontmatter | 1–7 | `context: fork`, `agent: epic-orchestrator`, argument hint | adapt-verbatim | `agent: parallel-orchestrator`; argument becomes the parallel manifest path or slug. |
| Intro | 9–20 | Frames the skill for the agent; lists covered procedures | adapt-verbatim | Name substitution; replace the procedure list with the parallel set. |
| `## Prerequisites` | 22–28 | CLAUDE.md, rules, compliance reading order | adapt-verbatim | Unchanged. |
| `## Epic Dependency Manifest` | 30–77 | Manifest frontmatter schema (single schema authority); `issue_num` primary key; `depends_on` resolution; malformed-manifest rejection | adapt-modified | The parallel manifest (§11) has no `depends_on` and adds `mode`, `max_concurrency`, per-item `state` and `blast_radius`. Unlike the epic skill, this section must NOT be the schema authority: F3 owns the schema (`.claude/rules/parallel-orchestration.md` and the validators, epic.md lines 190–197). The section should reference F3's schema and define only consumption behavior (`issue_num` primary key retained; malformed manifest rejected as a synthetic Blocking finding before kickoff, mirroring lines 70–72). |
| `## Wave Assignment` | 79–96 | Longest-path layering formula; cycle rejection; reference implementation | adapt-modified | Becomes "Cohort Consumption": cohorts are an input (seeded by F4 from F2's `parallel_cohort_computation.py`, §6/§10), not computed by this skill. Recoloring belongs to F6/F8. The section documents determinism expectations and how `cohorts[] { index, generation, item_keys[] }` is read. |
| `## Epic Integration Branch Lifecycle` | 98–119 | Create/fetch integration branch; children branch from it; child PR base override; final integration-to-`main` PR incl. `enforce-epic-merge-gate.ps1` | drop | Replaced by a `new` "Per-Item Branch and Merge Lifecycle" section: `git fetch origin main` before each cohort; each item worktree branches from `origin/main`; PR base is `main` (the default — no `--base` override semantics needed, though an explicit `--base main` line in the kickoff is harmless and self-documenting); merge-on-green per item; no final PR; no fan-in. There is no parallel analogue of `enforce-epic-merge-gate.ps1` (§4, design lines 47–49) — but see E.4 for the existing hook's cross-surface interaction. |
| `## Merge-on-Green Kickoff Parameter` | 121–132 | The literal `Epic mode: true` kickoff line; child records `epic_mode`/`epic_context`; S9 step 6 behavior | adapt-modified | Marker becomes the literal `Parallel mode: true`; field set per D.2; child records `parallel_mode`/`parallel_context` and on CI-green merges its own PR into `main`, recording `parallel_merge`. See C.2 for where the child-side contract must live. |
| `## Model Selection` | 134–159 | `model_budget.fable_policy` kickoff marker; per-delegation resolution via `ModelRouting.psm1`; `route` never a model input | adapt-verbatim | Name substitution only (the delegating agent name). The `Agent(pr-author)` sentence (lines 149–154) narrows to `Agent(orchestrator)` only. |
| `## Context Handoff to Dependent Features` | 161–176 | Upstream-context citation lines per `depends_on` edge | drop | No `depends_on` (§4, §11). Ordering knowledge lives in blast-radius overlap; no citation lines exist to emit. |
| `## Merge-Conflict Handling (Fan-In)` | 178–203 | Child-owned conflict remediation via R1–R5; conflict against the integration branch; loop cap; `blocked_conflict_loop_limit` mirroring | adapt-modified | Same child-owned R1–R5 shape, with `origin/main` substituted for `origin/<integration_branch>` in step 1 (lines 189–190). The epic terminal status `blocked_conflict_loop_limit` (line 203) has no counterpart in the §12 `merge_status` enum — see C.3 and E.5 for the required mapping. Additionally, the parallel section must state the §13.1 boundary: a conflict between two same-cohort items is evidence of blast-radius under-report; F5 records the child's blocked/remediated outcome only and leaves drift recording, quiesce, recompute, and requeue to F8. |
| `## Wave Barrier (Two-Layer Design)` | 205–226 | Layer 1 `enforce-epic-wave-barrier.ps1`; Layer 2 validator invariant; durable confirmation before wave N+1 | adapt-modified | Same two-layer shape (§9). F5 documents the cohort-barrier procedure it must honor (durable confirmation via git/gh before launching cohort N+1) and names the F7 deliverables (`enforce-parallel-cohort-barrier.ps1`, `PARALLEL_COHORT_BARRIER_BLOCKED`/`_VIOLATION`) without shipping them. The hook files themselves are `drop` from F5's deliverable list (F7 owns them). |
| `## Worktree Cleanup` | 228–237 | Remove worktree after merge confirmation; gated by `enforce-epic-worktree-removal-gate.ps1`; state transitions | adapt-modified | Same sequence keyed on per-item `merge_status: "merged"` → `git worktree remove` → `merge_status: "worktree_removed"`. The parallel gate hook is F7's near-verbatim adaptation (§9, design lines 222–223). See E.4 for the existing epic hook's fail-closed interaction, which F5 must document but not fix. |
| `## Documentation Maintenance Boundaries` | 239–259 | `epic-status.md` projection rules: boundaries, row fields, generated-only statement | adapt-modified | See B.3 for the full `parallel-status.md` rule set. |
| `## Epic-Level Checkpoint` | 261–282 | Checkpoint field list; `merge_status` enum; durable re-derivation; validator invocation | adapt-modified | §12 field list; `merge_status` enum per §12 (8 values, design lines 290–291); validation via `artifact_type: "parallel-orchestrator-state"` (F3's `validate_parallel_orchestrator_state.py`). |
| `## Completion Requirements` | 284–293 | Four conditions incl. integration PR merged | adapt-modified | Mode-dependent (§8.7); drop the integration-PR condition. |

Sections with no epic precedent (`new`, must be authored fresh in F5):

1. **Cohort barrier statement** — "cohort N+1 branches from `main` only after every cohort-N item
   has merged" (§6, design lines 123–125). The epic barrier gates on per-feature `depends_on`
   edges; the cohort barrier gates on whole-cohort completion. Structural analogue exists, but the
   predicate is new.
2. **`max_concurrency` slot filling** — cap fan-out independently of cohort size, slots filled in
   ascending item-key order (§6, design lines 127–129). No epic counterpart (epics launch a full
   wave in one message, `epic-orchestrate` lines 126–127).
3. **Mode-dependent completion** — `closed` vs `open` (§8.7, design lines 199–205).
4. **`parallel-status.md` cohort/mutation/drift projection sections** — see B.3.
5. **Reserved wave-4 placeholder sections** — see F.

### A.3 `.claude/skills/epic-run/SKILL.md` (57 lines)

| Section | Lines | Purpose | Verdict | Notes for `parallel-run/SKILL.md` |
| --- | --- | --- | --- | --- |
| YAML frontmatter | 1–7 | `context: fork`, `agent: epic-orchestrator` | adapt-verbatim | `agent: parallel-orchestrator`; argument `[parallel-slug]`. |
| Intro | 9–15 | Frames replay of the planned run | adapt-verbatim | Name substitution. |
| `## Procedure` step 1 | 19–20 | Resolve the epic home from slug or path | adapt-verbatim | `docs/features/parallel/<slug>/`. |
| `## Procedure` step 2 | 21–42 | Kickoff-artifact discovery across local path AND the integration ref (`git cat-file -e`, `git show`); STOP when absent in both | adapt-modified | With no integration branch, the dual-location discovery collapses. The parallel analogue checks the local path (F4's committed kickoff artifact, expected `docs/features/parallel/<slug>/parallel-kickoff.md` — see G.5) and STOPs with "run `/parallel-plan` first (or invoke `/parallel-orchestrate <manifest-path>` directly)" when absent. The `git fetch`/`git show` integration-ref logic drops unless F4's landing contract requires it (open until F4 lands). |
| `## Procedure` step 3 | 43–47 | Execute the kickoff `## Invocation Prompt`; resume children at committed `plan-path` | adapt-verbatim | Name substitution; the resume-at-plan-path contract carries over intact. |
| `## Procedure` step 4 | 48–50 | Honor existing checkpoint state; resume instead of restart | adapt-verbatim | Checkpoint path substitution. |
| `## Scope` | 52–56 | Declares the skill adds only kickoff resolution; everything else is the orchestrate skill's | adapt-modified | Minor: the governed-procedure list changes (cohort scheduling, cohort barrier, per-item merge-on-green, worktree cleanup, `parallel-status.md`; no final integration PR). |

Note on precedent tests: `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py`
asserts content of `epic-run`'s discovery procedure; a `parallel-run` analogue test is the natural
pattern (see Testing Implications).

## B. The `epic-status.md` Projection Rules

The projection rules exist in four places; no derivation from the design document was necessary.

1. **Regeneration boundaries** — `.claude/skills/epic-orchestrate/SKILL.md` lines 246–254:
   regenerated from the epic checkpoint at (a) epic kickoff (initial table seeded from the
   manifest, one row per feature, status `not_started`); (b) every per-feature `merge_status`
   change (`worktree_created`, `pr_open`, `ci_green`, `merge_conflict`, `merged`,
   `worktree_removed`), row updated in place; (c) each wave transition (`current_wave`
   increments); (d) final integration PR opened, green, and merged. Restated in
   `.claude/agents/epic-orchestrator.md` lines 145–148.
2. **Section structure** — template `docs/features/templates/epic/epic-status.md` lines 1–21:
   an HTML comment banner ("GENERATED FILE — DO NOT HAND-AUTHOR", lines 1–11), a title, a
   restated generated-only paragraph (lines 15–16), and a single feature table with columns
   `feature_folder | issue_num | wave_number | merge_status | pr_url | merge_commit_sha`
   (lines 18–20). The produced-in-practice shape
   (`docs/features/epics/legacy-discovery-and-parity/epic-status.md` lines 1–31) adds a header
   bullet block (integration branch, current wave, last updated, fable_policy; lines 5–8), a
   wider table including complexity and the four lifecycle timestamps (line 10), and a
   `## Final Integration PR` trailer (lines 27–30). The skill's row contract
   (`epic-orchestrate` lines 256–258) requires: `feature_folder`, `issue_num`, `wave_number`,
   `merge_status`, `pr_url`, `merge_commit_sha`, and the four lifecycle timestamps.
3. **"Generated, never hand-authored" statements** — `epic-orchestrate` lines 243–245
   ("regenerated (never hand-authored) from the epic checkpoint and is never the source of the
   DAG"); `epic-orchestrator.md` line 150; the template banner itself. **Enforcement:** none is
   mechanical. SearchScope: `scripts/**`, `.claude/hooks/**`, `tests/**`. SearchPatterns:
   `epic-status`. SearchResult: only scaffolding code
   (`scripts/dev_tools/new_active_feature_folder_io.py` lines 96 and 110, which copies
   `epic-status.md` as a generated-only template without stamping it, and its tests). No hook or
   validator checks `epic-status.md` content. The constraint is prose-plus-template-banner only.

### B.3 What `parallel-status.md` must add

`parallel-status.md` (at `docs/features/parallel/<slug>/parallel-status.md`) is the same kind of
generated projection of `artifacts/orchestration/parallel-orchestrator-state.json`. Required
deltas versus the epic projection:

- **Header block:** `parallel_slug`, `mode`, `max_concurrency`, `current_cohort`,
  `recolor_generation`, `last_updated` (checkpoint fields, §12 design lines 278–282).
- **Item table:** one row per `items[]` entry: `issue_num`, `feature_folder`, cohort index,
  lifecycle `state` (§8.2), `merge_status` (§12 enum: `not_started`, `worktree_created`,
  `pr_open`, `ci_green`, `merged`, `worktree_removed`, `blocked_drift`,
  `blocked_ci_loop_limit`; design lines 290–291), `pr_url`, `merge_commit_sha`, lifecycle
  timestamps. The cohort column replaces the wave column.
- **Cohort table:** projection of `cohorts[] { index, generation, item_keys[] }` so a recolored
  schedule is visibly traceable by `generation` (§8.6 auditability requirement, design
  lines 190–194).
- **Read-only projections of F3-owned arrays** (F5 renders, never writes the underlying data):
  - `## Conflict Edges` — `conflict_edges[] { a, b, reason }` (§12 design line 285).
  - `## Mutations` — `mutations[] { op, item_key, at, prior_state, new_state, disposition,
    recolor_generation }` (§8.6); rows appear only after F6 populates the array — an empty array
    renders an empty section.
  - `## Drift Events` — `drift_events[] { item_key, declared, observed, escaped_paths[], at,
    action }` (§12 design line 287); populated only by F8.
- **Regeneration boundaries:** run kickoff; every item `state`/`merge_status` transition; every
  cohort transition (`current_cohort` increments); every `recolor_generation` increment; every
  append to `mutations[]` or `drift_events[]`; run completion (`closed` mode) or close (`open`
  mode). Defining mutation/drift appends as boundaries now means F6/F8 do not need to amend the
  projection rules later — their events flow through the checkpoint and the existing boundary
  list.
- **Never the source of the schedule:** the analogue of "never the source of the DAG" is "never
  the source of the cohort table"; the manifest and checkpoint JSON are authoritative.
- Recommend a `docs/features/templates/parallel/parallel-status.md` template with the same
  generated-file banner, mirroring `docs/features/templates/epic/epic-status.md`. MCP scaffolding
  wiring (`new_active_feature_folder` support for a `parallel` type) is not assigned to F5 by the
  design and should not be pulled into scope; F5's agent writes the projection directly.

## C. Reuse Inventory Items Named by §10

### C.1 Preparation-mode child contract

Authoritative definition: `.claude/skills/orchestrate/SKILL.md` `## Preparation Mode`
(lines 90–98), with the route defined in `config/orchestration-routing.json` lines 79–99 and the
issuing-side contract in `.claude/skills/epic-plan/SKILL.md` lines 87–122. Load-bearing lines:

> "A delegation prompt carrying the literal marker `Preparation mode: true` (issued by
> `epic-planner` per the `.claude/skills/epic-plan/SKILL.md` kickoff line) scopes the run to
> planning only" (orchestrate SKILL line 92), and "**Route.** Select `route_id: preparation`"
> (line 94).

Findings for F5:

- §8.3 step 2 reuses `route_id: preparation` **unchanged** — confirmed compatible: the route
  definition is issuer-agnostic (`config/orchestration-routing.json` lines 79–99 name no epic
  fields), and the marker detection in `orchestrate` keys on the literal `Preparation mode: true`
  line only. The parenthetical "(issued by epic-planner ...)" in line 92 is descriptive, not
  restrictive; no change to `orchestrate/SKILL.md` is needed for a `parallel-planner`/F6 issuer.
- **Ownership:** preparation fan-out is F4's (initial batch) and F6's (`/parallel-add`), not
  F5's. F5's only obligation is negative: the `Parallel mode: true` execution kickoff line and
  the `Preparation mode: true` planning line are distinct markers that must never co-occur in one
  prompt. Precedent: `epic-plan/SKILL.md` lines 102–105 deliberately omits `Epic mode: true` from
  preparation prompts so the execution-phase barrier hook does not fire. `parallel-orchestrate`
  must mirror that separation: its child kickoff carries `Parallel mode: true` and never
  `Preparation mode: true`.

### C.2 Merge-on-green S9 extension

Authoritative definition, three parts, all in `.claude/skills/orchestrate/SKILL.md`:

1. **S9 step 6** (line 223): "If the checkpoint's `epic_mode` is `true`, execute
   `gh pr merge --merge <PR>` merging the feature branch into `epic_context.integration_branch`
   ... On success, record `epic_merge: { merge_commit_sha, target_branch, merged_at }` ... On
   failure due to merge conflict ... convert the conflict into a synthetic Blocking finding ...
   and re-enter the standard R1–R5 remediation loop".
2. **`epic_merge` checkpoint object** (lines 239–242): `merge_commit_sha`, `target_branch`,
   `merged_at`, populated only in epic mode.
3. **PR Creation Gate condition 7** (line 285): "`epic_mode` is `false`, OR (`epic_mode` is
   `true` AND the integration-branch merge (`gh pr merge --merge`) has completed and
   `epic_merge.merge_commit_sha` is recorded in the checkpoint)."

The issuing side is `epic-orchestrate/SKILL.md` lines 121–132 (kickoff line; child records
`epic_mode` and `epic_context` at first checkpoint write).

**What the parallel analogue must look like** (merge target `main`):

- Child kickoff line carries `Parallel mode: true` plus `parallel_slug`,
  `parallel_checkpoint_path`, and `PR base branch MUST be main` (see D.2).
- Child records `parallel_mode: true` and
  `parallel_context: { parallel_slug, parallel_checkpoint_path }` at first checkpoint write —
  the direct replacement for `epic_mode`/`epic_context`. No `integration_branch` member exists;
  the merge target is constantly `main`.
- On CI-green the child executes `gh pr merge --merge <PR>` (base already `main`) and records
  `parallel_merge: { merge_commit_sha, target_branch: "main", merged_at }` — the replacement for
  `epic_merge`.
- A parallel analogue of PR Creation Gate condition 7 is required: with only the epic wording, a
  parallel child has `epic_mode` absent/false, so condition 7 passes vacuously and DONE would not
  be gated on the merge having completed.

**Structural finding — where the child-side contract lives.** S9 step 6, the `epic_merge`
schema, and condition 7 live in the *shared* `.claude/skills/orchestrate/SKILL.md`, not in an
epic-named file. The reuse instruction "adapt into new `parallel`-named files, not by
generalizing the epic implementations in place" (epic.md lines 239–244) freezes
`epic-orchestrator.md` and `epic-orchestrate/SKILL.md`; it does not freeze
`orchestrate/SKILL.md`, which is the child contract both surfaces share and which the epic
feature itself extended additively when epic mode was built. Recommended approach: F5 extends
`orchestrate/SKILL.md` additively — a `parallel_mode` clause in S9 (either an addition to step 6
or a parallel step alongside it), a `parallel_merge` object in the checkpoint-schema section, and
an additional PR Creation Gate condition mirroring condition 7 — leaving all epic wording
byte-identical. Rejected alternative: carrying the merge-on-green instruction purely in the
kickoff prompt with no `orchestrate/SKILL.md` change. Rejected because (a) nothing would gate
DONE on the merge (condition 7 passes vacuously), and (b) the child checkpoint would carry
undocumented `parallel_*` fields with no contract text. The planner should surface this as an
explicit scope item since the F5 spec's Behavior list does not currently name
`orchestrate/SKILL.md`.

**Hook interaction (blocking, owned by F7):** `.claude/hooks/enforce-epic-merge-gate.ps1` is
registered on the Bash matcher project-wide (`.claude/settings.json` lines 110–113) and matches
*any* `gh pr merge --merge` command. It allows only when the per-feature checkpoint has
`epic_mode == true` and `step9_status == "passed"`, or the epic checkpoint has a green
`epic_merge_pr` (hook lines 6–21, denial text line 287); everything else fails closed. A parallel
child's checkpoint has `parallel_mode`, not `epic_mode`, so its merge-on-green command would be
**denied** by this existing hook. The design's statement that dropping the integration branch
"removes `enforce-epic-merge-gate.ps1`" (§4, design lines 47–49) addresses the integration-PR
path only; the hook's child-path condition still fires on parallel merges. §9 does not currently
assign this to any feature. F5 must not modify the hook; the research recommendation is that the
planner record this as an F7 obligation (extend the gate's allow conditions to the
`parallel_mode`/`step9_status == "passed"` child path, or scope the epic gate), and that F5's
skill text state the dependency explicitly. Until F7 lands, a live parallel run cannot complete a
merge — acceptable sequencing, since F7 (wave 4) completes before the parallel surface is
usable end-to-end.

### C.3 R1–R5 remediation loop

Authoritative definition: `.claude/skills/orchestrate/SKILL.md` `## Remediation Loop (R1–R5)`
(lines 189–200), CI-failure entry at lines 265–273, and the epic merge-conflict entry adaptation
in `epic-orchestrate/SKILL.md` lines 178–203. Load-bearing lines: the five steps R1–R5
(lines 193–198), the shared `remediation_pass` cap of 3 (lines 199–200, 272–273), and the epic
conflict procedure's step 1 (`git fetch origin <integration_branch>`,
`git merge --no-commit origin/<integration_branch>`, capture
`git diff --name-only --diff-filter=U` plus conflict markers; lines 189–191).

**Verdict: consumed unmodified by each child**, with two parallel-specific notes:

1. The conflict-entry adaptation substitutes `origin/main` for `origin/<integration_branch>` in
   step 1. This lives in `parallel-orchestrate/SKILL.md`'s conflict-handling section (the child
   is instructed via its kickoff context), not in a change to the R1–R5 loop itself.
2. **Enum mapping:** the epic loop-limit terminal is `step9_status: "blocked_conflict_loop_limit"`
   mirrored to epic `merge_status: "blocked_conflict_loop_limit"` (`epic-orchestrate`
   lines 201–203). The §12 parallel `merge_status` enum (design lines 290–291) contains **no**
   conflict-specific value — its blocked states are `blocked_drift` and `blocked_ci_loop_limit`
   only. F5 must not extend the enum (F3 owns it). Consequence: a per-item conflict that exhausts
   the R1–R5 cap maps to `blocked_ci_loop_limit` at the parallel checkpoint (the child's own
   checkpoint still records the precise `blocked_conflict_loop_limit` `step9_status`), unless
   F3's landed validator provides a conflict value. F5's planner should verify F3's landed enum
   at execution time and use exactly what F3 shipped.

## D. Child Kickoff Contract and the `Parallel mode: true` Marker

### D.1 Epic analogue marker

- Emitted by `epic-orchestrate/SKILL.md` lines 123–126 as the literal kickoff line:
  `Epic mode: true. epic_feature_folder: <epic-slug>. integration_branch: ... epic_checkpoint_path: ... PR base branch MUST be <integration_branch>, not main; pass --base <integration_branch> to gh pr create.`
- Matched by `.claude/hooks/enforce-epic-wave-barrier.ps1`: activation requires
  `subagent_type == "orchestrator"` plus the marker constant
  `$script:EpicModeMarker = 'Epic mode: true'` (hook lines 6–8, 38). The hook then resolves the
  target item by scanning the prompt for a `docs/features/active/<token>` path (longest match
  wins, `.md` suffix resolves to parent; lines 58–105) and looks the basename up in the epic
  checkpoint. F7's `enforce-parallel-cohort-barrier.ps1` is specified to fire the same way on
  `Parallel mode: true` (§9, design lines 212–216).

### D.2 Required fields of a parallel child kickoff prompt

Derived from the epic kickoff line (lines 123–132), the model-budget marker (lines 137–147), the
issue-number line (`orchestrate/SKILL.md` lines 206–208), the resume contract
(`epic-orchestrator.md` lines 95–97), and the F7 hook's prompt-resolution technique:

1. The literal marker line: `Parallel mode: true. parallel_slug: <slug>. parallel_checkpoint_path:
   artifacts/orchestration/parallel-orchestrator-state.json. cohort_index: <n>. PR base branch
   MUST be main; pass --base main to gh pr create. On CI-green (S9), merge your own PR into main
   with gh pr merge --merge and record parallel_merge.`
2. The item's active feature folder path, written literally as
   `docs/features/active/<basename>` — required both for the child's own operation and because
   the F7 Layer 1 hook resolves the target item by scanning the prompt for exactly that path
   shape (see D.1). Including it as a bare path token preserves hook compatibility.
3. The canonical issue number line (`orchestrate/SKILL.md` lines 206–208): the item key.
4. The committed `plan-path` plus the resume instruction: "resume at atomic execution from this
   plan rather than re-running promotion, research, or planning" (epic precedent:
   `epic-orchestrator.md` item 2, lines 95–97; `epic-run` step 3, lines 43–47).
5. The model-budget marker line `model_budget.fable_policy: <disabled|available|preferred>.`
   (`epic-orchestrate` lines 137–139).
6. Spawn parameters, not prompt text: `isolation: "worktree"`, `run_in_background: true`,
   branch base `origin/main` (epic precedent: `epic-orchestrate` lines 105–109, 126–127), and
   `model` bound to the routing receipt (lines 149–154).

Not required in the prompt: the declared blast radius (F8 reads it from the manifest/checkpoint
when comparing diffs; the item key suffices to locate it), `max_concurrency` (a
parallel-orchestrator-side scheduling input only), and `mode` (completion semantics are the
parent's concern). Keeping the prompt minimal mirrors the epic kickoff line's field discipline.

### D.3 Resume-at-execution contract location today

Expressed in three places for epics: `.claude/agents/epic-orchestrator.md` `## Prepared-Epic
Execution` item 2 (lines 95–97); `.claude/skills/epic-run/SKILL.md` step 3 (lines 43–47); and the
kickoff artifact's `## Invocation Prompt` text authored by `epic-plan/SKILL.md` (lines 158–164:
"child features resume at atomic execution from their committed plan-path rather than
re-planning"). The parallel surface needs the same statement in `parallel-orchestrator.md`,
`parallel-run/SKILL.md`, and consumed from F4's kickoff artifact.

## E. Worktree Lifecycle and Per-Item Merge to `main`

### E.1 How the epic surface creates, tracks, and removes worktrees

- **Create:** child worktrees are created implicitly by the `Agent(orchestrator,
  isolation: "worktree", run_in_background: true)` spawn, branched from
  `origin/<integration_branch>` after a pre-wave `git fetch` (`epic-orchestrate` lines 103–109;
  `epic-orchestrator.md` lines 105–111).
- **Track:** per-feature `worktree_path`, `branch_name`, `pr_number`, `merge_status` in the epic
  checkpoint; all re-derivable from `git worktree list --porcelain`, `git branch`, and
  `gh pr view --json state,mergedAt,headRefOid` (`epic-orchestrate` lines 273–276).
- **Remove:** after `epic_merge.merge_commit_sha` is mirrored into `merge_status: "merged"`,
  the epic-orchestrator (from the main checkout) runs `git worktree remove <path>`, gated by
  `enforce-epic-worktree-removal-gate.ps1`, then records `worktree_removed` +
  `worktree_removed_at` (`epic-orchestrate` lines 228–237).

### E.2 What changes for parallel

- Every cohort-N item branches from the same `origin/main` tip: one `git fetch origin main`
  before cohort launch replaces the per-wave integration-branch fetch. Within a cohort, launch is
  bounded by `max_concurrency` (ascending item-key order), so a cohort may launch in several
  batches from the same recorded `main` tip.
- Items merge in any order (§6, design line 124): safe by construction because a cohort is an
  independent set in the conflict graph. After item A merges, item B's PR (based on the older
  tip) remains mergeable; GitHub produces a merge commit. Caveat recorded under Automation
  Feasibility: a branch-protection "require branches to be up to date" setting would insert a
  `gh pr update-branch` + re-green step between same-cohort merges; not evidenced as enabled.
- No integration branch, no fan-in, no final PR: the entire `## Epic Integration Branch
  Lifecycle` section drops (A.2), and completion keys on per-item `merged`/`worktree_removed`
  states only.

### E.3 Non-mergeable per-item PR (merge conflict at `main`)

Epic route: S9 step 6 merge failure → synthetic Blocking finding
(`remediation-inputs.<timestamp>.md` in the child's own feature folder) → child R1–R5, cap 3
(`orchestrate/SKILL.md` line 223; `epic-orchestrate` lines 184–203). The parallel child follows
the identical route with `origin/main` as the merge source.

**F5's boundary versus F8's (§13.1):**

- F5 does: mirror the child's terminal outcome into the item's `merge_status` (successful
  remediation → `merged`; exhausted loop → the blocked mapping per C.3); regenerate
  `parallel-status.md`; hold the cohort barrier (a blocked item is not `merged`, so cohort N+1
  does not start).
- F5 leaves to F8: recognizing the conflict as blast-radius under-report evidence, recording
  `drift_events[]`, quiescing admission, recomputing conflicts with the observed radius, halting
  and requeueing the later-started item (`blocked_drift`), per §7 steps 1–6. F5's skill text
  should state this hand-off in one sentence inside its conflict-handling section and otherwise
  not implement any of it.

### E.4 Cross-surface hook interactions F5 must document but not fix

Both epic Bash-matcher hooks are registered project-wide (`.claude/settings.json` lines 110–117)
and fail closed on commands a parallel run must issue:

1. `enforce-epic-merge-gate.ps1` denies any `gh pr merge --merge` without an epic-shaped
   checkpoint (see C.2).
2. `enforce-epic-worktree-removal-gate.ps1` denies any `git worktree remove` unless the **epic**
   checkpoint has a matching `features[]` record with safe `merge_status`; "checkpoint
   unreadable, no matching record" denies (hook lines 5–14, denial text line 220). A parallel
   run has no epic checkpoint record for its worktrees, so every parallel worktree removal would
   be denied by the existing hook even after F7 adds `enforce-parallel-worktree-removal-gate.ps1`
   (PreToolUse denials are conjunctive — a new allow-hook cannot override an existing deny).

Both are F7-scope resolutions (F7 already owns the worktree-removal and cohort-barrier hooks per
§9). F5's plan should include a coordination note so the F7 planner scopes the two epic hooks'
allow conditions (or their matching) for the parallel case. F5 itself writes no hook files and
modifies none.

### E.5 Enum note

See C.3: the §12 `merge_status` enum has no `merge_conflict` / `blocked_conflict_loop_limit`
values. During an in-flight conflict remediation the item legitimately remains `pr_open` (or
`ci_green`); only the exhausted-loop terminal needs the `blocked_ci_loop_limit` mapping.

## F. Wave-4 Sectioning Constraint

Evidence on delimiting and tooling: `epic-orchestrate/SKILL.md` uses flat `##` headings under one
`#` title; SearchScope: `scripts/**`, `tests/**`, `.claude/hooks/**`, `src/**`, `mcp-server/**`;
SearchPatterns: `epic-orchestrate`; SearchResult: eight files, none of which parse SKILL section
structure — matches are file-presence assertions in codex bundle tests
(`tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` lines 9–17, 135–143), prompt
recognition (`tests/scripts/codex-hooks/epic-provenance.Tests.ps1` lines 18–21), a settings list,
and docstring references. No tooling constrains heading names; the constraint is purely the
epic's decomposition rule (epic.md lines 152–159: distinct, explicitly named new sections; no
reflow of existing sections).

**Recommended top-level layout for `.claude/skills/parallel-orchestrate/SKILL.md`:**

F5-authored sections, in order:

1. YAML frontmatter (`context: fork`, `agent: parallel-orchestrator`)
2. `# Parallel Orchestrate Skill` (intro)
3. `## Prerequisites`
4. `## Parallel Manifest Consumption` (references F3's schema authority)
5. `## Cohort Consumption and Ordering`
6. `## Cohort Barrier and Max-Concurrency Slot Filling`
7. `## Per-Item Branch and Worktree Lifecycle`
8. `## Parallel-Mode Kickoff Parameter`
9. `## Model Selection`
10. `## Per-Item Merge to Main (Merge-on-Green)`
11. `## Per-Item Merge-Conflict Handling`
12. `## Worktree Cleanup`
13. `## Documentation Maintenance Boundaries` (`parallel-status.md`)
14. `## Parallel-Level Checkpoint`
15. `## Completion Requirements`

Reserved placeholder sections, authored by F5 as trailing `##` headings after
`## Completion Requirements`, each containing a single one-line body ("Reserved for F<N>; content
is appended by that feature and must not be relocated."):

16. `## Mutation Protocol (F6)` — `/parallel-add`, `/parallel-remove`, `/parallel-close`,
    admission control, pinning invariant, mutation log, abandon gate.
17. `## Enforcement Hooks (F7)` — cohort-barrier Layer 1/Layer 2, worktree-removal gate,
    invocation-origin extension, epic-hook allow-condition coordination (E.4).
18. `## Radius Drift Detection (F8)` — §7 procedure, drift gate, requeue.

Placing the three reserved sections last means each wave-4 feature appends `###` subsections
inside its own uniquely named `##` section without touching any F5 line, which keeps the three
concurrent wave-4 merges mechanical (epic.md lines 152–159). The seeded test condition
"reserved wave-4 placeholder sections are present and uniquely named" (spec.md lines 114) is
satisfiable by asserting these three exact headings.

## G. Upstream Contract Assumptions (F3 and F4 have NOT landed)

**Absence verification.**
SearchScope: entire worktree (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a3a2a828ce3d7d2fc`).
SearchPatterns: Glob `**/*parallel*`; Glob `scripts/dev_tools/*blast*`; Glob
`scripts/dev_tools/*cohort*`; Grep `parallel` in `config/orchestration-routing.json`.
SearchResult: the only `parallel`-named artifacts are the design document
(`docs/research/2026-08-07-parallel-orchestration-design-research.md`) and an unrelated completed
feature (`docs/features/completed/2026-07-03-parallel-ci-subworkflows-294/**`); no blast-radius or
cohort modules exist; `config/orchestration-routing.json` defines routes `small`, `large`,
`remediation`, `preparation`, `epic` only (lines 4–121) with no `parallel` route. Therefore
**none** of F1–F4 exists on this branch yet; F5's plan must consume the contracts below strictly
as specified by the design document, and verify F3/F4's landed artifacts at execution time
(waves 0–2 merge into the integration branch before F5's wave-3 execution).

Contracts F5 consumes and must NOT define or alter (F3 owns all schemas; F4 owns radius/cohort
seeding — epic.md lines 130–138, spec.md lines 72–78):

1. **Manifest (§11, design lines 248–272):** `docs/features/parallel/<slug>/parallel.md`
   frontmatter — `parallel: <slug>`, `mode: closed | open` (default `closed`),
   `max_concurrency: <int>` (default 4), `created_at`, `items[]` with `issue_num` (primary key),
   `feature_folder`, `kind`, `state` (§8.2 enum), and `blast_radius { paths, modules,
   shared_surfaces, contracts, source, computed_at }`. No `depends_on` field exists. F5 reads
   `mode`, `max_concurrency`, and per-item identity/state; it never writes the manifest.
2. **Checkpoint (§12, design lines 276–295):** F5 writes `objective`, `route_id: "parallel"`,
   `parallel_slug`, `parallel_manifest_path`, `parallel_status_doc_path`, `mode`,
   `max_concurrency`, `completed_steps`, `next_step`, `last_updated`, `current_cohort`,
   `recolor_generation`, `cohorts[] { index, generation, item_keys[] }`, `items[] { issue_num,
   feature_folder, state, blast_radius, worktree_path, branch_name, pr_number, pr_url,
   merge_status, merge_commit_sha, lifecycle timestamps }`, and the three receipt arrays.
   `merge_status` enum: `not_started`, `worktree_created`, `pr_open`, `ci_green`, `merged`,
   `worktree_removed`, `blocked_drift`, `blocked_ci_loop_limit`. Read-only to F5:
   `conflict_edges[] { a, b, reason }`, `mutations[]` (§8.6 shape), `drift_events[]` (§12
   line 287) — F5 projects them into `parallel-status.md` and never writes them
   (`blocked_drift` transitions are F8's; mutation entries are F6's).
3. **Cohort/coloring output (§6, design lines 111–129):** a deterministic partition of items
   into ordered independent sets (Welsh-Powell greedy coloring; descending degree, ties by
   ascending item key), serialized as `cohorts[]`. F4 seeds it; F5 consumes it and applies the
   barrier plus `max_concurrency` slot filling (ascending item key). F5 never recolors.
4. **`route_id: parallel`** in `config/orchestration-routing.json` — F3 deliverable (epic.md
   lines 190–197). F5's checkpoint records `route_id: "parallel"` and its receipts must satisfy
   whatever `required_agents` / `required_skills` / `required_mcp_tools` F3 ships (expected
   pattern per the `epic` route, config lines 100–121: agents `orchestrator`; skills
   `parallel-orchestrate`, `orchestrate`, plus shared skills; MCP `collect_pr_context`,
   `validate_orchestration_artifacts`).
5. **Open F4 contracts F5 depends on** (flag for the planner; resolve when F4 lands): (a) the
   kickoff artifact's name and committed location — the epic analogue is
   `docs/features/epics/<slug>/epic-kickoff.md` committed to the integration branch
   (`epic-plan/SKILL.md` lines 139–144); with no integration branch the parallel analogue is
   expected at `docs/features/parallel/<slug>/parallel-kickoff.md`, but *where* F4 commits it
   (directly to `main` via a docs PR, or a planning branch) is unspecified in the design; (b) the
   same question for prepared child feature folders and manifests — F5's cohort children branch
   from `origin/main` and must find their committed `plan-path` reachable from that tip.
   `parallel-run`'s discovery step (A.3, step 2) should be written against F4's landed behavior.
6. **Validator SubagentStop wiring:** the agent frontmatter hook reuses the parameterized
   `.claude/hooks/validate-orchestrator-output.ps1` with `-ArtifactType
   parallel-orchestrator-state` (epic precedent: `epic-orchestrator.md` line 32); the artifact
   type's dispatch is F3's MCP/validator wiring.

## H. Invocation-Origin Hook (read-only for F5)

`.claude/hooks/enforce-epic-invocation-origin.ps1`, registered on the Agent matcher
(`.claude/settings.json` line 186). Matching logic:

- Gated target set: `$script:GatedSubagentTypes = @('epic-planner', 'epic-orchestrator')`
  (line 36); prohibited caller: `$script:ProhibitedCallerAgentType = 'orchestrator'` (line 37).
- Decision (lines 197–229): resolve the target `subagent_type` from `CLAUDE_TOOL_INPUT` (fallback
  to the payload's `tool_input`); a non-gated target allows; then resolve the caller `agent_type`
  from `CLAUDE_HOOK_INPUT` — absent/empty means a main-thread invocation, which allows
  (lines 220–223); only a caller of exactly `orchestrator` denies, with reason
  `EPIC_INVOCATION_ORIGIN_BLOCKED` (line 228).

F7 extends the gated set to include `parallel-orchestrator` and `parallel-planner` (§9, design
lines 224–225). Compatibility obligations on F5 (no hook change):

1. The agent frontmatter `name:` must be exactly `parallel-orchestrator` — that string is the
   `subagent_type` the extended hook will match.
2. Both skills declare `context: fork` with `agent: parallel-orchestrator`, so `/parallel-run`
   and `/parallel-orchestrate` invocations originate from the main session (no `agent_type` in
   the payload → allow), matching the epic pattern (`epic-run/SKILL.md` lines 1–7).
3. The persona's `## Invocation Origin` section must instruct invocation from the main session
   only and must not instruct or imply delegation to `Agent(parallel-orchestrator)` from inside
   an `orchestrator` run (mirror of `epic-orchestrator.md` lines 68–76).

## Non-Negotiable Constraints — Verified Restatement

1. **Naming.** Surface is `parallel` throughout; the child kickoff marker is the literal
   `Parallel mode: true` (§9 design lines 212–215; epic.md lines 102–103). Verified consistent
   with the F7 hook precedent's exact-literal matching (D.1).
2. **No integration branch, final PR, or fan-in.** §4 (design lines 43–49); epic.md lines 91–93.
   The `## Epic Integration Branch Lifecycle`, `## Context Handoff`, and final-PR completion
   conditions drop (A.2). No parallel analogue of `enforce-epic-merge-gate.ps1` is built — with
   the caveat that the existing epic gate's child path must be coordinated in F7 (C.2, E.4).
3. **Same-tip branching, any-order merge.** §6 (design lines 123–124); non-conflicting by
   construction (independent set). Restated in E.2 with the branch-protection caveat.
4. **`max_concurrency`.** Caps fan-out independently of cohort size; slots filled in ascending
   item-key order (§6, design lines 127–129). New section, no epic precedent (A.2 `new` item 2).
5. **`mode: closed | open`, default `closed`; mode-dependent completion.** §3, §8.7 (design
   lines 26, 199–205); epic.md line 109.
6. **`parallel-status.md` is a generated projection only**, never the source of the schedule
   (B.3), mirroring the epic's generated-only contract (`epic-orchestrate` lines 243–245).
7. **Additive only.** `epic-orchestrator.md` and `epic-orchestrate/SKILL.md` are not modified
   (epic.md lines 94–96; spec.md lines 70–71, 115–116). This research proposes no change to
   either file. The one shared file recommended for additive extension is
   `orchestrate/SKILL.md` (C.2), which is outside the frozen set and has the epic feature's own
   additive extension as precedent.

## Behavior Semantics and Requirements Mapping

Proposed F5 state model (all state F3-schema-conformant):

- **Run-level:** `next_step` progression: manifest/kickoff consumption → cohort loop
  (per cohort: fetch `main` tip → launch up to `max_concurrency` items in ascending key order →
  refill slots as items merge → barrier) → completion (closed mode) or standing queue (open
  mode). `current_cohort` increments only when every cohort-N item is `merged` or
  `worktree_removed` (durably confirmed via git/gh, not in-memory notifications — epic precedent
  `epic-orchestrate` lines 223–226).
- **Item-level `merge_status` transitions written by F5:** `not_started` → `worktree_created`
  (spawn) → `pr_open` (child reports S8) → `ci_green` (child reports S9 pass) → `merged`
  (child's `parallel_merge.merge_commit_sha` mirrored) → `worktree_removed` (after gated
  removal). `blocked_ci_loop_limit` mirrors a child's terminal blocked status. `blocked_drift`
  is written only by F8.
- **File changes proposed for the planner:** new `.claude/agents/parallel-orchestrator.md`; new
  `.claude/skills/parallel-orchestrate/SKILL.md` (layout per F); new
  `.claude/skills/parallel-run/SKILL.md`; additive `parallel_mode` extension to
  `.claude/skills/orchestrate/SKILL.md` (S9 clause, `parallel_merge` schema, PR-gate condition —
  C.2); optional `docs/features/templates/parallel/parallel-status.md` template; contract tests
  (below). No hook files; no epic files; no schema/validator files; no config route.

## Testing Implications

Repository precedent for testing markdown runtime surfaces is Python contract tests over
`.claude` content: `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py`
(asserts `epic-run` skill content), `test_legacy_discovery_skills_contracts.py`,
`test_orchestration_guardrail_contracts.py`, and the Pester structure suite
`tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1`. Proposed strategy (no test
code here):

1. A `test_parallel_orchestrator_surface_contracts.py` (location mirroring the precedent under
   `tests/scripts/dev_tools/`) asserting the seeded conditions from spec.md lines 107–118:
   existence and required frontmatter of the three delivered files; the literal
   `Parallel mode: true` marker in the kickoff-parameter section; presence and uniqueness of the
   three reserved wave-4 headings; absence of the strings `integration_branch`,
   `epic-merge-gate`, and fan-in merge language in the delivered files (scoped to the new files,
   since the skill legitimately names epic files when documenting deltas — the assertion should
   target prescriptive text, e.g., forbid `--base epic/` and `integration-to-main`).
2. Epic-surface immutability: assert `epic-orchestrator.md` and `epic-orchestrate/SKILL.md`
   contain no `parallel` markers and match their current content hashes recorded at plan time
   (byte-identity per spec.md lines 115–116; a hash-pinned assertion is deterministic and needs
   no git dependency in-test).
3. Cohort-barrier and slot-filling order are documented procedures executed by an agent, not
   library code; their testable surface in F5 is the skill text (contract tests). Behavioral
   enforcement tests belong to F7 (hooks, validator invariant) and F2 (scheduler parity).
4. If the `orchestrate/SKILL.md` additive extension is accepted into scope, extend the existing
   routing/guardrail contract tests' expectations only where they assert S9/PR-gate text, keeping
   all epic assertions untouched.

## Automation Feasibility

Assessment per the autonomous-execution mandate (`.claude/skills/orchestrate/SKILL.md`
lines 49–77):

- **F5 deliverables themselves** (markdown agent/skill files, contract tests, status-doc
  generation) require no human interaction to author, test, or merge.
- **`gh pr merge` against `main`:** non-interactive when a merge-method flag is supplied
  (`--merge`), which is the repository's established unattended pattern — the epic surface
  already executes `gh pr merge --merge` into `main` for integration PRs without human
  interaction (`epic-orchestrate/SKILL.md` line 119; demonstrated by the completed
  `legacy-discovery-and-parity` epic, whose final integration PR #388 merged with the merge
  commit recorded in `docs/features/epics/legacy-discovery-and-parity/epic-status.md`
  lines 27–30). Evidence therefore indicates current branch protection on `main` permits
  automated merges once required checks are green and imposes no interactive approval step.
  Residual unknowns, verifiable unattended at execution time via
  `gh api repos/<owner>/<repo>/branches/main/protection`: (a) whether "require branches to be up
  to date" is enabled — if so, any-order merging within a cohort requires an automated
  `gh pr update-branch` + re-green cycle between merges (still unattended, but it serializes
  same-cohort merges in practice); (b) required-review settings — the release PR flow has a
  documented human-approval runbook
  (`docs/features/completed/separate-version-bump-from-publish-214/runbooks/release-pr-merge-approval.runbook.md`),
  but feature PRs merged by the epic surface show no such requirement.
- **Known automation blockers, machine-resolvable, F7-scope:** the existing
  `enforce-epic-merge-gate.ps1` and `enforce-epic-worktree-removal-gate.ps1` Bash hooks fail
  closed against parallel-run merge and worktree-removal commands (C.2, E.4). These are not
  human-interaction requirements; they are sequencing constraints resolved by F7 (wave 4) before
  the parallel surface is used end-to-end. No `human_interaction.requirements[]` entry is needed
  for F5; the F5 plan should carry the F7 coordination note instead.

**Conclusion: no step of F5 requires human interaction.** No `scope_change`, `exception`, or
`halt` response is required.

## Rejected Alternatives (summary)

- **Prompt-only merge-on-green (no `orchestrate/SKILL.md` change):** rejected — leaves DONE
  ungated on the per-item merge and the child checkpoint fields undocumented (C.2).
- **F5 computes or recomputes cohorts:** rejected — F4 seeds cohorts from F2's reference
  implementation; recoloring is F6/F8 (pinning invariant §8.1). F5 is a consumer only.
- **Generalizing epic files into a shared abstraction:** rejected by the epic's explicit
  non-goal (epic.md lines 94–96); reuse is by near-verbatim adaptation into new
  `parallel`-named files.
- **Extending the `merge_status` enum with conflict states:** rejected — F3 owns the schema;
  F5 maps the conflict loop-limit terminal onto the F3-owned enum (C.3).

## Open Items for the Planner

1. Scope decision: additive `parallel_mode` extension of `.claude/skills/orchestrate/SKILL.md`
   in F5 (recommended, C.2) — not currently named in spec.md's Behavior list.
2. F7 coordination notes: (a) extend `enforce-epic-merge-gate.ps1` allow conditions for the
   `parallel_mode` child path; (b) scope `enforce-epic-worktree-removal-gate.ps1` for parallel
   worktrees (E.4). Neither is currently listed in §9 or the F7 scope (epic.md lines 221–228).
3. F4-dependent contracts to pin when F4 lands: kickoff-artifact name/location and the commit
   destination of prepared folders (G.5); `parallel-run` step 2 discovery written against it.
4. Verify F3's landed `merge_status` enum before finalizing the conflict-terminal mapping (C.3).
