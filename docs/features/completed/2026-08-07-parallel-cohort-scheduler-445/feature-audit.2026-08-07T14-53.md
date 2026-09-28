# Feature Audit — 2026-08-07-parallel-cohort-scheduler-445

- **Timestamp:** 2026-08-07T14-53
- **Issue:** #445 (epic `parallel-orchestration`, child F2, wave 0)
- **Branch:** `feature/parallel-cohort-scheduler-445`
- **Baseline:** `epic/parallel-orchestration-integration` (merge base `8703d777`)
- **Work mode:** `full-feature` (`issue.md:12` — `- Work Mode: full-feature`)
- **AC sources:** `spec.md` **and** `user-story.md` (per the `acceptance-criteria-tracking` mode table)
- **Verdict:** **12 of 12 acceptance criteria genuinely satisfied in both files.** 0 Blocking.

## AC Source Resolution

Work mode `full-feature` resolves to two AC source files, each tracked independently:

| File | AC section | Items | Checked |
|---|---|---|---|
| `docs/features/active/2026-08-07-parallel-cohort-scheduler-445/spec.md` | `## Acceptance Criteria`, lines 330-386 | 12 | 12 |
| `docs/features/active/2026-08-07-parallel-cohort-scheduler-445/user-story.md` | `## Acceptance Criteria`, lines 109-165 | 12 | 12 |

The two sections were compared and are textually identical, all 12 items `- [x]`.

The check-off diff was verified to be checkbox-only — no criterion text was altered, which the
`acceptance-criteria-tracking` skill requires ("change only `- [ ]` to `- [x]`"):

```
$ git diff epic/parallel-orchestration-integration...HEAD -- .../spec.md .../user-story.md \
    | grep -E "^[+-]" | grep -v "^[+-][+-]" | grep -vE "^[+-]- \[[ x]\]"
NO non-checkbox line changes
```

## Acceptance Criteria Evaluation

Each verdict below is the reviewer's independent finding, derived from reading the delivered source
and re-executing verification, not from the executor's `acceptance-criteria-map` artifact.

### AC-1 — Module exists and exports `compute_cohorts` with Welsh-Powell greedy coloring

**PASS.** `scripts/dev_tools/parallel_cohort_computation.py` exists (468 lines). The signature at
`:350-353` matches the spec character-for-character:
`compute_cohorts(item_keys: Iterable[int], conflict_edges: Iterable[tuple[int, int]]) -> list[list[int]]`.
Ordering by the composite key `(-degree, item_key)` ascending is at `:293-296`
(`sorted(adjacency, key=lambda item_key: (-len(adjacency[item_key]), item_key))`). Lowest-free-index
greedy assignment is at `:341-345` (`candidate_index = 0`; `while candidate_index in
neighbor_indices: candidate_index += 1`). Anchor scenario reproduced independently by hand-trace and
by execution: `compute_cohorts([443, 444, 445, 446], [(443, 445), (443, 446)]) == [[443, 444],
[445, 446]]`.

### AC-2 — Accepts a computed conflict graph; no blast radii; never evaluates `conflicts(a, b)`; docstring records the F3 reduction

**PASS.** The only inputs are an item-key set and an edge list. The module contains no `conflicts`
symbol, no path/module mapping, and no radius derivation — confirmed by full read of all 468 lines.
The module docstring records the reduction verbatim at `:19-25`
(`[(e["a"], e["b"]) for e in conflict_edges]`), including the reason the record shape is rejected
(accepting it "would couple this module to the checkpoint schema in the wrong direction"). The
contention-relation boundary is stated at `:27-31` and names F1 as owner.

### AC-3 — Edge symmetry guaranteed by internal normalization, verified by test

**PASS.** Normalization is structural: `_build_adjacency:260-261` writes each edge to both endpoints
of a `dict[int, set[int]]`, so `(a, b)`, `(b, a)`, and repeats collapse to the same single neighbor
entry. Verified by three tests with exact equality against the normalized result —
`test_compute_cohorts_treats_a_reversed_edge_as_the_same_conflict` (`:185-192`),
`test_compute_cohorts_collapses_duplicated_edges_into_one_conflict` (`:195-210`), and
`test_compute_cohorts_is_unaffected_by_permuted_and_flipped_edges` (`:171-182`), which reverses
every canonical edge and reorders the list.

