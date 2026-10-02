# 2026-09-07-test-tree-typecheck-not-gated (Spec)

- **Issue:** #647
- **Parent (optional):** none
- **Related:** #645 (R20 consolidated into this item; R16-R19 excluded)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source; no `user-story.md`)
- **Research:** `research/research.2026-09-29T20-20.md`
- **Baseline evidence:** `evidence/baseline/tsc-jest-diagnostics.2026-09-29T20-15.log` (origin/main 43c9e95e)

## Context

The TypeScript test tree of the `extensions/drm-copilot` extension is not type-checked by any enforced gate.

- `npm run typecheck` (`extensions/drm-copilot/package.json:209`, `tsc -p ./ --noEmit`) uses `tsconfig.json`, whose `include` is `["src/**/*.ts"]`.
- `tsconfig.jest.json` is the only configuration that includes `test/**/*.ts`. It sets `isolatedModules: true`, so ts-jest compiles each file with `transpileModule`, which reports only syntactic diagnostics.
- No workflow runs `tsc` against `tsconfig.jest.json`. `_drm-copilot-extension-tests.yml` runs only `npm ci` and `npm run test`.

At the baseline revision, `node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit` exits non-zero. The diagnostics are in test files, in three shared test helpers, and in two production files: `src/lib/codex-native-converter/models.ts` and `src/lib/codex-native-converter/index.ts`. The production files emit TS1205 for interface re-exports that lack a `type` modifier under `isolatedModules`. The research record groups the diagnostics into mechanical fix classes C1-C11 (research Section 2) and assigns them to phases (research Section 3). The issue text reports earlier figures; the research record gives updated figures for 43c9e95e. The acceptance criteria below do not assert a diagnostic or file count. They require zero diagnostics, which does not depend on the size of the backlog.

Environment:
- OS/version: Windows 11 Pro 10.0.26200; CI runs `windows-latest` and `ubuntu-latest`
- Python version: not applicable
- Command/flags used: `node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit`
- Data source or fixture: repository at origin/main 43c9e95e; `extensions/drm-copilot/tsconfig.json`, `tsconfig.jest.json`, `package.json`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Type errors in tests do not fail CI, so test code can drift from production types. #645 R20 is an example: a request literal is missing the required independent-context fields, and the suite still passes. Coverage and behavior gates still hold. The gap affects long-term test quality and has not caused a shipped defect.

## Repro & Evidence

Steps to Reproduce:
1. From the repository root, run `npm --prefix extensions/drm-copilot run typecheck`. It exits 0.
2. Run `node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit`.
3. It exits non-zero and prints `error TS` diagnostics for test files and for the two `codex-native-converter` production files.

Expected:
The test tree type-checks with exit 0, and CI enforces that check.

Actual:
`npm run typecheck` reports success while the jest configuration reports type errors. No CI job fails on them.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Baseline log: `evidence/baseline/tsc-jest-diagnostics.2026-09-29T20-15.log`.
- Earlier record: `docs/features/completed/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/typescript-test-tree-typecheck.2026-09-07T03-16.md`.

## Scope & Non-Goals

- In scope:
  - Fix every diagnostic reported by `tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit` so the command exits 0. This includes the two production files `src/lib/codex-native-converter/models.ts` and `src/lib/codex-native-converter/index.ts`, where the only change is the `type` modifier on type-only re-export specifiers.
  - #645 R20: the `TransitionPreparedOrchestrationRequest` literal in `test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts` includes all `INDEPENDENT_CONTEXT` fields from `orchestration-handoff-materializer-test-support.ts`. It overrides `expectedWorkspaceRoot` to match the scenario's `workspaceRoot`.
  - Add an enforced gate:
    - `typecheck:test` npm script.
    - `typecheck` chained to `typecheck:test`.
    - A CI step in `.github/workflows/_drm-copilot-extension-tests.yml` that runs the extension `typecheck` script.
  - Add a regression test, `extensions/drm-copilot/test/package-typecheck-script.test.ts`, that asserts the gate wiring.
  - The gate is green in the same change that adds it.
