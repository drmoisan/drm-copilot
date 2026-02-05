# 2026-02-04-extension-tests-fail-in-container (Plan)

- **Issue:** #12
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-04T18-36
- **Status:** Draft
- **Version:** 0.1

## Overview
Replace the container-incompatible VS Code integration harness with Jest-based tests, remove the `vscode-test` scaffolding, and update scripts/docs so the default test workflow is container-safe.

## In-Scope Files (must remain limited)
- `tests/integration/extension.test.ts` (remove integration harness test)
- `tests/unit/vscode-test-removal.test.ts` (new Jest regression tests)
- `package.json` (update test scripts)
- `.vscode-test.mjs` (remove)
- `tsconfig.vscode-test.json` (remove)
- `docs/developer-tooling.md` (update test workflow docs)
- `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/spec.md` (status/acceptance updates)
- `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/links.md` (traceability)
- `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/pr-notes.md` (PR summary notes)

## Phase 0 Notes
Execution notes will be appended here during implementation to confirm policy reads and baseline captures.

- P0-T1 complete (2026-02-04T19:04:00Z)
- P0-T2 complete (2026-02-04T19:04:00Z)
- P0-T3 complete (2026-02-04T19:04:00Z)
- P0-T4 complete (2026-02-04T19:04:00Z)
- P0-T5 complete (2026-02-04T19:04:00Z)
- P0-T6 complete (2026-02-04T19:04:00Z)
- P0-T7 complete (2026-02-04T19:04:00Z) — change-plan.md not found.
- P0-T8 complete (2026-02-04T19:04:00Z) — baseline/ts-format.txt captured.
- P0-T9 complete (2026-02-04T19:04:00Z) — baseline/ts-lint.txt captured.
- P0-T10 complete (2026-02-04T19:04:00Z) — baseline/ts-typecheck.txt captured.
- P0-T11 complete (2026-02-04T19:04:00Z) — baseline/ts-test-unit.txt captured.

### Phase 0 — Context & Inputs
- [x] [P0-T1] Read `.github/copilot-instructions.md` and record completion in the Phase 0 Notes
	- Acceptance: Phase 0 Notes includes “P0-T1 complete” with ISO-8601 timestamp.
- [x] [P0-T2] Read `.github/instructions/general-code-change.instructions.md` and record completion in the Phase 0 Notes
	- Acceptance: Phase 0 Notes includes “P0-T2 complete” with ISO-8601 timestamp.
- [x] [P0-T3] Read `.github/instructions/general-unit-test.instructions.md` and record completion in the Phase 0 Notes
	- Acceptance: Phase 0 Notes includes “P0-T3 complete” with ISO-8601 timestamp.
- [x] [P0-T4] Read `.github/instructions/typescript-code-change.instructions.md` and record completion in the Phase 0 Notes
	- Acceptance: Phase 0 Notes includes “P0-T4 complete” with ISO-8601 timestamp.
- [x] [P0-T5] Read `.github/instructions/typescript-unit-test.instructions.md` and record completion in the Phase 0 Notes
	- Acceptance: Phase 0 Notes includes “P0-T5 complete” with ISO-8601 timestamp.
- [x] [P0-T6] Read `.github/instructions/typescript-suppressions.instructions.md` and record completion in the Phase 0 Notes
	- Acceptance: Phase 0 Notes includes “P0-T6 complete” with ISO-8601 timestamp.
- [x] [P0-T7] Check for `change-plan.md` and record presence/absence in Phase 0 Notes
	- Acceptance: Phase 0 Notes includes “P0-T7 complete” with explicit `change-plan.md` status.
- [x] [P0-T8] Capture baseline `npm run format` output in `baseline/ts-format.txt`
	- Acceptance: `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/baseline/ts-format.txt` exists and contains lines `Timestamp:`, `Command: npm run format`, and `EXIT_CODE:`.
- [x] [P0-T9] Capture baseline `npm run lint` output in `baseline/ts-lint.txt`
	- Acceptance: `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/baseline/ts-lint.txt` exists and contains lines `Timestamp:`, `Command: npm run lint`, and `EXIT_CODE:`.