### AC-4 — Structural invariants, each verified by a dedicated exact-output test

**PASS.** All six sub-claims are individually covered:

| Sub-claim | Test | Line |
|---|---|---|
| Every cohort is an independent set | `..._never_places_two_conflicting_items_in_one_cohort` | 225-239 |
| Each cohort sorted ascending | `..._emits_each_cohort_sorted_ascending` | 258-275 |
| Concatenation covers `item_keys` exactly once | `..._covers_every_item_key_exactly_once` | 242-255 |
| Empty input returns `[]` | `..._empty_input_returns_no_cohorts` | 41-44 |
| All-isolated returns one cohort | `..._all_isolated_vertices_share_one_cohort` | 53-62 |
| Complete graph on n → n singleton cohorts | `..._complete_graph_returns_one_singleton_cohort_per_vertex` | 65-87 |

Each asserts a full `list[list[int]]` literal. The independent-set test additionally checks every
unordered intra-cohort pair against the conflict set rather than trusting the literal alone.

### AC-5 — `compute_concurrency_batches` slot-filling rule and its boundary matrix

**PASS.** Signature at `:419-422` matches the spec exactly. The function sorts its own input
(`:461`, `sorted(cohort_item_keys)`) rather than trusting caller ordering, then chunks with a fixed
stride (`:465-468`). All four required boundary cases plus two extras are present in
`SLOT_FILLING_CASES` (`test_..._errors.py:37-77`): 12 items at `max_concurrency = 4` → 4/4/4
(`exact-divide-12-at-4`); 10 at 4 → 4/4/2 (`remainder-10-at-4`); `max_concurrency = 1` → singletons;
`max_concurrency = 3` (equals cohort size) → one batch; `max_concurrency = 99` (exceeds size) → one
batch; empty cohort → `[]`. Concatenation equality is asserted for every case by
`test_compute_concurrency_batches_concatenate_to_the_sorted_cohort` (`:91-104`). The
`max-concurrency-one-yields-singletons` and both single-batch cases supply keys out of order
(`[503, 501, 502]`) and expect ascending output, so they also pin the internal sort.

### AC-6 — Determinism verified by fixed literal permutations

**PASS.** Three tests, all using hard-coded literals with no RNG and no generated permutations:
`..._repeated_invocation_returns_identical_cohorts` (`:147-154`),
`..._is_unaffected_by_permuted_item_keys` (`:157-168`, permutation `[447, 444, 446, 443, 445]`), and
`..._is_unaffected_by_permuted_and_flipped_edges` (`:171-182`, edges
`[(446, 445), (447, 444), (446, 443), (445, 443)]`). Each asserts equality against the shared
`CANONICAL_COHORTS` literal. Confirmed by grep that neither test file imports `random` or generates
permutations; `itertools.combinations` is imported only to *assert* the independent-set property at
`:235`, never to build input.

### AC-7 — Tie-break test fails under a descending tie-break; a separate test shows degree ordering beating insertion order

**PASS — and independently verified rather than accepted on the executor's claim.** This was the
criterion subjected to the heaviest scrutiny, because a fixture that passes under both orderings
would provide no protection and would make the check-off unearned.

An independent reference colorer with four selectable orderings (correct Welsh-Powell ascending;
descending tie-break; pure insertion-order greedy; degree-only sort relying on sort stability) was
written and each fixture run through all four:

```
=== [P1-T10] Welsh-Powell fixture (crown + pendant, test line 90-120) ===
       welsh_asc: [[701, 702, 703], [704, 705, 706, 707]]  -> PASSES the assertion
      welsh_desc: [[701, 704], [705, 706, 707], [702, 703]] -> FAILS the assertion
       insertion: [[701, 704], [702, 705, 707], [703, 706]] -> FAILS the assertion
   degree_stable: [[701, 704], [702, 705, 707], [703, 706]] -> FAILS the assertion

=== [P1-T11] tie-break fixture (five-cycle, test line 123-139) ===
       welsh_asc: [[901, 903], [902, 904], [905]]  -> PASSES the assertion
      welsh_desc: [[903, 905], [902, 904], [901]]  -> FAILS the assertion
       insertion: [[901, 903], [902, 904], [905]]  -> PASSES the assertion
   degree_stable: [[901, 903], [902, 904], [905]]  -> PASSES the assertion
```

