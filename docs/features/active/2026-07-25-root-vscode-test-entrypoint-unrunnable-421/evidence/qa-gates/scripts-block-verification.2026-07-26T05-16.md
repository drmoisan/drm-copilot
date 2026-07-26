# QA Gate — Root `package.json` Scripts-Block-Only Verification (#421)

Timestamp: 2026-07-26T05-16

Task: [P1-T6] — AC1 and AC2 evidence.

Command:

```
git diff -- package.json
git diff --stat -- package.json
node -e 'const p=require("./package.json");const hits=Object.entries(p.scripts).filter(([k,v])=>v.includes("vscode-test"));console.log("SCRIPT_KEYS:",Object.keys(p.scripts).join(", "));console.log("VSCODE_TEST_VALUE_MATCHES:",hits.length);console.log(JSON.stringify(hits));'
node -e 'const p=require("./package.json");console.log("test =", JSON.stringify(p.scripts.test)); ...'
```

EXIT_CODE: 0

## 1. Diff Hunk Inventory

```
$ git diff --stat -- package.json
 package.json | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)
```

A single hunk was produced, with header:

```
@@ -26,17 +26,15 @@
   "scripts": {
```

Line 26 of the pre-change file is the `"scripts": {` key. The hunk spans 17 pre-change lines from line 26, i.e. lines 26–42, and the pre-change `"scripts"` object occupied lines 26–40 with `"devDependencies"` beginning at line 41. Every changed line in the hunk lies strictly between the `"scripts": {` opening and its closing `},`; the trailing context lines (`},`, `"devDependencies": {`, `"@jest/globals": "^30.4.1",`) are unmodified context, shown by the diff for anchoring only.

### Changed lines, classified

| Change | Line content (abbreviated) | Inside `scripts` object? |
|---|---|---|
| Removed | `"compile:integration-tests": "node -e \"...\""` | Yes |
| Removed | `"format": "... \".vscode-test.mjs\" ..."` | Yes |
| Removed | `"format:check": "... \".vscode-test.mjs\" ..."` | Yes |
| Removed | `"pretest": "npm run compile && npm run compile:integration-tests && npm run lint"` | Yes |
| Removed | `"test:integration": "vscode-test"` | Yes |
| Removed | `"test": "vscode-test"` | Yes |
| Added | `"format": "... (no .vscode-test.mjs) ..."` | Yes |
| Added | `"format:check": "... (no .vscode-test.mjs) ..."` | Yes |
| Added | `"pretest": "npm run compile && npm run lint"` | Yes |
| Added | `"test": "node run-jest.cjs"` | Yes |

**All 10 changed lines lie inside the `scripts` object.** Zero changed lines touch `name`, `publisher`, `displayName`, `description`, `version`, `engines`, `overrides`, `devDependencies`, or `dependencies`.

## 2. Zero-Match Grep of Script Values (AC2)

```
$ node -e 'const p=require("./package.json");const hits=Object.entries(p.scripts).filter(([k,v])=>v.includes("vscode-test"));...'
SCRIPT_KEYS: vscode:prepublish, compile, typecheck, watch, format, format:check, pretest, lint, test:unit, test:unit:coverage, test
VSCODE_TEST_VALUE_MATCHES: 0
[]
```

**Zero matches.** No root npm script *value* contains the substring `vscode-test`.

Note on the `vscode:prepublish` key: the key name contains `vscode` but not `vscode-test`; its value is `npm run compile`, which contains no `vscode-test` substring. AC2 constrains script values for the string `vscode-test`; this key is out of scope for this fix (root extension-manifest vestiges are an explicit non-goal per the spec's Scope & Non-Goals, owned by a sibling orchestration).

## 3. Per-Condition Assertions (AC1)

```
$ node -e '...'
test = "node run-jest.cjs"
pretest = "npm run compile && npm run lint"
has test:integration: false
has compile:integration-tests: false
format has .vscode-test.mjs: false
format:check has .vscode-test.mjs: false
```

| AC1 condition | Required | Observed | Verdict |
|---|---|---|---|
| `scripts.test` | `node run-jest.cjs` | `node run-jest.cjs` | PASS |
| `scripts.pretest` | `npm run compile && npm run lint` | `npm run compile && npm run lint` | PASS |
| `scripts.test:integration` | absent | absent | PASS |
| `scripts.compile:integration-tests` | absent | absent | PASS |
| `scripts.format` contains `.vscode-test.mjs` | false | false | PASS |
| `scripts.format:check` contains `.vscode-test.mjs` | false | false | PASS |

## 4. Forbidden-File Boundary

`package-lock.json` was not touched by any Phase 1 task; the boundary is re-verified comprehensively in [P4-T7].

Output Summary: `git diff -- package.json` produced exactly one hunk (`@@ -26,17 +26,15 @@`, 4 insertions / 6 deletions), and all 10 changed lines lie inside the `scripts` object — no `devDependencies`, `dependencies`, `overrides`, or manifest field changed. A programmatic search of all 11 root script values for the substring `vscode-test` returned **0 matches**. All six AC1 conditions verified individually: `test` == `node run-jest.cjs`, `pretest` == `npm run compile && npm run lint`, `test:integration` and `compile:integration-tests` absent, and neither `format` nor `format:check` contains `.vscode-test.mjs`. AC1 and AC2 evidence established.
