# Phase 0 — Baseline Python Tests and Coverage (P0-T6)

Timestamp: 2026-08-24T13-52

Task: [P0-T6]
Issue: #515
Stage: Toolchain stage 5 of 7 (unit tests), baseline capture, coverage-enabled.

Command: `poetry run pytest --cov=scripts.dev_tools --cov=src --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json`

EXIT_CODE: 0

## Test counts

```text
====================== 4112 passed, 5 skipped in 24.91s =======================
```

- Passed: **4112**
- Failed: **0**
- Errors: **0**
- Skipped: 5

The five skips are pre-existing and are declared by the test module itself, not by an environment condition. All five come from `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231` and are parametrized cases whose fixture "declares no accessor expectation" — that is, the parametrization deliberately carries no assertion for those five inputs. They are unrelated to this plan's scope and are not a failure or an error.

## Coverage — numeric totals computed from `artifacts/python/coverage.json`

The `totals` block of `artifacts/python/coverage.json`, verbatim:

```json
{"covered_lines": 13841, "num_statements": 14946, "percent_covered": 90.61460168330397, "percent_covered_display": "91", "missing_lines": 1105, "excluded_lines": 432, "percent_statements_covered": 92.60671751639235, "percent_statements_covered_display": "93", "num_branches": 5490, "num_partial_branches": 559, "covered_branches": 4677, "missing_branches": 813, "percent_branches_covered": 85.19125683060109, "percent_branches_covered_display": "85"}
```

Derived figures, computed exactly as this task specifies:

| Figure | Formula from `totals` | Operands | Value |
| --- | --- | --- | --- |
| **Total line coverage** | `covered_lines / num_statements` | 13841 / 14946 | **92.6067 %** |
| **Total branch coverage** | `covered_branches / num_branches` | 4677 / 5490 | **85.1913 %** |

Both are above the `.claude/rules/quality-tiers.md` thresholds: line 92.6067 % >= 85 %, branch 85.1913 % >= 75 %.

## Term report `TOTAL` row (combined figure — NOT the line percent and NOT the branch percent)

Verbatim final row of the `term-missing` report:

```text
TOTAL                                                               14946   1105   5490    559    91%
```

That trailing **91 %** is coverage.py's combined `percent_covered` (90.6146 %, displayed as 91), which blends statements and branches into a single ratio. It is recorded here **only** as the labelled combined figure and is deliberately not used as either headline number. The line figure is 92.6067 % and the branch figure is 85.1913 %; both differ from 91 %, which is precisely why this task requires the JSON report rather than the term report.

## Artifact-location note

`artifacts/python/coverage.json` is tool output, not evidence. `artifacts/` is gitignored at `.gitignore:6`, so writing it does not add an entry to any working-tree status snapshot and does not perturb the P3-T3, P4-T2, or P4-T6 snapshot comparisons, nor the P5-T1 write-target union. The evidence artifact is this file, under the canonical `evidence/baseline/` path.

Output Summary: **4112 passed, 0 failed, 0 errors, 5 pre-existing declared skips; exit code 0. Total line coverage 92.6067 % (13841/14946). Total branch coverage 85.1913 % (4677/5490). Term-report combined `TOTAL` row = 91 %, recorded as the combined figure only.**

Phase 0 contingency evaluation for this task: the exit code is 0, the failure count is 0, the error count is 0, and both coverage figures are above their thresholds (line 92.6067 % >= 85 %, branch 85.1913 % >= 75 %). This baseline is clean and imposes no scope conflict. The P4-T4 and P4-T5 counterparts compare against these two figures; because this plan's diff adds no line to the measured source set (`pyproject.toml` is configuration, and `tests/` is omitted from the coverage source set), the post-change figures are expected to be identical or to differ only marginally.