- The `[P1-T11]` tie-break fixture **fails under a descending tie-break**, which is exactly what the
  criterion demands. Its docstring predicts the descending output `[[903, 905], [902, 904], [901]]`;
  the reference colorer produces precisely that. The claim is literally accurate.
- The `[P1-T10]` fixture **fails under insertion-order greedy**, which is exactly what the criterion
  demands, and additionally fails under a descending tie-break and under a degree-only stable sort.
  Its docstring predicts the insertion-order output `[[701, 704], [702, 705, 707], [703, 706]]`; the
  reference colorer produces precisely that.

Neither fixture is a rubber stamp, neither docstring overstates what its fixture proves, and the two
are complementary rather than redundant (`[P1-T11]` does not discriminate against insertion order,
but that axis is `[P1-T10]`'s responsibility). The executor's empirical claim is corroborated.

### AC-8 — `ParallelCohortInputError` is the single exception for all four modes, with an offending-value attribute

**PASS.** One exception class at `:65`, subclassing `ValueError`, with
`offending_value: int | tuple[int, int]` declared at `:102` and set in `__init__` at `:125`. The
per-mode value mapping is documented on the class at `:84-99` and matched by the implementation:

| Mode | Raise site | `offending_value` | Test |
|---|---|---|---|
| Duplicate item key | `:160-164` | duplicated key (`int`) | `MALFORMED_GRAPH_CASES[duplicate-item-key]` |
| Self-loop | `:196-201` | self-conflicting key (`int`) | `MALFORMED_GRAPH_CASES[self-loop-edge]` |
| Unknown endpoint | `:208-213` | offending edge (`tuple`) | `MALFORMED_GRAPH_CASES[unknown-edge-endpoint]`, plus `..._names_the_unknown_key_and_edge` |
| Non-positive `max_concurrency` | `:456-459` | invalid `int` | `..._rejects_non_positive_max_concurrency` (params `0`, `-1`, `-7`) |

Every error test names `ParallelCohortInputError` specifically (no overbroad
`pytest.raises(Exception)`) and asserts both the message content and the `offending_value`
attribute. `..._is_catchable_as_value_error` pins the `ValueError` hierarchy. All four modes are
covered as the criterion requires. The positional gap noted as Advisory A-1 in the policy audit
concerns test durability within the already-covered unknown-endpoint mode; it does not leave any
criterion sub-claim unverified.

### AC-9 — Both functions pure; docstring documents caller-owned fields and the pinned-set boundary

**PASS.** Purity verified structurally, not just by assertion: the module's entire import set is
`from __future__ import annotations` (`:57`) and `from typing import TYPE_CHECKING` (`:59`). No
`os`, `io`, `open(`, `pathlib`, `random`, `time`, `datetime`, `urllib`, `requests`, or `print(`
appears anywhere in the file. Non-mutation is structural — `list(item_keys)` at `:154`, a fresh dict
at `:252`, and `sorted(...)` rather than `.sort()` at `:461` — and is additionally asserted for both
public functions by `..._does_not_mutate_its_input_arguments` (`:278-293`) and
`..._does_not_mutate_its_input_sequence` (`:296-310`). The docstring documents caller ownership of
`generation` / `recolor_generation` and `current_cohort` at `:33-36`, the pinned-set boundary and
the induced-subgraph composition pattern at `:38-42`, and the purity contract at `:44-48`. No
pinned-set parameter exists on either signature.

### AC-10 — Parity test suite at the named path, with the only permitted split fallback; no PowerShell module

**PASS.** Primary suite at exactly `tests/scripts/dev_tools/test_parallel_cohort_computation.py`.
The split file is at exactly the one permitted fallback path
`tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py`; no other layout was
improvised. The split was mandatory rather than discretionary: `[P1-T17]` triggers "if and only if
the test file meets or exceeds 450 lines," and the executor recorded 474 lines pre-split, consistent
with the post-split reconstruction (310 + 187 = 497, less roughly 20 lines of duplicated docstring
and import preamble ≈ 477). Style mirrors `test_epic_wave_computation.py`: deterministic scenario
tests, exact-output assertions, `pytest.raises` error paths, and module-level literal fixtures that
a future mirror can replicate. No `.ps1` or `.psm1` file appears anywhere in the branch diff,
satisfying the research §7 scope decision.

### AC-11 — Coverage thresholds for the module; Black, Ruff, Pyright clean

**PASS — all figures independently re-measured by this reviewer.**

| Gate | Required | Measured | Command |
|---|---|---|---|
| Module line coverage | >= 85% | **100.0%** (59/59 statements) | `poetry run coverage json` |
| Module branch coverage | >= 75% | **100.0%** (22/22 branches) | `poetry run coverage json` |
| Black | 0 errors | `All done! 337 files would be left unchanged.` | `poetry run black --check .` |
| Ruff | 0 errors | `All checks passed!` | `poetry run ruff check .` |
| Pyright (strict) | 0 errors | `0 errors, 0 warnings, 0 informations` | `poetry run pyright` |
| Tests | all pass | `2187 passed in 9.08s` | `poetry run pytest --cov --cov-branch` |

Repo-wide totals also re-measured: line 91.06289970047762%, branch 82.00267618198038% — matching the
executor's reported 91.06% / 82.00% to full precision, and both above the 85% / 75% thresholds. The
recorded baseline of 91.02% / 81.91% is corroborated arithmetically from the raw counters: statements
went 12294 → 12353 (+59) and branches 4462 → 4484 (+22) with missing counts unchanged at 1104 and
807, so the deltas are exactly the new module's fully-covered 59 statements and 22 branches. No
regression.

The plan's prohibition on recording the combined `Cover` column as line coverage was honored: the
term-missing `TOTAL` row reports 89% (`totals.percent_covered`), and both the baseline and
coverage-delta artifacts carry an explicit section identifying that value as combined and stating it
is not recorded as line coverage.

### AC-12 — Additive only; no dependency added; files under 500 lines

**PASS.** The full branch diff contains only `A` entries for code files:

- `scripts/dev_tools/epic_wave_computation.py` — absent from the diff. Unmodified.
- `pyproject.toml` — absent from the diff. Unchanged; `grep -i hypothesis pyproject.toml` returns
  nothing, so `hypothesis` was not added.
- `quality-tiers.yml` — `ls` confirms it does not exist. Neither created nor modified.
- `.claude/skills/atomic-plan-contract/SKILL.md` — absent from the diff.
- No pre-existing production or test file is modified anywhere on the branch.
- Line counts: 468 / 310 / 187, all under 500.

The criterion's phrase "both new files" is stale relative to the three files delivered under the
pre-approved split (policy-audit Advisory A-3). The substance — every new file under 500 lines — is
satisfied for all three, so the check-off is earned. The executor correctly did not edit the
criterion text, since the `acceptance-criteria-tracking` skill forbids executors and reviewers from
altering criterion wording.

## Adjudication — `spec.md` "Definition of Done" left unchecked

**Position: I agree with the executor. Leaving the five `## Definition of Done` items unchecked is
CORRECT — neither Blocking nor Advisory as to merge.**

The executor's reasoning (that the DoD section is not an AC source under the
`acceptance-criteria-tracking` skill and was not named by plan task `[P2-T7]`) is sound. Four
independent lines of evidence support it:

