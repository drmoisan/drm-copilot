# Baseline TypeScript Coverage (Post-Merge) (Remediation Cycle 1)

Timestamp: 2026-10-01T16-32
Task: [P0-T16]
Location: worktree root (the coverage run reaches `extensions/drm-copilot` through `npm --prefix`)

Precondition micro-action: `extensions/drm-copilot/node_modules` was absent in this worktree, so `npm --prefix extensions/drm-copilot ci` was run first (EXIT_CODE 0; "added 452 packages ... found 0 vulnerabilities"). The install output is gitignored; `git status --porcelain` afterwards listed only feature-folder paths.

## 1. Threshold-entry grep

Command: `grep -n -F -e "orchestrator-state-blocked-reason.ts" -e "orchestrator-state-issue-adoption.ts" -e "orchestrator-state-routing.ts" extensions/drm-copilot/jest.config.cjs`
EXIT_CODE: 0
Output Summary (verbatim; exactly three key lines at 77, 83, 87):

```text
77:    "./src/lib/validate/orchestrator-state-blocked-reason.ts": {
83:    "./src/lib/validate/orchestrator-state-issue-adoption.ts": {
87:    "./src/lib/validate/orchestrator-state-routing.ts": {
```

## 2. Coverage run

Command: `npm --prefix extensions/drm-copilot run test:coverage -- --coverageReporters=text > docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/remediation-baseline/ts-coverage-output.txt 2>&1`
EXIT_CODE: 0
Output Summary: exit 0, which is jest's signal that every `coverageThreshold` entry was met. Full output in `evidence/remediation-baseline/ts-coverage-output.txt`.

## 3. Count lines

Command: `grep -E -e "^(Test Suites|Tests):" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/remediation-baseline/ts-coverage-output.txt`
EXIT_CODE: 0
Output Summary (verbatim):

```text
Test Suites: 246 passed, 246 total
Tests:       3550 passed, 3550 total
```

`RB_TS_SUITES_PASSED` = 246, `RB_TS_TESTS_PASSED` = 3550, 0 failed.

## 4. Summary block

Command: `grep -E -e "^(Statements|Branches|Functions|Lines) +:" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/remediation-baseline/ts-coverage-output.txt`
EXIT_CODE: 0
Output Summary (verbatim):

```text
Statements   : 97.06% ( 50254/51776 )
Branches     : 91.29% ( 7310/8007 )
Functions    : 90.94% ( 1507/1657 )
Lines        : 97.06% ( 50254/51776 )
```

`RB_TS_LINES` = 97.06, `RB_TS_BRANCHES` = 91.29.

## 5. Threshold-file rows

Command: `grep -E -e "orchestrator-state-(blocked-reason|issue-adoption|routing)\.ts +\|" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/remediation-baseline/ts-coverage-output.txt`
EXIT_CODE: 0
Output Summary (verbatim; exactly three rows; columns `% Stmts | % Branch | % Funcs | % Lines | Uncovered`):

```text
  orchestrator-state-blocked-reason.ts                      |     100 |      100 |     100 |     100 |                                                                                     
  orchestrator-state-issue-adoption.ts                      |     100 |      100 |     100 |     100 |                                                                                     
  orchestrator-state-routing.ts                             |   95.93 |    92.45 |   93.75 |   95.93 | 139-142,159-160,220-221,258-259,291-292,350-354,388-389                             
```

| File | % Lines | % Branch | Lines >= 85 | Branch >= 75 |
| --- | --- | --- | --- | --- |
| `orchestrator-state-blocked-reason.ts` | 100 | 100 | yes | yes |
| `orchestrator-state-issue-adoption.ts` | 100 | 100 | yes | yes |
| `orchestrator-state-routing.ts` | 95.93 | 92.45 | yes | yes |

For reference, the first execution recorded 241 suites and 3431 tests before the merge; the post-merge values above (246 and 3550) include the #523 tests and are the reference for P4-T12.
