# Fail-Before — Slug Resolver Suite ([P1-T1]) [expect-fail]

Timestamp: 2026-08-25T09-33

Command: npm --prefix extensions/drm-copilot run test -- potential-to-issue/repo-slug

ExpectedExitCode: 1

EXIT_CODE: 1

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a38eff9588c69b6ec`
Branch: `bug/potential-to-issue-ignores-workspace-root-when-creating-the-issue-525`
Test file created by this task: `extensions/drm-copilot/test/lib/potential-to-issue/repo-slug.test.ts`
Test name: `returns the nameWithOwner slug and runs with cwd set to the workspace root`

## Output Summary

The suite failed to run. **The failure is existence-level, not assertion-level.** Jest could not
resolve the module under test, so no test executed and the assertions in the file were never
evaluated.

Unresolved-module diagnostic emitted by Jest:

```
FAIL test/lib/potential-to-issue/repo-slug.test.ts
  ● Test suite failed to run

    Cannot find module '../../../src/lib/potential-to-issue/repo-slug' from 'test/lib/potential-to-issue/repo-slug.test.ts'

      at Resolver._throwModNotFoundError (node_modules/jest-resolve/build/index.js:895:11)
      at Object.<anonymous> (test/lib/potential-to-issue/repo-slug.test.ts:8:1)
```

Counts reported by the run:

- Test Suites: 1 failed, 1 total
- Tests: 0 total

The diagnostic points at line 8 of the test file, which is the
`import { resolveRepoSlug } from "../../../src/lib/potential-to-issue/repo-slug";` statement. The
production module `extensions/drm-copilot/src/lib/potential-to-issue/repo-slug.ts` does not exist
yet; it is created by [P2-T1].

## Why This Fail-Before Is Existence-Level

The plan states this explicitly at [P1-T1]: a module that does not yet exist cannot produce a
value-level failure, because no code from it runs. `Tests: 0 total` is the machine-readable proof
that no assertion was evaluated. This is deliberately weaker than the value-level fail-before carried
by [P1-T3] and [P1-T4], where the module under test does exist, its code does run, and a specific
assertion compares two values and fails.

Per Settled Design Decision 6, the failure is not a compile diagnostic:
`extensions/drm-copilot/tsconfig.jest.json` sets `"isolatedModules": true`, so ts-jest transpiles
without type checking. The failure is Jest's runtime module resolver, not the TypeScript compiler.

## Exit-Code Capture Method

The command's stdout and stderr were redirected to a file and the exit code was echoed in the same
shell invocation immediately afterwards. The command was not piped into another process, so the
recorded status is the status of the test command itself and not of a downstream process.