- Out of scope / non-goals:
  - #645 R16, R17, R18, and R19.
  - Root-package TypeScript (`tsconfig.json`, `tsconfig.tests.json`, root `package.json`). Root `pretest` already type-checks the root test tree (research Section 6.3).
  - Refactoring files that already exceed 500 lines, including `test/extension.workflow-commands.test.ts`. The only requirement for these files is that they do not grow.
  - Adding the extension `lint` script to CI, or changing the ESLint configuration to a type-checked rule set (research Section 6.4).
  - Changing `compile`, `build`, `test`, `test:unit`, or `test:coverage`, or adding `pretest` or `vscode:prepublish` hooks.
  - Changing `isolatedModules` or other ts-jest transform options.
  - A baseline ratchet or suppression file. This was rejected in research Section 3.2.
  - Consolidating local `VirtualFileSystem` fakes into a shared module. This was rejected in research Section 3.2.
- Explicitly excluded systems, integrations, or datasets: publish workflows (`publish-extension.yml`, `publish-mcp-npm.yml`) and the esbuild bundle configuration.

## Root Cause Analysis

The configuration was never set up to type-check the test tree, and no gate replaced it:

1. `tsconfig.json` is scoped to `src/**` to keep the production build clean. The `typecheck`, `compile`, and `build` scripts all use it, so none of them sees `test/**`.
2. `tsconfig.jest.json` was added for ts-jest module resolution, not as a gate. Its `isolatedModules: true` makes ts-jest (29.4.14) skip the language service (`ts-jest/dist/legacy/compiler/ts-compiler.js:78`, `:97`) and use `transpileModule`, so semantic errors cannot fail a Jest run.
3. No workflow or script runs `tsc` against `tsconfig.jest.json`.

