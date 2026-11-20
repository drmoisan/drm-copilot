# Baseline — Python tests with coverage

Timestamp: 2026-08-20T09-53

Task: [P0-T10]

Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
Command (separate line/branch derivation): the same run's LCOV report at `artifacts/python/lcov.info`, written by the `addopts` at `pyproject.toml:116`, summed as `LH/LF` for lines and `BRH/BRF` for branches (overall and per file) by a scratchpad-only text summarizer
EXIT_CODE: 0

## Test outcome

- Passed: 3938
- Failed: 0
- Skipped: 5 (all five in `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231`, each declaring no accessor expectation)

## Overall coverage, separated

Derived from `artifacts/python/lcov.info` (176 measured files):

- Overall LINE coverage: 92.43% (13527/14635)
- Overall BRANCH coverage: 84.90% (4561/5372)

Both are above the policy thresholds (line >= 85%, branch >= 75%).

## Per-file coverage of the two Python files this change touches

| File | Line | Branch |
| --- | --- | --- |
| `scripts/dev_tools/pr_context/verification_evidence.py` | 93.62% (44/47) | 81.25% (13/16) |
| `scripts/dev_tools/pr_context/collector.py` | 92.38% (206/223) | 84.88% (73/86) |

## `term-missing` rows for the same two files, recorded for reference

```
scripts\dev_tools\pr_context\collector.py             223  17  86  13  90%  143-144, 260, 285, 300, 301->296, 335-336, 362-365, 378, 379->373, 391, 437, 470, 531, 553
scripts\dev_tools\pr_context\verification_evidence.py  47   3  16   3  90%  78->77, 104, 107->102, 126-127
TOTAL                                               14635 1108 5372 557  90%
```

Note that the `term-missing` table's `Cover` column (90% for each of the two files and for the
TOTAL) is a COMBINED statement-plus-branch metric. It is neither the line percentage nor the branch
percentage, which is why the separate figures above are derived from the LCOV report instead.

The `Missing` column for `verification_evidence.py` at baseline is `78->77, 104, 107->102, 126-127`.
Lines 126-127 are the non-integer-`EXIT_CODE` `except ValueError` branch and line 104 is the
`continue` for a colon-free line — the untested regions research section 5.2 predicted. Phase 3's new
dedicated test module targets them, so the changed-line coverage requirement of AC21 is met by
covering both the new branches and these pre-existing gaps.

## Load-bearing flags

`pyproject.toml:116` `addopts` carries no `--cov`, so `--cov --cov-branch` are load-bearing: a
pytest run without them measures nothing. The same `addopts` DOES carry
`--cov-report=lcov:artifacts/python/lcov.info`, which is the report the separated line and branch
figures above are derived from.

Output Summary: 3938 passed, 0 failed, 5 skipped; exit code 0. Overall line coverage 92.43%
(13527/14635) and overall branch coverage 84.90% (4561/5372), both derived from the run's LCOV
report. Per-file baseline: `verification_evidence.py` line 93.62% (44/47) / branch 81.25% (13/16);
`collector.py` line 92.38% (206/223) / branch 84.88% (73/86). All six required numeric values are
present; no placeholder is used.
