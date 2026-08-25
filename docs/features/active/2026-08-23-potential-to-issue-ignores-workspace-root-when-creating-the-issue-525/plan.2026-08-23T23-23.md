# 2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue (Plan)

- **Issue:** #525
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-24T00-12
- **Status:** Revised after preflight; ready for re-preflight
- **Work Mode:** full-bug
- **Version:** 1.0

## Requirements Sources

- Sole acceptance-criteria source: `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/spec.md`, section `## Acceptance Criteria` (17 criteria), plus required behavior R1-R4 and error handling E1-E5.
- Defect record: `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/issue.md`.
- Investigation: `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/research/2026-08-23T23-40-workspace-root-gh-repo-selector-research.md`.
- `user-story.md` is intentionally absent under `full-bug` work mode and is not a blocker.

## Settled Design Decisions (do not reopen during execution)

1. **Resolution mechanism is fixed.** The target repository slug is resolved by running the GitHub CLI repository-view operation for the `nameWithOwner` field through the already-injected command runner, with the runner's working directory set to the resolved workspace root. Remote-URL parsing is rejected outright; no leg of the resolver reads a remote URL and no URL-parsing surface is created.
2. **Both omissions are fixed.** The argument vector gains an explicit `--repo` selector, and the resolver invocation supplies a working directory. Fixing only one leaves the defect reachable.
3. **Fail closed.** An unresolvable slug throws before any GitHub write and before the filesystem move. There is no implicit-resolution fallback.
4. **Python is out of scope.** The Python sibling exposes no workspace parameter, so the defect cannot be exhibited there. The only obligation that follows is correcting the stale parity claim in the TypeScript client docstring, in-file.
5. **The spec E3 bullet referring to an unrecognized remote-URL form is unreachable** under the adopted mechanism. It is annotated as unreachable rather than deleted (see [P5-T1]); deleting a bullet from an error-handling enumeration silently shrinks a stated requirement, while annotating preserves the audit trail and prevents a later reader from implementing a branch that cannot be reached. **No implementation branch and no test is planned for that bullet**, because a test for an unreachable branch cannot fail.
6. **No acceptance condition may rely on a compile error.** `extensions/drm-copilot/tsconfig.jest.json` sets `"isolatedModules": true`, so ts-jest transpiles each test module without producing type diagnostics. A test that references a property or constructor option that does not yet exist therefore runs to completion and fails on a value assertion instead of failing to compile. Every fail-before acceptance in this plan asserts a value-level or existence-level failure, never a compile diagnostic.
7. **The default slug resolver performs no PATH probe.** Because slug resolution runs unconditionally (see [P3-T4]), a default that called `defaultGhPathLookup` would execute a real `where`/`which` child process inside every pre-existing service-call unit test, which is both an external-process dependency prohibited by `.claude/rules/general-unit-test.md` and a source of machine-dependent nondeterminism. The service call therefore constructs its default resolver with a `gh` path lookup that returns the literal program name `gh`. In production the operating system resolves `gh` from PATH at spawn time (`SubprocessRunner` spawns with `shell: false`, and the platform loader searches PATH). An absent `gh` surfaces as a failed invocation, which the resolver's fail-closed branch converts into the unresolved-slug error, so decision 3 is preserved.

## Concrete Names Fixed by This Plan

Execution must use these exact identifiers so the acceptance conditions below are checkable.

- New module `extensions/drm-copilot/src/lib/potential-to-issue/repo-slug.ts` exports the function `resolveRepoSlug` and the error-message prefix constant `REPO_SLUG_UNRESOLVED_PREFIX`.
- `RealGhClient` gains an optional constructor option named `repo`.
- The service-call input gains an optional injected resolver seam named `repoSlugResolver`.
- The result field is `targetRepository` on the TypeScript contracts and `target_repository` on the MCP surface.
- The extracted seam-helper module for the extension-level suite is `extensions/drm-copilot/test/extension-potential-to-issue-test-support.ts`, following the `-test-support.ts` convention already used by `extensions/drm-copilot/test/lib/potential-to-issue/promotion-test-support.ts` and `extensions/drm-copilot/test/collect-commit-context-test-support.ts`.

