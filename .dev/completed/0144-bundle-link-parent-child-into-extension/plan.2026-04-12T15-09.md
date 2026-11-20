# Atomic Plan — Feature #144 Link Parent/Child Bundling

## Overview
This large-path full-feature plan bundles the existing `scripts/dev-tools/link-parent-child.ps1` workflow into the published extension runtime, adds an interactive VS Code command, and exposes the same operation through the extension MCP server with explicit child/parent inputs. Scope is limited to the root script mirror under `extensions/drm-copilot/resources/templates/`, the shared repo-automation service, extension command and argument parsing, MCP input and dispatch plumbing, targeted tests, README updates, and evidence artifacts under this feature folder.

Preserved constraints:
- Keep the root script behavior intact and preserve the PowerShell CLI parameters `-ChildIssueNumber` and `-ParentIssueNumber`.
- Route both the VS Code command and the MCP tool through the shared repo-automation service; do not introduce a one-off subprocess path in the command handler or MCP layer.
- Remove the runtime dependency on `${workspaceFolder}/scripts/dev-tools/link-parent-child.ps1` for the extension-published surfaces.
- If execution reveals that a non-additive script behavior change would be required, stop and request replanning instead of widening scope silently.

Planned semantic surface:
- VS Code command: `drmCopilotExtension.linkParentChild`
- MCP tool: `link_parent_child`
- Direct command flags: `-ChildIssueNumber <digits>` and `-ParentIssueNumber <digits>`
- MCP inputs: `child_issue_number`, `parent_issue_number`

### Phase 0 — Baseline Capture
- [ ] [P0-T1] Read policy and requirements files in required order and persist evidence at `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/baseline/phase0-instructions-read.2026-04-12T15-09.md`.
  - Acceptance: Evidence file exists and contains `Timestamp:`, `Policy Order:`, `Work Mode Source: issue.md`, `Resolved Work Mode: full-feature`, and an explicit ordered list of files read: `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, `.github/instructions/typescript-suppressions.instructions.md`, `.github/instructions/powershell-code-change.instructions.md`, `.github/instructions/powershell-unit-test.instructions.md`, `AGENTS.md`, `.vscode/tasks.json`, `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/issue.md`, `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/spec.md`, `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/user-story.md`, and `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/research.md`.

- [ ] [P0-T2] Record the pre-edit link-parent-child surface inventory at `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/other/link-parent-child-surface-inventory.2026-04-12T15-09.md` by running `rg -n "Dev: 4 Link GitHub Parent/Child Issues|drmCopilotExtension\\.linkParentChild|link_parent_child|link-parent-child\\.ps1|ChildIssueNumber|ParentIssueNumber" .vscode/tasks.json extensions/drm-copilot/src extensions/drm-copilot/test extensions/drm-copilot/resources scripts tests -S`.
  - Acceptance: Evidence file contains `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`; identifies the task-backed workspace script path in `.vscode/tasks.json`; identifies the absence of a current extension command and MCP tool; and locks in the likely changed files for this plan.

- [ ] [P0-T3] Capture the TypeScript baseline formatting result by running `npm run format` from `extensions/drm-copilot/` and write `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/baseline/ts-format.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run format`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T4] Capture the TypeScript baseline lint result by running `npm run lint` from `extensions/drm-copilot/` and write `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/baseline/ts-lint.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run lint`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T5] Capture the TypeScript baseline type-check result by running `npm run typecheck` from `extensions/drm-copilot/` and write `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/baseline/ts-typecheck.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T6] Capture the TypeScript baseline unit-test and coverage result by running `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` from `extensions/drm-copilot/` and write `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/baseline/ts-test-unit.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`, `EXIT_CODE:`, and `Output Summary:` with numeric baseline coverage headline values.

