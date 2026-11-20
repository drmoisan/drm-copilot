# Coverage Delta and Threshold Verification (P8-T5)

Timestamp: 2026-07-18T11-43
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing (baseline and post-change)

## Baseline (Phase 0, 2026-07-18T11-12)

- Tests: 1679 passed.
- Statements: 11202 total, 1336 missed -> line coverage = 88.07%
- Branches: 4212 total, 550 partial -> branch coverage = 86.94%
- Combined TOTAL row: 86%

## Post-change (Phase 8, 2026-07-18T11-43)

- Tests: 1735 passed (56 new analyzer tests).
- Statements: 11428 total, 1322 missed -> line coverage = 88.43%
- Branches: 4248 total, 550 partial -> branch coverage = 87.05%
- Combined TOTAL row: 86%

## Delta

- Line coverage: 88.07% -> 88.43% (+0.36 pp). No regression.
- Branch coverage: 86.94% -> 87.05% (+0.11 pp). No regression.

## New / changed-code coverage (new analyzer production modules)

Aggregate new-code statements: 11 + 2 + 47 + 18 + 68 + 52 + 42 = 240; missed = 0.
Aggregate new-code branches: 4 + 0 + 2 + 2 + 16 + 6 + 6 = 36; partial = 0.

- New-code line coverage = 240/240 = 100.0%
- New-code branch coverage = 36/36 = 100.0%

Per module (line / branch): __init__ 100/100, __main__ 100/n-a, cli 100/100,
emitter 100/100, inventory 100/100, models 100/100, pipeline 100/100.

## Threshold confirmation

- Line coverage >= 85%: PASS (overall 88.43%; new code 100%).
- Branch coverage >= 75%: PASS (overall 87.05%; new code 100%).
- No regression on changed lines: PASS (every new/changed production line is covered;
  overall line and branch coverage both increased).

Outcome: PASS. All required coverage values are numeric and available.
