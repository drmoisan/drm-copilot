# 2026-03-04-expose-pr-context-script - Plan

- **Issue:** #77
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-03-04T23-07
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full
- **Target Plan Path:** `docs/features/active/2026-03-04-expose-pr-context-script-77/plan.2026-03-04T23-07.md`

## Objective

Expose `scripts/dev_tools/pr_context` through extension-side execution in `extensions/scaffold-extension` while preserving bundled-resource execution boundaries, destination-workspace `cwd` targeting, no script materialization in destination workspace root, deterministic branch picker behavior, and actionable error logging.

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context & Baseline Evidence

- [ ] [P0-T1] Record the selected work mode from `docs/features/active/2026-03-04-expose-pr-context-script-77/issue.md` into `docs/features/active/2026-03-04-expose-pr-context-script-77/evidence/baseline/phase0-mode-source.yyyy-MM-ddTHH-mm.md`
  - Acceptance: The evidence file exists and contains exact lines `Work Mode Source: issue.md` and `Resolved Work Mode: full`.

- [ ] [P0-T2] Read required policy files in compliance order and store proof in `docs/features/active/2026-03-04-expose-pr-context-script-77/evidence/baseline/phase0-instructions-read.yyyy-MM-ddTHH-mm.md`
  - Preconditions: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, and `.github/instructions/typescript-unit-test.instructions.md` exist.
  - Acceptance: The evidence file exists and contains `Timestamp:`, `Policy Order:`, and all five file paths in the exact read order.

- [ ] [P0-T3] Read `issue.md`, `spec.md`, `user-story.md`, and `artifacts/research/20260305-expose-pr-context-script-implementation-research.md`, then capture a requirement-to-file mapping in `docs/features/active/2026-03-04-expose-pr-context-script-77/evidence/baseline/phase0-requirements-map.yyyy-MM-ddTHH-mm.md`
  - Acceptance: The mapping file exists and includes the exact requirement strings `extension-side bundled execution boundary`, `destination cwd targeting`, `no script materialization`, `deterministic branch picker`, and `actionable error logging`.

- [ ] [P0-T4] Run baseline TypeScript format check for extension sources and record command evidence in `docs/features/active/2026-03-04-expose-pr-context-script-77/evidence/baseline/ts-format-check.yyyy-MM-ddTHH-mm.md`
  - Command: `npm --prefix extensions/scaffold-extension exec -- prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
  - Acceptance: Evidence file includes `Timestamp:`, exact `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T5] Run baseline ESLint for the extension package and record command evidence in `docs/features/active/2026-03-04-expose-pr-context-script-77/evidence/baseline/ts-lint.yyyy-MM-ddTHH-mm.md`
  - Command: `npm --prefix extensions/scaffold-extension run lint`
  - Acceptance: Evidence file includes `Timestamp:`, exact `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T6] Run baseline TypeScript type checking for the extension package and record command evidence in `docs/features/active/2026-03-04-expose-pr-context-script-77/evidence/baseline/ts-typecheck.yyyy-MM-ddTHH-mm.md`
  - Command: `npm --prefix extensions/scaffold-extension run typecheck`
  - Acceptance: Evidence file includes `Timestamp:`, exact `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T7] Run baseline Jest with coverage for the extension package and record numeric coverage evidence in `docs/features/active/2026-03-04-expose-pr-context-script-77/evidence/baseline/ts-test-coverage.yyyy-MM-ddTHH-mm.md`
  - Command: `npm --prefix extensions/scaffold-extension exec -- jest --config jest.config.cjs --coverage --coverageReporters=text-summary`
  - Acceptance: Evidence file includes `Timestamp:`, exact `Command:`, `EXIT_CODE:`, `Output Summary:`, and numeric `Lines:`, `Statements:`, `Functions:`, and `Branches:` values.

### Phase 1 — TDD Red Regression Tasks

