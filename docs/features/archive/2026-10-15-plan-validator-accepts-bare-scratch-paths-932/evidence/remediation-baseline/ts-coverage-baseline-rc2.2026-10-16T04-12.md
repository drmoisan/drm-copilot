# TypeScript Coverage Baseline (Remediation Cycle 2)

Timestamp: 2026-10-16T04-12
Task: [P0-T9]
Working directory: extensions/drm-copilot/
Command: npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary
EXIT_CODE: 0
Output Summary:

- Test Suites: 271 passed, 271 total. Tests: 4020 passed, 4020 total. 0 failing suites.
- text-summary totals: Statements 97.27% (51376/52813); Branches 92.32% (7599/8231); Functions 91.69% (1534/1673); Lines 97.27% (51376/52813).
- Coverage-threshold messages: none. No "Coverage data ... was not found" line appeared in this run's output.
- Per-file values from `extensions/drm-copilot/coverage/coverage-summary.json`:

| File | lines.pct | branches.pct | lines covered/total | branches covered/total |
| --- | --- | --- | --- | --- |
| `src/lib/validate/plan-gate-scratch.ts` | 100 | 100 | 207/207 | 31/31 |
| `src/lib/validate/plan-gate-commands.ts` | 95.94 | 85.39 | 426/444 | 76/89 |
| `src/lib/validate/plan-gate-rules.ts` | 97.71 | 89.55 | 427/437 | 60/67 |
| `src/lib/validate/plan-gate-discrimination.ts` (reference) | 100 | 98.27 | 293/293 | 57/58 |
