# p3t1-map-partial-failures

Timestamp: 2026-10-18T11-34
Command: python SCRATCH/issue-980-p3t1-failure-binding.py
EXIT_CODE: 0
Output Summary:   ],;   "basis": "Stable unchanged test sources; exact serial collection order; partial stopped run is not complete coverage.",;   "timestamp": "2026-10-18T11:34:39.771225+00:00"; }

Working directory: .
Started: 2026-10-18T11:34:39.732933+00:00
Duration seconds: 0.043
Phase: P3-T1 planned mutations and guarded commits; focused task verification.

## Captured output

```text
{
  "captured_progress": ".............................F.F..F...........",
  "partial_pass_count": 43,
  "partial_failure_count": 3,
  "completed_suite": false,
  "failed_ids": [
    "tests/discovery_runtime/test_mutation_plan.py::test_opaque_grants_cannot_create_structured_records[evidence-payload]",
    "tests/discovery_runtime/test_mutation_plan.py::test_report_view_requires_exact_structured_peer[False]",
    "tests/discovery_runtime/test_mutation_plan.py::test_projection_replays_only_captured_git_objects[True]"
  ],
  "basis": "Stable unchanged test sources; exact serial collection order; partial stopped run is not complete coverage.",
  "timestamp": "2026-10-18T11:34:39.771225+00:00"
}
```