- [ ] [P0-T7] Capture the PowerShell baseline format result by running `mcp__drmCopilotExtension__run_poshqc_format` with `workspace_root: c:/Users/DanMoisan/repos/drm-copilot-2026-04-02` and `scan_folders: ["scripts/dev-tools","tests/scripts/dev-tools","extensions/drm-copilot/resources/templates"]`, then write `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/baseline/powershell-format.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_format`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T8] Capture the PowerShell baseline analysis result by running `mcp__drmCopilotExtension__run_poshqc_analyze` with `workspace_root: c:/Users/DanMoisan/repos/drm-copilot-2026-04-02` and `scan_folders: ["scripts/dev-tools","tests/scripts/dev-tools","extensions/drm-copilot/resources/templates"]`, then write `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/baseline/powershell-analyze.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_analyze`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T9] Capture the PowerShell baseline Pester and coverage result by running `mcp__drmCopilotExtension__run_poshqc_test` with `workspace_root: c:/Users/DanMoisan/repos/drm-copilot-2026-04-02` and `scan_folders: ["scripts/dev-tools","tests/scripts/dev-tools","extensions/drm-copilot/resources/templates"]`, then write `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/baseline/powershell-test.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_test`, `EXIT_CODE:`, and `Output Summary:` with numeric baseline coverage headline values extracted from the generated PowerShell coverage outputs when available.

- [ ] [P0-T10] Capture the governed-JSON baseline formatting result by running `poetry run python -m scripts.dev_tools.format_json` from the repo root and write `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/baseline/json-format.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run python -m scripts.dev_tools.format_json`, `EXIT_CODE:`, and `Output Summary:`.

- [ ] [P0-T11] Capture the governed-JSON baseline validation result by running `poetry run python -m scripts.dev_tools.validate_json` from the repo root and write `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/baseline/json-validate.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run python -m scripts.dev_tools.validate_json`, `EXIT_CODE:`, and `Output Summary:`.

### Phase 1 — Bundle the PowerShell Workflow and Shared Service Entry
- [ ] [P1-T1] Copy `scripts/dev-tools/link-parent-child.ps1` byte-for-byte to `extensions/drm-copilot/resources/templates/link-parent-child.ps1`.
  - Acceptance: `extensions/drm-copilot/resources/templates/link-parent-child.ps1` exists, matches the root script exactly at copy time, and preserves the `-ChildIssueNumber` and `-ParentIssueNumber` parameters.

- [ ] [P1-T2] Update `tests/scripts/dev-tools/link-parent-child.Tests.ps1` to add a parity scenario proving the bundled template matches the repo-root script exactly and that the preserved CLI contract still centers on `-ChildIssueNumber` and `-ParentIssueNumber`.
  - Acceptance: The Pester file contains a deterministic parity test for `extensions/drm-copilot/resources/templates/link-parent-child.ps1`, and no test in the file requires external services or temporary runtime-created fixtures beyond the script’s existing mocked interactions.

- [ ] [P1-T3] Extend `extensions/drm-copilot/src/repo-automation-service.ts` with an additive `link_parent_child` workflow entry and service method that launches `resources/templates/link-parent-child.ps1` with `-ChildIssueNumber` and `-ParentIssueNumber`.
  - Acceptance: `REPO_AUTOMATION_TOOLS`, the service interface, and the default service implementation expose the new workflow; the service emits a concise summary; and the runtime path is always the bundled extension script rather than `${workspaceFolder}/scripts/dev-tools/link-parent-child.ps1`.

- [ ] [P1-T4] Update `extensions/drm-copilot/test/repo-automation-service.test.ts` to cover bundled path resolution, summary text, and argv propagation for the new service method.
  - Acceptance: Tests prove the service forwards `-ChildIssueNumber` and `-ParentIssueNumber` exactly once each, uses `resources/templates/link-parent-child.ps1`, and does not spawn the repo-local script path.

### Phase 2 — Add the Interactive VS Code Command Surface
- [ ] [P2-T1] Add a typed `LinkParentChildInput` contract and invocation parser to `extensions/drm-copilot/src/workflow-command-arguments.ts` that accepts direct flags `-ChildIssueNumber` and `-ParentIssueNumber`, validates digit-only values, and falls back to interactive mode when no args are supplied.
  - Acceptance: The parser rejects unknown or duplicate flags, rejects blank or non-digit issue numbers, and preserves the script parameter names instead of inventing new direct-invocation flags.

- [ ] [P2-T2] Update `extensions/drm-copilot/test/workflow-command-arguments.test.ts` to cover direct parsing, interactive fallback, duplicate-flag rejection, unknown-flag rejection, and digit-only validation for `-ChildIssueNumber` and `-ParentIssueNumber`.
  - Acceptance: Tests fail without the new parser behavior and pass when the direct invocation contract is typed and validated correctly.

