# collector-core-no-whichgh-branch-untested (Spec)

- **Issue:** #714
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-27T01-15
- **Status:** Draft
- **Version:** 1.0

## Context
- After issue #588 (PR #704), every existing caller of `collectPrContext` supplies a `whichGh` resolver explicitly. As a result, the `whichGh === undefined` arm of the conditional spread that builds the `GhClient` options object inside `collectPrContext` (`extensions/drm-copilot/src/lib/pr-context/collector-core.ts`, the `new GhClient({ ... })` call) is no longer exercised by any test.
- Observed environment(s): Jest with coverage, `extensions/drm-copilot` project (any OS; the coverage command is not host-specific).
- Customer impact and severity: no user-facing behavior is affected; this is a coverage regression on a single conditional branch. Severity is Low, as recorded in `issue.md`.
- First observed: coverage delta reported in `docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588/evidence/qa-gates/ts-coverage-delta.2026-09-25T22-06.md` and `code-review.2026-09-26T21-37.md` (CR-1), surfaced after PR #704 merged.

## Repro & Evidence
- Steps to reproduce: run Jest with coverage on `extensions/drm-copilot`; inspect the `lcov.info` `BRDA` line for `collector-core.ts` at the text anchor `whichGh === undefined` — one of the two branch-id entries reports zero hits.
- Expected vs actual: both arms of `...(whichGh === undefined ? {} : { whichGh })` should report nonzero hits; today only the `{ whichGh }` arm is covered because every call site in `collector-core.test.ts`, `collector-core-autoclose.test.ts`, and `collector-integration.test.ts` supplies `whichGh` explicitly.
- Logs/evidence: `docs/features/active/collector-core-no-whichgh-branch-untested-714/research/research.2026-09-27T00-30.md` Section 1 (call-site table) and Section 4 (requirements mapping).
- Frequency/determinism: deterministic and permanent until a test omits `whichGh` — the gap does not depend on data or timing.

## Scope & Non-Goals
- In scope: adding one deterministic Jest test that calls `collectPrContext` without a `whichGh` key, so `GhClient`'s own default resolver (`() => undefined`) runs and `collector-core.ts`'s `whichGh === undefined` (true) arm executes.
- Out of scope / non-goals: modifying `collector-core.ts`, `gh-client-core.ts`, or `GhClientOptions`'s type; changing the `exactOptionalPropertyTypes`-driven conditional-spread idiom used throughout the pr-context module; adding a coverage-ignore comment.
- Explicitly excluded systems: no real `gh` process, no real filesystem, no host PATH, no `origin/main`, no gitignored state, no Windows-only paths (see Test Strategy).

## Root Cause Analysis
- Confirmed root cause (research.2026-09-27T00-30.md Section 1.1–1.3): the `whichGh === undefined` arm of `collector-core.ts`'s `GhClient` construction has no covering test because every one of the 7 `collectPrContext` call sites in `collector-core.test.ts`, plus the `collectAndWrite` call sites in `collector-core-autoclose.test.ts` and `collector-integration.test.ts`, passes `whichGh` explicitly as a key (never omits it).
- Signals/evidence: grep-confirmed call-site table in research Section 1.3; `BRDA:135,2,0,0` in the pre-fix `lcov.info` (branch id 2 at the `whichGh === undefined` conditional, zero hits).
- Affected components: `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` (the branch itself; no code change required) and the test suite under `extensions/drm-copilot/test/lib/pr-context/`.

## Proposed Fix

### Design summary (what changes where):
Add one new Jest test file, `extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts`, containing a single `it` block that calls `collectPrContext` with an options object literal that omits the `whichGh` key entirely. No production file changes.

### Boundaries and invariants to preserve:
- `collector-core.ts`'s conditional-spread idiom (`...(whichGh === undefined ? {} : { whichGh })`) is preserved unchanged, consistent with the repository-wide pattern used to satisfy `exactOptionalPropertyTypes: true` (also present in `gh-client-core.test.ts`'s `buildClient` helper and analogous git-client test helpers).
- `GhClientOptions.whichGh`'s public type (`readonly whichGh?: WhichGh`) is not widened.

