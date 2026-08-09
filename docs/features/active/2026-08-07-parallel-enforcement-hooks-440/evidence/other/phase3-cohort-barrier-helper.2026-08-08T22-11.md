# Phase 3 — Layer 2 Cohort-Barrier Helper Module — Issue #440 (F7)

Timestamp: 2026-08-08T22-11

Task: [P3-T1]

Created file: `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` (378 lines, under the 500-line limit)

Command: `wc -l scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py`

EXIT_CODE: 0

## Public Signature

```python
def validate_cohort_barrier_ordering(state: dict[str, object]) -> list[str]:
```

One-argument form, exactly as specified by plan Binding Constraint 2 and P3-T3.
The P0-T11 advisory (recorded at `frozen-constants.2026-08-08T21-09.md` line 145)
noted that the F3 seam comment suggests a two-argument
`errors.extend(<helper>(state_map, CONTEXT))` form. The plan's one-argument form
was used, because the mandated message carries no `Parallel checkpoint` context
prefix and therefore has no use for `CONTEXT`. **The discrepancy is real and is
noted here as required:** the seam comment at
`scripts/dev_tools/validate_parallel_orchestrator_state.py:328-329` still reads
`one appended 'errors.extend(<helper>(state_map, CONTEXT))' call`, which does not
match the landed call. The comment is F3-owned prose and was not edited, per the
wave-4 contention constraint. Recommend F3 correct the comment, or the epic record
the divergence, at integration.

## Frozen Constants Consumed (P0-T11)

| Constant in the module | Value | Source |
| --- | --- | --- |
| `ITEM_START_TIMESTAMP_FIELD` | `worktree_created_at` | U9 frozen name, item start |
| `MERGE_CONFIRMATION_TIMESTAMP_FIELD` | `merged_at` | U9 frozen name, merge confirmation |
| `VIOLATION_PREFIX` | `PARALLEL_COHORT_BARRIER_VIOLATION` | design section 9 |
| `NOT_STARTED_MERGE_STATUS` | `not_started` | F3 merge-status enum (U5) |
| `GATING_KEYS` | `("conflict_edges", "cohorts")` | P3-T1 key gate |
| barrier-satisfying statuses | imported `MERGED_MERGE_STATUSES` = `('merged', 'worktree_removed')` | U6; imported, never redefined |

Neither `in_flight_at` nor `started_at` appears anywhere in the module, per the
explicitly frozen negative in P0-T11.

## Behavior Implemented

- **Key gate.** Returns `[]` immediately when either `conflict_edges` or `cohorts`
  is absent, so a checkpoint predating this invariant validates byte-identically.
- **Current-generation projection.** Only `cohorts[]` rows whose `generation`
  equals the top-level `recolor_generation` inform the member-to-cohort-index map.
  Superseded generations are ignored.
- **Structural reading.** A conflict edge whose endpoints share a
  current-generation cohort index is a violation, unconditionally, per `spec.md`
  ("Conflicting items scheduled into one cohort run concurrently by
  construction").
- **Temporal reading.** With the endpoints ordered by cohort index, a violation is
  reported when the later-cohort item has started (non-empty start timestamp
  string, or a `merge_status` other than `not_started`) while the earlier item's
  `merge_status` is not in `{merged, worktree_removed}`; or, when both timestamps
  are present as strings, when the earlier item's `merged_at` compares
  chronologically greater than the later item's `worktree_created_at` by ISO-8601
  string comparison.
- **Mandated degradation.** `_merge_confirmed_after_start` returns False whenever
  either timestamp is absent or is not a string, so the check falls back to the
  structural-plus-status readings. No timestamp is inferred, defaulted, or
  synthesized anywhere in the module.
- **`feature_folder` hint tolerance.** A union reference index over `items[]`
  resolves an `issue_num` reference or a `feature_folder` hint, stripping the
  lifecycle prefixes `docs/features/active/`, `docs/features/completed/`,
  `active/`, and `completed/`, following the epic precedent in
  `scripts/dev_tools/_epic_orchestrator_state_resolution.py`.
- **Message.** Exactly one message per violated edge, in `conflict_edges[]`
  document order, in the byte-exact form
  `PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with conflicting <b>`
  with `<a>` the earlier endpoint (the first endpoint for the structural case,
  the lower-cohort endpoint for the temporal case), with no context prefix and no
  trailing period.
- **Purity.** Every function reads its arguments and returns new values; nothing is
  written back. Asserted by `test_validation_does_not_mutate_the_checkpoint`.
- **No schema growth.** The module reads only `cohorts[]`, `conflict_edges[]`,
  `items[].issue_num`, `items[].feature_folder`, `items[].merge_status`,
  `recolor_generation`, and the two optional F3 lifecycle timestamps. It defines
  no new checkpoint field and extends no F3 enum.
- **No shape validation.** Malformed collections and entries are skipped rather
  than re-reported, because F3's invariants 5, 12, 13, and 15 already report them.

## Wave-4 Contention Compliance

The module is a new sibling file. It cannot textually conflict with F6 (#445) or
F8 (#446), and it cannot push the shared 336-line
`validate_parallel_orchestrator_state.py` toward the 500-line cap: all invariant
logic lives here, and the shared file grew by four lines only (see
`phase3-validator-seam-edit.2026-08-08T22-11.md`).

Output Summary: PASS. Created
`scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` at 378 lines
(under the 500-line cap), exposing the one-argument public entry
`validate_cohort_barrier_ordering(state: dict[str, object]) -> list[str]`. The
module isolates the U9 frozen timestamp field names `worktree_created_at` and
`merged_at` as constants, implements the unconditional structural reading and the
status-plus-timestamp temporal reading, degrades to structural-plus-status
whenever either timestamp is absent or non-string, tolerates `feature_folder`
hints via a union reference index, emits exactly one byte-exact
`PARALLEL_COHORT_BARRIER_VIOLATION` message per violated edge with the earlier
endpoint first, never mutates its input, and adds no checkpoint schema field.
Black-clean, ruff-clean, and pyright-clean (P3-T4/T5/T6), with 96.30% line and
91.07% branch coverage (P3-T7). The P0-T11 seam-comment/plan signature
discrepancy is confirmed and recorded above: the F3 seam comment still describes
the two-argument form and was deliberately left unedited.
