# Code Review: collector-core-no-whichgh-branch-untested (#714)

---

**Review Date:** 2026-09-27
**Reviewer:** feature-review agent (Claude Sonnet 5)
**Feature Folder:** `docs/features/active/collector-core-no-whichgh-branch-untested-714`
**Feature Folder Selection Rule:** Selected because its suffix (`-714`) matches the issue number carried in the branch name `bug/collector-core-no-whichgh-branch-untested-714`, and it is the only active feature folder with material scoping-doc changes in this diff.
**Base Branch:** `origin/main` (resolved base, at commit `daae7f79`)
**Head Branch:** `bug/collector-core-no-whichgh-branch-untested-714` (commit `300d05e4`)
**Review Type:** Initial review

---

## Executive Summary

This is a test-only, coverage-restoration change. It adds one Jest test, `extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts` (73 lines, new), that calls `collectPrContext` without a `whichGh` option, exercising the previously-untested `whichGh === undefined` arm of the conditional spread at `extensions/drm-copilot/src/lib/pr-context/collector-core.ts:136`. No production file is changed by this branch (verified: `git diff origin/main...HEAD --name-status` shows a single `A` entry for the test file and no path under `extensions/drm-copilot/src/`). The change is minimal, self-contained, and does not alter runtime behavior.

**What changed:**
Exactly one new file relative to `origin/main`: the test file above. The remaining 25 changed paths in the branch diff are feature-folder documentation and evidence artifacts under `docs/features/active/collector-core-no-whichgh-branch-untested-714/`.

