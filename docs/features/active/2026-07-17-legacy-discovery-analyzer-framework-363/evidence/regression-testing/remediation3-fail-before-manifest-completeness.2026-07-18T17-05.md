# Remediation Cycle 3 — Fail-Before: Manifest Completeness (P0-T7) [expect-fail]

Timestamp: 2026-07-18T17-05

Command (canonical CI form): `npm --prefix extensions/drm-copilot run test -- claude-pack-manifest-completeness`

Command (as executed in this worktree): `node run-jest.cjs --testMatch "**/test/**/*.test.ts" --testPathPatterns claude-pack-manifest-completeness` (from `extensions/drm-copilot`)

EXIT_CODE: 1

## Environment Note (test-discovery override, non-scope)

The canonical CI command `npm --prefix extensions/drm-copilot run test` discovers 0 tests in this worktree. Root cause: this feature branch is checked out in a git worktree under `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a4835d008d9c1fd14`. Jest resolves the config `testMatch` token `<rootDir>/test/**/*.test.ts` to an absolute glob that contains a stray backslash before the `.claude` dot-directory segment (`...drm-copilot\.claude/worktrees/...`), which breaks micromatch and yields 0 matches. CI checks out to a path with no leading-dot directory and is unaffected (CI run 29652993218 reported 1 failed, 1885 passed).

To execute the plan's required test commands in this worktree, `--testMatch "**/test/**/*.test.ts"` is supplied on the CLI. This overrides only the path-glob used for test discovery; it does not change which test files exist, the test bodies, coverage collection, or thresholds. The full test set is discovered under this override.

## Output Summary

- FAIL: `claude pack manifest completeness (real filesystem) › lists every bundled .claude agent, skill, and hook file in some pack manifest`.
- Assertion `expect(missing).toEqual([])` at `test/lib/push-down/claude-pack-manifest-completeness.test.ts:137`.
- `missing` array (received) contained exactly the four unregistered agent paths:
  - `.claude/agents/legacy-parity-analyst.md`
  - `.claude/agents/migration-coverage-reviewer.md`
  - `.claude/agents/requirements-reconciler.md`
  - `.claude/agents/runtime-characterization-analyst.md`
- Target file result: Tests: 1 failed, 6 passed, 7 total. Test Suites: 1 failed, 1 total.
- Confirms the blocking finding: the four bundled agent files exist in the payload but are absent from every `pack-manifests/*.json` `paths` array.
