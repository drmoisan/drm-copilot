# Phase 0 Fail-Before Baseline — Extension Suite (Issue #369, Remediation Cycle 4)

- Timestamp: 2026-07-19T00-23
- Task: [P0-T2] [expect-fail]

## Command

Planned command:

```
npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts
```

Environment note (worktree path workaround): The planned command reports `No tests found, exiting with code 1` in this agent worktree. Root cause is local to the worktree path only: the checkout path contains a `.claude` hidden directory (`...\.claude\worktrees\agent-a6a8d8043b625e184\...`). Jest's `<rootDir>` token substitution in `testMatch` emits a stray backslash before `.claude` (`drm-copilot\.claude`), which escapes the dot and drops the path separator in the resolved glob, so the `test/**/*.test.ts` glob matches zero files. CI checks out to a path without `.claude` and is unaffected; this is not a repository defect and requires no source change. To exercise the actual assertion, the same jest binary and the unmodified `jest.config.cjs` were invoked through a temporary config that supplies a literal forward-slash `testMatch` (no `<rootDir>` token to re-normalize) and changes no test behavior:

```
node <repo>/node_modules/jest/bin/jest.js --config <scratchpad>/jest.worktree.config.cjs claude-pack-manifest-completeness
```

## EXIT_CODE

- Planned command as written: 1 (No tests found — worktree path artifact)
- Assertion-exercising command (temp-config workaround): 1

## Output Summary

- Suite `claude pack manifest completeness (real filesystem)` FAILS as expected before the fix.
- Failing assertion: `expect(missing).toEqual([])` at `test/lib/push-down/claude-pack-manifest-completeness.test.ts:137`.
- `Received` (the `missing` set) is exactly:
  - `.claude/hooks/enforce-discovery-artifact-gate.ps1`
  - `.claude/hooks/validate-discovery-artifact-gate.ps1`
- Test totals: 1 failed, 6 passed, 7 total (this suite file).
- This confirms the Blocking finding reproduces: the two bundled discovery-artifact-gate hooks are registered in no pack manifest. The `missing` set matches the finding exactly (no more, no fewer paths).