## Write Set (authoritative for blast-radius derivation)

Production source:

- `extensions/drm-copilot/src/lib/potential-to-issue/gh-client.ts`
- `extensions/drm-copilot/src/lib/potential-to-issue/repo-slug.ts` (new)
- `extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts`
- `extensions/drm-copilot/src/repo-automation-service-contract.ts`
- `extensions/drm-copilot/src/mcp-tools.ts`

Test source:

- `extensions/drm-copilot/test/lib/potential-to-issue/gh-client.test.ts`
- `extensions/drm-copilot/test/lib/potential-to-issue/repo-slug.test.ts` (new)
- `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts`
- `extensions/drm-copilot/test/mcp-tools.potential-to-issue-target-repository.test.ts` (new)
- `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`
- `extensions/drm-copilot/test/extension-potential-to-issue-test-support.ts` (new)

The last two entries are seam-only updates forced by unconditional slug resolution, not assertion changes: no expected value asserted by any pre-existing test in either file is modified.

Configuration:

- `extensions/drm-copilot/jest.config.cjs`

Feature documents:

- `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/spec.md`
- `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/issue.md`

**Divergence from the supplied write set, stated explicitly:** the fourth test file above is added. Spec acceptance criterion 7 requires the echoed slug to be verified "through the full result projection chain rather than only at the service-call return", and the projection helper in the MCP tools module is not exported, so the only way to observe it is to dispatch a repo-automation tool against a mocked service. No existing test file is a correct home: the workspace-root test file covers the omitted-parameter failure envelope and never reaches the promotion path. The new file sits in the same test subtree as the other write-set test files, so it adds no module or shared-surface contention.

**Second divergence, stated explicitly:** the fifth and sixth test entries are added because slug resolution runs unconditionally, so two pre-existing suites that never previously reached the resolver now do. The extension-level suite stands at 497 lines and the repository limit is 500, so its seam helpers are extracted into the named sibling support module rather than growing the test file past the limit. That decision is fixed here, not left conditional, because this plan's stated paths feed a blast-radius computation that decides which work items run concurrently, and a conditional path cannot be scheduled.

Explicitly **not** written: any file under the policy-rules directory, the tier map, any instruction document, the Python promotion module or its pytest modules, the promotion workflow module or its shared test support, either tool-definitions module, the repo-automation service module, and the feature-promotion-lifecycle skill document or its bundled copies.

## Evidence Rules

