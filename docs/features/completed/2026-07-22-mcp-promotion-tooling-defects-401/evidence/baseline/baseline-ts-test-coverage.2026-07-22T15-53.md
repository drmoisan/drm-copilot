# Baseline — TypeScript Test + Coverage (Issue #401)

Timestamp: 2026-07-22T15-53

Command: npm run test:coverage -- --testMatch 'C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a4396e634050c686d/extensions/drm-copilot/test/**/*.test.ts' (from extensions/drm-copilot/, via pwsh)

EXIT_CODE: 0

Output Summary:
- Test Suites: 165 passed, 165 total
- Tests: 2006 passed, 2006 total
- Coverage (text-summary): Lines 96.3% (37511/38949); Branches 89.22% (5198/5826); Functions 89.48% (1098/1227); Statements 96.3%.
- Line coverage 96.3% >= 85% and branch coverage 89.22% >= 75% at baseline.

Note on invocation: A literal forward-slash `--testMatch` override is required because this worktree lives under a `.claude/` dot-directory. Jest's `replacePathSepForGlob` preserves a backslash preceding a glob-special char (`.`), so the config `<rootDir>/test/**/*.test.ts` glob produces `drm-copilot\.claude` and matches zero files. The override supplies an already-forward-slashed absolute glob, bypassing `<rootDir>` substitution. This is an environment/runner concern only; no production or config file is changed.