1. **The skill's heading enumeration does not include it.** The `acceptance-criteria-tracking`
   skill's deterministic heading rule enumerates `## Acceptance Criteria`, `### Acceptance
   Criteria`, and `## Done When` as AC headings. `## Definition of Done` is not among them. The
   skill also states "AC items are authored by planning/scoping agents, not by executors or
   reviewers," which cuts against an executor unilaterally promoting a non-enumerated section into
   AC status.

2. **The plan designates the AC sources explicitly.** `plan.2026-08-07T11-11.md:26-31`
   ("Acceptance-Criteria Sources") states: "The authoritative acceptance criteria are the identical
   12-item `## Acceptance Criteria` sections in ... `spec.md` and ... `user-story.md`." Task
   `[P2-T7]` likewise scopes check-off to "the 12 acceptance criteria in the identical `##
   Acceptance Criteria` sections." Neither names the DoD section.

3. **The parity argument is decisive.** `user-story.md` has **no** `## Definition of Done` section
   at all — its final section is `## Acceptance Criteria` at line 109. If DoD were an AC source, the
   two files could not be the "identical 12-item sections" the plan and the mode rule both rely on,
   and `full-feature` mode's requirement to "track checkboxes in **each** applicable file
   independently" would be unsatisfiable. Treating DoD as an AC source is internally inconsistent
   with the resolved work mode.

