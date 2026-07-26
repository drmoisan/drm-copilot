# jest-rootdir-testmatch-dot-directory (Issue #423)

- Date captured: 2026-07-25
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/jest-rootdir-testmatch-dot-directory/ (Issue #423)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #423
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/423
- Last Updated: 2026-07-26
- Work Mode: full-bug

## Summary

On Windows, Jest discovers zero test files when the repository is checked out under a path containing a dot-prefixed directory segment (for example `.claude/worktrees/<name>/`). Both Jest projects in this repository are affected: the root `jest.config.cjs` and `extensions/drm-copilot/jest.config.cjs`. Each interpolates `<rootDir>` into `testMatch`, and Jest's separator normalization leaves the `\` before the dot segment intact, where picomatch then consumes it as a glob escape rather than a path separator.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Node version: v24.14.0
- Jest version: 30.4.2 (root and `extensions/drm-copilot`)
- Command/flags used: `node run-jest.cjs` (root), `npm --prefix extensions/drm-copilot run test`
- Checkout path: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`

## Steps to Reproduce

1. Check out the repository on Windows at a path containing a dot-prefixed directory segment, for example `C:\Users\<user>\repos\drm-copilot\.claude\worktrees\<name>`.
2. Run `npm ci` at the repository root and `npm --prefix extensions/drm-copilot ci`.
3. Run `node run-jest.cjs` at the repository root.
4. Run `npm --prefix extensions/drm-copilot run test`.

## Expected Behavior

Jest discovers and executes the test files matched by `testMatch` (`tests/unit/**/*.test.ts` and `extensions/drm-copilot/test/**/*.test.ts`), independently of whether the checkout path contains a dot-prefixed directory segment.

## Actual Behavior

Both runs report zero discovered tests:

```
No tests found, exiting with code 1
Run with `--passWithNoTests` to exit with code 0
In C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f
  434 files checked.
  testMatch: C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a08c9cf1932159e8f/tests/unit/**/*.test.ts, ... - 0 matches
```

Note the literal backslash retained in `drm-copilot\.claude` while every other separator in the same pattern was converted to a forward slash.

## Logs / Screenshots

- [x] Attached minimal logs
- Snippet: see Actual Behavior above; identical failure reproduced for `extensions/drm-copilot` with `368 files checked` and `0 matches`.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Zero test discovery is reported as a distinct outcome rather than a test failure. Any agent or developer working in a `.claude/worktrees/**` checkout receives no test signal at all, and the message is easily mistaken for "nothing to run". Adding `--passWithNoTests` anywhere in the invocation chain would convert this into a true false-green.

## Suspected Cause / Notes

Root cause confirmed experimentally (not inferred):

1. `jest.config.cjs` interpolates `<rootDir>` into `testMatch`, producing an absolute Windows path inside a glob pattern.
2. `jest-util`'s `replacePathSepForGlob` normalizes separators with `path.replaceAll(/\\(?![$()+.?^{}])/g, '/')`. The negative lookahead intentionally preserves a backslash that precedes a glob metacharacter so that pre-escaped metacharacters survive normalization.
3. A dot-prefixed directory segment yields the byte pair `\.` in the Windows path. That pair is protected by the lookahead, so the separator is **not** converted to `/`.
4. picomatch then reads `\.` as an escaped literal dot rather than a path separator. The pattern `.../drm-copilot\.claude/...` matches the literal text `drm-copilot.claude/...`, which no real path produces.
5. Result: `testMatch` yields 0 matches and Jest reports "No tests found".

Refuted hypothesis: this is **not** micromatch/picomatch `dot: false` behaviour. Verified in-process that `globsToMatcher(["**/tests/unit/**/*.test.ts"])` returns `true` for `C:\Users\x\repo\.claude\wt\a\tests\unit\a.test.ts` under default options — a dot-prefixed segment matches fine when the separator survives as `/`. Jest 30 uses picomatch, not micromatch; the repository has no `micromatch` install.

Confirming probe results (run in-process against the installed Jest 30.4.2):

- `readConfig(...).projectConfig.testMatch[0]` = `C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-.../tests/unit/**/*.test.ts`
- `globsToMatcher(testMatch)(<real test file path>)` = `false`
- `picomatch("C:/Users/x/repo\\.claude/wt/a/tests/unit/**/*.test.ts")("C:/Users/x/repo.claude/wt/a/tests/unit/a.test.ts")` = `true` — proving the backslash is consumed as an escape, not treated as a separator.
- Neither `dot: true`, `windows: false`, nor `returnState` changes the outcome.

Files to inspect: `jest.config.cjs`, `run-jest.cjs`, `extensions/drm-copilot/jest.config.cjs`, `extensions/drm-copilot/run-jest.cjs`.

## Proposed Fix / Validation Ideas

- [ ] Remove `<rootDir>` interpolation from `testMatch` so no absolute host path enters the glob; rely on `roots` (which Jest matches as real paths, not globs) plus relative patterns.
- [ ] Make zero discovered tests loud rather than silent, so the condition can never be read as success.
- [ ] Unit coverage areas: assert on the **resolved** Jest configuration (via `jest-config`'s `readConfig` and `jest-util`'s `globsToMatcher`) that a representative test path under a simulated dot-prefixed root is matched. Repository policy prohibits creating temporary files or directories in tests, so the regression test must assert on configuration resolution and matcher behaviour rather than materialising a dot-prefixed checkout.
- [ ] Integration scenario to retest: run both Jest projects from a `.claude/worktrees/**` checkout and confirm non-zero test counts.
- [ ] Manual verification notes: compare discovered test counts between a dot-prefixed and a non-dot checkout.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
