# p3t6-gap-closure

Timestamp: 2026-10-18T18-23
Command: poetry run python SCRATCH/issue-980-p3t6-coverage-preparation.py
EXIT_CODE: 0
Output Summary:     };   },;   "status": "Five focused assertions pass; final combined current-source coverage still pending"; }

Working directory: .
Started: 2026-10-18T18:23:13.062217+00:00
Duration seconds: 0.867
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
{
  "evidence": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t6-gap-closure.2026-10-18T18-23.json",
  "timestamp": "2026-10-18T18:23:13.878710+00:00",
  "raw": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t6-gap-coverage.2026-10-18T18-23.json",
  "narrowed_units": [
    {
      "name": "prepare_snapshot_export",
      "start": 191,
      "end": 272,
      "covered": 18,
      "statements": 19,
      "percent": 94.73684210526316,
      "missing": [
        220
      ]
    },
    {
      "name": "prepare_snapshot_import",
      "start": 296,
      "end": 367,
      "covered": 26,
      "statements": 27,
      "percent": 96.29629629629629,
      "missing": [
        311
      ]
    }
  ],
  "accepted_raw_baselines": {
    "path_policy": {
      "raw": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p1t11-coverage.2026-10-18T07-30.json",
      "summary": {
        "covered_branches": 82,
        "covered_lines": 153,
        "excluded_lines": 3,
        "missing_branches": 0,
        "missing_lines": 0,
        "num_branches": 82,
        "num_partial_branches": 0,
        "num_statements": 153,
        "percent_branches_covered": 100.0,
        "percent_branches_covered_display": "100",
        "percent_covered": 100.0,
        "percent_covered_display": "100",
        "percent_statements_covered": 100.0,
        "percent_statements_covered_display": "100"
      }
    },
    "mutation_plan": {
      "raw": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t1-coverage.2026-10-18T12-38.json",
      "summary": {
        "covered_branches": 53,
        "covered_lines": 147,
        "excluded_lines": 7,
        "missing_branches": 3,
        "missing_lines": 2,
        "num_branches": 56,
        "num_partial_branches": 3,
        "num_statements": 149,
        "percent_branches_covered": 94.64285714285714,
        "percent_branches_covered_display": "95",
        "percent_covered": 97.5609756097561,
        "percent_covered_display": "98",
        "percent_statements_covered": 98.65771812080537,
        "percent_statements_covered_display": "99"
      }
    },
    "mutation_io": {
      "raw": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t1-coverage.2026-10-18T12-38.json",
      "summary": {
        "covered_branches": 31,
        "covered_lines": 130,
        "excluded_lines": 22,
        "missing_branches": 1,
        "missing_lines": 1,
        "num_branches": 32,
        "num_partial_branches": 1,
        "num_statements": 131,
        "percent_branches_covered": 96.875,
        "percent_branches_covered_display": "97",
        "percent_covered": 98.77300613496932,
        "percent_covered_display": "99",
        "percent_statements_covered": 99.23664122137404,
        "percent_statements_covered_display": "99"
      }
    },
    "references": {
      "raw": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t2-coverage.2026-10-18T08-15.json",
      "summary": {
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
      }
    }
  },
  "status": "Five focused assertions pass; final combined current-source coverage still pending"
}
```
