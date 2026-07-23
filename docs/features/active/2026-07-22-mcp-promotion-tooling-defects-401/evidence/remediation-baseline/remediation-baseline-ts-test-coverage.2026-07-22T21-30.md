# Remediation Baseline — TypeScript Test + Coverage (Cycle 1, Issue #401)

Timestamp: 2026-07-22T21-30

Command: npm run test:coverage -- --testMatch 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a4396e634050c686d/extensions/drm-copilot/test/**/*.test.ts' (from extensions/drm-copilot/, invoked via pwsh)

EXIT_CODE: 0

Output Summary:
- Test Suites: 168 passed, 168 total.
- Tests: 2031 passed, 2031 total. 0 failed.
- Line coverage: 96.33% (37622/39053).
- Branch coverage: 89.21% (5201/5830).
- Functions: 89.57% (1100/1228).
- Note: The forward-slashed absolute --testMatch override is required when running the extension Jest suite from a worktree whose path contains the dot-directory segment `.claude/`; without it Jest reports 0 matches. Runner concern only; no production/config file changed.
