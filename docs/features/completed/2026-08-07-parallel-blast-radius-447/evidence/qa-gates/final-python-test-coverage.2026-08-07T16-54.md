# Final QC — Python Tests and Coverage (P6-T4)

Timestamp: 2026-08-07T16-54
Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
EXIT_CODE: 0

Output Summary: 2427 tests passed, 0 failed, 0 errored, 0 skipped, in 10.03s (baseline P0-T5: 2149 passed; +278 tests added by this feature). Post-change total line (statement) coverage is 91.28% (11560 of 12665 statements covered; 1105 missing), up from the 91.02% baseline. Post-change total branch coverage is 82.46% (3798 of 4606 branch exits covered; 808 missing; 554 partial), up from the 81.91% baseline. Both exceed the repository thresholds of line >= 85% and branch >= 75%. Per-module coverage for all four new blast-radius production modules: `compute_blast_radius.py` 100.00% line / 100.00% branch; `_blast_radius_extraction.py` 100.00% line / 100.00% branch; `_blast_radius_validation.py` 100.00% line / 100.00% branch; `_blast_radius_conflicts.py` 98.67% line / 96.88% branch. The combined terminal `TOTAL` display is 89% (coverage.py `percent_covered_display`), which blends statements and branches; the separate figures above are the comparison values.

## Total Coverage (post-change)

| Metric | Baseline (P0-T5) | Post-change (P6-T4) | Delta |
|---|---|---|---|
| Total line (statement) coverage | 91.02% | 91.28% | +0.26 pp |
| Total branch coverage | 81.91% | 82.46% | +0.55 pp |
| Combined `TOTAL` display | 89% | 89% | 0 |
| Statements | 12294 | 12665 | +371 |
| Statements covered | 11190 | 11560 | +370 |
| Statements missing | 1104 | 1105 | +1 |
| Branch exits | 4462 | 4606 | +144 |
| Branch exits covered | 3655 | 3798 | +143 |
| Branch exits missing | 807 | 808 | +1 |
| Partial branches | 553 | 554 | +1 |

Exact coverage.py totals from the JSON export of the same `.coverage` data file:

```
covered_branches=3798
covered_lines=11560
missing_branches=808
missing_lines=1105
num_branches=4606
num_partial_branches=554
num_statements=12665
percent_branches_covered=82.45766391663048
percent_covered=88.92362920502576
percent_statements_covered=91.2751677852349
```

## Per-Module Coverage — All Four New Blast-Radius Modules

The plan text for P6-T4 names three modules. Under Guardrail 4 the facade split further during Phase 2, producing a fourth production module (`_blast_radius_conflicts.py`); all four are reported.

| Module | Statements | Stmts covered | Stmts missing | Line coverage | Branch exits | Branches covered | Branches missing | Branch coverage |
|---|---|---|---|---|---|---|---|---|
| `scripts/dev_tools/compute_blast_radius.py` | 58 | 58 | 0 | 100.00% | 8 | 8 | 0 | 100.00% |
| `scripts/dev_tools/_blast_radius_extraction.py` | 119 | 119 | 0 | 100.00% | 58 | 58 | 0 | 100.00% |
| `scripts/dev_tools/_blast_radius_validation.py` | 119 | 119 | 0 | 100.00% | 46 | 46 | 0 | 100.00% |
| `scripts/dev_tools/_blast_radius_conflicts.py` | 75 | 74 | 1 | 98.67% | 32 | 31 | 1 | 96.88% |

Every module exceeds line >= 85% and branch >= 75%.

## The Single Uncovered Line

`scripts/dev_tools/_blast_radius_conflicts.py:195` — the `return entry` fall-through in `_literal_prefix`, reached only when a path entry contains no glob metacharacter at any position. Every conflict fixture and unit case that exercises `_literal_prefix` supplies an entry containing a wildcard, so the wildcard-free fall-through is not reached. The line is a plain return of the input value with no branching side effect. Module coverage remains 98.67% line / 96.88% branch, above both thresholds, so no remediation is required.

## Test Counts

| Result | Baseline | Post-change |
|---|---|---|
| Passed | 2149 | 2427 |
| Failed | 0 | 0 |
| Errored | 0 | 0 |
| Skipped | 0 | 0 |

## Derivation Note

The `term-missing` report emits a single blended `TOTAL` percentage. The separate line and branch percentages and the per-module figures were read from coverage.py's own JSON export (`poetry run coverage json`) of the same `.coverage` data file produced by the run above. The export was written to the session scratchpad, outside the repository, so no repository file was added or modified.
