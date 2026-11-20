# TypeScript Test and Coverage — Final QC

Timestamp: 2026-08-20T13-32
Task: [P12-T9]
Issue: #486
Working directory: `extensions/drm-copilot`

Command: `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary`

EXIT_CODE: 0

Output Summary:

- Test Suites: 193 passed, 193 total. Tests: 2621 passed, 2621 total. 0 failed. Snapshots: 0. Time 7.93 s.
- Repository-wide coverage summary: Statements 96.64% (42898/44387), Branches 89.97% (6083/6761), Functions 89.65% (1256/1401), Lines 96.64% (42898/44387).
- Per-module rows from the `text` reporter (`% Stmts | % Branch | % Funcs | % Lines`) for every module named by this task, plus `plan-gate-rules.ts`, which the P8-T14 module split created and which carries its own per-file threshold entry in `extensions/drm-copilot/jest.config.cjs`:

| Module | % Lines | Line >= 85 | % Branch | Branch >= 75 |
| --- | --- | --- | --- | --- |
| `src/lib/validate/plan-gate-commands.ts` | 96.24 | PASS | 84.93 | PASS |
| `src/lib/validate/plan-gate-discrimination.ts` | 100 | PASS | 97.91 | PASS |
| `src/lib/validate/plan-gate-rules.ts` | 97.71 | PASS | 89.39 | PASS |
| `src/lib/validate/orchestration-artifacts.ts` | 100 | PASS | 98.68 | PASS |
| `src/lib/validate/validate-orchestration-service-call.ts` | 98.5 | PASS | 81.25 | PASS |
| `src/mcp-tools.ts` | 92.5 | PASS | 82.75 | PASS |

- Uncovered lines as reported: `plan-gate-commands.ts` 132-139, 157-158, 161-162, 210-211; `plan-gate-discrimination.ts` 199; `plan-gate-rules.ts` 162-163, 273-274, 298-299, 374-375, 430-431; `orchestration-artifacts.ts` 307; `validate-orchestration-service-call.ts` 117-118; `mcp-tools.ts` 80-81, 156-157, 170-173, 188-191, 194-197, 201, 204-207, 244-246.
- Every line percentage is at or above 85 and every branch percentage is at or above 75.
- Per-file threshold enforcement: the run exited 0 with no `Jest: "..." coverage threshold ... not met` message. `extensions/drm-copilot/jest.config.cjs` carries `lines: 85, branches: 75` entries for all three new modules (`./src/lib/validate/plan-gate-commands.ts`, `./src/lib/validate/plan-gate-rules.ts`, `./src/lib/validate/plan-gate-discrimination.ts`), so the clean exit is a real enforcement result, and the reporter printed a per-file row for each of the three. This satisfies the deferred second clause of `[P9-T12]`.
- `src/lib/validate/plan-gate-discrimination.ts` reports `% Funcs 52.17`. No function-coverage threshold exists in repository policy (`.claude/rules/quality-tiers.md` gates line and branch only) and no `functions` key appears in the jest per-file threshold entries, so this value is recorded for completeness and is not a gate result. The module is a thin re-export and delegation surface over `plan-gate-rules.ts`, whose own function coverage is 100.
