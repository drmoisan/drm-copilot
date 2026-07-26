# In-Process Spot Check — readConfig + globsToMatcher

Timestamp: 2026-07-26T01-16

Task: [P3-T6]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Source: research Q2 script (creates no files)

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`

Command:
```
node -e "const {readConfig}=require('jest-config');const {globsToMatcher}=require('jest-util');(async()=>{const {projectConfig}=await readConfig({ _: [], \$0: 'jest' }, process.cwd());console.log('projectConfig.testMatch:', JSON.stringify(projectConfig.testMatch));const real=require('node:path').join(process.cwd(),'tests','unit','hello-typescript.test.ts');console.log('real path:', real);console.log('matcher result:', globsToMatcher(projectConfig.testMatch)(real));})();"
```
EXIT_CODE: 0

## Full Output

```
projectConfig.testMatch: ["**/tests/unit/**/*.test.ts","**/extensions/drm-copilot/test/**/*.test.ts"]
real path: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f\tests\unit\hello-typescript.test.ts
matcher result: true
```

## Verification

| Acceptance condition | Observed | Verdict |
|---|---|---|
| `projectConfig.testMatch` equals `["**/tests/unit/**/*.test.ts", "**/extensions/drm-copilot/test/**/*.test.ts"]` | Exactly that array | PASS |
| Matcher returns `true` for this worktree's real dot-prefixed `tests\unit\hello-typescript.test.ts` path | `true` | PASS |

## Significance

This check probes Jest's own configuration-resolution pipeline rather than the raw config module, so
it verifies the property the regression tests cannot: that `readConfig` passes the patterns through
**unmodified**.

Comparison against the pre-fix probe recorded in `spec.md` → "Confirming probe results":

| | Pre-fix (spec.md) | Post-fix (this run) |
|---|---|---|
| `projectConfig.testMatch[0]` | `C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-.../tests/unit/**/*.test.ts` | `**/tests/unit/**/*.test.ts` |
| `globsToMatcher(testMatch)(<real test file path>)` | `false` | `true` |

The pre-fix value shows the absolute host path with the retained `\.claude` byte pair produced by
`<rootDir>` interpolation followed by `replacePathSepForGlob`. The post-fix value is the literal
relative pattern from `jest.config.cjs`, byte-for-byte: because the entry does not begin with
`<rootDir>`, it bypasses `replaceRootDirInPath` entirely, and because it contains no backslash,
`replacePathSepForGlob` has nothing to rewrite. No host path ever reaches picomatch as a glob.

The matcher result of `true` is against the **real** absolute path of an actual file in this
dot-prefixed worktree (`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f\tests\unit\hello-typescript.test.ts`),
not a synthetic fixture. The candidate path still carries the `\.claude` segment; the leading `**/`
globstar consumes it under picomatch's `dot: true` default, exactly as the accepted design predicted.

Output Summary: PASS. `readConfig` resolves `projectConfig.testMatch` to exactly
`["**/tests/unit/**/*.test.ts", "**/extensions/drm-copilot/test/**/*.test.ts"]` — the patterns pass
through Jest's configuration pipeline unmodified, with no `<rootDir>` interpolation and no separator
rewriting. `globsToMatcher(projectConfig.testMatch)` returns `true` for this worktree's real
dot-prefixed `tests\unit\hello-typescript.test.ts` path, inverting the pre-fix `false`. Exit code 0;
no files created.
