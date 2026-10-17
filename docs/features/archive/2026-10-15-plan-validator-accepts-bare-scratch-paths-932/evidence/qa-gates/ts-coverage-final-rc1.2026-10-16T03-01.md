# Final Jest Coverage Gate (Remediation Cycle 1, QA loop pass 1)

Timestamp: 2026-10-16T03-01
Task: [P5-T12]
Working directory: extensions/drm-copilot/
Command: npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary --coverageReporters=json-summary
EXIT_CODE: 0
Output Summary:

- `Test Suites: 271 passed, 271 total`; `Tests: 4020 passed, 4020 total`; 0 failed suites and tests. Coverage-threshold message: none.
- text-summary totals: Statements 97.27% (51376/52813); Branches 92.32% (7599/8231); Functions 91.69% (1534/1673); Lines 97.27% (51376/52813).
- From `extensions/drm-copilot/coverage/coverage-summary.json`:

| File | Baseline lines.pct | Post-change lines.pct | Baseline branches.pct | Post-change branches.pct |
| --- | --- | --- | --- | --- |
| `src/lib/validate/plan-gate-scratch.ts` | 100 (230/230) | 100 (207/207) | 100 (40/40) | 100 (31/31) |
| `src/lib/validate/plan-gate-commands.ts` | 95.93 (425/443) | 95.94 (426/444) | 85.05 (74/87) | 85.39 (76/89) |

- `plan-gate-scratch.ts` has `lines.pct` 100 and `branches.pct` 100; `plan-gate-commands.ts` percentages are not lower than [P0-T10].
- Changed lines (`git diff -U0 fcb5500c3837587c45862cff391677ac59c0cca9 HEAD -- extensions/drm-copilot/src/lib/validate/plan-gate-commands.ts extensions/drm-copilot/src/lib/validate/plan-gate-scratch.ts`):
  - `plan-gate-commands.ts` `+` lines 256-258 (TSDoc), 263, and 382. Zero-hit `DA:` lines in `coverage/lcov.info`: 139-146, 164, 165, 168, 169, 217, 218, 357, 358, 400, 401 (all outside the changed set). No changed line has a zero-hit record.
  - `plan-gate-scratch.ts` `+` lines 20-21 (TSDoc), 28, 80-83 (TSDoc), 85, 91, and 147. Zero-hit `DA:` lines: none.
