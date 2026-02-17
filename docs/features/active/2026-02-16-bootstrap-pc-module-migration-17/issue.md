# bootstrap-pc-module-migration (Issue #17)

- Date captured: 2026-02-16
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/bootstrap-pc-module-migration/ (Issue #17)
- Issue: #17
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/17
- Last Updated: 2026-02-16

## Problem / Why

Bootstrap host setup/verification logic is split across standalone scripts in `scripts/dev-tools/` plus a separate manifest file, which creates duplication in invocation patterns, weak discoverability, and higher maintenance cost when evolving host tooling.

Current tests and task wiring are tied to script file locations instead of a reusable module contract, making refactors noisy and increasing the chance of stale references. Consolidating this into a PowerShell module under `scripts/powershell/BootstrapPC` provides a single canonical implementation surface for bootstrapping and verification behavior.

## Proposed Behavior

Create a new PowerShell module at `scripts/powershell/BootstrapPC` that owns all behavior currently implemented by:

- `scripts/dev-tools/bootstrap-host.ps1`
- `scripts/dev-tools/bootstrap-host.helpers.ps1`
- `scripts/dev-tools/verify-host.ps1`
- `scripts/host-tools.manifest.json`

Re-home the implementation into module functions and module-local assets so the module is the only supported runtime location. Update all repository references to call the module entry points or module-hosting scripts in the new path.

Redirect all task/test/invocation points to the new location, including `.vscode/tasks.json`, and remove old-path references without compatibility shims.

## Acceptance Criteria (early draft)

- [ ] A new module folder `scripts/powershell/BootstrapPC` exists with complete bootstrap and host verification functionality migrated from the three `scripts/dev-tools/*host*.ps1` files.
- [ ] Data/config previously sourced from `scripts/host-tools.manifest.json` is relocated into the new module location and consumed there.
- [ ] No shim wrappers are introduced in `scripts/dev-tools/`; all callers are redirected to the new module location directly.
- [ ] All repo references to old bootstrap/verify paths are updated (tasks, docs, scripts, and tests) so no active references remain to the migrated files.
- [ ] Tests are moved from `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` to `tests/scripts/powershell/BootstrapPC` and continue validating bootstrap + verify behaviors.
- [ ] `.vscode/tasks.json` entries that invoked old bootstrap/verify scripts now invoke commands at the new module location.
- [ ] PowerShell quality toolchain passes after migration (format/analyze/test loop), and broader repo checks affected by path changes remain green.

## Constraints & Risks

- Scope must stay focused on relocation/refactoring of existing behavior; no net-new bootstrap features are added in this change.
- Direct path migration (no shims) increases blast radius if any hidden references are missed; comprehensive search/update is mandatory.
- CI/task contracts must remain stable from a user perspective even though implementation paths change.
- Module export boundaries must be explicit to avoid leaking helper internals or breaking testability.
- Documentation and developer workflows must be updated in the same change set to prevent onboarding drift.

## Test Conditions to Consider

- [ ] Unit coverage areas: migrated helper/function behavior in `BootstrapPC` module, including manifest/tool resolution logic and error paths.
- [ ] Integration scenarios: bootstrap-host and verify-host task invocations through updated `.vscode/tasks.json` and script entry points.
- [ ] CLI/API examples: direct module-based invocation for bootstrap and verify operations from repository root PowerShell sessions.
- [ ] Regression checks: ensure old-path script references fail lint/search gates (or are absent) and new-path references are the only active route.
- [ ] Toolchain checks: run PowerShell formatter/analyzer/Pester in required order and rerun until clean; run any impacted Python/TS checks if task wiring touches shared orchestration.

## Next Step

- [ ] Promote to GitHub issue (feature request template), with explicit note that migration is no-shim and reference-complete.
- [ ] Create `docs/features/active/bootstrap-pc-module-migration/` folder from the template.
- [ ] In active feature kickoff, enumerate all expected reference update targets (`.vscode/tasks.json`, tests path, docs, and script callers) before implementation begins.
