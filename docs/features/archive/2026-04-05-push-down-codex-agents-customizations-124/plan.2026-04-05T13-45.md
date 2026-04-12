# push-down-codex-agents-customizations - Plan

- **Issue:** #124
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-04-05T13-45
- **Status:** Draft
- **Version:** 0.1

## Required References

- General Coding Standards: [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
- General Unit Test Policy: [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
- Python Code Change Policy: [`.github/instructions/python-code-change.instructions.md`](../../../../.github/instructions/python-code-change.instructions.md)
- Python Unit Test Policy: [`.github/instructions/python-unit-test.instructions.md`](../../../../.github/instructions/python-unit-test.instructions.md)
- Python Suppressions Policy: [`.github/instructions/python-suppressions.instructions.md`](../../../../.github/instructions/python-suppressions.instructions.md)
- TypeScript Code Change Policy: [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
- TypeScript Unit Test Policy: [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)
- TypeScript Suppressions Policy: [`.github/instructions/typescript-suppressions.instructions.md`](../../../../.github/instructions/typescript-suppressions.instructions.md)

**All work must comply with these policies; do not duplicate their content here.**

## Implementation Plan (Atomic Tasks)

PREFLIGHT: ALL CLEAR

### Phase 0: Compliance & Context
- [x] [P0-T1] Read `.github/copilot-instructions.md`, `.github/instructions/general-code-change.instructions.md`, `.github/instructions/general-unit-test.instructions.md`, `.github/instructions/python-code-change.instructions.md`, `.github/instructions/python-unit-test.instructions.md`, `.github/instructions/python-suppressions.instructions.md`, `.github/instructions/typescript-code-change.instructions.md`, `.github/instructions/typescript-unit-test.instructions.md`, and `.github/instructions/typescript-suppressions.instructions.md`
  - Acceptance: implementation notes and final report cite the exact policy files read in repo policy order.
- [x] [P0-T2] Capture implementation research and design constraints in `research.md`
  - Acceptance: `research.md` documents the existing publisher seams, the chosen sibling-publisher design, and the non-regression constraint for the `.github` workflow.

### Phase 1: Python Publisher Surface
- [x] [P1-T1] Generalize `scripts/dev_tools/push_down_copilot_customizations.py` so root folders, artifact directory, and rewrite behavior are configurable without changing the current `.github` command contract
  - Acceptance: existing `.github` publisher call sites still work without passing new options.
- [x] [P1-T2] Add `scripts/dev_tools/push_down_codex_and_agents_customizations.py` as a dedicated `.codex` / `.agents` publisher entry point
  - Acceptance: the new module exposes `parse_args`, `main`, and `push_down_customizations`, requires `--destination`, and writes artifacts under `artifacts/codex-and-agents-customizations`.
- [x] [P1-T3] Add targeted Python tests covering the new publisher scope, artifact path, passthrough rewrite behavior, and CLI success path
  - Acceptance: targeted pytest coverage proves `.codex` and `.agents` files preserve relative paths, no rewrite counts are added for untouched content, and the summary artifact path uses the new artifact directory.

### Phase 2: Bundled Resources And Extension Surface
- [x] [P2-T1] Add bundled Python copies and a thin bundled wrapper for `push_down_codex_and_agents_customizations`
  - Acceptance: the wrapper imports the bundled module from `resources/scripts`, resolves `resources/codex-and-agents-customizations` as the source root, uses `Path.cwd()` as the artifact root, and forwards `--destination`.
- [x] [P2-T2] Mirror the repo-root `.codex` and `.agents` payload into `extensions/drm-copilot/resources/codex-and-agents-customizations/`
  - Acceptance: bundled payload paths exist for `.codex/config.toml`, `.codex/agents/orchestrator.toml`, `.agents/README.md`, and representative nested skill files.
- [x] [P2-T3] Add `drmCopilotExtension.pushDownCodexAndAgentsCustomizations` and `push_down_codex_and_agents_customizations` across `package.json`, `extension.ts`, `repo-automation-service.ts`, `mcp-tools.ts`, and `mcp-tool-inputs.ts`
  - Acceptance: the new command and MCP tool are wired through the shared repo-automation service and target the bundled wrapper path `resources/templates/push_down_codex_and_agents_customizations.py`.
- [x] [P2-T4] Add TypeScript tests for command registration, bundled execution, destination forwarding, and MCP exposure for the new publisher
  - Acceptance: Jest coverage proves the command is registered, uses the Python runtime, forwards `--destination <workspaceRoot>`, and the MCP tool dispatches through the new repo-automation service method.

### Phase 3: Contract And Documentation Updates
- [x] [P3-T1] Add a contract test that keeps the bundled `.codex` and `.agents` payload aligned with the repo-root sources
  - Acceptance: a deterministic test fails when bundled payload files drift from the current repo-root `.codex` and `.agents` trees.
- [x] [P3-T2] Update `README.md`, `extensions/drm-copilot/README.md`, `spec.md`, and `user-story.md` to document the new command and semantic tool surface
  - Acceptance: docs name the exact command ID, title, tool name, and `.codex` / `.agents` payload scope.

### Phase 4: Validation And Review
- [x] [P4-T1] Run the Python toolchain loop for the touched Python surface until one full pass is green
  - Acceptance: the final pass includes format, lint, type-check, and targeted Python tests with no remaining failures.
- [x] [P4-T2] Run the TypeScript toolchain loop for the touched extension surface until one full pass is green
  - Acceptance: the final pass includes format, lint, type-check, and targeted Jest tests with no remaining failures.
- [x] [P4-T3] Check off delivered acceptance criteria in `spec.md` and `user-story.md` only after verification succeeds
  - Acceptance: only delivered criteria change from `- [ ]` to `- [x]`.
- [x] [P4-T4] Produce policy, code, and feature review artifacts for the completed branch
  - Acceptance: the feature folder contains final review artifacts and the orchestration checkpoint records completion.

## Test Plan

- Unit:
  - targeted pytest for the new Python publisher and bundled-payload contract checks
  - targeted Jest for command registration and MCP dispatch
- Integration:
  - extension integration test that runs the new bundled wrapper in the workspace execution model
- Manual/CLI:
  - `python -m scripts.dev_tools.push_down_codex_and_agents_customizations --destination <workspace-root>`
  - MCP tool invocation through `push_down_codex_and_agents_customizations`

## Open Questions / Notes

- The chosen design is additive: it introduces a sibling `.codex` / `.agents` publisher instead of broadening the `.github` publisher's semantic scope.
