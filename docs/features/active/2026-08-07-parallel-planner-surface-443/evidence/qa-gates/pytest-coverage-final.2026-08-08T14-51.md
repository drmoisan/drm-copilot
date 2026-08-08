# Final QA Gate — Python Tests and Coverage ([P10-T4])

Timestamp: 2026-08-08T14-51

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Output Summary: 2959 passed, 0 failed, 0 errored, 0 skipped, in 12.00s. Repository-wide
post-change coverage: **line 91.82%** (12432 / 13539) and **branch 83.80%** (4190 / 5000). Both
Phase 2 production modules measure 100% line and 100% branch. No file was modified by this stage,
so no loop restart was triggered.

```
Name                                                                Stmts   Miss Branch BrPart  Cover
------------------------------------------------------------------------------------------------------
TOTAL                                                              13539   1107   5000    556    90%
Coverage LCOV written to file artifacts/python/lcov.info
============================ 2959 passed in 12.00s ============================
```

## Numeric post-change coverage headline values

| Metric | Covered | Total | Percent | Threshold | Result |
| --- | --- | --- | --- | --- | --- |
| Total line coverage | 12432 | 13539 | **91.82%** | >= 85% | PASS |
| Total branch coverage | 4190 | 5000 | **83.80%** | >= 75% | PASS |
| Combined (coverage.py `TOTAL` row) | — | — | 90% | — | — |

### Derivation of the separate line and branch percentages

The coverage.py terminal `TOTAL` row prints a single combined percentage when `--cov-branch` is
active, which is neither the line percentage nor the branch percentage. The separate values were
derived from the LCOV report emitted by the same run, using the identical method recorded in the
Phase 0 baseline artifact.

Command: `awk -F: '/^LF:/{lf+=$2} /^LH:/{lh+=$2} /^BRF:/{brf+=$2} /^BRH:/{brh+=$2} END{printf "LF=%d LH=%d line_pct=%.2f\nBRF=%d BRH=%d branch_pct=%.2f\n", lf, lh, (lh/lf)*100, brf, brh, (brh/brf)*100}' artifacts/python/lcov.info`

EXIT_CODE: 0

Output Summary:

```
LF=13539 LH=12432 line_pct=91.82
BRF=5000 BRH=4190 branch_pct=83.80
```

`LF` = 13539 agrees exactly with the coverage.py `Stmts` total, and `BRF` = 5000 agrees exactly
with the `Branch` total, confirming both reports describe the same measurement. No placeholder
value is recorded.

## Per-file coverage for the production modules changed by this feature

| Production module | Lines covered / found | Line % | Branches covered / found | Branch % | Result |
| --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/parallel_kickoff_contract.py` | 91 / 91 | **100.00%** | 26 / 26 | **100.00%** | PASS |
| `scripts/dev_tools/_parallel_kickoff_tables.py` (helper module created by [P2-T6]) | 72 / 72 | **100.00%** | 38 / 38 | **100.00%** | PASS |
| `scripts/dev_tools/validate_orchestration_artifacts.py` (five-surface wiring, Phase 3) | 119 / 127 | **93.70%** | 44 / 52 | **84.62%** | PASS |

Term-missing rows for the same three modules:

```
scripts\dev_tools\_parallel_kickoff_tables.py                         72      0     38      0   100%
scripts\dev_tools\parallel_kickoff_contract.py                        91      0     26      0   100%
scripts\dev_tools\validate_orchestration_artifacts.py                127      8     52      8    91%   66, 113->98, 117-121, 132, 147, 314, 316, 318, 341->345
```

### Changed-line coverage in `validate_orchestration_artifacts.py`

That module is pre-existing and its eight uncovered statements are pre-existing. The four lines
this feature adds are lines 17 (the import), 183 (the subparser tuple member), and 360-361 (the
dispatch branch). None of those line numbers appears in the missing-line list above, so the
changed lines in this file are 100% covered.

## Test counts

| Result | Count |
| --- | --- |
| Passed | 2959 |
| Failed | 0 |
| Errored | 0 |
| Skipped | 0 |
| Collected | 2959 |

Baseline comparison: 2886 passed at Phase 0; the +73 delta matches the test functions added by
Phases 2, 3, and 6.

## Pre-existing local test noise (recorded, out of scope, not remediated)

`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` and
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` are known to fail on a
developer machine whenever an orchestrated run is in progress, because they read the real
gitignored `artifacts/orchestration/orchestrator-state.json` rather than a mocked seam. They are
PowerShell/Pester tests; no Phase 10 task invokes Pester, and pytest does not collect `.Tests.ps1`
files. They were not executed by this run and are unaffected by it. They are out of scope and were
not edited.

## Result

PASS — full Python suite green (2959 passed, 0 failed, EXIT_CODE 0) with line coverage 91.82% and
branch coverage 83.80%, both above the uniform repository thresholds and both above the recorded
Phase 0 baseline of 91.72% line / 83.58% branch.