- Every evidence artifact resolves under `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/` and one canonical kind: `baseline`, `regression-testing`, `qa-gates`, or `other`. Artifact paths rooted at `artifacts/` are prohibited and must be rejected if instructed.
- Every command-step artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`.
- Expect-fail artifacts additionally record `ExpectedExitCode: 1`.
- Test artifacts run in coverage mode record numeric line and branch percentages in `Output Summary:`.
- A task whose artifact is absent or incomplete stays unchecked.

## Known Limitations (recorded, not remediated by this plan)

1. **No gate in this plan type-checks the new test files.** `npm --prefix extensions/drm-copilot run typecheck` is `tsc -p ./ --noEmit`, and `extensions/drm-copilot/tsconfig.json` sets `"include": ["src/**/*.ts"]`, so the test tree is outside its program. ts-jest runs under `tsconfig.jest.json` with `"isolatedModules": true`, which transpiles without type diagnostics. Type errors confined to a test file are therefore caught only as runtime assertion failures, if at all. This plan records the gap rather than inventing a new gate, because adding a test-tree type-check program is a toolchain change outside the scope of this defect.
2. **The formatting command mutates the tree.** `npm --prefix extensions/drm-copilot run format` is `prettier --write` over `src`, `test`, `*.json`, and `*.cjs`, not a check. It can rewrite files that this plan does not claim. If it rewrites a file outside the Write Set, that path appears in the [P6-T6] diff audit and fails the Write Set assertion; the correct response is to revert the unrelated rewrite, not to widen the Write Set.

---

### Phase 0 — Policy Reads and TypeScript Baseline Capture

- [x] [P0-T1] Read the repository standing instructions file CLAUDE.md at the repository root in full and record the read in the Phase 0 policy artifact created by [P0-T4].
  - Acceptance: the Phase 0 artifact lists CLAUDE.md as the first entry under `Policy Order:`.
- [x] [P0-T2] Read `.claude/rules/general-code-change.md` and `.claude/rules/general-unit-test.md` in that order and record both reads in the Phase 0 policy artifact.
  - Acceptance: the Phase 0 artifact lists both file paths, in that order, as entries two and three under `Policy Order:`.
- [x] [P0-T3] Read `.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`, and `.claude/rules/quality-tiers.md` and record all three reads in the Phase 0 policy artifact.
  - Acceptance: the Phase 0 artifact lists all three file paths as entries four through six under `Policy Order:`.
- [x] [P0-T4] Write the Phase 0 policy-read artifact at `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/baseline/phase0-instructions-read.2026-08-23T23-23.md`.
  - Acceptance: the file exists and contains `Timestamp:`, `Policy Order:`, and an explicit list of the six files read in [P0-T1] through [P0-T3].
- [x] [P0-T5] Capture the TypeScript formatting baseline by running `npm --prefix extensions/drm-copilot run format` and write `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/baseline/ts-format.2026-08-23T23-23.md`. This command is `prettier --write` and mutates the tree; record every path it rewrote so an unrelated rewrite is visible before implementation begins.
  - Acceptance: the artifact records `Command: npm --prefix extensions/drm-copilot run format`, an integer `EXIT_CODE:`, and an `Output Summary:` naming how many files Prettier rewrote.
- [x] [P0-T6] Capture the TypeScript lint baseline by running `npm --prefix extensions/drm-copilot run lint` and write `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/baseline/ts-lint.2026-08-23T23-23.md`.
  - Acceptance: the artifact records `Command: npm --prefix extensions/drm-copilot run lint`, an integer `EXIT_CODE:`, and an `Output Summary:` stating the error and warning counts.
- [x] [P0-T7] Capture the TypeScript type-check baseline by running `npm --prefix extensions/drm-copilot run typecheck` and write `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/baseline/ts-typecheck.2026-08-23T23-23.md`.
  - Acceptance: the artifact records `Command: npm --prefix extensions/drm-copilot run typecheck`, an integer `EXIT_CODE:`, and an `Output Summary:` stating the diagnostic count.
- [x] [P0-T8] Capture the TypeScript test-and-coverage baseline by running `npm --prefix extensions/drm-copilot run test:coverage` and write `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/baseline/ts-test-coverage.2026-08-23T23-23.md`.
  - Acceptance: the artifact records `Command: npm --prefix extensions/drm-copilot run test:coverage`, an integer `EXIT_CODE:`, and an `Output Summary:` carrying the suite pass/fail counts and the numeric overall line and branch percentages from the coverage summary. No placeholder value such as UNVERIFIED is permitted.
- [x] [P0-T9] Record the pre-change per-file coverage numbers for `extensions/drm-copilot/src/lib/potential-to-issue/gh-client.ts`, `extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts`, `extensions/drm-copilot/src/mcp-tools.ts`, and `extensions/drm-copilot/src/repo-automation-service-contract.ts` from the coverage report produced by [P0-T8], in `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/baseline/ts-changed-file-coverage.2026-08-23T23-23.md`.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` listing four rows, each with a numeric line percentage and a numeric branch percentage.

---

### Phase 1 — Regression Tests That Must Fail First

