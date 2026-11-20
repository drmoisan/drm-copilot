# Research: collector-core-no-whichgh-branch-untested (#714)

- **Issue:** #714
- **Branch:** bug/collector-core-no-whichgh-branch-untested-714
- **Scope:** Restore branch coverage of the `whichGh === undefined ? {} : { whichGh }` conditional in `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` (line 135) by adding a deterministic Jest test that omits `whichGh` when calling `collectPrContext`.

## 1. Current State Analysis

### 1.1 The uncovered branch (collector-core.ts)

`extensions/drm-copilot/src/lib/pr-context/collector-core.ts:119-136` (`collectPrContext`):

```ts
const whichGh = options.whichGh;
...
const gh = new GhClient({
  runner,
  cwd: resolvedRoot,
  fileSystem: fs,
  ...(whichGh === undefined ? {} : { whichGh }),
});
```

`options.whichGh` is `readonly whichGh?: WhichGh` on `CollectPrContextOptions` (collector-core.ts:100). When a caller does not pass the `whichGh` key at all, `options.whichGh` is `undefined`, `whichGh === undefined` is `true`, and the spread contributes `{}` — the `GhClient` constructor call omits the `whichGh` key entirely. `BRDA:135,2,0,0` is this arm (branch id 2, taken 0 times).

Every existing call site that reaches `collectPrContext` supplies `whichGh` explicitly (see 1.3), so only the `{ whichGh }` arm is exercised.

### 1.2 GhClient's own default resolver (gh-client-core.ts)

`extensions/drm-copilot/src/lib/pr-context/gh-client-core.ts:81-89` (`GhClient` constructor):

```ts
constructor(options: GhClientOptions) {
  this.runnerValue = options.runner;
  this.cwdValue = options.cwd;
  this.fileSystemValue = options.fileSystem;
  const whichGh = options.whichGh ?? (() => undefined);
  this.ghPath = options.ghPath ?? whichGh() ?? undefined;
  this.hydrateAvailability();
}
```

When `GhClientOptions.whichGh` is omitted (as it is on the `whichGh === undefined` arm from collector-core.ts), `GhClient` substitutes a local default resolver `() => undefined` — a plain in-memory function, not a `shutil.which`/PATH lookup, not a spawned process, and not a filesystem read. It is defined and invoked entirely inside the constructor.

`hydrateAvailability()` (gh-client-core.ts:141-175) checks `if (!this.ghPath)` first: when `ghPath` is falsy (as it is when both `ghPath` and `whichGh` are omitted), it sets `availabilityError = "GitHub CLI (gh) is not installed. Install from https://cli.github.com/."` and returns **without calling `this.runnerValue.run(...)`**. No injected `runner` call and no `fs` call occurs on this path. `ensureAvailable()` (gh-client-core.ts:129-134) then throws that exact message.

**Conclusion for research question 1:** the omitted-`whichGh` path is driven entirely through the injected `runner`/`fs` surface (in this case, by *not* calling the runner at all before reporting "not installed"). No real process is spawned and no real PATH lookup occurs anywhere in this call chain — `WhichGh` is a plain injected function type (`() => string | undefined`), and its absence is handled by a same-file default closure, not an import of a `which`/`shutil.which`-style module. There is no module to `jest.mock`; the determinism guarantee comes from never invoking any external resolution logic when `whichGh` is omitted.

This is independently confirmed by an existing test: `extensions/drm-copilot/test/lib/pr-context/gh-client-core.test.ts:91-105` (`buildClient` helper) uses the same conditional-spread idiom (`...(options?.whichGh === undefined ? {} : { whichGh: options.whichGh })`) to construct `GhClient` directly. Test at gh-client-core.test.ts:120-132 (`"reports the auth-failure message with a Details suffix"`) calls `buildClient([...], { ghPath: "/usr/bin/gh" })` with no `whichGh` key, so `GhClient`'s own constructor omits `whichGh` and falls back to its internal default — proving that path is already safe and deterministic at the `GhClient` level. No test, however, drives this by *also* leaving `ghPath` unset (so the default resolver's return value, not just its absence as a key, decides `ghPath`), and no test reaches this state through `collectPrContext`/`collector-core.ts`.