- [ ] [P2-T3] Add the command contribution `drmCopilotExtension.linkParentChild` to `extensions/drm-copilot/package.json`.
  - Acceptance: The manifest contributes one new stable command id with a title that clearly describes linking parent and child GitHub issues, and no existing command ids are renamed.

- [ ] [P2-T4] Register `drmCopilotExtension.linkParentChild` in `extensions/drm-copilot/src/extension.ts` so direct invocations bypass prompts and interactive invocations prompt for the same two values currently collected by `.vscode/tasks.json`.
  - Acceptance: The handler resolves `workspaceRoot` via the shared command runtime, prompts first for child issue number and then for parent tracking issue number when no direct args are supplied, and routes execution through the shared repo-automation service method rather than a bespoke subprocess call.

- [ ] [P2-T5] Update `extensions/drm-copilot/test/extension.workflow-commands.test.ts` and `extensions/drm-copilot/test/extension.test.ts` to cover command registration, interactive prompt ordering, prompt cancellation, and direct invocation routing for `drmCopilotExtension.linkParentChild`.
  - Acceptance: The workflow-command suite verifies prompt order and argument forwarding, and the registration suite proves the new command is registered exactly once.

- [ ] [P2-T6] Update `extensions/drm-copilot/test/extension.integration.test.ts` to verify the command executes the bundled `link-parent-child.ps1` template against the active workspace root rather than the workspace-local task path.
  - Acceptance: The integration test asserts the executed bundled relative path ends with `resources/templates/link-parent-child.ps1` and the argv payload contains the child and parent issue numbers supplied by the command layer.

### Phase 3 — Expose the MCP Tool Surface
- [ ] [P3-T1] Add a `LinkParentChildToolInput` resolver to `extensions/drm-copilot/src/mcp-tool-inputs.ts` that requires explicit `child_issue_number` and `parent_issue_number` string fields and normalizes `workspace_root`.
  - Acceptance: The resolver rejects missing, blank, or non-digit issue numbers before service dispatch and returns a typed object aligned with the service method contract.

- [ ] [P3-T2] Update `extensions/drm-copilot/test/mcp-tool-inputs.test.ts` to cover valid inputs, missing fields, blank values, non-digit values, and workspace-root normalization for `link_parent_child`.
  - Acceptance: Tests fail without the new input normalizer and pass once MCP callers must provide both explicit issue numbers.

- [ ] [P3-T3] Add `link_parent_child` metadata and dispatch handling to `extensions/drm-copilot/src/mcp-tools.ts`, routing the normalized MCP input through the shared repo-automation service method.
  - Acceptance: The MCP tool schema requires `child_issue_number` and `parent_issue_number`, sets `additionalProperties: false`, and returns the standard structured result shape without introducing a second execution path.

- [ ] [P3-T4] Update `extensions/drm-copilot/test/mcp-server.test.ts` to verify `link_parent_child` appears in `ListTools` and dispatches `CallTool` through the shared repo-automation service with the normalized input contract.
  - Acceptance: Server tests prove the new semantic tool is discoverable and forwards the expected workspace root, child issue number, and parent issue number to the service.

- [ ] [P3-T5] Update `extensions/drm-copilot/README.md` so the published command and MCP tool lists document `drmCopilotExtension.linkParentChild` and `link_parent_child`, including the interactive prompts and explicit MCP input fields.
  - Acceptance: README entries describe the two supported entrypoints, preserve the `-ChildIssueNumber` and `-ParentIssueNumber` script contract in the command section, and document `child_issue_number` plus `parent_issue_number` in the MCP section.

