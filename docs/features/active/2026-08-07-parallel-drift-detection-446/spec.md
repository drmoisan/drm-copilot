# 2026-08-07-parallel-drift-detection — Spec

- **Issue:** #446
- **Parent (optional):** Epic `parallel-orchestration` (child F8, wave 4)
- **Owner:** drmoisan
- **Last Updated:** 2026-08-07
- **Status:** Draft
- **Version:** 1.0
- **Work Mode:** full-feature
- **Design source:** `docs/research/2026-08-07-parallel-orchestration-design-research.md` (cited as §N)
- **Research:** `docs/features/active/2026-08-07-parallel-drift-detection-446/research/2026-08-07T12-15-parallel-drift-detection-research.md` (cited as research §N)

## Overview

The `parallel` orchestration surface schedules items concurrently based on each item's **declared**
blast radius. The declared radius is derived heuristically from the approved atomic plan (§5.3),
and derivation can under-report. An in-flight item whose actual diff escapes its declared radius
invalidates the concurrency guarantee for every item running beside it. §7 names this the dominant
failure mode of the whole design and the compensating control for heuristic derivation.

**V1/drift pairing (§13.1).** Radius-drift detection is the **execution-time** half of a paired
mitigation: F1's V1 coverage validation bounds under-reporting at **plan time**, and drift detection
bounds it at **execution time**. Neither half eliminates the risk; together they bound it. This
feature delivers only the execution-time half.

The surface is named `parallel` throughout — skills, agents, hook filenames, validator module
names, and checkpoint fields — per the epic Shared Design constraint #1.

## Behavior

### Six-step drift procedure (§7)

Evaluated at each child's pre-review commit — the moment in the child orchestrator's
Pre-Feature-Review Commit step between the successful commit and the `feature-review` delegation
(research §3.1):

1. Compare `git diff --name-only` against the declared `blast_radius.paths`.
2. On escape, record a `drift_events[]` entry and raise a synthetic Blocking finding in the child's
   own `remediation-inputs.<timestamp>.md`.
3. Quiesce: suspend admission of new items into the current cohort.
4. Recompute conflicts using the observed radius.
5. If the escape newly conflicts with a concurrently in-flight item, halt the **later-started**
   item of the pair, set its state to `blocked_drift`, and requeue it into a future cohort.
6. The child's existing R1-R5 remediation loop processes the finding unmodified.

**Halt the later-started item, not the drifting item.** This is the rule, per §7: the drifting
item's work is already broader than planned and is more expensive to unwind. Halting the drifting
item is not an option and must not be implemented or offered as a configuration.

### Drift gate (§9)

Block a child's transition to review while an unresolved `drift_events[]` entry exists for that
item. The gate is implemented at both enforcement layers (research §3.5):

- **Layer 1 — per-call deterrent.** `.claude/hooks/enforce-parallel-drift-gate.ps1`, registered on
  the `PreToolUse` `Agent` matcher. Fires when `subagent_type == "feature-review"` and the prompt
  carries the `Parallel mode: true` marker; reads the parallel checkpoint, resolves the item, and
  denies with `PARALLEL_DRIFT_GATE_BLOCKED` when the item's latest drift event is unresolved and
  its synthetic finding has not yet been written. The hook performs **presence gating only**
  (checkpoint-state reads; no glob matching and no git execution in PowerShell), keeping all
  path-matching semantics in the single Python implementation.
- **Layer 2 — retrospective backstop.** A key-gated invariant in
  `validate_parallel_orchestrator_state.py` (helper module
  `scripts/dev_tools/_parallel_orchestrator_state_drift.py`): an item whose latest `drift_events[]`
  entry is unresolved must not have `merge_status` in `{pr_open, ci_green, merged,
  worktree_removed}`. Error prefix: `PARALLEL_DRIFT_GATE_VIOLATION:`.

**"Unresolved" definition.** A drift event for item K is unresolved until a `resolved` entry for K
(with a later `at` timestamp) is appended, which the parallel-orchestrator does exactly when the
child remediation cycle that consumed the synthetic finding exits with `blocking_count == 0`
(research §5, drift-gate subsection; reuses the existing exit-gate semantics of
`.claude/rules/orchestrator-state.md` remediation-cycle invariant 3).

**Gate point reconciliation.** Resolution itself requires review (R4 is a `feature-review`
delegation), so the Layer-1 hook denies review only while the finding has not yet been surfaced.
Once the finding file exists, review (initial or R4) proceeds; the Layer-2 invariant enforces the
durable form (no merge progression while unresolved). This interpretation of §9 is recorded for
planner confirmation (research §10 point 3).

