# parallel-mutation-protocol — Remediation Plan (Cycle 1)

- **Issue:** #442
- **Parent:** Epic `parallel-orchestration` (`docs/features/epics/parallel-orchestration/epic.md`, child feature F6, wave 4)
- **Owner:** drmoisan
- **Last Updated:** 2026-08-09
- **Remediation cycle:** 1
- **Plan revision:** 5 (preflight deltas REV-1 through REV-20 applied, plus the four auditability fixes from preflight iteration 4; REV-5 applied per the adjudicated scope expansion, which supersedes the preflight's proposed REV-5 delta. Revisions 3 and 4 applied REV-6 through REV-17 without bumping this field; that omission is corrected here)
- **Work Mode:** full-feature
- **Diff bases (both pinned):** `a9e2463c` (the pre-remediation commit recording the fully-executed base plan; base for every "what this remediation cycle changed" check) and `c939b5b8` (the wave-0-3 integration head; base for whole-branch confinement checks only). See `## Conventions Used in This Plan` for which base applies to which check.
- **Plan Path (continuity):** `docs/features/active/2026-08-07-parallel-mutation-protocol-442/remediation-plan.2026-08-09T00-19.md` (update in place across preflight revision loops; do not create sibling plan files)
- **Base plan (fully executed, 51/51, MUST NOT be modified):** `docs/features/active/2026-08-07-parallel-mutation-protocol-442/plan.md`

## Remediation Inputs

- `<FEATURE>/remediation-inputs.2026-08-09T00-19.md` (findings R1 Blocking, R2–R6 Partial, A1–A9 Advisory)
- `<FEATURE>/policy-audit.2026-08-09T00-19.md` (B1, P1–P5, A1–A9)
- `<FEATURE>/code-review.2026-08-09T00-19.md`
- `<FEATURE>/feature-audit.2026-08-09T00-19.md` (24 AC evaluated; S9 PARTIAL; discrepancy D1)
- Preflight revision deltas REV-1 through REV-20 across four preflight iterations (see `## Preflight Revision Log`)

`<FEATURE>` = `docs/features/active/2026-08-07-parallel-mutation-protocol-442`.

## Preflight Revision Log

This plan is revision 5, produced across four preflight iterations. Each entry names the defect
corrected and the tasks that now carry the correction, so a re-preflight can confirm the delta
landed rather than inferring it.

Rows REV-1 through REV-5 record preflight iteration 1. Rows REV-6 through REV-11 record iteration
2 and rows REV-12 through REV-17 record iteration 3; those twelve rows are RECONSTRUCTED from the
landed plan text and from preflight iteration 4's confirmation set, because the per-delta wording
of iterations 2 and 3 was not carried in this file at the time it was applied. Rows REV-18 through
REV-20 record iteration 4 verbatim from its directive. If a reconstructed row misnames a delta,
re-preflight corrects it in this same table; no sibling plan file is created.

| Delta | Defect corrected (in the revision the delta was raised against) | Correction applied |
| --- | --- | --- |
| REV-1 | The `[expect-fail]` tag sat on the test-authoring task `[P2-T1]`, which runs no command, while the task whose command must exit non-zero carried no tag. The contract requires the tag on the task whose run is expected to fail. | `[expect-fail]` now tags exactly the three command-bearing Phase 2 tasks whose runs must exit non-zero, and not the two authoring tasks, which run no command and so have no run that can fail. Each command-bearing `[expect-fail]` task states its expected non-zero exit code explicitly and names its evidence artifact. |
| REV-2 | `[P2-T3]` ran `poetry run pytest -q` while the regression test was red, so its command must exit non-zero, yet the task was untagged and its acceptance criterion implied a clean run. | The whole-suite run is now `[P2-T5]`, tagged `[expect-fail]`, with `EXIT_CODE: 1` stated as the required outcome and its acceptance criterion expressed as "exactly the expected failing ids, no others". |
| REV-3 | Test-module headroom was asserted rather than computed. Revision 1 added content to `test_parallel_mutation_protocol.py` (498 lines) and to `test_parallel_mutation_protocol_properties.py` (499 lines) and assumed relocation would make room, with no arithmetic and no requirement that `test_parallel_mutation_protocol_ops.py` (exactly 500 lines) stay untouched. | `## Test-Module Relocation Arithmetic` now states the measured baseline line counts, every affected call site, the 88-character wrapping cost, the four new sibling modules, and the resulting per-file budgets. `[P0-T9]` captures the baseline counts as evidence before any edit, and `[P7-T9]` plus `[P7-T10]` Check I require `test_parallel_mutation_protocol_ops.py` to be byte-unchanged. The two stale docstrings the C1 signature change falsifies — `_parallel_mutation_models.py:122-127` and `_parallel_mutation_entries.py:106-107` — are corrected by [P3-T10]. |
| REV-4 | The plan's evidence and verification tasks did not bind the amended contract to the landed upstream validator: the `## Framing Confirmation` section reasoned about F3 invariants in prose with no executable check, and no task proved the corrected engine output is accepted by `validate_parallel_orchestrator_state_text`. | `[P4-T11]` adds a dedicated binding test module that runs the landed F3 validator over a constructed in-memory checkpoint reflecting the corrected recolor output, asserting zero errors for invariants 12, 13, and 14. `[P7-T12]` records the closure statement from executed results rather than from prose. |
| REV-5 | Revision 1 recorded the `recolor_unstarted` pinned-edge blindness as an adjacent observation deferred to a `docs/features/potential/` entry. | Superseded by the adjudicated scope expansion: the gap is REMEDIATED IN CODE in this cycle as correction C2. See `## Two Design Corrections`, `## Mandated Signatures`, Phase 3, and Phase 4. The deferral language is removed and the `docs/features/potential/` entry for it is NOT created. |
| REV-6 (reconstructed) | A single diff base `c939b5b8` was used for every check, but that base predates every path this feature created, so any "what this cycle changed" check against it was vacuous on those paths. | Two bases are pinned and every diff check names the one that applies: `a9e2463c` for what this remediation cycle changed, `c939b5b8` for whole-branch confinement only. Touched the header `Diff bases` line, the two `## Conventions Used in This Plan` base bullets, [P0-T8], [P1-T14], [P2-T5], [P3-T7], [P3-T10], [P4-T12], [P5-T1], [P5-T2], [P5-T7], [P7-T9], and [P7-T10]. |
| REV-7 (reconstructed) | The plan asserted that C1 plus C2 closed the contention guarantee without stating what residual remained, and still planned a `docs/features/potential/` entry for a gap it was closing in code. | `## Residual Gap Assessment` states the four closure legs and identifies the only residual as the pre-existing caller-side cache-doctrine obligation. The potential entry for the C2 observation is not created and the task that created it is deleted. Touched `## Residual Gap Assessment`, the `## Finding Disposition` table, [P6-T7], [P6-T8], and [P7-T12]. |
| REV-8 (reconstructed) | In the offset-not-applied case the returned keys sit at index `current_cohort`, and a consumer writing them as their own cohort entry would create two current-generation entries sharing that index, which F3 invariant 13 rejects. | The single-entry-per-index merge obligation is stated in the consumer instructions: returned keys whose index equals `current_cohort` are merged into the one existing entry at that index alongside its pinned members. Touched [P5-T1], [P5-T2], and [P5-T3]. |
| REV-9 (reconstructed) | The F3 binding test proved the merge obligation SUFFICIENT but not NECESSARY, so a consumer could satisfy the test while writing duplicate-index entries. | [P4-T11] carries four required positive cases plus one negative-path case asserting that two separate current-generation entries at index `current_cohort` DO produce a duplicate-index error. Touched [P4-T11] and `## Residual Gap Assessment`. |
| REV-10 (reconstructed) | Property P4's contention assertion could not distinguish the correct conditional offset from an unconditional `+1`, because an unconditional offset also vacates the pinned index and therefore also passes a pure contention check. | [P4-T8] adds the offset-value assertion: recompute `crosses_pinned` independently and assert `min(...) == current_cohort + 1` when true and `== current_cohort` when false. Touched [P4-T8] and [P4-T13]'s binding statement. |
| REV-11 (reconstructed) | P4's harness dropped a candidate admitted by `ADMIT_CURRENT_COHORT` from the unstarted set used by later steps, leaving a stale index in the map so the assertion tested the harness rather than the engine. | [P4-T8] states that an admitted candidate is `scheduled` and therefore joins the unstarted set of every subsequent step of the same run. Touched [P4-T8]. |
| REV-12 | The negative-`current_cohort` guard named no exception type, and adding one would have violated the no-new-type constraint. | [P3-T3] raises F2's existing `ParallelCohortInputError` with the invalid integer as `offending_value`; `## Mandated Signatures` records that no value object, enum, or exception TYPE is added; [P4-T5] and [P3-T5] carry the matching scenario and `Raises:` text. |
| REV-13 | [P3-T8] implied a Pyright zero-error gate at a point where the not-yet-migrated Phase 4 test call sites made a zero-error result impossible. | [P3-T8] states explicitly that Pyright is deliberately not run there and classifies each call site MIGRATED or PENDING-PHASE-4; the zero-error gate is [P4-T13] and again [P7-T3]. [P3-T10] likewise scopes its Ruff check to two files. |
| REV-14 | Not separately identified in preflight iteration 4's confirmation set, which named REV-12, REV-13, REV-15, REV-16, and REV-17. Recorded here as applied and absorbed into an adjacent row rather than as an outstanding delta. | No task text is attributed to this row. If iteration 5 identifies a distinct REV-14 defect that did not land, this row is corrected then. |
| REV-15 | [P6-T6]'s deviation from the rule's verbatim one-line suppression format was asserted rather than measured, so a reviewer could not confirm the 88-character limit forced it. | [P6-T6] records the measured 95-character composed line verbatim, the measured lengths of the two replacement rationale lines (74 and 72 at indentation 4), and the monkeypatch constraint that blocks shortening; its artifact records the same arithmetic. |
| REV-16 | [P6-T4]'s second `per-file-ignores` entry named a module that does not use `random.Random`, so the S311 authorization would not have covered the new seeded generator. | [P6-T4] names `tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py`, the only new module that uses `random.Random`, and its acceptance additionally requires `git diff c939b5b8 -- poetry.lock` to be empty. |
| REV-17 | [P4-T12]'s scenario inventory did not bound which pre-existing tests may be recorded as `replaced`, so a dropped test could have been laundered through that disposition. | [P4-T12] names the only three permitted `replaced` entries and requires each to name its replacement; no name may be dropped without one. |
| REV-18 | `[P7-T10]` Check G proved only numstat equality against `c939b5b8`, which cannot detect a line-count-preserving edit inside the added-line set — including the most plausible violation of Constraint 4, an executor toggling `- [ ]` to `- [x]` in the fully-executed base plan. | Check G now proves byte-identity: `git diff a9e2463c -- <FEATURE>/plan.md` must produce empty output. The `c939b5b8` numstat recorded by [P0-T8] is retained as an informational baseline only and is explicitly not the proof. Touched [P7-T10] Check G. |
| REV-19 | The `## Conventions` base bullet claimed `git diff c939b5b8 -- <path>` is empty by construction for a feature-created path. Committing those paths in `a9e2463c` falsified that: the diff now reports the whole file as an addition (measured `122 0` and `500 0`), so an executor applying the stated convention to `[P0-T8]` would have recorded empty values and produced wrong baseline evidence. | The bullet's operative prohibition is unchanged but its stated reason is corrected to the full-addition behavior, with both measurements quoted, and it records that [P0-T8]'s full-addition numstats are the correct recorded value rather than an anomaly. Touched the `## Conventions Used in This Plan` `c939b5b8` bullet. |
| REV-20 | The four corpus existentials in `[P4-T8]` are independent, so the rejection of an unconditional `+1` offset strictly required a single run that both lacks an unstarted-to-pinned edge AND performs a recolor; clause (iv) guaranteed the first and clause (ii) the second, but not on the same run. | The fourth non-vacuity clause now requires at least one run that both contains no unstarted-to-pinned conflict edge AND performs at least one recolor, so the offset-value assertion is evaluated on the offset-not-applied branch. Touched [P4-T8]. |

### Iteration 4 auditability corrections

Preflight iteration 4 also required a sweep of every stated line number, line count, and call-site
count against the files on disk. The corrections applied, each verified by reading the named file:

- `TestPinnedItemsNeverMove` has SIX `recolor_unstarted` call sites, not seven (lines 140, 153, 168, 181, 191, 201). Corrected in the `## Test-Module Relocation Arithmetic` layout table and in [P4-T4].
- `TestPinnedItemsNeverMove` spans lines 128-205, not 128-206: line 128 is the `class` statement and line 205 is its last code line. The class start is 128, NOT 126 — lines 126 and 127 are the blank separator lines preceding the class, and the enumerated call-site line numbers confirm the 128 offset. The shed size becomes approximately 78 lines and the net figure for `test_parallel_mutation_protocol.py` becomes approximately 379.
- `TestPropertyThreePinStability` spans lines 299-368, not 299-369: line 368 is its last code line. The shed size becomes approximately 70 lines.
- `decide_admission` call site line 335 lies INSIDE `TestPropertyThreePinStability` and therefore relocates with it under [P4-T9]; the only admission call site remaining in `test_parallel_mutation_protocol_properties.py` after the relocations is line 492. The wrapping cost becomes +10 over five sites and the net figure for that module becomes approximately 418.
- `recolor_unstarted` is defined at `scripts/dev_tools/parallel_mutation_protocol.py:164-235`; the induced-edge comment and comprehension are at lines 217-224. The former citation of `214-224` named the tail of the overlap guard instead of the function.
- The cohort-barrier increment rule is the `**Cohort barrier.**` paragraph at `.claude/skills/parallel-orchestrate/SKILL.md:113-118`, not `113-117`.
- The duplicate-current-generation-index rule spans `scripts/dev_tools/_parallel_state_structures.py:282-305` — detection at 282-293 and error emission at 301-305 — not `299-305`.
- FR1 step 4's two bullets are at `spec.md:46-48`; line 45 is the step heading.

Note on provenance: the REV-1 through REV-4 corrections above were derived from the defects
themselves as they stand in revision 1 of this plan and in the landed code, and were verified
against both. If any of them diverges from the preflight's own wording, re-preflight will
re-flag it and this same file is amended again; no sibling plan file is created.

## Conventions Used in This Plan

- Evidence artifacts go only to `<FEATURE>/evidence/<kind>/` per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No `artifacts/`-rooted evidence path appears anywhere in this plan. No supplied path required an override; `EVIDENCE_LOCATION_OVERRIDE_REJECTED` does not apply to this cycle.
- Every evidence artifact records `Timestamp:` (ISO-8601 `yyyy-MM-ddTHH-mm`), `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- Remediation-cycle artifacts use the `remediation1-` filename prefix so they never overwrite the base plan's Phase 0 / Phase 7 artifacts.
- Python toolchain: `poetry run black .` → `poetry run ruff check .` → `poetry run pyright` → `poetry run pytest --cov --cov-branch --cov-report=term-missing`. Restart from formatting if any stage fails or changes files.
- PowerShell toolchain: `mcp__drm-copilot__run_poshqc_format` → `mcp__drm-copilot__run_poshqc_analyze` → `mcp__drm-copilot__run_poshqc_test`. Restart from format if any stage fails or changes files.
- This cycle uses TWO diff bases, and every diff check names the one that applies. `a9e2463c` — the commit "feat(parallel): add mutation protocol for parallel runs (#442)" that recorded the fully-executed base plan's 67 paths — is the base for every check asking WHAT THIS REMEDIATION CYCLE CHANGED. Use `git diff a9e2463c -- <path>` and `git show a9e2463c:<path>`. Because that commit contains every F6 path, these checks are sound for new files as well as pre-existing ones.
- `c939b5b8` — the wave-0-3 integration head this feature was reconciled against — remains the base ONLY for whole-branch confinement checks that must prove this feature touched no epic artifact, no `.claude/rules/**` file, and no F1/F2/F3-owned definition across the entire branch. Those checks are not vacuous at `c939b5b8` because the files they examine exist there. The moving tip `origin/epic/parallel-orchestration-integration` is never a diff base. Note that for any path this feature created, `git diff c939b5b8 -- <path>` reports the WHOLE FILE as an addition, because the path is absent from `c939b5b8` and present in the working tree at `a9e2463c` (measured: `122 0` for `.claude/skills/parallel-add/SKILL.md`, `500 0` for `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py`). Such a diff is neither empty nor confined to this cycle, so never use `c939b5b8` to prove byte-identity or to isolate a change this remediation cycle made; use `a9e2463c` for both. `[P0-T8]` records these full-addition numstats as the pre-remediation inventory value for those paths, which is the correct recorded value, not an anomaly.
- No task in this plan is conditional. `SKIPPED` is not an authorized outcome for any command-bearing task. Where a task expects a non-zero exit code, the task text states the expected code explicitly and the non-zero result is the required outcome.
- `[expect-fail]` tags the three command-bearing Phase 2 tasks whose runs must exit non-zero ([P2-T2], [P2-T4], [P2-T5]); each states its expected non-zero exit code and names its own auditable evidence artifact under `<FEATURE>/evidence/regression-testing/`. [P2-T1] and [P2-T3] author the failing tests, run no command, and therefore carry no `[expect-fail]` tag and no fail-before artifact of their own.
- Black and Ruff enforce an 88-character line length in this repository. Any task that appends a keyword argument to an existing call site must wrap that call and must count the added lines against the file's 500-line budget (see `## Test-Module Relocation Arithmetic`).

## Two Design Corrections

This cycle makes two corrections to F6's own design. Both concern the same guarantee — that two
items scheduled into the same cohort never share a conflict edge — and both are corrections to
functions this feature authored, not to an upstream contract F6 merely consumes.

### C1 — Admission ignored not-yet-launched current-cohort members (finding R1 / B1 / D1)

**Corrected rule.** A candidate is admitted into the current cohort if and only if it shares no
conflict edge with any member of the current cohort — both the `in_flight` (pinned) members and
the scheduled/unstarted members. Any conflict with a current-cohort member defers the candidate
and triggers the recolor.

Verified against the landed item-state model:

- Unstarted (recolorable) states are exactly `proposed | admitted | prepared | scheduled` — `scripts/dev_tools/_parallel_mutation_models.py:98-100` (`UNSTARTED_ITEM_STATES`), matching the eight-member item-state enum fixed by `.claude/rules/parallel-orchestration.md` invariant 6.
- Pinned is exactly `in_flight` — `scripts/dev_tools/_parallel_mutation_models.py:103` (`PINNED_ITEM_STATE`).
- `scheduled` items are recolorable under the existing pinning model. `recolor_unstarted` colors the vertex set `unstarted_items`, which includes `scheduled`, and excludes only `pinned`. A `scheduled` member of the current cohort may therefore be moved to another cohort by a recolor without violating any invariant, which is precisely what makes "defer and recolor" a valid remedy for a candidate that conflicts with a `scheduled` current-cohort member.
- `max_concurrency` caps simultaneously in-flight items independently of cohort size and each freed slot is refilled with the next unstarted item of the SAME current cohort in ascending item-key order (`.claude/skills/parallel-orchestrate/SKILL.md` section `## Cohort Barrier and Max-Concurrency Slot Filling`), so the current cohort durably holds not-yet-launched `scheduled` members.
- The amended rule strictly generalizes the previous one, because every `in_flight` item is a member of the current cohort. The pinning invariant is unchanged.

### C2 — `recolor_unstarted` dropped the pinned CONSTRAINT along with the pinned items

**The defect.** `recolor_unstarted` (`scripts/dev_tools/parallel_mutation_protocol.py:164-235`,
whose induced-edge comment and comprehension are at lines 217-224)
builds `induced_edges` keeping an edge only when BOTH endpoints are unstarted, and its comment
claims that "dropping the rest is what keeps pinned items out of the coloring input". Dropping
those edges removes the pinned VERTICES from the coloring input, which is correct, but it also
removes the pinned CONSTRAINT, which is not. F2's `compute_cohorts` documents that "a key that
appears in no edge is an isolated vertex and lands in cohort 0"
(`scripts/dev_tools/parallel_cohort_computation.py`, `compute_cohorts` docstring). The cohort
barrier increments `current_cohort` only on durable confirmation that every cohort-`N` item is
`merged` or `worktree_removed` (`.claude/skills/parallel-orchestrate/SKILL.md:113-118`), and an
`in_flight` item is neither, so `current_cohort` cannot advance while any item runs.

Composing those three facts: a candidate deferred BECAUSE it conflicts with an in-flight item has
that edge dropped, becomes an isolated vertex, and is assigned cohort index 0. When
`current_cohort == 0`, index 0 IS the current cohort, so the candidate rejoins the very pinned
item it conflicts with and launches alongside it. The deferral accomplishes nothing on the
pinned-conflict trigger, which is the original trigger the design intended to handle. Without C2,
C1's fix is cosmetic on its primary case.

**Corrected rule — the pinned-barrier offset.** After any admission decision is applied and any
recolor is applied, no two items assigned to the same cohort may share a conflict edge, including
edges to pinned items. `recolor_unstarted` achieves that as follows.

1. The pinned items occupy cohort index `current_cohort` for as long as they run, because the
   cohort barrier cannot advance `current_cohort` while any item is `in_flight`. `current_cohort`
   is therefore the pinned items' index and becomes a required input.
2. Let `crosses_pinned` be true exactly when some conflict edge joins a key in
   `unstarted_items` to a key in `pinned`. This is computed from the full edge list BEFORE the
   induced subgraph drops those edges.
3. `cohort_offset = current_cohort + 1` when `crosses_pinned`, otherwise `current_cohort`.
4. Each unstarted key's final cohort index is `cohort_offset + local_index`, where `local_index`
   is the color-class index F2's `compute_cohorts` assigned over the induced unstarted subgraph.

**Why this formulation is correct.**

- **Independence is preserved exactly.** The offset is a single uniform shift applied to every
  color class, so the mapping from local index to final index is injective. Two unstarted items
  that F2 placed in different classes remain in different cohorts; two that F2 placed in the same
  class share no edge by F2's own guarantee. No non-uniform or per-item remapping is used,
  because a non-uniform map could collapse two distinct classes onto one index and reintroduce a
  contention violation.
- **The pinned constraint is honoured.** When `crosses_pinned`, every unstarted index is at least
  `current_cohort + 1`, strictly greater than the pinned items' index, so no unstarted item — in
  particular not the deferred candidate — can share a cohort with any pinned item.
- **Concurrency is not sacrificed when there is nothing to protect.** When no unstarted item
  conflicts with any pinned item, `cohort_offset == current_cohort` and unstarted items may share
  the running cohort, which is safe and preserves `max_concurrency` slot filling.
- **Backward compatible where it is correct to be.** With `pinned` empty and `current_cohort == 0`
  the assignment is identical to the pre-fix assignment, so every existing pinned-free scenario
  keeps its expected values.
- **Pinned items still never move.** They are absent from the result, exactly as before. No
  pinned item is assigned, reassigned, or named in `cohort_assignments`.
- **F2 is untouched.** No part of the coloring, the vertex ordering, or the `(-degree, item_key)`
  tie-break is changed or reimplemented; `compute_cohorts` is still called with the induced
  subgraph and its local indices are still the only coloring input to the result.

**Why the two naive formulations were rejected.**

- *Re-index from 0* is the pre-fix behavior. It violates the contention guarantee as shown above,
  and it can also violate F3 invariant 14 whenever `current_cohort` exceeds the recolored cohort
  count minus one, and can starve items by placing them in an already-drained cohort index.
- *Unconditional `+1` offset* would evacuate the running cohort of its not-yet-launched
  `scheduled` members even when no unstarted item conflicts with a pinned item, needlessly
  reducing concurrency and breaking correct existing behavior for the pinned-free case with no
  correctness gain.

**F3 invariants 13 and 14 remain satisfiable.** This is asserted here and PROVEN by `[P4-T11]`
against the landed validator, not by assertion alone.

- **Invariant 13** (every non-withdrawn item appears in exactly one current-generation cohort):
  the result covers every key of `unstarted_items` exactly once, because the offset map is
  injective and `compute_cohorts` partitions its vertex set. Pinned items are absent from the
  result and retain their membership in the cohort at index `current_cohort`, which the
  orchestrator preserves rather than rewrites. `merged`, `withdrawn`, and `blocked` items are
  exempt by the invariant's own text. Cohorts below `current_cohort` were drained before the
  barrier advanced — every member `merged` or `worktree_removed` — so no non-exempt item is left
  in a lower index. The union of the pinned cohort and the offset assignment therefore covers
  every non-withdrawn item exactly once.
- **Invariant 14** (`current_cohort` must not exceed the maximum current-generation index):
  `cohort_offset >= current_cohort`, so whenever `unstarted_items` is non-empty the maximum
  assigned index is at least `current_cohort`. When `unstarted_items` is empty the result is
  empty and the pinned items' cohort at index `current_cohort` is itself the maximum, giving
  equality. In neither case does `current_cohort` exceed the maximum.

**Divergence.** C2 amends the contract of `recolor_unstarted`, which is F6's own function. It
does not amend `.claude/rules/**`, adds no F3 field or enum member, moves no pinned item, and
does not touch F5's `## Cohort Barrier and Max-Concurrency Slot Filling` section or any section
of `.claude/skills/parallel-orchestrate/SKILL.md` other than the reserved
`## Mutation Protocol (F6)`.

## Residual Gap Assessment

After C1 and C2, no residual gap remains that is distinct from the pre-existing, already-recorded
caller-side obligation. The engine's guarantee is complete for the inputs it is given:

- the admit branch cannot place a candidate in a cohort with a conflicting member, pinned or
  unstarted (C1);
- the defer branch cannot place any unstarted item in the pinned items' cohort when a
  candidate-to-pinned edge exists (C2);
- within the unstarted set, independence is F2's guarantee, preserved by the uniform offset;
- the consumer write path cannot produce a duplicate current-generation cohort index when the
  offset is not applied, because [P5-T1], [P5-T2], and [P5-T3] state the single-entry-per-index
  merge obligation and [P4-T11] proves both its sufficiency and its necessity against the landed
  validator.

The only remaining way to co-schedule conflicting work is for a CALLER to supply an untrue
`current_cohort_members`, `in_flight`, or `current_cohort` value — for example by reading a stale
checkpoint instead of re-deriving durable state. That is not a new residual and not a gap in the
engine: it is the cache-doctrine obligation already recorded in `<FEATURE>/spec.md`
§ Constraints & Risks item 4 and already enforced by the mandatory re-derivation step in
`.claude/skills/parallel-add/SKILL.md` § Re-Derive Durable State Before Applying Anything. A pure
function cannot verify the truth of its own arguments. `[P5-T1]`, `[P5-T2]`, and `[P5-T3]`
therefore add the explicit caller obligation to write the returned indices verbatim and to derive
both new arguments from the re-verified durable state.

Consequently the `docs/features/potential/` entry that revision 1 planned for this observation
(`2026-08-09-parallel-recolor-pinned-edge-visibility.md`) is NOT created, and the task that
created it is deleted. The only `docs/features/potential/` entry this cycle creates is the R4
TypeScript-parity deferral (`[P6-T7]`).

## Mandated Signatures (normative for this cycle)

```python
def decide_admission(
    candidate: int,
    conflict_edges: Sequence[tuple[int, int]],
    in_flight: frozenset[int],
    *,
    current_cohort_members: frozenset[int],
) -> AdmissionDecision:


def recolor_unstarted(
    unstarted_items: Sequence[int],
    conflict_edges: Sequence[tuple[int, int]],
    pinned: frozenset[int],
    current_generation: int,
    *,
    current_cohort: int,
) -> RecolorResult:
```

- `current_cohort_members` and `current_cohort` are **required keyword-only** parameters with
  **no default**. A default would silently preserve the defective behavior, and keyword-only
  placement makes it impossible to pass either value positionally where a different set or a
  different integer belongs. `current_cohort` in particular must not be positional: it would sit
  beside `current_generation`, another `int`, where a transposition would be silent.
- `in_flight` is retained on `decide_admission` and stays semantically distinct: it is the
  pinning set. The two sets are never merged in the signature, only in the decision — the
  candidate is deferred when a conflict edge joins it to any key in
  `in_flight | current_cohort_members`.
- `current_cohort` is named for F3's top-level `current_cohort` field so its derivation is
  unambiguous: it is the index the pinned items occupy, read from the re-verified checkpoint.
- Return values are unchanged: `AdmissionDecision` with `ADMIT_CURRENT_COHORT` or
  `DEFER_AND_RECOLOR`; `RecolorResult` with `cohort_assignments` and
  `generation == current_generation + 1`. No value object, enum, or exception TYPE is added or
  changed. The negative-`current_cohort` guard raises F2's existing `ParallelCohortInputError`,
  which `recolor_unstarted`'s docstring already documents as part of its contract.
- Both functions stay pure, fully type-hinted, `int`-keyed, and free of I/O and clock reads. Both
  keep the delegation to F2's `compute_cohorts` without reimplementing any coloring.

## Test-Module Relocation Arithmetic

Measured on disk at the pinned base, and to be re-captured as evidence by `[P0-T9]` before any
edit:

| File | Baseline lines | `recolor_unstarted` call sites | `decide_admission` call sites |
| --- | --- | --- | --- |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol.py` | 498 | 8 (lines 140, 153, 168, 181, 191, 201, 214, 347) | 9 (lines 331, 339, 357, 375, 382, 391, 402 ×2, 409) |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py` | 499 | 5 (lines 172, 220, 291, 346, 493) | 3 (lines 335, 388, 492) |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` | 500 | 0 | 0 |
| `tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py` | n/a | 0 | 0 |

Wrapping cost: the existing single-line call sites are 78 to 86 characters at their indentation.
Appending `, current_cohort=0` (18 characters) or
`, current_cohort_members=frozenset({...})` pushes every one of them past the 88-character limit,
so Black rewrites each as a three-line call. Each converted single-line call site therefore costs
**+2 lines**. Headroom cannot be assumed; the two 498/499-line modules must SHED content, not
absorb it.

`tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` is at exactly 500 lines, has no
call site for either changed function, and must remain **byte-unchanged**. No task in this plan
edits it; `[P7-T9]` and `[P7-T10]` Check I prove that.

Resulting module layout. Four new sibling modules are created so that no file approaches the cap:

| Module | Status | Purpose | Budget |
| --- | --- | --- | --- |
| `tests/scripts/dev_tools/test_parallel_mutation_admission.py` | NEW | Unit scenarios for `decide_admission` under the corrected current-cohort rule, plus the C1 regression test. Receives the relocated `TestAdmissionOverAllItems` class, corrected. | `<= 200` |
| `tests/scripts/dev_tools/test_parallel_mutation_recolor.py` | NEW | Unit scenarios for `recolor_unstarted` under the pinned-barrier offset, plus the C2 regression test. Receives the relocated `TestPinnedItemsNeverMove` class with its 6 call sites updated. | `<= 320` |
| `tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py` | NEW | Seeded property suite: the composed contention property P4 over full assignment maps, the corrected per-function admission property, and the relocated P3 pin-stability property. The only new module that uses `random.Random`. | `<= 400` |
| `tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py` | NEW | Binds the corrected recolor output to F3's LANDED validator: runs `validate_parallel_orchestrator_state_text` over a constructed in-memory checkpoint and asserts zero errors for invariants 12, 13, and 14. | `<= 260` |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol.py` | EDIT | Sheds `TestAdmissionOverAllItems` (lines 325-411, approximately 87 lines) and `TestPinnedItemsNeverMove` (lines 128-205, approximately 78 lines) and their now-unused imports; keeps 1 recolor call site (line 214) which is wrapped (+2); gains the four R2 binding tests (approximately +48). Net approximately 498 − 165 − 4 + 2 + 48 = **approximately 379**. | `<= 500` |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py` | EDIT | Sheds `TestPropertyThreePinStability` (lines 299-368, approximately 70 lines) and the per-function admission property (lines 374-398, approximately 25 lines); keeps P1, P2, purity and their 4 remaining recolor call sites (lines 172, 220, 291, 493) plus 1 remaining admission call site (line 492) (+10 wrapping over five sites); `GeneratedRun` gains a `current_cohort` attribute (+4); two P1/P2 tests are corrected in place at approximately constant size. Net approximately 499 − 95 + 14 = **approximately 418**. | `<= 500` |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` | UNCHANGED | Byte-identical to the pinned base. | 500 exactly |

Each new property module is self-contained: it defines its own seeded `random.Random(seed)`
generator and imports from no other test module. That duplication is deliberate and is the cost
of the 500-line cap; `hypothesis` is absent and stays absent.

## Two Tests That Currently Codify the Defects

Both must be corrected, and neither correction is a weakening. `[P4-T12]` proves no scenario was
dropped.

1. `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py:278`
   `test_edges_touching_a_pinned_vertex_do_not_constrain_the_coloring` asserts the C2 defect
   directly. Under the corrected contract, pinned edges still do not constrain the LOCAL coloring
   — F2 receives the same induced subgraph — but they DO constrain the final assignment through
   the offset. The test is rewritten to assert both halves of that statement.
2. `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py:252`
   `test_cohort_indices_are_contiguous_from_zero` asserts a zero base that the offset replaces.
   The test is rewritten to assert contiguity from the computed offset and that the offset itself
   equals the rule in `## Two Design Corrections`, which is a strictly stronger assertion than
   contiguity from zero.

## Finding Disposition (1 Blocking + 5 Partial + 1 preflight-identified design gap)

| Finding | Class | Disposition | Tasks |
| --- | --- | --- | --- |
| R1 / B1 / D1 — admission ignores not-yet-launched current-cohort members | Blocking | RESOLVED IN CODE by spec+AC amendment, `decide_admission` signature and logic change, consumer updates, a regression test with fail-before/pass-after evidence, and the composed contention property | P1-T1, P1-T3, P1-T4, P1-T5, P1-T6, P1-T8, P1-T11, P1-T13, P2-T1, P2-T2, P3-T1, P3-T2, P4-T1, P4-T2, P4-T8, P5-T1, P5-T3, P7-T11, P3-T10 |
| C2 (preflight REV-5) — `recolor_unstarted` drops the pinned constraint with the pinned vertices | Blocking (adjudicated) | RESOLVED IN CODE by spec+AC amendment, `recolor_unstarted` signature and logic change, comment and docstring correction, consumer updates, a regression test with fail-before/pass-after evidence, the composed contention property, and an F3-invariant binding test | P1-T2, P1-T3, P1-T5, P1-T7, P1-T9, P1-T12, P1-T13, P2-T3, P2-T4, P3-T3, P3-T4, P3-T5, P3-T6, P3-T7, P4-T3, P4-T4, P4-T5, P4-T8, P4-T10, P4-T11, P5-T1, P5-T2, P5-T3, P7-T11, P7-T12 |
| R2 / P1 — F3 op-classification tuples copied without a binding assertion | Partial | RESOLVED by importing F3's three constants at both sites and deleting the local copies, plus binding tests | P6-T1, P6-T2, P6-T3 |
| R3 / P2 — FR9 invariant 3 narrower than its spec/AC wording | Partial | RESOLVED by amending `spec.md` FR9 invariant 3 and AC S9 to the delivered two-signal formalization (documentation only; no code change) | P1-T10, P7-T11 |
| R4 / P3 — Python/TypeScript parity gap for the three FR9 invariants | Partial | DEFERRED with recorded rationale: no AC required it, F6 has no TypeScript seam of its own (the only seam is F7's, which F6 must not touch), and pulling it into scope would require a further spec amendment. No TypeScript port task exists in this plan | P6-T7 |
| R5 / P4 — unauthorized `# noqa: S311` | Partial | RESOLVED by authorizing S311 through confined `pyproject.toml` per-file-ignores for the two seeded-RNG test modules and deleting both `# noqa: S311` comments | P6-T4, P6-T5 |
| R6 / P5 — `# noqa: S603` rationale on an inert line | Partial | RESOLVED by deleting the inert directive-shaped comment and placing a non-directive rationale immediately above the effective single-line suppression (the verbatim one-line format cannot coexist with the 88-character limit; the arithmetic is recorded) | P6-T6 |

Advisory items A1–A9 are not remediated by this plan and are not merge gates. The pre-existing
Pester failure at `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:142` is explicitly
out of scope, must remain the only PowerShell failure, and must not be edited.

## Constraints (binding on every task)

1. No field and no enum member is added to F3's `mutations[]`, `drift_events[]`, or `conflict_edges[]`, or to any item-state or merge-status enum.
2. No file under `.claude/rules/**` is modified.
3. No `enforce-epic-*` hook, epic validator, epic skill, or epic agent is modified.
4. The fully executed base plan `<FEATURE>/plan.md` is not modified by any task.
5. No Python dependency is added. `hypothesis` is absent and stays absent; property tests use seeded `random.Random(seed)` with the seed printed on failure.
6. No test creates or uses a temporary file; no test invokes live `gh` or `git`; the injected clock seam stays mandatory.
7. Every production and test file stays `<= 500` lines, per the budgets in `## Test-Module Relocation Arithmetic`. `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` must remain byte-unchanged at exactly 500 lines.
8. Shared-file confinement continues to apply: the only edit to `.claude/skills/parallel-orchestrate/SKILL.md` is inside `## Mutation Protocol (F6)` (lines 435-580 at the pinned base); no section is relocated, reflowed, reordered, or retitled; `## Cohort Barrier and Max-Concurrency Slot Filling`, `## Enforcement Hooks (F7)`, and `## Radius Drift Detection (F8)` are not touched.
9. Every `.claude/**` file edited must be mirrored byte-for-byte into `extensions/drm-copilot/resources/claude-customizations/.claude/**`, which the landed contract test `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` enforces.
10. F2 (`scripts/dev_tools/parallel_cohort_computation.py`) is not modified. The pinned-barrier offset is applied entirely inside F6's `recolor_unstarted`.
11. `<FEATURE>/spec.md` keeps exactly 15 acceptance criteria (S1–S15) and `<FEATURE>/user-story.md` exactly 9 (U1–U9). Text amendments are permitted; addition, removal, and renumbering are not. The spec version is bumped once for the whole cycle, to 1.2.
12. `POPULATED_RESERVED_HEADINGS` stays a one-line append for F7 and F8; no task in this plan touches it.

## Files In Scope

| File | Change |
| --- | --- |
| `<FEATURE>/spec.md` | FR1 step 4; FR4 headline and requirements; combined design-correction note; Recompute Boundary wording; API/CLI surface snippets for both functions; Test Strategy scenario 4, new scenario 9, and property P4; FR9 invariant 3; AC S2, S5, S9; version bump to 1.2 |
| `<FEATURE>/user-story.md` | AC U1 and U5 text |
| `scripts/dev_tools/parallel_mutation_protocol.py` | `decide_admission` signature, logic, docstring; `recolor_unstarted` signature, offset logic, negative guard, docstring, induced-subgraph comment; module docstring pinning paragraph |
| `scripts/dev_tools/_parallel_mutation_models.py` | `RecolorResult` docstring (absolute cohort indices); `AdmissionOutcome` `Attributes:` docstring (current-cohort rule); import F3's op-classification constants; delete local copies |
| `scripts/dev_tools/_parallel_mutation_entries.py` | `build_add_entry` `deferred` argument docstring only |
| `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` | import F3's op-classification constants; delete local copies |
| `scripts/dev_tools/parallel_mutation_abandon_cli.py` | S603 comment placement |
| `.claude/skills/parallel-add/SKILL.md` (+ bundle mirror) | FR1 admission procedure; recolor call shape; verbatim-index obligation |
| `.claude/skills/parallel-remove/SKILL.md` (+ bundle mirror) | recolor call shape; verbatim-index obligation |
| `.claude/skills/parallel-orchestrate/SKILL.md` (+ bundle mirror) | `## Mutation Protocol (F6)` section only |
| `tests/scripts/dev_tools/test_parallel_mutation_admission.py` | NEW |
| `tests/scripts/dev_tools/test_parallel_mutation_recolor.py` | NEW |
| `tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py` | NEW |
| `tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py` | NEW |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol.py` | remove two relocated classes and unused imports; wrap the one remaining recolor call site; add the R2 binding assertions |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py` | update remaining call sites; add `current_cohort` to `GeneratedRun`; correct the two defect-codifying tests; remove two relocated blocks |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` | UNCHANGED (byte-identical; verified) |
| `pyproject.toml` | confined `[tool.ruff.lint.per-file-ignores]` addition only |
| `docs/features/potential/` | one new record (R4 deferral only) |

## Implementation Plan (Atomic Tasks)

### Phase 0 — Policy Reads and Remediation Baseline Capture

- [x] [P0-T1] Read the policy files in the required order and record the read evidence.
  - Order: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/python.md`, `.claude/rules/python-suppressions.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/self-explanatory-code-commenting.md`, `.claude/rules/orchestrator-state.md`, `.claude/rules/parallel-orchestration.md`, `.claude/rules/tonality.md`
  - Artifact: `<FEATURE>/evidence/remediation-baseline/phase0-instructions-read.md` with `Timestamp:`, `Policy Order:`, and the explicit list of files read
  - Acceptance: artifact exists with all required fields and the list matches the order above
- [x] [P0-T2] Read the four remediation input artifacts plus `<FEATURE>/spec.md`, `<FEATURE>/user-story.md`, `<FEATURE>/plan.md`, `.claude/rules/parallel-orchestration.md`, and the `F6` section of `docs/features/epics/parallel-orchestration/epic.md`, and record the finding inventory read from the artifacts themselves.
  - Artifact: `<FEATURE>/evidence/remediation-baseline/remediation1-inputs-review.md` with `Timestamp:`, the list of files read, and a table of every Blocking and Partial finding with its ID, location, and planned disposition task IDs, plus a separate row for the preflight-identified design gap C2 marked as adjudicated-in-scope for this cycle
  - Acceptance: the table lists exactly one Blocking (R1/B1/D1) and five Partial (R2–R6) findings from the audit artifacts, each with at least one task ID from this plan, and one additional C2 row; the audit-derived counts match `<FEATURE>/remediation-inputs.2026-08-09T00-19.md`
- [x] [P0-T3] Capture the Python lint baseline for this cycle.
  - Command: `poetry run ruff check .`
  - Artifact: `<FEATURE>/evidence/remediation-baseline/remediation1-baseline-py-lint.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: artifact exists with the exit code recorded
- [x] [P0-T4] Capture the Python type-check baseline for this cycle.
  - Command: `poetry run pyright`
  - Artifact: `<FEATURE>/evidence/remediation-baseline/remediation1-baseline-py-typecheck.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: artifact exists with the exit code and error/warning counts recorded
- [x] [P0-T5] Capture the Python test and coverage baseline for this cycle with numeric values.
  - Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
  - Artifact: `<FEATURE>/evidence/remediation-baseline/remediation1-baseline-py-test-coverage.md`; `Output Summary:` MUST record the numeric line and branch coverage percentages, the passed/failed test counts, and the per-file coverage of the seven F6 production modules (no placeholders)
  - Acceptance: artifact records numeric line and branch coverage; the recorded values are the comparison basis for [P7-T8] (expected starting point: line 92.05%, branch 84.19%)
- [x] [P0-T6] Capture the PowerShell analyzer baseline for this cycle.
  - Command: MCP tool `mcp__drm-copilot__run_poshqc_analyze`
  - Artifact: `<FEATURE>/evidence/remediation-baseline/remediation1-baseline-ps-analyze.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` with the finding count)
  - Acceptance: artifact records the exit code and finding count
- [x] [P0-T7] Capture the PowerShell Pester test and coverage baseline for this cycle with numeric values.
  - Command: MCP tool `mcp__drm-copilot__run_poshqc_test`
  - Artifact: `<FEATURE>/evidence/remediation-baseline/remediation1-baseline-ps-test-coverage.md`; `Output Summary:` MUST record passed/failed/skipped counts, the numeric line coverage percentage, and the name of the single pre-existing failure
  - Acceptance: artifact records numeric coverage and names `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1:142` as the only failure
- [x] [P0-T8] Capture the pre-remediation diff inventory against the pinned base.
  - Commands: `git diff --stat c939b5b8 -- .`; then `git diff --numstat c939b5b8 -- <path>` for each of `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/skills/parallel-add/SKILL.md`, `.claude/skills/parallel-remove/SKILL.md`, `scripts/dev_tools/validate_parallel_orchestrator_state.py`, `.claude/settings.json`, `pyproject.toml`, `poetry.lock`, `docs/features/active/2026-08-07-parallel-mutation-protocol-442/plan.md`, `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py`
  - Artifact: `<FEATURE>/evidence/remediation-baseline/remediation1-baseline-diff-inventory.md` (`Timestamp:`, `Command:` per check, `EXIT_CODE:` per check, `Output Summary:` = the per-file numstat values before remediation)
  - Acceptance: artifact records the pre-remediation numstat for each listed path, including that `pyproject.toml` and `poetry.lock` are unchanged at baseline; every listed path exists at `a9e2463c`, so no ABSENT-AT-BASE condition can arise for this cycle's checks
- [x] [P0-T9] Capture the test-module line-count and call-site baseline that the relocation arithmetic depends on.
  - Commands: a line-count command over `tests/scripts/dev_tools/test_parallel_mutation_protocol.py`, `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py`, `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py`, `tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py`, and `scripts/dev_tools/parallel_mutation_protocol.py`; then `grep -rn "recolor_unstarted\|decide_admission" tests scripts .claude`
  - Artifact: `<FEATURE>/evidence/remediation-baseline/remediation1-baseline-test-module-sizes.md` (`Timestamp:`, `Command:` per check, `EXIT_CODE:` per check, `Output Summary:` = per-file line counts and the enumerated call sites with line numbers)
  - Acceptance: the recorded counts confirm the table in `## Test-Module Relocation Arithmetic` (498, 499, 500 respectively) and confirm that `test_parallel_mutation_protocol_ops.py` contains zero call sites for either changed function; any divergence from the table is recorded and the plan's budgets are recomputed before Phase 1 begins

### Phase 1 — Spec and Acceptance-Criteria Amendment (Two Design Corrections)

- [x] [P1-T1] Amend `<FEATURE>/spec.md` FR1 step 4 to the corrected admission rule (C1).
  - Replace the two bullets of step 4 (currently at `spec.md:46-48`; line 45 is the step heading) so that the admit branch reads: no conflict with any member of the current cohort — neither an `in_flight` (pinned) member nor an unstarted (`proposed`/`admitted`/`prepared`/`scheduled`) member scheduled into the current cohort — admit into the current cohort, no recompute; otherwise defer to a future cohort and recolor the unstarted subgraph (recompute; `recolor_generation` increments by exactly one)
  - Acceptance: FR1 step 4 no longer contains an in-flight-only admission condition; the deferral branch is unchanged in effect; no other FR is edited by this task
- [x] [P1-T2] Amend `<FEATURE>/spec.md` FR4 to state the pinned-barrier offset (C2).
  - Edits: the bold headline (`spec.md:89-90`) becomes "In-flight items are pinned; scheduling is recomputed only over the not-yet-started subgraph; recoloring is a pure function of `(remaining subgraph, pinned set, pinned cohort index)`"; the first requirements bullet (`spec.md:94-97`) adds the current cohort index as an input and states that the returned assignment places every unstarted item at an index at or above `current_cohort`, and strictly above it whenever any conflict edge joins an unstarted item to a pinned item; add one bullet stating that the offset is a single uniform shift so that F2's color classes remain distinct indices and independence is preserved exactly
  - Acceptance: FR4 states the offset rule and both of its cases; the "never assigns or moves a pinned item" requirement is unchanged; the purity requirement is unchanged; no other FR is edited by this task
- [x] [P1-T3] Add a combined "Design corrections (spec 1.2)" note to `<FEATURE>/spec.md` immediately after FR1, recording the rationale for BOTH C1 and C2.
  - Required content for C1: the pre-1.2 rule checked in-flight members only and was inherited verbatim from `docs/research/2026-08-07-parallel-orchestration-design-research.md` line 173; `max_concurrency` caps simultaneously in-flight items independently of cohort size and each freed slot is refilled with the next unstarted item of the SAME current cohort in ascending item-key order (cite `.claude/skills/parallel-orchestrate/SKILL.md` section `## Cohort Barrier and Max-Concurrency Slot Filling` by exact heading text), so the current cohort durably holds not-yet-launched `scheduled` members; a cohort is an independent set only because F2's coloring produced it, and a candidate inserted without a recolor is outside that coloring; the amended rule strictly generalizes the previous one; the pinning invariant is unchanged
  - Required content for C2: dropping the pinned-endpoint edges removed the pinned VERTICES correctly but also removed the pinned CONSTRAINT; F2's `compute_cohorts` places an edge-free key in cohort 0; the cohort barrier cannot advance `current_cohort` while any item is `in_flight`, so index 0 is the current cohort in exactly the situation the deferral was meant to resolve; the pinned-barrier offset rule and its two cases; the uniform-shift argument for preserving independence; the statement that F3 invariants 13 and 14 remain satisfiable and are proven by an executable binding test rather than by assertion; the statement that F2 is not modified
  - Required for both: an explicit statement that the amendments deliberately diverge from the design research and that `docs/research/2026-08-07-parallel-orchestration-design-research.md` is NOT amended by this feature
  - Acceptance: the note exists as one section covering both corrections, states every point listed above, cites the F5 slot-filling section by exact heading text and the design-research line, and explicitly records the deliberate divergence
- [x] [P1-T4] Amend the `## Recompute Boundary and Mutation-Log Entry Contents` wording in `<FEATURE>/spec.md` for coherence with C1, and state explicitly that C2 leaves the generation arithmetic unchanged.
  - Edits: recompute item 1 ("Deferred add", `spec.md:200-201`) reads "where the candidate conflicts with any member of the current cohort (in-flight or unstarted)"; non-recompute item 1 (`spec.md:211-212`) reads "Admission into the current cohort with no conflict against any current-cohort member"; add one sentence stating that the pinned-barrier offset changes only WHICH index an unstarted item receives and never how many times the generation increments, so a recolor still increments `recolor_generation` by exactly one
  - Acceptance: neither item states an in-flight-only condition; the per-op entry-contents table rows, their values, and the generation arithmetic are byte-identical to before this task
- [x] [P1-T5] Amend the `## API / CLI Surface` snippets in `<FEATURE>/spec.md` to the two mandated signatures.
  - Replace both snippets (`spec.md:285-297`) with the forms stated in this plan's `## Mandated Signatures` section, including both keyword-only markers, and correct the snippets' stale `str` key types to `int` for both functions
  - Acceptance: the `decide_admission` snippet shows `current_cohort_members` and the `recolor_unstarted` snippet shows `current_cohort`, each as a required keyword-only parameter with no default; both snippets use `int` keys; `is_closed_mode_complete` is unchanged apart from its key type
- [x] [P1-T6] Amend `<FEATURE>/spec.md` `## Test Strategy` scenario 4 (C1).
  - Scenario 4 must enumerate four cases: conflict with an in-flight item defers; conflict with a `scheduled` member of the current cohort defers and recolors (the case the previous wording got wrong); conflict only with an unstarted item that is NOT in the current cohort admits, since the cohort barrier keeps the two from running concurrently; no conflict admits with no generation change
  - Acceptance: scenario 4 no longer contains the sentence asserting that an unstarted conflict is "placed by the coloring, not rejected" without the current-cohort qualification; no other scenario is edited by this task
- [x] [P1-T7] Add `## Test Strategy` scenario 9 to `<FEATURE>/spec.md` for the pinned-barrier offset (C2), and replace the planned property addition with property P4.
  - Scenario 9 must enumerate four cases: an unstarted item conflicting with a pinned item is assigned an index strictly greater than `current_cohort`; with no unstarted-to-pinned edge the assignment starts at `current_cohort` exactly; the offset is uniform, so F2's color classes remain distinct indices; a negative `current_cohort` is rejected
  - Add to the property list, after P3 and without renumbering P1–P3: "**P4 (composed contention invariant):** over arbitrary conflict graphs, arbitrary pinned/unstarted partitions, and arbitrary admission-and-recolor sequences, no cohort in the resulting assignment contains two items sharing a conflict edge, counting edges to pinned items"
  - Acceptance: scenario 9 exists with all four cases; P1, P2, and P3 keep their labels and text; P4 is additive and is worded as the full-assignment invariant, not as an admission-only claim
- [x] [P1-T8] Amend `<FEATURE>/spec.md` acceptance criterion S2 (C1).
  - Change only the admission clause of S2 (`spec.md:536`) from "admits into the current cohort only when the candidate conflicts with no in-flight item" to "admits into the current cohort only when the candidate conflicts with no member of the current cohort, in-flight or unstarted"; leave the rest of S2 and its `[x]` marker unchanged
  - Acceptance: S2's text carries the amended rule; the `## Acceptance Criteria` list still contains exactly 15 items in the same order with the same labels
- [x] [P1-T9] Amend `<FEATURE>/spec.md` acceptance criterion S5 (C2).
  - Change only the recolor clause of S5 (`spec.md:539`) from "recoloring is a pure function of `(remaining subgraph, pinned set)`" to "recoloring is a pure function of `(remaining subgraph, pinned set, pinned cohort index)` and assigns every unstarted item an index strictly above the pinned items' index whenever any unstarted item conflicts with a pinned item"; keep the existing P1/P2/P3 clause and add P4 to the named property list within the same criterion; leave the rest of S5 and its `[x]` marker unchanged
  - Acceptance: S5's text carries the offset rule and names P4; the AC list still contains exactly 15 items with unchanged labels and order
- [x] [P1-T10] Amend acceptance criterion S9 and FR9 invariant 3 in `<FEATURE>/spec.md` to describe the delivered two-signal formalization (finding R3).
  - FR9 invariant 3 (`spec.md:173`) must state that the mode-dependent completion invariant is enforced from the two signals the F3 schema carries: a `mutations[]` `op == 'close'` record and an empty current-generation cohort set; that in `open` mode the close record must be terminal (nothing may follow it); and that the invariant deliberately does not fire on a healthy in-progress checkpoint or on an idle `open` run. Cite the module docstring `scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py:16-43`, which already documents the formalization, and record that F3's own invariant 20 under `require_complete` is what guards closed-mode completion and is deliberately not duplicated
  - Amend S9's clause "and the mode-dependent completion invariant" to name the same two-signal formalization; leave the rest of S9 and its `[x]` marker unchanged
  - Acceptance: FR9 invariant 3 and S9 both describe the two-signal formalization; the AC list still contains exactly 15 items with unchanged labels and order
- [x] [P1-T11] Amend acceptance criterion U1 in `<FEATURE>/user-story.md` (C1).
  - Change only the admission clause of U1 (`user-story.md:88`) to "admit into the current cohort only when the candidate conflicts with no member of the current cohort, in-flight or unstarted; otherwise defer to a future cohort and recolor the unstarted subgraph"; leave the rest of U1 and its `[x]` marker unchanged
  - Acceptance: U1 carries the amended rule; the `## Acceptance Criteria` list still contains exactly 9 items in the same order with the same labels
- [x] [P1-T12] Amend acceptance criterion U5 in `<FEATURE>/user-story.md` (C2).
  - Change only the recolor clause of U5 (`user-story.md:92`) to "recoloring is a pure function of `(remaining subgraph, pinned set, pinned cohort index)` and never places an unstarted item in the pinned items' cohort when the two conflict"; leave the rest of U5, including the determinism clause, and its `[x]` marker unchanged
  - Acceptance: U5 carries the offset rule; the AC list still contains exactly 9 items in the same order with the same labels
- [x] [P1-T13] Bump the `<FEATURE>/spec.md` version once for the whole cycle and record both amendments in evidence.
  - Edits: `- **Version:**` becomes `1.2 (design corrections: admission checks the full current cohort, not the in-flight subset; recoloring applies the pinned-barrier offset so a deferred candidate cannot rejoin its pinned conflict; FR9 invariant 3 wording reconciled to the delivered two-signal formalization)`; `- **Last Updated:**` becomes the execution timestamp. The version is bumped exactly once; it does not become 1.3
  - Artifact: `<FEATURE>/evidence/other/remediation1-spec-amendment-1.2.md` (`Timestamp:`, the exact before/after text of FR1 step 4, FR4, the Recompute Boundary items, both API snippets, Test Strategy scenarios 4 and 9, property P4, S2, S5, S9, U1, U5, and FR9 invariant 3; the rationale for each of C1 and C2; the cited F5 slot-filling section; the deliberate divergence from design-research line 173)
  - Acceptance: the spec version reads 1.2 and appears exactly once; the artifact records every amended passage as before/after text
- [x] [P1-T14] Verify the acceptance-criteria set integrity after the amendments.
  - Checks: count `- [` items under `## Acceptance Criteria` in `<FEATURE>/spec.md` (expected 15) and in `<FEATURE>/user-story.md` (expected 9); confirm no criterion was added, removed, reordered, or renumbered by this remediation cycle by inspecting `git diff a9e2463c -- <FEATURE>/spec.md <FEATURE>/user-story.md`
  - Artifact: `<FEATURE>/evidence/other/remediation1-ac-set-integrity.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` = the two counts and the list of criteria whose text changed)
  - Acceptance: counts are exactly 15 and 9; the only criteria whose text changed are S2, S5, S9, U1, and U5

### Phase 2 — Fail-Before Regression Demonstrations (Sequenced)

This phase runs BEFORE either engine change so both defects are demonstrated behaviorally against
the shipped implementation rather than through a signature error. The ordering is fixed and
explicit: the C1 demonstration ([P2-T1], [P2-T2]) completes first, then the C2 demonstration
([P2-T3], [P2-T4]), each executed against its own module in isolation so neither failure can be
mistaken for the other. [P2-T5] then runs the whole suite once with both regressions red. The
three command-bearing tasks ([P2-T2], [P2-T4], [P2-T5]) are tagged `[expect-fail]`; [P2-T1] and
[P2-T3] author the tests and run no command.

- [x] [P2-T1] Create `tests/scripts/dev_tools/test_parallel_mutation_admission.py` containing only the C1 regression test, written against the CURRENT three-argument `decide_admission` signature.
  - Scenario: item 100 is `in_flight`; item 200 is `scheduled` and is a member of the current cohort but not yet launched; candidate 300 conflicts with 200 only. The test calls `decide_admission(300, [(200, 300)], frozenset({100}))` and asserts `AdmissionOutcome.DEFER_AND_RECOLOR` with `triggers_recompute is True`
  - Constraints: literal `int` keys; no temp files; no subprocess; full type hints; module and test docstrings naming finding R1/B1 and the reason the case is unsafe; file within its `<= 200` budget
  - Acceptance: the file exists and contains exactly this one test; the assertion states the corrected expectation, so the test FAILS against the current engine. No production file is edited by this task
- [x] [P2-T2] [expect-fail] Run the C1 regression test alone and record the fail-before evidence.
  - Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_admission.py -v`
  - Required outcome: `EXIT_CODE: 1` with the assertion reporting `AdmissionOutcome.ADMIT_CURRENT_COHORT`
  - Artifact: `<FEATURE>/evidence/regression-testing/remediation1-c1-admission-cohort-independence.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` (the observed non-zero value), `Output Summary:` quoting the observed pre-fix outcome, a `## Fail-Before` heading, a `## Reproduction Premise` section (100 `in_flight`, 200 `scheduled` in the current cohort, candidate 300 conflicting with 200 only), and an `## Ordering` line stating that this demonstration precedes [P2-T4] and that no engine change has yet been made
  - Acceptance: the artifact records exit code 1 and the observed `ADMIT_CURRENT_COHORT` outcome under a `## Fail-Before` heading, and its `## Ordering` line names [P2-T4] as the next demonstration
- [x] [P2-T3] Create `tests/scripts/dev_tools/test_parallel_mutation_recolor.py` containing only the C2 regression test, written against the CURRENT four-argument `recolor_unstarted` signature.
  - Scenario: item 100 is `in_flight` and occupies cohort index 0, which is the current cohort; items 200 (`scheduled`) and 300 (the candidate just deferred) are unstarted; the only conflict edge is `(100, 300)`. The test calls `recolor_unstarted([200, 300], [(100, 300)], frozenset({100}), 7)` and asserts that the returned `cohort_assignments[300]` is NOT the pinned items' cohort index 0
  - The module docstring must state that 0 is the pinned items' index in this fixture, that the candidate was deferred precisely because of its conflict with item 100, and that co-scheduling the two is the contention violation the test forbids
  - Constraints: literal `int` keys; no temp files; no subprocess; full type hints; file within its `<= 320` budget
  - Acceptance: the file exists and contains exactly this one test; the pre-fix engine drops edge `(100, 300)` as non-induced, colors 200 and 300 as isolated vertices at index 0, and the assertion FAILS with an `AssertionError` rather than a `TypeError`, so the failure is behavioral. No production file is edited by this task
- [x] [P2-T4] [expect-fail] Run the C2 regression test alone and record the fail-before evidence.
  - Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_recolor.py -v`
  - Required outcome: `EXIT_CODE: 1` with the assertion reporting `cohort_assignments[300] == 0`
  - Artifact: `<FEATURE>/evidence/regression-testing/remediation1-c2-recolor-pinned-barrier.md` with `Timestamp:`, `Command:`, `EXIT_CODE:` (the observed non-zero value), `Output Summary:` quoting the observed pre-fix assignment mapping in full, a `## Fail-Before` heading, a `## Reproduction Premise` section, and an `## Ordering` line stating that [P2-T2] ran first, that this run is executed against its own module in isolation, and that no engine change has yet been made
  - Acceptance: the artifact records exit code 1 and the observed index-0 assignment for key 300 under a `## Fail-Before` heading, and its `## Ordering` line names [P2-T2] as the preceding demonstration
- [x] [P2-T5] [expect-fail] Run the whole Python suite once with both regressions red, and prove the failures are isolated to the two new tests.
  - Command: `poetry run pytest -q`
  - Required outcome: `EXIT_CODE: 1` with exactly two failing test ids — the [P2-T1] test and the [P2-T3] test — and no other failure
  - Artifact: `<FEATURE>/evidence/regression-testing/remediation1-regression-isolation.md` (`Timestamp:`, `Command:`, `EXIT_CODE:` = 1, `Output Summary:` = total counts plus the full list of failing test ids, and an `## Ordering` section stating the [P2-T2] → [P2-T4] → [P2-T5] sequence)
  - Acceptance: exactly the two expected failing ids appear and no others; `git diff a9e2463c --stat -- tests/` shows no deletion of an existing test file and no removed assertion; `git diff --numstat a9e2463c -- tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` reports no change

### Phase 3 — Engine Corrections

- [x] [P3-T1] Change `decide_admission`'s signature and decision logic in `scripts/dev_tools/parallel_mutation_protocol.py`.
  - Signature: exactly the form in this plan's `## Mandated Signatures` section — `current_cohort_members: frozenset[int]` is keyword-only and required, with no default
  - Logic: the candidate is deferred when any conflict edge joins it to a key in `in_flight | current_cohort_members`, checking both endpoint positions because edges are undirected; otherwise it is admitted. Keep the early return on the first qualifying edge, keep the function pure, keep `int` keys, add no I/O and no clock read, and add or change no value object, enum, or exception type
  - Constraints: the loop keeps an intent comment and the branch keeps a decision-logic comment per `.claude/rules/self-explanatory-code-commenting.md`
  - Acceptance: the signature matches the mandated form exactly; the union check is visible in the source; `AdmissionDecision`, `AdmissionOutcome`, and every other public name are unchanged
- [x] [P3-T2] Correct `decide_admission`'s docstring in `scripts/dev_tools/parallel_mutation_protocol.py`.
  - Delete the circular paragraph currently at lines 127-130 ("A conflict with an UNSTARTED item is deliberately not a deferral ... resolved by `recolor_unstarted`"), which is false on the admit branch because no coloring runs there and the candidate was absent when the last coloring ran
  - Replacement content: the corrected FR1 step 4 rule; an `Args:` entry for `current_cohort_members` stating that it is the full membership of the current cohort including its pinned and its not-yet-launched `scheduled` members, and why `in_flight` is retained separately (it is the pinning set, and the two must not be conflated); a statement that a conflict with an unstarted item OUTSIDE the current cohort is not a deferral because the cohort barrier prevents the two from running concurrently; and a statement that the deferral is what makes the recolor necessary, together with the pinned-barrier offset the recolor then applies
  - Acceptance: the circular paragraph is gone; the docstring documents all four parameters, the return contract, and the unchanged `Raises: None` contract; no claim in the docstring is false on either branch
- [x] [P3-T3] Change `recolor_unstarted`'s signature and add the pinned-barrier offset in `scripts/dev_tools/parallel_mutation_protocol.py`.
  - Signature: exactly the form in this plan's `## Mandated Signatures` section — `current_cohort: int` is keyword-only and required, with no default
  - Logic, in this order: keep the existing unstarted/pinned overlap guard unchanged; reject a negative `current_cohort` by raising F2's existing `ParallelCohortInputError` (imported from `scripts.dev_tools.parallel_cohort_computation`) with a literal message naming the invalid value and the non-negative requirement of F3 invariant 12, and with the invalid integer as `offending_value`; compute `crosses_pinned` from the FULL edge list as "some edge joins a key in `unstarted_items` to a key in `pinned`", before the induced subgraph is taken; keep the induced-subgraph comprehension and the `compute_cohorts` delegation byte-for-byte in behavior; set `cohort_offset = current_cohort + 1 if crosses_pinned else current_cohort`; derive the assignment as `cohort_offset + index` for each color class index
  - Constraints: the function stays pure, `int`-keyed, fully type-hinted, with no I/O and no clock read; no part of the coloring, the vertex ordering, or the `(-degree, item_key)` tie-break is reimplemented; `compute_concurrency_batches` is not called; `scripts/dev_tools/parallel_cohort_computation.py` is NOT modified; the `crosses_pinned` comprehension carries an intent comment and the offset branch carries a decision-logic comment
  - Acceptance: the signature matches the mandated form exactly; the offset is a single uniform shift applied to every class in one expression; `RecolorResult.generation` is still `current_generation + 1`; the result still names no pinned key; the file stays `<= 500` lines
- [x] [P3-T4] Correct the misleading induced-subgraph comment in `recolor_unstarted` (currently `scripts/dev_tools/parallel_mutation_protocol.py:217-219`).
  - The replacement comment must state that the induced subgraph restricts the COLORED VERTEX SET to unstarted keys, and must NOT claim that dropping those edges is what keeps pinned items out of the coloring input in any sense that covers the pinned CONSTRAINT. It must state explicitly that the dropped edges still carry a constraint, and that the constraint is honoured separately by the `crosses_pinned` test and the offset below it
  - Acceptance: the file contains no comment claiming that dropping the edges is what keeps pinned items out of the coloring input; the new comment names the constraint and points to the mechanism that honours it
- [x] [P3-T5] Correct `recolor_unstarted`'s docstring in `scripts/dev_tools/parallel_mutation_protocol.py`.
  - Delete the sentence claiming that dropping non-induced edges "is the mechanism that excludes pinned vertices from the coloring input" as a complete account, and replace it with the two-part account: the induced subgraph excludes pinned VERTICES, and the pinned-barrier offset honours the pinned CONSTRAINT
  - Add an `Args:` entry for `current_cohort` stating that it is F3's top-level `current_cohort`, that it is the index the pinned items occupy for as long as they run because the cohort barrier cannot advance it while any item is `in_flight`, and that it must be derived from re-verified durable state
  - Amend `Returns:` to state that assigned indices are ABSOLUTE checkpoint cohort indices at or above `current_cohort`, and strictly above it whenever any unstarted item conflicts with a pinned item
  - Amend `Raises:` to add `ParallelCohortInputError` for a negative `current_cohort` alongside the existing duplicate-key propagation
  - Add a short paragraph recording that the offset is uniform so F2's color classes remain distinct indices, that F3 invariants 13 and 14 remain satisfiable, and that `tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py` proves the latter against the landed validator
  - Acceptance: no claim in the docstring is false; every parameter including `current_cohort` is documented; the `Raises:` section matches the implemented behavior exactly
- [x] [P3-T6] Amend the `Pinning (spec FR4)` paragraph of the module docstring in `scripts/dev_tools/parallel_mutation_protocol.py`.
  - The paragraph must state that recoloring runs over the unstarted subgraph only, never assigns or moves a pinned item, AND places unstarted items at absolute cohort indices at or above the pinned items' index, strictly above it when an unstarted-to-pinned conflict exists
  - Acceptance: the module docstring's pinning paragraph states both halves of the guarantee; the surrounding paragraphs on delegation, key types, the recompute boundary, and side effects are unchanged
- [x] [P3-T7] Amend the `RecolorResult` class docstring in `scripts/dev_tools/_parallel_mutation_models.py`.
  - The `Usage and invariants` and `Attributes` text must state that `cohort_assignments` values are ABSOLUTE checkpoint cohort indices, not zero-based local color indices, and that the caller writes them verbatim into `cohorts[].index` without re-basing them
  - Constraints: no field is added, removed, or renamed; `__post_init__` is unchanged; no other class in the module is edited by this task
  - Acceptance: the docstring states the absolute-index and verbatim-write contract; `git diff a9e2463c -- scripts/dev_tools/_parallel_mutation_models.py` shows docstring-only change for this task
- [x] [P3-T8] Prove no stale call site of either changed function remains anywhere in the repository.
  - Commands: `grep -rn "decide_admission\|recolor_unstarted" scripts tests .claude extensions docs/features/active/2026-08-07-parallel-mutation-protocol-442`
  - Artifact: `<FEATURE>/evidence/other/remediation1-caller-migration.md` (`Timestamp:`, `Command:` per check, `EXIT_CODE:` per check, `Output Summary:` = the enumerated call sites with their files and line numbers and the confirmation that each passes the new keyword argument)
  - Acceptance: every call site of both functions is enumerated with file and line and classified MIGRATED or PENDING-PHASE-4; every non-test Python call site and every documentation reference is MIGRATED and names the new form; every PENDING-PHASE-4 entry is a test call site that [P4-T1] through [P4-T10] migrate. Pyright is deliberately not run here: the not-yet-migrated test call sites make a zero-error result impossible before Phase 4. The zero-error gate is [P4-T13] and again [P7-T3].
- [x] [P3-T9] Verify the production module's size and purity after both corrections.
  - Checks: line count of `scripts/dev_tools/parallel_mutation_protocol.py`; `grep -n "open(\|Path(\|datetime.now\|random\." scripts/dev_tools/parallel_mutation_protocol.py` returns no match introduced by this cycle; the purity grep is expected to report no match, so its recorded `EXIT_CODE` is 1, which is the required outcome for that check and is not a failure
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation1-engine-size-and-purity.md` (`Timestamp:`, `Command:` per check, `EXIT_CODE:` per check, `Output Summary:` = the line count and the purity grep result)
  - Acceptance: the file is `<= 500` lines; no I/O, clock, or RNG access was introduced
- [x] [P3-T10] Correct the two remaining docstrings the C1 signature change falsifies.
  - `scripts/dev_tools/_parallel_mutation_models.py` `AdmissionOutcome` `Attributes:` (lines 122-127): `ADMIT_CURRENT_COHORT` must read that the candidate conflicts with no member of the current cohort, pinned or unstarted, so it joins the current cohort with the generation unchanged; `DEFER_AND_RECOLOR` must read that a conflict with any current-cohort member — pinned or not-yet-launched — defers the candidate, the unstarted subgraph is recolored under the pinned-barrier offset, and the generation increments by exactly one
  - `scripts/dev_tools/_parallel_mutation_entries.py` `build_add_entry` `Args:` entry for `deferred` (lines 106-107): replace "an in-flight conflict forced a recolor" with "a conflict with a member of the current cohort, pinned or unstarted, forced a recolor"
  - Constraints: docstring text only in both modules; no field, constant, enum member, signature, or executable line changes; `AdmissionOutcome`'s two member values are unchanged
  - Acceptance: neither module contains a docstring claim that admission or deferral turns on the in-flight subset alone; `git diff a9e2463c -- scripts/dev_tools/_parallel_mutation_entries.py` shows a docstring-only change; `poetry run ruff check scripts/dev_tools/_parallel_mutation_models.py scripts/dev_tools/_parallel_mutation_entries.py` exits 0 (the dev_tools suite is not run here: the Phase 4 call-site migration has not happened, so it cannot pass until [P4-T13])

### Phase 4 — Test Relocation, Corrected Scenarios, Contention Properties, and Pass-After Evidence

- [x] [P4-T1] Update the C1 regression test in `tests/scripts/dev_tools/test_parallel_mutation_admission.py` to the corrected signature.
  - Change the call to `decide_admission(300, [(200, 300)], frozenset({100}), current_cohort_members=frozenset({100, 200}))` and keep the same assertion; keep the docstring's reference to finding R1
  - Acceptance: the test passes; the assertion is unchanged in substance (still `DEFER_AND_RECOLOR` with `triggers_recompute is True`); no assertion was weakened
- [x] [P4-T2] Relocate and correct the admission unit scenarios into `tests/scripts/dev_tools/test_parallel_mutation_admission.py`.
  - Move the whole `TestAdmissionOverAllItems` class (currently `tests/scripts/dev_tools/test_parallel_mutation_protocol.py:325-411`) into the new module, updating every call to the new signature, and correct the defective scenario: replace `test_unstarted_conflict_is_placed_by_the_coloring_not_rejected` with two tests — one asserting that a conflict with an unstarted member OF THE CURRENT COHORT defers and recolors, and one asserting that a conflict with an unstarted item NOT in the current cohort admits — and correct `test_conflict_only_with_an_unstarted_item_admits` so its fixture places the conflicting unstarted item outside the current cohort
  - Constraints: no temp files; fixed injected clock where an entry is constructed; `int` keys; the file stays within its `<= 200` budget
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_admission.py -v` exits 0; the module contains the C1 regression test plus every relocated scenario; no scenario present before the move is dropped
- [x] [P4-T3] Update the C2 regression test in `tests/scripts/dev_tools/test_parallel_mutation_recolor.py` to the corrected signature.
  - Change the call to `recolor_unstarted([200, 300], [(100, 300)], frozenset({100}), 7, current_cohort=0)` and keep the same assertion that `cohort_assignments[300]` is not the pinned index 0; keep the module docstring's statement of the contention violation being forbidden
  - Acceptance: the test passes; the assertion is unchanged in substance; no assertion was weakened
- [x] [P4-T4] Relocate `TestPinnedItemsNeverMove` into `tests/scripts/dev_tools/test_parallel_mutation_recolor.py` with every call site updated.
  - Move the whole class (currently `tests/scripts/dev_tools/test_parallel_mutation_protocol.py:128-205`, where line 128 is the `class` statement and line 205 is its last code line, with six `recolor_unstarted` call sites at lines 140, 153, 168, 181, 191, 201) into the new module and pass `current_cohort=` explicitly at every site, wrapping each call so no line exceeds 88 characters. Every existing assertion is preserved verbatim; only the added keyword argument and the wrapping change
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_recolor.py -v` exits 0; every test of the original class is present with its original name and assertions; no line exceeds 88 characters
- [x] [P4-T5] Add the pinned-barrier offset scenarios to `tests/scripts/dev_tools/test_parallel_mutation_recolor.py`.
  - Required scenarios, one test each: an unstarted item conflicting with a pinned item is assigned an index strictly greater than `current_cohort`, exercised at `current_cohort = 0` and at `current_cohort = 3`; with no unstarted-to-pinned edge present the lowest assigned index equals `current_cohort` exactly; the offset is uniform, so two unstarted items that conflict with each other still receive distinct indices differing by the same amount as their local color classes; a negative `current_cohort` raises `ParallelCohortInputError` with the invalid value as `offending_value`; with `pinned` empty and `current_cohort == 0` the assignment is identical to the pre-fix assignment for the same graph
  - Constraints: literal `int` keys; no temp files; full type hints; the file stays within its `<= 320` budget
  - Acceptance: every scenario passes; the offset-rule tests fail if the offset is removed or made unconditional, and the docstrings state that binding relationship
- [x] [P4-T6] Remove the two relocated classes and now-unused imports from `tests/scripts/dev_tools/test_parallel_mutation_protocol.py`, wrap its one remaining recolor call site, and update its module docstring.
  - Delete `TestAdmissionOverAllItems` and `TestPinnedItemsNeverMove`; remove `decide_admission`, `AdmissionDecision`, and `AdmissionOutcome` from the import list if and only if no remaining test uses them; wrap the surviving `recolor_unstarted` call at line 214 with `current_cohort=0`; the docstring's scenario list must state that scenario 4 (admission) now lives in `tests/scripts/dev_tools/test_parallel_mutation_admission.py` and that the pinned-item and recolor scenarios now live in `tests/scripts/dev_tools/test_parallel_mutation_recolor.py`, in the same style as its existing pointer to the `_ops` module
  - Acceptance: `poetry run ruff check tests/scripts/dev_tools/test_parallel_mutation_protocol.py` exits 0 with no F401; the file no longer references `decide_admission`; the file is `<= 500` lines and near the approximately 379-line figure computed in `## Test-Module Relocation Arithmetic`
- [x] [P4-T7] Create `tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py` with its self-contained seeded generator and the corrected per-function admission property.
  - Move `test_admission_defers_exactly_when_a_pinned_neighbour_exists` (currently `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py:374-398`) into the new module and correct it: the expected outcome is `DEFER_AND_RECOLOR` exactly when the candidate has a neighbour in `pinned | current_cohort_members`, derived independently from the generated edge list rather than from the engine's own return value
  - Mechanism: a self-contained seeded generator using `random.Random(seed)` over `int`-keyed graphs, a `SEEDS` tuple, pytest ids naming the seed, a `current_cohort` value, and a `__str__` that emits the seed and graph shape into every assertion message so a failure is reproducible from the report alone. Do not import `hypothesis`; do not import from another test module
  - Current-cohort construction: build the current cohort as an independent set of the FULL conflict graph by scanning keys in a seed-derived order and adding a key only when it has no edge to a key already in the set; the pinned subset of that set is the run's `in_flight` set and the remainder are its not-yet-launched `scheduled` members; the cohort's index is the run's `current_cohort`
  - Constraints: no temp files; full type hints; the file stays within its `<= 400` budget
  - Acceptance: the module exists, the relocated property passes for every seed, and the property's expected value is derived from the edge list rather than from the engine's own return value
- [x] [P4-T8] Add property P4, the composed contention invariant, to `tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py`.
  - Property: for each generated run, build the FULL assignment map — pinned items at index `current_cohort`, unstarted items at the indices the engine returns — then apply a seed-derived sequence of candidate admissions. For each candidate, call `decide_admission(candidate, edges, in_flight, current_cohort_members=<members at current_cohort>)`; on `ADMIT_CURRENT_COHORT` add the candidate to index `current_cohort`; on `DEFER_AND_RECOLOR` call `recolor_unstarted(<unstarted + candidate>, edges, pinned, generation, current_cohort=current_cohort)` and replace the unstarted portion of the map with the returned assignment. After EVERY step, assert that for every conflict edge whose two endpoints are both present in the map, the two endpoints hold DIFFERENT indices. Edges to pinned items are counted, because the pinned items are in the map. A candidate admitted by `ADMIT_CURRENT_COHORT` joins the unstarted set used by every subsequent step of the same run, because an admitted candidate is `scheduled` and is therefore a vertex of any later recolor; omitting it would leave a stale index in the map and make the assertion test the harness rather than the engine.
  - Non-vacuity assertions the property must also make, so a degenerate generator cannot make it pass trivially: the generated current cohort is an independent set of the full graph; across the seed corpus at least one run yields `ADMIT_CURRENT_COHORT` and at least one yields `DEFER_AND_RECOLOR`; at least one run contains a conflict edge joining an unstarted key to a pinned key; and at least one run both contains NO conflict edge joining an unstarted key to a pinned key AND performs at least one recolor, so the offset-value assertion is evaluated on the offset-not-applied branch; the corpus therefore exercises both the offset-applied and the offset-not-applied branch and an unconditional `+1` offset cannot pass this property either
  - Offset-value assertion, required because the contention assertion alone cannot distinguish the correct offset from an unconditional `+1` (an unconditional offset also vacates the pinned index, so no two conflicting items share an index and the contention assertion still passes): on every `recolor_unstarted` call the property makes, recompute `crosses_pinned` independently from the generated edge list and the run's pinned set, then, whenever the returned map is non-empty, assert `min(result.cohort_assignments.values()) == current_cohort + 1` when `crosses_pinned` is true and `== current_cohort` when it is false. With the corpus clauses requiring at least one run with and one run without an unstarted-to-pinned edge, this assertion fails deterministically under an unconditional offset and under a removed offset.
  - Binding statement required in the test docstring: this property fails if `decide_admission` is reverted to the in-flight-only rule, fails if `recolor_unstarted`'s offset is removed, and fails if the offset is made unconditional. It is the property whose absence allowed both C1 and C2 to ship
  - Acceptance: the property passes for every seed; the non-vacuity assertions and the offset-value assertion are present and themselves pass; the docstring states all three binding relationships
- [x] [P4-T9] Relocate the P3 pin-stability property into `tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py`.
  - Move `TestPropertyThreePinStability` (currently `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py:299-368`, both tests, carrying the `recolor_unstarted` call site at line 346 and the `decide_admission` call site at line 335, both of which relocate with the class) into the new module, updating its `decide_admission` and `recolor_unstarted` call sites to the new signatures and binding them to the module's own generator. Every existing assertion is preserved
  - Acceptance: both relocated tests pass for every seed; no assertion was weakened; the module stays within its `<= 400` budget
- [x] [P4-T10] Update `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py` for the new signatures and correct the two tests that codify the defects.
  - Edits: add a `current_cohort` attribute to `GeneratedRun` and pass it through the `recolor` helper; update the remaining `recolor_unstarted` call sites (lines 220, 291, 493 and the helper at 172) and the one remaining `decide_admission` call site (line 492 — line 335 lies inside `TestPropertyThreePinStability` and relocates with it under [P4-T9], and line 346 likewise), wrapping each so no line exceeds 88 characters; rewrite `test_cohort_indices_are_contiguous_from_zero` to assert contiguity from the computed offset AND that the offset equals `current_cohort + 1` when an unstarted-to-pinned edge exists and `current_cohort` otherwise; rewrite `test_edges_touching_a_pinned_vertex_do_not_constrain_the_coloring` to assert that pinned edges leave the induced coloring's class STRUCTURE unchanged while the final assignment is shifted past the pinned index; remove the two relocated blocks and update the module docstring's function and property lists accordingly
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py -v` exits 0; the file is `<= 500` lines and near the approximately 418-line figure computed in `## Test-Module Relocation Arithmetic`; the P1 and P2 property classes still exist and no assertion of theirs was removed except the two rewritten tests, each replaced by a strictly stronger assertion
- [x] [P4-T11] Create `tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py` and bind the corrected recolor output to F3's LANDED validator.
  - Mechanism: construct the checkpoint document as an in-memory JSON string (no temp file, no fixture file on disk) carrying every key F3 invariant 1 requires, with `items[]` holding one pinned item and at least two unstarted items in valid states with valid `blast_radius` shapes, `conflict_edges[]` normalized `a < b` with a valid `reason`, `current_cohort` set to the pinned items' index, `recolor_generation` set to the recolor's returned generation, and `cohorts[]` built as exactly one entry per distinct index, each entry's `item_keys` being the union of the pinned members at that index and the returned keys at that index, so the no-offset case yields a SINGLE entry at `current_cohort` holding both the pinned members and the returned keys rather than two entries sharing that index. Call `validate_parallel_orchestrator_state_text` from `scripts/dev_tools/validate_parallel_orchestrator_state.py` on that text
  - Required cases: `current_cohort = 0` with an unstarted-to-pinned edge (offset applied); `current_cohort = 3` with an unstarted-to-pinned edge (offset applied at a non-zero base); `current_cohort = 3` with no unstarted-to-pinned edge (offset not applied); and an empty unstarted set at `current_cohort = 2`
  - Assertions: the returned error list is empty in every case; and specifically that no error mentions cohort-uniqueness or coverage (invariant 13) or the current-cohort bound (invariant 14). Each test docstring must name the invariant it binds; and one negative-path case proving the merge obligation is necessary rather than assumed — constructing two separate current-generation cohort entries at index `current_cohort` instead of one MUST produce a duplicate-current-generation-index error, asserted on the returned error list
  - Constraints: no temp files; no live `git` or `gh`; full type hints; the file stays within its `<= 260` budget; no F3 field or enum member is added anywhere in the constructed document
  - Acceptance: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py -v` exits 0 with zero validator errors in every case, so F3 invariants 12, 13, and 14 are proven satisfiable under the corrected contract by execution rather than by assertion
- [x] [P4-T12] Prove that no test present before this cycle was dropped, renamed away, or weakened.
  - Checks: enumerate every `def test_` name in the pre-remediation commit's `tests/scripts/dev_tools/test_parallel_mutation_protocol.py` and `test_parallel_mutation_protocol_properties.py` via `git show a9e2463c:<path>`; enumerate every `def test_` name across the post-change set of six modules; produce the difference
  - Artifact: `<FEATURE>/evidence/regression-testing/remediation1-scenario-inventory.md` (`Timestamp:`, `Command:` per check, `EXIT_CODE:` per check, `Output Summary:` = the before list, the after list, and a per-name disposition of `relocated`, `unchanged`, `corrected`, or `replaced`)
  - Acceptance: every base test name is accounted for as relocated, unchanged, corrected, or explicitly replaced by a strictly stronger test; the only `replaced` entries are `test_unstarted_conflict_is_placed_by_the_coloring_not_rejected`, `test_cohort_indices_are_contiguous_from_zero`, and `test_edges_touching_a_pinned_vertex_do_not_constrain_the_coloring`, each with its replacement named; no name is dropped without a replacement
- [x] [P4-T13] Record the pass-after half of both regression demonstrations.
  - Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_admission.py tests/scripts/dev_tools/test_parallel_mutation_recolor.py tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py -v`; then `poetry run pyright`
  - Artifacts: append a `## Pass-After` section to BOTH `<FEATURE>/evidence/regression-testing/remediation1-c1-admission-cohort-independence.md` and `<FEATURE>/evidence/regression-testing/remediation1-c2-recolor-pinned-barrier.md`, each with `Timestamp:`, `Command:`, `EXIT_CODE:` (0), and `Output Summary:` = the passing counts, plus a `## Binding` section stating which reversion re-fails which test — reverting `decide_admission` to the in-flight-only rule re-fails the C1 test and property P4; removing `recolor_unstarted`'s offset re-fails the C2 test, the offset scenarios, and property P4
  - Acceptance: both artifacts carry a `## Fail-Before` section with exit code 1 and a `## Pass-After` section with exit code 0, each with its command; the `## Binding` sections name the specific tests that re-fail on reversion; `poetry run pyright` exits 0 with 0 errors, so every call site recorded PENDING-PHASE-4 by [P3-T8] is migrated

### Phase 5 — Consumer Updates: Skills, the F6 Section, and Bundle Mirrors

- [x] [P5-T1] Correct the FR1 admission and recolor procedure in `.claude/skills/parallel-add/SKILL.md`.
  - Edits, all inside the existing `## Procedure` steps 4 and 5: the call shape becomes `decide_admission(candidate, conflict_edges, in_flight, current_cohort_members=current_cohort_members)`; the recolor call shape becomes `recolor_unstarted(unstarted_items, conflict_edges, pinned, current_generation, current_cohort=current_cohort)`; the `ADMIT_CURRENT_COHORT` bullet states that the candidate shares no edge with any member of the current cohort, pinned or unstarted; the `DEFER_AND_RECOLOR` bullet states that any conflict with a current-cohort member defers and recolors; the paragraph at lines 77-79 asserting that "a conflict with an UNSTARTED item is not a deferral" is replaced by the corrected statement that a conflict with an unstarted member of the CURRENT cohort defers and recolors while a conflict with an unstarted item outside the current cohort does not, because the cohort barrier keeps them from running concurrently
  - Add, in the same two steps: one sentence stating how `current_cohort_members` is derived from the re-verified durable state (the current-generation cohort at `current_cohort`, including its not-yet-launched `scheduled` members) and one stating that `current_cohort` is F3's top-level field read from that same re-verified state; cite `## Cohort Barrier and Max-Concurrency Slot Filling` by exact heading text; and one sentence stating that the returned `cohort_assignments` values are ABSOLUTE cohort indices to be written verbatim into `cohorts[].index`, never re-based to zero; and one sentence stating that when the lowest returned index equals `current_cohort` (the no-pinned-conflict case, offset not applied) the returned keys at that index are MERGED into the single existing current-generation cohort entry at `current_cohort` alongside its pinned members, and are never written as a second cohort entry carrying the same `index`, because F3 invariant 13 requires current-generation `cohorts[].index` values to be unique (`scripts/dev_tools/_parallel_state_structures.py:282-305` — duplicate-index detection at 282-293, error emission at 301-305)
  - Step 5 must no longer read as optional in a way that hides either defect: keep "Apply the recolor result" and state explicitly that the admit branch performs no recolor precisely because the candidate conflicts with no current-cohort member, and that the recolor branch places every unstarted item at or above `current_cohort` and strictly above it when a pinned conflict exists
  - Constraints: frontmatter untouched; no other section of the file edited; no other file edited by this task
  - Acceptance: the file contains no in-flight-only admission condition and no four-argument recolor call shape; the two documented call shapes match `## Mandated Signatures`; `git diff a9e2463c -- .claude/skills/parallel-add/SKILL.md` shows changes only within `## Procedure` steps 4 and 5; the file states the single-entry-per-index merge obligation for the `current_cohort` index
- [x] [P5-T2] Correct the recolor call shape and add the verbatim-index obligation in `.claude/skills/parallel-remove/SKILL.md`.
  - Edits: the recolor call shape at line 81 becomes the five-argument form with `current_cohort=current_cohort`; add one sentence stating that `current_cohort` is read from the re-verified durable state, that the returned indices are absolute and written verbatim into `cohorts[].index`, and that returned keys whose index equals `current_cohort` are merged into the single existing cohort entry at that index rather than written as a duplicate-index entry, which F3 invariant 13 rejects
  - Constraints: frontmatter untouched; only the step containing the recolor call is edited; the FR2 behavior table, the disposition rules, and the abandon CLI contract are unchanged
  - Acceptance: no four-argument recolor call shape remains in the file; `git diff a9e2463c -- .claude/skills/parallel-remove/SKILL.md` shows changes only in that one step
- [x] [P5-T3] Correct the `## Mutation Protocol (F6)` section of `.claude/skills/parallel-orchestrate/SKILL.md` (F5-owned; confined in-section edit).
  - Edits, all inside that one section (lines 435-580 at the pinned base): the `/parallel-add` bullet (lines 440-444) states that the admission decision places the item in the current cohort only when it conflicts with no member of that cohort, pinned or unstarted, and otherwise defers and recolors; the `### Pinning invariant` subsection (lines 460-473) adds the current cohort index as a third recolor input, states the pinned-barrier offset and its two cases, states that the offset is uniform so F2's color classes remain distinct indices, and states that the returned indices are absolute and written verbatim into `cohorts[].index`, and that `cohorts[]` carries exactly one current-generation entry per index, so returned keys at index `current_cohort` join the pinned members of that one entry instead of forming a second entry with the same index; recompute-boundary item 1 (line 482) reads "the candidate conflicts with a member of the current cohort — pinned or not-yet-launched — so the unstarted subgraph, including the new item, is recolored"; non-recompute item 1 (line 491) reads "Admission into the current cohort with no conflict against any current-cohort member"; the `### Drift-requeue append contract` subsection (line 571) names the five-argument recolor call shape; add two sentences recording the two design corrections and their reasons, cross-referencing `## Cohort Barrier and Max-Concurrency Slot Filling` by exact heading text
  - Confinement: do not relocate, reflow, reorder, or retitle any section, including the target section; do not touch `## Cohort Barrier and Max-Concurrency Slot Filling`, `## Enforcement Hooks (F7)`, or `## Radius Drift Detection (F8)` or their headings; no added or removed line may fall before the `## Mutation Protocol (F6)` heading or at or after the `## Enforcement Hooks (F7)` heading; reference other sections only by exact heading text
  - Concurrency: F7 and F8 may be editing their own sections of this file concurrently. A merge conflict is expected and is resolved by keeping all three features' section bodies in place, never by relocating or reordering a section
  - Acceptance: `git diff c939b5b8 -- .claude/skills/parallel-orchestrate/SKILL.md` shows added and removed lines only inside `## Mutation Protocol (F6)`; the file still has the same `##` heading inventory in the same order; the three wave-4 headings remain in the order `## Mutation Protocol (F6)` → `## Enforcement Hooks (F7)` → `## Radius Drift Detection (F8)`
- [x] [P5-T4] Mirror `.claude/skills/parallel-add/SKILL.md` into the extension bundle byte-for-byte.
  - Target: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-add/SKILL.md`
  - Acceptance: `diff` between the two files reports no difference; no other bundle file is edited by this task; `pack-manifests/core.json` requires no change because no file is added or removed
- [x] [P5-T5] Mirror `.claude/skills/parallel-remove/SKILL.md` into the extension bundle byte-for-byte.
  - Target: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-remove/SKILL.md`
  - Acceptance: `diff` between the two files reports no difference; no other bundle file is edited by this task
- [x] [P5-T6] Mirror `.claude/skills/parallel-orchestrate/SKILL.md` into the extension bundle byte-for-byte.
  - Target: `extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-orchestrate/SKILL.md`
  - Acceptance: `diff` between the two files reports no difference; no other bundle file is edited by this task
- [x] [P5-T7] Prove no stale call shape and no unnecessary skill edit remains across the documentation surface.
  - Commands: `grep -rn "decide_admission\|recolor_unstarted" .claude extensions/drm-copilot/resources/claude-customizations`; then `git diff --numstat a9e2463c -- .claude/skills/parallel-close/SKILL.md`
  - Artifact: `<FEATURE>/evidence/other/remediation1-skill-call-shape-audit.md` (`Timestamp:`, `Command:` per check, `EXIT_CODE:` per check, `Output Summary:` = every occurrence with its file and line and the confirmation of the argument list at each)
  - Acceptance: every occurrence names the new signature or, in the case of `.claude/skills/parallel-close/SKILL.md` line 65, is a prohibition on calling the function at all and therefore needs no change; `parallel-close/SKILL.md` shows no diff against the pinned base
- [x] [P5-T8] Run the landed contract suites that bind the edited skills and their mirrors.
  - Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py -v`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation1-skill-contract-suites.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` = per-suite counts)
  - Acceptance: exit code 0; the bundle-parity assertions and the F5 heading-inventory assertions all pass

### Phase 6 — Remaining Partial Findings

- [x] [P6-T1] Replace the copied op-classification tuples in `scripts/dev_tools/_parallel_mutation_models.py` with imports of F3's constants (finding R2).
  - Delete the local `ITEM_SCOPED_OPS`, `OPS_WITH_NULL_PRIOR_STATE`, and `OPS_WITH_NULL_NEW_STATE` declarations (lines 109-113) and import F3's originals from `scripts.dev_tools._parallel_state_records` — `OPS_REQUIRING_ITEM_KEY`, `OPS_REQUIRING_NULL_PRIOR_STATE`, `OPS_REQUIRING_NULL_NEW_STATE` — updating every usage site to the imported names. Add an intent comment stating that the classification is F3-owned and consumed, never restated
  - Constraints: no behavior change; no import cycle (`_parallel_state_records` imports only `_parallel_state_common`); file stays `<= 500` lines
  - Acceptance: the module declares none of the three tuples locally; `poetry run pytest tests/scripts/dev_tools -q` exits 0; Pyright reports 0 errors
- [x] [P6-T2] Replace the copied op-classification tuples in `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` with imports of F3's constants (finding R2).
  - Delete the local `ITEM_SCOPED_OPS`, `OPS_WITH_NULL_PRIOR_STATE`, and `OPS_WITH_NULL_NEW_STATE` declarations (lines 92-99) and import F3's originals as in [P6-T1], updating every usage site. `MUTATION_ENTRY_FIELDS` and `CLOSE_OP` are unchanged
  - Acceptance: the module declares none of the three tuples locally; every validator error string produced by the module is unchanged, proven by `poetry run pytest tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutations.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_mutation_modes.py -v` exiting 0
- [x] [P6-T3] Add the binding assertions that pin F6's op classification to F3's, in `tests/scripts/dev_tools/test_parallel_mutation_protocol.py`.
  - Add to `TestEnumConsumption` three tests asserting that the op-classification constants the two F6 modules use are the identical objects imported from `scripts.dev_tools._parallel_state_records`, plus one test asserting that neither F6 module declares a module-level tuple named `ITEM_SCOPED_OPS`, `OPS_WITH_NULL_PRIOR_STATE`, or `OPS_WITH_NULL_NEW_STATE` (so a future re-restatement fails)
  - Constraints: no temp files; the file must stay `<= 500` lines, for which the [P4-T6] relocations provide the measured headroom recorded in `## Test-Module Relocation Arithmetic`
  - Acceptance: the four tests pass and fail if either module reintroduces a local copy
- [x] [P6-T4] Authorize S311 for the two seeded-RNG test modules through a confined `pyproject.toml` edit (finding R5).
  - Edit: add exactly two entries to `[tool.ruff.lint.per-file-ignores]` — `"tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py" = ["S311"]` and `"tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py" = ["S311"]` — preceded by one comment line stating that seeded `random.Random` generation is mandated by `.claude/rules/general-unit-test.md` § Determinism Infrastructure and by `<FEATURE>/spec.md` § Constraints & Risks item 2
  - Confinement: no other table, key, or line of `pyproject.toml` changes; no dependency, dependency group, coverage, pytest, or Pyright setting is touched; `poetry.lock` is not modified
  - Acceptance: `git diff c939b5b8 -- pyproject.toml` shows only the three added lines inside `[tool.ruff.lint.per-file-ignores]`, and the second entry names `test_parallel_mutation_contention_properties.py`, the only new module that uses `random.Random`; `git diff c939b5b8 -- poetry.lock` is empty
- [x] [P6-T5] Delete both `# noqa: S311` suppressions from `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py` (finding R5).
  - Replace each with a plain, non-directive comment stating why the seeded generator is used (deterministic test-data generation with the seed printed on failure), on the line above the `random.Random(...)` construction. Confirm the new contention-properties module created in [P4-T7] likewise carries no `# noqa` comment
  - Acceptance: `grep -rn "noqa: S311" --include=*.py .` returns no match and therefore exits 1, which is the required outcome for that check; `poetry run ruff check .` exits 0
- [x] [P6-T6] Correct the S603 suppression placement in `scripts/dev_tools/parallel_mutation_abandon_cli.py` (finding R6).
  - Delete the inert directive-shaped comment at line 152 and place a non-directive rationale on the two lines immediately above the effective suppression, in this form (each line within 88 characters):
    `# S603 rationale: static analysis can't verify runtime validation. The`
    `# executable is resolved through shutil.which above before the call.`
    keeping `completed = subprocess.run(  # noqa: S603` as the effective single-line suppression
  - Recorded reason for the format deviation: composing the rule's verbatim one-line text onto the suppressing line yields 95 characters (measured: `    completed = subprocess.run(  # noqa: S603 - static analysis can't verify runtime validation`), above the repository's 88-character Black/Ruff limit, and shortening it further would require renaming the `subprocess` import path that `tests/scripts/dev_tools/test_parallel_mutation_abandon_cli.py` monkeypatches as `cli.subprocess.run`. The rule's substantive requirements are unaffected: pre-authorized pattern, `shutil.which` validation at line 148, single-line scope
  - Artifact: `<FEATURE>/evidence/other/remediation1-s603-comment-placement.md` (`Timestamp:`, the before/after lines, the 95-character arithmetic with the measured line reproduced verbatim, and the measured lengths of the two replacement rationale lines (74 and 72 at indentation 4), and the statement that no other suppression mechanism changed)
  - Acceptance: no line of the file contains a `# noqa` token that suppresses nothing; `poetry run ruff check scripts/dev_tools` exits 0; the CLI tests still pass
- [x] [P6-T7] Record the Python/TypeScript parity gap as an explicit deferral (finding R4).
  - Create `docs/features/potential/2026-08-09-parallel-f6-typescript-parity-gap.md` recording: that `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` does not implement F6's three FR9 invariant families, so a checkpoint whose `add` entry omits `new_state` yields Python errors and zero TypeScript errors; that no parity test exists; the three reasons the gap was correctly deferred (no acceptance criterion required a port; F6 has no TypeScript seam of its own, the only comment-delimited seam being F7's, which F6 must not touch; and `.claude/rules/parallel-orchestration.md` § Enforcement scopes its parity claim to F3's invariants 1-21, which F6 may not amend); that pulling the port into scope would require a further spec amendment; and that no TypeScript port is attempted on this branch
  - Artifact: `<FEATURE>/evidence/other/remediation1-typescript-parity-deferral.md` (`Timestamp:`, the potential-entry path, the deferral rationale, and the explicit statement that this cycle adds no TypeScript task)
  - Acceptance: the potential entry and the evidence artifact both exist; no file under `extensions/drm-copilot/src/` is modified by this plan; this is the ONLY `docs/features/potential/` entry this cycle creates
- [x] [P6-T8] Record the consolidated finding disposition for the cycle.
  - Artifact: `<FEATURE>/evidence/other/remediation1-finding-disposition.md` (`Timestamp:`, one row per finding R1–R6 plus one row for the preflight-identified design gap C2, each with its class, the resolving task IDs or the deferral rationale, and the resulting Blocking count)
  - Acceptance: the artifact shows R1 and C2 resolved IN CODE with their task IDs, R2/R3/R5/R6 resolved, R4 deferred with rationale, and a Blocking count of 0. It must also record explicitly that no `docs/features/potential/` entry was created for the C2 gap because the gap was closed in code, and must state the residual assessment from this plan's `## Residual Gap Assessment` section verbatim in substance

### Phase 7 — Final QA Loop, Coverage Evidence, Confinement, and AC Re-Verification

Loop rule for this phase: if any command in [P7-T1] through [P7-T7] fails or changes a file, fix
the cause, restart that language's loop from its formatting step, and re-record every affected
artifact. No `SKIPPED` outcome is authorized for any task in this phase.

- [x] [P7-T1] Run Python formatting and record evidence.
  - Command: `poetry run black .`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation1-final-py-format.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: exit code 0 and no file changed on the final pass
- [x] [P7-T2] Run Python linting and record evidence.
  - Command: `poetry run ruff check .`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation1-final-py-lint.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: exit code 0 with zero findings
- [x] [P7-T3] Run Python type-checking and record evidence.
  - Command: `poetry run pyright`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation1-final-py-typecheck.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: exit code 0 with 0 errors, 0 warnings
- [x] [P7-T4] Run Python tests in coverage mode and record numeric post-change coverage.
  - Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation1-final-py-test-coverage.md`; `Output Summary:` MUST record the numeric post-change line and branch coverage percentages, the passed/failed counts, and the per-file line and branch coverage of `scripts/dev_tools/parallel_mutation_protocol.py`, `scripts/dev_tools/_parallel_mutation_models.py`, `scripts/dev_tools/_parallel_mutation_entries.py`, `scripts/dev_tools/_parallel_mutation_errors.py`, `scripts/dev_tools/parallel_mutation_abandon_cli.py`, `scripts/dev_tools/_parallel_orchestrator_state_mutations.py`, and `scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py` (no placeholders)
  - Acceptance: every test passes and every required numeric value is recorded
- [x] [P7-T5] Run PowerShell formatting and record evidence.
  - Command: MCP tool `mcp__drm-copilot__run_poshqc_format`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation1-final-ps-format.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: exit code 0 and no file changed on the final pass
- [x] [P7-T6] Run the PowerShell analyzer and record evidence.
  - Command: MCP tool `mcp__drm-copilot__run_poshqc_analyze`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation1-final-ps-analyze.md` (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`)
  - Acceptance: exit code 0 with zero findings
- [x] [P7-T7] Run PowerShell Pester tests in coverage mode and record numeric post-change coverage.
  - Command: MCP tool `mcp__drm-copilot__run_poshqc_test`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation1-final-ps-test-coverage.md`; `Output Summary:` MUST record passed/failed/skipped counts, the numeric line coverage percentage, the coverage of `.claude/hooks/enforce-parallel-abandon-gate.ps1`, and the name of the single pre-existing failure
  - Acceptance: the only failure is the pre-existing `enforce-pr-author-skill.Tests.ps1:142` case, unedited; every other test passes; numeric coverage recorded
- [x] [P7-T8] Verify the coverage delta and thresholds against the Phase 0 remediation baseline.
  - Compare `<FEATURE>/evidence/remediation-baseline/remediation1-baseline-py-test-coverage.md` and `remediation1-baseline-ps-test-coverage.md` against the [P7-T4] and [P7-T7] artifacts; report per language the baseline coverage, the post-change coverage, and the coverage of the changed and new code; confirm Python line `>= 92.05%` and branch `>= 84.19%` (no regression below the figures recorded at baseline) and, independently, line `>= 85%` and branch `>= 75%`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation1-coverage-delta.md` (`Timestamp:`, the three numeric figures per language, and an explicit verdict per threshold)
  - Acceptance: every threshold is met with numeric evidence; if any required value is unavailable or below threshold the outcome is remediation-required and MUST NOT be reported as PASS
- [x] [P7-T9] Verify the 500-line cap on every touched and every new file against the budgets in `## Test-Module Relocation Arithmetic`.
  - Files: `scripts/dev_tools/parallel_mutation_protocol.py`, `scripts/dev_tools/_parallel_mutation_models.py`, `scripts/dev_tools/_parallel_orchestrator_state_mutations.py`, `scripts/dev_tools/parallel_mutation_abandon_cli.py`, `tests/scripts/dev_tools/test_parallel_mutation_admission.py`, `tests/scripts/dev_tools/test_parallel_mutation_recolor.py`, `tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py`, `tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py`, `tests/scripts/dev_tools/test_parallel_mutation_protocol.py`, `tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py`, and `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py`
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation1-file-size-cap.md` (`Timestamp:`, `Command:` = the line-count command used, `EXIT_CODE:`, `Output Summary:` = per-file line counts alongside the planned budget for each)
  - Acceptance: every listed file is `<= 500` lines and within its planned budget; `test_parallel_mutation_protocol_ops.py` is still exactly 500 lines and `git diff a9e2463c -- tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` is empty; the cap is not relaxed for any file
- [x] [P7-T10] Re-verify shared-file confinement and the additive-only constraint against the pinned base.
  - Check A — no epic contention: `git diff --stat c939b5b8 -- .` shows no modified file under `.claude/hooks/enforce-epic-*`, no modified epic skill, agent, or validator, and no modified file under `.claude/rules/`; and `git status --porcelain` lists no modified or untracked path under `.claude/rules/`, `.claude/hooks/enforce-epic-*`, or any epic skill, agent, or validator
  - Check B — orchestrate SKILL confinement: `git diff c939b5b8 -- .claude/skills/parallel-orchestrate/SKILL.md` shows added and removed lines only inside `## Mutation Protocol (F6)`; no added or removed line falls before that heading or at or after the `## Enforcement Hooks (F7)` heading; `## Cohort Barrier and Max-Concurrency Slot Filling` is byte-identical to the base; the three wave-4 headings are present, unmodified, and in their original relative order; no section was relocated, reflowed, reordered, or retitled
  - Check C — validator confinement: `git diff c939b5b8 -- scripts/dev_tools/validate_parallel_orchestrator_state.py` still shows exactly one added import line and one added call line and zero removed lines, and every line between the `# BEGIN` and `# END F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` comments is byte-identical to the base
  - Check D — settings confinement: `git diff c939b5b8 -- .claude/settings.json` still shows exactly one added Bash-matcher hook entry and nothing else
  - Check E — no schema growth: `git diff a9e2463c -- scripts/dev_tools/_parallel_state_common.py scripts/dev_tools/_parallel_state_records.py scripts/dev_tools/_parallel_state_structures.py .claude/rules/parallel-orchestration.md` produces empty output with `EXIT_CODE: 0`, proving no member was added to any of the nine parallel enums — all nine are declared in `scripts/dev_tools/_parallel_state_common.py:39-82` — and that no F3 record-shape module changed; and `grep -n -A 12 "^MUTATION_ENTRY_FIELDS" scripts/dev_tools/_parallel_orchestrator_state_mutations.py` (`EXIT_CODE: 0`) lists the same seven `mutations[]` field names as `git show a9e2463c:scripts/dev_tools/_parallel_orchestrator_state_mutations.py`, so no field was added to `mutations[]`, `drift_events[]`, or `conflict_edges[]`
  - Check F — config confinement: `git diff c939b5b8 -- pyproject.toml` shows only the three lines added by [P6-T4] inside `[tool.ruff.lint.per-file-ignores]`, and `git diff c939b5b8 -- poetry.lock` is empty, so no dependency changed
  - Check G — base plan untouched by this cycle: `git diff a9e2463c -- <FEATURE>/plan.md` produces empty output, proving the file is byte-identical to the pre-remediation commit. The whole-branch numstat recorded for this path by [P0-T8] is retained as an informational baseline only and is NOT the proof: numstat equality against `c939b5b8` cannot detect a line-count-preserving edit, because a line replaced inside the added-line set is still counted as one addition and the `c939b5b8` line it displaced is still counted as one deletion, leaving the measured `170 114` unchanged
  - Check H — bundle parity: `diff` between each edited `.claude/**` file and its `extensions/drm-copilot/resources/claude-customizations/.claude/**` mirror reports no difference
  - Check I — ops test module byte-unchanged: `git diff a9e2463c -- tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` produces empty output, proving this remediation cycle added and removed no line in the 500-line module
  - Check J — F2 untouched: `git diff c939b5b8 -- scripts/dev_tools/parallel_cohort_computation.py` produces empty output, proving the offset was added entirely inside F6's function
  - Check K — `POPULATED_RESERVED_HEADINGS` remains a one-line append: `git diff a9e2463c -- tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` produces empty output with `EXIT_CODE: 0`; and `grep -n "POPULATED_RESERVED_HEADINGS" tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (`EXIT_CODE: 0`) reports exactly one declaration, at line 83, whose value is the single-element tuple `("## Mutation Protocol (F6)",)`, proving F6 neither expanded the tuple on F7's or F8's behalf nor altered the skip guard at `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:260`
  - Note on concurrent features: if F7 or F8 lines are present in a shared file because their branches merged first, those lines are part of the base for this comparison and are not an F6 violation. These checks constrain only F6's own added and removed lines
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation1-confinement-verification.md` (`Timestamp:`, `Command:` for each check recorded verbatim and naming the base it uses — `a9e2463c` for Checks E, G, I, and K, and `c939b5b8` for the whole-branch confinement Checks A, B, C, D, F, and J, per `## Conventions Used in This Plan`; Check H compares working-tree files against their bundle mirrors and uses no base — `EXIT_CODE:` per check, with every non-zero expected exit declared in the check text, `Output Summary:` = per-check verdicts A–K)
  - Acceptance: every check A–K passes; any violation is remediation-required
- [x] [P7-T11] Re-verify the acceptance criteria against the amended text and confirm check-off honesty.
  - Re-evaluate S2, S5, S9, U1, and U5 against their amended wording and the delivered work; re-confirm the remaining 19 criteria are unaffected by this cycle's changes; state for each of the five amended criteria whether its `[x]` marker is honest under the amended text and correct the marker if it is not. S5 and U5 must cite the executed evidence for the offset rule, namely the [P4-T5] scenarios, property P4 from [P4-T8], and the F3 binding module from [P4-T11]
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation1-ac-recheck.md` (`Timestamp:`, the `### Acceptance Criteria Status` block for `<FEATURE>/spec.md` (15 items) and `<FEATURE>/user-story.md` (9 items), a per-criterion verdict for S2, S5, S9, U1, and U5 with file-and-line evidence, and the confirmation that no criterion was added, removed, or renumbered)
  - Acceptance: S2, S5, S9, U1, and U5 each evaluate PASS against their amended text with cited evidence; counts remain 15 and 9; any criterion that does not evaluate PASS is left unchecked with its gap documented
- [x] [P7-T12] Record the contention-guarantee closure statement from executed results.
  - Content, each item citing the artifact and exit code that establishes it: the C1 fail-before and pass-after exit codes; the C2 fail-before and pass-after exit codes; property P4 passing for every seed together with its three non-vacuity assertions; the F3 invariant binding module passing with zero validator errors in all four cases; the scenario inventory showing no dropped or weakened test; and the explicit statement that the guarantee "no two items assigned to the same cohort share a conflict edge, including edges to pinned items" now holds after any admission decision and any recolor, for the inputs the engine is given
  - The artifact must also restate this plan's `## Residual Gap Assessment` conclusion — that the only remaining path to co-scheduled conflicting work is a caller supplying untrue arguments, which is the pre-existing cache-doctrine obligation already recorded in `<FEATURE>/spec.md` § Constraints & Risks item 4 and enforced by the mandatory re-derivation step in `.claude/skills/parallel-add/SKILL.md` — and must record that no `docs/features/potential/` entry was created for it
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation1-contention-closure.md` (`Timestamp:`, every citation above with its artifact path and exit code, and the closure statement)
  - Acceptance: every claim in the artifact cites an executed command and its recorded exit code; no claim rests on prose reasoning alone
- [x] [P7-T13] Record the remediation-cycle completion summary.
  - Content: the per-finding disposition from [P6-T8]; the fail-before and pass-after exit codes from both regression artifacts; the numeric coverage figures and threshold verdicts from [P7-T8]; the per-file line counts and budgets from [P7-T9]; the confinement verdicts A–K from [P7-T10]; the AC verdicts from [P7-T11]; the closure statement from [P7-T12]; and the resulting Blocking count
  - Artifact: `<FEATURE>/evidence/qa-gates/remediation1-cycle-summary.md` (`Timestamp:`, all of the above, and an explicit exit-gate statement)
  - Acceptance: the artifact reports Blocking count 0, both design corrections remediated in code with fail-before and pass-after evidence, every Partial finding either resolved by a named task or deferred with a recorded rationale, all seven toolchain stages green in a single pass, coverage at or above both the no-regression figures and the policy thresholds, `test_parallel_mutation_protocol_ops.py` byte-unchanged, and the single pre-existing Pester failure unchanged and unedited
