# 2026-02-04-typescript-engineer-agent - Plan

![Status: Planned](https://img.shields.io/badge/Status-Planned-blue)

- **Issue:** #10
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-04T12-35
- **Status:** Planned
- **Version:** 0.2

## Required References

All work must comply with these policies; do not duplicate their content here.

1. [`.github/copilot-instructions.md`](../../../../.github/copilot-instructions.md)
2. [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
3. [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
4. [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
5. [`.github/instructions/typescript-suppressions.instructions.md`](../../../../.github/instructions/typescript-suppressions.instructions.md)
6. [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)

## Implementation Plan (Atomic Tasks)

Requirements and constraints are identified with the following prefixes:

- `REQ-` functional requirements
- `SEC-` security requirements
- `CON-` non-functional constraints

### Requirements Traceability

| ID | Description | Delivered by tasks |
|---|---|---|
| REQ-LINT-001 | Enable type-aware ESLint rules for TS-family files only (typed linting) without breaking linting for JS files. | P1-T1 |
| REQ-LINT-002 | Fix the known typed-lint findings (as measured in `research.md`) without file-level suppressions so `npm run lint` passes. | P2-T2, P2-T3, P2-T4, P2-T5, P2-T6 |
| REQ-QA-001 | Complete a clean toolchain loop pass (format → lint → typecheck → unit tests) after changes. | P3-T1, P3-T2, P3-T3, P3-T4 |

### Constraints

- CON-TOOLCHAIN-ORDER: All verification must run in this order and repeat from step 1 if any step fails or changes files: `npm run format` → `npm run lint` → `npm run typecheck` → `npm run test:unit`.
- CON-NO-BROAD-SUPPRESSIONS: Do not introduce file-level ESLint disables, `// @ts-ignore`, or `// @ts-nocheck`. Only the pre-authorized single-line suppression formats may be used.

### Security

- SEC-BOUNDARY-INPUTS: Any boundary code that consumes untrusted input (CLI args, workspace settings, regex captures) must treat values as `unknown` and narrow explicitly instead of relying on implicit `any`.

### Phase 0 — Context & Inputs

- [ ] [P0-T1] Create directory `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/`
  - Acceptance: directory `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/` exists.

- [ ] [P0-T2] Read `.github/copilot-instructions.md` and record the exact file path in `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.txt`
  - Acceptance: `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.txt` exists and contains the line `.github/copilot-instructions.md`.

- [ ] [P0-T3] Read `.github/instructions/general-code-change.instructions.md` and record the exact file path in `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.txt`
  - Acceptance: `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.txt` contains the line `.github/instructions/general-code-change.instructions.md`.

- [ ] [P0-T4] Read `.github/instructions/general-unit-test.instructions.md` and record the exact file path in `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.txt`
  - Acceptance: `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.txt` contains the line `.github/instructions/general-unit-test.instructions.md`.

- [ ] [P0-T5] Read `.github/instructions/typescript-code-change.instructions.md` and record the exact file path in `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.txt`
  - Acceptance: `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.txt` contains the line `.github/instructions/typescript-code-change.instructions.md`.

- [ ] [P0-T6] Read `.github/instructions/typescript-suppressions.instructions.md` and record the exact file path in `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.txt`
  - Acceptance: `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.txt` contains the line `.github/instructions/typescript-suppressions.instructions.md`.

- [ ] [P0-T7] Read `.github/instructions/typescript-unit-test.instructions.md` and record the exact file path in `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.txt`
  - Acceptance: `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.txt` contains the line `.github/instructions/typescript-unit-test.instructions.md`.

- [ ] [P0-T8] Capture baseline formatting results by running `npm run format:check` and writing stdout+stderr and the numeric exit code to `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/ts-format-check.txt`
  - Acceptance: `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/ts-format-check.txt` exists and contains a line matching `EXIT_CODE=\d+`.

- [ ] [P0-T9] Capture baseline lint results by running `npm run lint` and writing stdout+stderr and the numeric exit code to `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/ts-lint.txt`
  - Acceptance: `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/ts-lint.txt` exists and contains a line matching `EXIT_CODE=\d+`.

- [ ] [P0-T10] Capture baseline typecheck results by running `npm run typecheck` and writing stdout+stderr and the numeric exit code to `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/ts-typecheck.txt`
  - Acceptance: `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/ts-typecheck.txt` exists and contains a line matching `EXIT_CODE=\d+`.

- [ ] [P0-T11] Capture baseline unit test results by running `npm run test:unit` and writing stdout+stderr and the numeric exit code to `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/ts-test-unit.txt`
  - Acceptance: `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/ts-test-unit.txt` exists and contains a line matching `EXIT_CODE=\d+`.

### Phase 1 — Enable Typed ESLint for TypeScript

- [ ] [P1-T1] Update `eslint.config.mjs` to enable typescript-eslint typed linting scoped to TS-family files only
  - Preconditions: [P0-T10] baseline lint captured.
  - Implementation details (exact edits required):
    - Replace the existing `export default` configuration array with a configuration that applies to:
      - TS-family files: `files: ["**/*.{ts,tsx,mts,cts}"]`
      - JS-family files: `files: ["**/*.{js,mjs,cjs}"]` using the default ESLint parser (do NOT set the TypeScript parser for these globs).
    - For TS-family config, set:
      - `languageOptions.parserOptions.projectService: true`
      - `languageOptions.parserOptions.tsconfigRootDir: import.meta.dirname`
    - For TS-family config, extend the type-aware rule sets by including these presets in the TS config `extends` list:
      - `typescriptEslint.configs.recommendedTypeChecked`
      - `typescriptEslint.configs.stylisticTypeChecked`
    - Preserve the repo’s existing custom rules:
      - `@typescript-eslint/naming-convention` (import selector camelCase/PascalCase)
      - `curly`, `eqeqeq`, `no-throw-literal`, `semi`
  - Acceptance: `npm run lint` fails with typed-lint findings only in TS files (no parse errors for `.js` files under `src/` or `tests/`).

### Phase 2 — Fix Typed-Lint Findings (No Suppressions)

Tasks in this phase may be executed in parallel after [P2-T1] is completed.

- [ ] [P2-T1] [expect-fail] Add Jest unit test that asserts `dispatchUtility()` formats non-`Error` throws as `Unknown error`
  - File to add: `tests/unit/utility-dispatcher.non-error-throw.test.ts`
  - Exact test content requirements:
    - Mock `vscode` as a virtual module with `window.showErrorMessage` as `jest.fn()`.
    - Mock `../../src/utilities/utility-spec` so that `getUtilitySpec` throws a non-`Error` value (throw the literal object `{ boom: 1 }`) and `getRequiredInputIds` returns `[]`.
    - Import `dispatchUtility` from `../../src/utilities/utility-dispatcher` after the mocks are defined.
    - Add a test named exactly: `returns Unknown error when a non-Error is thrown`
    - Assert that the returned result has `success === false` and `error` contains the substring `Utility dispatch failed: Unknown error`.
  - Acceptance: running `npm run test:unit -- --runTestsByPath tests/unit/utility-dispatcher.non-error-throw.test.ts` fails and the output contains `Utility dispatch failed: [object Object]`.

- [ ] [P2-T2] Fix unused parameter finding in `src/drm-task-provider.ts` by replacing `_task` with a used parameter
  - File: `src/drm-task-provider.ts`
  - Location: line 76 (current signature `resolveTask(_task: vscode.Task): vscode.Task | undefined`).
  - Exact change:
    - Change method signature `resolveTask(_task: vscode.Task): vscode.Task | undefined` to `resolveTask(task: vscode.Task): vscode.Task | undefined`.
    - Add the line `void task;` as the first statement in the method body.
  - Acceptance: `npm run lint` output no longer includes `src/drm-task-provider.ts` with `@typescript-eslint/no-unused-vars`.

- [ ] [P2-T3] Fix consistent type definitions finding in `src/task-command-map.ts` by converting `TaskExecutionSpec` to an interface
  - File: `src/task-command-map.ts`
  - Location: lines 8-11 (current definition starts with `export type TaskExecutionSpec = {`).
  - Exact change:
    - Replace `export type TaskExecutionSpec = {` with `export interface TaskExecutionSpec {`.
    - Replace the closing `};` with `}`.
  - Acceptance: `npm run lint` output no longer includes `src/task-command-map.ts` with `@typescript-eslint/consistent-type-definitions` for `TaskExecutionSpec`.

- [ ] [P2-T4] Fix typed-lint `no-unsafe-member-access` in `src/task-command-map.ts` by typing the regex replacement callback parameters
  - File: `src/task-command-map.ts`
  - Location: around line 653 in `resolveTaskArgs` where the `${input:<id>}` replacement callback is defined.
  - Exact change:
    - Change callback signature from `(_match, inputId) => {` to `(_match: string, inputId: string) => {`.
  - Acceptance: `npm run lint` output no longer includes `src/task-command-map.ts` with `@typescript-eslint/no-unsafe-member-access`.

- [ ] [P2-T5] Fix typed-lint `no-unsafe-member-access` and `no-base-to-string` in `src/utilities/utility-dispatcher.ts` by typing the regex callback and removing `String(error)`
  - File: `src/utilities/utility-dispatcher.ts`
  - Location: line 119 (current `${input:<id>}` replacement callback signature `(_, inputId) => {`).
  - Exact changes:
    - In the `${input:<id>}` replacement callback, change the signature from `(_, inputId) => {` to `(_match: string, inputId: string) => {`.
    - Replace the catch error message construction so it does not call `String(error)`.
    - Add a new helper function in this module:
      - Name: `formatUnknownError`
      - Signature: `function formatUnknownError(error: unknown): string`
      - Behavior: return `error.message` when `error instanceof Error`, return `error` when `typeof error === "string"`, otherwise return the literal string `"Unknown error"`.
    - Update the catch block to call `formatUnknownError(error)`.
  - Acceptance: running `npm run test:unit -- --runTestsByPath tests/unit/utility-dispatcher.non-error-throw.test.ts` exits with code 0.

- [ ] [P2-T6] Fix consistent type definitions finding in `src/utilities/utility-spec.ts` by converting object type aliases to interfaces
  - File: `src/utilities/utility-spec.ts`
  - Locations: lines 8-19 (current `export type ExternalUtilitySpec = {` and `export type PowerShellUtilitySpec = {`).
  - Exact changes:
    - Replace `export type ExternalUtilitySpec = {` with `export interface ExternalUtilitySpec {` and replace closing `};` with `}`.
    - Replace `export type PowerShellUtilitySpec = {` with `export interface PowerShellUtilitySpec {` and replace closing `};` with `}`.
    - Keep `export type UtilitySpec = ExternalUtilitySpec | PowerShellUtilitySpec;` as a type union.
  - Acceptance: `npm run lint` output no longer includes `src/utilities/utility-spec.ts` with `@typescript-eslint/consistent-type-definitions`.

### Phase 3 — Final QA (Toolchain Loop)

This phase MUST be repeated from step 1 until a single clean pass completes with no file changes.

- [ ] [P3-T1] Run formatting step: `npm run format`
  - Acceptance: `git diff --name-only` outputs an empty string immediately after the command completes.

- [ ] [P3-T2] Run linting step: `npm run lint`
  - Acceptance: command exits with code 0.

- [ ] [P3-T3] Run typecheck step: `npm run typecheck`
  - Acceptance: command exits with code 0.

- [ ] [P3-T4] Run unit tests step: `npm run test:unit`
  - Acceptance: command exits with code 0.

## Test Plan

- Unit (Jest, Node-only; no VS Code host):
  - Existing coverage to rely on (must remain green):
    - `tests/unit/task-execution-spec.test.ts` covers `resolveTaskArgs` behavior.
    - `tests/unit/utility-dispatcher.test.ts` covers `dispatchUtility` behavior.
- Integration (VS Code extension host):
  - None required for this feature. Do not add integration tests for agent-template or ESLint config changes.
- Manual/CLI:
  - None required. Verification is via the required toolchain loop.

## Open Questions / Notes

- None. This plan is fully specified and self-contained.
