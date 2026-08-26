# Baseline — TypeScript Tests and Coverage ([P0-T8])

Timestamp: 2026-08-25T09-26

Command: npm --prefix extensions/drm-copilot run test:coverage

EXIT_CODE: 0

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a38eff9588c69b6ec`
Branch: `bug/potential-to-issue-ignores-workspace-root-when-creating-the-issue-525`
Underlying command: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`

## Output Summary

Full suite passed with coverage collected. All values below are the literal figures reported by the
run; no value is a placeholder.

**Suite result: 195 of 195 test suites passed, 2658 of 2658 tests passed, 0 failed, 0 snapshots, 12.36 s.**

**Overall line coverage: 96.66%. Overall branch coverage: 90.05%.**

| Metric | Percentage | Covered / Total |
| --- | --- | --- |
| Statements | 96.66% | 43084 / 44571 |
| Branches | 90.05% | 6128 / 6805 |
| Functions | 89.67% | 1260 / 1405 |
| Lines | 96.66% | 43084 / 44571 |

| Suite metric | Passed | Total |
| --- | --- | --- |
| Test Suites | 195 | 195 |
| Tests | 2658 | 2658 |

Both headline figures clear the uniform thresholds in `.claude/rules/quality-tiers.md`: line coverage
96.66% against the >= 85% floor, and branch coverage 90.05% against the >= 75% floor.

## Verbatim Coverage Summary Block

```
=============================== Coverage summary ===============================
Statements   : 96.66% ( 43084/44571 )
Branches     : 90.05% ( 6128/6805 )
Functions    : 89.67% ( 1260/1405 )
Lines        : 96.66% ( 43084/44571 )
================================================================================

Test Suites: 195 passed, 195 total
Tests:       2658 passed, 2658 total
Snapshots:   0 total
Time:        12.36 s
Ran all test suites.
```

## Reporter Configuration Note

The `test:coverage` script pins `--coverageReporters=lcov --coverageReporters=text-summary`. The
`text-summary` reporter emits the whole-project totals recorded above and does **not** emit per-file
rows. The per-file figures required by [P0-T9] are therefore read from the `lcov` reporter's output at
`extensions/drm-copilot/coverage/lcov.info`, which is produced by this same run.

## Exit-Code Capture Method

The command's stdout and stderr were redirected to a file and the exit code was echoed in the same
shell invocation immediately afterwards. The command was not piped into another process, so the
recorded status is the status of the test command itself and not of a downstream process.