As a result, the test tree drifted from production types in several ways:
- `FileSystem` gained `exists`, `isDirectory`, and `listDirectory`.
- `@jest/globals` 30 types a bare `jest.fn()` as `Mock<UnknownFunction>`.
- Strict flags (`noPropertyAccessFromIndexSignature`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`) were not satisfied.
- Request contracts gained required fields (R20).

The TS1205 errors in the two production files appear only under `isolatedModules`, which `tsconfig.json` does not set.

## Proposed Fix

### Design summary (what changes where):

1. **Test-tree type fixes (research Phases 1-7).** Apply the class fix patterns in research Section 2:
   - Give mocks explicit `jest.fn<Signature>()` signatures (C1-C3).
   - Add `exists`, `isDirectory`, and `listDirectory` to `FileSystem` fakes. Members a fake does not use throw `new Error("not used")` (C4).
   - Use bracket access for index-signature properties (C5).
   - Use optional chaining in assertions and throwing guards at mutation sites for indexed access (C6).
   - Use conditional spreads or omitted keys for exact optional properties (C7).
   - Complete the request and contract literals, including R20 (C8).
   - Use type-guard predicates for record narrowing (C9).
   - Correct the typing of the `fs` overload, Buffer, and negative-input cases (C10).
   - Remove the duplicate `resolveCodexExecutable` export from `test/extension-test-harness.ts` (C11).
2. **Production re-exports (C11).** Add the inline `type` modifier to the interface re-export specifiers flagged by TS1205 in `src/lib/codex-native-converter/models.ts` and `index.ts`. The modifier is erased at emit.
3. **Gate (research Phase 8, Section 4.2).**
   - `extensions/drm-copilot/package.json`: add `"typecheck:test": "tsc -p tsconfig.jest.json --noEmit"`. Change `typecheck` to `"tsc -p ./ --noEmit && npm run typecheck:test"`.
   - `.github/workflows/_drm-copilot-extension-tests.yml`: insert a step named `Type-check extension source and test tree` that runs `npm --prefix extensions/drm-copilot run typecheck`. It goes between `Install extension dependencies` and `Run extension unit/integration tests`.
4. **Regression guard.** Add a new file, `extensions/drm-copilot/test/package-typecheck-script.test.ts`.

### Boundaries and invariants to preserve:

- The `tsc -p ./ --noEmit` leg stays in `typecheck`, `compile`, and `build`. It checks `src` without Jest global types, so production code cannot reference Jest globals.
- `compile` and `build` do not reference `tsconfig.jest.json`, so the publish and bundle path stays src-only.
- Test runtime behavior does not change. Every existing test keeps its assertions, and no test is removed, skipped, or focused.
- No new `any`, `@ts-ignore`, `@ts-expect-error`, `@ts-nocheck`, or `eslint-disable` directives.
- No file crosses 500 lines. `test/extension.workflow-commands.test.ts`, which is already over the limit, has a net line change of zero or less.

### Dependencies or blocked work:

- None blocking. The gate depends on all type fixes landing first in the same change. Phase 8 is last.
- Changing a file under `.github/workflows/**` requires a green workflow run at the branch head (feature-review rule `modified-workflow-needs-green-run`). The PR's `ci.yml` run provides it.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

- The `extensions/drm-copilot/test/**` files and test helpers listed in research Section 3.1, Phases 1-7.
- `extensions/drm-copilot/src/lib/codex-native-converter/models.ts` and `index.ts`: `type` modifiers only.
- `extensions/drm-copilot/package.json`: `typecheck` and `typecheck:test` scripts only.
- `.github/workflows/_drm-copilot-extension-tests.yml`: one added step.
- New: `extensions/drm-copilot/test/package-typecheck-script.test.ts`.

#### Functions/classes/CLI commands impacted:

- npm scripts `typecheck` (changed) and `typecheck:test` (new).
- Test-helper exports in `test/extension-test-harness.ts`:
  - Host mocks gain explicit signatures.
  - `createTerminalMock` gains an options parameter.
  - The duplicate `resolveCodexExecutable` export is removed.
- Local `FileSystem` fake classes and object literals gain the three missing members.

#### Data flow and validation changes:

None at runtime. The R20 request gains independent-context fields that are passed only to mocked topology and routing resolvers (`src/lib/validate/orchestration-handoff-materializer-request.ts:22-41`).

#### Error handling and logging updates:

- The new throwing guards for indexed access (C6) change only the failure message when a fixture is malformed.
- Unused `FileSystem` fake members throw `new Error("not used")`. If code under test starts calling them, the failure makes that dependency visible.

#### Rollback/feature-flag considerations (if applicable):

To roll back, revert the change. If only the gate must be disabled, restore `typecheck` to `tsc -p ./ --noEmit` and remove the workflow step. The type fixes are safe to keep without the gate.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- `npm run typecheck:test`: exits 0 with no output when the test tree is clean. Otherwise it exits non-zero with `tsc` diagnostics.
- `npm run typecheck`: exits 0 only when both legs exit 0.

#### Required configuration keys and defaults:

- `package.json` `scripts.typecheck:test` = `tsc -p tsconfig.jest.json --noEmit`.
- `package.json` `scripts.typecheck` = `tsc -p ./ --noEmit && npm run typecheck:test`.
- The `tsconfig.json` and `tsconfig.jest.json` files are unchanged.

#### Backward-compatibility expectations:

- Callers of `npm run typecheck` see the same exit contract with wider coverage. These include the atomic-executor QC runner (`tests/scripts/dev_tools/atomic_executor/test_qc_runner.py:472`) and the documented toolchain loop.
- Nothing is removed from the extension's public or runtime API.

#### Performance constraints (latency/throughput/memory):

- The type check adds one `tsc` pass over `src` and `test` per CI matrix leg and per local `typecheck` run.
- Jest runs are unchanged. `test` does not invoke `tsc`.
- No latency threshold is imposed.

## Assumptions, Constraints, Dependencies

- Assumptions: the installed dependency versions at origin/main 43c9e95e (TypeScript, ts-jest 29.4.14, `@jest/globals` 30) are unchanged by this work.
- Constraints:
  - No `any`, and no suppression directives (`.claude/rules/typescript.md`, `.claude/rules/typescript-suppressions.md`).
  - 500-line file limit.
  - Line coverage >= 85% and branch coverage >= 75%, enforced by `jest.config.cjs` `coverageThreshold`.
  - No temporary files in tests.
  - The regression test reads the repository's `package.json` and workflow file with `fs.readFileSync` and `JSON.parse`. It does not use `require`, so it needs no `eslint-disable` directive.
- External dependencies: GitHub Actions `ci.yml` run on the PR for workflow green-run evidence.

## Data / API / Config Impact

- User-facing or API changes: none.
- Data or migration considerations: none.
- Logging/telemetry updates: none.
- Compatibility notes: the `typecheck` npm script now also checks `test/**`. The CI job `drm-copilot-extension-tests` gains a type-check step on each matrix leg.

## Test Strategy

- Regression test to add: `extensions/drm-copilot/test/package-typecheck-script.test.ts`. It contains `describe("extension type-check gate wiring")` with these tests:
  - `typecheck script chains typecheck:test`: `scripts.typecheck` contains `tsc -p ./ --noEmit` and `npm run typecheck:test`.
  - `typecheck:test script checks tsconfig.jest.json`: `scripts["typecheck:test"]` equals `tsc -p tsconfig.jest.json --noEmit`.
  - `compile and build do not reference tsconfig.jest.json`: publish-path isolation.
  - `extension tests workflow runs the typecheck script before tests`: `.github/workflows/_drm-copilot-extension-tests.yml` contains `npm --prefix extensions/drm-copilot run typecheck`, positioned before `npm --prefix extensions/drm-copilot run test`.
- Fail-before and pass-after: the first, second, and fourth tests fail against the baseline `package.json` and workflow. Record a run from before the Phase 8 edits and a run from after them.
- Existing tests: no assertion changes. Run the full suite after each phase.
- Edge cases: the publish-path isolation test guards against the test tree entering `compile` or `build`.
- Coverage: only test files and erased `type` modifiers change in production code, so coverage on changed lines is unaffected. Run `test:coverage` to confirm the thresholds.
- Toolchain per phase, run in `extensions/drm-copilot`:
  1. `npm run format`
  2. `npm run lint`
  3. `npm run typecheck:test` (before Phase 8 this may still report diagnostics outside completed phases, but must report zero for the phase's files)
  4. `npm run test`
- Manual validation: none required beyond the commands in the acceptance criteria.

Definitions used below:
- `<base>` = output of `git merge-base origin/main HEAD`.
- `<ext>` = `extensions/drm-copilot`.
- Commands run from the repository root unless stated otherwise.
- Evidence logs are written under `docs/features/active/2026-09-07-test-tree-typecheck-not-gated-647/evidence/<kind>/`.

## Acceptance Criteria

- [x] AC-1 `node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit` exits 0, and its combined output contains no line matching `error TS`. The command, exit code, and output are recorded in `evidence/qa-gates/`.
- [x] AC-2 `npm --prefix extensions/drm-copilot run typecheck` exits 0, and its output shows that the `typecheck:test` script ran. The command, exit code, and output are recorded in `evidence/qa-gates/`.
- [x] AC-3 In `extensions/drm-copilot/package.json`, `scripts["typecheck:test"]` equals `tsc -p tsconfig.jest.json --noEmit` and `scripts.typecheck` equals `tsc -p ./ --noEmit && npm run typecheck:test`. Verified by the tests `typecheck script chains typecheck:test` and `typecheck:test script checks tsconfig.jest.json` in `extensions/drm-copilot/test/package-typecheck-script.test.ts`.
- [x] AC-4 `git diff <base> -- extensions/drm-copilot/package.json` changes no script other than `typecheck` and the added `typecheck:test`. `compile`, `build`, `test`, `test:unit`, and `test:coverage` are byte-identical to `<base>`. Also verified by the test `compile and build do not reference tsconfig.jest.json`.
- [x] AC-5 `.github/workflows/_drm-copilot-extension-tests.yml` has a step that runs `npm --prefix extensions/drm-copilot run typecheck`, placed after `Install extension dependencies` and before `Run extension unit/integration tests`. Verified by the test `extension tests workflow runs the typecheck script before tests` and by `git diff <base> -- .github/workflows/_drm-copilot-extension-tests.yml`, which shows only the added step.
- [x] AC-6 `npm --prefix extensions/drm-copilot run test -- test/package-typecheck-script.test.ts` exits 0 and reports all tests in `describe("extension type-check gate wiring")` as passed. A fail-before run from before the `package.json` and workflow edits shows the AC-3 and AC-5 tests failing. Both runs are recorded in `evidence/regression-testing/`.
- [x] AC-7 `git diff --name-only <base> -- extensions/drm-copilot/src` lists no path other than `extensions/drm-copilot/src/lib/codex-native-converter/models.ts` and `extensions/drm-copilot/src/lib/codex-native-converter/index.ts`. In `git diff -U0 <base> -- extensions/drm-copilot/src`, every removed line has a matching added line that differs only by an inserted `type ` modifier on an export specifier.
- [x] AC-8 `npm --prefix extensions/drm-copilot run compile` exits 0.
- [x] AC-9 (#645 R20) In `extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts`, the `TransitionPreparedOrchestrationRequest` literal spreads `INDEPENDENT_CONTEXT` with `expectedWorkspaceRoot` overridden to the scenario's `workspaceRoot`. AC-1 reports no diagnostic for this file. `npm --prefix extensions/drm-copilot run test -- test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts` exits 0, with the same number of passing tests as the same command at `<base>` and zero failures.
- [x] AC-10 `npm --prefix extensions/drm-copilot run test` exits 0. The total number of passing tests is at least the number at `<base>` plus the tests added in `package-typecheck-script.test.ts`. `git diff -U0 <base> -- extensions/drm-copilot/test` has no added line matching `\.(skip|only)\(|\bx(it|describe|test)\(`.
- [x] AC-11 `npm --prefix extensions/drm-copilot run test:coverage` exits 0, so the `jest.config.cjs` `coverageThreshold` (line >= 85%, branch >= 75%) is met. The text-summary output is recorded in `evidence/qa-gates/`, and it shows line and branch percentages no lower than the same command at `<base>`.
- [x] AC-12 The added lines in `git diff -U0 <base> -- extensions/drm-copilot` (lines starting with `+`, excluding `+++` headers) contain no match for `@ts-ignore|@ts-expect-error|@ts-nocheck|eslint-disable|:\s*any\b|\bas\s+any\b|<any>|\bany\[\]`.
- [x] AC-13 `git diff --numstat <base> -- extensions/drm-copilot/test/extension.workflow-commands.test.ts` reports an added-line count less than or equal to the deleted-line count. Every other `.ts` file listed by `git diff --name-only --diff-filter=AM <base> -- extensions/drm-copilot` has at most 500 lines at HEAD, measured with `(Get-Content <path>).Count`.
- [x] AC-14 `npm --prefix extensions/drm-copilot run lint` exits 0. From `extensions/drm-copilot`, `npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"` exits 0.
- [ ] AC-15 The PR's `ci.yml` run at the branch head completes with conclusion `success` for every matrix leg of `drm-copilot-extension-tests`, and each leg includes the step `Type-check extension source and test tree`. Verified with `gh run view <run-id> --json jobs`, and the run ID is recorded in `evidence/qa-gates/`.

## Risks & Mitigations

- **Test runtime behavior drift from typing edits.**
  - Most edits are erased at emit: type arguments, `type` modifiers, bracket access, optional chaining.
  - A few edits do change runtime code paths: R20 context fields, throwing guards, omitted optional keys, new "not used" fake members, and removal of the duplicate harness export.
  - Mitigation: run the full suite after each phase. AC-9 and AC-10 compare test counts against `<base>`.
- **Line-count growth in files near 500 lines.** Several files are at 470-499 lines (research Section 5). Typed `jest.fn<...>()` declarations can wrap after Prettier formatting.
  - Mitigation: check post-Prettier line counts per file. Prefer line-neutral patterns such as bracket access and optional chaining. AC-13 enforces the limit.
- **`test/extension.workflow-commands.test.ts` fixes adding lines.** Most of its diagnostics clear through the harness mock typing.
  - Mitigation: keep the remaining edits in that file net non-positive (AC-13).
- **Production bundle effect of the `type` modifiers was not verified in research.**
  - Mitigation: AC-8 requires `compile`, which runs `tsc -p ./` and both esbuild bundles, to succeed.
- **New diagnostics introduced on main between research and merge.** Other branches may add test-tree type errors before this change merges.
  - Mitigation: rebase on main before opening the PR, rerun AC-1, and fix any new diagnostics with the same patterns. After merge, the gate prevents recurrence.
- **Scope pressure toward suppressions.** Some diagnostic may seem to need a suppression.
  - Mitigation: AC-12 prohibits suppressions. If one is unavoidable, stop and escalate under `.claude/rules/typescript-suppressions.md:17-21` instead of adding it.
- **Workflow change needs a green run.**
  - Mitigation: AC-15 records the PR `ci.yml` run.
- **Rollback.** Revert the change. To disable only the gate, restore the previous `typecheck` script and remove the workflow step. The type fixes are safe to keep.

## Rollout & Follow-up

- Release/rollout steps: merge through the standard PR flow. No extension version bump is required, because published runtime code and packaging are unchanged.
- Post-fix monitoring or clean-up tasks: file separate items for the out-of-scope observations in research Section 6.4 if they are not already tracked. These are: the extension `lint` script is not run in CI, ESLint runs with `project: false`, and `test/extension.workflow-commands.test.ts` exceeds 500 lines.
- Links:
  - Issue #647: https://github.com/drmoisan/drm-copilot/issues/647
  - Related #645 (R20)
  - Research: `research/research.2026-09-29T20-20.md`
