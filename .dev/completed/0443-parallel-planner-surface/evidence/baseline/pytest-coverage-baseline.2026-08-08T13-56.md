# Pytest Test-and-Coverage Baseline — parallel-planner-surface (#443)

Timestamp: 2026-08-08T13-56

Task: [P0-T5]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aa53d4070e6155e59` (repository root of the feature worktree)
Branch: `feature/parallel-planner-surface-443`
Runtime: Python 3.13.12, pytest 9.0.2, pytest-cov 7.0.0, platform win32

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Output Summary:

```
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-aa53d4070e6155e59
configfile: pyproject.toml
testpaths: tests
collected 2886 items
...
Name                                                                Stmts   Miss Branch BrPart  Cover
--------------------------------------------------------------------------------------------------------------
TOTAL                                                              13373   1107   4934    556    90%
Coverage LCOV written to file artifacts/python/lcov.info
============================ 2886 passed in 12.20s ============================
PYTEST_EXIT_CODE=0
```

### Numeric coverage headline values (baseline)

| Metric | Covered | Total | Percent |
| --- | --- | --- | --- |
| **Total line coverage** | 12266 | 13373 | **91.72%** |
| **Total branch coverage** | 4124 | 4934 | **83.58%** |
| Combined (coverage.py `TOTAL` row) | — | — | 90% |

### Test counts

| Result | Count |
| --- | --- |
| Passed | 2886 |
| Failed | 0 |
| Errored | 0 |
| Skipped | 0 |
| **Collected** | **2886** |

- Wall time: 12.20s (a first confirming run of the identical command completed in 15.01s with identical counts and identical coverage totals, confirming determinism of the baseline).

### Threshold status at baseline

- Line coverage 91.72% >= 85% required (`.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`) — PASS.
- Branch coverage 83.58% >= 75% required — PASS.

## Derivation of the separate line and branch percentages

The coverage.py terminal `TOTAL` row prints a single combined percentage (`90%`) when `--cov-branch` is active; it is `(covered statements + covered branch exits) / (total statements + total branch exits)` and is therefore not the line percentage nor the branch percentage. The separate values above were derived from the LCOV report emitted by the same run.

Command: `awk -F: '/^LF:/{lf+=$2} /^LH:/{lh+=$2} /^BRF:/{brf+=$2} /^BRH:/{brh+=$2} END{printf "LF=%d LH=%d line_pct=%.2f\nBRF=%d BRH=%d branch_pct=%.2f\n", lf, lh, (lh/lf)*100, brf, brh, (brh/brf)*100}' artifacts/python/lcov.info`

EXIT_CODE: 0

Output Summary:

```
LF=13373 LH=12266 line_pct=91.72
BRF=4934 BRH=4124 branch_pct=83.58
```

- `LF` (lines found) = 13373 agrees exactly with the coverage.py `Stmts` total of 13373, confirming the LCOV report and the terminal report describe the same measurement.
- `BRF` (branches found) = 4934 agrees exactly with the coverage.py `Branch` total of 4934.
- No placeholder values are recorded; both headline percentages are real measured numbers.

## Targeted-module baseline percent — not applicable (spec R10)

Per spec R10 and the plan Scope Summary, the base scope of this feature introduces **no production Python module**. The Python deliverable is a single test file (`tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py`), which policy excludes from the coverage denominator (`.claude/rules/general-unit-test.md`, Coverage Requirements: "Configure coverage tooling to exclude test files (e.g., `tests/`) so metrics reflect application code, not tests").

Therefore **no targeted-module baseline percentage applies**. The coverage obligation for this plan is exactly two conditions, both measured against the repository-wide totals recorded above:

1. No regression of existing-suite coverage against this baseline (line 91.72%, branch 83.58%).
2. Repository thresholds maintained (line >= 85%, branch >= 75%).

This statement is recorded explicitly as required by [P0-T5].

## Pre-existing local test noise (recorded, out of scope, not remediated)

The following PowerShell/Pester tests are known to fail on a developer machine whenever an orchestrated run is in progress, because they read the real gitignored `artifacts/orchestration/orchestrator-state.json` rather than a mocked seam:

- `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`
- `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1`

Disposition:

- These are **pre-existing** failures unrelated to this feature; they fail identically at baseline.
- They are **out of scope** for this plan. Do not edit them under this plan.
- They are **PowerShell/Pester** tests and are outside this plan's toolchain scope in any case: the plan Scope Summary states "Python is the only language with baseline and final-QA toolchain obligations", and Phase 8's final QA loop is Python-only (`black`, `ruff`, `pyright`, `pytest`).
- Evidence-first note: the Pester suite was **not executed** as part of this baseline, because no plan task in Phase 0 or Phase 8 invokes it. The characterization above is recorded as a known pre-existing condition reported by the delegating orchestrator, not as an observation made by this run. The two file paths were verified to exist in this worktree via `Glob`.
- The Python baseline above is unaffected: pytest does not collect or execute `.Tests.ps1` files (`testpaths: tests`, pytest collection matches `test_*.py`), and the run recorded 0 failures across 2886 collected tests.

## Result

PASS — full Python suite green at baseline (2886 passed, 0 failed, EXIT_CODE 0) with line coverage 91.72% and branch coverage 83.58%, both above the uniform repository thresholds.