### 1.3 Existing tests calling `collectPrContext` / `collectAndWrite`

`grep`-confirmed call sites and their `whichGh` handling:

| File | Calls | `whichGh` handling |
|---|---|---|
| `test/lib/pr-context/collector-core.test.ts` | `collectPrContext` (7 call sites: lines 180, 207, 225, 319, 370, 404, 437, 460) | Every call passes `whichGh: () => "/usr/bin/gh"`, `whichGh: () => GH_PATH`, or `whichGh: () => undefined` — always as an explicit key, so `options.whichGh` is a defined function (never `undefined` itself). None omits the key. |
| `test/lib/pr-context/collector-core-autoclose.test.ts` | `collectAndWrite` (line 218, inside `runScenario`) | `whichGh: () => GH_PATH` always. |
| `test/lib/pr-context/collector-integration.test.ts` | `collectAndWrite` (line 148) | `whichGh: () => GH_PATH` always. |

`collectAndWrite` (`collector-output.ts:362-366`) forwards its entire `options` object straight to `collectPrContext(options)` — it does not rebuild the options object, so a `collectAndWrite` call that omits `whichGh` would exercise the same collector-core.ts branch. Neither of the two `collectAndWrite`-based test files currently omits it either.

**File line counts** (exact, via `Read`/`cat -n` last line number):
- `collector-core.test.ts`: **477 lines** (500-line limit → 23 lines of headroom).
- `collector-core-autoclose.test.ts`: **401 lines** (99 lines of headroom).
- `collector-integration.test.ts`: **172 lines** (328 lines of headroom).
- `gh-client-core.test.ts`: read through line 179 of a larger file; not a `collectPrContext` call site and therefore not the correct home for an AC-1-satisfying test (AC-1 requires a test that "calls `collectPrContext`").

