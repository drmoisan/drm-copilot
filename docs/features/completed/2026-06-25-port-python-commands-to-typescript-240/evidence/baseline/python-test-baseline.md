# Phase 0 — Python Suite Baseline (F11 ts-command-runtime-cleanup)

Timestamp: 2026-06-26T09-01
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
- Result: 1206 passed, 19 skipped, 0 failed.
- Coverage source (pyproject `[tool.coverage.run]`): `["src", "scripts/dev_tools"]`. The bundled tree `extensions/drm-copilot/resources/scripts/dev_tools/**` is NOT in the coverage denominator; removing the bundled-parity tests (P5) does not change the coverage math.
- Coverage TOTAL (combined statement+branch, pytest-cov term TOTAL): 83%.
  - Raw totals: 8620 statements, 1231 missed; 3080 branches, 432 partial.
- The 19 skips are pre-existing environment skips (`.codex`/`.agents` gitignored in CI); unrelated to F11.
- This baseline is the reference for the post-change Python run (P7-T7) and the Python coverage delta (P7-T8). The F11 obligation is no regression attributable to the bundled-parity test removals.
