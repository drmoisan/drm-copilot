# Python-Lane Reproduction (P1-T6)

Timestamp: 2026-10-01T23:25:00-04:00
Command: python -m scripts.dev_tools.parallel_lane_assertion --manifest tests/fixtures/parallel_manifest_payload/parallel.md --edges $'999:998\n101:202'
EXIT_CODE: 0
Output Summary: the first stdout line is `Lane assertion: 1 derived conflict component(s); 0 disagreement(s).`

Exact stdout:
```
Lane assertion: 1 derived conflict component(s); 0 disagreement(s).
ADVISORY [item_covered_by_no_component] manifest item 101 is covered by no expected component.
ADVISORY [item_covered_by_no_component] manifest item 202 is covered by no expected component.
Advisory only: this diagnostic never blocks, never modifies a derived edge, never feeds compute_cohorts, and never influences scheduling.
```

The plan expects the bash lane before the fix to print `2 derived` (P1-T5); that bash-side line is not observed locally (deviation D5), so the pinned divergence rests on the unmodified-library behavior described in the issue and the plan, with CI as the authority.
