# TypeScript Test and Coverage Baseline

Timestamp: 2026-08-20T11-35
Task: [P0-T9]
Issue: #486
Working directory: `extensions/drm-copilot`

Command: `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary`

EXIT_CODE: 0

Output Summary:

- Test Suites: 185 passed, 185 total. Tests: 2558 passed, 2558 total. 0 failed.
- Repository-wide coverage summary: Statements 96.61% (41750/43212), Branches 89.96% (5902/6560), Functions 90.11% (1221/1355), Lines 96.61% (41750/43212).
- Per-module baselines for the three modules gated by P12-T9, taken from the `text` reporter table (columns `% Stmts | % Branch | % Funcs | % Lines`):
  - `src/lib/validate/orchestration-artifacts.ts` — Stmts 100, Branch 98.5, Funcs 100, Lines 100. Uncovered line: 233.
  - `src/lib/validate/validate-orchestration-service-call.ts` — Stmts 100, Branch 84.61, Funcs 100, Lines 100. Uncovered lines: 84-87.
  - `src/mcp-tools.ts` — Stmts 92.45, Branch 82.14, Funcs 100, Lines 92.45. Uncovered lines: 79-80, 154-155, 168-171, 186-189, 192-195, 199, 202-205, 242-244.
- All three per-module rows are recorded because P12-T9 gates all three, and the P12-T10 delta table requires a Phase 0 baseline for each.
