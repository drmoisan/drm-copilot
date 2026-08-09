# Acceptance-Criteria Check-Off — Final QC, Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P8-T11]
Work mode: `full-feature`. Per the `acceptance-criteria-tracking` skill, the authoritative AC sources
are therefore the `## Acceptance Criteria` sections of **both**
`docs/features/active/2026-08-07-parallel-drift-detection-446/spec.md` (line 304) and
`docs/features/active/2026-08-07-parallel-drift-detection-446/user-story.md` (line 76). Each file is
tracked independently.

Scope note: `spec.md` contains further checkbox lists after its `## Acceptance Criteria` section
(Definition of Done items and Test Conditions). Those are **not** acceptance criteria and are excluded
from the counts below, consistent with the prior check-off artifact
`acceptance-criteria-checkoff.2026-08-08T23-24.md`, which recorded the same 12-item AC scope for
`spec.md`.

**No checkbox was changed by this cycle.** All 12 `spec.md` criteria were already `[x]` and remain so;
all 3 unchecked `user-story.md` criteria remain `[ ]` because their F6 dependencies are still unmet.
Both AC source files are unmodified in the working tree, verified by `git status --porcelain`.

---

## `spec.md` — 12 criteria, all `[x]`

| # | Criterion (abbreviated) | State | Evidence |
| --- | --- | --- | --- |
| SP-1 | `detect_escaped_paths` returns observed paths not subsumed by declared `blast_radius.paths`, reusing F1's predicate | `[x]` | `tests/scripts/dev_tools/test_parallel_drift_detection.py`; `parallel_drift_detection.py` at 100% line / 100% branch ([P8-T4]) |
| SP-2 | An escape records an append-only `drift_events[]` entry with the §12 shape | `[x]` | `test_parallel_drift_detection.py`; enum reconciliation recorded in `evidence/other/upstream-contract-reconciliation.2026-08-08T21-19.md` IC-3a |
| SP-3 | An escape produces a synthetic Blocking finding with the literal `- Severity: Blocking` line | `[x]` | `test_parallel_drift_detection.py`; `_parallel_drift_cli_io.py` at 100% line / 100% branch |
| SP-4 | Quiesce is derived state via the exported predicate; no quiesce field is added | `[x]` | `tests/scripts/dev_tools/test_parallel_drift_detection_quiesce.py`. **Signature widening recorded this cycle**: the delivered export is `has_unresolved_drift(events, items)`; see the IC-6a amendment appended by [P6-T3]. The derived-state substance of the criterion is unaffected — no field was added. |
| SP-5 | Conflict recomputation substitutes the observed radius and evaluates F1's `conflicts` relation, imported not reimplemented | `[x]` | `tests/scripts/dev_tools/test_parallel_drift_detection_conflicts.py`; [P2-T3] routed the observed-radius construction through `build_observed_radius`, which still calls the F1 library |
| SP-6 | `select_halted_item` halts the later-started item with the three tie-breaks; identical inputs give identical decisions | `[x]` | `tests/scripts/dev_tools/test_parallel_drift_halt.py` (30 tests). [P3-T2] left the signature and body byte-identical to `bcf2de15`; only its docstring changed |
| SP-7 | Halted item's `merge_status` is `blocked_drift`; requeue appends one `mutations[]` entry and increments `recolor_generation`, through the single recolor seam or the documented stub | `[x]` | `parallel_drift_halt.py` at 100% line / 100% branch. Checked because the criterion text explicitly admits "F6's entry point **or the documented stub**" |
| SP-8 | **Layer-1 drift gate** denies `feature-review` with `PARALLEL_DRIFT_GATE_BLOCKED` while unresolved and unsurfaced; allows the three allow-paths; fails closed on an unreadable checkpoint | `[x]` | `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`, 42 of 42 passing. **Strengthened this cycle by the F8-N3 fix**: the finding that opens the gate must now be dated at or after the current event ([P5-T2], [P5-T3]), so a stale finding no longer satisfies "its synthetic finding has not been written". Evidence: `evidence/remediation-baseline/f8-n3-verification.2026-08-09T00-01.md` |
| SP-9 | **Layer-2 drift gate** emits one `PARALLEL_DRIFT_GATE_VIOLATION:` per unresolved item at a review-progressed `merge_status`; no `drift_events[]` key yields zero new errors | `[x]` | `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_drift.py`; `_parallel_orchestrator_state_drift.py` at 100% line / 100% branch. **The F8-B1 fix is the evidence that this gate now has a release path**: before it, both resolution disjuncts required a write nothing produced, so the gate could block permanently. `evidence/remediation-baseline/f8-b1-verification.2026-08-09T00-01.md` |
| SP-10 | R1-R5 loop reused unmodified; `.claude/skills/orchestrate/SKILL.md` not modified | `[x]` | [P7-T6]: `.claude/skills/orchestrate/SKILL.md` absent from both changed-path lists; no new remediation loop authored |
| SP-11 | Wave-4 contention constraints hold | `[x]` | `evidence/remediation-baseline/shared-file-edit-confinement.2026-08-09T00-01.md` ([P7-T1] through [P7-T7]); [P8-T8] 36 of 36 F5 surface-contract tests pass with that file unmodified |
| SP-12 | All new modules pass their full toolchains and meet line >= 85% and branch >= 75% | `[x]` | [P8-T1] through [P8-T7] and `evidence/qa-gates/coverage-delta.2026-08-09T00-01.md`. New this cycle: `parallel_drift_resolution.py` 100% line; `enforce-parallel-drift-gate-helpers.ps1` 100% line and instruction |

