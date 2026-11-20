# p3t2-pass10-coverage-audit-corrected

Timestamp: 2026-10-18T13-44
Command: poetry run python SCRATCH/issue-980-p3t2-audit.py 10
EXIT_CODE: 1
Output Summary:     "Callable/class below 90%: packages/discovery-runtime/src/drm_copilot_discovery/init_flow.py:232 commit_initialization 87.18%",;     "Callable/class below 90%: packages/discovery-runtime/src/drm_copilot_discovery/init_io.py:109 capture 88.89%";   ]; }

Working directory: .
Started: 2026-10-18T13:44:34.811577+00:00
Duration seconds: 1.533
Phase: P3-T2 safe draft initialization; focused task verification.

## Captured output

```text
warning: in the working copy of 'tests/discovery_runtime/test_initialization.py', CRLF will be replaced by LF the next time Git touches it
{
  "audit": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t2-coverage-audit-prestage.2026-10-18T13-44.json",
  "raw": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t2-raw-coverage-prestage.2026-10-18T13-44.json",
  "coverage": {
    "packages/discovery-runtime/src/drm_copilot_discovery/init_flow.py": {
      "covered_lines": 129,
      "lines": 136,
      "covered_branches": 31,
      "branches": 36,
      "line_percent": 94.8529411764706,
      "branch_percent": 86.11111111111111,
      "baseline_percent": null,
      "classification": "new authoritative module"
    },
    "packages/discovery-runtime/src/drm_copilot_discovery/init_io.py": {
      "covered_lines": 136,
      "lines": 140,
      "covered_branches": 46,
      "branches": 50,
      "line_percent": 97.14285714285714,
      "branch_percent": 92.0,
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
  "minimum_callable": 87.17948717948718,
  "findings": [
    "Missing intent docstring: tests/scripts/dev_tools/discovery/test_init_cli.py:40",
    "Missing intent docstring: tests/scripts/dev_tools/discovery/test_init_cli.py:72",
    "Missing intent docstring: tests/scripts/dev_tools/discovery/test_init_cli.py:106",
    "Missing intent docstring: tests/scripts/dev_tools/discovery/test_init_models.py:22",
    "Missing intent docstring: tests/scripts/dev_tools/discovery/test_init_models.py:26",
    "Missing intent docstring: tests/scripts/dev_tools/discovery/test_init_models.py:30",
    "Missing intent docstring: tests/scripts/dev_tools/discovery/test_init_models.py:34",
    "Missing intent docstring: tests/scripts/dev_tools/discovery/test_init_models.py:37",
    "Missing intent docstring: tests/scripts/dev_tools/discovery/test_init_models.py:41",
    "Suppression requires recorded disposition: tests/scripts/dev_tools/discovery/test_init_models.py",
    "Callable/class below 90%: packages/discovery-runtime/src/drm_copilot_discovery/init_flow.py:232 commit_initialization 87.18%",
    "Callable/class below 90%: packages/discovery-runtime/src/drm_copilot_discovery/init_io.py:109 capture 88.89%"
  ]
}
```