4. **The DoD text is itself stale, which is a further reason not to mechanically check it.** DoD
   item 5 reads "No file outside the **two** named new files is created or modified." Three new code
   files were delivered under the spec's own pre-approved split fallback (`spec.md:302-306`), and
   feature-folder evidence and plan documents were also written. Checking that item `[x]` as written
   would assert something literally false. Under the skill's rule 4 ("Leave unmet items unchecked"),
   leaving it unchecked is the correct handling even on the alternative reading that DoD *is*
   trackable.

**Substantive status, for the record.** Independent of the tracking question, four of the five DoD
items are substantively satisfied by this review: all 12 AC are checked with evidence (item 1);
behavior matches the Welsh-Powell, slot-filling, determinism, and error-handling rules exactly
(item 2, verified by code read plus the discrimination and mutation probes); tests exist at the
specified paths with edge cases and error handling covered (item 3); and the four-stage toolchain
passes in a single clean pass (item 4, re-run by this reviewer). Item 5 is satisfied in substance —
no file outside the delivered new files and feature-folder documents was created or modified — but
not as literally worded, because "two" is stale.

**Recommendation:** treat this as a documentation-hygiene follow-up for a planning agent, recorded
as policy-audit Advisory A-4. The DoD section should either be removed from the spec template or
marked explicitly non-tracking, and its item 5 reconciled with the pre-approved split. This reviewer
does not check the boxes, consistent with the skill's prohibition on reviewers acting outside the
resolved AC source set. **It does not block merge.**

## Baseline Comparison

The baseline `epic/parallel-orchestration-integration` contains no cohort-scheduling capability.
`scripts/dev_tools/epic_wave_computation.py` implements longest-path layering over a **directed**
dependency DAG, which as `spec.md:19-21` explains does not apply to the parallel surface's
**undirected**, symmetric contention relation. This feature adds the missing capability without
touching that module, exactly as the epic's "Reuse is by near-verbatim adaptation into new files,
not by refactoring the epic implementations into a shared abstraction" requires.

Net capability delta versus baseline:

- New: deterministic greedy Welsh-Powell cohort assignment over an undirected conflict graph.
- New: `max_concurrency` slot-filling with ascending-key batch ordering.
- New: four-mode malformed-input rejection with a dedicated `ValueError` subclass.
- New: 38 tests, +59 fully-covered statements, +22 fully-covered branches.
- Changed: nothing. Removed: nothing.

Downstream epic children F3 (#444) and F4 (#443) declare a dependency on F2 and can now consume the
documented contract, including the checkpoint-record reduction the module docstring pins for them.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-07-parallel-cohort-scheduler-445/spec.md
          docs/features/active/2026-08-07-parallel-cohort-scheduler-445/user-story.md
- Total AC items: 12 (per file; identical sections)
- Checked off (delivered): 12
- Remaining (unchecked): 0
- Items remaining: none
```

No criterion required a reviewer check-off, because the executor had already checked all 12 and this
audit independently confirmed each was earned. No criterion was downgraded to PARTIAL, FAIL, or
UNVERIFIED, so no check-off needed to be reverted.

Separately tracked, not part of the AC total: `spec.md` `## Definition of Done`, 5 items, 0 checked —
correct per the adjudication above.

## Verdict

**ACCEPT.** All 12 acceptance criteria are genuinely satisfied in both `spec.md` and
`user-story.md`; every check-off is earned by delivered code and independently reproduced
verification, not by assertion. The criterion carrying the greatest risk of an unearned check-off
(AC-7, the discriminating fixtures) was tested adversarially with an independent reference colorer
and survived. 0 Blocking findings; 4 Advisory findings recorded in the policy audit and code review,
none of which blocks merge. No remediation-inputs artifact is required.