- [x] [P0-T10] Capture baseline `npm run typecheck` output in `baseline/ts-typecheck.txt`
	- Acceptance: `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/baseline/ts-typecheck.txt` exists and contains lines `Timestamp:`, `Command: npm run typecheck`, and `EXIT_CODE:`.
- [x] [P0-T11] Capture baseline `npm run test:unit` output in `baseline/ts-test-unit.txt`
	- Acceptance: `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/baseline/ts-test-unit.txt` exists and contains lines `Timestamp:`, `Command: npm run test:unit`, and `EXIT_CODE:`.

## Phase 1 Notes
Execution notes will be appended here to confirm scope validation and test harness analysis.

- P1-T1 complete (2026-02-04T19:06:00Z) — in-scope files exist and match plan list; no deviations.
- P1-T2 complete (2026-02-04T19:06:00Z) — integration test asserts activation and command registration; unit test already covers activation and command registration list via mocked VS Code APIs.

### Phase 1 — Preparation
- [x] [P1-T1] Confirm the in-scope file list matches the repository and record confirmation in Phase 1 Notes
	- Acceptance: Phase 1 Notes includes “P1-T1 complete” with any deviations explicitly listed.
- [x] [P1-T2] Review `tests/integration/extension.test.ts` and `tests/unit/extension.test.ts` to identify coverage overlap and record findings in Phase 1 Notes
	- Acceptance: Phase 1 Notes includes “P1-T2 complete” with a summary of overlapping assertions.

## Phase 2 Notes
Execution notes will be appended here to capture regression evidence artifacts.

- P2-T1 complete (2026-02-04T19:11:00Z) — failing script reference test recorded in regression-testing/expect-fail-scripts.txt.
- P2-T2 complete (2026-02-04T19:11:00Z) — failing .vscode-test.mjs absence test recorded in regression-testing/expect-fail-vscode-test-mjs.txt.
- P2-T3 complete (2026-02-04T19:11:00Z) — failing tsconfig.vscode-test.json absence test recorded in regression-testing/expect-fail-vscode-test-tsconfig.txt.

### Phase 2 — Regression Tests (must fail first)
- [x] [P2-T1] [expect-fail] Add Jest test in `tests/unit/vscode-test-removal.test.ts` asserting `package.json` scripts do not reference `@vscode/test-electron`
	- Acceptance: `tests/unit/vscode-test-removal.test.ts` contains a test named `scripts avoid vscode-test electron harness`.
	- Acceptance: `npm run test:unit -- --runTestsByPath tests/unit/vscode-test-removal.test.ts -t "scripts avoid vscode-test electron harness"` fails.
	- Acceptance: `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/regression-testing/expect-fail-scripts.txt` exists and includes `Timestamp:`, `Command: npm run test:unit -- --runTestsByPath tests/unit/vscode-test-removal.test.ts -t "scripts avoid vscode-test electron harness"`, and `EXIT_CODE:` with a non-zero value, plus a `Failure:` line containing the failing assertion.
- [x] [P2-T2] [expect-fail] Add Jest test in `tests/unit/vscode-test-removal.test.ts` asserting `.vscode-test.mjs` is absent
	- Acceptance: `tests/unit/vscode-test-removal.test.ts` contains a test named `vscode-test mjs removed`.
	- Acceptance: `npm run test:unit -- --runTestsByPath tests/unit/vscode-test-removal.test.ts -t "vscode-test mjs removed"` fails.
	- Acceptance: `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/regression-testing/expect-fail-vscode-test-mjs.txt` exists and includes `Timestamp:`, `Command: npm run test:unit -- --runTestsByPath tests/unit/vscode-test-removal.test.ts -t "vscode-test mjs removed"`, and `EXIT_CODE:` with a non-zero value, plus a `Failure:` line containing the failing assertion.
- [x] [P2-T3] [expect-fail] Add Jest test in `tests/unit/vscode-test-removal.test.ts` asserting `tsconfig.vscode-test.json` is absent
	- Acceptance: `tests/unit/vscode-test-removal.test.ts` contains a test named `vscode-test tsconfig removed`.
	- Acceptance: `npm run test:unit -- --runTestsByPath tests/unit/vscode-test-removal.test.ts -t "vscode-test tsconfig removed"` fails.
	- Acceptance: `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/regression-testing/expect-fail-vscode-test-tsconfig.txt` exists and includes `Timestamp:`, `Command: npm run test:unit -- --runTestsByPath tests/unit/vscode-test-removal.test.ts -t "vscode-test tsconfig removed"`, and `EXIT_CODE:` with a non-zero value, plus a `Failure:` line containing the failing assertion.

