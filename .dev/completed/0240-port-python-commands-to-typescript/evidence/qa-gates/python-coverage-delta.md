# P7-T8 — Python Coverage Delta (F11 ts-command-runtime-cleanup)

Timestamp: 2026-06-26T09-27

## Baseline (from P0-T7)
- Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
- Result: 1206 passed, 19 skipped, 0 failed.
- Raw totals: 8620 statements, 1231 missed; 3080 branches, 432 partial. Combined TOTAL 83%.

## Final (from P7-T7)
- Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
- Result: 1123 passed, 19 skipped, 0 failed.
- Raw totals: 8620 statements, 1231 missed; 3080 branches, 432 partial. Combined TOTAL 83%.

## Delta Analysis
- Raw coverage totals are BYTE-IDENTICAL between baseline and final (same statements, misses, branches, partials).
- Line coverage: 85.72% baseline = 85.72% final (no change). Branch: 85.97% = 85.97% (no change).
- Reason: the Python coverage source is `["src", "scripts/dev_tools"]` (pyproject `[tool.coverage.run]`). The removed tests were bundled-Python-parity tests targeting `extensions/drm-copilot/resources/scripts/dev_tools/**`, which is NOT in the coverage denominator. Removing them therefore cannot change coverage of the canonical source.
- The passed-test count dropped (1206 -> 1123) only because the removed tests no longer run; the canonical `scripts/dev_tools` source remains covered by its retained source tests.

## Outcome
PASS. Final Python line coverage 85.72% (>= 85%) and branch coverage 85.97% (>= 75%); no regression attributable to the removals (coverage is unchanged). All values recorded numerically.
