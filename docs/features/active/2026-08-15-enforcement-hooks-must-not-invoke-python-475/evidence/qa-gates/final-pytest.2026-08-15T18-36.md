# Final QA — Python Step 4, Tests with Coverage — [P15-T7]

Timestamp: 2026-08-15T18-36

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing` (run from the worktree root). Exact totals read from the coverage database via `poetry run coverage json`.

EXIT_CODE: 0

Output Summary: **3785 passed, 0 failed, 0 errors, 5 skipped** in 12.15 s. Full suite green in one pass; the loop does not restart from `[P15-T4]`. **Line (statement) coverage 92.30%** (13288/14396, floor 85% — met with 7.30 points headroom). **Branch coverage 84.66%** (4475/5286, floor 75% — met with 9.66 points headroom). `SKIPPED` was not used as a task outcome.

## Coverage Headline Values

The `term-missing` report's `TOTAL` row prints the **combined** line-plus-branch figure
(90%), which is not the line-coverage figure the policy floors are stated against. Exact
totals were therefore read from the coverage database.

| Metric | Covered | Total | Percent | Floor | Status |
| --- | --- | --- | --- | --- | --- |
| **Line (statement) coverage** | 13288 | 14396 | **92.30%** | >= 85% | MET |
| **Branch coverage** | 4475 | 5286 | **84.66%** | >= 75% | MET |
| Combined (as displayed by `term-missing` TOTAL) | — | — | 90.25% | — | — |

Supporting raw totals from the coverage JSON:

```
covered_lines: 13288, num_statements: 14396, missing_lines: 1108, excluded_lines: 418
percent_statements_covered: 92.30341761600445
num_branches: 5286, covered_branches: 4475, missing_branches: 811, num_partial_branches: 557
percent_branches_covered: 84.6575860764283
```

## Comparison Against the Phase 0 Baseline

| Metric | Baseline `[P0-T8]` | Final `[P15-T7]` | Delta |
| --- | --- | --- | --- |
| Passed | 3785 | 3785 | 0 |
| Failed | 0 | 0 | 0 |
| Skipped | 5 | 5 | 0 |
| Line coverage | 92.30% (13288/14396) | 92.30% (13288/14396) | 0.00 pts |
| Branch coverage | 84.68% (4476/5286) | 84.66% (4475/5286) | **−0.02 pts** |

The branch-coverage delta is one branch arc (4476 → 4475 covered; partial branches 556 → 557).
Both figures remain far above the 75% floor. Statement coverage, statement counts, and test
counts are identical. No Python production code was added or modified by this feature
(`scripts/dev_tools/*.py` is unmodified, verified in `[P15-T9]` clause (i)), so there is no
new/changed Python code whose coverage could regress; the arc difference is measurement
variation in already-covered code, not a coverage regression on changed lines.

## Known-Red Window — Now Closed

The `[P0-T8]` baseline recorded in advance that
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
would be expectedly red from `[P2-T2]` (first new `.claude/lib/**` module) until the bundle
mirror and manifest registration completed in Phase 12. `[P12-T10]` was the first planned
pytest run and it passed; this full-suite run confirms the window is closed with zero
failures.

## Skipped Tests

5 skipped, identical to the baseline: all five in
`tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231`, each with the reason
`manifest_m1_* declares no accessor expectation`. Pre-existing and unrelated to this feature.
No test was newly skipped.
