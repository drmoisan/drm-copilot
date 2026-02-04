# 2026-02-01-extension-code-barrier - Plan

- **Issue:** #2
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-03T15-51
- **Status:** Planned
- **Version:** 2.0

Status Badge: ![Status](https://img.shields.io/badge/status-Planned-blue)

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- TypeScript Coding Standards: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test Policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- TypeScript Suppressions: [`.github/instructions/typescript-suppressions.instructions.md`](../../../../.github/instructions/typescript-suppressions.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Requirements & Constraints

| ID | Type | Requirement / Constraint | Source |
| --- | --- | --- | --- |
| REQ-001 | Requirement | Execute all `drm-copilot` commands in any workspace without workspace-local `.vscode/tasks.json` or scripts. | `v2/spec.md` Scope & Proposed Fix |
| REQ-002 | Requirement | Execute utilities from extension-owned assets and avoid workspace-local module imports such as `scripts.dev_tools.*`. | `v2/spec.md` Proposed Fix |
| REQ-003 | Requirement | Deterministic workspace selection: single-root uses the only folder; multi-root prompts; none shows error. | `v2/spec.md` Proposed Fix |
| REQ-004 | Requirement | Preserve existing command IDs and labels. | `v2/spec.md` Scope |
| REQ-005 | Requirement | Emit actionable errors for missing workspace, missing utility mapping, or missing host tools. | `v2/spec.md` Proposed Fix |
| REQ-006 | Requirement | Preflight check host tool dependencies (`poetry`, `python`, `pwsh`, `gh`, `npm`) when required. | `v2/spec.md` Proposed Fix |
| CON-001 | Constraint | Do not edit user `.vscode/tasks.json`. | `v2/spec.md` Scope |
| CON-002 | Constraint | Avoid direct `child_process`-style execution paths; prefer VS Code task/process execution abstractions. | `v2/spec.md` Non-Goals |

## Implementation Plan (Atomic Tasks)

### Phase 0 — Context & Inputs
- [x] [P0-T1] Create `docs/features/active/2026-02-01-extension-code-barrier-2/v2/baseline/` directory
  - Acceptance: `docs/features/active/2026-02-01-extension-code-barrier-2/v2/baseline/` exists
- [x] [P0-T2] Read `.github/copilot-instructions.md` and record completion in a local execution note
  - Acceptance: Note includes `copilot-instructions.md: read`
- [x] [P0-T3] Read `.github/instructions/general-code-change.instructions.md`
  - Acceptance: Note includes `general-code-change.instructions.md: read`
- [x] [P0-T4] Read `.github/instructions/general-unit-test.instructions.md`
  - Acceptance: Note includes `general-unit-test.instructions.md: read`
- [x] [P0-T5] Read `.github/instructions/typescript-code-change.instructions.md`
  - Acceptance: Note includes `typescript-code-change.instructions.md: read`
- [x] [P0-T6] Read `.github/instructions/typescript-unit-test.instructions.md`
  - Acceptance: Note includes `typescript-unit-test.instructions.md: read`
- [x] [P0-T7] Read `.github/instructions/typescript-suppressions.instructions.md`
  - Acceptance: Note includes `typescript-suppressions.instructions.md: read`
- [x] [P0-T8] Read `docs/features/active/2026-02-01-extension-code-barrier-2/v2/spec.md`
  - Acceptance: Note includes `spec.md: read`
- [x] [P0-T9] Read `docs/features/active/2026-02-01-extension-code-barrier-2/v2/research.md`
  - Acceptance: Note includes `research.md: read`
- [x] [P0-T10] Capture baseline format output to `docs/features/active/2026-02-01-extension-code-barrier-2/v2/baseline/format.txt` using `npm run format`
  - Acceptance: Command exits with code 0
- [x] [P0-T11] Capture baseline lint output to `docs/features/active/2026-02-01-extension-code-barrier-2/v2/baseline/lint.txt` using `npm run lint`
  - Acceptance: Command exits with code 0
- [x] [P0-T12] Capture baseline typecheck output to `docs/features/active/2026-02-01-extension-code-barrier-2/v2/baseline/typecheck.txt` using `npm run typecheck`
  - Acceptance: Command exits with code 0
- [x] [P0-T13] Capture baseline unit test output to `docs/features/active/2026-02-01-extension-code-barrier-2/v2/baseline/test-unit.txt` using `npm run test:unit`
  - Acceptance: Command exits with code 0

### Phase 1 — Utility Map & Contracts (TDD)
- [x] [P1-T1] [expect-fail] Add Jest test in `tests/unit/utility-spec.test.ts` asserting `getUtilitySpec("drm-copilot.qcFixAll")` resolves to an external-tool spec that sets `env.PYTHONPATH` to the extension root
  - Acceptance: Test file created with test case that expects failure (missing export or mismatched spec)
- [x] [P1-T2] [expect-fail] Add Jest test in `tests/unit/utility-spec.test.ts` asserting `getUtilitySpec("drm-copilot.devNewPotentialEntry")` resolves to a PowerShell spec with `${extensionRoot}/scripts/dev-tools/new-potential-entry.ps1`
  - Acceptance: Test case added that expects failure (missing export or mismatched spec)
- [x] [P1-T3] [expect-fail] Add Jest test in `tests/unit/utility-spec.test.ts` asserting `getRequiredInputIds("drm-copilot.devNewPotentialEntry")` returns `["PotentialShortName"]`
  - Acceptance: Test case added that expects failure (missing export or incorrect inputs)
- [x] [P1-T4] Implement `src/utilities/utility-spec.ts` with `UtilitySpec`, `UtilityKind`, `UTILITY_COMMAND_SPECS`, `getUtilitySpec`, and `getRequiredInputIds`
  - Preconditions: Command IDs are sourced from `TaskCommandId` in `src/task-command-map.ts`
  - Acceptance: `npm run test:unit -- --runTestsByPath tests/unit/utility-spec.test.ts` passes after implementation
  - Requirements: REQ-001, REQ-002, REQ-004

### Phase 2 — Workspace Context & Input Resolution (TDD)
- [x] [P2-T1] [expect-fail] Add Jest test in `tests/unit/workspace-context.test.ts` for `resolveWorkspaceFolder` returning the only folder and not prompting
  - Acceptance: Test file created with test case that expects failure (missing function)
- [x] [P2-T2] [expect-fail] Add Jest test in `tests/unit/workspace-context.test.ts` for `resolveWorkspaceFolder` showing error and returning undefined when no folders exist
  - Acceptance: Test case added that expects failure (missing function)
- [x] [P2-T3] [expect-fail] Add Jest test in `tests/unit/input-collection.test.ts` for `collectCommandInputs` returning default value when prompt returns undefined (user cancel)
  - Acceptance: Test file created with test case that expects failure (missing function)
- [x] [P2-T4] Implement `src/utilities/workspace-context.ts` with `resolveWorkspaceFolder` using `vscode.workspace.workspaceFolders` and `vscode.window.showWorkspaceFolderPick`
  - Acceptance: Implementation complete with workspace-context tests passing
  - Requirements: REQ-003, REQ-005
- [x] [P2-T5] Implement `src/utilities/input-collection.ts` with `collectCommandInputs` that uses `TASK_INPUT_DEFINITIONS` from `src/task-command-map.ts`
  - Acceptance: `npm run test:unit -- --runTestsByPath tests/unit/workspace-context.test.ts tests/unit/input-collection.test.ts` passes after implementation
  - Requirements: REQ-005

### Phase 3 — Runtime Dispatcher & Tool Preflight (TDD)
- [x] [P3-T1] [expect-fail] Add Jest test in `tests/unit/tool-preflight.test.ts` for `resolveExecutable("gh")` returning undefined when PATH lacks the executable
  - Acceptance: Test file created with test case that expects failure (missing function)
- [x] [P3-T2] [expect-fail] Add Jest test in `tests/unit/utility-dispatcher.test.ts` for `dispatchUtility` returning a user-facing error when tool preflight fails
  - Acceptance: Test file created with test case that expects failure (missing function)
- [x] [P3-T3] Implement `src/utilities/tool-preflight.ts` with `resolveExecutable` that scans `process.env.PATH` and applies `.exe` suffix on Windows
  - Acceptance: Implementation complete with tool-preflight tests passing
  - Requirements: REQ-006
- [x] [P3-T4] Implement `src/utilities/utility-dispatcher.ts` with `dispatchUtility(commandId, context)` that:
  - Looks up `UtilitySpec` from `utility-spec.ts`
  - Validates required inputs
  - Performs host-tool preflight when `UtilitySpec.kind === "external"`
  - Executes via VS Code task/process execution using `ProcessExecution` (no workspace `tasks.json`)
  - Acceptance: Implementation complete and all Phase 3 tests pass
  - Requirements: REQ-001, REQ-002, REQ-005, REQ-006, CON-001, CON-002

### Phase 4 — Extension Wiring & Command Execution
- [x] [P4-T1] Update `src/extension.ts` to route all command handlers through `dispatchUtility` and remove `ShellExecution` task construction
  - Acceptance: TypeScript compilation succeeds with no references to `getTaskExecutionSpec` in `extension.ts`
  - Requirements: REQ-001, REQ-004
- [x] [P4-T2] Update `src/task-command-map.ts` to keep `TASK_COMMAND_MAP` and `TASK_INPUT_DEFINITIONS` only, and remove dependency on `TASK_EXECUTION_MAP` for runtime execution
  - Acceptance: `tsc -p ./ --noEmit` succeeds with no unused `TASK_EXECUTION_MAP` references ✅
  - Requirements: REQ-002, REQ-004
- [x] [P4-T3] Update or deprecate `src/drm-task-provider.ts` so command execution no longer depends on provider-backed task creation
  - Acceptance: No command handler uses provider-backed task creation in `extension.ts` ✅
  - Requirements: REQ-001

### Phase 5 — Utility Spec Completion (Extension-Owned Paths)
- [x] [P5-T1] Populate `UTILITY_COMMAND_SPECS` entries to replace workspace-local module execution with extension-owned paths
  - Acceptance: For each command that previously used `scripts.dev_tools.*`, the spec sets `env.PYTHONPATH` to the extension root and points to the extension-owned module or script path ✅
  - Requirements: REQ-001, REQ-002
- [x] [P5-T2] Add Jest test in `tests/unit/utility-spec.test.ts` to validate that `UTILITY_COMMAND_SPECS` entries referencing PowerShell scripts use `${extensionRoot}` paths (no `${workspaceFolder}`)
  - Acceptance: `npm run test:unit -- --runTestsByPath tests/unit/utility-spec.test.ts -t "ps scripts use extensionRoot"` passes ✅
  - Requirements: REQ-002

### Phase 6 — QA Toolchain Loop
- [x] [P6-T1] Run `npm run format` and restart this phase if files change
  - Acceptance: Command exits with code 0 and no file changes after a clean run
- [x] [P6-T2] Run `npm run lint` and restart from P6-T1 if it fails or changes files
  - Acceptance: Command exits with code 0
- [x] [P6-T3] Run `npm run typecheck` and restart from P6-T1 if it fails
  - Acceptance: Command exits with code 0
- [x] [P6-T4] Run `npm run test:unit` and restart from P6-T1 if it fails
  - Acceptance: Command exits with code 0

## Test Plan

- Unit: Jest tests in `tests/unit/*.test.ts` covering utility spec mapping, workspace context selection, input collection, tool preflight, and utility dispatch error handling.
- Integration: `tests/integration/extension.test.ts` updated to validate command registration and that command execution does not depend on workspace tasks.
- Manual/CLI: Install extension in a clean workspace with no `.vscode/tasks.json`, invoke `drm-copilot.devNewPotentialEntry`, confirm extension-owned script path usage and workspace output changes.

## Open Questions / Notes

- None.
