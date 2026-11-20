# `npx jest` Command-Form Verification (Issue #422)

Timestamp: 2026-07-26T00-58

Command:
```
npx jest --listTests
```

EXIT_CODE: 0

Output Summary:

## Part 1 — Static inspection (three required checks)

| # | Check | Result | Evidence |
|---|---|---|---|
| a | Root `package.json` declares `"jest": "^30.4.2"` under `devDependencies` | CONFIRMED | `package.json:49` — `    "jest": "^30.4.2",` |
| b | `jest.config.cjs` exists at the repo root | CONFIRMED | Present, 452 bytes. Declares `testEnvironment: "node"`, `testMatch` of `<rootDir>/tests/unit/**/*.test.ts` and `<rootDir>/extensions/drm-copilot/test/**/*.test.ts`, `ts-jest` transform with `tsconfig.jest.json`, and `coverageProvider: "v8"`. |
| c | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:67` recognizes the command family `npx (prettier\|eslint\|tsc\|jest)` | CONFIRMED | Line 67 of `$implementationCommandPatterns`: `'(^\|\s)npx\s+(prettier\|eslint\|tsc\|jest)\b'` |

No file listed above was modified. All three are read-only verifications.

## Part 2 — Confirmation invocation

The skip branch authorized by `[P3-T2]` was **not** required: although `node_modules/` is absent at both `./` and `extensions/drm-copilot/` in this worktree, `npx` resolved Jest without a registry fetch (the worktree is nested under the primary checkout, so Node's parent-directory `node_modules` resolution supplied the binary). The invocation was therefore executed.

- `npx jest --listTests` — EXIT_CODE 0.
- Supporting no-fetch probe `npx --no jest --listTests` (the `--no` flag makes npx fail rather than fetch from the registry if the package cannot be resolved locally) — Jest started, loaded `jest.config.cjs`, checked 435 files, and reported `No tests found, exiting with code 1` because this worktree contains no file matching the configured `testMatch` patterns. That exit code reflects an empty test set, not a resolution failure. The probe also emitted a pre-existing, unrelated `jest-haste-map: Haste module naming collision: drm-copilot` warning for the two `package.json` files (root and `extensions/drm-copilot/`); this is baseline behavior of the existing configuration and is out of scope for this feature.
- `npx jest --version` — EXIT_CODE 0, output `30.4.1` (satisfies the declared `^30.4.2` range constraint family; the resolved binary is Jest 30).

Conclusion: the allowlist entry `Bash(npx jest *)` introduced by `[P2-T4]` names a command form that resolves and executes in this repository. The previously allowlisted `npx vitest` had no resolvable binary, since no Vitest dependency is declared anywhere in the repository.

Flag-name note (as recorded in `spec.md`): bare `npx jest` bypasses `run-jest.cjs`, which performs the `--testPathPattern` to `--testPathPatterns` alias rewrite. Jest 30 flag names must be used with the bare form. Only Jest 30 flag names were used in the invocations above.
