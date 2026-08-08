# Coverage Delta and Threshold Verification (P6-T5)

- **Issue:** #441
- **Feature:** 2026-08-07-parallel-orchestrator-surface-441
- **Task:** [P6-T5]
- **Branch:** `feature/parallel-orchestrator-surface-441`

Timestamp: 2026-08-08T17-58

Sources:

- Baseline: `evidence/baseline/baseline-pytest-coverage.2026-08-08T16-47.md` (P0-T5)
- Post-change: `evidence/qa-gates/final-qc-pytest-coverage.2026-08-08T17-57.md` (P6-T4)

Both figures come from the same command (`poetry run pytest --cov --cov-branch
--cov-report=term-missing`) run from the repository root under the same coverage configuration
(`[tool.coverage.run]` with `source = ["src", "scripts/dev_tools"]` and `omit` covering
`tests/*`), so the two runs are directly comparable.

## Comparison Table

| Metric | Baseline (P0-T5) | Post-change (P6-T4) | Delta | Threshold | Verdict |
| --- | --- | --- | --- | --- | --- |
| Line (statement) coverage | 91.82% (12432 / 13539) | 91.82% (12432 / 13539) | 0.00 pp | >= 85% | PASS |
| Branch coverage | 83.80% (4190 / 5000) | 83.82% (4191 / 5000) | +0.02 pp | >= 75% | PASS |
| Combined coverage.py headline | 89.66% (89.65963644209505) | 89.67% (89.66503047629323) | +0.0054 pp | n/a (informational) | PASS |
| Statements missing | 1107 | 1107 | 0 | n/a | no regression |
| Statements excluded | 387 | 387 | 0 | n/a | no regression |
| Branch destinations missing | 810 | 809 | -1 | n/a | improvement |
| Partial branches | 556 | 555 | -1 | n/a | improvement |
| Tests passed | 2968 | 3004 | +36 | n/a | improvement |
| Tests failed | 0 | 0 | 0 | must be 0 | PASS |

Precise underlying values (from `coverage json` `totals`, not hand-derived):

| Field | Baseline | Post-change |
| --- | --- | --- |
| `covered_lines` | 12432 | 12432 |
| `num_statements` | 13539 | 13539 |
| `missing_lines` | 1107 | 1107 |
| `excluded_lines` | 387 | 387 |
| `percent_statements_covered` | 91.82362065145136 | 91.82362065145136 |
| `num_branches` | 5000 | 5000 |
| `covered_branches` | 4190 | 4191 |
| `missing_branches` | 810 | 809 |
| `num_partial_branches` | 556 | 555 |
| `percent_branches_covered` | 83.8 | 83.82 |
| `percent_covered` | 89.65963644209505 | 89.66503047629323 |

## New / Changed-Code Coverage for This Feature's Diff

This feature's diff contains exactly three Python files, all of them in the test tree:

- `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`
- `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`
- `tests/scripts/dev_tools/parallel_orchestrator_surface_test_support.py`

All three lie outside the measured source set on two independent grounds in
`[tool.coverage.run]`: they are not under `source = ["src", "scripts/dev_tools"]`, and they are
additionally matched by the `omit` patterns `tests/*` and `*/tests/*`. They are therefore excluded
from the coverage denominator, which is required behaviour under
`.claude/rules/general-unit-test.md` ("Configure coverage tooling to exclude test files (e.g.,
`tests/`) so metrics reflect application code, not tests"). Their exclusion is not a
coverage-exclusion policy violation, because the prohibition in that rule applies to production
files, and none of the three is production code.

**No production Python file changed on this branch.** This is confirmed independently by P5-T2
(`evidence/other/no-hook-or-settings-change.2026-08-08T17-47.md`), whose full 24-path changed-path
enumeration contains no `.py` path outside `tests/scripts/dev_tools/`. Every other changed path is
Markdown (the four deliverable surface and template files plus the feature documents and evidence
artifacts) or JSON (`pack-manifests/core.json`).

Consequence: the set of changed executable lines that are inside the coverage denominator is
empty. Changed-line coverage regression is therefore structurally zero — there is no changed
production line whose coverage could have regressed. The identical baseline and post-change
statement figures (12432 / 13539, 1107 missing, 387 excluded) confirm this arithmetically: the
denominator, the numerator, and the missing count are all unchanged.

The branch metric moved by exactly one destination in the favourable direction (`covered_branches`
4190 to 4191; `missing_branches` 810 to 809; `num_partial_branches` 556 to 555) with the
denominator held at 5000. This is an improvement, not a regression. The most likely mechanism is
that the newly added `.claude` runtime files and the three new `pack-manifests/core.json` entries
changed the inputs traversed by existing production helpers under `scripts/dev_tools` when the
pre-existing bundle-parity suites run, so one previously-partial branch destination in that
traversal is now taken. That attribution is an inference from the unchanged denominator rather
than a directly measured per-branch attribution; the verified facts are the totals above.

## Threshold Verification

1. Post-change line coverage 91.82% >= 85% required. **PASS** (margin +6.82 pp.)
2. Post-change branch coverage 83.82% >= 75% required. **PASS** (margin +8.82 pp.)
3. No regression versus baseline: line coverage is exactly equal (91.82362065145136% both sides,
   identical covered/total/missing counts), and branch coverage increased by 0.02 pp. Neither
   metric decreased. **PASS**
4. All required numeric values are available; no placeholder or `UNVERIFIED` value appears in the
   baseline artifact, the post-change artifact, or this comparison. **PASS**
5. Test outcome: 3004 passed, 0 failed, exit code 0, with the test count reconciling exactly as
   2968 baseline + 36 added. No test was weakened, deleted, or skipped to make a gate pass.
   **PASS**

## Verdict

**PASS.**

All four thresholds hold, every required numeric value is present, and there is no coverage
regression on any measured metric. The QC loop (P6-T1 through P6-T4) completed in a single clean
pass: Black reformatted zero files, Ruff reported zero findings, Pyright reported zero errors and
zero warnings, and Pytest reported 3004 passed with zero failures. No loop step modified any file,
so no restart was required and no bundled-mirror re-sync (P3-T4) or bundle-parity re-verification
(P5-T7) had to be repeated.
