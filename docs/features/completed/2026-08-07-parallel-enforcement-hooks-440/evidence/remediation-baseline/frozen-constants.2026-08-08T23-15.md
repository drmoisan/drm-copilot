# Frozen Port Constants and No-Touch List — Issue #440 F7 Remediation Cycle 1

- **Task:** [P0-T11]
- **Plan of record:** `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/remediation-plan.2026-08-08T23-15.md`

Timestamp: 2026-08-09T00-27

Sources read: `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py` (378 lines, untracked in the working tree) and `scripts/dev_tools/validate_parallel_orchestrator_state.py` (seam edit uncommitted). The Python side is the reference; the TypeScript port must reproduce it constant-for-constant and helper-for-helper.

## Frozen Literals — quoted as observed

### Message form

Observed at `_parallel_orchestrator_state_cohort_barrier.py:374-377`:

```python
errors.append(
    f"{VIOLATION_PREFIX}: {endpoints[0]} ran concurrently with "
    f"conflicting {endpoints[1]}"
)
```

Resolved byte-exact form:

```
PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with conflicting <b>
```

`<a>` is the earlier or first endpoint. **No context prefix** — unlike every other error this validator family emits, there is no `Parallel checkpoint` prefix. **No trailing period.** The module docstring states this explicitly: "Each violated edge contributes exactly one message in the byte-exact form mandated by design section 9, which deliberately carries no ``Parallel checkpoint`` context prefix and no trailing period."

### Module constants

Observed at lines 61, 67, 68, 72, 77, and 81-86:

```python
VIOLATION_PREFIX = "PARALLEL_COHORT_BARRIER_VIOLATION"

ITEM_START_TIMESTAMP_FIELD = "worktree_created_at"
MERGE_CONFIRMATION_TIMESTAMP_FIELD = "merged_at"

NOT_STARTED_MERGE_STATUS = "not_started"

GATING_KEYS: tuple[str, ...] = ("conflict_edges", "cohorts")

FOLDER_HINT_PREFIXES: tuple[str, ...] = (
    "docs/features/active/",
    "docs/features/completed/",
    "active/",
    "completed/",
)
```

`FOLDER_HINT_PREFIXES` is in **longest-first order** so the repository-rooted form is stripped before the bare lifecycle form. `GATING_KEYS` order is `conflict_edges` then `cohorts`.

### Barrier-satisfying set

Observed at `_parallel_orchestrator_state_cohort_barrier.py:253`:

```python
return record.get("merge_status") in MERGED_MERGE_STATUSES
```

`MERGED_MERGE_STATUSES` is **imported**, not redefined. Its definition is at `scripts/dev_tools/_parallel_state_common.py:84`:

```python
MERGED_MERGE_STATUSES: tuple[str, ...] = ("merged", "worktree_removed")
```

The set is `{merged, worktree_removed}`. **`ci_green` does NOT satisfy the barrier** — the docstring at lines 248-250 states: "``ci_green`` deliberately does not satisfy the barrier: the next cohort may branch only from durably merged work." The TypeScript port must likewise **import** `MERGED_MERGE_STATUSES` from `./parallel-state-shared` rather than redefine it.

The barrier module's full import block, observed at lines 52-56, is the set of shared helpers the TypeScript port must mirror by import rather than reimplementation:

```python
from scripts.dev_tools._parallel_state_common import (
    MERGED_MERGE_STATUSES,
    is_non_negative_integer,
    is_positive_integer,
)
```

`is_positive_integer` is defined at `_parallel_state_common.py:137` and `is_non_negative_integer` at line 151; both reject booleans (`isinstance(value, int) and not isinstance(value, bool)`), which the TypeScript `isPositiveInteger` / `isNonNegativeInteger` guards must match.

### The Python seam call — the helper takes the state only

Observed in the uncommitted diff of `scripts/dev_tools/validate_parallel_orchestrator_state.py`, inside the F7 seam:

```python
    # Add F7 helper invocations below this line, one per line.
    errors.extend(validate_cohort_barrier_ordering(state_map))
    # END F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION
```

with the matching import:

```python
from scripts.dev_tools._parallel_orchestrator_state_cohort_barrier import (
    validate_cohort_barrier_ordering,
)
```

The call passes **the state only and no context argument.** The public signature, observed at line 331, is `def validate_cohort_barrier_ordering(state: dict[str, object]) -> list[str]:`. This is why P1-T2's TypeScript seam call is `errors.push(...validateCohortBarrierOrdering(state));` with no `CONTEXT` argument: the seam comment's `(state, CONTEXT)` wording is a template, not a signature, and an unused parameter would fail `@typescript-eslint/no-unused-vars`.

### Behavioral rules the port must reproduce

