# Coverage Delta Verification (Issue #422)

Timestamp: 2026-07-26T01-08

Sources compared:
- Baseline: `docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/baseline/baseline-python-pytest-coverage.2026-07-26T00-50.md` (`[P0-T11]`)
- Post-change: `docs/features/active/2026-07-25-claude-rules-vitest-jest-divergence-422/evidence/qa-gates/final-python-pytest-coverage.2026-07-26T01-08.md` (`[P5-T4]`)

Both were produced by `poetry run pytest --cov --cov-branch --cov-report=term-missing`, with exact percentages extracted from the same coverage data file via `poetry run coverage json`.

## Numeric comparison

| Metric | Baseline (pre-change) | Post-change | Delta | Policy floor | Verdict |
|---|---|---|---|---|---|
| Line (statement) coverage | 91.00% | 91.00% | 0.00 pp | >= 85% | PASS |
| Branch coverage | 81.84% | 81.84% | 0.00 pp | >= 75% | PASS |
| Combined statement+branch total (coverage.py `TOTAL`) | 88.57% | 88.57% | 0.00 pp | n/a | PASS |
| Covered lines / total statements | 11175 / 12280 | 11175 / 12280 | 0 / 0 | n/a | unchanged |
| Covered branches / total branches | 3642 / 4450 | 3642 / 4450 | 0 / 0 | n/a | unchanged |
| Tests passed | 2123 | 2138 | +15 | n/a | PASS |
| Tests failed | 0 | 0 | 0 | 0 | PASS |

Both coverage denominators and numerators are byte-identical between the two runs. The measured coverage did not move in either direction.

## No-regression analysis

No coverage regression is attributable to this change, and none was expected. The change set consists of:

1. Twelve Markdown instruction files (six repo-root mirrors plus their six bundled copies). Markdown is not executable and is not in the coverage denominator.
2. One new file, `tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py`. This is test code. `pyproject.toml` `[tool.coverage.run]` scopes measurement to `source = ["src", "scripts/dev_tools"]` and additionally omits `tests/*` and `*/tests/*`, so the new module is excluded from the coverage denominator by the repository's pre-existing configuration. That exclusion is permitted by `.claude/rules/general-unit-test.md` ("Configure coverage tooling to exclude test files (e.g., `tests/`) so metrics reflect application code, not tests") and is not a new or widened exclusion introduced by this change.

No production source file under `src/` or `scripts/dev_tools/` was added, modified, or deleted. That is why the statement and branch totals are numerically identical to the baseline.

## New/changed-code coverage

**Not applicable**, with rationale: this change introduces zero new or changed production code lines. The only added executable Python is test code, which policy places outside the coverage denominator. There is therefore no new-code population to measure. This is a recorded rationale, not a placeholder, and it does not lower or waive any coverage threshold.

## Verdict

**PASS.**

- Line coverage 91.00% >= 85% floor.
- Branch coverage 81.84% >= 75% floor.
- Zero regression on changed lines (no production line changed).
- All required numeric values are available and recorded; no placeholder was used.
