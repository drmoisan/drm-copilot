# Authority Derivation (P1-T2)

Timestamp: 2026-10-01T23:21:00-04:00
Command: python -m scripts.dev_tools.parallel_lane_assertion --manifest tests/fixtures/parallel_lane_assertion/manifests/two-items-no-assertion.md --edges $'999:998\n101:202'
EXIT_CODE: 0 (re-run with stdout redirected to /dev/null returned with no tool error)
Output Summary: the first stdout line is `Lane assertion: 1 derived conflict component(s); 0 disagreement(s).`

Exact stdout:
```
Lane assertion: 1 derived conflict component(s); 0 disagreement(s).
ADVISORY [item_covered_by_no_component] manifest item 101 is covered by no expected component.
ADVISORY [item_covered_by_no_component] manifest item 202 is covered by no expected component.
Advisory only: this diagnostic never blocks, never modifies a derived edge, never feeds compute_cohorts, and never influences scheduling.
```

This stdout is the only source of the `expected_stdout` field in the fixture `edges_newline_separated.json` (P1-T3).
