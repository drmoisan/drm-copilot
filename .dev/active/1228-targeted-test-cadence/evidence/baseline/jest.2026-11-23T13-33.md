# Phase 0 Baseline - Jest Gates - Issue #1228 ([P0-T5])

Timestamp: 2026-11-23T13-33
Command: `npm --prefix <item worktree> ci` and `npm --prefix <item worktree>/extensions/drm-copilot ci` (both exit 0, run 2026-11-23T13-02); then `sh C:/<item worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage`; then `sh C:/<item worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh jest`
EXIT_CODE: 0
Output Summary:
- jest-extension (`node run-jest.cjs` in `extensions/drm-copilot`, normal parallel workers, coverage): EXIT_CODE 0; Test Suites 412 passed of 412; Tests 6707 passed of 6707; 0 failed.
- jest-extension repo-wide coverage summary: Statements 97.59% (74531/76371); Branches 94.96% (11909/12541); Functions 93.35% (2248/2408); Lines 97.59% (74531/76371).
- jest (root, launcher `jest` suite, integration lane excluded): EXIT_CODE 0; Test Suites 415 passed of 415; Tests 6724 passed of 6724; 0 failed.
- In-scope TypeScript files: none (no TypeScript change), so no per-file figure applies.