**Top 3 risks:**
1. None identified as blocking. The most notable residual item is a documented, non-code v8/istanbul coverage-instrumentation artifact (the anchor line's `BRDA:` entry count grew from one to two after the test was added) — explained below and confirmed as a tooling behavior, not a defect.
2. The test's `.git`-marker-only `TreeFileSystem` seeding for `GitClient.resolveRoot()` was not independently re-verified line-by-line against `git-client.ts` in this review pass; it is corroborated by the observed test pass and empty `RecordingRunner.calls`, which is consistent with no shell-out occurring.
3. The repository's test tree uses a singular `test/` directory instead of the general policy document's literal `tests/` example; this is a pre-existing, project-wide convention unrelated to this branch.

**PR readiness recommendation:** **Go** — the change is narrowly scoped, correctly targets the stated coverage gap, introduces no new risk surface, and all toolchain and coverage evidence is verified and passing.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|

No Blockers or Major findings. No Minor or Nit findings were identified either; the change is narrowly scoped test-only code with no defects found during this review.

---

## Implementation Audit

### TypeScript implementation audit

#### What changed well

- The test targets the public `collectPrContext` entry point only; it does not reach into `GhClient` or `hydrateAvailability` internals, keeping the test coupled to behavior rather than implementation.
- The test's Act step omits the `whichGh` key entirely from the options object literal (not `whichGh: undefined`), which is the only way to make `options.whichGh === undefined` true through absence rather than assignment under `exactOptionalPropertyTypes: true`. Verified directly: the `collectPrContext(...)` call (lines 55-62 of the test file) contains no `whichGh` property at all.
- The fake `CommandRunner` (`RecordingRunner`) is the minimum needed to observe whether a `gh` invocation occurred, and it is defined locally rather than imported from `collector-core.test.ts` because that file's fakes (`ScriptRunner`, `buildRunner`, and others) are module-private and not exported (confirmed: no export of those names appears in `collector-core.test.ts`).
- The test reuses the existing `TreeFileSystem` fake from `./tree-file-system` rather than duplicating filesystem-fake logic — the correct reuse boundary, since that fake's behavior is shared infrastructure while the test-specific `CommandRunner` fake is unique to this test's needs.
- No production code is touched, consistent with `spec.md`'s D1 design decision (test-only fix, rejecting a production-side restructure), since the conditional exists specifically to satisfy `exactOptionalPropertyTypes: true`.

#### Type safety and maintainability

- Type-only imports (`type CommandResult`, `type CommandRunner`, `type CommandRunOptions`) are correctly separated from the value import (`collectPrContext`) (verified by direct read).
- `RecordingRunner implements CommandRunner` with a fully-typed `run` method signature; no `any` is used anywhere in the file.
- The `void _options;` statement in `run` (line 39) is a pre-existing repository idiom for satisfying `@typescript-eslint/no-unused-vars` on an intentionally-unused parameter, matching the pattern used elsewhere in the test suite (for example `test/lib/new-active-feature-folder/fakes.ts`, per the plan's citation). This is a minimal-footprint choice rather than a suppression comment.
- No unauthorized suppressions (`eslint-disable`, `@ts-expect-error`, `@ts-ignore`, `@ts-nocheck`) appear anywhere in the file.
- File size is 73 lines, well within the 500-line policy limit.

#### Error handling and logging

- No production error-handling code is touched. The new test asserts on the existing literal message `"GitHub CLI (gh) is not installed."` (a substring match via `toContain`), which is corroborated verbatim against `gh-client-core.ts:144` in `spec.md`'s D3 design-decision record.
- The assertions target the exact code path being exercised:
  - `expect(result.ghAvailable).toBe(false)` and `expect(result.ghStatusOverride).toContain(...)` verify the `hydrateAvailability()` early-return path ran.
  - `expect(runner.calls.some((argv) => argv[0] === "gh")).toBe(false)` verifies no `gh` process invocation occurred, which is the behavioral signature of the default-resolver arm actually running (as opposed to, for example, a resolver that returns a truthy but unused value).

---

## Test Quality Audit

The reviewed evidence demonstrates deterministic, isolated, fast unit-test coverage of exactly the branch the change targets, with a verified repo-wide and per-file coverage delta.

### Reviewed test and QA artifacts

- `extensions/drm-copilot/test/lib/pr-context/collector-core-default-resolver.test.ts` — the new test itself; verifies the `whichGh === undefined` default-resolver arm executes and no `gh` process is invoked.
- `docs/features/active/collector-core-no-whichgh-branch-untested-714/evidence/qa-gates/verify-new-test.2026-09-27T10-30.md` — isolated run of the new test: exit 0, 1 passed, 0.459 s.
- `docs/features/active/collector-core-no-whichgh-branch-untested-714/evidence/qa-gates/final-typescript-test-coverage.2026-09-27T10-30.md` — full-suite run: exit 0, 3143/3143 passing, 96.95% lines / 90.91% branches repo-wide.
- `docs/features/active/collector-core-no-whichgh-branch-untested-714/evidence/qa-gates/coverage-delta-collector-core.2026-09-27T10-30.md` — per-file `collector-core.ts` delta: branch coverage 90.3846% -> 92.4528%, line coverage unchanged at 98.4456%.
- `extensions/drm-copilot/coverage/lcov.info` — independently re-parsed during this review: `SF:src\lib\pr-context\collector-core.ts` block confirms `LF:386`, `LH:380`, `BRDA:136,2,0,1`, `BRDA:136,3,0,52`, matching the evidence artifacts above.

No gap remains: the coverage gap this bugfix targets is fully closed, and no unrelated regression was introduced.

### Quality assessment prompts

- **Determinism:** no `jest.mock`, `jest.spyOn`, or fake timers are used; the fake `RecordingRunner` is a plain class with fully deterministic behavior (always returns `{ stdout: "", stderr: "", code: 0 }`). No real filesystem, network, or process I/O; no dependency on host `PATH`, `origin/main`, or gitignored state.
- **Isolation:** the single `it` targets exactly one behavior (the default-resolver arm); no shared or global state is used across tests.
- **Speed:** 0.459 s isolated, 5.531 s for the full 3143-test suite — both fast by the repository's existing standards.
- **Diagnostics:** each of the three assertions (`ghAvailable`, `ghStatusOverride` substring, absence of a `"gh"` argv call) targets a distinct, specific concern, so a failure would identify precisely which behavior regressed.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | No credential, token, or secret literal appears in the new file (verified by direct read). |
| No unsafe subprocess or command construction | PASS | The test uses only an in-memory `RecordingRunner` fake; no real subprocess is spawned. Production `collector-core.ts`/`gh-client-core.ts` code is unchanged by this branch. |
| Input validation at boundaries | N/A | Test-only change; no new input-boundary code is introduced. |
| Error handling remains explicit | PASS | The test asserts on the specific, existing error-status message rather than swallowing or genericizing it. |
| Configuration / path handling is safe | PASS | The only path used is the literal `/repo` constant (`ROOT`), consistent with the rest of the pr-context test suite's POSIX-style literals; no host-path or environment-derived path is used. |

---

## Research Log

No external research was required for this review. All findings are based on direct inspection of the new test file, the referenced production source files (`collector-core.ts`, `gh-client-core.ts`), the branch diff (`git diff origin/main...HEAD`), the feature folder's `spec.md` design-decision records, and the feature folder's evidence artifacts under `evidence/`.

---

## Verdict

The change is ready for normal PR flow. It is a narrowly-scoped, test-only coverage-restoration fix that correctly targets a specific, previously-untested branch, introduces no production code change, uses only deterministic in-memory fakes, and is corroborated by verified toolchain and coverage evidence (format, lint, type-check, and test-with-coverage all exit 0; repo-wide and per-file coverage both meet or exceed policy thresholds with no regression). No Blocking, Major, Minor, or Nit finding was identified. This conclusion is consistent with the empty Findings Table and the Go recommendation above.