### Dependencies or blocked work:
None. This branch is independent of sibling issue #716 (`compare-code-point-helper-duplicated`), which may also touch `collector-core.ts`; see the merge-order-independence note under Acceptance Criteria.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- New: `extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts`.
- No changes to any file under `extensions/drm-copilot/src/`.

#### Functions/classes/CLI commands impacted:
- Test-only. Exercises `collectPrContext` (`collector-core.ts`) and, transitively, `GhClient`'s constructor default-resolver path (`gh-client-core.ts`, `hydrateAvailability`). Neither function's implementation changes.

#### Data flow and validation changes:
None (no production data flow changes).

#### Error handling and logging updates:
None (no production error-handling changes). The new test asserts on the existing literal message `"GitHub CLI (gh) is not installed. Install from https://cli.github.com/."` (verified verbatim at `extensions/drm-copilot/src/lib/pr-context/gh-client-core.ts:144`).

#### Rollback/feature-flag considerations (if applicable):
None required; a test-only addition can be reverted independently with no runtime effect.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
The new test constructs an in-memory `TreeFileSystem` (imported from `./tree-file-system`) seeded with only a `.git` marker file, and a minimal local `CommandRunner` fake defined in the new test file (not exported by `collector-core.test.ts`, so not imported from it) that records every invoked argv and answers every command with a successful, empty result. It calls:

```ts
collectPrContext({
  base: "main",
  head: "feature/x",
  repoRoot: ROOT,
  includeUntracked: false,
  fs,
  runner,
  // no `whichGh` key
});
```

#### Required configuration keys and defaults:
None (no config surface changes).

#### Backward-compatibility expectations:
No public API changes; `CollectPrContextOptions` and `GhClientOptions` are unchanged.

#### Performance constraints (latency/throughput/memory):
None beyond the existing Jest suite's implicit fast-test expectation; the new test uses only in-memory fakes.

## Assumptions, Constraints, Dependencies
- Assumptions: `GhClient`'s constructor default resolver (`() => undefined`) and `hydrateAvailability`'s `!ghPath` early-return branch (both in `gh-client-core.ts`) are unchanged from the state verified in research.2026-09-27T00-30.md Section 1.2.
- Constraints: `extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts` is at 477/500 lines (23-line headroom) — a new file avoids further tightening that margin, per D2 below.
- External dependencies: none. The test uses only the existing `TreeFileSystem` fake (`./tree-file-system`) and a new minimal in-file `CommandRunner` fake.

## Design Decisions

- **D1 — Fix approach.** Options: (a) test-only — add a `collectPrContext` call that omits the `whichGh` key; (b) restructure the production conditional or widen `GhClientOptions.whichGh` to accept `undefined`; (c) exclude the branch via a coverage-ignore comment. **Adopted: (a).** Option (b) requires changing a public constructor option's type (`GhClientOptions.whichGh`) against the repository-wide `exactOptionalPropertyTypes: true` idiom used consistently elsewhere in this module (`collector-core.ts:135`, `gh-client-core.test.ts`'s `buildClient` helper, analogous git-client test helpers), and the issue's own "Expected Behavior" frames the fix as adding coverage, not eliminating the conditional. Option (c) is prohibited outright by the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md` (no production `exclude`/ignore entries for reachable branches). This matches the researcher's recommendation in research.2026-09-27T00-30.md Section 2.

- **D2 — Test home.** Options: extend `collector-core.test.ts` (477/500 lines — 23-line headroom); extend `collector-integration.test.ts` via `collectAndWrite` (172/500 lines, ample headroom, but only reaches the branch indirectly since `collectAndWrite` forwards its options object to `collectPrContext` unchanged); or a new dedicated file `extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts`. **Adopted: the new dedicated file**, `extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts`. This keeps every touched file comfortably under the 500-line limit, avoids narrowing `collector-core.test.ts`'s already-tight margin (relevant because sibling issue #716 may independently edit `collector-core.ts` and shift line counts, and any concurrent test-file edit would compound headroom risk), and does not collide with a sibling PR editing `collector-core.test.ts`. Reused helpers: `TreeFileSystem` is imported from `extensions/drm-copilot/test/lib/pr-context/tree-file-system.ts`, which already exports it (`export class TreeFileSystem implements FileSystem`) — no changes to that file are needed. `ScriptRunner`, `seedFeatureTree`, `buildRunner`, `ghHandler`, `gitHandler`, `GH_PATH`, and `ROOT` in `collector-core.test.ts` are module-local (not exported), so per the delegation instructions the new file defines its own minimal local fakes (`ROOT` constant and a small `CommandRunner` implementation) rather than importing or modifying them.

