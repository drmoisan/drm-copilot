# coverage-delta

Timestamp: 2026-10-16T01-26
Command: read pytest-full-coverage-reference and pytest-full-coverage-final artifacts
EXIT_CODE: 0
Output Summary:
- (a) Baseline (pytest-full-coverage-reference.2026-10-16T01-16.md): TOTAL   17638   1094   6368    505    92%; computed line percentage 93.8%.
- (b) Post-change (pytest-full-coverage-final, this pass): TOTAL   17638   1094   6368    505    92%; computed line percentage 93.8%.
- (c) BrPart: baseline 505, final 505 (information only, not compared).
- (d) New or changed production-code coverage: 0 production statements added or changed; the only repository edit is a module under tests/, excluded by the omit list in pyproject.toml.
- Comparisons: passed count 7099 equals 7099; Cover 92 >= 92 and >= baseline 92; Miss 1094 <= 1094; Stmts 17638 and Branch 6368 equal baseline.
- Both floors (85 percent line, 75 percent branch) confirmed by exit code 0 of coverage-thresholds-final.