- [ ] [P1-T1] [expect-fail] Create `extensions/drm-copilot/test/lib/potential-to-issue/repo-slug.test.ts` containing a single success test named `returns the nameWithOwner slug and runs with cwd set to the workspace root`, which injects a recording command runner and an injected `gh` path lookup, seeds a JSON payload carrying `nameWithOwner`, calls `resolveRepoSlug`, and asserts both the returned slug and that the recorded run options carry a working directory equal to the supplied workspace root. This task's fail-before is **existence-level only**: the suite fails because the module under test cannot be resolved, not because an assertion compared two values. That is the strongest fail-before achievable for a module that does not yet exist, and it is deliberately weaker than the value-level fail-before carried by [P1-T3] and [P1-T4].
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- potential-to-issue/repo-slug` exits non-zero because the module under test does not yet exist, and the evidence file `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/regression-testing/p1-t1-repo-slug.2026-08-23T23-23.md` records `Timestamp:`, that exact `Command:`, `ExpectedExitCode: 1`, a non-zero `EXIT_CODE:`, and an `Output Summary:` naming the unresolved-module diagnostic and stating explicitly that the failure is existence-level.
- [ ] [P1-T2] [expect-fail] Add three argument-boundary tests to `extensions/drm-copilot/test/lib/potential-to-issue/gh-client.test.ts`, named `binds the repo selector into the issue create vector`, `binds the repo selector into the label create vector`, and `binds the repo selector into the issue view vector`, each constructing `RealGhClient` with the recording runner, the injected path lookup, and the `repo` option, and asserting the full expected argument vector with the selector present. Per Settled Design Decision 6, the unknown `repo` constructor option produces no compile diagnostic under ts-jest; the tests run and fail on the exact-vector comparison because the recorded vector carries no repository selector.
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- potential-to-issue/gh-client` exits non-zero, and `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/regression-testing/p1-t2-gh-client.2026-08-23T23-23.md` records `Timestamp:`, that exact `Command:`, `ExpectedExitCode: 1`, a non-zero `EXIT_CODE:`, and an `Output Summary:` naming the failing exact-vector assertion and stating that the recorded vector carries no repository selector.
- [ ] [P1-T3] [expect-fail] Add a value-level test named `resolves the target repository from a workspace root that differs from the process working directory` to `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts`, arranging the in-memory filesystem fake, a fake `gh` client (so no `RealGhClient` is constructed and no real `gh` is located or executed), the recording command runner, and an injected `repoSlugResolver` that records the workspace value it was handed and returns a fixed slug, then asserting the resolver recorded exactly the supplied workspace root and the returned record's `targetRepository` equals that slug.
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- potential-to-issue/potential-to-issue-service-call --testNamePattern "differs from the process working directory"` exits non-zero, and `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/regression-testing/p1-t3-service-call-differing-root.2026-08-23T23-23.md` records `Timestamp:`, that exact `Command:`, `ExpectedExitCode: 1`, a non-zero `EXIT_CODE:`, and an `Output Summary:` stating that the resolver recorded nothing and the field was absent.
- [ ] [P1-T4] [expect-fail] Add a second value-level test named `resolves the target repository when the workspace root matches the process working directory` to the same file, arranging the in-memory filesystem fake, a fake `gh` client (so no `RealGhClient` is constructed and no real `gh` is located or executed), the recording command runner, and an injected `repoSlugResolver`, with the workspace root set to the process working directory, and asserting the resolver recorded that path, the record echoes that checkout's slug, and the pre-existing `summary`, `destinationPath`, and `artifacts` assertions hold with unchanged expected values.
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- potential-to-issue/potential-to-issue-service-call --testNamePattern "matches the process working directory"` exits non-zero, and `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/regression-testing/p1-t4-service-call-matching-root.2026-08-23T23-23.md` records `Timestamp:`, that exact `Command:`, `ExpectedExitCode: 1`, a non-zero `EXIT_CODE:`, and an `Output Summary:` stating the failing assertion.
- [ ] [P1-T5] Write the consolidated fail-before summary at `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/regression-testing/fail-before-summary.2026-08-23T23-23.md`, cross-referencing the four artifacts produced by [P1-T1] through [P1-T4].
  - Acceptance: the file exists, contains `Timestamp:`, and lists the four artifact filenames together with each recorded non-zero `EXIT_CODE:` value and a one-line statement of which of the two required cases (differing workspace root, matching workspace root) each covers.

---

### Phase 2 — Slug Resolver Module

