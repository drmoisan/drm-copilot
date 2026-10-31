# Baseline Jest with Coverage (Issue #1003)

Timestamp: 2026-10-31T12-56
Command: npm run test:coverage (in extensions/drm-copilot/; node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary), then node SCRATCH/issue-1003-lcov.cjs extensions/drm-copilot to read coverage/lcov.info
EXIT_CODE: 0
Output Summary: Tests: 5257 passed, 5257 total (324 suites). Text summary Lines 97.05% (61650/63521), Branches 93.67% (9389/10023). src/extension.ts lines 97.38% (483/496), branches 90.91% (60/66); src/claude-worktree-session.ts lines 100.00% (248/248), branches 95.00% (19/20); src/codex-worktree-session.ts lines 100.00% (120/120), branches 100.00% (14/14). Zero-hit DA records in handler bodies: newClaudeWorktreeSession 0 of 101, newCodexWorktreeSession 0 of 88.

## Jest summary

```
Test Suites: 324 passed, 324 total
Tests:       5257 passed, 5257 total
Statements   : 97.05% ( 61650/63521 )
Branches     : 93.67% ( 9389/10023 )
Functions    : 91.87% ( 1843/2006 )
Lines        : 97.05% ( 61650/63521 )
```

## coverage/lcov.info per-file records

| SF | LF | LH | Lines % | BRF | BRH | Branches % |
|---|---|---|---|---|---|---|
| src/extension.ts | 496 | 483 | 97.38% | 66 | 60 | 90.91% |
| src/claude-worktree-session.ts | 248 | 248 | 100.00% | 20 | 19 | 95.00% |
| src/codex-worktree-session.ts | 120 | 120 | 100.00% | 14 | 14 | 100.00% |

## Handler-body zero-hit DA records (src/extension.ts)

| Handler | Body lines (baseline source) | DA records | Zero-hit DA |
|---|---|---|---|
| newClaudeWorktreeSession | 150-250 | 101 | 0 |
| newCodexWorktreeSession | 255-342 | 88 | 0 |

Body range: the lines after the `"drmCopilotExtension.<id>",` literal up to (excluding) the closing `  );` of the `registerCommand` call, located by the helper from the source text.