### Phase 3 — Minimal Fix
- [x] [P3-T1] Remove `tests/integration/extension.test.ts` to eliminate the VS Code integration harness test
	- Acceptance: `tests/integration/extension.test.ts` no longer exists in the workspace.
- [x] [P3-T2] Remove `.vscode-test.mjs` from the repository
	- Acceptance: `.vscode-test.mjs` no longer exists in the workspace.
- [x] [P3-T3] Remove `tsconfig.vscode-test.json` from the repository
	- Acceptance: `tsconfig.vscode-test.json` no longer exists in the workspace.
- [x] [P3-T4] Update `package.json` so `scripts.test` runs `npm run test:unit`
	- Acceptance: `package.json` sets `scripts.test` to `npm run test:unit`.
- [x] [P3-T5] Update `package.json` so `scripts.test:integration` runs `npm run test:unit`
	- Acceptance: `package.json` sets `scripts.test:integration` to `npm run test:unit`.
- [x] [P3-T6] Update `package.json` to remove `@vscode/test-electron` references
	- Acceptance: `package.json` contains no `@vscode/test-electron` references.
- [x] [P3-T7] Update `docs/developer-tooling.md` to document the Jest-only test workflow for containers
	- Acceptance: `docs/developer-tooling.md` includes a section stating `npm test` and `npm run test:integration` run Jest without the VS Code test runner.

### Phase 4 — Verification Loop
- [x] [P4-T1] Re-run Jest regression tests to confirm fixes pass
	- Acceptance: `npm run test:unit -- --runTestsByPath tests/unit/vscode-test-removal.test.ts` exits with code 0.
- [x] [P4-T2] Record scope confirmation for integration harness removal in Phase 4 Notes
	- Acceptance: Phase 4 Notes includes “P4-T2 complete” with confirmation that no `vscode-test` files remain.

## Phase 4 Notes
Execution notes will be appended here to confirm verification outcomes.

- P4-T2 complete (2026-02-04T20:30:00Z) — confirmed `.vscode-test.mjs`, `tsconfig.vscode-test.json`, and `tests/integration/extension.test.ts` were removed.

### Phase 5 — Documentation & Status
- [x] [P5-T1] Update the spec status and acceptance checklist for Issue #12
	- Acceptance: `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/spec.md` has updated Status, Last Updated, and Acceptance Criteria checkmarks reflecting completion.

### Phase 6 — Toolchain QA (TypeScript)
- [x] [P6-T1] Run `npm run format`; if files change, restart Phase 6 from P6-T1
	- Acceptance: `npm run format` completes with exit code 0 and no file changes on a clean rerun.
- [x] [P6-T2] Run `npm run lint`; if lint fixes or failures occur, restart Phase 6 from P6-T1
	- Acceptance: `npm run lint` completes with exit code 0.
- [x] [P6-T3] Run `npm run typecheck`; if failures occur, restart Phase 6 from P6-T1
	- Acceptance: `npm run typecheck` completes with exit code 0.
- [x] [P6-T4] Run `npm run test:unit`; if failures occur, restart Phase 6 from P6-T1
	- Acceptance: `npm run test:unit` completes with exit code 0.

### Phase 7 — PR & Follow-up
- [x] [P7-T1] Prepare PR notes summarizing test changes, risks, and validation steps
	- Acceptance: `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/pr-notes.md` exists and includes a section titled `Test Workflow` describing `npm test` and `npm run test:integration`, plus a section titled `QA Commands` listing `npm run format`, `npm run lint`, `npm run typecheck`, and `npm run test:unit`.
- [x] [P7-T2] Record issue/PR links and follow-up items in the feature folder
	- Acceptance: `docs/features/active/2026-02-04-extension-tests-fail-in-container-12/links.md` includes `Issue:` and `PR:` entries with full URLs.
