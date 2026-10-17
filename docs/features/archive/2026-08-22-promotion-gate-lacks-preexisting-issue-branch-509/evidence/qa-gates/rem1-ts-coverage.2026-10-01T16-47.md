# Final QA: TypeScript Coverage on the Final Tree (Remediation Cycle 1)

Timestamp: 2026-10-01T16-47
Task: [P4-T12]
Location: worktree root (the coverage run reaches `extensions/drm-copilot` through `npm --prefix`)

## 1. Threshold-entry grep

Command: `grep -n -F -e "orchestrator-state-blocked-reason.ts" -e "orchestrator-state-issue-adoption.ts" -e "orchestrator-state-routing.ts" extensions/drm-copilot/jest.config.cjs`
EXIT_CODE: 0
Output Summary (verbatim; same three key lines at 77, 83, 87):

```text
77:    "./src/lib/validate/orchestrator-state-blocked-reason.ts": {
83:    "./src/lib/validate/orchestrator-state-issue-adoption.ts": {
87:    "./src/lib/validate/orchestrator-state-routing.ts": {
```

## 2. Coverage run

Command: `npm --prefix extensions/drm-copilot run test:coverage -- --coverageReporters=text > docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/rem1-ts-coverage-output.txt 2>&1`
EXIT_CODE: 0
Output Summary: exit 0, jest's signal that every `coverageThreshold` entry, including the three named ones, was met. Full output in `evidence/qa-gates/rem1-ts-coverage-output.txt`.

## 3. Count lines

Command: `grep -E -e "^(Test Suites|Tests):" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/rem1-ts-coverage-output.txt`
EXIT_CODE: 0
Output Summary (verbatim):

```text
Test Suites: 246 passed, 246 total
Tests:       3550 passed, 3550 total
```

## 4. Summary block

Command: `grep -E -e "^(Statements|Branches|Functions|Lines) +:" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/rem1-ts-coverage-output.txt`
EXIT_CODE: 0
Output Summary (verbatim):

```text
Statements   : 97.06% ( 50254/51776 )
Branches     : 91.29% ( 7310/8007 )
Functions    : 90.94% ( 1507/1657 )
Lines        : 97.06% ( 50254/51776 )
```

## 5. Threshold-file rows

Command: `grep -E -e "orchestrator-state-(blocked-reason|issue-adoption|routing)\.ts +\|" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/rem1-ts-coverage-output.txt`
EXIT_CODE: 0
Output Summary (verbatim; exactly three rows):

```text
  orchestrator-state-blocked-reason.ts                      |     100 |      100 |     100 |     100 |                                                                                     
  orchestrator-state-issue-adoption.ts                      |     100 |      100 |     100 |     100 |                                                                                     
  orchestrator-state-routing.ts                             |   95.93 |    92.45 |   93.75 |   95.93 | 139-142,159-160,220-221,258-259,291-292,350-354,388-389                             
```

## Baseline-to-final comparison

| Value | Baseline (P0-T16) | Final (P4-T12) | Condition | Result |
| --- | --- | --- | --- | --- |
| Test Suites passed | 246 (`RB_TS_SUITES_PASSED`) | 246, 0 failed | equal | pass |
| Tests passed | 3550 (`RB_TS_TESTS_PASSED`) | 3550, 0 failed | equal | pass |
| Summary Lines | 97.06 (`RB_TS_LINES`) | 97.06 | >= baseline | pass |
| Summary Branches | 91.29 (`RB_TS_BRANCHES`) | 91.29 | >= baseline | pass |
| `orchestrator-state-blocked-reason.ts` % Lines / % Branch | 100 / 100 | 100 / 100 | >= 85 / >= 75 | pass |
| `orchestrator-state-issue-adoption.ts` % Lines / % Branch | 100 / 100 | 100 / 100 | >= 85 / >= 75 | pass |
| `orchestrator-state-routing.ts` % Lines / % Branch | 95.93 / 92.45 | 95.93 / 92.45 | >= 85 / >= 75 | pass |

Result: PASS.
