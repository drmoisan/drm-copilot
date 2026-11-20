# p3t2-pass14-coverage-audit

Timestamp: 2026-10-18T14-03
Command: poetry run python SCRATCH/issue-980-p3t2-audit.py 14
EXIT_CODE: 1
Output Summary:   "findings": [;     "Suppression requires recorded disposition: tests/scripts/dev_tools/discovery/test_init_models.py";   ]; }

Working directory: .
Started: 2026-10-18T14:03:19.988562+00:00
Duration seconds: 1.842
Phase: P3-T2 safe draft initialization; focused task verification.

## Captured output

```text
warning: in the working copy of 'tests/discovery_runtime/initialization_test_support.py', CRLF will be replaced by LF the next time Git touches it
warning: in the working copy of 'tests/discovery_runtime/test_initialization.py', CRLF will be replaced by LF the next time Git touches it
warning: in the working copy of 'tests/scripts/dev_tools/discovery/test_domain_neutrality.py', CRLF will be replaced by LF the next time Git touches it
warning: in the working copy of 'tests/scripts/dev_tools/discovery/test_init_cli.py', CRLF will be replaced by LF the next time Git touches it
warning: in the working copy of 'tests/scripts/dev_tools/discovery/test_init_flow.py', CRLF will be replaced by LF the next time Git touches it
warning: in the working copy of 'tests/scripts/dev_tools/discovery/test_init_models.py', CRLF will be replaced by LF the next time Git touches it
{
  "audit": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t2-coverage-audit-prestage.2026-10-18T14-03.json",
  "raw": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t2-raw-coverage-prestage.2026-10-18T14-03.json",
  "coverage": {
    "packages/discovery-runtime/src/drm_copilot_discovery/init_flow.py": {
      "covered_lines": 134,
      "lines": 136,
      "covered_branches": 34,
      "branches": 36,
      "line_percent": 98.52941176470588,
      "branch_percent": 94.44444444444444,
      "baseline_percent": null,
      "classification": "new authoritative module"
    },
    "packages/discovery-runtime/src/drm_copilot_discovery/init_io.py": {
      "covered_lines": 137,
      "lines": 140,
      "covered_branches": 47,
      "branches": 50,
      "line_percent": 97.85714285714286,
      "branch_percent": 94.0,
      "baseline_percent": null,
      "classification": "new authoritative module"
    },
    "packages/discovery-runtime/src/drm_copilot_discovery/init_projection.py": {
      "covered_lines": 178,
      "lines": 178,
      "covered_branches": 60,
      "branches": 60,
      "line_percent": 100.0,
      "branch_percent": 100.0,
      "baseline_percent": null,
      "classification": "new authoritative module"
    },
    "scripts/dev_tools/discovery/init_flow.py": {
      "covered_lines": 2,
      "lines": 2,
      "covered_branches": 0,
      "branches": 0,
      "line_percent": 100.0,
      "branch_percent": 100,
      "baseline_percent": 100,
      "classification": "changed thin adapter"
    }
  },
  "minimum_callable": 94.44444444444444,
  "findings": [
    "Suppression requires recorded disposition: tests/scripts/dev_tools/discovery/test_init_models.py"
  ]
}
```
