# Baseline — TypeScript Toolchain Suites — [P0-T10]

Timestamp: 2026-08-23T00-52

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P0-T10]
State captured: PRE-CHANGE baseline

Working directory for all four npm commands: `extensions/drm-copilot`.

## Before snapshot, verbatim

Command: `git status --porcelain -- extensions/drm-copilot`

```text
```

Empty. Recorded verbatim as an empty block per the acceptance requirement.

## Command 1 — format

Command: `npm run format`

EXIT_CODE: 0

Output Summary: Prettier reported every file it visited as `(unchanged)`. The tail of the output,
which covers the extension-root files the format glob also visits, was:

```text
package-lock.json 31ms (unchanged)
package.json 2ms (unchanged)
tsconfig.jest.json 1ms (unchanged)
tsconfig.json 1ms (unchanged)
esbuild-extension.cjs 5ms (unchanged)
esbuild-mcp-server.cjs 2ms (unchanged)
jest.config.cjs 4ms (unchanged)
run-jest.cjs 3ms (unchanged)
```

## Command 2 — lint

Command: `npm run lint`

EXIT_CODE: 0

Output Summary: `eslint --no-error-on-unmatched-pattern src test` produced no diagnostic output,
which is ESLint's clean result. ESLint is invoked with no fix flag and the repository ESLint
configuration sets none, so this stage is read-only.

## Command 3 — typecheck

Command: `npm run typecheck`

EXIT_CODE: 0

Output Summary: `tsc -p ./ --noEmit` produced no diagnostic output. Zero type errors.

## Command 4 — test

Command: `npm test`

EXIT_CODE: 0

Output Summary:

```text
Test Suites: 195 passed, 195 total
Tests:       2654 passed, 2654 total
Snapshots:   0 total
Time:        4.503 s
```

| Metric | Count |
| --- | --- |
| suites passed | 195 |
| suites failed | 0 |
| tests passed | 2654 |
| tests failed | 0 |

## After snapshot, verbatim

Command: `git status --porcelain -- extensions/drm-copilot`

```text
```

Empty, and therefore byte-identical to the before snapshot. The tree carried no pre-existing
formatting drift and the write-mode `format` command rewrote nothing.

## Why the snapshot pair is captured at baseline

The `format` script is a write-mode Prettier invocation. Prettier exits 0 whether or not it
rewrites a file. Capturing the pair here — rather than only at the [P8-T10] gate — makes the
baseline and the gate observe the same quantity by the same method, so the two are comparable.
This task carries no threshold: differing snapshots would be recorded as pre-existing drift for
the operator, not treated as a failure. They did not differ.

## Pack-manifest-completeness suite, pre-change green state

The acceptance requires this suite's pre-change state specifically, because [P4-T3] adds an entry
to the bundled pack manifest and this suite is what proves the manifest stays complete.

Command: `npm test -- test/lib/push-down/claude-pack-manifest-completeness.test.ts`

EXIT_CODE: 0

```text
Test Suites: 1 passed, 1 total
Tests:       15 passed, 15 total
Snapshots:   0 total
Time:        0.349 s, estimated 1 s
```

The suite is green pre-change: 1 suite, 15 tests, 0 failures.

## Output Summary

All four npm commands exited 0. Aggregate pass count 2654 across 195 suites; aggregate fail count
0. The before and after snapshots are both empty and byte-identical. The
pack-manifest-completeness suite is green pre-change at 15 passing tests.