### R1-R5 remediation loop — reused unmodified

The drift finding is processed exactly as a local blocking finding: `atomic-planner` plans the
resolution (R1), `atomic-executor` performs preflight (R2) then resolves (R3), `feature-review`
re-audits (R4), and R5 exits on zero blocking findings. **No new remediation loop is authored, and
no line of the existing loop is modified.** Research §5 "Step 6" verified this end-to-end: two
existing synthetic-finding producers — the CI-failure handler
(`.claude/skills/orchestrate/SKILL.md`, Remediation Loop — CI-Failure Handling) and the epic
merge-conflict handler (`.claude/skills/epic-orchestrate/SKILL.md`, Merge-Conflict Handling) —
prove the synthetic-finding injection path requires zero loop changes. The shared
`remediation_pass` cap of 3 applies.

The synthetic finding file:

- Path: `docs/features/active/<child-slug>/remediation-inputs.<yyyy-MM-ddTHH-mm>.md` in the child's
  own active feature folder (flat form, matching the epic merge-conflict precedent; the newer
  folder-per-cycle convention is deliberately not used — research §3.2 dual-convention caution).
- Written by the **parallel-orchestrator** (which detects the escape and owns the checkpoint) via
  the child worktree path recorded in `items[].worktree_path`.
- Must contain the literal line `- Severity: Blocking` (matched case-sensitively by the child
  orchestrator's Post-Review Outcome Evaluation), the escaped paths, the declared patterns, and the
  required action.

## Inputs / Outputs

- **Inputs:**
  - Changed-path list from `git diff --name-only <merge-base(origin/main, HEAD)> HEAD` at the
    child's pre-review commit (research §5 step 1; three-dot semantics so concurrently merged peer
    items never appear as spurious drift; renames list both old and new paths, both must be
    covered — fail closed).
  - Declared `blast_radius.paths` from the parallel checkpoint `items[]` entry.
  - Parallel checkpoint state (`items[]`, `drift_events[]`, `conflict_edges[]`) for recomputation
    and halt selection.
  - Timestamps entering the halt decision are function inputs, never read from the wall clock
    inside the pure functions (determinism rule).
- **Outputs:**
  - `drift_events[]` entries (append-only) in
    `artifacts/orchestration/parallel-orchestrator-state.json`.
  - Synthetic Blocking finding file in the child's active feature folder.
  - On halt: updated `merge_status` (`blocked_drift`), one `mutations[]` entry, incremented
    `recolor_generation` — all via F6's recolor path (see Constraints).
  - Validator errors prefixed `PARALLEL_DRIFT_GATE_VIOLATION:`; hook denial reason
    `PARALLEL_DRIFT_GATE_BLOCKED`.
- **Config keys and defaults:** none added. No new dependency is added.
- **Backward compatibility:** the validator invariant is key-gated — a checkpoint with no
  `drift_events[]` key validates exactly as before and produces no new errors, matching the
  additive-invariant style of `.claude/rules/orchestrator-state.md`.

## API / CLI Surface

Pure reference implementation `scripts/dev_tools/parallel_drift_detection.py` (no I/O):

- `detect_escaped_paths(changed, declared)` — returns observed paths not subsumed by the declared
  patterns, using F1's path-subsumption predicate (IC-1a).
- `select_halted_item(a, b)` — later-started selection: `argmax` over the tuple
  `(start_ts, item_key)` with lexicographic comparison, `item_key` compared as integer
  (`issue_num`). Equal timestamps (the normal case for same-minute cohort fan-out) deem the item
  with the **larger** `issue_num` later-started, so the smaller key survives — consistent with the
  repository's ascending-item-key determinism convention (§6). A missing start timestamp on exactly
  one item makes the timestamped item earlier-started; both missing falls through to the item-key
  tie-break. Deterministic: identical inputs produce identical decisions.
- `build_drift_event(...)` — constructs the §12-shaped record.
- `has_unresolved_drift(events) -> bool` — the quiesce predicate exported for F6's admission
  control (IC-6a).

Thin CLI wrapper `scripts/dev_tools/parallel_drift_detection_cli.py` (argparse; isolates I/O from
the pure module) lets the parent agent invoke detection with `git diff --name-only` output.

