# Phase 3 — Two-Statement Edit to the F3-Owned Validator — Issue #440 (F7)

Timestamp: 2026-08-08T22-11

Task: [P3-T3]

Target file: `scripts/dev_tools/validate_parallel_orchestrator_state.py` (was 336 lines, now **340** lines, under the 500-line limit)

Command: `git diff -- scripts/dev_tools/validate_parallel_orchestrator_state.py`

EXIT_CODE: 0

## Exact Diff

```diff
diff --git a/scripts/dev_tools/validate_parallel_orchestrator_state.py b/scripts/dev_tools/validate_parallel_orchestrator_state.py
index f444b7e0..3ac9ab8a 100644
--- a/scripts/dev_tools/validate_parallel_orchestrator_state.py
+++ b/scripts/dev_tools/validate_parallel_orchestrator_state.py
@@ -35,6 +35,9 @@ from __future__ import annotations
 import json
 from typing import cast

+from scripts.dev_tools._parallel_orchestrator_state_cohort_barrier import (
+    validate_cohort_barrier_ordering,
+)
 from scripts.dev_tools._parallel_state_common import (
     MERGED_MERGE_STATUSES,
     VALID_MODES,
@@ -329,6 +332,7 @@ def validate_parallel_orchestrator_state_text(
     # this block, plus the helper's import. Nothing else in this function moves,
     # so F7 and F3 cannot contend over the same lines (epic wave-4 rule).
     # Add F7 helper invocations below this line, one per line.
+    errors.extend(validate_cohort_barrier_ordering(state_map))
     # END F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION

     if require_complete:
```

## Acceptance Verification

Command: `git diff --numstat -- scripts/dev_tools/validate_parallel_orchestrator_state.py`

EXIT_CODE: 0

```
4	0	scripts/dev_tools/validate_parallel_orchestrator_state.py
```

- **4 insertions, 0 deletions.** No existing line was modified, reflowed,
  reordered, or removed. Every line in the diff other than the four `+` lines is a
  context line.
- **Two statements only**, exactly as P3-T3 specifies: the import and the
  `errors.extend(...)` call.
- **Import rendered as the predicted three-line parenthesized form.** The
  single-line form is 105 characters, above `black`'s configured `line-length = 88`,
  so `black` renders it parenthesized. Confirmed black-clean in P3-T4 without
  further reformatting.
- **Import placement.** Inserted in the existing alphabetically ordered
  `scripts.dev_tools.*` block, before `_parallel_state_common` because
  `_parallel_o` sorts before `_parallel_s`. Ruff's import-order rules pass (P3-T5).
- **Call placement.** Inside the delimited F7 extension seam, on the line
  immediately after `# Add F7 helper invocations below this line, one per line.`
  and immediately before `# END F7 EXTENSION SEAM`. Both delimiter comments are
  unchanged. All pre-existing `errors.extend(...)` helper calls remain outside the
  block, above it, untouched.
- **No F6 or F8 surface touched.** The diff contains no other hunk. No section or
  helper belonging to F6 (#445, mutation protocol) or F8 (#446, drift detection)
  appears in it.
- **No checkpoint schema field added.** The edit adds a call, not a field.

## Signature Discrepancy (recorded per the delegation's instruction)

The seam's interior comment reads:

```
# one appended `errors.extend(<helper>(state_map, CONTEXT))` call inside
```

which suggests a two-argument helper. The landed call is the one-argument form
`errors.extend(validate_cohort_barrier_ordering(state_map))`, per plan Binding
Constraint 2, P3-T3, and the P0-T11 advisory. The plan's form is correct on the
merits: the mandated message
`PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with conflicting <b>`
carries no `Parallel checkpoint` context prefix, so `CONTEXT` has no consumer in
the helper. The F3-owned comment was deliberately **not** edited, because the
wave-4 contention constraint forbids touching existing lines of this file.
Recommendation for integration: F3 corrects the comment text, or the epic records
the divergence; it is a documentation inaccuracy in F3's seam prose, not a defect
in F7's call.

## Contention Risk Assessment

The file is shared with F8 (#446), which is expected to extend it concurrently for
its drift gate. F7's footprint is four contiguous added lines in two locations that
F8 has no reason to touch: the import block (a distinct alphabetical slot) and the
interior of the F7-named seam. The 500-line cap is not approached (340 lines), and
all invariant logic lives in the new sibling module, so F8's own additions are not
crowded.

Output Summary: PASS. `git diff --numstat` reports `4 0` — four insertions, zero
deletions — for `scripts/dev_tools/validate_parallel_orchestrator_state.py`, which
grew from 336 to 340 lines. The diff contains exactly the two specified statements:
the helper import, rendered by black at `line-length = 88` as the predicted
three-line parenthesized form and placed in the alphabetically ordered
`scripts.dev_tools.*` block, and the single
`errors.extend(validate_cohort_barrier_ordering(state_map))` call placed inside the
delimited F7 extension seam. No existing line was reflowed, reordered, or modified;
both seam delimiter comments are intact; all pre-existing helper calls remain
outside the seam; and no F6 or F8 surface appears in the diff. The one-argument
call form was used per the plan over the seam comment's two-argument suggestion,
and that documented discrepancy in F3's comment prose is recorded above.