- [ ] [P2-T1] Create `extensions/drm-copilot/src/lib/potential-to-issue/repo-slug.ts` exporting `resolveRepoSlug` and `REPO_SLUG_UNRESOLVED_PREFIX`. The function takes an injected command runner, a workspace root, and an optional `gh` path lookup; it runs the repository-view operation for the `nameWithOwner` field with the working directory set to the workspace root and with non-zero exits tolerated by the runner; it returns the slug on success and throws an `Error` whose message begins with `REPO_SLUG_UNRESOLVED_PREFIX` and names the workspace root otherwise.
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- potential-to-issue/repo-slug --testNamePattern "returns the nameWithOwner slug"` exits with `EXIT_CODE: 0` and reports 1 passing test.
- [ ] [P2-T2] Add the failure-branch tests to `extensions/drm-copilot/test/lib/potential-to-issue/repo-slug.test.ts`, one test per condition, named `throws when the checkout has no origin remote`, `throws when the resolution command exits non-zero`, `throws when the command produces empty output`, `throws when the output is not valid JSON`, `throws when the payload is parseable but is not an object`, `throws when the owner and name field is missing`, and `throws when the owner and name field is not a string`.
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- potential-to-issue/repo-slug` exits with `EXIT_CODE: 0` and reports 8 passing tests in that file.
- [ ] [P2-T3] Add a test named `names the workspace root in the thrown message` to the same file, asserting the thrown message contains both `REPO_SLUG_UNRESOLVED_PREFIX` and the exact workspace-root string supplied to the call.
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- potential-to-issue/repo-slug` exits with `EXIT_CODE: 0` and reports 9 passing tests in that file.

---

### Phase 3 — Repository Binding, Threading, and Result Projection

- [ ] [P3-T1] Add the optional `repo` constructor option to `RealGhClient` in `extensions/drm-copilot/src/lib/potential-to-issue/gh-client.ts`, store it on the instance, and insert the selector flag and its value immediately after the subcommand words in `issueCreate` when the option is present.
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- potential-to-issue/gh-client --testNamePattern "binds the repo selector into the issue create vector"` exits with `EXIT_CODE: 0` and reports 1 passing test.
- [ ] [P3-T2] Insert the same selector flag and value in `ensureLabel` and `issueView` in `extensions/drm-copilot/src/lib/potential-to-issue/gh-client.ts` when the `repo` option is present, leaving the vectors unchanged when it is absent.
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- potential-to-issue/gh-client` exits with `EXIT_CODE: 0`, and the three pre-existing exact-vector tests pass with their expected values unmodified.
- [ ] [P3-T3] Correct the `Parity:` block of the module docstring in `extensions/drm-copilot/src/lib/potential-to-issue/gh-client.ts` so it no longer claims the argument vectors are byte-identical to the Python source, and instead states that the repository selector is a deliberate TypeScript-only divergence, with the reason that the Python command-line surface exposes no workspace parameter. The phrase to remove from the `Parity:` block is `are byte-identical to the Python source`, and the replacement wording must not reintroduce it. The second occurrence, in the `GH_NOT_FOUND_MESSAGE` docstring, is a separate claim about the error message that remains true and must be left intact.
  - Acceptance: `git grep -n -F "are byte-identical to the Python source" -- extensions/drm-copilot/src/lib/potential-to-issue/gh-client.ts` exits non-zero (zero matches) after the edit, whereas it exits zero before the edit.
- [ ] [P3-T4] In `extensions/drm-copilot/src/lib/potential-to-issue/potential-to-issue-service-call.ts`, add the optional `repoSlugResolver` seam to the input interface; resolve the slug from the resolved workspace root unconditionally, before the `input.gh ?? new RealGhClient(...)` expression is evaluated, so the resolver runs whether or not a fake `gh` client is injected; pass the resolved slug into the `RealGhClient` construction as the `repo` option; add the optional `targetRepository` property to the service-call result interface; and populate it from the resolved slug in the returned record. Per Settled Design Decision 7, construct the default resolver with a `gh` path lookup that returns the literal program name `gh` and performs no PATH probe, so a test that injects only a stub runner spawns no child process.
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- potential-to-issue/potential-to-issue-service-call --testNamePattern "process working directory"` exits with `EXIT_CODE: 0` and reports 2 passing tests.
- [ ] [P3-T5] Update the shared `makeRunner` stub in `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` so it returns the JSON payload `{"nameWithOwner":"drmoisan/drm-copilot"}` on stdout for the repository-view argument vector and the pre-existing empty result for every other vector. Change no expected value asserted by any of the eight pre-existing tests. This is required because all eight pre-existing tests use `makeRunner`, which returns empty stdout, and empty output is an E3 unresolvable condition, so every one of them would otherwise throw once slug resolution runs unconditionally.
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- potential-to-issue/potential-to-issue-service-call` exits with `EXIT_CODE: 0`.
- [ ] [P3-T6] Add the optional `targetRepository` property to the execution-result interface in `extensions/drm-copilot/src/repo-automation-service-contract.ts`, leaving every other property unchanged.
  - Acceptance: `npm --prefix extensions/drm-copilot run typecheck` exits with `EXIT_CODE: 0`.
- [ ] [P3-T7] Add the optional `target_repository` property to the MCP tool-result interface in `extensions/drm-copilot/src/mcp-tools.ts` and add the matching conditional spread to the projection helper so the field is emitted when present and omitted when absent.
  - Acceptance: `npm --prefix extensions/drm-copilot run typecheck` exits with `EXIT_CODE: 0` and `npm --prefix extensions/drm-copilot run lint` exits with `EXIT_CODE: 0`.
- [ ] [P3-T8] Add a fail-closed test named `fails closed without creating an issue or moving the record when the slug cannot be resolved` to `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts`, injecting a `repoSlugResolver` that throws, and asserting the call rejects with a message containing the workspace root, that the recording command runner recorded zero issue-creation invocations, and that the in-memory filesystem fake still holds the potential record at its original path.
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- potential-to-issue/potential-to-issue-service-call --testNamePattern "fails closed without creating an issue"` exits with `EXIT_CODE: 0` and reports 1 passing test.