**Recommended home:** `extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts`. It is the direct, single-purpose test file for `collectPrContext` (matches AC-1's literal wording), already defines every fixture the new test needs (`ROOT`, `seedFeatureTree()`, `buildRunner({ ghAvailable })`), and has just enough headroom (23 lines) for one compact `it` block reusing those helpers without approaching the 500-line limit. A minimal addition (new `describe`/`it` pair, no new helpers, 3-line Arrange, reused `buildRunner`/`seedFeatureTree`, 2-line Assert) fits in roughly 17-21 lines, leaving 2-6 lines of margin. `collector-core-autoclose.test.ts` and `collector-integration.test.ts` have more headroom but call `collectAndWrite`, not `collectPrContext` directly, so they are viable fallbacks only if `collector-core.test.ts`'s margin proves too tight once formatted by Prettier.

## 2. Candidate Approaches

### Approach (a) — Test-only: add a `collectPrContext` call that omits `whichGh`

Add one `it` block to `collector-core.test.ts` that calls `collectPrContext` without a `whichGh` key, reusing `seedFeatureTree()` and `buildRunner({ ghAvailable: false })`. Because the default `GhClient` resolver returns `undefined` and no explicit `ghPath` is supplied, `ghPath` stays falsy and `hydrateAvailability()` takes its earliest branch, producing the literal message `"GitHub CLI (gh) is not installed. Install from https://cli.github.com/."` on `result.ghStatusOverride`. This is a distinct, assertable outcome from every existing test (which all report either "not authenticated" or a successful auth), so the assertion is not vacuous.

- **Advantages:** No production-code change; zero risk to the No-COM / architecture-boundary gates; matches the file's established `ScriptRunner`/`TreeFileSystem` fixture conventions; satisfies AC-1's literal wording ("a Jest test calls `collectPrContext`"); satisfies AC-4 (no real `gh` process, no real filesystem, no host PATH — the assertion above shows the runner is never even invoked on this path).
- **Limitations:** `collector-core.test.ts` is close to the 500-line file-size cap, so the new test must stay compact; if later changes add more tests to this file, headroom will need to be watched.

### Approach (b) — Restructure the conditional so no branch exists

Change `GhClientOptions.whichGh` to `readonly whichGh?: WhichGh | undefined` (or widen it) so `collectPrContext` can pass `whichGh: options.whichGh` unconditionally instead of the `...(whichGh === undefined ? {} : { whichGh })` spread, eliminating the ternary and its branch.

`tsconfig.json` (extensions/drm-copilot) sets `"exactOptionalPropertyTypes": true` (confirmed at line 14). Under this flag, assigning `undefined` to an optional property whose declared type does not itself include `| undefined` is a compile error. `GhClientOptions.whichGh` is currently `readonly whichGh?: WhichGh` (no explicit `| undefined`), so `new GhClient({ ..., whichGh: options.whichGh })` — where `options.whichGh: WhichGh | undefined` — would fail to type-check today. Making option (b) viable requires widening `GhClientOptions.whichGh`'s type, which is exactly the kind of change the repository has consistently avoided: the same `...(x === undefined ? {} : { x })` idiom recurs at `collector-core.ts:135`, in the test-only helper `gh-client-core.test.ts:101-102` (`buildClient`), and in analogous git-client test helpers — it is the established, repo-wide pattern for satisfying `exactOptionalPropertyTypes` on optional constructor fields, not a one-off. Removing it here would create an inconsistency with the rest of the codebase and would touch a public constructor's type surface (`GhClientOptions`) for a coverage-only concern.
- **Advantages:** Removes the branch outright — no future default-arm can go uncovered again for this specific line.
- **Limitations:** Requires a production-code and public-API type change against an established repo idiom; the issue's own "Expected Behavior" section ("Both arms of `...(whichGh === undefined ? {} : { whichGh })` are covered") frames the fix as adding coverage, not eliminating the conditional; no diff to `collector-core.ts` was reported by the regression that caused this issue, so widening scope beyond a test change increases review surface for a low-severity coverage gap.

### Recommendation

**Approach (a) — test-only.** It directly satisfies every acceptance criterion without touching production code, aligns with the issue's framing ("both arms... are covered"), and preserves the repository-wide `exactOptionalPropertyTypes`-driven conditional-spread convention that option (b) would have to break.

**Rejected alternative:** Option (b) (widen `GhClientOptions.whichGh`'s type to remove the branch) — rejected because it requires a public API type change against an established repo-wide idiom, for a problem AC-1 through AC-3 fully resolve with a test-only change.

## 3. Behavior Semantics

- **Success condition:** A test exists in `collector-core.test.ts` that calls `collectPrContext({...})` with no `whichGh` property in the options literal. Running it exercises `collector-core.ts:135`'s `whichGh === undefined` (true) arm, and the resulting `GhClient` is constructed without a `whichGh` key, so `GhClient`'s own default `() => undefined` resolver runs.
- **Observable outcome to assert:** `result.ghAvailable === false` and `result.ghStatusOverride` contains `"GitHub CLI (gh) is not installed."` — the message unique to the "no `ghPath`" branch inside `hydrateAvailability()`, distinguishing this scenario from every other existing test (which reach the "not authenticated" or "authenticated" messages instead).
- **Ordering/edge cases:** None beyond the existing `collectPrContext` flow — `ghAvailable=false` short-circuits `issueDetails`/`prDetails`/`ciStatus` calls exactly as the existing "gh unavailable" test (collector-core.test.ts:221-242) already demonstrates; the new test does not need to assert those downstream effects since they are already covered elsewhere.
- **Failure condition:** If the new test instead passed `whichGh: undefined` as an explicit key, TypeScript's `exactOptionalPropertyTypes: true` would reject it as a type error (assigning `undefined` to a property typed `WhichGh` without `| undefined`) — the property must be omitted entirely, not set to `undefined`, to produce `options.whichGh === undefined` through absence. This is the same distinction the codebase already relies on elsewhere (e.g., collector-core.test.ts never passes `clock` to `collectPrContext` at all, since `clock` is unused there).

## 4. Requirements Mapping

| Acceptance Criterion (issue.md) | Design element |
|---|---|
| AC-1: a Jest test calls `collectPrContext` with no `whichGh` option | New `it` block in `collector-core.test.ts` omitting `whichGh` from the options object literal. |
| AC-2: both arms of the ternary reported covered | The existing 7 call sites cover the `{ whichGh }` arm; the new test covers the `whichGh === undefined` arm. No `/* istanbul ignore */`-style suppression is used or needed. |
| AC-3: branch coverage of `collector-core.ts` restored to >= 91.22%, line coverage does not regress | Test-only change; no lines added to `collector-core.ts`, so line coverage is unaffected. Adding coverage for the one previously-0-hit branch raises the file's branch percentage; the exact post-change percentage must be read from the coverage run itself (see Section 6), not asserted here. |
| AC-4: deterministic — no real `gh` process, no real filesystem touch, no PATH/origin/main/gitignored-state dependency | Confirmed in Section 1.2: omitting `whichGh` and `ghPath` causes `hydrateAvailability()` to return before any `runner.run(...)` call; `seedFeatureTree()`/`buildRunner` are the same in-memory fakes (`TreeFileSystem`, `ScriptRunner`) every other test in the file already uses — no new fixture risk. |
| AC-5: full TypeScript toolchain (format, lint, type-check, test with coverage) passes | Standard toolchain loop per `.claude/rules/typescript.md`; no production code changes reduce the risk of new lint/type findings, but the new test itself must satisfy ESLint/Prettier/TSC same as any other addition to the file. |

No numeric enumeration or population is being proposed against `spec.md`'s acceptance criteria in this research (the `spec.md` on this branch is an unfilled Draft template; the operative acceptance criteria live in `issue.md` and are qualitative pass/fail conditions, not counts requiring a `## Numeric Derivation Evidence` section). The one percentage cited (91.22%) is a pre-existing baseline value quoted verbatim from the issue report, not a count this research derives or enumerates.

## 5. Automation Feasibility

This is a pure test-code change to a TypeScript Jest test file, with no human-interaction requirement: it adds one deterministic unit test that exercises an already-injectable code path (fakes for `runner` and `fs` are already established in the target file), asserts on plain string/boolean return values, and requires no manual UI interaction, no credential entry, no live `gh`/network access, and no host-specific setup. The full toolchain (format, lint, typecheck, test with coverage) can be run non-interactively via the existing `npm run format` / `npm run lint` / `npm run typecheck` / `npm run test:coverage` scripts in `extensions/drm-copilot/package.json`.

## 6. Testing Implications / Test Strategy

- **Test location:** `extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts` (mirrors `src/lib/pr-context/collector-core.ts` under `test/`, consistent with the existing tree and with `.claude/rules/general-unit-test.md`'s test-location rule).
- **Proposed test:** a new `it` (optionally its own `describe("collectPrContext (no whichGh option)", ...)` block to avoid disturbing existing `describe` groupings) that:
  1. Arranges `seedFeatureTree()` and `buildRunner({ ghAvailable: false })` (both already defined in the file).
  2. Acts by calling `collectPrContext({ base: "main", head: "feature/docs", repoRoot: ROOT, includeUntracked: false, fs, runner })` — **no `whichGh` key**.
  3. Asserts `result.ghAvailable === false` and `result.ghStatusOverride` contains `"GitHub CLI (gh) is not installed."`.
- **Determinism:** Uses only the file's existing `ScriptRunner`/`TreeFileSystem` fakes; no timers, no real I/O, no network. Satisfies the repository's Independence/Isolation/Fast/Determinism/Readability criteria.
- **Coverage command:** `extensions/drm-copilot/package.json` defines `"test:coverage": "node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary"`; the root `package.json` defines `"test:unit:coverage": "node run-jest.cjs --coverage"` (extension-relative), which relies on `jest.config.cjs`'s own `coverageReporters: ["lcov", "text-summary"]` (line 18). Neither configuration includes the default Jest `"text"` reporter, so **no per-file console table is printed** — only an aggregate `text-summary` line and an `lcov` file (`extensions/drm-copilot/coverage/lcov.info` per `coverageDirectory` at jest.config.cjs:19). Per-file branch coverage for `collector-core.ts` must be read from the `lcov.info` `BRDA:` lines for that file's `SF:` section (counting non-zero-hit branches over total branches), not from console output. This does not depend on `origin/main`, gitignored state, or a Windows-only path — `coverage/` is a build artifact and its path is the same on any OS running the npm scripts from `extensions/drm-copilot/`.
- **Existing per-file gate:** `jest.config.cjs:33-36` already declares an explicit `coverageThreshold` entry for `"./src/lib/pr-context/collector-core.ts": { lines: 85, branches: 75 }`. The regression described in the issue (89.28% branches) is still above this 75% gate, so the coverage command would not have failed on this file today — the gap is a real but sub-gate regression that AC-3 asks to close back to the pre-#588 91.22% figure, which must be confirmed by reading the actual post-fix `lcov.info`/coverage run rather than assumed.
- **Toolchain order:** format → lint → typecheck → test (per `.claude/rules/typescript.md`), restarting from format if any stage changes files or fails, consistent with `.claude/rules/general-code-change.md`'s seven-stage loop (steps 4/6/7 — architecture-boundary, contract, integration — are not implicated by a test-only Jest addition in this module).

## 7. Merge-Order Independence (issues 706-716)

No shell/`gh` CLI access was available in this research session, so the titles/scope of sibling issues 706-716 (other than 714 itself) could not be queried directly (`gh issue view <n> --json title` was not run) — this is recorded as **unknown**, per the task's instruction, rather than assumed. A repository search of `docs/features/active/` for any feature folder or file referencing `collector-core` or `gh-client-core` found only folders tied to issues #588, #622, #633, and #675 (all outside the 706-716 range) plus this feature's own folder (#714). No local evidence indicates another in-flight issue in the 706-716 range touches `collector-core.ts` or `collector-core.test.ts`.

Given that uncertainty, edits should be **anchored by text, not line numbers**:
- In `collector-core.ts`, anchor on the `new GhClient({` construction inside `collectPrContext` (unique in the file) rather than "line 135", since a concurrent PR could shift line numbers before this branch merges.
- In `collector-core.test.ts`, anchor the new test's insertion point on an existing named `describe` block (e.g., append after the `describe("collectPrContext autoclose body availability", ...)` block, which is the file's last block) rather than a specific line number, and re-verify the file's line count immediately before committing to confirm the 500-line limit still holds after a possible upstream merge changes the file's length.

## 8. Risks

- **File-size margin:** `collector-core.test.ts` at 477/500 lines leaves only ~23 lines of headroom; Prettier reformatting or a slightly more verbose test than estimated could push the file over the 500-line limit. Mitigation: keep the new test minimal (reuse existing helpers, no new fixtures/comments beyond a short AAA annotation), and if it does not fit, fall back to `collector-integration.test.ts` (172 lines, ample headroom) using `collectAndWrite` instead — `collectAndWrite` forwards its full options object to `collectPrContext` unchanged (collector-output.ts:366), so omitting `whichGh` there reaches the identical branch, though it satisfies AC-1's coverage effect rather than its literal "calls `collectPrContext`" wording.
- **Baseline percentage confirmation:** AC-3's target (91.22%) is quoted from the issue, not independently re-derived in this research; the actual pre-#588 and post-fix percentages must be read from the coverage run's `lcov.info` (or the referenced qa-gate evidence files under `docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588/evidence/`) at execution time rather than assumed to match exactly.
- **Sibling-issue collision:** Unknown (see Section 7) whether another in-flight issue in the 706-716 range edits the same two files; text-anchored edits and a pre-commit line-count re-check mitigate line-shift risk from a concurrent merge.
