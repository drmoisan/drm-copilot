# Coverage Delta ([P8-T5])

Timestamp: 2026-11-06T00-09
Command: comparison of `baseline/jest-coverage.2026-11-05T23-39.md` ([P0-T9]) with `qa-gates/jest-coverage.2026-11-06T00-09.md` ([P8-T4]); both from node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=lcov
EXIT_CODE: 0
Output Summary:
- No edited production file decreased in `% Lines` or `% Branch`; every edited file is at or above 85 lines and 75 branches.
- Suite totals rose from 97.06 / 93.67 to 97.1 / 93.76 (`% Lines` / `% Branch`).

| File | Baseline % Lines | Post % Lines | Delta | Baseline % Branch | Post % Branch | Delta |
|---|---|---|---|---|---|---|
| `src/mcp-tools.ts` | 95.87 | 95.98 | +0.11 | 91.48 | 92 | +0.52 |
| `src/repo-automation-tool-names.ts` | 100 | 100 | 0 | 100 | 100 | 0 |
| `src/mcp-repo-automation-tool-definitions.ts` | 100 | 100 | 0 | 100 | 100 | 0 |
| `src/mcp-tool-definitions.ts` | 100 | 100 | 0 | 100 | 100 | 0 |
| `src/repo-automation-service.ts` | 98.22 | 98.31 | +0.09 | 93.18 | 93.33 | +0.15 |
| Suite totals (All files) | 97.06 | 97.1 | +0.04 | 93.67 | 93.76 | +0.09 |
