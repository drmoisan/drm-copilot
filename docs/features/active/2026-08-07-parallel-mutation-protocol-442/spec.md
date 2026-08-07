# 2026-08-07-parallel-mutation-protocol — Spec

- **Issue:** #442
- **Parent (optional):** Epic `parallel-orchestration` (`docs/features/epics/parallel-orchestration/epic.md`, child feature F6, wave 4)
- **Owner:** drmoisan
- **Last Updated:** 2026-08-07T11-11
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** full-feature
- **Design source:** `docs/research/2026-08-07-parallel-orchestration-design-research.md` (§8 in full, §9 abandon gate; consumed structures §5.4, §6, §11, §12)
- **Research artifact:** `docs/features/active/2026-08-07-parallel-mutation-protocol-442/research/2026-08-07-parallel-mutation-protocol-research.md`

## Overview

The `parallel` orchestration surface (epic `parallel-orchestration`) schedules multiple
independent bugs and features into concurrent cohorts computed from blast-radius contention.
Unlike the epic surface, the item set is mutable mid-execution: items can be added to a live
run, removed from it, and an `open`-mode run must be explicitly terminable. The epic surface
has no analogue for dynamic membership, so this capability must be built new. Without it, a
parallel run's membership is frozen at plan time and any change requires abandoning the run.

Mutable membership also introduces an auditability requirement epics do not have: a cohort
table that changes must be traceable rather than silently rewritten.

F6 delivers the mutation protocol: the slash commands `/parallel-add`, `/parallel-remove`, and
`/parallel-close`; admission control; the pinning invariant; the item lifecycle; the mutation
log; mode-dependent completion semantics; and the abandon gate from design §9. Per the research
recommendation, all decision logic is implemented as a pure-Python mutation engine; the slash
commands are thin fork-routed skills; the abandon gate is a PreToolUse Bash hook; and F6's
validator contribution is one isolated helper module with a single additive call site in the
F3-owned validator.

## Behavior

### FR1 — `/parallel-add <issue|potential-entry>` (design §8.3)

1. The item enters state `proposed`.
2. The item is prepared via a preparation-mode child `Agent(orchestrator)` run — promotion,
   research, `spec.md`, `user-story.md`, atomic plan, preflight clearance — reusing the existing
   `route_id: preparation` contract unchanged (verified landed:
   `config/orchestration-routing.json` and `.claude/skills/epic-plan/SKILL.md` lines 97–122).
   Preparation yields the declared blast radius.
3. Conflict edges are computed against ALL items, including in-flight ones, using F1's
   `conflicts(a, b)` relation (expected contract; see Upstream Contracts).
4. Admission decision:
   - No conflict with any in-flight item: admit into the current cohort. No recompute occurs.
   - Otherwise: defer to a future cohort and recolor the unstarted subgraph (recompute;
     `recolor_generation` increments by exactly one).

The item's lifecycle transitions during the add procedure follow §8.2
(`proposed -> admitted -> prepared -> scheduled`); the add op appends exactly one `mutations[]`
entry at admission-decision time (see Recompute Boundary and Mutation-Log Entry Contents).

### FR2 — `/parallel-remove <item> [--disposition detach|abandon]` (design §8.4)

The state-dependent behavior table is normative and must be implemented exactly:

| Item state | Behavior |
| --- | --- |
| `proposed`, `admitted`, `prepared`, `scheduled` | Mark `withdrawn`, drop the vertex, recolor the unstarted subgraph (recompute). |
| `in_flight` | **Reject** unless `--disposition` is supplied. A default disposition is never inferred. |
| `in_flight` with `--disposition detach` | Let the item finish and merge on its own; the run stops tracking it. No recompute. |
| `in_flight` with `--disposition abandon` | Close the PR, remove the worktree, mark `withdrawn`. Destructive; hook-gated (FR8). No recompute. |
| `merged` | Reject; the change is already in `main`. |

Spec decisions within F3's expected state enum (no new enum values may be added):

- `detach` records item state `withdrawn` with `disposition: "detach"` in the mutation entry.
  Rationale: both dispositions end the run's tracking of the item; the `disposition` field
  disambiguates them, and the `closed`-mode completion predicate (FR7) correctly excludes
  withdrawn items so the run does not wait for a detached item. This mapping must be re-verified
  against F3's landed schema.
- The abandon side effects (`gh pr close`, `git worktree remove`) must be routed through a
  single deterministic CLI invocation of the mutation engine's entry point, so the abandon gate
  (FR8) has a deterministic match target. Executing the abandon disposition through ad hoc
  `gh`/`git` commands is prohibited by the procedure documented in the SKILL section.

