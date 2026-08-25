# Baseline — Pytest with Repository-Wide Coverage

- **Task:** [P0-T10]
- **Issue:** #505

Timestamp: 2026-08-25T09-17

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`

EXIT_CODE: 1

## Test Counts

| Outcome | Count |
| --- | --- |
| passed | 4116 |
| failed | 1 |
| skipped | 5 |

Terminal summary line: `1 failed, 4116 passed, 5 skipped in 27.19s`

## Coverage (read from `artifacts/python/coverage.json`, key `totals`)

| Metric | JSON key | Baseline value (percent) |
| --- | --- | --- |
| Repository line coverage | `totals.percent_statements_covered` | **92.6086956521739** |
| Repository branch coverage | `totals.percent_branches_covered` | **85.19664967225054** |

Supporting raw counters from the same `totals` object: `num_statements` 14950, `missing_lines`
1105, `num_branches` 5492, `num_partial_branches` 559.

The terminal `TOTAL` row's `Cover` column reads `91%`. That figure is **not** recorded as either
coverage percentage. It is the rounded value of `totals.percent_covered` (90.61735642305058), which
is the combined statements-plus-branches ratio, and the plan's Toolchain section explicitly forbids
deriving either headline figure from it. Both figures above come from the two named JSON keys.

Both baseline figures clear the uniform thresholds in `.claude/rules/quality-tiers.md`: line
coverage 92.61 >= 85, branch coverage 85.20 >= 75.

## Pre-Existing Failure (present at baseline, unrelated to this change)

One test fails on the unmodified tree at commit `d5e3a462f51c1dd1612b4f2009aaea4552a35ec7`:

```
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
E   AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:120: AssertionError
```

The failure asserts that a repository runtime-contract file
(`.claude/state/python-batch-budget.default.json`) is absent from the bundled push-down payload
under `extensions/drm-copilot/resources/`. It is a push-down payload-parity defect. It touches no
file in this change's write set, no file in its read-only set, and no `fix_all` module. It is
recorded here as the baseline state so the Phase 6 final QC comparison is made against a known
starting point rather than against an assumed-green tree.

**Consequence for Phase 6, recorded now and not actioned here:** [P6-T4] requires `EXIT_CODE: 0` and
zero failures from the same command. That acceptance condition cannot be met while this pre-existing
failure persists, and the failure is outside this fix's scope. The condition is flagged for the
Phase 6 executor rather than resolved in Phase 0. Phases 0 through 3 are the scope of this
execution; no attempt is made here to repair the push-down payload.

Output Summary: Baseline pytest run over the full suite: **4116 passed, 1 failed, 5 skipped**, exit
code 1. Repository-wide **line coverage 92.6086956521739 percent**
(`totals.percent_statements_covered`) and **branch coverage 85.19664967225054 percent**
(`totals.percent_branches_covered`), both read from `artifacts/python/coverage.json` and both above
the 85 and 75 thresholds. The single failure,
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, is pre-existing on the unmodified
tree, is a push-down bundled-payload parity defect concerning
`.claude/state/python-batch-budget.default.json`, and is unrelated to the `fix_all` cancel-race fix.
The five skips are pre-existing parametrized parity cases in
`test_parallel_manifest_bash_parity.py` that declare no accessor expectation.