### Phase 4 — Targeted Regression Evidence and Bundled-Surface Verification
- [ ] [P4-T1] Run the focused Pester suite with `pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Pester -Path ./tests/scripts/dev-tools/link-parent-child.Tests.ps1 -Output Detailed"` from the repo root and write `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/regression-testing/powershell-link-parent-child.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, the exact `Command:`, `EXIT_CODE: 0`, and `Output Summary:` naming the root-behavior and bundled-parity scenarios that passed.

- [ ] [P4-T2] Run the focused Jest regression suite from `extensions/drm-copilot/` using `node run-jest.cjs --runTestsByPath test/repo-automation-service.test.ts test/workflow-command-arguments.test.ts test/extension.workflow-commands.test.ts test/extension.integration.test.ts test/extension.test.ts test/mcp-tool-inputs.test.ts test/mcp-server.test.ts` and write `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/regression-testing/ts-link-parent-child.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, the exact `Command:`, `EXIT_CODE: 0`, and `Output Summary:` naming the command, service, and MCP suites that passed.

- [ ] [P4-T3] Run the post-edit surface scan with `rg -n "link-parent-child\\.ps1|drmCopilotExtension\\.linkParentChild|link_parent_child|\\$\\{workspaceFolder\\}/scripts/dev-tools/link-parent-child\\.ps1" .vscode/tasks.json extensions/drm-copilot/src extensions/drm-copilot/test extensions/drm-copilot/resources scripts tests -S` and write `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/regression-testing/bundled-surface-verification.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command:`, `EXIT_CODE: 0`, and `Output Summary:` confirming the extension command and MCP tool reference the bundled template while the workspace-local path remains only in the legacy task and root script source locations.

### Phase 5 — Final TypeScript QA Loop
- [ ] [P5-T1] Run final TypeScript formatting from `extensions/drm-copilot/` using `npm run format` and capture `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/qa-gates/ts-format.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run format`, `EXIT_CODE: 0`, and `Output Summary:`.

- [ ] [P5-T2] Run final TypeScript lint from `extensions/drm-copilot/` using `npm run lint` and capture `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/qa-gates/ts-lint.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run lint`, `EXIT_CODE: 0`, and `Output Summary:`; if this step changes files or fails, restart Phase 5 from [P5-T1].

- [ ] [P5-T3] Run final TypeScript type-check from `extensions/drm-copilot/` using `npm run typecheck` and capture `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/qa-gates/ts-typecheck.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run typecheck`, `EXIT_CODE: 0`, and `Output Summary:`; if this step fails, restart Phase 5 from [P5-T1].

- [ ] [P5-T4] Run final TypeScript unit tests with coverage from `extensions/drm-copilot/` using `npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary` and capture `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/qa-gates/ts-test-unit.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: npm run test:unit -- --coverage --coverageReporters=text-summary --coverageReporters=json-summary`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage headline values; if this step fails, restart Phase 5 from [P5-T1].

- [ ] [P5-T5] Record the final TypeScript coverage disposition at `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/qa-gates/ts-coverage-summary.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: derived-from-P0-T6-and-P5-T4`, `EXIT_CODE: 0`, and `Output Summary:`; cites the baseline coverage from [P0-T6]; cites the post-change coverage from [P5-T4]; states whether coverage regressed; and states `remediation required` rather than `PASS` if changed/new-code coverage cannot be determined deterministically from the recorded evidence.

### Phase 6 — Final PowerShell and Governed-JSON QA Loop
- [ ] [P6-T1] Run final PowerShell formatting by calling `mcp__drmCopilotExtension__run_poshqc_format` with `workspace_root: c:/Users/DanMoisan/repos/drm-copilot-2026-04-02` and `scan_folders: ["scripts/dev-tools","tests/scripts/dev-tools","extensions/drm-copilot/resources/templates"]`, then capture `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/qa-gates/powershell-format.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_format`, `EXIT_CODE: 0`, and `Output Summary:`.

- [ ] [P6-T2] Run final PowerShell analysis by calling `mcp__drmCopilotExtension__run_poshqc_analyze` with `workspace_root: c:/Users/DanMoisan/repos/drm-copilot-2026-04-02` and `scan_folders: ["scripts/dev-tools","tests/scripts/dev-tools","extensions/drm-copilot/resources/templates"]`, then capture `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/qa-gates/powershell-analyze.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_analyze`, `EXIT_CODE: 0`, and `Output Summary:`; if this step changes files or fails, restart Phase 6 from [P6-T1].