Procedure documentation: one new H2 section `## Radius Drift Detection and Drift Gate` in
`.claude/skills/parallel-orchestrate/SKILL.md`, documenting all six steps, the drift gate, and the
child-side evaluation point under the `Parallel mode: true` marker. This feature must not modify
`.claude/skills/orchestrate/SKILL.md` (additive-only constraint).

## Data & State

### `drift_events[]` entry shape (§12; schema owned by F3)

`{ item_key, declared, observed, escaped_paths[], at, action }`

- `item_key` — the item's `issue_num` (§11 primary key; epic Shared Design #3).
- `declared` / `observed` — declared `blast_radius.paths` set and observed changed-path set, with
  `source: declared` / `source: observed` provenance (§5.2).
- `escaped_paths[]` — observed paths not subsumed by declared patterns.
- `at` — ISO-8601 timestamp.
- `action` — §12 does not enumerate values; the recommended enum (**Assumed**; reconcile with F3's
  landed schema, research §10 point 2):
  - `blocking_finding_raised` — escape recorded, finding written, recomputation found no new
    conflict (steps 2-4 only).
  - `halted_later_started` — escape recorded, finding written, and recomputation found a new
    conflict, so the later-started item was halted and requeued (steps 2-5).
  - `resolved` — appended as a new entry for the same `item_key` (event-log style, mirroring the
    append-only `mutations[]` convention of §8.6) when the consuming remediation cycle exits with
    `blocking_count == 0`.

`drift_events[]` is append-only.

### Quiesce is derived state, not a stored field

Admission of new items into the current cohort is suspended while `has_unresolved_drift(events)`
returns `True` (the latest entry for any `item_key` has `action != "resolved"`). §12 defines no
quiesce field and F3 owns the schema; deriving quiesce from the event log makes it self-clearing on
resolution and keeps the checkpoint contract untouched. Deferral of admission into a **future**
cohort (F6's existing path) remains allowed during quiesce.

### Halt and requeue state changes

The halted item's `merge_status` becomes `blocked_drift` (a value F3's §12 enum already defines)
and its lifecycle state becomes `blocked` (§8.2) pending requeue. The requeue appends one
`mutations[]` entry
`{ op, item_key, at, prior_state: "in_flight", new_state: "blocked_drift", disposition: null,
recolor_generation: <new> }` and increments `recolor_generation` by one — through F6's recolor path
only (see Constraints). The in-flight pinned set is untouched; only the unstarted subgraph is
recolored (§8.1).

## Interfaces and Upstream Dependencies

**Every upstream contract below is Assumed, not Verified.** The research verified by filesystem
enumeration that none of F1, F3, F5, or F6 exists on the integration branch in this worktree (the
branch content is the epic scaffold only; no `parallel-*` skill, agent, validator, or feature
folder other than this one exists — research §2). Each contract is cited to a design-document
section and must be reconciled against the real upstream artifacts at execution time. F1/F3/F5 land
in waves 0-3 before F8 executes in wave 4; F6 lands concurrently with F8.

| ID | From | Contract | Design source | Fallback if absent at execution time |
| --- | --- | --- | --- | --- |
| IC-1a | F1 | Path-subsumption predicate reused for escape detection (same matcher V1 uses), assumed in `scripts/dev_tools/compute_blast_radius.py` | §5.3, §10-F1 | Implement `fnmatch.fnmatchcase` over POSIX-normalized paths per the `inventory.py` precedent; record deviation |
| IC-1b | F1 | `conflicts(a, b)` relation for step-4 recomputation with the observed radius substituted for the drifting item's declared radius | §5.4 | Blocking — do not reimplement the relation; if unavailable, the plan must sequence steps 4/5 behind F1's landing (F1 is wave 0, so absence indicates a broken branch state) |
| IC-3a | F3 | Checkpoint schema: `drift_events[]` field, `items[]` lifecycle timestamps (start marker: `in_flight_at` or `worktree_created_at`), `blocked_drift` in the `merge_status` enum, `recolor_generation`, `mutations[]` | §12, §8.6 | Blocking — F8 populates, never defines; reconcile field names against F3's spec |
| IC-3b | F3 | `validate_parallel_orchestrator_state.py` exists with the epic-validator structure so F8 can add its key-gated invariant + helper module | §10-F3 | Blocking — same as IC-1b |
| IC-5a | F5 | `Parallel mode: true` kickoff marker line including `parallel_checkpoint_path` (analog of the epic-mode line) so the hook and the child-side evaluation can locate the parallel checkpoint from a child-worktree cwd | §9 Layer 1 | Reconcile marker text verbatim against F5's skill; the hook constant must match byte-for-byte |
| IC-5b | F5 | `.claude/skills/parallel-orchestrate/SKILL.md` exists with a reserved placeholder section for F8 (recommended name `## Radius Drift Detection and Drift Gate`); `items[].worktree_path` recorded so the parent can write the child's remediation-inputs file | epic Wave-4 note, §12 | If no placeholder exists, append the named section at the end without reflowing |
| IC-6a | F6 | Admission control consults `has_unresolved_drift(drift_events) -> bool` (exported by F8) and defers current-cohort admission while true | §7 step 3, §8.3 | F8 exports the predicate regardless; the consultation edge is F6's to wire — record as a cross-feature acceptance dependency |
| IC-6b | F6 | Single recolor entry point `requeue_via_recolor(...)`: pins in-flight items (§8.1), recolors the unstarted subgraph, increments `recolor_generation`, appends the `mutations[]` entry | §8.6, §8.1 | Stub behind one narrow seam in F8's module; never a second recolor implementation |

