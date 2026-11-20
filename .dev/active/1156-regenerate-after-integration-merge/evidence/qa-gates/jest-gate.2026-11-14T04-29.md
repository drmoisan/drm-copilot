# Jest Root Coverage Run — feature-review (#1156)

Timestamp: 2026-11-14T04-29
Command: sh SCRATCH/jest.sh (from the item worktree root: node run-jest.cjs --coverage; normal parallel Jest workers; one suite run at a time on the machine)
EXIT_CODE: 0
Output Summary: run by the feature-review agent because the worktree-root TypeScript coverage artifact `coverage/lcov.info` was absent (the executor's gate ran in `extensions/drm-copilot/` and wrote only `extensions/drm-copilot/coverage/lcov.info`). Result at head 8533618dd: Test Suites 345 passed of 345; Tests 5576 passed of 5576; All files Statements 98.29%, Branches 93.67%, Functions 92.28%, Lines 98.29%. The run wrote the gitignored `coverage/lcov.info` only; no tracked file changed. No production TypeScript file is in the branch diff; the one TypeScript change is the appended case in `extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-core.test.ts`.
