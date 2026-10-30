# P3-T6 reference coverage reconciliation

Timestamp: 2026-10-18 18:48:42 UTC
Captured result: 2026-10-18T18:48:17.016936+00:00
Command: `poetry run python SCRATCH/issue-980-p3t6-reference-coverage.py`
EXIT_CODE: 0

Output Summary: Five independent reconciliation checks pass. The task coverage gate remains failed: current references.py is 168/171 lines and 81/84 arcs versus accepted 152/154 lines and 74/76 arcs. No mapped previously covered line is lost. The new missed statement is line 243 and its incoming branch 242 to 243, which adds an imported canonical representative to an existing proven alias group. Covering this statement and branch raises the rates to 169/171 (98.830409%) and 82/84 (97.619048%), above both accepted rates.

Required correction: Add isolated assertions that each manifest selects its own imported representative or alias, source-contract selection is deterministic, and an unmatched manifest cannot select another copy. Existing no-group/conflict/provenance controls and production bytes remain unchanged. A narrow diagnostic may confirm these assertions; final acceptance requires restarting the complete seven-stage task loop. The completed 430-test invocation remains historical passing behavior with a failed coverage gate.

Raw reconciliation: [p3t6-executor-reference-coverage.2026-10-18T18-48.json](p3t6-executor-reference-coverage.2026-10-18T18-48.json). This records the exact raw coverage SHA-256 and current source SHA-256; it does not claim a new behavior run or task acceptance.

```text
{
  "timestamp": "2026-10-18T18:48:17.016936+00:00",
  "task": "P3-T6 coverage reconciliation",
  "source": "packages/discovery-runtime/src/drm_copilot_discovery/references.py",
  "source_sha256": "9a9a53d31366abc67126422cee4e3f0a3a8cd3dc41b7384bf99c7f5ba95e187c",
  "baseline": "27753e5f8b9a6cd1d85b9d1d28d2999800af209a",
  "baseline_raw": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t2-coverage.2026-10-18T08-15.json",
  "current_raw": "SCRATCH/issue-980-p3t6-pass2-coverage.json",
  "current_raw_sha256": "b9c0cf0218f5a76160187ef593e280bb2579b488838f5fb23fbd3a2d079fe679",
  "previous": {
    "covered_branches": 74,
    "covered_lines": 152,
    "excluded_lines": 3,
    "missing_branches": 2,
    "missing_lines": 2,
    "num_branches": 76,
    "num_partial_branches": 2,
    "num_statements": 154,
    "percent_branches_covered": 97.36842105263158,
    "percent_branches_covered_display": "97",
    "percent_covered": 98.26086956521739,
    "percent_covered_display": "98",
    "percent_statements_covered": 98.7012987012987,
    "percent_statements_covered_display": "99"
  },
  "current": {
    "covered_lines": 168,
    "num_statements": 171,
    "percent_covered": 97.6470588235294,
    "percent_covered_display": "98",
    "missing_lines": 3,
    "excluded_lines": 3,
    "percent_statements_covered": 98.24561403508773,
    "percent_statements_covered_display": "98",
    "num_branches": 84,
    "num_partial_branches": 3,
    "covered_branches": 81,
    "missing_branches": 3,
    "percent_branches_covered": 96.42857142857143,
    "percent_branches_covered_display": "96"
  },
  "current_missing_lines": [
    200,
    243,
    335
  ],
  "current_missing_branches": [
    [
      199,
      200
    ],
    [
      242,
      243
    ],
    [
      334,
      335
    ]
  ],
  "mapped_previous_line_regressions": [],
  "missing_changed_lines": [
    243
  ],
  "minimum_required_covered_lines": 169,
  "minimum_required_covered_arcs": 82,
  "checks": {
    "original_accepted_line_and_branch_counts": true,
    "current_line_and_branch_counts": true,
    "no_old_mapped_covered_line_lost": true,
    "single_new_missing_statement_and_branch": true,
    "one_added_statement_and_arc_satisfy_original_rates": true
  },
  "passed": 5,
  "failed": 0,
  "disposition": "Add isolated physical-selection assertions for an imported canonical record with an actual proven alias group. Preserve prior tests and production. The 430 passing tests remain historical because this coverage gate failed; restart the full seven-stage task loop after the added tests pass their narrow diagnostic."
}
```