Rejected removals (`in_flight` without disposition, `merged`) fail fast with a specific error,
append no `mutations[]` entry, and make no state change.

### FR3 — `/parallel-close <slug>` (design §8.5)

Terminates an `open`-mode run. Rejected while any item is `in_flight`; a rejected close appends
no `mutations[]` entry and makes no state change. A successful close appends one run-scoped
`mutations[]` entry (see the entry-contents table) and does not recompute.

### FR4 — Pinning invariant (design §8.1)

**In-flight items are pinned; scheduling is recomputed only over the not-yet-started subgraph;
recoloring is a pure function of `(remaining subgraph, pinned set)`.**

This is the core correctness property of the feature. Requirements:

- The recolor function takes the induced subgraph of unstarted items (states
  `proposed | admitted | prepared | scheduled`), the pinned set (states `in_flight`), and the
  current generation; it returns cohort assignments for unstarted items only and never assigns
  or moves a pinned item.
- Coloring delegates to F2's Welsh-Powell entry point in
  `scripts/dev_tools/parallel_cohort_computation.py` (expected contract; see Upstream
  Contracts). F6 must not reimplement the coloring.
- The function is pure: no file I/O, no wall-clock reads, no mutation of inputs. Identical
  inputs produce identical outputs.
- Proving this invariant under mutation against a live in-flight set is the primary test
  obligation of the feature: determinism and property-based tests are required (see Test
  Strategy).

### FR5 — Item lifecycle (design §8.2)

```
proposed -> admitted -> prepared -> scheduled -> in_flight -> merged
                                                     |
                                          withdrawn / blocked
```

State values are F3's item-state enum
(`proposed | admitted | prepared | scheduled | in_flight | merged | withdrawn | blocked`). A
drift-induced requeue sets item state `blocked` and per-item `merge_status` `blocked_drift`
(design §7 step 5, §12 enum), subject to re-verification against F3's landed field semantics.

### FR6 — Mutation log (design §8.6)

Every add, remove, close, and drift-induced requeue appends exactly one `mutations[]` entry
with the F3-owned shape
`{ op, item_key, at, prior_state, new_state, disposition, recolor_generation }`.
`recolor_generation` increments on each recompute. The recompute boundary and per-op entry
contents are specified below. The `at` timestamp is supplied through an injectable clock seam;
the engine never reads the wall clock.

### FR7 — Mode-dependent completion semantics (design §8.7)

