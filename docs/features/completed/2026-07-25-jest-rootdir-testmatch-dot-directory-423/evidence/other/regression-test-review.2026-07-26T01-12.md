# Regression Test Review — AC11 through AC14

Timestamp: 2026-07-26T01-12

Task: [P3-T3]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Spec AC: AC11, AC12, AC13, AC14

## Files Reviewed

| File | Lines | Under 500-line limit |
|---|---|---|
| `tests/unit/jest-config-resolution.test.ts` | 191 | Yes |
| `extensions/drm-copilot/test/jest-config-resolution.test.ts` | 164 | Yes |

Both files live in the mandated test tree locations (`tests/` for the root package, `test/` for the
extension package) and are not colocated with production source, per
`.claude/rules/general-unit-test.md` → "Test File Location".

---

## AC11 — Each configured pattern individually asserted: **PASS**

Requirement: each configured `testMatch` pattern must be asserted individually via
`globsToMatcher([pattern])`, so a partial collapse of one pattern to zero matches fails the test.

### `tests/unit/jest-config-resolution.test.ts` (2 configured patterns)

The accessor `patternAt(index)` (line 51) reads one pattern at a time from `config.testMatch` and
throws a descriptive error if the index is absent. Every matcher is built from a **single-element**
array — never from the full `config.testMatch` array — so no pattern can be masked by a sibling.

| Group | Pattern index | Call site | Line |
|---|---|---|---|
| 2 (Windows) | `UNIT_PATTERN_INDEX` (0) | `globsToMatcher([patternAt(UNIT_PATTERN_INDEX)])` | 133 |
| 2 (Windows) | `EXTENSION_PATTERN_INDEX` (1) | `globsToMatcher([patternAt(EXTENSION_PATTERN_INDEX)])` | 139 |
| 3 (POSIX) | `UNIT_PATTERN_INDEX` (0) | `globsToMatcher([patternAt(UNIT_PATTERN_INDEX)])` | 147 |
| 3 (POSIX) | `EXTENSION_PATTERN_INDEX` (1) | `globsToMatcher([patternAt(EXTENSION_PATTERN_INDEX)])` | 153 |
| 5 (negative) | `UNIT_PATTERN_INDEX` (0) | `globsToMatcher([patternAt(UNIT_PATTERN_INDEX)])` | 169 |
| 5 (negative) | `EXTENSION_PATTERN_INDEX` (1) | `globsToMatcher([patternAt(EXTENSION_PATTERN_INDEX)])` | 175 |

Both root patterns are covered separately in the Windows positive case, the POSIX positive case, and
the negative case — six independent single-pattern matchers. A regression collapsing only
`**/extensions/drm-copilot/test/**/*.test.ts` while leaving `**/tests/unit/**/*.test.ts` intact fails
the tests at lines 139 and 153.

### `extensions/drm-copilot/test/jest-config-resolution.test.ts` (1 configured pattern)

Same `patternAt(index)` accessor (line 53), same single-element-array construction, applied to
`TEST_PATTERN_INDEX` (0) in group 2 (Windows positive), group 3 (POSIX positive), and group 5
(negative). The config declares one pattern; the accessor keeps the assertion style identical to the
root test and remains correct if a pattern is added later.

Additionally, group 1 in both files asserts `config.testMatch` deep-equals the exact expected array
(root line 100, extension line 94), so adding, removing, or reordering a pattern is caught
independently of the matcher assertions.

---

## AC12 — Defect-witness assertion present in both files: **PASS**

Requirement: a hard-coded broken normalized pattern containing the retained `\.` byte pair, asserted
NOT to match the corresponding synthetic test-file path.

| File | Constant | Line | Value | Assertion |
|---|---|---|---|---|
| root | `DEFECTIVE_PATTERN` | 94 | `"C:/Users/x/repos/drm-copilot\\.claude/worktrees/wt-1/tests/unit/**/*.test.ts"` | group 4, line 161: `expect(globsToMatcher([DEFECTIVE_PATTERN])(WINDOWS_UNIT_PATH)).toBe(false)` |
| extension | `DEFECTIVE_PATTERN` | 88 | `"C:/Users/x/repos/drm-copilot\\.claude/worktrees/wt-1/extensions/drm-copilot/test/**/*.test.ts"` | group 4: `expect(globsToMatcher([DEFECTIVE_PATTERN])(WINDOWS_TEST_PATH)).toBe(false)` |

In both cases the source literal `\\.` produces the single retained backslash-dot byte pair at
runtime — exactly the output `replacePathSepForGlob` produced from the pre-fix `<rootDir>`
configuration in this worktree (see `evidence/regression-testing/fail-before-root-jest.*.md`, where
the reported pattern text shows `drm-copilot\.claude`). The pattern is hard-coded rather than derived
from the current config, so it pins picomatch's escaped-dot semantics independently of the fix. A
future Jest change to `replacePathSepForGlob` or to picomatch escape handling flips this assertion to
`true` and fails the suite, forcing re-evaluation of the fix's assumptions. Each defective-pattern
assertion targets the corresponding group-2 path in the same file.

---

## AC13 — Jest + `@jest/globals`, no filesystem access beyond the config `require`: **PASS**

