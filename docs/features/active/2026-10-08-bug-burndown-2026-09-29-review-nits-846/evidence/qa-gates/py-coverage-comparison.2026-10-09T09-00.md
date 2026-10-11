# Final QC: Python coverage comparison ([P10-T10])

Timestamp: 2026-10-09T21-57
Loop-Iteration: 1
Command: git diff -U0 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a -- scripts/dev_tools/check_quality_tiers.py
EXIT_CODE: 0
Output Summary: AC-35 no-regression half PASS. Whole-repository line 93.68 -> 93.7 and branch 87.1 -> 87.97 (both non-decreasing; both above 85 / 75). Every changed production module is at or above 85 line and 75 branch. Changed executable lines of check_quality_tiers.py (lines 101-105) are absent from the [P10-T4] Missing column: 100% of changed executable lines covered. The diff is anchored to merge-base 311dea0548cb2e2fe57259aec6e1e3a06a9bdd2a, substituted for e7d3779b398604af919678c16c877c8539a86cc0 per the recorded-value substitution rule.

## Whole repository ([P0-T15] versus [P10-T8])

| Metric | Baseline | Post-change | Delta |
| --- | --- | --- | --- |
| Total line (COVTOTAL) | 93.68 | 93.7 | +0.02 |
| Total branch (COVTOTAL) | 87.1 | 87.97 | +0.87 |
| Tests | 6722 passed, 6 skipped | 6731 passed, 6 skipped | +9 passed |

## Per module

| Module | Source | Baseline line | Post line | Baseline branch | Post branch |
| --- | --- | --- | --- | --- | --- |
| scripts.dev_tools.check_quality_tiers | [P0-T11] / [P10-T4] | 100.0 | 100.0 | 91.67 | 92.86 |
| scripts.dev_tools.quality_tiers_contract | [P0-T11] / [P10-T4] | 98.43 | 100.0 | 96.15 | 100.0 |
| scripts.dev_tools.potential_to_issue | [P0-T13] / [P10-T5] | 99.26 | 99.26 | 97.37 | 97.37 |
| scripts.dev_tools.potential_to_issue_filesystem | [P0-T12] / [P10-T6] | 100.0 | 100.0 | 100.0 | 100.0 |

## New or changed-code coverage

- scripts/dev_tools/check_quality_tiers.py: the changed executable lines of the non-zero branch of `list_tracked_files` are line 101 (`detail = ...`), line 102 (`message = ...`), line 103 (`if detail:`), line 104 (`message = f"{message}: {detail}"`), and line 105 (`raise OSError(message)`). The [P10-T4] Missing column for this module contains only the partial arc `157->160`, which is in `main` and corresponds to the baseline arc `146->149` shifted by the 11 added lines. None of lines 101-105 is missing and the module has one partial branch only (the 157->160 arc), so both arcs of `if detail:` are covered. Changed executable lines covered: 5 of 5 (100%). The added `stderr` Protocol property (lines 59-62) is a declaration stub; the module reports 0 missed statements.
- scripts/dev_tools/potential_to_issue.py: the change is docstring and comments only (no changed executable line). The single missed statement moved from line 296 to line 298 and is the same statement (`_emit(f"Fallback reason: {fallback_reason}")`).
