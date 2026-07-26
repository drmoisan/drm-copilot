# 2026-07-25-jest-rootdir-testmatch-dot-directory (Spec)

- **Issue:** #423
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-26
- **Status:** Ready
- **Version:** 1.0

## Context
On Windows, Jest discovers zero test files when the repository is checked out under a path containing a dot-prefixed directory segment (for example `.claude/worktrees/<name>/`). Both Jest projects in this repository are affected: the root `jest.config.cjs` and `extensions/drm-copilot/jest.config.cjs`. Each interpolates `<rootDir>` into `testMatch`, and Jest's separator normalization leaves the `\` before the dot segment intact, where picomatch then consumes it as a glob escape rather than a path separator.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Node version: v24.14.0
- Jest version: 30.4.2 (root and `extensions/drm-copilot`)
- Command/flags used: `node run-jest.cjs` (root), `npm --prefix extensions/drm-copilot run test`
- Checkout path: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Zero test discovery is reported as a distinct outcome rather than a test failure. Any agent or developer working in a `.claude/worktrees/**` checkout receives no test signal at all, and the message is easily mistaken for "nothing to run". Adding `--passWithNoTests` anywhere in the invocation chain would convert this into a true false-green.


## Repro & Evidence
Steps to Reproduce:
1. Check out the repository on Windows at a path containing a dot-prefixed directory segment, for example `C:\Users\<user>\repos\drm-copilot\.claude\worktrees\<name>`.
2. Run `npm ci` at the repository root and `npm --prefix extensions/drm-copilot ci`.
3. Run `node run-jest.cjs` at the repository root.
4. Run `npm --prefix extensions/drm-copilot run test`.

Expected:
Jest discovers and executes the test files matched by `testMatch` (`tests/unit/**/*.test.ts` and `extensions/drm-copilot/test/**/*.test.ts`), independently of whether the checkout path contains a dot-prefixed directory segment.

Actual:
Both runs report zero discovered tests:

```
No tests found, exiting with code 1
Run with `--passWithNoTests` to exit with code 0
In C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f
  434 files checked.
  testMatch: C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-a08c9cf1932159e8f/tests/unit/**/*.test.ts, ... - 0 matches
```

Note the literal backslash retained in `drm-copilot\.claude` while every other separator in the same pattern was converted to a forward slash.

Logs / Screenshots:
- [x] Attached minimal logs
- Snippet: see Actual Behavior above; identical failure reproduced for `extensions/drm-copilot` with `368 files checked` and `0 matches`.