| Sub-requirement | root | extension | Evidence |
|---|---|---|---|
| Uses Jest, not Vitest | PASS | PASS | Line 1 of each file: `import { describe, expect, it } from "@jest/globals";`. No `vitest` import, no `vi.` usage, no `import.meta`. Neither package installs Vitest. |
| No filesystem read/write other than the config `require` | PASS | PASS | A grep of both files for `readFile`, `writeFile`, `mkdir`, `mkdtemp`, `existsSync`, `fs.`, `os.tmpdir`, `spawn`, `exec`, and `require(` returned only two code hits: root line 32 `require("../../jest.config.cjs")` and extension line 37 `require("../jest.config.cjs")`. The remaining hits were prose inside the header comments. Neither file imports `node:fs`, `node:os`, `node:path`, or `node:child_process`. |
| Creates no temporary files or directories | PASS | PASS | No filesystem write API is imported or called (same grep). |
| Does not materialise a dot-prefixed checkout | PASS | PASS | No directory is created. The dot-prefixed paths exist only as string literals. |
| All matcher inputs are synthetic path strings | PASS | PASS | Every matcher argument is one of the module-level `const` string fixtures: root — `WINDOWS_UNIT_PATH`, `WINDOWS_EXTENSION_PATH`, `POSIX_UNIT_PATH`, `POSIX_EXTENSION_PATH`, `WINDOWS_PRODUCTION_PATH`; extension — `WINDOWS_TEST_PATH`, `POSIX_TEST_PATH`, `WINDOWS_PRODUCTION_PATH`. None of these paths exists on disk and none is stat-ed; `globsToMatcher` performs pure string matching. |
| No spawned processes | PASS | PASS | `node:child_process` is not imported; no `spawn`/`exec` call appears (same grep). |
| Deterministic | PASS | PASS | No clock, no RNG, no timers, no environment reads. Inputs are literals and the required config object. Results are byte-identical on Windows and Linux, confirmed by the fact that both the Windows-path and POSIX-path assertions are executed in the same run on this Windows host. |

### Suppression review

The extension file carries one suppression at line 36:

```
// eslint-disable-next-line @typescript-eslint/no-require-imports -- jest.config.cjs is a CommonJS module and is the unit under test here; an ESM import would not load it as the runtime object Jest itself consumes
```

This matches the pre-authorized pattern in `.claude/rules/typescript-suppressions.md`
(`// eslint-disable-next-line <rule-name> -- <reason>`): single rule, single line, with a specific
local reason. It follows established precedent in this package
(`extensions/drm-copilot/test/extension-test-harness.ts:193`,
`extensions/drm-copilot/test/runtime-test-helpers.ts:86` and `:99`). The rule is required because the
extension eslint config composes `tseslint.configs.recommended`, which enables
`@typescript-eslint/no-require-imports`.

The root file needs no suppression: the root `eslint.config.mjs` declares only four rules
(`@typescript-eslint/naming-convention`, `curly`, `eqeqeq`, `no-throw-literal`, `semi`) and does not
compose the recommended preset, so `no-require-imports` is not enabled there. This was confirmed by
the clean root lint result in Phase 4.

No other suppression appears in either file. No `@ts-ignore`, `@ts-nocheck`, or file-level
`eslint-disable` is present.

---

## AC14 — Group-6 loudness config guard present in both files: **PASS**

| File | Assertion | Location |
|---|---|---|
| root | `expect(config.passWithNoTests).toBeFalsy()` | group 6 (describe at line 181) |
| root | `expect(config.testPathIgnorePatterns).toContain("/node_modules/")` and `.toContain("/out/")` | group 6 |
| extension | `expect(config.passWithNoTests).toBeFalsy()` | group 6 (describe at line 154) |
| extension | `expect(config.testPathIgnorePatterns).toContain("/node_modules/")` and `.toContain("/out/")` | group 6 |

`toBeFalsy()` implements the "strictly falsy" requirement: the key is currently absent
(`undefined`), and the assertion fails if anyone later sets `passWithNoTests: true`, closing the
false-green vector at the configuration layer just as the `run-jest.cjs` guard closes it at the CLI
layer. The `testPathIgnorePatterns` assertions pin the two ignore entries that bound the over-match
surface of the new `**/`-anchored patterns.

---

## Assertion Group Coverage Matrix

| Group | Root file | Extension file |
|---|---|---|
| 1 — shape guard (string, no `<rootDir>`, no backslash, leading `**/`, exact array) | PASS (line 98) | PASS (line 92) |
| 2 — per-pattern positive, dot-prefixed Windows | PASS (line 131) | PASS (line 122) |
| 3 — per-pattern positive, POSIX | PASS (line 145) | PASS (line 130) |
| 4 — defect witness | PASS (line 159) | PASS (line 138) |
| 5 — negative flow (production source path) | PASS (line 167) | PASS (line 146) |
| 6 — loudness config guard | PASS (line 181) | PASS (line 154) |

All six groups are present in both files.

## Execution Confirmation

- `node run-jest.cjs tests/unit/jest-config-resolution.test.ts` (repo root): 1 suite passed,
  **14 tests passed**, exit 0.
- `node run-jest.cjs test/jest-config-resolution.test.ts` (from `extensions/drm-copilot/`): 1 suite
  passed, **11 tests passed**, exit 0.

Output Summary: PASS on all four criteria. AC11 — every configured pattern is asserted individually
via single-element `globsToMatcher([pattern])` calls in both files (6 such calls in the root file
covering both patterns across positive-Windows, positive-POSIX, and negative cases). AC12 —
hard-coded `\.`-bearing defective pattern present and asserted false in both files. AC13 — both files
use Jest with `@jest/globals`, touch the filesystem only via the config `require`, create no temp
artifacts, spawn no processes, and use synthetic path strings exclusively; the single suppression is
pre-authorized and precedented. AC14 — group-6 `passWithNoTests` and `testPathIgnorePatterns`
assertions present in both files. Both suites execute green.
