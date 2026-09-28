# Remediation Cycle 1 — Acceptance-Criteria Re-Verification Against the Amended Text

Timestamp: 2026-08-09T09-15

Task: [P7-T11]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Work mode: `full-feature`, so BOTH `spec.md` (S1-S15) and `user-story.md` (U1-U9) are AC sources.

Command: a count of `^- \[([ x])\]` items in each file's `## Acceptance Criteria` section
EXIT_CODE: 0
Output Summary: `spec.md` total **15**, checked **15**, unchecked 0. `user-story.md` total **9**,
checked **9**, unchecked 0.

---

## Per-Criterion Verdicts for the Five Amended Criteria

### S2 (amended by [P1-T8], correction C1) — **PASS**

Amended clause: "admits into the current cohort only when the candidate conflicts with no member of
the current cohort, in-flight or unstarted, otherwise defers and recolors the unstarted subgraph."

Evidence that the delivered work satisfies the AMENDED text:

- `scripts/dev_tools/parallel_mutation_protocol.py:121-127` — `decide_admission` carries the required
  keyword-only `current_cohort_members: frozenset[int]` with no default.
- `scripts/dev_tools/parallel_mutation_protocol.py:183` — `blocking_keys = in_flight | current_cohort_members`,
  the visible union; the edge scan at the following lines defers on a conflict with ANY blocking key,
  checking both endpoint positions.
- `.claude/skills/parallel-add/SKILL.md:69` — the documented call shape is the four-argument form; the
  `ADMIT_CURRENT_COHORT` bullet states "shares no edge with any member of the current cohort, pinned or
  unstarted".
- `tests/scripts/dev_tools/test_parallel_mutation_admission.py` — 12 passing tests including the C1
  regression (`test_conflict_with_an_unstarted_current_cohort_member_defers`) and the replacement pair
  distinguishing an in-cohort from an out-of-cohort unstarted conflict.
- Fail-before / pass-after: `EXIT_CODE: 1` with observed `ADMIT_CURRENT_COHORT`, then `EXIT_CODE: 0`
  (`<FEATURE>/evidence/regression-testing/remediation1-c1-admission-cohort-independence.md`).

**`[x]` marker is HONEST under the amended text. No correction required.**

### S5 (amended by [P1-T9], correction C2) — **PASS**