The "started" marker for later-started selection uses the item's `in_flight_at` timestamp if F3
defines one; otherwise `worktree_created_at`, the epic-precedented start-of-execution marker
(Verified in `validate_epic_orchestrator_state.py`; research §5 steps 4/5).

## Constraints & Risks

1. **Halt the later-started item, not the drifting item.** Deliberate per §7: the drifting item's
   work is already broader than planned and is more expensive to unwind. This is not configurable
   and no alternative is in scope.
2. **Reuse R1-R5 unmodified.** The drift finding is processed exactly as a local blocking finding
   (R1 `atomic-planner`, R2 preflight, R3 `atomic-executor` resolution, R4 `feature-review`
   re-audit). No new remediation loop is authored. The two existing synthetic-finding producers
   (CI-failure handler, epic merge-conflict handler) prove zero loop changes are required
   (research §5 "Step 6", Verified).
3. **V1/drift pairing.** F1's V1 bounds under-reporting at plan time; this feature bounds it at
   execution time; neither eliminates the risk (§13.1). If drift events prove frequent in practice,
   §13.1 directs revisiting the decision to leave the atomic-plan contract unchanged — out of scope
   here.
4. **Surface name is `parallel` throughout** — skills, agents, hook filenames, validator module
   names, checkpoint fields.
5. **Additive only.** Do not modify or refactor the existing epic implementations; adapt them
   near-verbatim into new `parallel`-named files (`enforce-parallel-drift-gate.ps1` is adapted from
   `enforce-epic-wave-barrier.ps1`; the validator helper follows the `_orchestrator_state_*.py`
   split convention).
6. **Wave-4 contention (mandatory).** F8 executes concurrently with F6
   (`parallel-mutation-protocol`) and F7 (`parallel-enforcement-hooks`). All three extend
   `.claude/skills/parallel-orchestrate/SKILL.md` and, to a lesser degree,
   `validate_parallel_orchestrator_state.py`. F8's edits MUST be confined to a distinct, explicitly
   named new section and MUST NOT reflow or reorder existing sections. Claimed names:
   - SKILL.md section: `## Radius Drift Detection and Drift Gate` (one H2 section; F5 is expected
     to reserve named placeholder sections — F8 fills its own placeholder if present, otherwise
     appends the named section at the end without reflowing).
   - Validator helper module: `scripts/dev_tools/_parallel_orchestrator_state_drift.py`. F8's edit
     to `validate_parallel_orchestrator_state.py` (an F3-owned file) is confined to one import line
     and one key-gated dispatch call. F6 and F7 are expected to take distinct helper filenames; no
     shared helper file.
   - `.claude/settings.json` hook registration is **append-only** to the `Agent` matcher hook
     list: F8 appends exactly one entry and does not reorder existing entries.
7. **F3 owns the checkpoint schema**, including `drift_events[]`, `conflict_edges[]`,
   `mutations[]`, `recolor_generation`, and the `blocked_drift` value in the per-item
   `merge_status` enum. F8 **populates** those structures and MUST NOT add schema fields to any of
   them.
