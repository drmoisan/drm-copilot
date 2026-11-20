# Baseline — Python Tests with Coverage

Timestamp: 2026-10-16T23-22
Task: [P0-T4]
Command: poetry run pytest tests -q --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage-964-baseline.json
EXIT_CODE: 0
Output Summary:
- 7260 passed, 6 skipped, 0 failed (129.20 s).
- Total (from the JSON report): line 94.04%, branch 88.65% (terminal combined column: 93%).
- `scripts.dev_tools.plan_gate_discrimination`: line 99.25%, branch 98.08% (from the JSON report; terminal row 99%, missing line 213).
- Coverage source per `pyproject.toml` `[tool.coverage.run]`: `src`, `scripts/dev_tools`.
