# p3t3-pass2-coverage-check

Timestamp: 2026-10-18T15-16
Command: poetry run python SCRATCH/issue-980-p3t3-coverage-check.py pass2
EXIT_CODE: 0
Output Summary:   },;   "minimum_callable": 94.11764705882354,;   "findings": []; }

Working directory: .
Started: 2026-10-18T15:16:52.890249+00:00
Duration seconds: 0.863
Phase: P3-T3 configuration and activation; focused task verification.

## Captured output

```text
{
  "audit": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t3-pass2-coverage-audit.2026-10-18T15-16.json",
  "metrics": {
    "packages/discovery-runtime/src/drm_copilot_discovery/activation_filesystem.py": {
      "covered_lines": 102,
      "lines": 102,
      "line_percent": 100.0,
      "covered_branches": 30,
      "branches": 30,
      "branch_percent": 100.0
    },
    "packages/discovery-runtime/src/drm_copilot_discovery/activation_store.py": {
      "covered_lines": 162,
      "lines": 162,
      "line_percent": 100.0,
      "covered_branches": 58,
      "branches": 58,
      "branch_percent": 100.0
    },
    "packages/discovery-runtime/src/drm_copilot_discovery/configuration.py": {
      "covered_lines": 123,
      "lines": 123,
      "line_percent": 100.0,
      "covered_branches": 48,
      "branches": 48,
      "branch_percent": 100.0
    },
    "packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py": {
      "covered_lines": 207,
      "lines": 209,
      "line_percent": 99.04306220095694,
      "covered_branches": 51,
      "branches": 54,
      "branch_percent": 94.44444444444444
    }
  },
  "minimum_callable": 94.11764705882354,
  "findings": []
}
```
