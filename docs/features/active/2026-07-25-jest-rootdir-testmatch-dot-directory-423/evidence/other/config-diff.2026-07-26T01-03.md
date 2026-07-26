# Config Diff vs Base — testMatch Fix

Timestamp: 2026-07-26T01-03

Task: [P1-T3]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Spec AC: AC1, AC2

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`

Command: `git diff fb483b84 -- jest.config.cjs extensions/drm-copilot/jest.config.cjs`
EXIT_CODE: 0

## Full Diff

```diff
diff --git a/extensions/drm-copilot/jest.config.cjs b/extensions/drm-copilot/jest.config.cjs
index 96603480..a3776653 100644
--- a/extensions/drm-copilot/jest.config.cjs
+++ b/extensions/drm-copilot/jest.config.cjs
@@ -1,7 +1,7 @@
 /** @type {import('jest').Config} */
 module.exports = {
   testEnvironment: "node",
-  testMatch: ["<rootDir>/test/**/*.test.ts"],
+  testMatch: ["**/test/**/*.test.ts"],
   testPathIgnorePatterns: ["/node_modules/", "/out/"],
   moduleFileExtensions: ["ts", "tsx", "js", "jsx", "json", "node"],
   transform: {
diff --git a/jest.config.cjs b/jest.config.cjs
index 30baa154..2f2673af 100644
--- a/jest.config.cjs
+++ b/jest.config.cjs
@@ -2,8 +2,8 @@
 module.exports = {
   testEnvironment: "node",
   testMatch: [
-    "<rootDir>/tests/unit/**/*.test.ts",
-    "<rootDir>/extensions/drm-copilot/test/**/*.test.ts",
+    "**/tests/unit/**/*.test.ts",
+    "**/extensions/drm-copilot/test/**/*.test.ts",
   ],
   testPathIgnorePatterns: ["/node_modules/", "/out/"],
   moduleFileExtensions: ["ts", "tsx", "js", "jsx", "json", "node"],
```

The diff comprises exactly two hunks, one per file, each touching only `testMatch` array elements.
Three lines removed, three lines added. No other line in either file changed.

## AC2 Boundary Verification (unchanged keys)

| Key | Root config | Extension config | Changed? |
|---|---|---|---|
| `roots` | absent (not added) | absent (not added) | No — key never introduced |
| `testPathIgnorePatterns` | `["/node_modules/", "/out/"]` | `["/node_modules/", "/out/"]` | No |
| `moduleFileExtensions` | unchanged | unchanged | No |
| `transform` (ts-jest `tsconfig: "<rootDir>/tsconfig.jest.json"`) | unchanged | unchanged | No |
| `coverageProvider` | unchanged (`"v8"`) | unchanged (`"v8"`) | No |
| `testEnvironment` | unchanged (`"node"`) | unchanged (`"node"`) | No |
| `collectCoverage` | n/a | unchanged (`false`) | No |
| `collectCoverageFrom` | n/a | unchanged (`["src/**/*.ts", "!src/**/*.d.ts"]`) | No |
| `coverageReporters` | n/a | unchanged | No |
| `coverageDirectory` | n/a | unchanged (`"<rootDir>/coverage"`) | No |
| `coverageThreshold` (all per-file entries + comments) | n/a | unchanged | No |
| All comments | n/a | unchanged | No |

The `<rootDir>` token still appears in `transform.tsconfig` and (extension only) `coverageDirectory`.
That is intentional and correct: those `<rootDir>` uses resolve via literal-path mechanisms, not via
glob compilation, and are unaffected by the defect (spec "Scope & Non-Goals" and "Boundaries and
invariants to preserve").

## AC1 Shape Verification (loaded config objects)

Command: `node -e "..."` requiring both config modules and inspecting the exported `testMatch`.
EXIT_CODE: 0

```
root.testMatch ["**/tests/unit/**/*.test.ts","**/extensions/drm-copilot/test/**/*.test.ts"]
  isString: true | hasRootDir: false | hasBackslash: false | startsWithGlobstar: true
  isString: true | hasRootDir: false | hasBackslash: false | startsWithGlobstar: true
ext.testMatch ["**/test/**/*.test.ts"]
  isString: true | hasRootDir: false | hasBackslash: false | startsWithGlobstar: true
root.roots: undefined | ext.roots: undefined
root.passWithNoTests: undefined | ext.passWithNoTests: undefined
```

- Root `testMatch` equals exactly
  `["**/tests/unit/**/*.test.ts", "**/extensions/drm-copilot/test/**/*.test.ts"]`.
- Extension `testMatch` equals exactly `["**/test/**/*.test.ts"]`.
- Every entry in both files: is a string, contains no `<rootDir>`, contains no backslash, starts
  with `**/`.
- `roots` is `undefined` in both configs, confirming no `roots` key was introduced.
- `passWithNoTests` is `undefined` (strictly falsy) in both configs.

Output Summary: PASS. The diff against base `fb483b84` shows only the `testMatch` value change in
each config — two hunks, three lines replaced. No `roots` key added; `testPathIgnorePatterns`,
`collectCoverageFrom`, `coverageThreshold`, `coverageDirectory`, and the ts-jest `tsconfig`
references are byte-identical to base. Both loaded config objects export the exact specified
`testMatch` arrays and satisfy the four-part shape contract. AC1 and AC2 satisfied.