## Scope & Non-Goals
- In scope:
  - `jest.config.cjs` (repo root): replace the two `<rootDir>`-interpolated `testMatch` entries with relative `**/`-anchored globs.
  - `extensions/drm-copilot/jest.config.cjs`: replace the single `<rootDir>`-interpolated `testMatch` entry with a relative `**/`-anchored glob.
  - `run-jest.cjs` (repo root) and `extensions/drm-copilot/run-jest.cjs`: add an inline pre-spawn guard that rejects `--passWithNoTests` (and the flags `--onlyChanged` and `--lastCommit`, which share Jest's `exitWith0` path) with exit code 1 and an actionable message citing issue #423.
  - New regression tests: `tests/unit/jest-config-resolution.test.ts` and `extensions/drm-copilot/test/jest-config-resolution.test.ts` (Jest + `@jest/globals`).
  - Fail-before / pass-after evidence captured under `docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/regression-testing/`.
- Out of scope / non-goals:
  - Any change to the `roots` option. Research established that constraining `roots` couples test discovery to the coverage denominator through the haste map and would silently shrink the extension's `collectCoverageFrom` enumeration.
  - Any change to `testPathIgnorePatterns`, `collectCoverageFrom`, `coverageThreshold`, `coverageDirectory`, or the ts-jest `tsconfig` references (`<rootDir>` in those options resolves via literal-path or regex mechanisms and is unaffected by the defect).
  - New helper modules for the `run-jest.cjs` guard. The guard stays inline; new modules are outside the delegated file-ownership scope.
  - Wiring the root package's Jest entry point into CI. Recorded below as a known gap; workflow files are owned by parallel work.
  - Reconciling the Vitest statement in `.claude/rules/typescript.md` with the packages' actual Jest toolchain (documentation discrepancy recorded by research; `.claude/rules/**` is forbidden in this feature).
  - Upstream changes to Jest/`jest-util`/picomatch behavior.
- Explicitly excluded systems, integrations, or datasets (forbidden files owned by parallel orchestrations; this fix must not modify them and must not depend on modifying them):
  - Root `package.json`
  - `tsconfig*.json`
  - `.vscode-test.*`
  - `.claude/rules/**`
  - `.agents/skills/**`
  - `extensions/drm-copilot/resources/claude-customizations/**`

## Root Cause Analysis
Root cause confirmed experimentally (not inferred):

1. `jest.config.cjs` interpolates `<rootDir>` into `testMatch`, producing an absolute Windows path inside a glob pattern.
2. `jest-util`'s `replacePathSepForGlob` normalizes separators with `path.replaceAll(/\\(?![$()+.?^{}])/g, '/')`. The negative lookahead intentionally preserves a backslash that precedes a glob metacharacter so that pre-escaped metacharacters survive normalization.
3. A dot-prefixed directory segment yields the byte pair `\.` in the Windows path. That pair is protected by the lookahead, so the separator is **not** converted to `/`.
4. picomatch then reads `\.` as an escaped literal dot rather than a path separator. The pattern `.../drm-copilot\.claude/...` matches the literal text `drm-copilot.claude/...`, which no real path produces.
5. Result: `testMatch` yields 0 matches and Jest reports "No tests found".

Refuted hypothesis: this is **not** micromatch/picomatch `dot: false` behaviour. Verified in-process that `globsToMatcher(["**/tests/unit/**/*.test.ts"])` returns `true` for `C:\Users\x\repo\.claude\wt\a\tests\unit\a.test.ts` under default options — a dot-prefixed segment matches fine when the separator survives as `/`. Jest 30 uses picomatch, not micromatch; the repository has no `micromatch` install.

Confirming probe results (run in-process against the installed Jest 30.4.2):

- `readConfig(...).projectConfig.testMatch[0]` = `C:/Users/DanMoisan/repos/drm-copilot\.claude/worktrees/agent-.../tests/unit/**/*.test.ts`
- `globsToMatcher(testMatch)(<real test file path>)` = `false`
- `picomatch("C:/Users/x/repo\\.claude/wt/a/tests/unit/**/*.test.ts")("C:/Users/x/repo.claude/wt/a/tests/unit/a.test.ts")` = `true` — proving the backslash is consumed as an escape, not treated as a separator.
- Neither `dot: true`, `windows: false`, nor `returnState` changes the outcome.

Files to inspect: `jest.config.cjs`, `run-jest.cjs`, `extensions/drm-copilot/jest.config.cjs`, `extensions/drm-copilot/run-jest.cjs`.


## Proposed Fix

The design follows the accepted recommendation in `research/2026-07-25T22-15-jest-rootdir-testmatch-dot-directory-research.md` (option (b): relative `**/`-anchored `testMatch` globs, no `roots` change, plus an inline loudness guard in both `run-jest.cjs` entry points).

### Design summary (what changes where):

| Change | File(s) | Content |
|---|---|---|
| Fix testMatch | `jest.config.cjs` (root) | `testMatch: ["**/tests/unit/**/*.test.ts", "**/extensions/drm-copilot/test/**/*.test.ts"]` |
| Fix testMatch | `extensions/drm-copilot/jest.config.cjs` | `testMatch: ["**/test/**/*.test.ts"]` |
| Loudness guard | `run-jest.cjs`, `extensions/drm-copilot/run-jest.cjs` | Inline pre-spawn rejection of `--passWithNoTests`, `--onlyChanged`, `--lastCommit`: exit 1 with an actionable message citing issue #423, before Jest is spawned |
| Regression tests | `tests/unit/jest-config-resolution.test.ts`, `extensions/drm-copilot/test/jest-config-resolution.test.ts` | Assertion groups 1–6 (see Test Strategy), Jest + `@jest/globals`, synthetic path strings only |

Why relative `**/` patterns work: a `testMatch` entry that does not start with `<rootDir>` bypasses `replaceRootDirInPath` and passes through `replacePathSepForGlob` unchanged (it contains no backslashes). At match time the candidate absolute path still carries the protected `\.claude` byte pair, but the leading `**/` globstar consumes it (picomatch `dot: true` default). This is directly validated by the recorded in-process probe against the installed jest-util/picomatch.

### Boundaries and invariants to preserve:

- **No `roots` change.** `roots` constrains the haste-map crawl, and `CoverageReporter._addUntestedFiles` enumerates the haste map when `collectCoverageFrom` is set. Restricting `roots` in the extension config would silently remove untested `src/**` files from the coverage denominator, weakening the per-file coverage gate without any error.
- `testPathIgnorePatterns: ["/node_modules/", "/out/"]` remains unchanged in both configs (it also bounds the over-match surface of the new `**/`-anchored patterns).
- `collectCoverageFrom`, `coverageThreshold`, `coverageDirectory`, `coverageProvider`, `moduleFileExtensions`, `transform` (including ts-jest `tsconfig: "<rootDir>/tsconfig.jest.json"`) remain unchanged in both configs; those `<rootDir>` uses resolve via literal-path mechanisms and are not affected by the defect.
- Both `run-jest.cjs` files keep their existing `--testPathPattern` → `--testPathPatterns` rewrite and their existing spawn/exit-code propagation behavior for all non-rejected arguments.
- Jest's built-in behavior of exiting 1 on zero discovered tests remains the enforcement backstop; the guard removes the only switches that convert zero discovery into exit 0 for these entry points.
- No forbidden file (see Scope & Non-Goals) is modified or required.

### Dependencies or blocked work:

- No blocking dependencies. All touched files are inside the delegated ownership scope, and both packages already have their dependencies installed in this worktree.
- The regression tests import `globsToMatcher` from `jest-util`, a transitive dependency of `jest` physically present in both packages' `node_modules` trees. Declaring it as a direct devDependency would require `package.json` edits, which are out of scope (root `package.json` is forbidden). Accepted residual risk: the import resolves under `npm ci` in both packages because `jest` requires `jest-util`.
- Parallel orchestrations own the forbidden files; this fix must remain mergeable without any change to them.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

1. `jest.config.cjs` (root) — `testMatch` value only.
2. `extensions/drm-copilot/jest.config.cjs` — `testMatch` value only.
3. `run-jest.cjs` (root) — add inline prohibited-flag guard before `runNodeTool(...)` is invoked.
4. `extensions/drm-copilot/run-jest.cjs` — add the same inline guard before `cp.spawnSync(...)`.
5. `tests/unit/jest-config-resolution.test.ts` — new regression test (root config).
6. `extensions/drm-copilot/test/jest-config-resolution.test.ts` — new regression test (extension config).

#### Functions/classes/CLI commands impacted:

- CLI entry points `node run-jest.cjs` (root) and `node run-jest.cjs` / `npm --prefix extensions/drm-copilot run test` (extension): new failure mode when invoked with `--passWithNoTests`, `--onlyChanged`, or `--lastCommit` — immediate exit 1 with a message citing issue #423, Jest not spawned. All other invocations are behaviorally unchanged except that test discovery now succeeds in dot-prefixed checkouts.
- No production TypeScript functions or classes change. No new helper modules are created; the guard is an inline exact-argument check (same style as the existing `--testPathPattern` rewrite).

#### Data flow and validation changes:

- Configuration flow: `testMatch` entries no longer enter `jest-config`'s `<rootDir>` interpolation path (`escapeGlobCharacters` + `path.resolve`), so no absolute host path ever reaches `replacePathSepForGlob`/picomatch as a glob. The candidate file paths Jest matches against are unchanged; only the pattern side of the match changes.
- Argument flow in both `run-jest.cjs` files: arguments are scanned for the prohibited flags before any rewrite/spawn; a hit short-circuits with exit 1. Non-prohibited arguments flow through exactly as today.

#### Error handling and logging updates:

- New guard message (both entry points), written to stderr before `process.exit(1)`. Required content: the rejected flag name, the statement that zero discovered tests must fail, and the reference `issue #423`. Reference wording: `--passWithNoTests is prohibited in this repository: zero discovered tests must fail (issue #423).` (analogous wording for `--onlyChanged` / `--lastCommit`).
- No other logging changes. Jest's own no-tests diagnostic (which prints the resolved rootDir, each testMatch pattern, and per-pattern match counts) is retained as-is; research evaluated and rejected an additional preflight diagnostic as redundant startup cost.

#### Rollback/feature-flag considerations (if applicable):

- No feature flag. The change is a static configuration and entry-point edit; rollback is `git revert` of the fix commit(s).
- Rolling back restores the defect (zero discovery in dot-prefixed Windows checkouts) but does not break non-dot checkouts; the two states are otherwise behavior-identical for CI runner paths.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- `jest.config.cjs` (root) exports a CommonJS config object whose `testMatch` is exactly `["**/tests/unit/**/*.test.ts", "**/extensions/drm-copilot/test/**/*.test.ts"]`.
- `extensions/drm-copilot/jest.config.cjs` exports a CommonJS config object whose `testMatch` is exactly `["**/test/**/*.test.ts"]`.
- Contract for every `testMatch` entry (regression-test shape guard): string; contains no `<rootDir>` substring; contains no backslash; starts with `**/`.
- `run-jest.cjs` (both): argv in, Jest child exit code out, except prohibited flags → exit 1 + stderr message, Jest never spawned.

#### Required configuration keys and defaults:

- No new configuration keys. `passWithNoTests` must remain unset (falsy) in both config objects — asserted by the regression tests so it cannot be introduced silently.
- picomatch matching relies on jest-util's `globsToMatcher` defaults (`dot: true`); no options are overridden.

#### Backward-compatibility expectations:

- The set of discovered test files in a non-dot checkout is unchanged: the `**/`-anchored patterns match the same files, and over-match into `node_modules`/`out` is excluded by the haste map and `testPathIgnorePatterns`.
- `--passWithNoTests`, `--onlyChanged`, and `--lastCommit` become hard errors at these entry points. No repository script, workflow, or documented invocation uses them today (verified by research Q3/Q5), so no caller breaks.
- All other CLI arguments, npm scripts, and coverage behavior are unchanged.

#### Performance constraints (latency/throughput/memory):

- No measurable impact. The guard is an O(argc) array scan before spawn; the pattern change alters only glob compilation inputs. No preflight run or extra Jest startup is added (research explicitly rejected a `--listTests` preflight for doubling startup cost).

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - Jest 30.4.2 semantics as read from the installed sources hold: `replacePathSepForGlob`'s lookahead, picomatch `dot: true` default in `globsToMatcher`, and the `exitWith0 = passWithNoTests || lastCommit || onlyChanged` computation in `@jest/core`. The defect-witness regression assertion pins the escaped-dot semantics so a future Jest change is flagged.
  - This worktree (path contains `\.claude\worktrees\`) is available for the direct fail-before/pass-after reproduction; `npm ci` has been run in both packages.
  - Test inventory at branch head: 1 root test file (`tests/unit/hello-typescript.test.ts`), 168 extension test files under `extensions/drm-copilot/test/**`.
- Constraints (budget, performance, compatibility):
  - Regression tests must not create temporary files or directories and must not materialise a dot-prefixed checkout (repository unit-test policy). All matcher inputs are synthetic path strings.
  - The guard must remain inline in `run-jest.cjs`; new helper modules are outside the delegated file-ownership scope.
  - Forbidden files (Scope & Non-Goals list) must not be modified and the fix must not require modifying them.
  - Unit tests must not spawn external processes; executable coverage of the guard, if added, must be classed as an integration test.
- External dependencies (services, libraries, releases):
  - `jest` ^30.4.2 / ^30.0.0, `ts-jest`, `@jest/globals` — already installed in both packages.
  - `jest-util` (transitive via `jest`, ships its own TypeScript declarations) — imported by the regression tests; undeclared-direct-dependency status recorded as accepted residual risk.
  - No new dependencies are added.

## Data / API / Config Impact
- User-facing or API changes:
  - `node run-jest.cjs` (root and extension) rejects `--passWithNoTests`, `--onlyChanged`, and `--lastCommit` with exit 1 and an actionable stderr message citing issue #423. No other CLI surface changes.
- Data or migration considerations:
  - None. No persisted data, schemas, or state files are involved.
- Logging/telemetry updates (if any):
  - One new stderr message per rejected prohibited flag (see Error handling and logging updates). No telemetry.
- Compatibility notes (CLI flags, config schemas, versioning):
  - `testMatch` moves from absolute `<rootDir>`-interpolated globs to relative `**/`-anchored globs; the discovered-file set is unchanged in non-dot checkouts and becomes correct in dot-prefixed checkouts, on both Windows and POSIX (research Q6: the fix is platform-independent string processing).
  - No `roots` key is introduced; coverage enumeration semantics are unchanged.
  - Known CI gap (recorded, not fixed here): no CI workflow executes the root package's Jest entry point, so `tests/unit/jest-config-resolution.test.ts` will not run in CI. The extension regression test runs in CI on windows-latest and ubuntu-latest via `_drm-copilot-extension-tests.yml` (and both publish workflows).

## Test Strategy
Framework resolution (per research Q4): the new regression tests are **Jest** tests using `@jest/globals` imports, matching the 169 existing test files. Vitest (named in `.claude/rules/typescript.md`) is not installed in either package; the discrepancy is recorded as a documentation finding and the rule file is out of scope.

- Regression tests to add or update:
  - `tests/unit/jest-config-resolution.test.ts` (root config) and `extensions/drm-copilot/test/jest-config-resolution.test.ts` (extension config). Unit under test: the exported config object (`require` of the respective `jest.config.cjs`) plus `globsToMatcher` from `jest-util`. All inputs are synthetic path strings; no filesystem access, no temporary files, no directory needs to exist; deterministic and byte-identical on Windows and Linux.
  - Assertion groups per config file:
    1. **Shape guard:** every `testMatch` entry is a string, contains no `<rootDir>`, contains no `\\`, and starts with `**/`.
    2. **Positive matcher, synthetic dot-prefixed Windows root** — one representative path **per pattern** (closes the partial-collapse gap where only one of two root patterns regresses to zero):
       - root pattern 1: `C:\Users\x\repos\drm-copilot\.claude\worktrees\wt-1\tests\unit\sample.test.ts`
       - root pattern 2: `C:\Users\x\repos\drm-copilot\.claude\worktrees\wt-1\extensions\drm-copilot\test\lib\sample.test.ts`
       - extension pattern: `C:\Users\x\repos\drm-copilot\.claude\worktrees\wt-1\extensions\drm-copilot\test\sample.test.ts`
    3. **Positive matcher, POSIX root:** the same matcher returns `true` for `/home/runner/work/drm-copilot/drm-copilot/tests/unit/sample.test.ts` (root) and the analogous extension path.
    4. **Defect witness:** hard-code the broken normalized pattern the old config produced (e.g. `"C:/Users/x/repos/drm-copilot\\.claude/worktrees/wt-1/tests/unit/**/*.test.ts"`) and assert `globsToMatcher([broken])` returns `false` for the corresponding group-2 path. This pins picomatch's escaped-dot semantics; a future `replacePathSepForGlob` change flags the assumption.
    5. **Negative flow:** the matcher returns `false` for a non-test path (e.g. `...\src\extension.ts`) — guards against over-broad patterns.
    6. **Loudness config guard:** `config.passWithNoTests` is strictly falsy and `config.testPathIgnorePatterns` still contains `"/node_modules/"` and `"/out/"`.
- Unit tests for the fixed behavior and boundaries:
  - Covered by the two regression test files above (groups 1–6). The `run-jest.cjs` guard is a spawn-and-exit script and is not unit-tested directly (unit tests must not spawn external processes and no helper module may be extracted); its verification is the manual/evidence step below. If executable coverage is added later it must be an integration test.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - Dot-prefixed Windows path (group 2), POSIX path (group 3), broken legacy pattern (group 4), non-test production file (group 5), prohibited CLI flags (evidence step).
- Error handling and logging verification:
  - Evidence step: `node run-jest.cjs --passWithNoTests` at both package roots must exit 1 with a stderr message citing issue #423, without spawning Jest; same for `--onlyChanged` and `--lastCommit`. Captured under `evidence/regression-testing/`.
- Coverage impact and targets for changed lines/modules:
  - `jest.config.cjs` and `run-jest.cjs` are config/entry-point scaffolding outside both packages' `collectCoverageFrom` globs (`src/**`); no coverage-metric movement is expected. The 85% line / 75% branch repository gates are unaffected; no coverage exclusion is added or modified.
- Toolchain commands to run (format → lint → type-check → test):
  - Root package (repo root): `npm run format:check` (or `npm run format` with a clean diff), `npm run lint`, `npm run typecheck`, `node run-jest.cjs`. Note: the root prettier globs cover `jest.config.cjs` and `run-*.cjs`; root eslint covers `src` and `tests` (includes the new test file).
  - Extension package: `npm --prefix extensions/drm-copilot run format` (with a clean diff afterward), `npm --prefix extensions/drm-copilot run lint`, `npm --prefix extensions/drm-copilot run typecheck`, `npm --prefix extensions/drm-copilot run test`.
  - Repeat the loop from formatting until all stages pass in a single pass, per `.claude/rules/general-code-change.md`.
- Manual validation steps (if required):
  - Fail-before: at the unfixed base in this dot-prefixed worktree, capture `node run-jest.cjs` (expected: `No tests found, exiting with code 1`, 0 matches, 434 files checked) and `npm --prefix extensions/drm-copilot run test` (expected: same, 368 files checked). Alternatively/additionally, run the new regression tests against the unfixed configs (assertion groups 1–2 fail; group 4 passes by construction).
  - Pass-after: same two commands with the fix applied; expected discovery at branch head + new tests: 171 test suites for the root run (2 under `tests/unit/`, 169 under `extensions/drm-copilot/test/`), 169 test suites for the extension run; exit 0 on pass.
  - In-process spot check (no files created), run at repo root: `readConfig(...)` must show `projectConfig.testMatch` equal to the relative patterns, and `globsToMatcher(projectConfig.testMatch)` must return `true` for this worktree's real `tests\unit\hello-typescript.test.ts` path (research Q2 script).
  - Store all captured outputs under `docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/regression-testing/`.


## Acceptance Criteria
- [x] `jest.config.cjs` (root) exports `testMatch: ["**/tests/unit/**/*.test.ts", "**/extensions/drm-copilot/test/**/*.test.ts"]` and `extensions/drm-copilot/jest.config.cjs` exports `testMatch: ["**/test/**/*.test.ts"]`; no `testMatch` entry in either file contains `<rootDir>` or a backslash. Verified by inspection of both files and enforced by the shape-guard assertions (group 1) in both regression test files.
- [x] Neither config adds or modifies a `roots` key, and `testPathIgnorePatterns`, `collectCoverageFrom`, `coverageThreshold`, `coverageDirectory`, and the ts-jest `tsconfig` references are byte-identical to base `fb483b84`. Verified by `git diff fb483b84 -- jest.config.cjs extensions/drm-copilot/jest.config.cjs` showing only the `testMatch` value change.
- [x] Fail-before evidence is captured: outputs of `node run-jest.cjs` (root) and `npm --prefix extensions/drm-copilot run test` against the unfixed configs in this dot-prefixed worktree, each showing `No tests found, exiting with code 1` with 0 testMatch matches, stored under `docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/regression-testing/`.
- [x] Pass-after evidence is captured in the same evidence directory: with the fix applied, `node run-jest.cjs` (root) discovers a non-zero suite count matching the on-disk inventory (expected at spec time: 171 test suites) and `npm --prefix extensions/drm-copilot run test` discovers a non-zero suite count (expected at spec time: 169 test suites); both runs exit 0 with all tests passing.
- [x] `node run-jest.cjs --passWithNoTests` exits with code 1 at the repository root without spawning Jest and prints a stderr message that names the rejected flag and cites issue #423; the exit code and message are captured in the evidence directory.
- [x] `node run-jest.cjs --passWithNoTests` run from `extensions/drm-copilot/` exits with code 1 without spawning Jest and prints a stderr message that names the rejected flag and cites issue #423; the exit code and message are captured in the evidence directory.
- [x] Both `run-jest.cjs` entry points also reject `--onlyChanged` and `--lastCommit` (the remaining flags on Jest's `exitWith0` path) with exit 1 and a message citing issue #423; verified by invoking each flag once per entry point and capturing the results in the evidence directory.
- [x] The guard in both `run-jest.cjs` files is inline (no new helper module is created), and the existing `--testPathPattern` → `--testPathPatterns` rewrite and exit-code propagation are unchanged. Verified by review of the diff.
- [x] `tests/unit/jest-config-resolution.test.ts` exists, runs under the root Jest project, and passes with assertion groups 1–6: shape guard, per-pattern dot-prefixed Windows match, per-pattern POSIX match, defect witness, negative flow, and loudness config guard.
- [x] `extensions/drm-copilot/test/jest-config-resolution.test.ts` exists, runs under the extension Jest project, and passes with assertion groups 1–6 for the extension config.
- [x] Each configured `testMatch` pattern is individually asserted (via `globsToMatcher([pattern])` or equivalent per-pattern assertions) to match both a representative synthetic dot-prefixed Windows path and a representative POSIX path — i.e., the root test asserts both root patterns separately, so a partial collapse of one pattern to zero matches fails the test. Verified by reading the test assertions.
- [x] The defect-witness assertion is present in both test files: a hard-coded broken normalized pattern containing the retained `\.` byte pair (e.g. `"C:/Users/x/repos/drm-copilot\\.claude/worktrees/wt-1/tests/unit/**/*.test.ts"`) is asserted to NOT match the corresponding synthetic test-file path, pinning picomatch's escaped-dot semantics against future Jest changes.
- [x] Both regression test files use Jest with `@jest/globals` imports (not Vitest), perform no filesystem reads or writes other than `require` of the config module, create no temporary files or directories, and do not materialise a dot-prefixed checkout — all matcher inputs are synthetic path strings. Verified by review of the test files.
- [x] `config.passWithNoTests` is asserted strictly falsy and `config.testPathIgnorePatterns` is asserted to contain `"/node_modules/"` and `"/out/"` in both regression test files (loudness config guard, group 6).
- [x] Full toolchain pass, root package: `npm run format:check`, `npm run lint`, `npm run typecheck`, and `node run-jest.cjs` all succeed in a single pass at the repository root.
- [x] Full toolchain pass, extension package: `npm --prefix extensions/drm-copilot run format` leaves no diff, and `npm --prefix extensions/drm-copilot run lint`, `npm --prefix extensions/drm-copilot run typecheck`, and `npm --prefix extensions/drm-copilot run test` all succeed in a single pass.
- [x] No forbidden file is modified: `git diff --name-only fb483b84...HEAD` contains no entry matching root `package.json`, `tsconfig*.json`, `.vscode-test.*`, `.claude/rules/**`, `.agents/skills/**`, or `extensions/drm-copilot/resources/claude-customizations/**`, and the changed-file set is limited to the six in-scope files plus feature-folder documentation and evidence.

## Risks & Mitigations
- Technical or operational risks:
  1. **Upstream Jest semantic change.** A future Jest release could alter `replacePathSepForGlob` or picomatch escape handling, invalidating the assumptions behind the fix. Mitigation: the defect-witness assertion (group 4) fails loudly on such a change, forcing re-evaluation; risk is dormant until a Jest upgrade.
  2. **Over-match of relative `**/` patterns.** A `test/` or `tests/unit/` directory appearing under an unexpected tree could be picked up. Mitigation: the haste map does not retain `node_modules`, `testPathIgnorePatterns` excludes `/node_modules/` and `/out/`, and the negative-flow assertion (group 5) guards against over-broad matching; the pass-after suite counts in evidence confirm the discovered set equals the inventory.
  3. **Root regression test not CI-wired (known gap, recorded, not fixed here).** `tests/unit/jest-config-resolution.test.ts` executes only in local/agent runs of `node run-jest.cjs`; a regression at the root config could merge without CI signal. Mitigation: the extension regression test (which covers the identical mechanism) runs in CI on windows-latest and ubuntu-latest; the gap is carried as follow-up for the orchestration that owns workflow files.
  4. **`jest-util` imported as an undeclared transitive dependency.** An npm tree reshape could in principle relocate it. Mitigation: `jest-util` is a hard dependency of `jest` itself and ships TypeScript declarations; declaring it directly requires out-of-scope `package.json` edits; recorded as accepted residual risk with follow-up below.
  5. **Guard flag rejection breaks an unknown caller.** Mitigation: research verified no repository script, workflow, or documented invocation uses `--passWithNoTests`, `--onlyChanged`, or `--lastCommit`; the error message is actionable and cites issue #423.
- Mitigations and rollbacks:
  - Rollback is a `git revert` of the fix commit(s); no data migration or flag cleanup is involved. Reverting restores the defect in dot-prefixed checkouts only.

## Rollout & Follow-up
- Release/rollout steps:
  1. Land the six-file change on `bug/jest-no-tests-found-dot-directory-worktree`; the extension-tests workflow (`_drm-copilot-extension-tests.yml`, windows-latest + ubuntu-latest) exercises the extension regression test on the PR automatically.
  2. Merge to `main` per standard PR flow. No deployment, publish, or version bump is required by this fix; the next runs of `publish-extension.yml` / `publish-mcp-npm.yml` re-execute the extension test suite as usual.
- Post-fix monitoring or clean-up tasks (follow-ups recorded by research, all out of scope here):
  1. Wire the root package's Jest entry point into a CI workflow so `tests/unit/jest-config-resolution.test.ts` gains CI signal (owned by the orchestration that owns workflow files).
  2. Reconcile `.claude/rules/typescript.md` (names Vitest) with the packages' actual Jest 30 toolchain in a rules-owning change.
  3. Declare `jest-util` as a direct devDependency in a `package.json`-owning change.
  4. On any future Jest upgrade, watch the defect-witness assertion for failures indicating changed `replacePathSepForGlob`/picomatch semantics.
- Links: issue [#423](https://github.com/drmoisan/drm-copilot/issues/423); research: `docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/research/2026-07-25T22-15-jest-rootdir-testmatch-dot-directory-research.md`; issue capture: `docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/issue.md`; evidence: `docs/features/active/2026-07-25-jest-rootdir-testmatch-dot-directory-423/evidence/regression-testing/`; PR: to be added at PR-authoring time.
