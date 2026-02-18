# 2026-02-17-bootstrap-pc-host - Initiative Overview

- Issue: #21
- Owner: drmoisan
- Last Updated: 2026-02-17T15-38

## Goal & Outcomes

Deliver a reliable Windows host bootstrap capability that can recreate a known-good workstation setup on a new machine using a PowerShell-first workflow. The initiative outcome is reduced manual setup effort, fewer onboarding failures, and repeatable host state across re-runs and reboots.

Measurable outcomes:
- New host reaches a "ready for repository workflows" state using documented bootstrap commands with minimal manual steps.
- Bootstrap execution is deterministic and restart-safe (resume after reboot without redoing completed work).
- Dependency and package setup is data-driven from centralized manifests (groups/sub-groups/packages) rather than ad hoc script edits.
- Security requirements are upheld: elevation is explicit, credentials are never persisted in plaintext, and post-reboot credential behavior is controlled.

## Decomposition (Child Features/Workstreams)

- Workstream A — MVP host verification + install parity with devcontainer baseline (Issue #25) - `./2026-02-17-devcontainer-to-host-25/`
	- Scope: deliver `verify` and `install` command behavior, OS-aware prerequisite checks, idempotent install paths, and report output (text/json).
- Workstream B — Centralize bootstrap into independent PowerShell module (Issue #17) - `../2026-02-16-bootstrap-pc-module-migration-17/` (target folder expected from issue promotion)
	- Scope: migrate bootstrap/verify behavior and manifest ownership into `scripts/powershell/BootstrapPC` as the canonical runtime surface.
- Workstream C — Manifest-driven grouped bootstrap orchestration (Issue: TBD child) - `../<tbd-group-orchestration-child>/`
	- Scope: implement group/sub-group model with default-all execution, explicit include/exclude selection, standardized provider contract, and fallback install methods.
- Workstream D — Resume/reboot state + secure elevation credential flow (Issue: TBD child) - `../<tbd-resume-security-child>/`
	- Scope: checkpoint/resume state machine, reboot boundary handling, in-memory elevation reuse during run, and post-reboot re-prompt/encrypted-only credential persistence policy.
- Workstream E — Repo cloning and self-hosted system restore flows (Issue: TBD child) - `../<tbd-repos-and-selfhosted-child>/`
	- Scope: clone/configure named repos, install per-repo dependencies, and restore/bring online selected self-hosted systems with validation.

Dependencies: A establishes baseline behavior and output contracts; B hardens architecture and canonical module surface; C depends on A/B command contracts; D depends on C orchestration checkpoints; E depends on C/D for grouped execution, state resume, and secure privilege handling. Recommended order: A → B → C → D → E (with limited parallel discovery/spec work).

## Cross-Cutting Constraints & Assumptions

- Shared behaviors/contracts that must stay aligned:
	- Common status vocabulary across all commands (`present`, `missing`, `installed`, `failed`, `skipped`).
	- Idempotent execution semantics: already-satisfied entries are skipped, not reinstalled.
	- Consistent include/exclude group resolution rules (default install scope is all groups).
- Determinism/performance/compatibility guarantees:
	- Deterministic group and entry ordering from manifest.
	- Windows-first support is required; unsupported platforms must fail explicitly with guidance.
	- Re-runs and resume operations must converge to stable terminal states.
- Data/artifact/tooling assumptions:
	- Manifest-driven configuration is the source of truth for groups and package entries.
	- State checkpoints and logs are machine-readable and human-readable.
	- Bootstrap command surface remains scriptable for local tasks and CI-adjacent validation workflows.
- Compliance/security boundaries:
	- No plaintext credential persistence.
	- Elevation requests must be explicit and user-confirmed.
	- External downloads/installers must use trusted sources and provide fallback/remediation paths.
- Quality gates required across workstreams:
	- PowerShell format/analyze/test loop must pass for PowerShell changes.
	- Any affected Python/TypeScript tooling/tests must remain green when wiring or orchestration is touched.
	- Feature docs (`issue.md`, `user-story.md`, `spec.md`, `initiative.md`) stay synchronized with delivered behavior.

## Milestones & Status

- M1 MVP dependency verify/install delivered - In progress (Issue #25 has issue/user-story/spec drafted; implementation and validation pending)
- M2 Canonical BootstrapPC module migration completed - Not started (Issue #17 tracks path/module centralization and caller rewiring)
- M3 Manifest-group orchestration + fallback provider model delivered - Not started (default-all + opt-in/opt-out + extensibility without code edits)
- M4 Reboot-resume + secure elevation credential policy implemented - Not started (checkpoint/restart flow and credential guarantees validated)
- M5 Repo and self-hosted restore flows integrated - Not started (end-to-end host rebuild including repo dependency and service bring-up)
- CLI/UX alignment milestone - Not started (uniform command naming, flags, status output schema, and remediation messaging across all workstreams)

## Initiative-Level Validation

- End-to-end:
	- Validate a fresh Windows host bootstrap run from zero prerequisites to "repo workflows runnable" state using the documented command path.
	- Validate a full grouped bootstrap run including foundational tools, optional packages, repo dependency setup, and selected self-hosted restore actions.
- Integration:
	- Confirm Issue #25 command contracts remain compatible after Issue #17 module migration.
	- Confirm manifest schema drives execution consistently across group selection, fallback methods, and status reporting.
	- Confirm reboot checkpoints restore execution at correct next step without duplicating completed entries.
- Determinism/Regression:
	- Re-run bootstrap on already-configured host and verify idempotent outcomes.
	- Guard against drift by comparing required dependency/tool manifests to current devcontainer/repo expectations during verification.
	- Keep output schema stable for automation consumers.
- Error handling/Resilience:
	- Simulate installer/network failures and verify fallback/remediation behavior.
	- Validate unsupported platform and no-admin scenarios produce explicit, actionable errors.
	- Validate credential lifecycle boundaries: no plaintext persistence and safe post-reboot handling.

## Notes / Follow-Ups

- Decision: Issue #21 serves as tracking issue and initiative umbrella; child features carry delivery details and tests.
- Decision: Issue #25 is the MVP baseline and should set initial CLI/reporting contracts that downstream workstreams preserve.
- Decision: Issue #17 is the architectural consolidation step to avoid long-term script sprawl and stale references.
- Follow-up: Promote remaining scope areas (group orchestration, resume/security, repo/self-hosted restore) into dedicated child issues and folders with linked specs.
- Follow-up: Publish a traceability map from initiative outcomes to child acceptance criteria and validation evidence once implementation begins.