8. **Shared recolor path with F6 (Assumed).** F8's step-5 requeue and F6's mutation-driven recolor
   must both go through the same recolor path and both increment `recolor_generation` — §8.6:
   "drift-induced requeues append to `mutations[]` exactly as add/remove/close do". F6's `spec.md`
   has not landed (Verified: the research confirms no `parallel-*` feature folders exist on the
   branch beyond this one), so the entry-point name and `mutations[].op` value are recorded as
   assumptions with the §8.6 citation. F8 must route through a single narrow seam (one function in
   F8's module that F6's landing replaces or that delegates to F6's entry point once known) and
   must never implement a second recolor.

Additional risks:

- **Matcher divergence (IC-1a).** F8's escape detection and F1's V1 validation are the same
  predicate evaluated at different times; divergent matchers produce false-positive or
  false-negative drift. Mitigation: import F1's predicate; if the fallback matcher is used, record
  the deviation for reconciliation.
- **`action` enum reconciliation (IC-3a).** If F3's landed schema enumerates `action` values, adopt
  F3's names.
- **Gate-point interpretation.** The §9 drift-gate reading (finding-surfaced-before-review plus
  merge-progression forbidden while unresolved) is an interpretation chosen to avoid deadlocking
  R4; the planner must confirm it (research §10 point 3).

## Implementation Strategy

Scope (what changes, not sequencing). All production files are new except two confined edits:

| Path | Content | New/Edit |
| --- | --- | --- |
| `scripts/dev_tools/parallel_drift_detection.py` | Pure reference implementation: `detect_escaped_paths`, `select_halted_item`, `build_drift_event`, `has_unresolved_drift`; no I/O | New |
| `scripts/dev_tools/parallel_drift_detection_cli.py` | Thin argparse CLI wrapper; isolates I/O from the pure module | New |
| `scripts/dev_tools/_parallel_orchestrator_state_drift.py` | Key-gated validator helper: `drift_events[]` shape checks, unresolved-drift-versus-`merge_status` invariant (`PARALLEL_DRIFT_GATE_VIOLATION:` messages) | New |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | Layer-1 Agent-matcher deterrent (`PARALLEL_DRIFT_GATE_BLOCKED`), adapted near-verbatim from `enforce-epic-wave-barrier.ps1` (injectable checkpoint-read seam, fail-closed deny, dot-source guard) | New |
| `.claude/skills/parallel-orchestrate/SKILL.md` | One new H2 section `## Radius Drift Detection and Drift Gate` | Edit (F5 file) |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | One import + one key-gated dispatch call | Edit (F3 file) |
| `.claude/settings.json` | One hook entry appended to the `Agent` matcher list | Edit (append-only) |

- Languages in scope: Python (detection module, CLI wrapper, validator helper) and PowerShell
  (Layer-1 hook). No TypeScript: the MCP `artifact_type` wiring is F3's.
- Every file stays under the 500-line cap; the pure-logic/CLI/validator split is what keeps each
  file small. If the pure module trends past ~400 lines, split halt/tie-break/requeue-decision
  logic into `parallel_drift_halt.py`.
- Dependency changes: none. Property-based tests are not required (T4 dev tooling per
  `.claude/rules/quality-tiers.md`; `hypothesis` is not a repository dependency).
- Logging/telemetry: validator error strings and hook denial reasons only, following the existing
  literal, context-prefixed message style.
- Rollout: no feature flag. The validator invariant is key-gated (inert for checkpoints without
  `drift_events[]`); the hook fires only under the `Parallel mode: true` marker, so existing
  orchestrations are unaffected.

## Acceptance Criteria

- [ ] `detect_escaped_paths` returns the set of observed paths not subsumed by declared
      `blast_radius.paths`, reusing F1's path-subsumption predicate (or the documented
      `fnmatch.fnmatchcase` fallback with the deviation recorded), covering the cases: no escape,
      single escape, multiple escapes, and glob boundary cases (pattern-edge paths, separator
      handling, rename old/new paths both required to be covered).
