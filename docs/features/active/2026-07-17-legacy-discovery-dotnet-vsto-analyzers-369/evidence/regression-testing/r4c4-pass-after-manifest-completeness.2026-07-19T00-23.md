# Pass-After — Manifest Completeness Suite (Issue #369, Remediation Cycle 4)

- Timestamp: 2026-07-19T00-23
- Task: [P1-T3]

## Command

Planned command:

```
npm --prefix extensions/drm-copilot run test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts
```

Environment note: As documented in `evidence/remediation-baseline/r4c4-phase0-extension-suite-fail-before.2026-07-19T00-23.md`, the planned command reports `No tests found` in this agent worktree because the checkout path contains a `.claude` hidden directory that breaks jest's `<rootDir>` testMatch glob substitution. This is a worktree-path artifact only; CI is unaffected. The assertion was exercised with the same jest binary and unmodified `jest.config.cjs` via a temporary config that supplies a literal forward-slash `testMatch` and changes no test behavior:

```
node <repo>/node_modules/jest/bin/jest.js --config <scratchpad>/jest.worktree.config.cjs claude-pack-manifest-completeness
```

## EXIT_CODE

0

## Output Summary

- Test Suites: 1 passed, 1 total.
- Tests: 7 passed, 7 total (previously 1 failed, 6 passed).
- The `expect(missing).toEqual([])` assertion now passes: the `missing` set is empty. Both `.claude/hooks/enforce-discovery-artifact-gate.ps1` and `.claude/hooks/validate-discovery-artifact-gate.ps1` are now registered in `core.json` and no longer reported as missing from every pack manifest.
