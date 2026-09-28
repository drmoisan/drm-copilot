# Acceptance-Criteria Map and End-State Verification

- Task: [P2-T7]
- Feature: 2026-08-07-parallel-cohort-scheduler-445 (issue #445)

Timestamp: 2026-08-07T14-44
Command: git status --porcelain
EXIT_CODE: 0

Output Summary:
- Work mode is `full-feature`, so the AC sources are both `spec.md` and `user-story.md`. Both carry
  identical 12-item `## Acceptance Criteria` sections.
- All 12 criteria were verified against delivered code, named tests, and Phase 2 toolchain
  artifacts, and were checked off independently in both files. 0 remain unchecked.
- `git status --porcelain` confirms no file outside the three delivered new files and the
  feature-folder documents was created or modified.

## AC Sources

| File | AC section | Items |
|---|---|---|
| `docs/features/active/2026-08-07-parallel-cohort-scheduler-445/spec.md` | `## Acceptance Criteria` (lines 330-386) | 12 |
| `docs/features/active/2026-08-07-parallel-cohort-scheduler-445/user-story.md` | `## Acceptance Criteria` (lines 109-165) | 12 |

## Criterion-to-Evidence Mapping

### AC-1 — Module exists and exports `compute_cohorts` with Welsh-Powell greedy coloring

Verdict: **PASS** — checked off in both files.

- `scripts/dev_tools/parallel_cohort_computation.py` exists (468 lines).
- `compute_cohorts(item_keys: Iterable[int], conflict_edges: Iterable[tuple[int, int]]) -> list[list[int]]`
  is defined at lines 350-353 with the exact spec signature.
- Welsh-Powell ordering by the composite key `(-degree, item_key)` ascending is implemented in
  `_welsh_powell_order` (lines 266-296): `sorted(adjacency, key=lambda item_key: (-len(adjacency[item_key]), item_key))`.
- Lowest-free-index greedy assignment is implemented in `_assign_cohort_indices` (lines 299-347):
  the `while candidate_index in neighbor_indices` scan starts at 0.
- Tests: `test_module_public_surface_is_importable`,
  `test_compute_cohorts_user_story_scenario_splits_the_conflicting_items` (asserts
  `compute_cohorts([443, 444, 445, 446], [(443, 445), (443, 446)]) == [[443, 444], [445, 446]]`),
  `test_compute_cohorts_uses_degree_order_not_the_supplied_item_key_order`.

### AC-2 — Accepts a precomputed conflict graph; no blast radii; no `conflicts(a, b)`; docstring records the F3 reduction

Verdict: **PASS** — checked off in both files.

- Module docstring section `Input reduction from the checkpoint record:` (lines 19-25) records the
  one-line reduction `[(e["a"], e["b"]) for e in conflict_edges]` from the F3
  `conflict_edges[] = { a, b, reason }` record shape.
- Module docstring section `Contention-relation boundary:` (lines 27-31) states the module does not
  compute blast radii and never evaluates `conflicts(a, b)`.
- Verified by reading the full module: there is no `conflicts` symbol and no blast-radius
  computation anywhere in the file; the only inputs are the item-key set and the edge list.
- Test: `test_compute_cohorts_user_story_scenario_splits_the_conflicting_items` consumes an
  already-computed edge list only.

### AC-3 — Edge symmetry by internal normalization, verified by direction-flipped and duplicated tests

Verdict: **PASS** — checked off in both files.

- `_build_adjacency` (lines 216-263) records each conflict on both endpoints into `set[int]`
  neighbor sets, which collapses `(a, b)`, `(b, a)`, and repeats to one neighbor entry per side.
- Tests: `test_compute_cohorts_treats_a_reversed_edge_as_the_same_conflict` (asserts
  `compute_cohorts([443,444,445], [(445, 443)]) == compute_cohorts([443,444,445], [(443, 445)])`),
  `test_compute_cohorts_collapses_duplicated_edges_into_one_conflict` (edge list
  `[(443, 445), (445, 443), (443, 445)]` yields the normalized result).

### AC-4 — Structural invariants with exact-output assertions

Verdict: **PASS** — checked off in both files.

| Sub-invariant | Test |
|---|---|
| Independent set per cohort | `test_compute_cohorts_never_places_two_conflicting_items_in_one_cohort` (checks every unordered pair per cohort against the conflict set) |
| Each cohort sorted ascending | `test_compute_cohorts_emits_each_cohort_sorted_ascending` |
| Concatenation covers `item_keys` exactly once | `test_compute_cohorts_covers_every_item_key_exactly_once` |
| Empty input returns `[]` | `test_compute_cohorts_empty_input_returns_no_cohorts` |
| All-isolated returns one cohort | `test_compute_cohorts_all_isolated_vertices_share_one_cohort` (`[[443, 444, 445, 446]]`) |
| Complete graph on `n` returns `n` singletons | `test_compute_cohorts_complete_graph_returns_one_singleton_cohort_per_vertex` (`[[443], [444], [445], [446]]`) |

Additional: `test_compute_cohorts_single_vertex_returns_one_singleton_cohort`. Every listed test
uses an exact-output assertion.

### AC-5 — `compute_concurrency_batches` slot-filling rule and boundary matrix

Verdict: **PASS** — checked off in both files.

- Implemented at lines 419-468 with the exact spec signature; sorts its own input at line 461
  (`ordered_keys = sorted(cohort_item_keys)`) and chunks with a fixed stride at lines 465-468.
- Boundary matrix is `SLOT_FILLING_CASES` in
  `tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py` (lines 37-77), driving two
  parametrized tests:
  - `test_compute_concurrency_batches_matches_the_expected_batch_layout`
  - `test_compute_concurrency_batches_concatenate_to_the_sorted_cohort` (asserts concatenation
    equals `sorted(cohort)` for every case)
- Cases: `exact-divide-12-at-4` (three batches of four), `remainder-10-at-4` (4/4/2),
  `max-concurrency-one-yields-singletons`, `max-concurrency-equals-cohort-size`,
  `max-concurrency-exceeds-cohort-size`, `empty-cohort-yields-no-batches`.

### AC-6 — Determinism verified by fixed literal permutations

Verdict: **PASS** — checked off in both files.

- Tests (all permutations are hard-coded literals; no RNG and no generation):
  - `test_compute_cohorts_repeated_invocation_returns_identical_cohorts`
  - `test_compute_cohorts_is_unaffected_by_permuted_item_keys` (literal `[447, 444, 446, 443, 445]`)
  - `test_compute_cohorts_is_unaffected_by_permuted_and_flipped_edges` (literal
    `[(446, 445), (447, 444), (446, 443), (445, 443)]`)
- All three assert equality against `CANONICAL_COHORTS = [[443, 444], [445, 447], [446]]`.

### AC-7 — Dedicated tie-break test and Welsh-Powell-versus-insertion-order test

Verdict: **PASS** — checked off in both files.

- `test_compute_cohorts_breaks_degree_ties_by_ascending_item_key`: five-cycle fixture where every
  vertex has degree 2, so the tie-break alone decides. Ascending yields
  `[[901, 903], [902, 904], [905]]`; the docstring records that a descending tie-break would yield
  `[[903, 905], [902, 904], [901]]`, so the exact-output assertion fails if the direction inverts.
- `test_compute_cohorts_uses_degree_order_not_the_supplied_item_key_order`: crown-graph-plus-pendant
  fixture supplied in interleaved order. Insertion-order greedy coloring yields three cohorts
  (`[[701, 704], [702, 705, 707], [703, 706]]`); Welsh-Powell yields the two-cohort
  `[[701, 702, 703], [704, 705, 706, 707]]`, which is what the test asserts.

### AC-8 — `ParallelCohortInputError` as the single dedicated exception for all four modes

Verdict: **PASS** — checked off in both files.

- Defined at lines 65-126, subclasses `ValueError`, declares `offending_value: int | tuple[int, int]`,
  and documents the per-mode attribute mapping in its class docstring.
- Raise sites: `_validate_item_keys` (duplicate key), `_validate_edge` (self-loop; unknown
  endpoint), `compute_concurrency_batches` (non-positive `max_concurrency`). It is the only
  exception type raised in the module.
- Tests in `test_parallel_cohort_computation_errors.py`:
  - `test_compute_cohorts_rejects_malformed_graph_input` parametrized over `unknown-edge-endpoint`,
    `self-loop-edge`, `duplicate-item-key`; each asserts the type, that `offending_value` equals the
    per-mode value, and that the message names the offending value.
  - `test_compute_concurrency_batches_rejects_non_positive_max_concurrency` over `[0, -1, -7]`;
    asserts type, `offending_value`, the value in the message, and the `">= 1"` requirement text.
  - `test_parallel_cohort_input_error_message_names_the_unknown_key_and_edge` asserts the message
    names both `999` and `(444, 999)`.
  - `test_parallel_cohort_input_error_is_catchable_as_value_error`.

### AC-9 — Purity of both public functions; caller-owned fields and pinned-set boundary documented

Verdict: **PASS** — checked off in both files.

- Purity verified by reading the module: the only import is `typing.TYPE_CHECKING` plus
  `collections.abc` names under `TYPE_CHECKING`. There is no file I/O, no network call, no `time`,
  `datetime`, or `random` access anywhere in the file.
- Module docstring section `Purity contract:` (lines 44-48) states the contract explicitly.
- Module docstring section `Caller-owned fields:` (lines 33-36) documents that `generation`
  (the `recolor_generation` counter) and `current_cohort` are caller-owned and never produced,
  incremented, or accepted.
- Module docstring section `Pinned-set boundary:` (lines 38-42) documents that recoloring is
  performed by the caller invoking `compute_cohorts` on the induced not-yet-started subgraph with
  in-flight items excluded; no pinned-set parameter exists (confirmed by the two function
  signatures).
- Non-mutation tests: `test_compute_cohorts_does_not_mutate_its_input_arguments` (asserts both the
  `item_keys` list object and the `conflict_edges` list object equal their pre-call copies) and
  `test_compute_concurrency_batches_does_not_mutate_its_input_sequence`.

### AC-10 — Parity test suite at the specified path(s); no PowerShell module

Verdict: **PASS** — checked off in both files.

- `tests/scripts/dev_tools/test_parallel_cohort_computation.py` exists (310 lines, 19 test
  functions).
- `tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py` exists (187 lines), which is
  the only permitted split fallback; the [P1-T17] split condition triggered and was applied. No
  other new test file exists.
- Style parity with `tests/scripts/dev_tools/test_epic_wave_computation.py`: deterministic scenario
  tests with exact-output assertions, `pytest.raises` error paths with message and attribute
  assertions, and replicable literal scenario fixtures (`CANONICAL_*`, `INVARIANT_*`,
  `SLOT_FILLING_CASES`, `MALFORMED_GRAPH_CASES`).
- No PowerShell module created: `git status --porcelain --untracked-files=all` filtered for
  `.ps1`/`.psm1`/`.psd1` returned no matches (grep exit 1).

### AC-11 — Coverage thresholds met; Black, Ruff, Pyright each pass with zero errors

Verdict: **PASS** — checked off in both files.

- Module line coverage 100.00%, branch coverage 100.00% (>= 85% / >= 75%), measured by
  `poetry run pytest --cov --cov-branch --cov-report=term-missing`. Evidence:
  `evidence/qa-gates/final-qc-pytest.2026-08-07T14-39.md` and
  `evidence/qa-gates/coverage-delta.2026-08-07T14-39.md`.
- Black: `EXIT_CODE: 0`, 0 files reformatted — `evidence/qa-gates/final-qc-black.2026-08-07T14-37.md`.
- Ruff: `EXIT_CODE: 0`, `All checks passed!` — `evidence/qa-gates/final-qc-ruff.2026-08-07T14-37.md`.
- Pyright: `EXIT_CODE: 0`, `0 errors, 0 warnings, 0 informations` —
  `evidence/qa-gates/final-qc-pyright.2026-08-07T14-37.md`.

### AC-12 — Additive-only change; no `quality-tiers.yml`; no new dependency; files under 500 lines

Verdict: **PASS** — checked off in both files.

- `git diff --stat` reports changes only to three feature-folder documents
  (`plan.2026-08-07T11-11.md`, `spec.md`, `user-story.md`), all of which are checkbox updates
  required by the plan. No production or test file is modified.
- `scripts/dev_tools/epic_wave_computation.py` is absent from `git status --porcelain`, so it is
  unmodified.
- `quality-tiers.yml` does not exist at the repository root (`ls quality-tiers.yml` -> `No such file
  or directory`); it was neither created nor modified.
- `pyproject.toml` contains zero occurrences of `hypothesis` and is unmodified;
  `poetry.lock` is likewise unmodified (`git diff --stat -- pyproject.toml poetry.lock` produced no
  output). No new Python dependency was added.
- File sizes, all under the 500-line limit:
  - `scripts/dev_tools/parallel_cohort_computation.py` — 468 lines
  - `tests/scripts/dev_tools/test_parallel_cohort_computation.py` — 310 lines
  - `tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py` — 187 lines

## End-State Verification (`git status --porcelain`)

```
 M docs/features/active/2026-08-07-parallel-cohort-scheduler-445/plan.2026-08-07T11-11.md
 M docs/features/active/2026-08-07-parallel-cohort-scheduler-445/spec.md
 M docs/features/active/2026-08-07-parallel-cohort-scheduler-445/user-story.md
?? docs/features/active/2026-08-07-parallel-cohort-scheduler-445/evidence/
?? scripts/dev_tools/parallel_cohort_computation.py
?? tests/scripts/dev_tools/test_parallel_cohort_computation.py
?? tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py
```

Classification of every entry:

| Entry | Category | Permitted |
|---|---|---|
| `plan.2026-08-07T11-11.md` | Feature-folder document (plan checkbox updates) | Yes |
| `spec.md` | Feature-folder document (AC checkbox updates, [P2-T7]) | Yes |
| `user-story.md` | Feature-folder document (AC checkbox updates, [P2-T7]) | Yes |
| `.../evidence/` | Feature-folder evidence directory | Yes |
| `scripts/dev_tools/parallel_cohort_computation.py` | Delivered new production file | Yes |
| `tests/scripts/dev_tools/test_parallel_cohort_computation.py` | Delivered new test file | Yes |
| `tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py` | Delivered new test file ([P1-T17] split) | Yes |

No file outside the delivered new files and the feature-folder documents was created or modified.

## Scope Note — `## Definition of Done`

`spec.md` also contains a separate `## Definition of Done` section (lines 388-396) with five
checkbox items. That section is not an acceptance-criteria source under the
`acceptance-criteria-tracking` skill and is not named by the [P2-T7] task text, so its checkbox
state was intentionally left unchanged. This note is recorded so the untouched state is auditable
and is not mistaken for an unverified acceptance criterion.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-07-parallel-cohort-scheduler-445/spec.md,
          docs/features/active/2026-08-07-parallel-cohort-scheduler-445/user-story.md
- Total AC items: 12 (per file; the two sections are identical)
- Checked off (delivered): 12 in spec.md, 12 in user-story.md
- Remaining (unchecked): 0 in spec.md, 0 in user-story.md
- Items remaining: none
```