- **D3 — Assertion.** The new test asserts `result.ghAvailable === false` and that `result.ghStatusOverride` contains the literal substring `"GitHub CLI (gh) is not installed."` — the exact message defined at `extensions/drm-copilot/src/lib/pr-context/gh-client-core.ts:144` (`"GitHub CLI (gh) is not installed. Install from https://cli.github.com/."`), verified verbatim by reading that file. It additionally asserts that the injected runner recorded no invocation whose first argv element is `"gh"`, proving the default-resolver arm ran: research.2026-09-27T00-30.md Section 1.2 confirms `hydrateAvailability()` returns before calling `this.runnerValue.run(...)` whenever `ghPath` is falsy, and `GhClient.currentPr()` (`gh-client-details.ts`, `currentPrImpl`) checks `client.available` and returns `null` before any runner call, so no `gh` invocation occurs anywhere in the pipeline on this path.

- **D4 — Coverage observation.** The coverage reporters configured in `extensions/drm-copilot/jest.config.cjs` are `lcov` and `text-summary` only (no console per-file table). Per-file branch coverage for `collector-core.ts` is read from the `BRDA:` lines under that file's `SF:` section in `extensions/drm-copilot/coverage/lcov.info` after running the coverage command. The line containing the ternary must be located at execution time by the text anchor `whichGh === undefined` in `collector-core.ts`, not by a fixed line number (the line was 135 in research.2026-09-27T00-30.md but may shift). Both `BRDA` entries for that line (the `{}` arm and the `{ whichGh }` arm) must report nonzero hit counts after the change.

- **D5 — Merge-order independence with #716.** Sibling issue #716 (`compare-code-point-helper-duplicated`) may edit `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` and shift its line numbers and branch count. The branch-coverage acceptance criterion is therefore expressed relative to the Phase 0 baseline measured on the same tree immediately before this change (not the fixed 91.22% figure quoted in `issue.md`, which predates PR #704's regression), and this change writes no production file, so it cannot itself alter the file's branch count independent of whatever #716 does.

- **D6 — File manifest.** No production code change. The files this feature writes are exactly: `extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts` (new test file) plus feature-folder evidence under `docs/features/active/collector-core-no-whichgh-branch-untested-714/evidence/` (toolchain and coverage run records produced during implementation). `user-story.md` is explicitly not produced (full-bug work mode).

## Data / API / Config Impact
- User-facing or API changes: none.
- Data or migration considerations: none.
- Logging/telemetry updates: none.
- Compatibility notes: none — no CLI flags, config schemas, or public types change.