---

### Phase 4 — Recovery Leg, Extension Seam, Projection Chain, and Coverage Configuration

- [ ] [P4-T1] Add a test named `carries the same repo selector on the missing-label recovery retry` to `extensions/drm-copilot/test/lib/potential-to-issue/gh-client.test.ts`, driving one bound client through issue creation, label creation, and a second issue creation, and asserting all three recorded vectors carry the identical selector value.
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- potential-to-issue/gh-client --testNamePattern "missing-label recovery retry"` exits with `EXIT_CODE: 0` and reports 1 passing test.
- [ ] [P4-T2] Add a test named `leaves the three vectors unchanged when no repo is supplied` to `extensions/drm-copilot/test/lib/potential-to-issue/gh-client.test.ts`, constructing the client without the `repo` option and asserting the issue-creation, label-creation, and issue-view vectors equal their pre-change forms exactly.
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- potential-to-issue/gh-client --testNamePattern "unchanged when no repo is supplied"` exits with `EXIT_CODE: 0` and reports 1 passing test.
- [ ] [P4-T3] Extract the in-process seam helpers out of `extensions/drm-copilot/test/extension.potential-to-issue.test.ts` into the new sibling module `extensions/drm-copilot/test/extension-potential-to-issue-test-support.ts`, which exports the feature-content constant and a factory that accepts the `node:fs` and `node:child_process` mock handles and returns the seam-installing function, leaving the `jest.mock` registrations and every call site in the test file unchanged; then extend `installInProcessSeams` with a repository-view branch whose stdout is `Buffer.from('{"nameWithOwner":"drmoisan/drm-copilot"}')`. A plain string is discarded: `SubprocessRunner.run` reads stdout only when it is a `Buffer`. The new branch must match the repository-view argument vector irrespective of the executable token, because per Settled Design Decision 7 the resolver invokes the bare program name `gh` rather than the seeded lookup path. The extraction is mandatory rather than optional: the test file stands at 497 lines and the repository file-size limit is 500, so adding the branch in place would exceed it.
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- extension.potential-to-issue` exits with `EXIT_CODE: 0`, and `extensions/drm-copilot/test/extension.potential-to-issue.test.ts` is at most 500 lines.
- [ ] [P4-T4] Create `extensions/drm-copilot/test/mcp-tools.potential-to-issue-target-repository.test.ts` with a test named `projects the target repository onto the potential to issue MCP result`, dispatching the promotion tool against a mocked repo-automation service whose execution result carries `targetRepository`, and asserting the dispatched MCP result carries the snake-cased key with the same value.
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- mcp-tools.potential-to-issue-target-repository --testNamePattern "projects the target repository"` exits with `EXIT_CODE: 0` and reports 1 passing test.
- [ ] [P4-T5] Add a test named `omits the target repository key for tools that resolve none` to `extensions/drm-copilot/test/mcp-tools.potential-to-issue-target-repository.test.ts`, dispatching a different repo-automation tool whose execution result omits `targetRepository`, and asserting the snake-cased key is absent from the dispatched result and that every other key is unchanged.
  - Acceptance: `npm --prefix extensions/drm-copilot run test -- mcp-tools.potential-to-issue-target-repository` exits with `EXIT_CODE: 0` and reports 2 passing tests in that file.
