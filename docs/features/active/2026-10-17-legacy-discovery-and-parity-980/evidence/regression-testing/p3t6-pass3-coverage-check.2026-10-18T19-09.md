# p3t6-pass3-coverage-check

Timestamp: 2026-10-18T19-09
Command: poetry run python SCRATCH\issue-980-p3t6-coverage-check.py pass3
EXIT_CODE: 0
Output Summary:   },;   "minimum_callable": 92.5,;   "findings": []; }

Working directory: .
Started: 2026-10-18T19:08:59.722212+00:00
Duration seconds: 1.015
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
{
  "audit": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t6-pass3-coverage-audit.2026-10-18T19-09.json",
  "metrics": {
    "packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py": {
      "covered_lines": 135,
      "lines": 136,
      "line_percent": 99.26470588235294,
      "covered_branches": 35,
      "branches": 36,
      "branch_percent": 97.22222222222223
    },
    "packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py": {
      "covered_lines": 161,
      "lines": 163,
      "line_percent": 98.77300613496932,
      "covered_branches": 63,
      "branches": 66,
      "branch_percent": 95.45454545454545
    },
    "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py": {
      "covered_lines": 156,
      "lines": 156,
      "line_percent": 100.0,
      "covered_branches": 84,
      "branches": 84,
      "branch_percent": 100.0
    },
    "packages/discovery-runtime/src/drm_copilot_discovery/references.py": {
      "covered_lines": 169,
      "lines": 171,
      "line_percent": 98.83040935672514,
      "covered_branches": 82,
      "branches": 84,
      "branch_percent": 97.61904761904762
    },
    "packages/discovery-runtime/src/drm_copilot_discovery/source_snapshots.py": {
      "covered_lines": 150,
      "lines": 152,
      "line_percent": 98.6842105263158,
      "covered_branches": 50,
      "branches": 52,
      "branch_percent": 96.15384615384616
    },
    "packages/discovery-runtime/src/drm_copilot_discovery/transport_manifest.py": {
      "covered_lines": 112,
      "lines": 115,
      "line_percent": 97.3913043478261,
      "covered_branches": 45,
      "branches": 48,
      "branch_percent": 93.75
    }
  },
  "minimum_callable": 92.5,
  "findings": []
}
```
