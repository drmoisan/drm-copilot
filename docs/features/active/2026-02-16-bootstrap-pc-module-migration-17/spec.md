# 2026-02-16-bootstrap-pc-module-migration — Spec

- **Issue:** #17
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-16T16-15
- **Status:** Draft
- **Version:** 0.1

## Overview

Bootstrap host setup/verification logic is split across standalone scripts in `scripts/dev-tools/` plus a separate manifest file, which creates duplication in invocation patterns, weak discoverability, and higher maintenance cost when evolving host tooling.

Current tests and task wiring are tied to script file locations instead of a reusable module contract, making refactors noisy and increasing the chance of stale references. Consolidating this into a PowerShell module under `scripts/powershell/BootstrapPC` provides a single canonical implementation surface for bootstrapping and verification behavior.


## Behavior

Create a new PowerShell module at `scripts/powershell/BootstrapPC` that owns all behavior currently implemented by:

- `scripts/dev-tools/bootstrap-host.ps1`
- `scripts/dev-tools/bootstrap-host.helpers.ps1`
- `scripts/dev-tools/verify-host.ps1`
- `scripts/host-tools.manifest.json`

Re-home the implementation into module functions and module-local assets so the module is the only supported runtime location. Update all repository references to call the module entry points or module-hosting scripts in the new path.

Redirect all task/test/invocation points to the new location, including `.vscode/tasks.json`, and remove old-path references without compatibility shims.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
	- Existing bootstrap/verify invocation arguments currently accepted by the dev-tools scripts are preserved at the behavior level.
	- Module-local configuration/data relocated from `scripts/host-tools.manifest.json` into `scripts/powershell/BootstrapPC`.
	- Repository task invocations from `.vscode/tasks.json` that previously targeted `scripts/dev-tools/bootstrap-host.ps1` and `scripts/dev-tools/verify-host.ps1`.
- Outputs (artifacts, logs, telemetry)
	- Same host bootstrap and verification outcomes currently produced by existing scripts.
	- Existing console/log behavior remains functionally equivalent unless path text changes due to relocation.
	- No new telemetry surface introduced by this migration.
- Config keys and defaults:
	- No net-new configuration keys required for migration.
	- Existing manifest-backed configuration semantics are retained after relocation to module-local assets.
- Versioning or backward-compatibility constraints:
	- No shim compatibility layer is provided at legacy script paths.
	- Old path references are intentionally removed; all supported invocations must reference the new module location.

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Example invocations with expected outputs (concise):
	- Bootstrap host command resolves to the new `scripts/powershell/BootstrapPC` location and performs the same setup responsibilities as before.
	- Verify host command resolves to the new `scripts/powershell/BootstrapPC` location and performs the same verification responsibilities as before.
	- Task-based invocation through `.vscode/tasks.json` continues to provide bootstrap/verify developer entry points, now mapped to new paths.
- Contracts and validation rules:
	- Behavior contract remains equivalent to pre-migration scripts for successful bootstrap and verification flows.
	- Parameter validation and failure conditions remain consistent with prior behavior unless required by module boundary extraction.
	- Invocation contract changes only in canonical path ownership: new module path is authoritative; legacy script paths are unsupported.

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
	- Manifest/config data used by bootstrap/verify is moved from `scripts/host-tools.manifest.json` into module-owned assets under `scripts/powershell/BootstrapPC`.
	- Functional invariants for tool detection, host setup, and verification checks remain unchanged.
- Caching or persistence details:
	- No new persistence or cache mechanism is introduced by this relocation.
- Migration or backfill requirements (if any):
	- Repository references (tasks/docs/tests/scripts) must be updated from legacy paths to the new module paths in the same change set.
	- Test assets are relocated from `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` to `tests/scripts/powershell/BootstrapPC` with equivalent coverage intent.

## Constraints & Risks

- Scope must stay focused on relocation/refactoring of existing behavior; no net-new bootstrap features are added in this change.
- Direct path migration (no shims) increases blast radius if any hidden references are missed; comprehensive search/update is mandatory.
- CI/task contracts must remain stable from a user perspective even though implementation paths change.
- Module export boundaries must be explicit to avoid leaking helper internals or breaking testability.
- Documentation and developer workflows must be updated in the same change set to prevent onboarding drift.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Relocate bootstrap/verify implementation and supporting helper logic into `scripts/powershell/BootstrapPC`.
	- Relocate manifest/config asset ownership from root-level host-tools manifest file into the module folder.
	- Redirect all active invocations (tasks, docs, tests, script callers) to the new module location.
	- Remove old-path usage without introducing compatibility wrappers.
- New classes/functions/commands to add or update:
	- Introduce or update module entry points for bootstrap and host verification in `scripts/powershell/BootstrapPC`.
	- Update task commands in `.vscode/tasks.json` to invoke new module-backed entry points.
	- Update test targets under `tests/scripts/powershell/BootstrapPC` to validate relocated behavior.
- Dependency changes (new/removed packages) and rationale:
	- No new runtime dependency expected; migration focuses on relocation and reference updates.
- Logging/telemetry additions and locations:
	- No required telemetry additions; preserve existing logging intent.
- Rollout plan (feature flags, staged deploys, fallback path):
	- Single-cut migration in one change set.
	- No fallback path via shims; success criteria requires complete reference redirection.

## Definition of Done

- [x] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas: migrated helper/function behavior in `BootstrapPC` module, including manifest/tool resolution logic and error paths.
- [ ] Integration scenarios: bootstrap-host and verify-host task invocations through updated `.vscode/tasks.json` and script entry points.
- [ ] CLI/API examples: direct module-based invocation for bootstrap and verify operations from repository root PowerShell sessions.
- [ ] Regression checks: ensure old-path script references fail lint/search gates (or are absent) and new-path references are the only active route.
- [ ] Toolchain checks: run PowerShell formatter/analyzer/Pester in required order and rerun until clean; run any impacted Python/TS checks if task wiring touches shared orchestration.