- [ ] [P4-T6] Add per-changed-file coverage threshold entries of 85 lines and 75 branches for `./src/lib/potential-to-issue/gh-client.ts`, `./src/lib/potential-to-issue/repo-slug.ts`, and `./src/lib/potential-to-issue/potential-to-issue-service-call.ts` to the threshold map in `extensions/drm-copilot/jest.config.cjs`, and add an inline comment recording that the interface-only contract file remains excluded from the threshold gate for the reason already documented in that file.
  - Acceptance: `npm --prefix extensions/drm-copilot run test:coverage` exits with `EXIT_CODE: 0`, which requires all three new threshold entries to be satisfied.

---

### Phase 5 — Feature Document Updates

- [ ] [P5-T1] In `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/spec.md`, annotate the E3 bullet that refers to an unrecognized remote-URL form as unreachable under the adopted mechanism, cross-referencing E4, without deleting the bullet. Rationale, recorded in the annotation: the adopted resolver reads no remote URL on any leg, so the condition cannot arise; deleting the bullet would silently shrink a stated requirement enumeration, while annotating preserves the audit trail and prevents a later reader from implementing an unreachable branch.
  - Acceptance: the E3 list in that file still contains six bullets, and the sixth bullet carries an explicit unreachability annotation naming E4.
- [ ] [P5-T2] Update the `- **Last Updated:**` and `- **Status:**` metadata lines in `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/spec.md` to reflect the implemented state, leaving the `- **Work Mode:** full-bug` marker unchanged.
  - Acceptance: the file's `- **Work Mode:**` line still reads `full-bug`, and the `- **Status:**` line no longer reads `Specified`.
- [ ] [P5-T3] Update `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/issue.md` to record the delivered fix under `## Proposed Fix / Validation Ideas`, including the recorded `scope_change` disposition that replaced the live integration retest with hermetic argument-boundary assertions, and mirror the same text at `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/issue-updates/issue-525.2026-08-23T23-23.md`.
  - Acceptance: the mirror artifact exists and contains `Timestamp:`, the exact text written into the issue document, and a `PostedAs:` line.

---

### Phase 6 — Final QA Loop and Acceptance Verification

The loop order is formatting, then linting, then type checking, then testing in coverage mode. If any step fails or rewrites files, restart this phase from [P6-T1].

- [ ] [P6-T1] Run the TypeScript formatting gate `npm --prefix extensions/drm-copilot run format` and write `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/qa-gates/ts-format.2026-08-23T23-23.md`. This command is `prettier --write` and mutates the tree; if it rewrites a file outside the Write Set, revert that unrelated rewrite rather than widening the Write Set, because the path would otherwise fail the [P6-T6] audit.
  - Acceptance: the artifact records `Command: npm --prefix extensions/drm-copilot run format`, `EXIT_CODE: 0`, and an `Output Summary:` stating whether any file was rewritten and naming each rewritten path; if any file was rewritten, this phase restarts from this task.
- [ ] [P6-T2] Run the TypeScript lint gate `npm --prefix extensions/drm-copilot run lint` and write `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/qa-gates/ts-lint.2026-08-23T23-23.md`.
  - Acceptance: the artifact records `Command: npm --prefix extensions/drm-copilot run lint`, `EXIT_CODE: 0`, and an `Output Summary:` stating zero errors and zero warnings.
- [ ] [P6-T3] Run the TypeScript type-check gate `npm --prefix extensions/drm-copilot run typecheck` and write `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/qa-gates/ts-typecheck.2026-08-23T23-23.md`.
  - Acceptance: the artifact records `Command: npm --prefix extensions/drm-copilot run typecheck`, `EXIT_CODE: 0`, and an `Output Summary:` stating zero diagnostics.
