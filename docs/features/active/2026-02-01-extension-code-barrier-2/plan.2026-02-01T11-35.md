# 2026-02-01-extension-code-barrier (Plan)

---
issue: "#2"
parent: "none"
owner: "drmoisan"
last_updated: "2026-02-01T11-35"
status: "Planned"
status_color: "blue"
version: "0.1"
---

Status Badge: ![Status](https://img.shields.io/badge/status-Planned-blue)

Execution Notes:
- Copilot instructions file path to verify: `.github/copilot-instructions.md` (re-check during Phase 0).

Requirements Table:

| ID | Requirement | Source |
| --- | --- | --- |
| REQ-001 | Execute `drm-copilot` commands without workspace `.vscode/tasks.json` by providing tasks programmatically. | spec.md → Scope & Non-Goals, Proposed Fix |
| REQ-002 | Resolve extension-packaged scripts via `context.extensionUri`/`context.asAbsolutePath()` while using workspace folder as `cwd`. | spec.md → Proposed Fix (Boundaries) |
| REQ-003 | Provide deterministic workspace selection: single-root uses the only folder; multi-root prompts for selection; no workspace yields error. | spec.md → Proposed Fix (Data flow) |
| REQ-004 | Preserve existing command IDs and task labels for UI stability. | spec.md → Scope & Non-Goals |
| REQ-005 | Emit actionable errors for missing workspace, unknown command mapping, or missing required input values. | spec.md → Proposed Fix (Error handling) |
| REQ-006 | Resolve task inputs and VS Code variable tokens (`${input:*}`, `${file}`, `${relativeFile}`, `${workspaceFolder}`) for provider-created tasks. | .vscode/tasks.json + spec.md scope |

Constraints Table:

| ID | Constraint | Source |
| --- | --- | --- |
| CON-001 | Do not auto-generate or edit user `.vscode/tasks.json`. | spec.md → Scope & Non-Goals |
| CON-002 | Do not add new runtime dependencies. | spec.md → Dependencies |
| CON-003 | Use VS Code Task APIs (`vscode.tasks.registerTaskProvider`, `ShellExecution`/`ProcessExecution`). | spec.md → Proposed Fix |
| CON-004 | Toolchain loop must pass: `npm run format` → `npm run lint` → `npm run typecheck` → `npm run test:unit`. | typescript-code-change.instructions.md |

Security Table:

| ID | Security Requirement | Source |
| --- | --- | --- |
| SEC-001 | Never write to the extension install directory; only read packaged resources. | spec.md → Boundaries |

Requirements Traceability:

| Requirement ID | Planned Task IDs |
| --- | --- |
| REQ-001 | P2-T4, P2-T5 |
| REQ-002 | P2-T4, P2-T5 |
| REQ-003 | P2-T5, P3-T3 |
| REQ-004 | P2-T1, P2-T5 |
| REQ-005 | P2-T3, P2-T5 |
| REQ-006 | P2-T2, P2-T3, P2-T4, P3-T1 |
| CON-001 | P2-T5 |
| CON-002 | P2-T4, P2-T5 |
| CON-003 | P2-T4, P2-T5 |
| CON-004 | P5-T1 |
| SEC-001 | P2-T4, P2-T5 |

### Phase 0 — Context & Inputs
- [ ] [P0-T1] Read `.github/copilot-instructions.md` and record the result in Execution Notes.
	- Acceptance: Execution Notes includes a line stating either `copilot-instructions.md: read` or `copilot-instructions.md: missing`.
- [ ] [P0-T2] Read `.github/instructions/general-code-change.instructions.md` and record completion in Execution Notes.
	- Acceptance: Execution Notes includes `general-code-change.instructions.md: read`.
- [ ] [P0-T3] Read `.github/instructions/general-unit-test.instructions.md` and record completion in Execution Notes.
	- Acceptance: Execution Notes includes `general-unit-test.instructions.md: read`.
- [ ] [P0-T4] Read `.github/instructions/typescript-code-change.instructions.md` and record completion in Execution Notes.
	- Acceptance: Execution Notes includes `typescript-code-change.instructions.md: read`.
- [ ] [P0-T5] Read `.github/instructions/typescript-unit-test.instructions.md` and record completion in Execution Notes.
	- Acceptance: Execution Notes includes `typescript-unit-test.instructions.md: read`.
- [ ] [P0-T6] Read `.github/instructions/typescript-suppressions.instructions.md` and record completion in Execution Notes.
	- Acceptance: Execution Notes includes `typescript-suppressions.instructions.md: read`.
- [ ] [P0-T7] Read `docs/features/active/2026-02-01-extension-code-barrier-2/spec.md` and record the `Last Updated` value in Execution Notes.
	- Acceptance: Execution Notes includes `spec.last_updated: 2026-02-01T11-35`.
- [ ] [P0-T8] Read `artifacts/research/20260201-extension-code-barrier-implementation-research.md` and record the recommended approach in Execution Notes.
	- Acceptance: Execution Notes includes `research.recommended_approach: task provider + extension-path resolution`.
- [ ] [P0-T9] Capture baseline formatting result with `npm run format` and record exit code in Execution Notes.
	- Acceptance: Execution Notes includes `baseline.format.exit_code: 0`.
- [ ] [P0-T10] Capture baseline lint result with `npm run lint` and record exit code in Execution Notes.
	- Acceptance: Execution Notes includes `baseline.lint.exit_code: 0`.
- [ ] [P0-T11] Capture baseline typecheck result with `npm run typecheck` and record exit code in Execution Notes.
	- Acceptance: Execution Notes includes `baseline.typecheck.exit_code: 0`.
- [ ] [P0-T12] Capture baseline unit test result with `npm run test:unit` and record exit code in Execution Notes.
	- Acceptance: Execution Notes includes `baseline.test_unit.exit_code: 0`.

### Phase 1 — Regression Tests (TDD, expect fail)
- [ ] [P1-T1] [expect-fail] Add Jest test in `tests/unit/task-execution-spec.test.ts` for `getTaskExecutionSpec` returning the command/args for `drm-copilot.qcBlackFormat`.
	- Preconditions: `src/task-command-map.ts` exports `getTaskExecutionSpec` (to be added in Phase 2).
	- Line numbers: new file `tests/unit/task-execution-spec.test.ts` (line numbers N/A).
	- Acceptance: `npm run test:unit -- --runTestsByPath tests/unit/task-execution-spec.test.ts -t "getTaskExecutionSpec returns QC black"` fails with missing export or incorrect mapping.
- [ ] [P1-T2] [expect-fail] Add Jest test in `tests/unit/task-execution-spec.test.ts` for `getTaskInputIdsForCommand` returning `["PotentialPromotionType"]` for `drm-copilot.devPromotePotentialToIssue`.
	- Preconditions: `src/task-command-map.ts` exports `getTaskInputIdsForCommand` (to be added in Phase 2).
	- Line numbers: new file `tests/unit/task-execution-spec.test.ts` (line numbers N/A).
	- Acceptance: `npm run test:unit -- --runTestsByPath tests/unit/task-execution-spec.test.ts -t "getTaskInputIdsForCommand uses inputs"` fails with missing export or incorrect input mapping.
- [ ] [P1-T3] [expect-fail] Add Jest test in `tests/unit/task-execution-spec.test.ts` for `resolveTaskArgs` replacing `${workspaceFolder}`, `${extensionRoot}`, `${file}`, `${relativeFile}`, and `${input:PotentialShortName}` tokens.
	- Preconditions: `src/task-command-map.ts` exports `resolveTaskArgs` (to be added in Phase 2).
	- Line numbers: new file `tests/unit/task-execution-spec.test.ts` (line numbers N/A).
	- Acceptance: `npm run test:unit -- --runTestsByPath tests/unit/task-execution-spec.test.ts -t "resolveTaskArgs replaces tokens"` fails with missing export or incorrect substitution.
- [ ] [P1-T4] [expect-fail] Add Jest test in `tests/unit/task-execution-spec.test.ts` for `resolveTaskArgs` throwing `Missing input value: <id>` when `${input:<id>}` is not provided.
	- Preconditions: `src/task-command-map.ts` exports `resolveTaskArgs` (to be added in Phase 2).
	- Line numbers: new file `tests/unit/task-execution-spec.test.ts` (line numbers N/A).
	- Acceptance: `npm run test:unit -- --runTestsByPath tests/unit/task-execution-spec.test.ts -t "resolveTaskArgs missing input"` fails with missing export or missing error handling.
- [ ] [P1-T5] [expect-fail] Run the new tests to confirm the regression coverage fails before implementation.
	- Depends on: [P1-T1], [P1-T2], [P1-T3], [P1-T4].
	- Acceptance: `npm run test:unit -- --runTestsByPath tests/unit/task-execution-spec.test.ts` exits with non-zero status.

### Phase 2 — Implementation (make tests pass)
- [ ] [P2-T1] Add `TaskExecutionSpec` type and `TASK_EXECUTION_MAP` in `src/task-command-map.ts` (insert after line 6, before line 7) with one entry per `TaskCommandId`.
	- Depends on: [P1-T5].
	- Implementation details:
		- Use `Record<TaskCommandId, TaskExecutionSpec>` with `satisfies` to enforce completeness.
		- For each task label in `.vscode/tasks.json`, copy `command` and `args`.
		- Replace script path args starting with `${workspaceFolder}/scripts/` or `${workspaceFolder}/.github/` with `${extensionRoot}/...` tokens.
		- For `npm: watch`, set `command: "npm"` and `args: ["run", "watch"]`.
	- Acceptance: `TASK_EXECUTION_MAP` has the same number of entries as `TASK_COMMAND_MAP` and is type-checked by TypeScript.
- [ ] [P2-T2] Add `TaskInputDefinition` type and `TASK_INPUT_DEFINITIONS` array in `src/task-command-map.ts` (insert after `TASK_EXECUTION_MAP`, before line 52).
	- Depends on: [P2-T1].
	- Implementation details:
		- Include ids: `PRBaseBranch`, `PotentialShortName`, `PotentialBugShortName`, `PotentialPromotionType`, `ActiveFeatureName`, `ExecutePlanFeatureFolder`, `ActiveWorkType`, `ActiveIssueNumber`, `LinkIssueNumber`, `LinkFeatureName`, `ChildIssueNumber`, `ParentIssueNumber`, `ExecutePlanAgent`, `AtomicPreferredModel`, `AtomicFeaturePath`.
		- Preserve `default`, `description`, and `options` values from `.vscode/tasks.json`.
	- Acceptance: `TASK_INPUT_DEFINITIONS` contains all input ids listed above with exact defaults and options.
- [ ] [P2-T3] Add pure helper exports in `src/task-command-map.ts` (insert after line 52 and before line 54) for task lookup and argument resolution.
	- Depends on: [P2-T2].
	- Implementation details:
		- `getTaskExecutionSpec(commandId: TaskCommandId): TaskExecutionSpec | undefined`.
		- `getTaskInputDefinition(id: string): TaskInputDefinition | undefined`.
		- `getTaskInputIdsForCommand(commandId: TaskCommandId): string[]` by scanning `TASK_EXECUTION_MAP[commandId].args` for `${input:<id>}` patterns.
		- `resolveTaskArgs(args: string[], context: { workspaceRoot: string; extensionRoot: string; activeFilePath?: string; activeRelativePath?: string; inputValues: Record<string, string>; }): string[]` that replaces tokens and throws `Error("Missing input value: <id>")` when missing.
	- Acceptance: Functions are exported, unit-testable without `vscode`, and match the Phase 1 test expectations.
- [ ] [P2-T4] Add `src/drm-task-provider.ts` implementing `DrmCopilotTaskProvider` and task creation.
	- Depends on: [P2-T1], [P2-T2], [P2-T3].
	- Line numbers: new file `src/drm-task-provider.ts` (line numbers N/A).
	- Implementation details:
		- Export `createDrmCopilotTaskProvider(context: vscode.ExtensionContext): vscode.TaskProvider`.
		- Use `getTaskExecutionSpec` and `resolveTaskArgs` to build `vscode.Task` with `ShellExecution` or `ProcessExecution`.
		- Always set `task.scope` to the selected workspace folder and set `options.cwd` to that folder.
		- Convert `${extensionRoot}` tokens using `context.asAbsolutePath()` before calling `resolveTaskArgs`.
	- Acceptance: Provider compiles, and task creation uses extension script paths and workspace `cwd`.
- [ ] [P2-T5] Update `src/extension.ts` (lines 14–74) to use provider-backed task execution and deterministic workspace selection.
	- Depends on: [P2-T4].
	- Implementation details:
		- Replace `runTaskByLabel` with `runTaskByCommandId(commandId: string)`.
		- Add `getTargetWorkspaceFolder()` helper that:
			- returns the only folder when length is 1,
			- prompts with `vscode.window.showWorkspaceFolderPick` when length > 1,
			- shows error and returns `undefined` when length is 0.
		- Register `DrmCopilotTaskProvider` in `activate` and dispose it via `context.subscriptions`.
		- `registerTaskCommand` should call `runTaskByCommandId(commandId)`.
	- Acceptance: `extension.ts` no longer calls `vscode.tasks.fetchTasks()` and uses the provider path.
- [ ] [P2-T6] Update `package.json` to add a `contributes.taskDefinitions` entry for type `drm-copilot` if absent (insert under line 16 in the `contributes` object).
	- Depends on: [P2-T4].
	- Implementation details:
		- Add `"contributes": { "taskDefinitions": [{ "type": "drm-copilot" }] }` or merge into existing `contributes`.
	- Acceptance: `package.json` contains `contributes.taskDefinitions` with type `drm-copilot` and no schema errors.

### Phase 3 — Unit Test Pass & Edge Validation
- [ ] [P3-T1] Add Jest test in `tests/unit/task-execution-spec.test.ts` for `getTaskExecutionSpec` returning `undefined` on unknown command id.
	- Depends on: [P2-T3].
	- Line numbers: new file `tests/unit/task-execution-spec.test.ts` (line numbers N/A).
	- Acceptance: `npm run test:unit -- --runTestsByPath tests/unit/task-execution-spec.test.ts -t "unknown command id"` passes.
- [ ] [P3-T2] Run `npm run test:unit -- --runTestsByPath tests/unit/task-execution-spec.test.ts` and confirm all new tests pass.
	- Depends on: [P2-T1], [P2-T2], [P2-T3], [P2-T4], [P2-T5], [P2-T6], [P3-T1].
	- Acceptance: Command exits with code 0 and no failed tests in the output.

### Phase 4 — Integration Validation (non-hosted)
- [ ] [P4-T1] Update `tests/integration/extension.test.ts` (lines 1–15) to replace the sample test with an assertion that the extension activates and registers commands for all `TaskCommandId` values.
	- Depends on: [P2-T5].
	- Acceptance: `npm run test:unit -- --runTestsByPath tests/integration/extension.test.ts` passes.

### Phase 5 — QA Toolchain Loop
- [ ] [P5-T1] Run `npm run format` and restart the loop if files change.
	- Depends on: [P4-T1].
	- Acceptance: Command exits with code 0 and no files are modified after a clean run.
- [ ] [P5-T2] Run `npm run lint` and restart the loop from P5-T1 if it fails or changes files.
	- Depends on: [P5-T1].
	- Acceptance: Command exits with code 0.
- [ ] [P5-T3] Run `npm run typecheck` and restart the loop from P5-T1 if it fails.
	- Depends on: [P5-T2].
	- Acceptance: Command exits with code 0.
- [ ] [P5-T4] Run `npm run test:unit` and restart the loop from P5-T1 if it fails.
	- Depends on: [P5-T3].
	- Acceptance: Command exits with code 0.

### Phase 6 — Documentation & Status
- [ ] [P6-T1] Update `docs/features/active/2026-02-01-extension-code-barrier-2/spec.md` with any scope deviations and final test evidence.
	- Depends on: [P5-T4].
	- Acceptance: Spec includes the final test command list and outcomes.
- [ ] [P6-T2] Update this plan file status to `In progress` at start of execution, including badge color update to yellow.
	- Depends on: [P0-T1].
	- Acceptance: Front matter shows `status: "In progress"` and badge uses `status-In%20progress-yellow`.
- [ ] [P6-T3] Update this plan file status to `Completed` at finish, including badge color update to bright green.
	- Depends on: [P6-T1].
	- Acceptance: Front matter shows `status: "Completed"` and badge uses `status-Completed-brightgreen`.

### Phase 7 — Handoff
- [ ] [P7-T1] Prepare PR notes summarizing changes, risks, and validation commands in the PR description.
	- Depends on: [P6-T3].
	- Acceptance: PR description includes summary, risks, and toolchain results.
