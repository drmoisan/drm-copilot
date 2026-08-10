# Final QA — Python Tests and Coverage ([P7-T4])

Timestamp: 2026-08-09T03-37

Task: [P7-T4] Run Python tests in coverage mode and record numeric post-change coverage.

Feature: `docs/features/active/2026-08-07-parallel-mutation-protocol-442` (issue #442)
Branch: `feature/parallel-mutation-protocol-442`
Reconciliation base: `c939b5b8`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a3b16f891ab2f782c`

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

## Test Result Counts (numeric, no placeholders)

| Metric | Post-change value | Baseline (P0-T4) |
| --- | --- | --- |
| Passed | **3386** | 3007 |
| Failed | **0** | 0 |
| Errors | 0 | 0 |
| Skipped | 0 | 0 |
| Total collected | 3386 | 3007 |
| Wall time | 10.96 s | 15.30 s |

Terminal summary line: `============================ 3386 passed in 10.96s ============================`

Net new passing Python tests: **+379**. Zero failures, so no Python regression.

## Coverage — Numeric Post-Change Values (no placeholders)

TOTAL row as printed by `term-missing`:

```
TOTAL                                                               13922   1107   5122    556    90%
```

As at baseline, the `Cover` column of the `TOTAL` row is coverage.py's COMBINED statement-plus-branch
figure, which is neither the line-coverage nor the branch-coverage figure the policy thresholds are
stated against. The separate figures were therefore read from the coverage data itself, using the same
extraction method as the baseline so P7-T8 compares like for like.

Confirming extraction command:
`poetry run coverage json -o <scratchpad>/coverage-final-probe.json -q`
(written outside the repository to the session scratchpad, so no probe artifact is added to the branch)

Confirming EXIT_CODE: 0

```json
{
  "covered_lines": 12815,
  "num_statements": 13922,
  "percent_covered": 89.93383742911153,
  "percent_covered_display": "90",
  "missing_lines": 1107,
  "excluded_lines": 400,
  "percent_statements_covered": 92.04855624191926,
  "percent_statements_covered_display": "92",
  "num_branches": 5122,
  "num_partial_branches": 556,
  "covered_branches": 4312,
  "missing_branches": 810,
  "percent_branches_covered": 84.18586489652479,
  "percent_branches_covered_display": "84"
}
```

| Coverage metric | Post-change value | Threshold | Verdict |
| --- | --- | --- | --- |
| Line (statement) coverage | **92.05%** (12815 covered / 13922 statements; 1107 missing) | >= 85% | PASS, margin +7.05 pp |
| Branch coverage | **84.19%** (4312 covered / 5122 branches; 810 missing, 556 partial) | >= 75% | PASS, margin +9.19 pp |
| Combined statement+branch (`Cover` column) | 89.93% (displayed 90%) | not a policy threshold | recorded for row-to-row comparison |
| Excluded lines | 400 (baseline 387) | n/a | +13, from the pre-existing `if __name__ == "__main__"` / `TYPE_CHECKING` exclusion rules applying to new modules; no new `exclude` pattern was added to any config |

## Per-Module Coverage for Every New Production Module

The four modules named in the plan, plus the three additional delegate modules execution created to
hold every file under the 500-line cap. All seven are new production files; none existed at baseline,
so their baseline coverage is NOT APPLICABLE (file absent), not zero.

| New production module | Stmts | Miss | Line cov | Branches | Partial/Miss br | Branch cov | `term-missing` row |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/parallel_mutation_protocol.py` (planned) | 44 | 0 | **100.00%** | 22 | 0 | **100.00%** | `44 0 22 0 100%` |
| `scripts/dev_tools/_parallel_mutation_models.py` (planned) | 95 | 0 | **100.00%** | 30 | 0 | **100.00%** | `95 0 30 0 100%` |
| `scripts/dev_tools/parallel_mutation_abandon_cli.py` (planned) | 62 | 0 | **100.00%** | 10 | 0 | **100.00%** | `62 0 10 0 100%` |
| `scripts/dev_tools/_parallel_orchestrator_state_mutations.py` (planned) | 67 | 0 | **100.00%** | 28 | 0 | **100.00%** | `67 0 28 0 100%` |
| `scripts/dev_tools/_parallel_mutation_errors.py` (delegate, beyond plan inventory) | 34 | 0 | **100.00%** | 0 | 0 | n/a (no branches) | `34 0 0 0 100%` |
| `scripts/dev_tools/_parallel_mutation_entries.py` (delegate, beyond plan inventory) | 13 | 0 | **100.00%** | 0 | 0 | n/a (no branches) | `13 0 0 0 100%` |
| `scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py` (delegate, beyond plan inventory) | 66 | 0 | **100.00%** | 32 | 0 | **100.00%** | `66 0 32 0 100%` |

Every new production module reaches 100% line coverage and 100% branch coverage (where branches
exist). No new production file is excluded from coverage measurement.

## The One Shared Python File F6 Edits — No Regression

```
scripts\dev_tools\validate_parallel_orchestrator_state.py              84      2     34      2    97%   227, 266
```

| Figure | Baseline (P0-T4) | Post-change | Delta |
| --- | --- | --- | --- |
| Statements | 82 | 84 | +2 (the one added import line and the one added call line) |
| Missing statements | 2 | 2 | 0 |
| Line coverage | 97.56% (80/82) | **97.62%** (82/84) | +0.06 pp |
| Branches | 34 | 34 | 0 |
| Partial branches | 2 | 2 | 0 |
| Branch coverage | 94.12% (32/34) | **94.12%** (32/34) | 0 |
| Uncovered lines | 226, 265 | 227, 266 | the same two pre-existing uncovered lines, shifted by +1 by the single added import line above them |

Both F6-added lines are covered: the statement count rose by 2 while the missing count stayed at 2,
and the uncovered line identities are the pre-existing pair shifted by the import. There is no
coverage regression on the changed lines of this file.

## New/Changed-Code Coverage

All F6-authored production lines are covered:
- 381 new production statements across the seven new modules, 0 missing → **100.00%** line coverage on
  new code; 122 new branches, 0 missing → **100.00%** branch coverage on new code.
- 2 changed statements in `validate_parallel_orchestrator_state.py`, both covered → **100.00%**.

Combined new/changed-code coverage: **383 of 383 statements covered = 100.00%**.

## Coverage LCOV Side-Output

Coverage LCOV written by the existing pytest configuration to `artifacts/python/lcov.info`. That path
is the pre-existing tool output location configured in the repository, not an evidence path; no
evidence artifact for this feature is written under `artifacts/`.

Output Summary: `poetry run pytest --cov --cov-branch --cov-report=term-missing` exited **0** with
**3386 passed, 0 failed, 0 errors, 0 skipped** in 10.96 s (baseline 3007 passed, so +379 tests).
Post-change **line (statement) coverage 92.05%** (12815/13922) versus baseline 91.82%, and
**branch coverage 84.19%** (4312/5122) versus baseline 83.80% — both improved, both above threshold
(line >= 85%, branch >= 75%). Per-module coverage is **100% line and 100% branch for all seven new
production modules**: `parallel_mutation_protocol.py` (44 stmts), `_parallel_mutation_models.py` (95),
`parallel_mutation_abandon_cli.py` (62), `_parallel_orchestrator_state_mutations.py` (67),
`_parallel_mutation_errors.py` (34), `_parallel_mutation_entries.py` (13), and
`_parallel_orchestrator_state_mode_completion.py` (66). The one shared Python file,
`validate_parallel_orchestrator_state.py`, went from 82 to 84 statements with missing count unchanged
at 2, so both added lines are covered and there is no regression on changed lines. New/changed-code
coverage is 383/383 statements = 100.00%.

Verdict: PASS (all tests pass; numeric line and branch coverage recorded; per-module figures recorded
for every new production module).

## Confirming Re-Run After Documentation-Only Edits (Phase 7 loop rule)

After this gate ran, the only files that changed were Markdown documentation inside the feature folder
(`plan.md` checkbox updates, the three deferred `spec.md` AC markers, and evidence artifacts). The Phase 7
loop rule requires a clean pass after any file change, so the full Python loop was rerun in order.

Timestamp: 2026-08-09T03-56

| Stage | Command | Exit code | Result |
| --- | --- | --- | --- |
| Format | `poetry run black --check .` | 0 | `388 files would be left unchanged` |
| Lint | `poetry run ruff check .` | 0 | `All checks passed!` |
| Type check | `poetry run pyright` | 0 | `0 errors, 0 warnings, 0 informations` |
| Test + coverage | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | 0 | `3386 passed in 11.79s`; `TOTAL 13922 1107 5122 556 90%` |

The `TOTAL` coverage row and the passing count are identical to the primary run recorded above, so the
figures in this artifact remain accurate. All four stages passed consecutively in a single pass; no loop
restart was required.
