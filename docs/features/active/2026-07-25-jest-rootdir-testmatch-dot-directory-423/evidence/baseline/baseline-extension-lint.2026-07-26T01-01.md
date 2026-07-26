# Baseline — Extension Lint

Timestamp: 2026-07-26T01-01

Task: [P0-T10]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`

Command: `npm --prefix extensions/drm-copilot run lint`
Resolved script: `eslint --no-error-on-unmatched-pattern src test`
EXIT_CODE: 0

## Full Output

```
> drm-copilot@1.0.19 lint
> eslint --no-error-on-unmatched-pattern src test

EXIT_CODE=0
```

No diagnostics emitted (empty output, exit 0).

## Note on ESLint Scope (relevant to [P3-T2])

Extension ESLint lints `src` and `test`. The new regression test file
`extensions/drm-copilot/test/jest-config-resolution.test.ts` created in [P3-T2] therefore falls
inside this gate. That test must `require("../jest.config.cjs")` to obtain the CommonJS config
object, which trips `@typescript-eslint/no-require-imports` (enabled in this package's eslint
configuration, unlike the root configuration).

The repository's established remedy is the pre-authorized single-line suppression pattern from
`.claude/rules/typescript-suppressions.md`:
`// eslint-disable-next-line @typescript-eslint/no-require-imports -- <reason>`. Existing precedent
in this package: `extensions/drm-copilot/test/extension-test-harness.ts:193` and
`extensions/drm-copilot/test/runtime-test-helpers.ts:86,99`.

Output Summary: PASS. `npm --prefix extensions/drm-copilot run lint` exits 0 with zero diagnostics at
baseline. Clean base confirmed for the extension lint gate.
