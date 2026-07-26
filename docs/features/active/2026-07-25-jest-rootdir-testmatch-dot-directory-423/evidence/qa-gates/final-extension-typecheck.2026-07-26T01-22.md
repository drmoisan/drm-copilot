# Final QC — Extension Typecheck

Timestamp: 2026-07-26T01-22

Task: [P4-T7]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Spec AC: AC16
QC Loop Pass: 1 (single clean pass; no restart required)

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`

Command: `npm --prefix extensions/drm-copilot run typecheck`
Resolved script: `tsc -p ./ --noEmit`
EXIT_CODE: 0

## Full Output

```
> drm-copilot@1.0.19 typecheck
> tsc -p ./ --noEmit

EXIT_CODE=0
```

Zero TypeScript diagnostics.

## Type-Check Coverage of the New Test File

`extensions/drm-copilot/tsconfig.json` sets `include: ["src/**/*.ts"]`, so this `tsc -p ./` gate
compiles production sources only and does **not** include `test/**`. The new
`extensions/drm-copilot/test/jest-config-resolution.test.ts` is therefore type-checked by a different
mechanism, and its type correctness is not left unverified:

1. **ts-jest under `tsconfig.jest.json`** — the extension Jest config's `transform` entry is
   `["ts-jest", { tsconfig: "<rootDir>/tsconfig.jest.json" }]`, and `tsconfig.jest.json` extends
   `tsconfig.json` with `include: ["src/**/*.ts", "test/**/*.ts"]`, `rootDir: "."`,
   `isolatedModules: true`, and `types: ["node", "jest"]`. ts-jest type-checks the file on every
   test run, so the green [P4-T8] and [P4-T9] runs are type-check evidence for it.
2. **Root `tsc -p ./ --noEmit`** — the root `tsconfig.json` sets
   `include: ["src/**/*.ts", "tests/**/*.ts"]`, which covers the root test file but not the
   extension one; the root Jest project transforms the extension test file through root
   `tsconfig.jest.json` at run time ([P4-T4], green).

The file inherits the same strict settings as production code through the `extends` chain, including
`strict`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, `noUnusedLocals`, and
`noPropertyAccessFromIndexSignature`. The `patternAt(index)` helper handles the
`string | undefined` result of indexing `config.testMatch` with an explicit check rather than a
non-null assertion.

`jest-util` ships its own declarations in the extension package's dependency tree
(`extensions/drm-copilot/node_modules/jest-util/build/index.d.ts`), so
`import { globsToMatcher } from "jest-util"` resolves without any `package.json` or `tsconfig`
change — both of which are on the FORBIDDEN list.

No `tsconfig*.json` was modified by this feature; the scope check in [P4-T11] confirms it.

Output Summary: PASS. `npm --prefix extensions/drm-copilot run typecheck` exits 0 with zero
TypeScript diagnostics for the production `src/**` project. The new test file, which lies outside
this project's `include`, is type-checked by ts-jest under `tsconfig.jest.json` on every test run and
passed there ([P4-T8], [P4-T9] both green). No loop restart triggered.
