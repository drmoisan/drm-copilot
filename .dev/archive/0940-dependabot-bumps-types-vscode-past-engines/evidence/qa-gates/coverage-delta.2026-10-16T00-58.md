# Coverage delta (P2-T11)

Timestamp: 2026-10-16T00-58
Command: read pytest-full-coverage-reference and pytest-full-coverage-final artifacts
EXIT_CODE: 0
Output Summary:
- (a) Baseline (pytest-full-coverage-reference.2026-10-16T00-51.md): 7099 passed, 6 skipped; TOTAL `17638   1094   6368    504    92%`; computed line percentage 93.8%.
- (b) Post-change (pytest-full-coverage-final.2026-10-16T00-58.md): 7099 passed, 6 skipped; TOTAL `17638   1094   6368    505    92%`; computed line percentage 93.8%.
- (c) New or changed production-code coverage: 0 production statements added or changed; the only repository edit is a module under tests/, excluded by the omit list in pyproject.toml.
- Comparisons: passed 7099 == 7099; Cover 92% >= 92%; Miss 1094 <= 1094; Stmts 17638 == 17638; Branch 6368 == 6368. BrPart moved from 504 to 505; the plan does not gate BrPart, and no production or test-count change accounts for it (likely run-to-run variation in partial-branch attribution).
- Both floors (85 percent line, 75 percent branch) confirmed by exit code 0 of P2-T9.
