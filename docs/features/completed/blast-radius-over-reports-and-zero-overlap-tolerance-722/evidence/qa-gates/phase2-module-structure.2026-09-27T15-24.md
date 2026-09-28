# Phase 2 Module Structure Checks (P2-T2, P2-T3, P2-T5, P2-T6)

Timestamp: 2026-09-27T15-24
Command: sh SCRATCH/run-ps.sh SCRATCH/line-counts.ps1 scripts/dev_tools/parallel_drift_detection.py scripts/dev_tools/_parallel_drift_scheduling.py tests/scripts/dev_tools/test_parallel_drift_scheduling.py tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py
EXIT_CODE: 0
Output Summary: All four Phase 2 Python files are at most 500 lines. The drift-detection module measures 460 lines against its P0-T13 baseline of 499 (FEATURE/evidence/baseline/line-counts.2026-09-27T14-40.md), so it did not grow (39 lines fewer).

## Printed output

```text
scripts/dev_tools/parallel_drift_detection.py LineCount=460
scripts/dev_tools/_parallel_drift_scheduling.py LineCount=143
tests/scripts/dev_tools/test_parallel_drift_scheduling.py LineCount=255
tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py LineCount=95
```

## Drift-module change summary (git diff against BASE_SHA beae3f021674e64fa6662097fe48a332d8da62b8)

- Deleted the two private helpers _existing_edge_pairs and _observed_contends (relocated as
  existing_edge_pairs and observed_pair_is_edge in scripts/dev_tools/_parallel_drift_scheduling.py;
  the edge-pair collector body is unchanged).
- Removed the now-unused imports of as_item_key and BlastRadius; kept the import of conflicts from
  compute_blast_radius.
- Inside recompute_conflicts_with_observed: reads the drifting item's band with item_band(items,
  drifting) and each peer's band with item_band(items, item_key), and calls observed_pair_is_edge
  with relation=conflicts. The module-level name conflicts is read inside the function body at call
  time (it is not bound as a default argument of any drift-module function), so the existing
  monkeypatch of the drift module's conflicts attribute still governs the decision.
- The public signature of recompute_conflicts_with_observed is unchanged; its docstring now states
  that peers are evaluated through the scheduling rule with complexity bands.

## Helper contract (block B15)

- existing_edge_pairs: relocated unchanged.
- observed_pair_is_edge: returns True when the peer radius is not a mapping or cannot be rebuilt
  (the relation is not called); otherwise returns decide_pair(observed, peer, config, band_a=
  observed_band, band_b=peer_band, relation=relation).edge, with the observed radius passed first.
- item_band: returns the item's complexity_band when it is one of C1 through C4, otherwise None, so
  default_band applies.

SCRATCH denotes the executor session scratchpad directory (outside the repository).
FEATURE denotes docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722.