- [ ] [P6-T3] Run final PowerShell Pester and coverage validation by calling `mcp__drmCopilotExtension__run_poshqc_test` with `workspace_root: c:/Users/DanMoisan/repos/drm-copilot-2026-04-02` and `scan_folders: ["scripts/dev-tools","tests/scripts/dev-tools","extensions/drm-copilot/resources/templates"]`, then capture `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/qa-gates/powershell-test.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: mcp__drmCopilotExtension__run_poshqc_test`, `EXIT_CODE: 0`, and `Output Summary:` with numeric post-change coverage headline values extracted from the generated PowerShell coverage outputs when available; if this step fails, restart Phase 6 from [P6-T1].

- [ ] [P6-T4] Run final governed-JSON formatting from the repo root using `poetry run python -m scripts.dev_tools.format_json` and capture `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/qa-gates/json-format.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run python -m scripts.dev_tools.format_json`, `EXIT_CODE: 0`, and `Output Summary:`.

- [ ] [P6-T5] Run final governed-JSON validation from the repo root using `poetry run python -m scripts.dev_tools.validate_json` and capture `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/qa-gates/json-validate.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: poetry run python -m scripts.dev_tools.validate_json`, `EXIT_CODE: 0`, and `Output Summary:`; if this step fails, restart Phase 6 from [P6-T4].

- [ ] [P6-T6] Record the mixed-language coverage disposition at `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/qa-gates/mixed-language-coverage-summary.2026-04-12T15-09.md`.
  - Acceptance: Artifact contains `Timestamp:`, `Command: derived-from-P0-T6-P5-T4-P0-T9-and-P6-T3`, `EXIT_CODE: 0`, and `Output Summary:`; cites TypeScript baseline and post-change coverage values; cites PowerShell baseline and post-change coverage values when available from the generated artifacts; states whether either language regressed; and states `remediation required` rather than `PASS` if the required coverage values cannot be determined from recorded evidence.

- [ ] [P6-T7] Record the final QA loop summary at `docs/features/active/2026-04-12-bundle-link-parent-child-into-extension-144/evidence/qa-gates/qa-loop-summary.2026-04-12T15-09.md`.
  - Acceptance: Summary artifact records the final clean-pass order `TypeScript format -> TypeScript lint -> TypeScript typecheck -> TypeScript test -> PowerShell format -> PowerShell analyze -> PowerShell test -> JSON format -> JSON validate`, any rerun counts triggered by file changes or failures, cites [P5-T5] and [P6-T6], and states whether the feature is ready for post-delivery review or requires remediation.

## Acceptance Criteria Traceability
- AC1 (interactive extension command prompts for child and parent issue numbers and runs the bundled workflow): P1-T3, P2-T1, P2-T3, P2-T4, P2-T5, P2-T6, P4-T3
- AC2 (repo automation service runs the bundled workflow while preserving the existing PowerShell contract): P1-T1, P1-T2, P1-T3, P1-T4, P4-T1, P4-T3
- AC3 (MCP exposes the same workflow with explicit child and parent inputs): P1-T3, P3-T1, P3-T2, P3-T3, P3-T4, P4-T2, P4-T3
- AC4 (tests cover command registration, prompting, direct invocation, service execution, MCP normalization/dispatch, and bundled-script expectations): P1-T2, P1-T4, P2-T2, P2-T5, P2-T6, P3-T2, P3-T4, P4-T1, P4-T2, P5-T4, P6-T3

## Preflight Checklist
- [x] Phase headings follow the required `### Phase N — Title` format.
- [x] Task ids are sequential and phase-aligned.
- [x] The plan updates the provided plan path in place and creates no sibling plan files.
- [x] Phase 0 includes explicit policy-read evidence, surface-inventory evidence, TypeScript baseline evidence, PowerShell baseline evidence, and governed-JSON baseline evidence.
- [x] The implementation scope is explicit for the mixed TypeScript and PowerShell surfaces and preserves the root script CLI parameters `-ChildIssueNumber` and `-ParentIssueNumber`.
- [x] The plan requires the extension command and MCP tool to route through the shared repo-automation service and bundled extension script path.
- [x] The plan includes targeted Pester and Jest regression evidence tasks before final QA.
- [x] Final QA includes per-command evidence tasks for TypeScript, PowerShell, and governed JSON plus explicit coverage-disposition summaries.
- [x] No placeholder tokens or bucket tasks remain.
