# TypeScript Coverage Baseline (Remediation Cycle 3)

Timestamp: 2026-10-16T06-19
Task: [P0-T9]
Working directory: extensions/drm-copilot/
Command: npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary --reporters=default
EXIT_CODE: 0
Output Summary:

- Test Suites: 271 passed, 271 total. Tests: 4023 passed, 4023 total. No failing suite.
- No coverage-threshold message printed.
- text-summary totals: Statements 97.28% (51397/52832), Branches 92.33% (7601/8232), Functions 91.69% (1534/1673), Lines 97.28% (51397/52832).
- Per-file values from `extensions/drm-copilot/coverage/coverage-summary.json`:

| File | lines.pct | branches.pct |
| --- | --- | --- |
| `src/lib/validate/plan-gate-scratch.ts` | 100 (226/226) | 100 (31/31) |
| `src/lib/validate/plan-gate-commands.ts` | 95.94 (426/444) | 85.39 (76/89) |
| `src/lib/validate/plan-gate-rules.ts` | 98.16 (429/437) | 91.17 (62/68) |
