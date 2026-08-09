# Phase 3 — Layer 2 Seam Test File — Issue #440 (F7)

Timestamp: 2026-08-08T22-11

Task: [P3-T2]

Created file: `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py` (496 lines, under the 500-line limit)

Command: `poetry run pytest tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py -q`

EXIT_CODE: 0

## Result

```
31 passed in 0.08s
```

## Mandatory Seam Property (verified, not asserted by convention)

Every case reaches the invariant only through the public entry point
`validate_parallel_orchestrator_state_text`. The file's sole production import is:

```python
from scripts.dev_tools.validate_parallel_orchestrator_state import (
    validate_parallel_orchestrator_state_text,
)
```

It does **not** import
`scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py`, and it does
not import the module's `VIOLATION_PREFIX` constant either — the expected message
is restated as a literal in the test file so byte-exactness is asserted against
the specification text rather than against the implementation's own constant.

Consequence: a passing run cannot be produced by a correct-but-unbound helper.
This is the property the delegation required, because two earlier features in this
epic shipped a producer and a consumer that each reported 100% coverage while
being unbound.

Verification 1 — the test file contains no reference to the helper module.

Command: `grep -c "_parallel_orchestrator_state_cohort_barrier" tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py`

EXIT_CODE: 1 (grep exit 1 = zero matches; printed count `0`)

The file's complete import list is `from __future__ import annotations`,
`import copy`, `import json`, `from typing import cast`, `import pytest`, and
`from scripts.dev_tools.validate_parallel_orchestrator_state import ...`.

Verification 2 — the entry point actually calls the helper at run time. The helper
name was rebound to a stub inside the validator module's namespace and the same
fixture revalidated through the entry point; the stub's output appeared, proving
the call site is live rather than dead code.

Command: `poetry run python -c "import json; import scripts.dev_tools.validate_parallel_orchestrator_state as v; import tests.scripts.dev_tools.test_validate_parallel_orchestrator_state_cohort_barrier as t; s=t.build_same_cohort_state(); print('SEAM_LIVE   ', v.validate_parallel_orchestrator_state_text(json.dumps(s))); v.validate_cohort_barrier_ordering = lambda state: ['STUB_CALLED']; print('SEAM_STUBBED', v.validate_parallel_orchestrator_state_text(json.dumps(s)))"`

EXIT_CODE: 0

```
SEAM_LIVE    ['PARALLEL_COHORT_BARRIER_VIOLATION: 444 ran concurrently with conflicting 445']
SEAM_STUBBED ['STUB_CALLED']
```

No file was modified to obtain this proof; the rebinding was in-process only.

## Determinism and Isolation

- Fixtures are dicts built in memory and serialized with `json.dumps`; the JSON
  document handed to the entry point is constructed inline in every case.
- No temporary file, no filesystem read, no network call, no subprocess, no clock
  read, no randomness, no mutable module-level state. Timestamp values are fixed
  literals (`2026-08-08T10-00`, `2026-08-08T12-00`).
- Order-independent: each case builds its own checkpoint from a builder function
  and mutates only its own copy.

## Test Inventory (31 cases from 24 test functions)

| # | Test function | Params | Behavior covered |
| --- | --- | --- | --- |
| 1 | `test_clean_multi_cohort_checkpoint_yields_no_barrier_errors` | 1 | clean cross-cohort pair, merged in order |
| 2 | `test_checkpoint_without_a_gating_key_emits_no_violation` | 3 | key gate: drop `conflict_edges`, drop `cohorts`, drop both |
| 3 | `test_same_cohort_conflicting_pair_reports_one_structural_violation` | 1 | structural reading, exactly one message |
| 4 | `test_violation_message_matches_the_exact_literal_form` | 1 | byte-exact literal, no interpolation |
| 5 | `test_cross_cohort_start_before_terminal_merge_reports_a_violation` | 1 | status-based temporal reading |
| 6 | `test_ci_green_earlier_item_does_not_satisfy_the_barrier` | 1 | `ci_green` does not release the barrier |
| 7 | `test_start_timestamp_alone_evidences_a_start` | 1 | start-timestamp disjunct of "has started" |
| 8 | `test_merge_confirmed_after_later_start_reports_a_temporal_violation` | 1 | timestamp-ordering violation, both present |
| 9 | `test_merge_confirmed_before_later_start_is_clean` | 1 | correct timestamp ordering is clean |
| 10 | `test_absent_timestamps_degrade_to_structural_plus_status` | 3 | neither, only `merged_at`, only `worktree_created_at` |
| 11 | `test_non_string_timestamps_degrade_to_structural_plus_status` | 1 | integer and null timestamps are not coerced |
| 12 | `test_multiple_violated_edges_each_report_exactly_one_message` | 1 | three edges, three messages, correct order |
| 13 | `test_earlier_cohort_endpoint_is_named_first` | 1 | earlier endpoint named first even when it is the edge's `b` |
| 14 | `test_superseded_generation_cohorts_are_ignored` | 1 | current-generation projection |
| 15 | `test_feature_folder_hint_cohort_membership_resolves` | 1 | union-index hint tolerance, prefixed and bare |
| 16 | `test_unresolved_edge_endpoint_reports_no_barrier_violation` | 1 | unresolvable endpoint is not judged |
| 17 | `test_self_edge_reports_no_barrier_violation` | 1 | self-edge is invariant 15's defect |
| 18 | `test_malformed_conflict_edges_report_no_barrier_violation` | 3 | non-list, string entry, null entry |
| 19 | `test_malformed_cohorts_report_no_barrier_violation` | 3 | non-list, string entry, row without `item_keys` |
| 20 | `test_malformed_recolor_generation_reports_no_barrier_violation` | 1 | non-integer generation counter |
| 21 | `test_malformed_items_report_no_barrier_violation` | 1 | non-list `items` |
| 22 | `test_item_outside_the_current_coloring_is_left_unjudged` | 1 | endpoint in no current-generation cohort |
| 23 | `test_validation_does_not_mutate_the_checkpoint` | 1 | purity, via `copy.deepcopy` comparison |

The cases that deliberately malform a collection assert through the
`barrier_errors` filter, which selects only messages beginning with the invariant
label. The filter isolates the barrier contribution from the F3 shape errors that
the same malformation legitimately raises; it never suppresses a barrier message.
All other cases assert against the **entire** error list with `== [...]`, so an
unexpected extra error would fail them.

Output Summary: PASS. EXIT_CODE 0, `31 passed`, from 24 test functions in a
496-line file (under the 500-line cap). Every case exercises the invariant through
`validate_parallel_orchestrator_state_text` and the file contains zero references
to the helper module (grep count 0), which is the mandatory seam property. The
binding was additionally proven at run time by rebinding the helper name to a stub
inside the validator's namespace and observing the stub's output emerge from the
entry point. All eight plan-enumerated
cases are present, including the key-gated backward-compatibility case (three
parametrizations) and the exact-literal message assertion written with no
interpolation. No temp files, no filesystem reads, no network, no clock, no
randomness.