- [ ] [P6-T4] Run the TypeScript test-and-coverage gate `npm --prefix extensions/drm-copilot run test:coverage` and write `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/qa-gates/ts-test-coverage.2026-08-23T23-23.md`.
  - Acceptance: the artifact records `Command: npm --prefix extensions/drm-copilot run test:coverage`, `EXIT_CODE: 0`, and an `Output Summary:` carrying the suite and test pass counts and the numeric overall line and branch percentages. No placeholder value is permitted.
- [ ] [P6-T5] Write the coverage-delta comparison at `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/other/coverage-delta.2026-08-23T23-23.md`, comparing the baseline numbers from [P0-T9] against the post-change numbers from [P6-T4] for each write-set source file and the new resolver module.
  - Acceptance: the artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` containing one row per file with baseline line percentage, post-change line percentage, baseline branch percentage, post-change branch percentage, and an explicit statement that no changed file regressed and that every gated file meets 85 lines and 75 branches.
- [ ] [P6-T6] Audit the branch diff against the declared write set and write `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/other/write-set-diff-audit.2026-08-23T23-23.md` from the output of `git diff --name-only origin/main...HEAD`. The remote-tracking ref is required: the local `main` ref is ahead of this branch's base, so a diff taken against it is dominated by an unrelated archival commit.
  - Acceptance: the artifact records `Timestamp:`, `Command: git diff --name-only origin/main...HEAD`, `EXIT_CODE: 0`, and an `Output Summary:` confirming that the Python promotion module, its three dedicated pytest modules, the feature-promotion-lifecycle skill document and its bundled copies, every policy-rules file, the tier map, and both tool-definitions modules each appear zero times in the diff, and that every path in the diff appears in the Write Set section of this plan.
- [ ] [P6-T7] Re-run the four regression suites in one pass with `npm --prefix extensions/drm-copilot run test -- potential-to-issue` and record the pass-after evidence at `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/regression-testing/pass-after.2026-08-23T23-23.md`.
  - Acceptance: the artifact records `Command: npm --prefix extensions/drm-copilot run test -- potential-to-issue`, `EXIT_CODE: 0`, and an `Output Summary:` stating the number of passing tests and confirming that each of the tests named in [P1-T1] through [P1-T4], [P2-T2], [P2-T3], [P3-T8], [P4-T1], and [P4-T2] passed.
- [ ] [P6-T8] Check off all 17 criteria in the `## Acceptance Criteria` section of `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/spec.md` and record the mapping at `docs/features/active/2026-08-23-potential-to-issue-ignores-workspace-root-when-creating-the-issue-525/evidence/other/acceptance-criteria-checkoff.2026-08-23T23-23.md`. Criterion 17 names seven toolchain stages, and only four have a configured runner in `extensions/drm-copilot/package.json` (`format`, `lint`, `typecheck`, `test`); the mapping artifact must record the architecture-boundary, contract/schema, and integration stages as `n/a — no configured runner in extensions/drm-copilot/package.json`.
  - Acceptance: the spec file's `## Acceptance Criteria` section contains 17 checked boxes and zero unchecked boxes, and the mapping artifact records `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` with 17 numbered rows, each naming the criterion, the task identifier that satisfied it, and the evidence artifact filename that proves it, plus the three stages recorded as having no configured runner.

---

## Out-of-Scope Reminders for the Executor

- Do not add a remote-URL parsing surface on any leg.
- Do not add a fallback to implicit repository resolution; the failure path throws.
- Do not modify the Python promotion module, its pytest modules, the promotion workflow module, the shared promotion test support, either tool-definitions module, the repo-automation service module, the MCP provider module, any policy-rules file, the tier map, or the feature-promotion-lifecycle skill document or its bundled copies.
- Do not change any expected value asserted by a pre-existing test in `extensions/drm-copilot/test/lib/potential-to-issue/potential-to-issue-service-call.test.ts` or `extensions/drm-copilot/test/extension.potential-to-issue.test.ts`; the updates to those two files are seam arrangement only.
- Do not write any evidence artifact outside the feature folder's `evidence/` tree.
