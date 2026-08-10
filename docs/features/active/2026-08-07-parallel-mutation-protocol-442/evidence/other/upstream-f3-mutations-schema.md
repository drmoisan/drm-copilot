# Upstream Contract Re-Verification — F3 `mutations[]` Schema ([P1-T3])

Timestamp: 2026-08-08T21-48

Command: `Read scripts/dev_tools/validate_parallel_orchestrator_state.py`
EXIT_CODE: 0

Command: `Read scripts/dev_tools/_parallel_state_records.py`
EXIT_CODE: 0

Command: `Grep '^VALID_|^MERGED_' scripts/dev_tools/_parallel_state_common.py`
EXIT_CODE: 0

Command: `wc -l scripts/dev_tools/validate_parallel_orchestrator_state.py scripts/dev_tools/_parallel_state_records.py`
EXIT_CODE: 0

Command: `grep -n "BEGIN F7 EXTENSION SEAM\|END F7 EXTENSION SEAM\|_validate_collections(state_map)" scripts/dev_tools/validate_parallel_orchestrator_state.py`
EXIT_CODE: 0

## Verified Entry Shape (seven fields)

`scripts/dev_tools/_parallel_state_records.py::validate_mutations` reads exactly these
fields from each `mutations[]` entry, in this order:

| Field | Read at | Verdict |
| --- | --- | --- |
| `op` | `_parallel_state_records.py:242` | no divergence |
| `item_key` | `_parallel_state_records.py:91` (via `_validate_mutation_item_key`) | no divergence |
| `at` | `_parallel_state_records.py:248` | no divergence |
| `prior_state` | `_parallel_state_records.py:132` (via `_validate_mutation_state_field`) | no divergence |
| `new_state` | `_parallel_state_records.py:132` (via `_validate_mutation_state_field`) | no divergence |
| `disposition` | `_parallel_state_records.py:163` (via `_validate_mutation_disposition`) | no divergence |
| `recolor_generation` | `_parallel_state_records.py:196` (via `_validate_mutation_generation`) | no divergence |

No eighth field is read. F6 adds no field.

## Verified Enums (all consumed, never extended)

- `op` vocabulary: `VALID_MUTATION_OPS = ("add", "remove", "close", "requeue")`
  (`_parallel_state_common.py:64`). Verdict: no divergence.
- Item-state enum: `VALID_ITEM_STATES = proposed admitted prepared scheduled in_flight
  merged withdrawn blocked` (`_parallel_state_common.py:39-41`). Verdict: no divergence.
- `merge_status` enum: `VALID_MERGE_STATUS = not_started worktree_created pr_open
  ci_green merged worktree_removed blocked_drift blocked_ci_loop_limit`
  (`_parallel_state_common.py:46-51`) — includes `worktree_removed` and `blocked_drift`
  as the task requires. Verdict: no divergence.
- `MERGED_MERGE_STATUSES = ("merged", "worktree_removed")`
  (`_parallel_state_common.py:84`) — the completion-predicate terminal set.
  Verdict: no divergence.
- `disposition` enum: `VALID_DISPOSITIONS = ("detach", "abandon")`
  (`_parallel_state_common.py:68`). Verdict: no divergence.

## Confirmed Landed Nullability Rule (the reconciled cell)

Expected verdict per the plan: **no divergence**. Confirmed against two independent
landed sources.

Source 1 — `scripts/dev_tools/_parallel_state_records.py`:

- line 53: `OPS_REQUIRING_NULL_PRIOR_STATE: tuple[str, ...] = tuple("add close".split())`
  — resolves to `("add", "close")`.
- line 56: `OPS_REQUIRING_NULL_NEW_STATE: tuple[str, ...] = ("close",)`.
- lines 135-138 emit `f"{entry_context} {field} must be null for op {op!r}; found:
  {value!r}."`, which for `op == "add"` and `field == "prior_state"` renders the error
  text `prior_state must be null for op 'add'`.
- lines 95-101: `item_key` must be null for `op == "close"`.
- line 102: `item_key` must resolve to an `items[].issue_num` for
  `OPS_REQUIRING_ITEM_KEY = ("add", "remove", "requeue")` (line 49).
- lines 164-176: `disposition` must be `detach` or `abandon` only when
  `op == "remove"` AND `prior_state == "in_flight"`, and must be null on every other
  entry.

Source 2 — `.claude/rules/parallel-orchestration.md` invariant 16: "`prior_state` and
`new_state` either null or in the item-state enum, with `prior_state` null for `add`
and `close` and `new_state` null for `close`". Invariant 17 states the in-flight
removal disposition rule verbatim as implemented.

| Nullability cell | Landed rule | Verdict |
| --- | --- | --- |
| `prior_state` on `add` | must be null | no divergence |
| `prior_state` on `close` | must be null | no divergence |
| `prior_state` on `remove` / `requeue` | item-state enum member | no divergence |
| `new_state` on `close` | must be null | no divergence |
| `new_state` on `add` / `remove` / `requeue` | item-state enum member | no divergence |
| `item_key` on `close` | must be null | no divergence |
| `item_key` on `add` / `remove` / `requeue` | resolves to `items[].issue_num` | no divergence |
| `disposition` | non-null only on `remove` with `prior_state == in_flight` | no divergence |

