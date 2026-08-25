# Baseline — TypeScript Tests and Coverage [P0-T10]

Timestamp: 2026-08-24T22-23

Task: [P0-T10]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad5151536d95b2586\extensions\drm-copilot`

Command: `node run-jest.cjs --coverage --coverageReporters=text --coverageReporters=text-summary`

EXIT_CODE: 0

Output Summary:

- Total line coverage: **96.66 percent** (43071 / 44558 lines).
- Total branch coverage: **90.04 percent** (6122 / 6799 branches).
- Total statement coverage: 96.66 percent (43071 / 44558).
- Total function coverage: 89.67 percent (1259 / 1404).
- Passed test suites: **195**. Failed test suites: **0**. Total suites: 195.
- Passed tests: **2657**. Failed tests: **0**. Total tests: 2657.
- Snapshots: 0.
- Wall time: 12.34 s.

Per-file row for the target module, copied verbatim from the `text` coverage table
(`src/lib/validate/epic-orchestrator-state-launch-binding.ts`, listed under the
`src/lib/validate` group as `epic-orchestrator-state-launch-binding.ts`):

```
File                                                        | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
  epic-orchestrator-state-launch-binding.ts                 |   95.83 |     92.3 |     100 |   95.83 | 45-46,56-61,215-217,250-251
```

Per-file figures for `src/lib/validate/epic-orchestrator-state-launch-binding.ts`:

- Line coverage: **95.83 percent**.
- Branch coverage: **92.30 percent**.
- Statement coverage: 95.83 percent.
- Function coverage: 100 percent.
- Uncovered lines at baseline: 45-46, 56-61, 215-217, 250-251.

Threshold check at baseline (uniform gate of `.claude/rules/quality-tiers.md`: line at or above 85 percent, branch at or above 75 percent):

| Scope | Line | Branch | Line gate | Branch gate |
| --- | --- | --- | --- | --- |
| All files | 96.66% | 90.04% | PASS | PASS |
| `src/lib/validate/epic-orchestrator-state-launch-binding.ts` | 95.83% | 92.30% | PASS | PASS |

Coverage summary and test summary, verbatim:

```
=============================== Coverage summary ===============================
Statements   : 96.66% ( 43071/44558 )
Branches     : 90.04% ( 6122/6799 )
Functions    : 89.67% ( 1259/1404 )
Lines        : 96.66% ( 43071/44558 )
================================================================================

Test Suites: 195 passed, 195 total
Tests:       2657 passed, 2657 total
Snapshots:   0 total
Time:        12.34 s
Ran all test suites.
```
