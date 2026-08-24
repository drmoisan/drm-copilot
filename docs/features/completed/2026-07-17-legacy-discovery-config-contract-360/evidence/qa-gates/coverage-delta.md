# Coverage Threshold and Delta Verification (P5-T6)

Timestamp: 2026-07-18T14-40

## Baseline (P0-T6)

- Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
- TOTAL combined: 85% (Stmts=10909, Miss=1335, Branch=4114, BrPart=549).
- Baseline line coverage: 87.8%. Baseline branch coverage (derived): ~77.7%.
- New discovery package: not present at baseline (N/A).

## Post-change (P5-T5)

- Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
- TOTAL combined: 86% (Stmts=11202, Miss=1336, Branch=4212, BrPart=550).
- Post-change line coverage: 88.1%. Post-change branch coverage (derived): ~80.5%.

## New / changed-code coverage (the discovery package — all newly added files)

- Aggregate new-package statements: 3 + 189 + 55 + 46 = 293; missed = 1 → line coverage
  = 99.7%.
- Aggregate new-package branches: 0 + 78 + 14 + 6 = 98; partial = 1 → branch coverage
  ≈ 99%.
- Required modules:
  - `domain_profile.py`: line 99.5%, branch 98.7%.
  - `profile_cli.py`: line 100%, branch 100%.

## Threshold check (policy: line >= 85%, branch >= 75%)

- New-package line coverage 99.7% >= 85%: PASS.
- New-package branch coverage ~99% >= 75%: PASS.
- `domain_profile.py` line 99.5% / branch 98.7%: PASS.
- `profile_cli.py` line 100% / branch 100%: PASS.

## No-regression check on changed lines

All changed lines are net-new (four new production files, two new test files, one new
`pyproject.toml` script line). There are no modified pre-existing production lines, so no
changed-line regression is possible. Total combined coverage moved from 85% to 86% (no
regression; a small improvement).

## Verdict

PASS. The new modules meet line >= 85% and branch >= 75% with no changed-line regression.
