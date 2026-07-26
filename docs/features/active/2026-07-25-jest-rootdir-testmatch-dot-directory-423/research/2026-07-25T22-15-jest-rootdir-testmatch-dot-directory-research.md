# Research: Jest `<rootDir>` testMatch failure under dot-prefixed directories (Issue #423)

- **Issue:** #423
- **Feature:** `docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/`
- **Branch:** `bug/jest-no-tests-found-dot-directory-worktree` (base `origin/main` = `fb483b84`)
- **Date:** 2026-07-25T22-15
- **Researcher:** task-researcher agent

## Current State Analysis

### Affected configurations

| File | testMatch (current, defective) | Other `<rootDir>` uses |
|---|---|---|
| `jest.config.cjs` (root) | `["<rootDir>/tests/unit/**/*.test.ts", "<rootDir>/extensions/drm-copilot/test/**/*.test.ts"]` | ts-jest `tsconfig: "<rootDir>/tsconfig.jest.json"` |
| `extensions/drm-copilot/jest.config.cjs` | `["<rootDir>/test/**/*.test.ts"]` | ts-jest `tsconfig: "<rootDir>/tsconfig.jest.json"`, `coverageDirectory: "<rootDir>/coverage"` |

Both packages install Jest 30 (installed `jest-config` version is `30.4.2`, `node_modules/jest-config/package.json` line 3; `jest-util` depends on `picomatch ^4.0.3`, `node_modules/jest-util/package.json` line 27). Both packages have `jest-config` and `jest-util` physically present in their own `node_modules` trees (verified: `node_modules/jest-{config,util}` and `extensions/drm-copilot/node_modules/jest-{config,util}`).

Test inventories at branch head:
- Root project: 1 test file (`tests/unit/hello-typescript.test.ts`), written with `@jest/globals` imports.
- Extension project: 168 test files under `extensions/drm-copilot/test/**` (glob verified).

Both `run-jest.cjs` copies spawn `jest/bin/jest --config jest.config.cjs` and propagate the child exit code (root via `run-node-tool.cjs`; extension via `cp.spawnSync(...).status ?? 1`). Neither passes `--passWithNoTests`, and neither config sets `passWithNoTests`.

### Root-cause corroboration (independent source reading, installed Jest 30.4.2)

The orchestrator's confirmed root cause is corroborated at every step by the installed sources:

1. **Interpolation.** `jest-config` normalizes `testMatch` as `_replaceRootDirTags(escapeGlobCharacters(options.rootDir), rawValue)` and then maps `replacePathSepForGlob` over the result (`node_modules/jest-config/build/index.js` lines 1863–1874).
2. **Path resolution collapses the escapes.** `escapeGlobCharacters` escapes `!()*?[\]{}` and backslash (line 2820), but `replaceRootDirInPath` then runs `path.resolve(rootDir, path.normalize('./' + suffix))` (lines 2822–2827). On win32 `path.resolve` collapses the doubled backslashes back to single `\` and renders the whole pattern with `\` separators.
3. **Separator normalization protects `\.`.** `jest-util`'s `replacePathSepForGlob` is `path.replaceAll(/\\(?![$()+.?^{}])/g, '/')` (`node_modules/jest-util/build/index.js` lines 999–1001). Every `\` is converted to `/` except one directly followed by a glob metacharacter — including `.`. A dot-prefixed directory segment (`\.claude`) therefore keeps its backslash.
4. **picomatch consumes `\.` as an escape.** `globsToMatcher` compiles each glob with picomatch (`dot: true` default; jest-util lines 616–651) and also passes the candidate path through `replacePathSepForGlob` before matching (line 640). The pattern `.../drm-copilot\.claude/worktrees/...` matches only the literal text `drm-copilot.claude/...`, which no filesystem path produces.
5. **Zero matches → exit 1.** `@jest/core` computes `exitWith0 = passWithNoTests || lastCommit || onlyChanged` (`node_modules/@jest/core/build/index.js` line 2149) and otherwise calls `exit(1)` after printing the no-tests message (line 3487).

The resolved-pattern value recorded in `spec.md` (`C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-.../tests/unit/**/*.test.ts`) is exactly what steps 1–3 produce.

**Refuted hypothesis (recorded per delegation):** this is NOT micromatch/picomatch `dot: false` behavior. Jest 30 uses picomatch (not micromatch), and `globsToMatcher` defaults `dot` to `true` (jest-util line 617). The orchestrator verified in-process that `globsToMatcher(["**/tests/unit/**/*.test.ts"])` returns `true` for `C:\Users\x\repo\.claude\wt\a\tests\unit\a.test.ts` under default options; dot-prefixed segments match when the separator survives as `/`. Neither `dot: true`, `windows: false`, nor `returnState` changes the failing case.

## Q1 — How each configuration option is actually resolved

Read from the installed sources; “glob-interpolated” means the value passes through `replacePathSepForGlob`/picomatch and is therefore vulnerable to the defect.

| Option | Resolution mechanism (source cite) | Glob-interpolated? | Broken here? |
|---|---|---|---|
| `testMatch` | escape + `path.resolve` + `replacePathSepForGlob`, matched by picomatch (jest-config 1863–1874; jest-util 616–651) | Yes | **Yes — sole defect site** |
| `roots` / `modulePaths` | `path.resolve(rootDir, replaceRootDirInPath(...))` (jest-config 1735–1739); consumed as a **regex of literally-escaped paths** via `escapePathForRegex` (@jest/core line 432; jest-regex-util lines 30–43, dots regex-escaped) | No — literal path | No; immune |
| `testPathIgnorePatterns` (and coverage/module/transform/watch ignore patterns) | `<rootDir>` string-substitution + `replacePathSepForRegex`; consumed as RegExp (jest-config 1543–1550; @jest/core 443–448) | No — regex; `.` in a path matches regex `.` | No |
| `coverageDirectory` / `cacheDirectory` | `path.resolve` literal (jest-config 1744–1750) | No | No |
| `collectCoverageFrom` | leading `<rootDir>/` prefix **stripped**, pattern kept relative (jest-config line 1539); matched at runtime against `path.relative(rootDir, filename)` (@jest/transform line 982; @jest/reporters `_addUntestedFiles` line 302 via `hasteFS.matchFilesWithGlob`) | Yes, but against **relative** paths that contain no dot-prefixed worktree segments | No (extension values are already relative `src/**`) |
| `coverageThreshold` keys (extension `./src/...`) | passthrough in jest-config (case group at line 1968); matched in `@jest/reporters` first as a **literal path prefix** after `path.resolve(thresholdGroup)` (`file.indexOf(absoluteThresholdGroup) === 0`, lines 410–420), with a glob fallback that uses `glob.sync(..., { windowsPathsNoEscape: true })` (lines 427–431) | Glob fallback only, and with `windowsPathsNoEscape: true` | No; immune both ways. Caveat: keys resolve against `process.cwd()`, which is correct because both packages are always run with cwd at the package root (`npm --prefix` sets cwd to the prefix for scripts) |
| ts-jest `tsconfig: "<rootDir>/tsconfig.jest.json"` | ts-jest `resolvePath`: `path.resolve(path.join(this.rootDir, path.substr(9)))` (`node_modules/ts-jest/dist/legacy/config/config-set.js` lines 588–590) | No — literal path | No |
| `testRegex` | `replacePathSepForRegex` per pattern (jest-config 1875–1880) | No — regex | n/a (unused) |

**Conclusion:** in both configs, the `testMatch` entries are the only `<rootDir>` interpolations that are glob-matched. Nothing else is affected by the mechanism.

### Candidate fixes

**(a) `roots: ["<rootDir>/tests/unit", ...]` + relative `testMatch`.**
`roots` is verified literal-safe: resolved with `path.resolve` (jest-config 1738) and matched as a regex built with `escapePathForRegex`, which regex-escapes the dot (`\.claude` becomes a correct literal in the regex). So (a) is immune to the defect. However, `roots` also constrains the haste-map crawl, and `hasteFS` is what `CoverageReporter._addUntestedFiles` enumerates when `collectCoverageFrom` is set (@jest/reporters lines 297–306). For the extension config, `roots: ["<rootDir>/test"]` would silently remove every untested `src/**` file from the coverage denominator, weakening the per-file coverage gate without any error. Avoiding that requires `roots: ["<rootDir>/src", "<rootDir>/test"]` — a non-obvious coupling that is easy to regress later.

**(b) Relative `testMatch` patterns with a leading `**/`, no `roots` change.**
A pattern that does not start with `<rootDir>` passes through `replaceRootDirInPath` untouched (jest-config lines 2823–2825) and through `replacePathSepForGlob` as a no-op (no backslashes). At match time the candidate is the absolute native path passed through `replacePathSepForGlob` — it still contains the protected `\.claude` byte pair, but the leading `**/` consumes it: picomatch's globstar matches any characters (including a literal `\`) with `dot: true`. This exact behavior is the orchestrator's recorded in-process probe: `globsToMatcher(["**/tests/unit/**/*.test.ts"])` → `true` for `C:\Users\x\repo\.claude\wt\a\tests\unit\a.test.ts`. No haste-map, coverage, or watch semantics change; the files-checked set is identical. Over-match risk (e.g. a `test/` directory inside `node_modules` or `out/`) is already excluded because the haste map does not retain `node_modules` and `testPathIgnorePatterns` contains `/node_modules/` and `/out/`. A secondary durability benefit: `shouldInstrument` uses `globsToMatcher(config.testMatch)` to exclude test files from coverage instrumentation (@jest/transform line 973); relative patterns keep that exclusion correct in dot-prefixed checkouts too.

**(c) `testPathDirs` / `testRegex`.**
`testPathDirs` was removed; Jest 30 emits a deprecation replacement message “Option "testPathDirs" was replaced by "roots"” (jest-config line 182). Not viable. `testRegex` works mechanically (regex `.` matches the dot; separators handled by `replacePathSepForRegex`) but is mutually exclusive with `testMatch` (jest-config lines 2125–2131), loses the per-pattern stats in the no-tests diagnostic, and departs from the repository’s existing glob convention for no benefit.

**(d) Manually pre-posixified absolute globs** (e.g. `` `${__dirname.replaceAll("\\", "/")}/tests/unit/**/*.test.ts` `` without `<rootDir>`). Works because non-`<rootDir>` strings bypass `replaceRootDirInPath`, but it re-implements Jest’s normalization in config code and breaks if the checkout path ever contains a glob metacharacter (`(`, `)`, `[`, etc.) that Jest’s own `escapeGlobCharacters` would have handled. Less durable than (b).

### Recommendation

**Adopt (b): relative `testMatch` globs with a leading `**/`, no `roots` change.**

- Root `jest.config.cjs`: `testMatch: ["**/tests/unit/**/*.test.ts", "**/extensions/drm-copilot/test/**/*.test.ts"]`
- `extensions/drm-copilot/jest.config.cjs`: `testMatch: ["**/test/**/*.test.ts"]`

Rationale: it is the minimal diff (simplicity-first per `.claude/rules/general-code-change.md`); it removes the absolute-path-into-glob interpolation entirely rather than routing around one symptom; it has zero side effects on coverage enumeration (unlike (a)); it is directly validated by the recorded in-process probe against the installed picomatch/jest-util; and it behaves identically on Windows and POSIX because both the pattern and the normalization applied to it are platform-independent.

**Rejected alternatives (summary):** (a) immune but couples test discovery to the coverage denominator through the haste map — a silent coverage-gate weakening risk in the extension; acceptable only with `src` added to `roots`, which is subtle. (c) `testPathDirs` no longer exists; `testRegex` is a convention change with no added safety. (d) hand-rolled absolute posix globs duplicate Jest’s escaping logic and are fragile against metacharacters in checkout paths.

## Q2 — Verification of the chosen fix

**Execution constraint disclosure:** this researcher agent has no command-execution tool in its toolset (Read/Grep/Glob/WebFetch/Write/Edit only), so it could not itself run the in-process probe. The verification basis is therefore (i) the orchestrator's already-recorded in-process probes (spec.md “Root Cause Analysis”, run against the installed Jest 30.4.2 in this worktree), and (ii) the static source trace above. The decisive recorded probe for fix (b) is:

- `globsToMatcher(["**/tests/unit/**/*.test.ts"])("C:\\Users\\x\\repo\\.claude\\wt\\a\\tests\\unit\\a.test.ts")` → `true` (installed jest-util/picomatch, default options).
- `readConfig(...).projectConfig.testMatch[0]` under the current config → `C:/Users/DanMoisot/...` form with the retained `\.` and `globsToMatcher(testMatch)(<real test file>)` → `false` (fail-before witness).

The executor must re-run the end-to-end confirmation in this worktree during implementation and store it as evidence under `docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/regression-testing/`:

```text
# fail-before (current HEAD):
node run-jest.cjs                              -> "No tests found, exiting with code 1", testMatch 0 matches, 434 files checked
npm --prefix extensions/drm-copilot run test   -> same, 368 files checked

# pass-after (with fix b applied):
node run-jest.cjs                              -> 169 test suites discovered (1 root + 168 extension), exit 0 on pass
npm --prefix extensions/drm-copilot run test   -> 168 test suites discovered, exit 0 on pass
```

In-process spot check the executor can run from the repo root (no files created):

```js
// node -e "<this>"
const { readConfig } = require("jest-config");
const { globsToMatcher } = require("jest-util");
readConfig({ $0: "", _: [] }, process.cwd()).then(({ projectConfig }) => {
  console.log(projectConfig.testMatch); // expect: ["**/tests/unit/**/*.test.ts", "**/extensions/drm-copilot/test/**/*.test.ts"]
  const m = globsToMatcher(projectConfig.testMatch);
  console.log(m(`${process.cwd()}\\tests\\unit\\hello-typescript.test.ts`)); // expect: true
});
```

Note: `readConfig` cannot be pointed at a *simulated* nonexistent dot-prefixed rootDir (`normalizeRootDir` calls `verifyDirectoryExists`, jest-config lines 1562–1578). Running it in this worktree — whose real path contains `\.claude\worktrees\` — is the direct, non-simulated verification. The CI-portable regression tests instead assert at the `globsToMatcher` level with synthetic path strings (Q4), which has no directory-existence requirement.

## Q3 — Loudness: making zero discovered tests impossible to read as success

Evaluated mechanisms:

1. **Jest’s built-in exit code (primary, already in place).** With no tests found, Jest calls `exit(1)` unless `passWithNoTests`, `--lastCommit`, or `--onlyChanged` is in effect (@jest/core lines 2149, 3478–3488). Both `run-jest.cjs` copies propagate the child status. So at the process level, zero discovery already fails — the reproduction in this worktree exits 1. The residual risks are: someone later adds `--passWithNoTests`/`passWithNoTests: true`, or invokes with `--onlyChanged`/`--lastCommit` in CI.
2. **Guard inside `run-jest.cjs` (recommended, in scope).** Add a trivial pre-spawn check in both `run-jest.cjs` files that rejects `--passWithNoTests` (exact-argument match, same style as the existing `--testPathPattern` rewrite) with an actionable message, e.g. `"--passWithNoTests is prohibited in this repository: zero discovered tests must fail (issue #423)."` and `process.exit(1)`. This closes the only switch that converts zero discovery into exit 0 for these entry points. Optionally also reject `--onlyChanged` and `--lastCommit`, which share the `exitWith0` path; they are not used by any repo script or workflow today.
3. **Preflight diagnostic naming resolved rootDir and testMatch (evaluated, not recommended).** A `--listTests` preflight or a `readConfig`-based check would double Jest startup cost on every run while adding little: Jest’s own no-tests message already prints the resolved rootDir, the per-pattern testMatch strings, and per-pattern match counts (see the captured output in `spec.md` — the retained `\.` is visible in that output). The diagnostic quality requirement is already met by Jest itself.
4. **Minimum-expected-test-count assertion (evaluated, not recommended as a runtime gate).** A numeric floor is brittle (changes with every test addition/removal) and duplicates what exit-code enforcement provides for the total. However, the exit code does **not** protect against *partial* collapse: the root config has two testMatch patterns, and if only one regressed to zero matches, the run would still pass. That gap is covered statically by the regression tests (Q4), which assert each configured pattern individually matches a representative synthetic path — not by a runtime count gate.
5. **Config-level assertion (recommended, part of Q4 tests).** Assert `passWithNoTests` is not enabled in either config, so a config-level `passWithNoTests: true` cannot be introduced silently.

**Recommendation:** keep Jest’s built-in `exit(1)` as the enforcement backstop; add the `--passWithNoTests` rejection guard to both `run-jest.cjs` files; add the config-shape and per-pattern matcher assertions to the regression tests. Do not add a runtime preflight or a numeric test-count floor.

Testability note for the guard: `run-jest.cjs` is a spawn-and-exit script; direct unit testing would require spawning it as an external process, which the unit-test policy prohibits for unit tests (`.claude/rules/general-unit-test.md`, “no external processes”). The delegated file-ownership list does not include new helper modules, so the guard must stay inline in `run-jest.cjs`. Keep it to an `if (args.includes("--passWithNoTests"))` check (trivially reviewable); if the implementer wants executable coverage, it must be classed as an integration test (spawning `node run-jest.cjs --passWithNoTests` and asserting exit 1 + message needs no temporary files), which repo policy permits as a category.

## Q4 — Regression coverage design (no temporary files, no materialized dot-prefixed checkout)

### Framework resolution (rule discrepancy)

`.claude/rules/typescript.md` (lines 16, 42) mandates Vitest. Neither package installs Vitest; both install and execute **Jest 30**:

- Root `package.json`: devDependencies `jest ^30.4.2`, `ts-jest ^29.4.11`, `@jest/globals ^30.4.1`; script `test:unit = node run-jest.cjs` (lines 36–37, 42–53).
- `extensions/drm-copilot/package.json`: devDependencies `jest ^30.0.0`, `ts-jest ^29.4.0`, `@jest/globals`, `@types/jest`; scripts `test`/`test:unit` = `node run-jest.cjs` (lines 210–212, 230–238).
- CI executes the extension `test` script (Q5), i.e. Jest.

**Resolution:** the new regression tests must be **Jest** tests using `@jest/globals` imports, matching the 169 existing test files. The Vitest statement in `.claude/rules/typescript.md` does not describe these two packages' actual toolchain; this is recorded as a documentation discrepancy finding. `.claude/rules/**` is out of scope for modification in this feature, so do not edit the rule; a Vitest test would simply never execute here.

### Test file locations

- **Root package:** `tests/unit/jest-config-resolution.test.ts`. The root testMatch (fixed form) discovers only `tests/unit/**`; the mirrored-`tests/` rule places tests for a repo-root production file under `tests/`, and `tests/unit/` is the established root convention (`tests/unit/hello-typescript.test.ts`).
- **Extension package:** `extensions/drm-copilot/test/jest-config-resolution.test.ts`. The extension uses `test/` (singular), a pre-existing package convention required by its own testMatch; all 168 existing extension tests live there. The deviation from the universal `tests/` layout rule is pre-existing and out of scope to change.

Both files are “test files covering Jest configuration resolution” and are inside the delegated ownership scope.

### Modules and assertions

Unit under test: the exported config object (`require("../../jest.config.cjs")` / `require("../jest.config.cjs")`) plus the installed matching pipeline (`globsToMatcher` from `jest-util`). All inputs are synthetic strings — no filesystem access, no temporary files, no directory needs to exist. `globsToMatcher` → `replacePathSepForGlob` → picomatch compilation is pure string processing with no platform branch, so every assertion below is byte-identical on windows-latest and ubuntu-latest (deterministic per policy).

Per config file, assert:

1. **Shape guard (regression tripwire for this defect class).** For every `testMatch` entry: it is a string, contains no `<rootDir>`, contains no `\\`, and starts with `**/`. This fails immediately if absolute-path interpolation is ever reintroduced.
2. **Positive matcher behavior under a synthetic dot-prefixed Windows root.** `globsToMatcher(config.testMatch)` returns `true` for one representative synthetic absolute path **per pattern** (this also closes the partial-collapse gap from Q3 item 4):
   - root pattern 1: `C:\\Users\\x\\repos\\drm-copilot\\.claude\\worktrees\\wt-1\\tests\\unit\\sample.test.ts`
   - root pattern 2: `C:\\Users\\x\\repos\\drm-copilot\\.claude\\worktrees\\wt-1\\extensions\\drm-copilot\\test\\lib\\sample.test.ts`
   - extension pattern: `C:\\Users\\x\\repos\\drm-copilot\\.claude\\worktrees\\wt-1\\extensions\\drm-copilot\\test\\sample.test.ts`
3. **Positive matcher behavior under a POSIX root** (cross-platform safety of the fix): the same matcher returns `true` for `/home/runner/work/drm-copilot/drm-copilot/tests/unit/sample.test.ts` (root) and the analogous extension path.
4. **Defect witness (fail-before semantics without a dot-prefixed checkout).** Hard-code the broken normalized pattern the old config produced (the exact string shape Jest 30.4.2 emits, taken from the recorded probe): `"C:/Users/x/repos/drm-copilot\\.claude/worktrees/wt-1/tests/unit/**/*.test.ts"`, and assert `globsToMatcher([broken])` returns `false` for the matching synthetic file path from item 2. This pins the picomatch escaped-dot semantics; if a future Jest changes `replacePathSepForGlob`, this assertion flags the assumption for re-evaluation.
5. **Negative flow.** The matcher returns `false` for a non-test path (e.g. `...\\src\\extension.ts`) — guards against over-broad patterns.
6. **Loudness config guard.** `config.passWithNoTests` is `undefined` (or strictly falsy) and `config.testPathIgnorePatterns` still contains `"/node_modules/"` and `"/out/"`.

Dependency note: `jest-util` is a transitive dependency of `jest`, physically present at both packages' `node_modules` roots (verified above), and it ships its own TypeScript declarations. Importing it in a test targets the exact contract surface under test. Residual risk: it is not a declared devDependency; declaring it would require `package.json` edits, which are out of scope (root `package.json` explicitly forbidden). Record as accepted residual risk; the import will resolve under `npm ci` in both packages because `jest` requires it.

Fail-before evidence: because these are new tests, run them once against the unfixed configs (only assertion groups 1–2 fail; 4 passes by construction) or rely on the worktree reproduction runs as the failing-run artifact; store under `<FEATURE>/evidence/regression-testing/` per the evidence conventions.

## Q5 — CI exposure

Grep of every `run:` line invoking npm/node under `.github/workflows/`:

- `_drm-copilot-extension-tests.yml` (windows-latest + ubuntu-latest matrix): `npm --prefix extensions/drm-copilot ci` then `npm --prefix extensions/drm-copilot run test` (lines 27, 30). The extension `test` script is `node run-jest.cjs` — Jest, despite the workflow step name mentioning “integration”.
- `publish-extension.yml` (line 37) and `publish-mcp-npm.yml` (line 29) also run `npm --prefix extensions/drm-copilot run test`.
- **No workflow executes the root package's `test:unit`, `node run-jest.cjs` at repo root, or any root-package npm script** (the only root-level npm usage is `npm ci` + `npm audit` in `_npm-audit-gate.yml`).

**Findings:**
- The extension regression test (`extensions/drm-copilot/test/jest-config-resolution.test.ts`) **will** run in CI on both Windows and Linux, on every invocation of the extension-tests workflow and both publish workflows.
- The root regression test (`tests/unit/jest-config-resolution.test.ts`) **will not** run in any CI workflow, because the root package's Jest entry point is not CI-wired. It executes only in local/agent runs of `node run-jest.cjs`. This is an explicit gap finding; per the delegation, no change to root `package.json` or workflows is proposed here (owned by a parallel orchestration).

## Q6 — Cross-platform analysis

- **Defect is Windows-only.** The mechanism requires a `\` before a dot in the interpolated pattern. POSIX rootDirs contain no backslashes; `replacePathSepForGlob` is a no-op; a POSIX dot-directory (`/home/x/.claude/wt/...`) appears in the pattern as the literal segment `/.claude/`, which picomatch matches literally regardless of the `dot` option (the dot restriction applies to wildcard-matched segments, not literals). `escapeGlobCharacters` could still escape `!()*?[]{}` characters in a POSIX path, but the preserved `\` before those characters is the intended pre-escape behavior and CI runner paths (`/home/runner/work/...`) contain none.
- **The fix is safe on Linux/macOS.** Relative `**/`-anchored globs match absolute POSIX inputs (standard picomatch behavior; `dot: true` default covers any dot-prefixed segments in the input). Asserted explicitly by regression-test group 3, which runs identically on both CI OSes because the entire matching pipeline is platform-independent string processing.

## Requirements Mapping (design summary)

| Change | File(s) | Content |
|---|---|---|
| Fix testMatch | `jest.config.cjs` | `testMatch: ["**/tests/unit/**/*.test.ts", "**/extensions/drm-copilot/test/**/*.test.ts"]` |
| Fix testMatch | `extensions/drm-copilot/jest.config.cjs` | `testMatch: ["**/test/**/*.test.ts"]` |
| Loudness guard | `run-jest.cjs`, `extensions/drm-copilot/run-jest.cjs` | reject `--passWithNoTests` (exit 1 with actionable message) before spawning Jest |
| Regression tests | `tests/unit/jest-config-resolution.test.ts`, `extensions/drm-copilot/test/jest-config-resolution.test.ts` | assertion groups 1–6 (Q4), Jest + `@jest/globals` |

Invariants preserved: no `roots` change (coverage denominator untouched); `testPathIgnorePatterns`, `coverageThreshold`, `collectCoverageFrom`, ts-jest `tsconfig` unchanged; no forbidden file touched (root `package.json`, `tsconfig*.json`, `.vscode-test.*`, `.claude/rules/**`, `.agents/skills/**`, `extensions/drm-copilot/resources/claude-customizations/**` all unmodified). The recommended fix requires no forbidden file.

## Automation Feasibility

Every step is automatable with no human interaction:

- Config edits and guard additions: deterministic file edits in-scope.
- Regression tests: pure in-process assertions; no temp files, no processes, no network; deterministic on both CI OSes.
- Fail-before/pass-after verification: `node run-jest.cjs` and `npm --prefix extensions/drm-copilot run test` in this worktree (dependencies already installed); outputs captured to `<FEATURE>/evidence/regression-testing/`.
- CI confirmation: the extension-tests workflow runs automatically on the PR; no manual dispatch required for the extension path. The root-package path has no CI execution (Q5 finding) — verification of it is local-only, still automated.

One limitation to carry forward: this research agent could not execute code (no execution tool), so the Q2 in-process spot check is specified but was not run by the researcher; the executor must run it and record the observed values before and after the fix.

## Open risks / follow-ups (informational, not in scope)

1. Root-package Jest is not CI-wired; the root regression test only runs locally (Q5).
2. `.claude/rules/typescript.md` names Vitest while both packages run Jest 30 — documentation discrepancy to reconcile in a rules-owning change.
3. `jest-util` is imported by tests as a transitive dependency (declared-dependency cleanup would need out-of-scope `package.json` edits).
4. Upstream Jest behavior (`replacePathSepForGlob` lookahead) is unchanged as of 30.4.2; the defect-witness assertion (Q4 group 4) will flag any future semantic change.