- `closed` (default): the completion gate fires when every non-withdrawn item is `merged` or
  `worktree_removed` (evaluated over per-item `merge_status`; re-verify field semantics against
  F3's landed schema). Mid-execution mutation remains permitted in `closed` mode.
- `open`: never auto-completes; the run terminates only via `/parallel-close`.

The completion predicate is a pure function in the mutation engine. The validator helper (FR9)
enforces the corresponding invariant: an `open`-mode checkpoint must not record
auto-completion, and a `closed`-mode checkpoint recording completion must satisfy the
predicate.

### FR8 — Abandon gate (design §9)

A PreToolUse hook `.claude/hooks/enforce-parallel-abandon-gate.ps1` on the `Bash` matcher:

- Denies any command carrying `--disposition abandon` that does not also carry the explicit
  confirmation marker, with deny reason code prefix `PARALLEL_ABANDON_BLOCKED`.
- Allows the command when the confirmation marker is present in the same command.
- Allows commands out of scope (no `--disposition abandon`).
- Fails fast (throws) on malformed `CLAUDE_TOOL_INPUT` JSON.
- The confirmation marker is an explicit token in the same command (proposed:
  `--confirm-abandon`; exact token fixed at plan time and documented in the `parallel-remove`
  SKILL and the `## Mutation Protocol` section).
- Registration: one additive entry in the existing `PreToolUse` → `Bash` matcher `hooks` array
  in `.claude/settings.json` (pattern: the epic Bash-matcher gates).
- Implementation follows `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` near-verbatim:
  injectable read seam, allow/block decision builders emitting
  `hookSpecificOutput.permissionDecision`, dot-source guard for Pester coverage.

The gate is assigned to F6 rather than F7 because it enforces the `--disposition abandon`
contract this feature defines.

### FR9 — Validator helper

`scripts/dev_tools/_parallel_orchestrator_state_mutations.py` (F6-owned, new), wired into the
F3-owned `scripts/dev_tools/validate_parallel_orchestrator_state.py` by a single additive
import and one call line, following the `_orchestrator_state_*.py` convention documented in
`.claude/rules/orchestrator-state.md`. Invariants enforced (key-gated; a checkpoint without the
relevant keys validates as before):

1. Mutation-entry shape: each `mutations[]` entry carries the seven §8.6 fields.
2. `recolor_generation` is monotonically non-decreasing across `mutations[]` in append order,
   which makes a lost update detectable retrospectively.
3. The mode-dependent completion invariant per FR7.

The helper returns literal error strings in the existing validator message style and never
mutates its input.

### FR10 — Slash-command surface

Three separate skill folders, one per command, following the verified frontmatter convention
(`name`, `description`, `argument-hint`, `context: fork`, `agent: parallel-orchestrator`):

- `.claude/skills/parallel-add/SKILL.md` — `argument-hint: "[issue|potential-entry]"`
- `.claude/skills/parallel-remove/SKILL.md` — `argument-hint: "[item] [--disposition detach|abandon]"`
- `.claude/skills/parallel-close/SKILL.md` — `argument-hint: "[parallel-slug]"`

Fork-routed skills are injected at invocation, so F6 does not edit the F5-owned
`parallel-orchestrator` agent frontmatter. Each command re-derives durable state
(`git worktree list --porcelain`, `git branch`, `gh pr view`) before applying a mutation, per
the design §12 rule that the checkpoint is a cache of durable state, not the source of truth.

## Recompute Boundary and Mutation-Log Entry Contents

This section resolves the clarification flagged by the research artifact (Risks item 4):
design §8.6 states that `recolor_generation` "increments on each recompute", while §8.3
admission into the current cohort performs no recompute. The boundary below is normative.

### Operations that trigger a recompute (`recolor_generation` increments by exactly one)

1. **Deferred add** — `/parallel-add` where the candidate conflicts with an in-flight item; the
   unstarted subgraph (including the new item) is recolored.
2. **Remove of an unstarted item** — `/parallel-remove` on a `proposed`, `admitted`,
   `prepared`, or `scheduled` item; the vertex is dropped and the remaining unstarted subgraph
   is recolored.
3. **Drift-induced requeue** — the later-started item of a newly conflicting pair is halted and
   requeued into a future cohort (design §7 step 5; the requeue is invoked by F8, issue 446,
   through F6's append/recolor contract).

### Operations that do not trigger a recompute (generation unchanged)

1. **Admission into the current cohort with no in-flight conflict** — the item joins the
   current cohort; no cohort assignment changes.
2. **`detach`** — the detached item was pinned and is not a vertex in the unstarted subgraph;
   its departure does not change the induced unstarted subgraph.
3. **`abandon`** — same rationale as `detach`: the abandoned item was pinned, not a vertex in
   the unstarted subgraph. An unstarted item previously deferred because of a conflict with the
   now-abandoned item retains its deferred cohort assignment; the assignment remains valid
   (only potentially conservative), and no opportunistic recompute is performed. This keeps
   generation accounting minimal and deterministic.
4. **`close`** — run termination changes no cohort assignment.

Non-recompute operations still append exactly one `mutations[]` entry, stamping the **current**
(unchanged) `recolor_generation` into the entry.

### Per-op entry contents

| Op case | `op` | `item_key` | `prior_state` | `new_state` | `disposition` | `recolor_generation` |
| --- | --- | --- | --- | --- | --- | --- |
| Add, no-conflict admit | `add` | item key | `prepared` | `scheduled` | null | `g` (unchanged) |
| Add, deferred | `add` | item key | `prepared` | `scheduled` | null | `g + 1` |
| Remove, unstarted | `remove` | item key | prior state (`proposed`/`admitted`/`prepared`/`scheduled`) | `withdrawn` | null | `g + 1` |
| Remove, `detach` | `remove` | item key | `in_flight` | `withdrawn` | `detach` | `g` (unchanged) |
| Remove, `abandon` | `remove` | item key | `in_flight` | `withdrawn` | `abandon` | `g` (unchanged) |
| Close | `close` | null (run-scoped) | null | null | null | `g` (unchanged) |
| Drift-induced requeue | `requeue` | item key | `in_flight` | `blocked` | null | `g + 1` |

Notes:

- Rejected operations (in-flight remove without disposition, merged remove, close while any
  item is in flight) append no entry and make no state change.
- The add op appends its single entry at admission-decision time; the earlier lifecycle
  transitions (`proposed -> admitted -> prepared`) are recorded as item-state updates with
  lifecycle timestamps in `items[]` (F3 fields), not as separate mutation entries.
- The `op` value vocabulary (`add | remove | close | requeue`) and the nullability of
  `item_key`, `prior_state`, `new_state`, and `disposition` must be re-verified against F3's
  landed `mutations[]` schema; if F3 constrains these differently, the landed shape wins and
  this table is updated at plan time.
- A sequence of N mutation operations starting at generation `g` ends at exactly
  `g + (number of recompute-triggering operations)`.

## Inputs / Outputs

- Inputs: slash-command arguments (`/parallel-add <issue|potential-entry>`,
  `/parallel-remove <item> [--disposition detach|abandon]`, `/parallel-close <slug>`); the
  parallel checkpoint `artifacts/orchestration/parallel-orchestrator-state.json` (F3-owned
  schema); durable git/gh state re-derived before each mutation.
- Outputs: updated checkpoint fields F6 is permitted to populate (`mutations[]`, item `state`,
  `recolor_generation`, `cohorts[].generation`); PR-close and worktree-removal side effects for
  `abandon`; validator error strings from the FR9 helper.
- Config keys and defaults: none added. `mode` (`closed | open`, default `closed`) and
  `max_concurrency` (default 4) are F3-owned and consumed, not defined, by F6.
- Backward compatibility: the FR9 validator invariants are key-gated; a checkpoint without the
  relevant keys validates exactly as before.

## API / CLI Surface

Expected engine shapes (final names fixed at plan time; normative in intent):

```python
def recolor_unstarted(
    unstarted_items: Sequence[str],            # item keys, state in {proposed..scheduled}
    conflict_edges: Sequence[tuple[str, str]], # full graph; induced subgraph taken internally
    pinned: frozenset[str],                    # item keys with state in_flight
    current_generation: int,
) -> RecolorResult:                            # cohorts for unstarted items only,
    ...                                        # generation == current_generation + 1

def decide_admission(
    candidate: str,
    conflict_edges: Sequence[tuple[str, str]], # computed over ALL items incl. in-flight
    in_flight: frozenset[str],
) -> AdmissionDecision:                        # ADMIT_CURRENT_COHORT | DEFER_AND_RECOLOR

def is_closed_mode_complete(items: Mapping[str, ItemRecord]) -> bool: ...
```

Value objects (`RecolorResult`, `AdmissionDecision`, `ItemRecord`) are frozen dataclasses. The
clock is injected (`clock: Callable[[], datetime]`) wherever a `mutations[].at` timestamp is
constructed. A thin CLI entry point wraps the engine for the abandon path so the abandon gate
has a deterministic match target (FR2, FR8).

## Data & State

- Data transformations and invariants: item-state transitions per FR5; cohort assignments per
  FR4 (pure recolor over the unstarted subgraph); the append-only `mutations[]` log per FR6
  with the recompute boundary above; the completion predicate per FR7.
- Persistence: the checkpoint is a cache of durable state; each mutation command re-derives
  worktree, branch, and PR state before applying (design §12).
- Migration or backfill: none. All invariants are additive and key-gated.

## Deliverables (file inventory)

All new unless noted:

- `scripts/dev_tools/parallel_mutation_protocol.py` — pure mutation engine (split into a second
  module before approaching the 500-line cap), plus its thin CLI entry point for the abandon
  path.
- `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` — validator helper (FR9).
- `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-remove/SKILL.md`,
  `.claude/skills/parallel-close/SKILL.md` — slash-command skills (FR10).
- `.claude/hooks/enforce-parallel-abandon-gate.ps1` — abandon gate (FR8).
- `.claude/settings.json` — one additive Bash-matcher hook registration entry (shared surface;
  see the wave-4 section).
- `.claude/skills/parallel-orchestrate/SKILL.md` (F5-owned) — one appended
  `## Mutation Protocol` section only (see the wave-4 section).
- `scripts/dev_tools/validate_parallel_orchestrator_state.py` (F3-owned) — one additive import
  plus one call line only (see the wave-4 section).
- Tests: `tests/scripts/dev_tools/test_parallel_mutation_protocol.py`,
  `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutations.py`,
  `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1`.

## Non-Negotiable Constraints

1. **Pinning invariant.** In-flight items are pinned; scheduling is recomputed only over the
   not-yet-started subgraph; recoloring is a pure function of
   `(remaining subgraph, pinned set)`. Determinism under mutation is what the tests must prove.
2. **No default disposition.** Removal of an `in_flight` item is rejected without an explicit
   `detach | abandon` disposition. A default is never inferred (accepted decision, design §3).
3. **Traceability.** `recolor_generation` exists so that a changing cohort table is traceable,
   not silently rewritten. Every mutation appends to `mutations[]`; the generation is monotone
   non-decreasing across the log.
4. **Naming.** The surface is named `parallel` throughout: skills, hook filename, module names,
   error prefixes.
5. **Additive only.** Existing epic implementations (`enforce-epic-*` hooks, epic validators,
   epic skills and agents) are not modified or refactored.
6. **No schema fields.** F3 (issue 444) owns the complete checkpoint schema including
   `mutations[]`; F6 populates `mutations[]`, item `state`, `recolor_generation`, and
   `cohorts[].generation` but adds no fields and no enum values.
7. **Wave-4 contention constraint** — see the next section, which is mandatory in its own
   right.

## Wave-4 Contention Constraint (Mandatory)

F6 executes concurrently with F7 (`parallel-enforcement-hooks`, issue 440) and F8
(`parallel-drift-detection`, issue 446). All three extend
`.claude/skills/parallel-orchestrate/SKILL.md` and, to a lesser degree,
`scripts/dev_tools/validate_parallel_orchestrator_state.py`. This is a decomposition constraint
from the epic manifest, not a suggestion: it is what keeps wave-4 fan-in merges mechanical.

F6's edits to shared files must be confined as follows and must NOT reflow or reorder existing
sections:

| Shared file | Owner | F6's confinement |
| --- | --- | --- |
| `.claude/skills/parallel-orchestrate/SKILL.md` | F5 (issue 441) | Append exactly one new section, named `## Mutation Protocol`, containing the add/remove/close procedures, the pinning invariant, the recompute boundary, mutation-log and completion semantics, the abandon confirmation-marker contract, and pointers to the three slash-command skills. Append-only; no edits inside existing sections. If F5's landed SKILL reserves a differently named placeholder section for F6, the landed name wins (re-verify per Upstream Contracts). |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | F3 (issue 444) | One additive import plus one call line delegating to the F6-owned helper module `scripts/dev_tools/_parallel_orchestrator_state_mutations.py`. All F6 invariant logic lives in the helper module. |
| `.claude/settings.json` | shared | One additive entry in the existing `PreToolUse` → `Bash` matcher `hooks` array registering `enforce-parallel-abandon-gate.ps1`. F7 appends to the same arrays; the atomic plan must name the exact insertion point to keep the fan-in merge clean. |

F3 owns the complete checkpoint schema including `mutations[]`, `drift_events[]`, and
`conflict_edges[]`; F6 populates the structures it consumes and must not add schema fields.

## Upstream Contracts (expected, not yet landed)

At authoring time, waves 0–3 (F1 issue 447, F2 issue 445, F3 issue 444, F4 issue 443, F5 issue
441) have NOT landed on the integration branch (verified by the research artifact via glob over
`scripts/dev_tools/`, `.claude/skills/`, `.claude/agents/`, and `docs/features/`). The
contracts below are derived from the design document and are marked **expected, not yet
landed**. If any landed shape differs, the landed shape wins.

| Feature (issue) | Expected contract F6 consumes | Design source | Status |
| --- | --- | --- | --- |
| F1 (447) | `conflicts(a, b) = path_overlap OR module_overlap OR shared_surface_overlap OR contract_dependency`, fail-closed, in `scripts/dev_tools/compute_blast_radius.py`. Used by FR1 step 3. | §5.4, §8.3 | Expected, not yet landed |
| F2 (445) | Deterministic greedy Welsh-Powell coloring entry point in `scripts/dev_tools/parallel_cohort_computation.py` (descending degree, ascending-item-key tie-break; `max_concurrency` slot-filling in ascending item key). FR4 delegates to it and does not reimplement it. | §6 | Expected, not yet landed |
| F3 (444) | Checkpoint schema at `artifacts/orchestration/parallel-orchestrator-state.json`: `mode`, `max_concurrency`, `current_cohort`, `recolor_generation`, `cohorts[]` (`{ index, generation, item_keys[] }`), `items[]` (state enum, `merge_status` enum incl. `worktree_removed` and `blocked_drift`), `conflict_edges[]`, `mutations[]` (`{ op, item_key, at, prior_state, new_state, disposition, recolor_generation }`), `drift_events[]`; validator `scripts/dev_tools/validate_parallel_orchestrator_state.py`. | §8.6, §11, §12 | Expected, not yet landed |
| F4 (443) | `parallel-planner` surface; F6 makes no direct call into F4. The preparation contract both reuse (`route_id: preparation`) is verified landed. | §10 | Expected, not yet landed |
| F5 (441) | `parallel-orchestrator` agent (`.claude/agents/parallel-orchestrator.md`), `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/skills/parallel-run/SKILL.md`, checkpoint-driven cohort scheduling and fan-out. Expected to reserve named placeholder sections for wave-4 extenders; the reserved names cannot be cited until F5 lands. | §10 | Expected, not yet landed |

Verified landed in this worktree (research artifact, "Landed" table): the
`route_id: preparation` child-run contract (`config/orchestration-routing.json`;
`.claude/skills/epic-plan/SKILL.md` lines 97–122), the slash-command skill frontmatter
convention, the PreToolUse hook registration surface in `.claude/settings.json`, and the
validator helper-module convention.

**Precondition (blocking) for the atomic plan:** before execution begins, the atomic plan must
re-verify the landed contracts against the integration branch head, at minimum:

1. F5's reserved section names in `.claude/skills/parallel-orchestrate/SKILL.md` (adopt the
   landed name for the `## Mutation Protocol` section if one is reserved).
2. F3's `mutations[]` schema shape, including the `op` vocabulary and field nullability
   (per-op entry-contents table above).
3. F1's `conflicts(a, b)` signature.
4. F2's Welsh-Powell recoloring entry point signature.

Any divergence between the expected and landed shapes is resolved in favor of the landed shape
and recorded in the plan.

## Constraints & Risks

1. **All upstream contracts are unverified expectations.** Mitigated by the blocking
   re-verification precondition above.
2. **`hypothesis` is not a dev dependency** at authoring time, while the property-test
   obligation applies. Resolution rule: check at plan time whether F2 (wave 0) added
   `hypothesis` to `[tool.poetry.group.dev.dependencies]`; if yes, use it; if no, use
   seeded-RNG randomized graph generation via `random.Random(seed)` with the seed printed on
   failure (permitted by the determinism rules) and record the deviation.
3. **`.claude/settings.json` append collision with F7.** Both append to the same `PreToolUse`
   arrays. The atomic plan must name the exact insertion point.
4. **Checkpoint read-modify-write races.** The engine is pure, so the race moves to the forked
   slash-command runs. Mitigations specified: each mutation command re-derives durable state
   before applying (FR10), and the validator's generation-monotonicity invariant (FR9) makes a
   lost update detectable retrospectively. Whether a stronger exclusion (rejecting mutation
   commands mid-cohort-launch) is needed is deferred; it is not required for this feature's
   acceptance.
5. **Tier classification.** `quality-tiers.yml` does not exist at the repo root (F1's known
   constraint). The engine is treated as T1/T2 rigor regardless (see Quality Obligations).
6. **Abandon-gate matching surface.** The gate is textual; it is effective because FR2 requires
   the abandon disposition to be routed through a single deterministic CLI invocation.
7. **Live-mutation concurrency.** The pinning invariant and `recolor_generation` accounting
   must hold against a live, concurrently mutating set of in-flight items; this has no
   in-repository prior art. The pure-engine design plus the property tests (P1–P3) are the
   compensating controls.

## Implementation Strategy

- Implementation scope: the file inventory above. All decision logic in the pure engine; skills
  and hook are thin surfaces; validator logic isolated in the helper module.
- New functions: `recolor_unstarted`, `decide_admission`, per-state removal decision, close
  gating, `is_closed_mode_complete`, mutation-entry construction; frozen dataclass value
  objects; CLI entry point for the abandon path.
- Dependency changes: none by default. `hypothesis` only if already added upstream by F2
  (Constraints & Risks item 2); otherwise no dependency change.
- Logging: engine raises specific exceptions for rejected operations (dedicated exception types
  carrying the offending key, per the `epic_wave_computation.py` pattern); validator helper
  returns literal error strings.
- Rollout: no feature flags. The validator invariants are key-gated and backward compatible;
  the hook is additive.

## Quality Obligations

### Python (`parallel_mutation_protocol.py`, `_parallel_orchestrator_state_mutations.py`)

- Toolchain clean in a single pass: Black, Ruff, Pyright.
- Pytest with line coverage >= 85% and branch coverage >= 75%
  (`poetry run pytest --cov --cov-branch --cov-report=term-missing`).
- Tests under `tests/` mirroring source:
  `tests/scripts/dev_tools/test_parallel_mutation_protocol.py`,
  `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutations.py`.
- Property-based determinism tests for the pure recoloring/admission functions (Test Strategy).
- 500-line cap on every production and test file; split the engine before approaching it.
- Full type hints; frozen dataclasses for value objects; injectable clock seam; no file I/O in
  the pure engine.

### PowerShell (`enforce-parallel-abandon-gate.ps1`)

- PoshQC format and PSScriptAnalyzer clean.
- Pester tests at `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1`,
  following the pattern of
  `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1` (dot-source the
  hook, mock the read seam with literal JSON, no temp files, no live git).
- Deny-with-reason-code behavior: reason code prefix `PARALLEL_ABANDON_BLOCKED`.
- Dot-source guard so the hook body is coverable without executing the entry point.

### Cross-cutting

- No temporary files in any test. Deterministic tests only: injected clock for timestamps;
  seeded RNG with printed seed for any randomized graph generation.
- Treat the mutation engine as T1/T2 rigor for the property-test obligation (>= 1 property test
  per pure function), regardless of the `quality-tiers.yml` state.

## Test Strategy

Unit tests (pytest):

1. **Pinned items never move.** With in-flight items and unstarted items, the `RecolorResult`
   contains no assignment for any pinned item, and applying the result leaves pinned items'
   states and current-cohort membership unchanged.
2. **Purity and determinism.** Two calls with equal inputs return equal outputs; inputs are
   unmutated.
3. **Generation accounting.** Each recompute-triggering op yields `generation == g + 1`; each
   non-recompute op leaves the generation unchanged and stamps the current generation into its
   entry; a sequence of N ops from generation `g` ends at exactly
   `g + (number of recompute-triggering ops)`.
4. **Admission over ALL items.** A candidate conflicting only with an in-flight item is
   deferred; a candidate conflicting only with an unstarted item is placed by the coloring, not
   rejected; a candidate with no conflicts is admitted into the current cohort with no
   generation change.
5. **Removal behavior table** (FR2): one test per row, including rejection without disposition
   for `in_flight` and rejection for `merged`; disposition never defaulted.
6. **Close gating** (FR3): rejected while any item is `in_flight`; terminates `open` mode
   otherwise.
7. **Completion predicate** (FR7): `closed`-mode predicate fires only when every non-withdrawn
   item is `merged` or `worktree_removed` (parametrized over the `merge_status` enum); `open`
   mode never auto-completes.
8. **Mutation-log shape**: every op appends exactly one entry with the seven §8.6 fields; `at`
   from the injected clock; rejected ops append nothing.

Property-based tests (>= 1 per pure function):

- **P1 (determinism):** for arbitrary conflict graphs and arbitrary pinned/unstarted
  partitions, `recolor_unstarted(x) == recolor_unstarted(x)`; every unstarted vertex is
  assigned to exactly one cohort; no pinned vertex is assigned to any cohort.
- **P2 (independent-set validity):** no two items in the same recolored cohort share a conflict
  edge.
- **P3 (pin stability under mutation sequences):** for an arbitrary sequence of add/remove ops,
  items in flight at op time never change cohort or state as a result of the op.

Validator-helper tests (pytest): mutation-entry shape errors, generation-monotonicity violation
detection, the mode-dependent completion invariant, and backward compatibility (a checkpoint
without the relevant keys produces no new errors).

Hook tests (Pester): deny with `PARALLEL_ABANDON_BLOCKED` when `--disposition abandon` appears
without the confirmation marker; allow with the marker; allow out-of-scope commands; throw on
malformed JSON.

Integration scenarios (fixture-driven, no live git/gh): add during an active cohort with and
without in-flight conflicts; remove at each lifecycle state; close on an `open`-mode run.

## Acceptance Criteria

- [ ] `scripts/dev_tools/parallel_mutation_protocol.py` exists and implements the recolor, admission, removal, close, generation-accounting, mutation-log-entry, and completion functions as pure functions (no file I/O, no wall-clock reads, inputs never mutated), with frozen dataclass value objects and an injectable clock seam.
- [ ] `/parallel-add` is delivered as `.claude/skills/parallel-add/SKILL.md` (`context: fork`, `agent: parallel-orchestrator`): the item enters `proposed`, is prepared via a preparation-mode child `Agent(orchestrator)` run reusing the `route_id: preparation` contract unchanged, conflict edges are computed against all items including in-flight ones, and the admission decision admits into the current cohort only when the candidate conflicts with no in-flight item, otherwise defers and recolors the unstarted subgraph.
- [ ] `/parallel-remove` is delivered as `.claude/skills/parallel-remove/SKILL.md` and implements the design §8.4 state-dependent behavior table exactly: `proposed`/`admitted`/`prepared`/`scheduled` mark `withdrawn`, drop the vertex, and recolor the unstarted subgraph; `in_flight` removal is rejected without an explicit `detach|abandon` disposition and no default is ever inferred; `detach` lets the item finish and merge on its own while the run stops tracking it; `abandon` closes the PR, removes the worktree, and marks `withdrawn` via a single deterministic CLI invocation; `merged` removal is rejected.
- [ ] `/parallel-close` is delivered as `.claude/skills/parallel-close/SKILL.md`: it terminates an `open`-mode run and is rejected while any item is `in_flight`.
- [ ] The pinning invariant holds and is proven by tests: recoloring is a pure function of `(remaining subgraph, pinned set)` delegating to F2's coloring entry point without reimplementation; pinned items are never assigned or moved; unit tests plus property-based tests P1 (determinism), P2 (independent-set validity), and P3 (pin stability under mutation sequences) pass.
- [ ] Every add, remove, close, and drift-induced requeue appends exactly one `mutations[]` entry with the fields `{ op, item_key, at, prior_state, new_state, disposition, recolor_generation }`, matching the per-op entry-contents table in this spec; rejected operations append nothing and change no state.
- [ ] The recompute boundary is implemented as specified: deferred add, remove of an unstarted item, and drift-induced requeue each increment `recolor_generation` by exactly one; no-conflict admission, `detach`, `abandon`, and `close` do not increment it and stamp the current generation into their entries; a sequence of N ops from generation g ends at exactly g plus the number of recompute-triggering ops, verified by test.
- [ ] Mode-dependent completion semantics are implemented and tested: the `closed`-mode completion predicate fires only when every non-withdrawn item is `merged` or `worktree_removed`; `open` mode never auto-completes and terminates only via `/parallel-close`.
- [ ] `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` enforces mutation-entry shape, monotonically non-decreasing `recolor_generation` across `mutations[]`, and the mode-dependent completion invariant, wired into `validate_parallel_orchestrator_state.py` by exactly one additive import and one call line; checkpoints without the relevant keys validate unchanged.
- [ ] `.claude/hooks/enforce-parallel-abandon-gate.ps1` denies any command carrying `--disposition abandon` without the explicit confirmation marker using reason code prefix `PARALLEL_ABANDON_BLOCKED`, allows it with the marker, allows out-of-scope commands, throws on malformed JSON, and is registered by one additive entry in the `.claude/settings.json` `PreToolUse` → `Bash` matcher.
- [ ] The wave-4 contention constraint is honored: the only edit to `.claude/skills/parallel-orchestrate/SKILL.md` is one appended section (proposed `## Mutation Protocol`, or F5's landed reserved name); no existing section of any shared file is reflowed or reordered; no checkpoint schema field or enum value is added; no existing epic implementation is modified.
- [ ] The atomic plan records and executes the upstream re-verification precondition before execution: F5's reserved section names, F3's `mutations[]` schema shape (op vocabulary and field nullability), F1's `conflicts(a, b)` signature, and F2's Welsh-Powell recoloring entry point, each checked against the integration branch head, with any divergence resolved in favor of the landed shape.
- [ ] Python deliverables pass Black, Ruff, and Pyright with zero findings; pytest passes with line coverage >= 85% and branch coverage >= 75%; all Python tests live under `tests/scripts/dev_tools/`; no production or test file exceeds 500 lines.
- [ ] The PowerShell hook passes PoshQC formatting and PSScriptAnalyzer with zero findings; Pester tests at `tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1` cover the deny, allow, out-of-scope, and malformed-JSON paths using a mocked read seam.
- [ ] No test creates or uses temporary files; all tests are deterministic (injected clock for timestamps; seeded RNG with printed seed for any randomized generation).

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)

- [ ] Unit coverage: admission decision (no-conflict admit, in-flight-conflict defer), removal behavior per lifecycle state, disposition rejection paths, close rejection while in-flight, mutation-log append shape, recolor-generation increment, mode-dependent completion.
- [ ] Property/determinism tests: recoloring is a pure function of `(remaining subgraph, pinned set)`; identical inputs yield identical cohort assignments; pinned items never move.
- [ ] Hook tests: abandon gate denies without the confirmation marker and permits with it.
- [ ] Integration scenarios: add during an active cohort with and without in-flight conflicts; remove at each lifecycle state; close on `open`-mode runs.
