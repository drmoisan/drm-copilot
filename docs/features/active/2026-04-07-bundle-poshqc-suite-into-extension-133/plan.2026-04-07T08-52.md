# 2026-04-07-bundle-poshqc-suite-into-extension-133 - Plan

- **Issue:** #133
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-07T09-16
- **Status:** Complete
- **Version:** 0.2

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- PowerShell Code Change Policy: [`.github/instructions/powershell-code-change.instructions.md`](../../../../.github/instructions/powershell-code-change.instructions.md)
- PowerShell Unit Test Policy: [`.github/instructions/powershell-unit-test.instructions.md`](../../../../.github/instructions/powershell-unit-test.instructions.md)
- TypeScript Code Change Policy: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test Policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)

## Implementation Plan (Atomic Tasks)

### Phase 0: Baseline Capture and Requirements Lock
- [x] [P0-T1] Record the current branch, checkpoint, and feature-folder inventory, then write baseline evidence under `docs/features/active/2026-04-07-bundle-poshqc-suite-into-extension-133/evidence/baseline/`
- [x] [P0-T2] Complete the active feature requirements by replacing the template content in `issue.md`, `spec.md`, and `user-story.md` with the PoshQC bundling scope, destination-workspace scan-folder behavior, and explicit acceptance criteria
- [x] [P0-T3] Capture baseline TypeScript command outputs for the extension package and store one evidence artifact per command under `evidence/baseline/`
- [x] [P0-T4] Capture baseline PowerShell suite outputs for the shared PoshQC module and store one evidence artifact per command under `evidence/baseline/`

### Phase 1: Implementation
- [x] [P1-T1] Add a shared `run-poshqc-suite.ps1` wrapper that works from both `scripts/dev-tools/` and `extensions/drm-copilot/resources/templates/` while importing the colocated bundled PoshQC module
- [x] [P1-T2] Copy the PoshQC module and settings into extension resources so the packaged workflow runs without repo-local `scripts/powershell/PoshQC` dependencies
- [x] [P1-T3] Extend the shared PowerShell module so format, analyze, and test entry points accept destination-workspace scan-folder selection and validate that selected folders stay within the workspace
- [x] [P1-T4] Wire a new extension command, MCP tool, and workflow-argument parsing path for running the bundled PoshQC suite with optional folder selection
- [x] [P1-T5] Update extension and PowerShell documentation so the bundled suite and scan-folder behavior are discoverable and consistent with existing bundled workflows
- [x] [P1-T6] Add or update Jest and Pester coverage for the new wrapper, command wiring, MCP surface, and folder-selection behavior

### Phase 2: Final QA and Evidence
- [x] [P2-T1] Run the extension formatting pass and store the final formatting evidence under `evidence/qa-gates/`
- [x] [P2-T2] Run the extension lint pass and store the final lint evidence under `evidence/qa-gates/`
- [x] [P2-T3] Run the extension type-check pass and store the final type-check evidence under `evidence/qa-gates/`
- [x] [P2-T4] Run the extension Jest suite and store the final test/coverage evidence under `evidence/qa-gates/`
- [x] [P2-T5] Run the PowerShell PoshQC wrapper against the destination workspace with explicit scan folders, then store the final PowerShell format/analyze/test evidence under `evidence/qa-gates/`

### Phase 3: Review and Acceptance Closeout
- [x] [P3-T1] Refresh or collect PR-context artifacts for the current branch if they are missing or stale
- [x] [P3-T2] Check off the delivered acceptance criteria in `spec.md` and `user-story.md` only after verification is complete
- [x] [P3-T3] Produce the feature review artifacts in the active feature folder and confirm the branch is ready for review

## Test Plan

- Unit: Jest coverage for the extension command, helper, service, and MCP input/output paths.
- Unit: Pester coverage for the shared PoshQC module, including folder-selection validation and wrapper behavior.
- Integration: Execute the bundled PoshQC suite from the extension resources against a destination workspace root with explicit scan folders.
- Manual/CLI: Run the repo-root wrapper against the checkout with the new scan-folder parameters to confirm the packaged and local entry points stay aligned.

## Open Questions / Notes

- The extension should preserve existing command IDs and MCP semantics for the current workflows; the new PoshQC command/tool is additive.
- The bundled wrapper should remain identical between repo-root and extension resources so the packaged behavior and local CLI parity stay aligned.
- Final QA must capture evidence for both the TypeScript extension package and the PowerShell module because the feature spans both languages.
