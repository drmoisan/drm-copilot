# `2026-02-16-bootstrap-pc-module-migration` — User Story

- Issue: #17
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-02-16T16-15

## Story Statement

- As a repository maintainer, I want bootstrap/verify host logic relocated into `scripts/powershell/BootstrapPC`, so that there is one canonical PowerShell module surface for host setup and verification behavior.
- As a contributor running local quality checks, I want tests relocated to `tests/scripts/powershell/BootstrapPC` and task/script references redirected to the new module path, so that refactors do not leave stale path references and quality workflows remain predictable.

## Problem / Why

Bootstrap host setup/verification logic is split across standalone scripts in `scripts/dev-tools/` plus a separate manifest file, which creates duplication in invocation patterns, weak discoverability, and higher maintenance cost when evolving host tooling.

Current tests and task wiring are tied to script file locations instead of a reusable module contract, making refactors noisy and increasing the chance of stale references. Consolidating this into a PowerShell module under `scripts/powershell/BootstrapPC` provides a single canonical implementation surface for bootstrapping and verification behavior.


## Personas & Scenarios

- Persona: Repository maintainer (PowerShell/tooling owner)
  - Maintains `scripts/dev-tools`, `scripts/powershell`, and task wiring for local developer workflows.
  - Cares about a single source of truth for bootstrap and verification behavior.
  - Must avoid compatibility shims and keep references fully redirected to prevent drift.
  - Wants future updates to land in one module boundary without duplicate script maintenance.
- Persona: Contributor onboarding on a new machine
  - Runs bootstrap and verification commands through documented scripts/tasks.
  - Cares that commands continue to work after migration without memorizing legacy paths.
  - Needs tests and docs to reflect current paths so troubleshooting is straightforward.
- Scenario: Maintainer performs no-shim migration
  - Trigger: issue #17 requires consolidating host bootstrap/verify into a dedicated module.
  - Action: move host bootstrap/verify logic and manifest data into `scripts/powershell/BootstrapPC`.
  - Action: relocate tests from `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` to `tests/scripts/powershell/BootstrapPC`.
  - Action: update task and script references (including `.vscode/tasks.json`) to target the new module location directly.
  - Decision: intentionally avoid any `scripts/dev-tools` shim wrappers so old paths are not a supported runtime route.
  - Expected outcome: bootstrap/verify behavior is unchanged for users, and all active references point to the module location only.


## Acceptance Criteria

- [ ] A new module folder `scripts/powershell/BootstrapPC` exists with complete bootstrap and host verification functionality migrated from the three `scripts/dev-tools/*host*.ps1` files.
- [ ] Data/config previously sourced from `scripts/host-tools.manifest.json` is relocated into the new module location and consumed there.
- [ ] No shim wrappers are introduced in `scripts/dev-tools/`; all callers are redirected to the new module location directly.
- [ ] All repo references to old bootstrap/verify paths are updated (tasks, docs, scripts, and tests) so no active references remain to the migrated files.
- [ ] Tests are moved from `tests/scripts/dev-tools/bootstrap-host.Tests.ps1` to `tests/scripts/powershell/BootstrapPC` and continue validating bootstrap + verify behaviors.
- [ ] `.vscode/tasks.json` entries that invoked old bootstrap/verify scripts now invoke commands at the new module location.
- [ ] PowerShell quality toolchain passes after migration (format/analyze/test loop), and broader repo checks affected by path changes remain green.


## Non-Goals

- Adding new bootstrap-host capabilities, flags, or behavior beyond relocation/refactoring of existing functionality.
- Keeping old `scripts/dev-tools/*host*.ps1` entry points as compatibility wrappers or fallback shims.
- Reworking unrelated developer tooling outside bootstrap/verify path migration and directly impacted references.
- Introducing dependency changes that are not required to complete the module/test/tasks relocation.
