# p3t3-native3-coverage-check

Timestamp: 2026-10-18T15-02
Command: python SCRATCH/issue-980-p3t3-coverage-check.py native3
EXIT_CODE: 0
Output Summary:   },;   "minimum_callable": 95.23809523809524,;   "findings": []; }

Working directory: .
Started: 2026-10-18T15:02:36.927581+00:00
Duration seconds: 0.062
Phase: P3-T3 configuration and activation; focused task verification.

## Captured output

```text
{
  "audit": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t3-native3-coverage-audit.2026-10-18T15-02.json",
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
      "covered_lines": 159,
      "lines": 162,
      "line_percent": 98.14814814814815,
      "covered_branches": 55,
      "branches": 58,
      "branch_percent": 94.82758620689656
    },
    "packages/discovery-runtime/src/drm_copilot_discovery/configuration.py": {
      "covered_lines": 123,
      "lines": 123,
      "line_percent": 100.0,
      "covered_branches": 31,
      "branches": 48,
      "branch_percent": 64.58333333333333
    }
  },
  "minimum_callable": 95.23809523809524,
  "findings": []
}
```