## Test Strategy
- Regression test to add: one `it` block in the new file `extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts`, named to describe the scenario (for example, `"runs the GhClient default-resolver arm and reports gh as not installed"` inside a `describe("collectPrContext (whichGh option omitted)", ...)` block).
- Unit test for the fixed behavior: the test calls `collectPrContext` with an options object literal that has no `whichGh` property (never `whichGh: undefined`, which `exactOptionalPropertyTypes: true` would reject at compile time as a type error since `WhichGh` has no `| undefined` in its declared type); this is the only way to make `options.whichGh === undefined` true through absence rather than assignment.
- Edge cases and negative scenarios: none beyond the single omitted-key scenario — downstream effects of `ghAvailable === false` (skipped `issueDetails`/`prDetails`/`ciStatus` calls) are already covered by the existing `"collectPrContext (gh unavailable)"` test in `collector-core.test.ts` and are not re-asserted here to avoid duplicate coverage of unrelated behavior.
- Error handling and logging verification: the test asserts the exact `ghStatusOverride` substring produced by `hydrateAvailability`'s `!ghPath` branch, and separately asserts that no `gh` argv was ever dispatched through the injected runner, confirming the code path taken.
- Coverage impact and targets: line coverage for `collector-core.ts` is unaffected (no lines added to the file). Branch coverage for `collector-core.ts` must rise above the Phase 0 baseline measured on the same tree immediately before this change (per D5); both `BRDA` entries for the `whichGh === undefined` conditional must be nonzero in `extensions/drm-copilot/coverage/lcov.info` after the change (per D4).
- Toolchain commands to run: `npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:coverage` (all within `extensions/drm-copilot`), in that order, restarting from `format` if any stage fails or modifies a file, per `.claude/rules/typescript.md` and `.claude/rules/general-code-change.md`.
- Determinism: the new test is deterministic. It spawns no real `gh` process (the injected `CommandRunner` fake never shells out), touches no real filesystem (the injected `TreeFileSystem` fake is entirely in-memory), depends on no host `PATH` entry (no `whichGh` resolver is supplied, and the fallback default resolver is a plain in-memory closure), depends on no `origin/main` state (the git responses are scripted), depends on no gitignored state, and uses no Windows-only paths (all paths are POSIX-style literals such as `/repo`, consistent with the rest of the pr-context test suite, and the coverage artifact path `extensions/drm-copilot/coverage/lcov.info` is the same on any OS running the npm scripts from `extensions/drm-copilot/`).
- Manual validation steps: none required; the change is fully covered by the automated toolchain.

## Acceptance Criteria
- [ ] A new Jest test in `extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts` calls `collectPrContext` with no `whichGh` option, so the `whichGh === undefined` arm of the `GhClient` construction in `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` is executed.
- [ ] Both arms of the `whichGh === undefined ? {} : { whichGh }` conditional (located by the text anchor `whichGh === undefined`, not a fixed line number) are reported covered — nonzero `BRDA` hit counts for both branch ids of that line — in `extensions/drm-copilot/coverage/lcov.info` for `collector-core.ts`.
- [ ] Branch coverage of `collector-core.ts` rises above the Phase 0 baseline measured on the same tree immediately before this change (expressed relative to that baseline, not the fixed 91.22% figure, because sibling issue #716 may independently change the file's branch count), and line coverage does not regress.
- [ ] The new test in `collector-core-default-resolver.test.ts` is deterministic: it spawns no real `gh` process, touches no real filesystem, and does not depend on the host `PATH`, on `origin/main`, on gitignored state, or on Windows-only paths.
- [ ] The full TypeScript toolchain (`npm run format`, `npm run lint`, `npm run typecheck`, `npm run test:coverage`, all within `extensions/drm-copilot`) passes with no production code changes.

## Risks & Mitigations
- Risk: a concurrent merge of sibling issue #716 shifts `collector-core.ts`'s line numbers or branch count before this branch merges. Mitigation: this spec's acceptance criteria and test locate the conditional by the text anchor `whichGh === undefined` rather than a fixed line number, and express the branch-coverage target relative to the Phase 0 baseline measured on the same tree rather than a fixed percentage (D5).
- Risk: the assertion on the injected runner's invocation list could become vacuous if a future change causes `hydrateAvailability` to call the runner even when `ghPath` is unset. Mitigation: the assertion is paired with the `ghStatusOverride` message assertion, so a behavior change that starts invoking the runner would still be caught by a mismatched status message or a newly nonzero runner-call assertion, not silently pass.

## Rollout & Follow-up
- Release/rollout steps: standard PR merge; no feature flag or staged rollout required (test-only change).
- Post-fix monitoring or clean-up tasks: none beyond confirming the coverage gate reflects the restored branch coverage in the next CI run.
- Links: issue #714; research `docs/features/active/collector-core-no-whichgh-branch-untested-714/research/research.2026-09-27T00-30.md`; prior related issue #588 (PR #704, the source of the regression) and its evidence at `docs/features/active/2026-08-28-pr-context-gh-detection-false-negative-588/evidence/qa-gates/ts-coverage-delta.2026-09-25T22-06.md`.
