# bootstrap-pc-host (Issue #21)

- Date captured: 2026-02-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/bootstrap-pc-host/ (Issue #21)

- Issue: #21
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/21
- Last Updated: 2026-02-17
## Problem / Why

I have a repeatable host setup for my primary PC, but reproducing it on a new machine is currently manual, error-prone, and time-consuming. I need an automated and resilient PowerShell-based bootstrap flow that can restore my working environment with minimal manual intervention. The process must support selective install scopes, restart-safe execution, and secure handling of elevation/credentials.

## Proposed Behavior

Create a PowerShell module that bootstraps a Windows host from a central package manifest organized into install groups and sub-groups. By default, all groups run, but callers can opt in/out of specific groups and sub-groups at execution time.

Core flow:
- Load a configurable manifest that defines groups, entries, install method metadata, optional fallback install method, and post-install validation checks.
- Execute groups in deterministic order with per-entry status tracking.
- Support at least these initial groups:
	1. Foundational tools and systems
	2. Optional user-preferred packages
	3. Repo clone + dependency install per repo
	4. Restore and bring self-hosted systems online
- Standardize installer execution through shared installers/providers so new manifest entries generally require data changes only (no code changes).
- Persist execution state to allow resume after reboot at group/sub-group/package granularity.
- Support elevation prompting and in-memory admin credential reuse during a single execution session.
- After reboot, do not persist plaintext credentials; either prompt again or use encrypted-at-rest credential handling if implemented.

## Acceptance Criteria (early draft)

- [ ] Running the module with default parameters installs all defined groups in manifest order and records success/failure per entry.
- [ ] A caller can include/exclude specific groups and sub-groups via module parameters, and excluded scopes are skipped with explicit log/state entries.
- [ ] Manifest updates can add a new group or package entry without requiring module source-code changes when using existing standardized install providers.
- [ ] Each package entry can declare a primary and fallback installation method; fallback executes only when the primary fails and this decision is logged.
- [ ] If a reboot is required mid-run, the module resumes from persisted state and does not repeat already-completed entries unless explicitly requested.
- [ ] Elevation can be requested when needed; admin credentials are retained in memory only for the active run and are not written to disk in plaintext.
- [ ] After reboot/resume, credentials are re-requested unless an encrypted credential persistence mechanism is explicitly enabled and successfully decrypted.

## Constraints & Risks

- Platform: primary target is Windows host bootstrap via PowerShell module.
- Security: credential handling must avoid plaintext persistence and minimize elevated-context exposure.
- Reliability: installs may fail because of network outages, package source drift, installer UI prompts, or changed external endpoints.
- Idempotency: reruns should converge safely without duplicate destructive actions.
- Maintainability: manifest schema must remain simple enough for data-driven extensibility while still supporting installer-specific edge cases.
- Reboot orchestration risk: restart boundaries can break transient state unless checkpointing and resume hooks are deterministic.

## Test Conditions to Consider

- [ ] Unit coverage areas
	- [ ] Manifest schema validation (groups, sub-groups, package entries, install/fallback methods)
	- [ ] Group/sub-group inclusion-exclusion selection logic (defaults + overrides)
	- [ ] Provider selection and fallback decision behavior
	- [ ] State checkpoint serialize/deserialize and resume cursor logic
	- [ ] Credential handling boundaries (in-memory lifetime and no plaintext write path)
- [ ] Integration scenarios
	- [ ] Fresh machine bootstrap with all groups enabled (happy path)
	- [ ] Partial run interrupted by reboot, then successful resume from checkpoint
	- [ ] Primary installer failure triggering fallback success/failure paths
	- [ ] Repo clone + dependency install with already-cloned repo idempotency behavior
	- [ ] Self-hosted system restore and online verification flow
- [ ] CLI/API examples
	- [ ] Run all groups: module entry command with default behavior
	- [ ] Exclude user-preferred packages group while running all others
	- [ ] Include only repo bootstrap group/sub-group for targeted setup
	- [ ] Resume from persisted state after reboot

## Next Step

- [ ] Promote to GitHub issue (feature request template) with initial manifest schema + security requirements.
- [ ] Create `docs/features/active/bootstrap-pc-host/` folder from the template.
