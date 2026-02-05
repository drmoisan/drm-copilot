# 2026-02-04-extension-tests-fail-in-container (Spec)

- **Issue:** #12
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-04T20:30:00Z
- **Status:** Complete
- **Version:** 0.1

## Context
Extension integration tests cannot run inside the dev container, so the integration suite fails consistently.
This blocks running the full test workflow in container environments.

Environment:
- OS/version: Linux (dev container)
- Python version: Unknown (not provided)
- Command/flags used: Extension integration test suite executed in the container
- Data source or fixture: Extension test harness (no external data sources reported)

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Open the repo in the dev container.
2. Run the extension integration tests from the container.
3. Observe that the integration suite fails due to container limitations.

Expected:
Integration tests complete successfully when run in the container, or are implemented in a way that works in both container and host environments.

Actual:
Integration tests fail consistently in the dev container because the container cannot run the required integration test environment.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: Not provided.


## Scope & Non-Goals
- In scope:
	- Replace the VS Code extension host integration test with Jest-based tests that can run in containers and on host.
	- Remove or repurpose the `vscode-test` harness (`tests/integration`, `tsconfig.vscode-test.json`, `.vscode-test.mjs`) so default test workflows no longer require a GUI.
	- Update npm scripts and documentation so `npm test` and `npm run test:integration` do not invoke the VS Code test runner.
- Out of scope / non-goals:
	- End-to-end UI validation in a live VS Code extension host.
	- Adding new extension features or modifying runtime behavior beyond test plumbing.
- Explicitly excluded systems, integrations, or datasets:
	- No external services, network calls, or VS Code marketplace dependencies.

## Root Cause Analysis
The current integration test harness relies on a runtime that is not available in the dev container. The suite should be rewritten to use the Jest provider so it can run in container or on host.


## Proposed Fix

### Design summary (what changes where):
Convert the existing integration test (`tests/integration/extension.test.ts`) into Jest-based tests that use mocked VS Code APIs (similar to existing unit tests). Remove the VS Code test CLI configuration and script hooks so container-safe Jest tests are the default. Update docs to reflect the new test entry points.

### Boundaries and invariants to preserve:
- Command registration logic and activation behavior must remain unchanged.
- Jest unit tests must not require the VS Code extension host or a GUI.
- No new runtime dependencies are introduced.

### Dependencies or blocked work:
- None expected. Keep using existing Jest tooling and mocks.

### Implementation strategy (what changes, not sequencing):
- Delete or relocate the integration test file to a Jest test location (e.g., `tests/unit/`), using mocked VS Code APIs.
- Remove `tsconfig.vscode-test.json` and `.vscode-test.mjs` if no longer needed, and adjust `package.json` scripts (`test`, `test:integration`, `pretest`, `compile:integration-tests`) to avoid `vscode-test`.
- Update README or developer docs to document the Jest-based test workflow and clarify that `npm test` runs Jest.
	
#### Files/modules to change:
- `tests/integration/extension.test.ts` (remove/replace with Jest test in `tests/unit/`)
- `package.json` (test script updates)
- `.vscode-test.mjs` (remove if unused)
- `tsconfig.vscode-test.json` (remove if unused)
- `README.md` or `docs/developer-tooling.md` (update test instructions)

#### Functions/classes/CLI commands impacted:
- `activate` / `deactivate` (only test coverage; no functional change)
- npm scripts: `test`, `test:integration`, `pretest`, `compile:integration-tests`

#### Data flow and validation changes:
- No production data flow changes. Test-only adjustments to how command registration is validated.

#### Error handling and logging updates:
- None expected.

#### Rollback/feature-flag considerations (if applicable):
- Rollback by restoring `vscode-test` scripts and integration test harness if needed.

### Technical specifications (interfaces/contracts):
- Jest tests must mock the `vscode` module and assert expected command registration via `vscode.commands.registerCommand` and `vscode.tasks.registerTaskProvider`.
- Jest tests must not import from the VS Code extension host runtime (`@vscode/test-electron`) or require GUI execution.

#### Inputs/outputs and formats:
- Inputs: mocked `vscode.ExtensionContext` with minimal required fields.
- Outputs: Jest assertions; no external files or artifacts.

#### Required configuration keys and defaults:
- None.

#### Backward-compatibility expectations:
- `npm test` should remain a valid entry point, but it will run Jest unit tests instead of the VS Code test runner.
- `npm run test:integration` should be removed or repointed to Jest to avoid container-only failures.

#### Performance constraints (latency/throughput/memory):
- Jest tests should stay fast (< a few seconds) and deterministic; no external processes.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
	- Dev containers can run Node/Jest but not VS Code GUI.
	- Existing Jest mocks are acceptable for extension API coverage.
- Constraints (budget, performance, compatibility):
	- No new runtime dependencies; only adjust tests and scripts.
	- Must comply with Jest-only unit test policy (no VS Code host).
- External dependencies (services, libraries, releases):
	- None.

## Data / API / Config Impact
- User-facing or API changes:
	- None.
- Data or migration considerations:
	- None.
- Logging/telemetry updates (if any):
	- None.
- Compatibility notes (CLI flags, config schemas, versioning):
	- `npm test` and `npm run test:integration` behaviors change to avoid `vscode-test`.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: Ensure Jest-based tests cover the same integration behaviors currently covered by container-incompatible tests.
- [ ] Integration scenario to retest: Run the Jest-based integration suite in the dev container and on host to confirm parity.
- [ ] Manual verification notes: Validate that the extension still behaves correctly in a local VS Code instance after test rewrite.

- Regression tests to add or update:
	- Jest test that mirrors the previous integration assertions: extension activation and command registration with mocked VS Code APIs.
- Unit tests (pytest) for the fixed behavior and boundaries:
	- Not applicable (TypeScript scope).
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
	- Validate behavior when extension activation is called with minimal context.
- Error handling and logging verification:
	- Ensure no additional logging or errors are introduced.
- Coverage impact and targets for changed lines/modules:
	- Maintain or improve coverage for `src/extension.ts` and command registration paths.
- Toolchain commands to run (format → lint → type-check → test):
	- `npm run format`
	- `npm run lint`
	- `npm run typecheck`
	- `npm run test:unit`
- Manual validation steps (if required):
	- Optional: run `npm test` on host to confirm no VS Code test runner is invoked.


## Acceptance Criteria
- [x] Repro steps now produce the expected behavior in all documented environments.
- [x] Regression test(s) added and passing: `tests/unit/vscode-test-removal.test.ts` (`scripts avoid vscode-test electron harness`, `vscode-test mjs removed`, `vscode-test tsconfig removed`).
- [x] Edge cases and invalid inputs are handled with correct errors or fallbacks.
- [x] No unintended behavior changes outside the defined scope.
- [x] Required logs/telemetry updated and validated (if applicable): not applicable.
- [x] Performance constraints met or explicitly waived with rationale.
- [x] Full toolchain pass completed (format → lint → type-check → test).
- [x] Docs/config references updated to match the new behavior.

## Risks & Mitigations
- Technical or operational risks:
- Mitigations and rollbacks:

## Rollout & Follow-up
- Release/rollout steps:
- Post-fix monitoring or clean-up tasks:
- Links: issue, PRs, related docs