- **Key gate** (lines 348-352): return `[]` when either gating key is absent from `state`, or when `conflict_edges` is not a list.
- **First-occurrence semantics** (lines 139, 142, 217): `records.setdefault`, `by_folder_hint.setdefault`, and `assignments.setdefault` — first occurrence wins in all three maps. Duplicates are invariant 5's and invariant 13's errors, not this module's.
- **Strict generation equality** (line 206): `if row.get("generation") != recolor_generation: continue`. Only rows whose `generation` strictly equals the top-level `recolor_generation` are read; a superseded generation records a coloring that no longer governs scheduling.
- **Empty projection guard** (line 197): the projection is empty unless `cohorts` is a list and `recolor_generation` satisfies `is_non_negative_integer`.
- **Row skip** (line 210): a cohort row is skipped unless `index` satisfies `is_non_negative_integer` and `item_keys` is a list.
- **`_has_started`** (lines 234-238): a non-blank `worktree_created_at` string, OR a string `merge_status` other than `not_started`. An **absent** `merge_status` never evidences a start.
- **Structural reading** (lines 306-307): equal defined cohort indices are a violation, and the edge's own endpoint order names the message — `return (first, second)`.
- **Unjudgeable edge** (lines 310-311): an endpoint outside the current coloring returns `None`.
- **Temporal reading** (lines 318-328): order endpoints by cohort index, then violate when `_has_started(later) and not _satisfies_barrier(earlier)` OR `_merge_confirmed_after_start(earlier, later)`.
- **Degrade-to-structural-plus-status** (lines 275-276): `_merge_confirmed_after_start` returns `False` whenever either value is absent or is not a string. **No timestamp is ever inferred, defaulted, or synthesized.** Otherwise the comparison is ordinal string comparison `confirmed > started`.
- **Edge skip** (lines 363-371): a non-object edge is skipped; an edge whose endpoints do not both resolve, or which is a self-edge (`first == second`), is skipped.
- **One message per violated edge**, appended in `conflict_edges[]` document order, even when both readings hold.
- **No schema field is added, no shape validation is performed, the argument is never mutated, and no I/O occurs.** The module docstring's "Raises and side effects" section states: "None anywhere in this module. Every function is pure."

### Private helper roster to mirror one-for-one

| Python private | TypeScript module-private |
|---|---|
| `_normalize_folder_hint` | `normalizeFolderHint` |
| `_build_reference_index` | `buildReferenceIndex` |
| `_resolve_reference` | `resolveReference` |
| `_cohort_index_by_item` | `cohortIndexByItem` |
| `_has_started` | `hasStarted` |
| `_satisfies_barrier` | `satisfiesBarrier` |
| `_merge_confirmed_after_start` | `mergeConfirmedAfterStart` |
| `_violation_endpoints` | `violationEndpoints` |
| `validate_cohort_barrier_ordering` (public) | `validateCohortBarrierOrdering` (the only export) |

## No-Touch List (complete)

No task in this cycle may create, modify, delete, or reformat any of the following.

### Python barrier reference files — the reference conforms to nothing; the TypeScript side conforms to it

1. `scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py`
2. `scripts/dev_tools/validate_parallel_orchestrator_state.py`
3. `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py`

No narrowing, weakening, or re-scoping of the Python implementation is permitted.

### Concurrent wave-4 sibling surfaces

4. Every F6 (#442, mutation protocol) surface.
5. Every F8 (#446, radius drift detection) surface.
6. The reserved section `## Mutation Protocol (F6)` in `.claude/skills/parallel-orchestrate/SKILL.md`.
7. The reserved section `## Radius Drift Detection (F8)` in `.claude/skills/parallel-orchestrate/SKILL.md`.

`.claude/skills/parallel-orchestrate/SKILL.md` is already modified in the working tree by the **original** plan and must remain unchanged by this cycle. It appears in the P0-T12 baseline set, not in this cycle's delta.

### Policy documents

8. Every file under `.claude/rules/`.
9. Every file under `.github/instructions/`.

Option B for finding B-1 — an authoritative deferral recorded in `.claude/rules/parallel-orchestration.md` — is therefore unavailable to an executor, which is why Option A (port the invariant) is the selected resolution.

## Permitted Edit Set (for contrast)

Exactly four existing files may be edited by this cycle, each within the narrow bound its task states:

- `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts` — two added lines, zero changed (P1-T2)
- `extensions/drm-copilot/test/lib/validate/parallel-orchestrator-state-structures.test.ts` — the `stateWithEdges` cohort recolour and its TSDoc expansion (P1-T3)
- `extensions/drm-copilot/jest.config.cjs` — one added `coverageThreshold` entry (P1-T5)
- This feature's own plan and evidence artifacts

Plus new files: the new TypeScript module, two new TypeScript test files, one new Python parity test, and the `tests/fixtures/parallel_cohort_barrier/` corpus.
