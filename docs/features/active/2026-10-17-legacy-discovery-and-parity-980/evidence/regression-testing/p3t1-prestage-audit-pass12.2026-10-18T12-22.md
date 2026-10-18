# p3t1-prestage-audit-pass12

Timestamp: 2026-10-18T12-22
Command: poetry run python SCRATCH/issue-980-p3t1-task-audit.py 12 --prestage
EXIT_CODE: 1
Output Summary:   "findings": [;     "New callable/class coverage below 90%: packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py:105 (inspect, 87.50%)";   ]; }

Working directory: .
Started: 2026-10-18T12:22:28.809747+00:00
Duration seconds: 1.230
Phase: P3-T1 planned mutations and guarded commits; focused task verification.

## Captured output

```text
warning: in the working copy of 'packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py', CRLF will be replaced by LF the next time Git touches it
warning: in the working copy of 'tests/discovery_runtime/test_mutation_filesystem.py', CRLF will be replaced by LF the next time Git touches it
{
  "metrics": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t1-coverage-metrics-prestage.2026-10-18T12-22.json",
  "raw": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t1-coverage-prestage.2026-10-18T12-22.json",
  "owned": 7,
  "prior": 211,
  "authorized_dependency_paths": 2,
  "frozen": 24,
  "focused": 89,
  "reversed": 89,
  "coverage": {
    "packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py": {
      "covered_lines": 207,
      "statements": 209,
      "covered_branches": 51,
      "branches": 54,
      "line_percent": 99.04306220095694,
      "branch_percent": 94.44444444444444,
      "baseline_statements": 0,
      "classification": "new production module"
    },
    "packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py": {
      "covered_lines": 130,
      "statements": 131,
      "covered_branches": 31,
      "branches": 32,
      "line_percent": 99.23664122137404,
      "branch_percent": 96.875,
      "baseline_statements": 0,
      "classification": "new production module"
    },
    "packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py": {
      "covered_lines": 146,
      "statements": 149,
      "covered_branches": 52,
      "branches": 56,
      "line_percent": 97.98657718120805,
      "branch_percent": 92.85714285714286,
      "baseline_statements": 0,
      "classification": "new production module"
    }
  },
  "minimum_unit_percent": 87.5,
  "findings": [
    "New callable/class coverage below 90%: packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py:105 (inspect, 87.50%)"
  ]
}
```