Amended clause: "recoloring is a pure function of `(remaining subgraph, pinned set, pinned cohort
index)` and assigns every unstarted item an index strictly above the pinned items' index whenever any
unstarted item conflicts with a pinned item ... property-based tests P1, P2, P3, and P4 pass."

Executed evidence, as [P7-T11] requires S5 to cite:

- **[P4-T5] offset scenarios** — `tests/scripts/dev_tools/test_parallel_mutation_recolor.py`,
  `TestPinnedBarrierOffset`: strictly-greater index at `current_cohort = 0` and at `current_cohort = 3`;
  lowest index equals `current_cohort` exactly with no unstarted-to-pinned edge; uniform offset keeping
  conflicting items distinct; negative `current_cohort` raising `ParallelCohortInputError` with the
  invalid value as `offending_value`; pinned-free run at zero matching the pre-fix assignment. 13
  passing tests in that module.
- **Property P4 from [P4-T8]** —
  `tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py`,
  `test_no_cohort_holds_a_conflicting_pair_across_admission_sequences`, passing for the full 12-seed
  corpus with all four non-vacuity existentials and the offset-value assertion. Its binding is PROVEN
  by execution in `<FEATURE>/evidence/regression-testing/remediation1-property-p4-binding.md`: it fails
  under the in-flight-only reversion (`9 failed`), under a removed offset (`6 failed`), and under an
  unconditional offset (`3 failed`).
- **F3 binding module from [P4-T11]** —
  `tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py`, 5 passing tests: four
  positive cases returning ZERO validator errors from the landed
  `validate_parallel_orchestrator_state_text`, plus the negative case proving the merge obligation is
  NECESSARY.
- P1, P2, and P3 all pass: `test_parallel_mutation_protocol_properties.py` (180 tests) and
  `test_parallel_mutation_pin_stability_properties.py` (24 tests).
- Purity retained: `<FEATURE>/evidence/qa-gates/remediation1-engine-size-and-purity.md` records the
  purity grep exiting 1 with no match.
- Delegation without reimplementation retained: Check J proves
  `scripts/dev_tools/parallel_cohort_computation.py` is byte-identical to `c939b5b8`.
- "Pinned items are never assigned or moved" retained:
  `TestPinnedItemsNeverMove` (6 relocated tests) passes with every assertion verbatim.

**`[x]` marker is HONEST under the amended text. No correction required.**

### S9 (amended by [P1-T10], finding R3) — **PASS**

Amended clause names the two-signal formalization: a `mutations[]` `op == 'close'` record together with
an empty current-generation cohort set; the close record required to be terminal in `open` mode; no
firing on a healthy in-progress checkpoint or an idle `open` run; closed-mode completion guarded by F3's
invariant 20 under `require_complete` and deliberately not duplicated.

Evidence: `scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py` implements exactly that
formalization and its module docstring at lines 16-43 documents it; FR9 invariant 3 in `spec.md` now
cites that docstring by line range. Wiring remains exactly one additive import and one call line
(Check C: `2 0`, zero removals). Key-gating and backward compatibility hold: 43 passing tests across
`test_validate_parallel_orchestrator_state_mutations.py` and
`test_validate_parallel_orchestrator_state_mutation_modes.py`. Coverage of the module is 100% line and
100% branch.

The feature audit scored S9 **PARTIAL** on fidelity of scope — the delivered invariant was narrower
than the pre-1.2 sentence. That gap is closed by amending the sentence to describe what was built,
which is the remediation the audit itself recommended as the better of its two options. **The AC and
the code now agree**, so S9 evaluates PASS rather than PARTIAL.

**`[x]` marker is HONEST under the amended text. No correction required.**

### U1 (amended by [P1-T11], correction C1) — **PASS**

Amended clause: "admit into the current cohort only when the candidate conflicts with no member of the
current cohort, in-flight or unstarted; otherwise defer to a future cohort and recolor the unstarted
subgraph." Same evidence as S2. The unchanged clauses — preparation via `route_id: preparation` and
edges computed over all items including in-flight ones — are untouched by this cycle and remain
satisfied (`.claude/skills/parallel-add/SKILL.md` steps 2 and 3 show no diff in this cycle).

**`[x]` marker is HONEST under the amended text. No correction required.**

### U5 (amended by [P1-T12], correction C2) — **PASS**

Amended clause: "recoloring is a pure function of `(remaining subgraph, pinned set, pinned cohort
index)` and never places an unstarted item in the pinned items' cohort when the two conflict".

Same executed evidence as S5, and specifically: the C2 regression test asserts exactly the amended
clause's negative — `cohort_assignments[300] != pinned_cohort_index` — and moved from `EXIT_CODE: 1`
(observed `{200: 0, 300: 0}`) to `EXIT_CODE: 0`. The retained determinism clause, "determinism under
mutation against a live in-flight set is proven by unit and property-based tests", is discharged by P3
in `test_parallel_mutation_pin_stability_properties.py`, whose pinned-cohort baseline now uses
`run.current_cohort` rather than a hard-coded 0, which is strictly more general than before.

**`[x]` marker is HONEST under the amended text. No correction required.**

---

## The Remaining 19 Criteria — Unaffected by This Cycle

`spec.md` S1, S3, S4, S6, S7, S8, S10, S11, S12, S13, S14, S15 and `user-story.md` U2, U3, U4, U6, U7,
U8, U9 are byte-identical to `a9e2463c` ([P1-T14] confirmed only S2, S5, S9, U1, U5 changed), and each
remains satisfied by delivered work that this cycle either did not touch or only strengthened:

- **S1** (pure functions, frozen dataclasses, injected clock) — strengthened: the purity grep still
  reports no I/O, clock, or RNG access, and both changed functions remain pure.
- **S6, S7, U6** (entry shape and recompute boundary) — the per-op entry-contents table and generation
  arithmetic are byte-identical ([P1-T4] acceptance); `_stamped_generation` is untouched; the
  generation-accounting tests pass.
- **S8, U7** (mode-dependent completion semantics) — engine predicate untouched; tests pass.
- **S10, U8** (abandon-gate hook) — no PowerShell file changed; 22/22 hook tests pass.
- **S11** (wave-4 confinement) — re-proven in full by [P7-T10] Checks A-K, all PASS.
- **S12** (upstream re-verification recorded in the atomic plan) — the base plan is byte-identical
  (Check G), so its recorded reconciliation stands.
- **S13** (Black, Ruff, Pyright zero findings; coverage floors; tests under `tests/scripts/dev_tools/`;
  no file over 500 lines) — re-verified: `393 files left unchanged`, `All checks passed!`,
  `0 errors, 0 warnings`, line 92.0491% / branch 84.1920%, all five new test modules under
  `tests/scripts/dev_tools/`, every file `<= 500` ([P7-T9]).
- **S14** (PowerShell gates) — re-verified zero analyzer findings, hook suite 22/22.
- **S15** (no temp files; deterministic tests) — upheld by the new modules: no `tmp_path`, `tempfile`,
  or `TestDrive` anywhere; fixed clocks; seeded `random.Random(seed)` with the seed emitted into every
  assertion message and every pytest case id; `hypothesis` still absent.
- **S3, S4, U2, U3, U4, U9** — removal table, close gating, dispositions, and mutation-log traceability
  are untouched by this cycle; `test_parallel_mutation_protocol_ops.py` is byte-identical (Check I) and
  its 24 tests pass.

## No Criterion Was Added, Removed, or Renumbered

Counts are exactly **15** and **9**, matching plan Constraint 11. [P1-T14] independently verified via
`git diff a9e2463c` that the only AC lines changed are S2, S5, S9, U1, and U5, each as a paired
removal-and-addition at the same list position — a text amendment, not an insertion or deletion. Every
label and the file order of every criterion are unchanged, and every `[x]` marker is preserved.

---

### Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-07-parallel-mutation-protocol-442/spec.md
          docs/features/active/2026-08-07-parallel-mutation-protocol-442/user-story.md
- Total AC items: 24 (15 spec + 9 user-story)
- Checked off (delivered): 24
- Remaining (unchecked): 0
- Items remaining: none
- Executor re-evaluation after amendment: 24 PASS, 0 PARTIAL, 0 FAIL, 0 UNVERIFIED
- Newly checked off by this cycle: none (all 24 were already checked; this cycle amended the TEXT of
  S2, S5, S9, U1, and U5 and re-verified that each marker remains honest under the amended wording)
- Marker corrections required: none. All five amended criteria evaluate PASS with cited executed
  evidence, and the previously PARTIAL S9 now evaluates PASS because the spec text was amended to
  describe the delivered two-signal formalization.
```
