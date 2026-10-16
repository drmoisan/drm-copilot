# Coverage delta (P2-T11)

Timestamp: 2026-10-16T00-28
Command: read pytest-full-coverage-baseline and pytest-full-coverage-final artifacts
EXIT_CODE: 0
Output Summary:
- (a) Baseline: `TOTAL   17638   1094   6368    504    92%`; computed line percentage 93.8%.
- (b) Post-change: `TOTAL   17638   1094   6368    504    92%`; computed line percentage 93.8%.
- (c) New or changed production-code coverage: 0 production statements were added or changed. The only repository edits are a YAML file and a module under `tests/`, which the `omit` list in `pyproject.toml` excludes from measurement.
- Comparisons: final Cover 92% >= baseline 92%; final Miss 1094 <= baseline Miss 1094.
- Both floors (85 percent line, 75 percent branch) were confirmed by the exit code 0 of P2-T9.
