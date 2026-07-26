# Final QC — Root Typecheck

Timestamp: 2026-07-26T01-19

Task: [P4-T3]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Spec AC: AC15
QC Loop Pass: 1 (single clean pass; no restart required)

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`

Command: `npm run typecheck`
Resolved script: a `node -e` wrapper that scans `src/` and `tests/` for `.ts` files, then spawns
`typescript/bin/tsc -p ./ --noEmit`.
EXIT_CODE: 0

## Full Output

```
> drm-copilot@1.0.0 typecheck
> node -e "...resolveTool('typescript/bin/tsc'); spawnSync(node, [tsc, '-p', './', '--noEmit'])..."

EXIT_CODE=0
```

`tsc` emitted zero diagnostics. The wrapper did not print
`Skipping typecheck: no TypeScript sources found under src/ or tests/.`, confirming TypeScript
sources were detected and `tsc -p ./ --noEmit` actually ran.

## In-Scope Coverage

Root `tsconfig.json` sets `include: ["src/**/*.ts", "tests/**/*.ts"]`, so the new
`tests/unit/jest-config-resolution.test.ts` ([P3-T1]) is inside this gate. It type-checks clean under
the project's strict settings without any `tsconfig` modification — `tsconfig*.json` is on the
FORBIDDEN list and was not touched.

Strict options the new test satisfies:

- `strict: true` and `noUncheckedIndexedAccess: true` — indexing `config.testMatch[index]` yields
  `string | undefined`, which the `patternAt(index)` helper narrows with an explicit `undefined`
  check that throws a descriptive error rather than asserting non-null.
- `noUnusedLocals` / `noUnusedParameters` — no unused declaration remains in the file.
- `exactOptionalPropertyTypes` — the `JestConfigUnderTest` interface declares
  `passWithNoTests?: unknown`, compatible with the config object's absent key.
- `types: ["node"]` — supplies the `require` global used to load the CommonJS config module.

`jest-util` ships its own TypeScript declarations
(`node_modules/jest-util/build/index.d.ts`, exporting
`globsToMatcher(globs: Array<string>, picomatchOptions?: picomatch.PicomatchOptions): Matcher`), so
the `import { globsToMatcher } from "jest-util"` resolves under `tsc` with no added `@types` package
and no `package.json` edit. This confirms the accepted residual risk recorded in `spec.md` (item 4
under Risks) does not manifest at type-check time.

Output Summary: PASS. `npm run typecheck` exits 0 with zero TypeScript diagnostics. The new root
regression test compiles clean under the existing strict configuration, including
`noUncheckedIndexedAccess` and `exactOptionalPropertyTypes`, with no tsconfig change. No loop restart
triggered.