- [ ] An escape records an append-only `drift_events[]` entry with the §12 shape
      `{ item_key, declared, observed, escaped_paths[], at, action }`, where `item_key` is the
      item's `issue_num` and `action` is one of `blocking_finding_raised`, `halted_later_started`,
      `resolved` (or F3's landed enum names, with the reconciliation recorded).
- [ ] An escape produces a synthetic Blocking finding written into the child's own
      `docs/features/active/<child-slug>/remediation-inputs.<yyyy-MM-ddTHH-mm>.md` (flat form)
      containing the literal line `- Severity: Blocking`, the escaped paths, and the declared
      patterns.
- [ ] Quiesce is derived state: `has_unresolved_drift(events)` returns `True` exactly while the
      latest entry for any `item_key` has `action != "resolved"`, and the exported predicate is the
      single seam F6's admission control consults; no quiesce field is added to the checkpoint.
- [ ] Conflict recomputation substitutes the observed radius for the drifting item's declared
      radius and evaluates F1's `conflicts(a, b)` relation; the relation is imported, not
      reimplemented.
- [ ] `select_halted_item` halts the **later-started** item of a newly conflicting pair using the
      `(start_ts, item_key)` lexicographic rule with the deterministic tie-break (equal timestamps:
      larger `issue_num` is later-started; single missing timestamp: the timestamped item is
      earlier-started; both missing: item-key tie-break), and identical inputs produce identical
      halt/requeue decisions.
- [ ] The halted item's `merge_status` is set to `blocked_drift` and the requeue appends exactly
      one `mutations[]` entry and increments `recolor_generation` by one, routed through the single
      recolor seam (F6's entry point or the documented stub); no second recolor implementation
      exists in F8's code.
- [ ] Layer-1 drift gate: `.claude/hooks/enforce-parallel-drift-gate.ps1` denies a
      `feature-review` delegation with `PARALLEL_DRIFT_GATE_BLOCKED` when the target item's latest
      drift event is unresolved and its synthetic finding has not been written; allows
      non-feature-review targets, prompts without the `Parallel mode: true` marker, and resolved
      events; fails closed on an unreadable checkpoint or unresolved target.
- [ ] Layer-2 drift gate: the key-gated invariant in
      `scripts/dev_tools/_parallel_orchestrator_state_drift.py` emits one
      `PARALLEL_DRIFT_GATE_VIOLATION:` error per item whose latest drift event is unresolved while
      its `merge_status` is in `{pr_open, ci_green, merged, worktree_removed}`; a checkpoint with
      no `drift_events[]` key produces zero new errors.
- [ ] The R1-R5 remediation loop is reused unmodified: no new remediation loop is authored, and
      `.claude/skills/orchestrate/SKILL.md` is not modified by this feature.
- [ ] Wave-4 contention constraints hold: the SKILL.md edit is confined to the single H2 section
      `## Radius Drift Detection and Drift Gate` with no reflow or reorder of existing sections;
      the validator edit is one import plus one key-gated dispatch call; the `.claude/settings.json`
      edit appends exactly one entry to the `Agent` matcher list.
- [ ] All new Python and PowerShell modules pass their full toolchains and meet line coverage
      >= 85% and branch coverage >= 75%.

## Definition of Done

- [ ] Acceptance criteria above mapped to tests (see Test Plan) and all checked off with evidence
- [ ] Behavior matches acceptance criteria; all Assumed contracts reconciled against landed
      upstream artifacts (or fallbacks applied with deviations recorded)
- [ ] Tests added per the Test Plan; edge cases and error handling covered
- [ ] Docs updated: the `## Radius Drift Detection and Drift Gate` SKILL.md section is authored
- [ ] Python toolchain pass: `poetry run black .` → `poetry run ruff check .` →
      `poetry run pyright` → `poetry run pytest --cov --cov-branch --cov-report=term-missing`
- [ ] PowerShell toolchain pass: `run_poshqc_format` → `run_poshqc_analyze` → `run_poshqc_test`

## Test Plan

Test files (mirroring production structure per the repository layout rule; no temp files in
tests — mock the checkpoint-read seam):

| Path | Covers |
| --- | --- |
| `tests/scripts/dev_tools/test_parallel_drift_detection.py` | Escape matrix (none/single/multiple/glob boundaries), later-started selection including equal-timestamp and missing-timestamp tie-breaks, event shapes, `has_unresolved_drift`, determinism |
| `tests/scripts/dev_tools/test_parallel_drift_detection_cli.py` | CLI parsing/dispatch with seams mocked |
| `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_drift.py` | Key-gated invariant: absent key = zero errors; unresolved event + progressed status = one error per item; resolved event passes |
| `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` | Allow on non-feature-review targets / no marker / resolved events; deny on unresolved-without-finding; fail-closed on unreadable checkpoint |

## Seeded Test Conditions (from potential)

- [ ] Unit coverage: escape detection (no escape, single escape, multiple escapes, glob boundary cases).
- [ ] Unit coverage: later-started selection when two in-flight items newly conflict.
- [ ] Unit coverage: drift gate blocks review transition while unresolved; permits it once resolved.
- [ ] Unit coverage: `drift_events[]` and `mutations[]` record shapes and `recolor_generation` increment.
- [ ] Integration scenario: drift event flows into the child's `remediation-inputs.<timestamp>.md` unchanged.
- [ ] Determinism: identical inputs produce identical halt/requeue decisions.
