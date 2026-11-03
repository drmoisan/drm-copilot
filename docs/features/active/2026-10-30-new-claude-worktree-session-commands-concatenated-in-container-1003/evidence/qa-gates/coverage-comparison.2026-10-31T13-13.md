# QA Gate: Coverage Comparison (Issue #1003)

Timestamp: 2026-10-31T13-13
Command: node SCRATCH/issue-1003-lcov.cjs extensions/drm-copilot (baseline values from evidence/baseline/jest-coverage.2026-10-31T12-56.md; post-change values from evidence/qa-gates/jest-coverage.2026-10-31T13-13.md)
EXIT_CODE: 0
Output Summary: src/extension.ts lines 97.38% -> 97.10%, branches 90.91% -> 88.46% (both above 85/75; the uncovered lines and branches are outside the two handlers); zero-hit DA records inside the rewritten handler bodies: newClaudeWorktreeSession 0 of 72, newCodexWorktreeSession 0 of 75 (baseline 0 of 101 and 0 of 88). Changed-line coverage did not regress. Builders stay at 100% lines; the new launch module is 100% lines and branches.

## Per-file comparison

| File | Baseline LF | Baseline LH | Baseline lines % | Baseline BRF | Baseline BRH | Baseline branches % | Post LF | Post LH | Post lines % | Post BRF | Post BRH | Post branches % |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| src/extension.ts | 496 | 483 | 97.38% | 66 | 60 | 90.91% | 448 | 435 | 97.10% | 52 | 46 | 88.46% |
| src/claude-worktree-session.ts | 248 | 248 | 100.00% | 20 | 19 | 95.00% | 260 | 260 | 100.00% | 20 | 19 | 95.00% |
| src/codex-worktree-session.ts | 120 | 120 | 100.00% | 14 | 14 | 100.00% | 121 | 121 | 100.00% | 14 | 14 | 100.00% |
| src/worktree-session-launch.ts | n/a (new) | n/a | n/a | n/a | n/a | n/a | 244 | 244 | 100.00% | 14 | 14 | 100.00% |

## Handler-body changed-line check (src/extension.ts)

| Handler | Post-change body lines | DA records | Zero-hit DA |
|---|---|---|---|
| newClaudeWorktreeSession | 144-215 | 72 | 0 |
| newCodexWorktreeSession | 220-294 | 75 | 0 |

Every `DA` record inside the two rewritten handler bodies has a hit count above 0. The uncovered lines (13) and the uncovered branches (6) in `src/extension.ts` are the same counts as the baseline (13 and 6) and lie outside the handler bodies; the percentage change follows from the smaller denominator after the handler code was removed.