### Reconciliation note (required by the task text)

This cell was reconciled after the FIRST EXECUTION ATTEMPT of [P1-T3] recorded a
genuine conflict. At that time `spec.md`'s per-op entry-contents table assigned
`prior_state: prepared` to both `add` rows, while the landed validator requires
`prior_state must be null for op 'add'`. The conflict was resolved in favor of the
landed shape, per `spec.md`'s own re-verification rule ("if F3 constrains these
differently, the landed shape wins and this table is updated at plan time"): the
spec per-op table was corrected in place to `prior_state: null` on both `add` rows,
and the plan was amended at [P1-T3], [P2-T6], [P2-T8] scenario 8, and [P3-T1]
invariant 1 to cite the landed rule directly.

The `prepared -> scheduled` transition is not lost. It is recorded as an item-state
update in the checkpoint's `items[]` state field with F3's lifecycle timestamps — the
same mechanism the spec already prescribes for `proposed -> admitted -> prepared`. The
mutation entry records only the admission outcome (`new_state: "scheduled"`) and the
generation stamp. `new_state` is unchanged by this rule: it remains `"scheduled"` on
both `add` rows. The `op` vocabulary is unchanged and no field or enum member is added
to any F3 structure.

## Confirmed Item-Key Typing (`int`, never `str`)

- `.claude/rules/parallel-orchestration.md` invariant 5: each `items[]` entry's
  `issue_num` is "a positive integer unique across items".
- `_parallel_state_records.py:59-72` — `_resolves` accepts a value only when
  `isinstance(value, int) and not isinstance(value, bool) and value in issue_nums`.
  A `str` key can never resolve.
- `_parallel_state_records.py:102` applies `_resolves` to `mutations[].item_key`, so
  `item_key` is an `int` for `add`, `remove`, and `requeue` and `None` for `close`.
- `.claude/rules/parallel-orchestration.md` invariant 15: `conflict_edges[].a` and
  `.b` resolve to `items[].issue_num` with `a < b` numeric normalization.

**Recorded explicitly: item keys are `int`, not `str`. Every F6 signature, value
object key type, exception payload, and conflict-edge tuple element must use `int`.**
Verdict: no divergence.

## Validator Extension Structure and F6 Insertion Point

- `scripts/dev_tools/validate_parallel_orchestrator_state.py` is **336 lines**
  (cap 500). Matches the plan's recorded 336.
- F7 seam boundaries at read time:
  - `# BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` — **line 325**
  - `# END F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` — **line 332**
  - The seam's own comment body (lines 326-331) states that F7 owns the block and that
    F6/F8 must not contend over those lines.
- Existing helper calls OUTSIDE the seam, in order:
  - line 320 `errors.extend(_missing_required_keys(state_map))`
  - line 321 `errors.extend(_validate_identity(state_map))`
  - line 322 `errors.extend(scan_prohibited_keys(state_map, CONTEXT))`
  - line 323 `errors.extend(_validate_collections(state_map))`
  - line 335 `errors.extend(_validate_completion(state_map))` under the
    `if require_complete:` gate at line 334, which FOLLOWS the `# END` comment.
- No F7 call line is currently present inside the seam (the block holds comments
  only). Per the task's acceptance text, the presence of one later would NOT be a
  divergence.

**Exact call-site text F6's own call line will follow:
`    errors.extend(_validate_collections(state_map))` (line 323).**

**Confirmed F6 insertion point: between line 323 and the
`# BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` comment at line 325
— that is, at current line 324, OUTSIDE the F7 seam.** Verdict: no divergence.

## Helper-Module Import/Call Structure

`validate_parallel_orchestrator_state.py` imports its helpers from
`scripts.dev_tools._parallel_state_common` (lines 38-46) and
`scripts.dev_tools._parallel_state_structures` (lines 47-56); the latter re-exports
`validate_mutations` and `validate_drift_events` from
`scripts.dev_tools._parallel_state_records`. Each collection check in
`_validate_collections` is key-gated (`if "mutations" in state:` at line 194), so an
absent key produces exactly one required-key error and no second error. F6's helper
follows the same convention. Verdict: no divergence.

## Output Summary

Overall verdict: **NO DIVERGENCE on every cell.** The seven-field entry shape, the
`op` vocabulary, the item-state and `merge_status` enums, the landed nullability rule
(`prior_state` null for `add` and `close`; `new_state` null for `close`; `item_key`
null for `close`), the `int` item-key type, and the F7-seam boundaries all match the
plan's reconciled expected states. The Phase 1 stop rule is NOT triggered. The
nullability cell is confirmed reconciled after the first execution attempt of this
task, with the conflict resolved in favor of the landed shape.