### The two Blocking fixes, named against the criteria they affect

- **F8-B1** (derived resolution had no producer, so the Layer-2 gate had no release path) —
  affects **SP-9**, and indirectly SP-4 and SP-5. Remediated in Phase 2:
  `scripts/dev_tools/parallel_drift_resolution.py` supplies `build_observed_radius` and the
  request-only seam `request_resolution_write`; `evaluate_drift` emits the ninth payload key
  `observed_radius`; and SKILL.md `#### Seven-Step Procedure` step 7 names the actor
  (`parallel-orchestrator`), the trigger (`blocking_count == 0`), and both writes. The loop closure is
  asserted end-to-end by `test_applying_the_emitted_observed_radius_resolves_the_recorded_drift`.
- **F8-B2** (halt selection could select the drifting item) — affects **SP-6** and **SP-7**, and is
  the F8-owned half of **US-4**. Remediated in Phase 3: the drifting key is dropped at the call site
  `halted_item_keys` before any selection, so it can never be returned;
  `select_halted_item` is unchanged apart from its docstring.

---

## `user-story.md` — 9 criteria, 6 `[x]`, 3 `[ ]`

| # | Criterion (abbreviated) | State | Evidence or reason |
| --- | --- | --- | --- |
| US-1 | Drift is detected automatically with no operator intervention | `[x]` | `test_parallel_drift_detection.py` |
| US-2 | The escape is surfaced as a synthetic Blocking finding processed by the existing R1-R5 loop | `[x]` | `_parallel_drift_cli_io.py` at 100% line / 100% branch |
| **US-3** | While any drift event is unresolved, no new item is admitted; admission resumes automatically at zero blocking findings | **`[ ]`** | **F6 dependency.** Admission control is F6's (issue #442). F8 exports the quiesce predicate F6 consults; F6's admission-control path does not exist and its `spec.md` still contains no reference to `has_unresolved_drift`. No F8-owned clause is outstanding. |
| **US-4** | The later-started item is halted and requeued into a future cohort; the drifting item is never the one halted | **`[ ]`** | **Three-clause split — see the dedicated section below.** Clauses 1 and 2 are F8's and are now met; clause 3 (requeue) is an F6 IC-6b dependency. |
| US-5 | Re-running the same inputs yields the same halt/requeue decision | `[x]` | `test_the_detection_and_halt_path_is_deterministic_across_repeated_calls` |
| **US-6** | Every requeue is visible as one `mutations[]` entry with an incremented `recolor_generation` | **`[ ]`** | **F6 dependency.** No code appends the `mutations[]` entry or increments `recolor_generation`; that is F6's recolor entry point (reviewer finding F8-N7, explicitly out of scope for this cycle). No F8-owned clause is outstanding. |
| US-7 | A child with unresolved, unsurfaced drift cannot enter review; the operator sees `PARALLEL_DRIFT_GATE_BLOCKED` | `[x]` | `enforce-parallel-drift-gate.Tests.ps1`, 42 of 42. Strengthened by the F8-N3 narrowing ([P5-T2] through [P5-T4]) |
| US-8 | An unresolved item cannot appear at a review-progressed `merge_status` without a `PARALLEL_DRIFT_GATE_VIOLATION:` | `[x]` | `test_validate_parallel_orchestrator_state_drift.py` |
| US-9 | Non-parallel orchestrations are unaffected; checkpoints without `drift_events[]` validate with zero new errors | `[x]` | `test_validate_parallel_orchestrator_state_drift.py`; the Layer-1 hook fires only under the `Parallel mode: true` marker |

---

## US-4 — Explicit Clause Split

