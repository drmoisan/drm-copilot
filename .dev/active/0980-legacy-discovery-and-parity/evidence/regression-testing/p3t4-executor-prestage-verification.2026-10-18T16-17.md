# P3-T4 independent prestage source and coverage check

Timestamp: 2026-10-18T16-17
Command: poetry run python SCRATCH/issue-980-p3t4-final-check.py prestage
EXIT_CODE: 0
Output Summary: 331 checks passed, zero findings; exact five-source scope, 246 accepted prior paths and 24 frozen paths preserved. Recomputed coverage is 169/170 lines and 51/52 arcs; all 18 AST ranges meet 94.117647%, maximum 431 physical lines. This is not final task acceptance.

Exact results: [prestage checks](p3t4-executor-prestage-checks.2026-10-18T16-17.json).

The checker independently measures every class/function range from raw coverage and current AST positions, verifies all source hashes against the completed forward run, and binds the retained 29 behavioral assertions. It checks the original accepted baseline `c114f98583599ebd5ee02281ece3524b2909fa51`, including the WIP changes, rather than comparing only the latest commit.

Final staged index, complete gate sequence and composed integration evidence remain pending. After this check, the coordinator reported that stage 7's SCRATCH harness failed before calling a draft API because its memory provider used a captured POSIX root instead of the required absolute provider root. The canonical seven-stage loop must restart after that harness correction. These source/coverage checks and the unchanged-source behavioral proofs remain valid historical measurements; they do not replace the required new complete ordered pass.

## Captured output

```text
{
  "timestamp": "2026-10-18T16:17:18.092935+00:00",
  "task": "P3-T4",
  "phase": "prestage",
  "baseline": "c114f98583599ebd5ee02281ece3524b2909fa51",
  "head": "d9791ad7baaed3e6990bc6dc6c06b8feb204482c",
  "checks_passed": 331,
  "findings": [],
  "unchanged_prior": 246,
  "frozen_paths": 24,
  "coverage_raw_sha256": "5877a9ea73774dcb972baad242556eb58ae434b23d066d01b2addb06dbb63748",
  "coverage_audit": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t4-pass1-coverage-audit.2026-10-18T16-10.json",
  "coverage": {
    "covered_lines": 169,
    "lines": 170,
    "covered_branches": 51,
    "branches": 52,
    "ranges": 18,
    "minimum_range_percent": 94.11764705882354
  },
  "max_physical_lines": 431,
  "physical_lines": {
    "packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": 396,
    "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": 231,
    "tests/discovery_runtime/draft_test_support.py": 126,
    "tests/discovery_runtime/test_draft_contracts.py": 431,
    "tests/discovery_runtime/test_draft_scenarios.py": 378
  }
}
```