- [ ] [P1-T1] [expect-fail] Add unit test in `extensions/scaffold-extension/test/extension.test.ts` asserting `activate()` registers `scaffoldExtension.collectPrContext`
  - Acceptance: Command `npm --prefix extensions/scaffold-extension exec -- jest test/extension.test.ts -t "registers collectPrContext"` exits non-zero and evidence is saved at `docs/features/active/2026-03-04-expose-pr-context-script-77/evidence/regression-testing/p1-t1-register-command-fail.yyyy-MM-ddTHH-mm.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and a failing assertion excerpt.

- [ ] [P1-T2] [expect-fail] Add unit test in `extensions/scaffold-extension/test/extension.test.ts` asserting branch selection cancel aborts `scaffoldExtension.collectPrContext` before subprocess spawn
  - Acceptance: Command `npm --prefix extensions/scaffold-extension exec -- jest test/extension.test.ts -t "collectPrContext cancels before spawn"` exits non-zero and evidence is saved at `docs/features/active/2026-03-04-expose-pr-context-script-77/evidence/regression-testing/p1-t2-cancel-before-spawn-fail.yyyy-MM-ddTHH-mm.md` with `Timestamp:`, `Command:`, and `EXIT_CODE:`.

- [ ] [P1-T3] [expect-fail] Add unit test in `extensions/scaffold-extension/test/extension.test.ts` asserting selected base branch is passed through `--base` and PR artifact flags
  - Acceptance: Command `npm --prefix extensions/scaffold-extension exec -- jest test/extension.test.ts -t "collectPrContext passes base and artifact args"` exits non-zero and evidence is saved at `docs/features/active/2026-03-04-expose-pr-context-script-77/evidence/regression-testing/p1-t3-base-arg-fail.yyyy-MM-ddTHH-mm.md` with `Timestamp:`, `Command:`, and `EXIT_CODE:`.

### Phase 2 — Extension Command Implementation

- [ ] [P2-T1] Add command contribution `scaffoldExtension.collectPrContext` to `extensions/scaffold-extension/package.json`
  - Acceptance: `extensions/scaffold-extension/package.json` contains the exact JSON entry with command id `scaffoldExtension.collectPrContext` and title `drm-copilot: Collect PR Context`.

- [ ] [P2-T2] Add a branch-discovery helper in `extensions/scaffold-extension/src/extension.ts` that returns deterministic candidates from destination repository refs and deterministic default selection
  - Acceptance: `extensions/scaffold-extension/src/extension.ts` contains a dedicated helper used by PR context command flow and includes deterministic ordering logic with `origin/HEAD` priority.

- [ ] [P2-T3] Add a branch-picker helper in `extensions/scaffold-extension/src/extension.ts` that uses VS Code Quick Pick and returns cancel state as command abort
  - Acceptance: `extensions/scaffold-extension/src/extension.ts` contains a helper that handles `undefined` Quick Pick result and emits a cancellation log line with command id `scaffoldExtension.collectPrContext`.

- [ ] [P2-T4] Register `scaffoldExtension.collectPrContext` in `activate()` and invoke bundled collector with destination workspace `cwd`
  - Preconditions: [P2-T1], [P2-T2], and [P2-T3] completed.
  - Acceptance: `extensions/scaffold-extension/src/extension.ts` registers command id `scaffoldExtension.collectPrContext` and calls bundled script execution with args `--base`, `--out artifacts/pr_context.summary.txt`, and `--appendix-out artifacts/pr_context.appendix.txt`.

- [ ] [P2-T5] Extend PR-context command logging in `extensions/scaffold-extension/src/extension.ts` for branch discovery, selection, cancellation, runtime probe failures, and non-zero collector exits
  - Acceptance: The file contains command-id-scoped log lines for each failure class and success completion path.

### Phase 3 — Scenario-Specific Unit and Integration Verification

- [ ] [P3-T1] Update `extensions/scaffold-extension/test/extension.test.ts` so scenario `activate registers collectPrContext` passes
  - Acceptance: Command `npm --prefix extensions/scaffold-extension exec -- jest test/extension.test.ts -t "registers collectPrContext"` exits `0`.

- [ ] [P3-T2] Add or update `extensions/scaffold-extension/test/extension.test.ts` so scenario `collectPrContext without workspace throws clear no-workspace error` passes
  - Acceptance: Command `npm --prefix extensions/scaffold-extension exec -- jest test/extension.test.ts -t "collectPrContext fails when no workspace folder is open"` exits `0`.

- [ ] [P3-T3] Update `extensions/scaffold-extension/test/extension.test.ts` so scenario `collectPrContext cancels before spawn` passes and asserts no subprocess invocation
  - Acceptance: Command `npm --prefix extensions/scaffold-extension exec -- jest test/extension.test.ts -t "collectPrContext cancels before spawn"` exits `0`.

- [ ] [P3-T4] Add or update `extensions/scaffold-extension/test/extension.test.ts` so scenario `collectPrContext deterministic default branch selection` passes
  - Acceptance: Command `npm --prefix extensions/scaffold-extension exec -- jest test/extension.test.ts -t "collectPrContext selects deterministic default base branch"` exits `0`.

- [ ] [P3-T5] Update `extensions/scaffold-extension/test/extension.test.ts` so scenario `collectPrContext passes base and artifact args with destination cwd` passes
  - Acceptance: Command `npm --prefix extensions/scaffold-extension exec -- jest test/extension.test.ts -t "collectPrContext passes base and artifact args"` exits `0`.

- [ ] [P3-T6] Add integration scenario in `extensions/scaffold-extension/test/extension.integration.test.ts` validating no PR collector script materialization in destination workspace root
  - Acceptance: Command `npm --prefix extensions/scaffold-extension exec -- jest test/extension.integration.test.ts -t "collectPrContext executes bundled resource without workspace script copy"` exits `0`.

- [ ] [P3-T7] Add integration scenario in `extensions/scaffold-extension/test/extension.integration.test.ts` validating artifact path handling with destination workspace path containing spaces or unicode
  - Acceptance: Command `npm --prefix extensions/scaffold-extension exec -- jest test/extension.integration.test.ts -t "collectPrContext handles workspace paths with spaces or unicode"` exits `0`.

### Phase 4 — Final QA Loop and Coverage Gates

- [ ] [P4-T1] Run extension formatter and save QA evidence in `docs/features/active/2026-03-04-expose-pr-context-script-77/evidence/qa-gates/ts-format.yyyy-MM-ddTHH-mm.md`
  - Command: `npm --prefix extensions/scaffold-extension run format`
  - Acceptance: Evidence file includes `Timestamp:`, exact `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P4-T2] Run extension lint and save QA evidence in `docs/features/active/2026-03-04-expose-pr-context-script-77/evidence/qa-gates/ts-lint.yyyy-MM-ddTHH-mm.md`
  - Command: `npm --prefix extensions/scaffold-extension run lint`
  - Acceptance: Evidence file includes `Timestamp:`, exact `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P4-T3] Run extension type check and save QA evidence in `docs/features/active/2026-03-04-expose-pr-context-script-77/evidence/qa-gates/ts-typecheck.yyyy-MM-ddTHH-mm.md`
  - Command: `npm --prefix extensions/scaffold-extension run typecheck`
  - Acceptance: Evidence file includes `Timestamp:`, exact `Command:`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P4-T4] Run extension Jest suite with coverage and save numeric QA evidence in `docs/features/active/2026-03-04-expose-pr-context-script-77/evidence/qa-gates/ts-test-coverage.yyyy-MM-ddTHH-mm.md`
  - Command: `npm --prefix extensions/scaffold-extension exec -- jest --config jest.config.cjs --coverage --coverageReporters=text-summary`
  - Acceptance: Evidence file includes `Timestamp:`, exact `Command:`, `EXIT_CODE:`, `Output Summary:`, and numeric `Lines:`, `Statements:`, `Functions:`, and `Branches:` values.

- [ ] [P4-T5] Repeat the TypeScript QA loop from [P4-T1] through [P4-T4] until one full pass completes with all `EXIT_CODE: 0` and no formatter-introduced file changes
  - Acceptance: A single run-sequence record exists at `docs/features/active/2026-03-04-expose-pr-context-script-77/evidence/qa-gates/ts-final-pass.yyyy-MM-ddTHH-mm.md` that lists the exact evidence filenames for [P4-T1] through [P4-T4] from the clean pass.

- [ ] [P4-T6] Verify coverage deltas against baseline and persist threshold verification in `docs/features/active/2026-03-04-expose-pr-context-script-77/evidence/qa-gates/ts-coverage-delta.yyyy-MM-ddTHH-mm.md`
  - Preconditions: [P0-T7] and [P4-T4] completed.
  - Acceptance: Evidence file includes numeric baseline vs post-change coverage for `Lines`, `Statements`, `Functions`, and `Branches`, plus an explicit pass/fail statement for no-regression.

## Executor Preflight Requirement (Validate-Only)

Use this exact handoff directive for plan validation before execution:

`DIRECTIVE: PREFLIGHT VALIDATION ONLY`

Required terminal signal before implementation handoff:

`PREFLIGHT: ALL CLEAR`