US-4 carries **three** clauses with **two** owners. The original check-off deflected clause 2 to F6 in
error; that correction is recorded in full in the appended
`## CORRECTION — US-4 Disposition Restated as a Three-Clause Split (2026-08-09)` block of
`evidence/qa-gates/acceptance-criteria-checkoff.2026-08-08T23-24.md` ([P6-T4], [P6-T5]) and is restated
here:

| Clause | Owner | Status |
| --- | --- | --- |
| "the **later-started** item of the pair is halted (`merge_status: blocked_drift`)" | **F8** | **MET.** `select_halted_item` implements the later-started rule with all three tie-breaks; `test_parallel_drift_halt.py` passes with 30 tests. |
| "the drifting item is never the one halted" | **F8** | **MET, once F8-B2 was fixed.** The drifting key is dropped from every candidate list before selection. Asserted for both tie-break paths by `test_the_drifting_item_is_never_halted_even_when_it_started_later`. Evidence: `evidence/remediation-baseline/f8-b2-verification.2026-08-09T00-01.md`. |
| "and requeued into a future cohort" | **F6 (issue #442), IC-6b** | **OUTSTANDING.** F6's recolor entry point is not callable on the branch; F8 ships one documented stub seam returning the requeue intent and implements no second recolor. |

**The checkbox remains `- [ ]`.** A markdown checkbox is atomic and cannot record two met clauses beside
one unmet clause. Because the requeue clause is still unmet, the criterion as a whole is not satisfied,
so `user-story.md` lines 88-90 stay unchecked and that file was not modified by this cycle.

---

## Cross-Feature Dependency Register

| ID | Dependency | Owner | Blocks | Status |
| --- | --- | --- | --- | --- |
| IC-6a | Admission control consults the quiesce predicate `has_unresolved_drift` | F6, issue #442 | `US-3` | Outstanding. F8's export is unconditional and delivered. **Amended this cycle**: the delivered signature is the two-argument `has_unresolved_drift(events, items)`; the second argument is unavoidable because resolution is derived from `items[].blast_radius`. Recorded in the IC-6a amendment ([P6-T3]). F6's `spec.md` still names neither the predicate nor quiesce. |
| IC-6b | F6's recolor entry point applies the requeue intent | F6, issue #442 | `US-4` (requeue clause only), `US-6` | Outstanding. F8 ships one documented stub seam; F6's entry point is named `recolor_unstarted` in its spec and is not callable. No second recolor exists in F8. |
| F8-N7 | Code that appends the `mutations[]` entry and increments `recolor_generation` | F6, issue #442 | `US-6` | Outstanding, and explicitly out of scope for this cycle. Closes when F6 lands. |
| F8-N1 | TypeScript Layer-2 drift-gate parity port | separately scheduled | none of the AC | Recorded this cycle as `docs/features/potential/2026-08-09-parallel-drift-gate-typescript-parity-divergence.md` ([P6-T1]). Python is authoritative in the interim. |

All three unchecked criteria are F6 cross-feature dependencies. After the US-4 correction, **no
F8-owned clause of any acceptance criterion is outstanding.**

---

### Acceptance Criteria Status

- Source: `docs/features/active/2026-08-07-parallel-drift-detection-446/spec.md` (`## Acceptance
  Criteria`, line 304) and
  `docs/features/active/2026-08-07-parallel-drift-detection-446/user-story.md` (`## Acceptance
  Criteria`, line 76)
- Total AC items: 21
- Checked off (delivered): 18
- Remaining (unchecked): 3
- Items remaining:
  - (`user-story.md`) While any drift event is unresolved, no new item is admitted into the current
    cohort; admission resumes automatically once the consuming remediation cycle exits with zero
    blocking findings — **F6 dependency (IC-6a, admission control). No F8-owned clause outstanding.**
  - (`user-story.md`) When the observed radius newly conflicts with a concurrently in-flight item, the
    later-started item of the pair is halted (`merge_status: blocked_drift`) and requeued into a future
    cohort; the drifting item is never the one halted — **F8's two clauses (later-started halt, and the
    drifting item never halted) are MET after the F8-B2 fix; the "requeued into a future cohort" clause
    is an F6 dependency (IC-6b), so the atomic checkbox stays unchecked.**
  - (`user-story.md`) Every requeue is visible in the checkpoint as one `mutations[]` entry with an
    incremented `recolor_generation` — **F6 dependency (IC-6b / F8-N7). No F8-owned clause
    outstanding.**

Per-file totals:

| AC source file | Total | Checked | Unchecked |
| --- | --- | --- | --- |
| `spec.md` (`## Acceptance Criteria`, line 304) | 12 | 12 | 0 |
| `user-story.md` (`## Acceptance Criteria`, line 76) | 9 | 6 | 3 |
| **Combined** | **21** | **18** | **3** |
