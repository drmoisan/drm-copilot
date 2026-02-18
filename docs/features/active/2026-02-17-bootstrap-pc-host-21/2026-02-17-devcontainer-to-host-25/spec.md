# 2026-02-17-devcontainer-to-host — Spec

- **Issue:** #25
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-17T16-38
- **Status:** Draft
- **Version:** 0.1

## Overview

The repository currently defines a working dependency baseline inside the devcontainer, but developers setting up a fresh host machine must manually infer and install those dependencies. This leads to inconsistent local environments, onboarding delays, and failures that are hard to diagnose. We need a host-side bootstrap workflow that can both verify required dependencies and install missing ones in a repeatable way.

This feature delivers two host bootstrap commands: one to verify dependency readiness and one to install missing dependencies where automation is supported. The behavior is grounded in the dependency/tooling signals present in `.devcontainer/local/Dockerfile` and `.devcontainer/local/devcontainer.json`, plus repository quality-policy expectations (Python, PowerShell, and CI tooling).


## Behavior

Deliver host bootstrap tooling that maps devcontainer dependencies to host prerequisites and automates setup.

Required outputs:
- A verification script that checks whether required host dependencies are present and usable.
- An installation script that installs any missing dependencies identified by the verifier.

Required verification scope:
- Core CLI/runtime prerequisites used by this repo workflows (for example: `git`, `python`, `poetry`, `pwsh`, `node`, `npm`, and required PowerShell modules/tooling).
- Repository-specific tooling expected by local quality workflows (for example: action linting/toolchain commands, shell quality dependencies, and PowerShell test/analyzer modules).
- Version/compatibility checks where minimum versions are required by repo policy or devcontainer baseline.

Required installation behavior:
- Detect host OS and run platform-appropriate installation steps.
- Install only missing dependencies (idempotent behavior).
- Support a preview mode (no changes) and an apply mode (perform installs).
- Produce a machine-readable and human-readable summary of installed, already-present, failed, and skipped items.

Required script UX:
- `verify` command exits non-zero when required dependencies are missing.
- `install` command can optionally run verification before and after installation.
- Clear remediation hints are printed for any dependency that cannot be auto-installed.

Main flow:
- Resolve host OS and execution context.
- Build the required dependency checklist from repository-defined baseline (Dockerfile + devcontainer settings/features + repo quality commands).
- Run `verify`:
	- detect installed version/availability for each dependency,
	- classify each dependency as `present` or `missing` (with version status when relevant),
	- emit structured and human-readable report,
	- exit `0` only when all required dependencies are satisfied.
- Run `install`:
	- optionally run pre-check (`verify`) to compute missing set,
	- execute install actions for auto-installable dependencies by platform/package-manager,
	- preserve idempotency by skipping already-present dependencies,
	- emit per-dependency result (`installed`, `present`, `failed`, `skipped`),
	- optionally run post-check (`verify`) and return non-zero if unresolved required dependencies remain.

Notable alternatives and edge handling:
- Unsupported OS/package-manager: command returns non-zero with explicit unsupported message and manual fallback steps.
- Partial install failure: command continues best-effort for remaining dependencies, then reports aggregate failure with actionable detail.
- No-admin environment: command attempts non-privileged path first and clearly marks steps requiring elevation.
- Offline/blocked network: dependencies that require remote download are marked failed with remediation instructions.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
	- CLI flags (minimum contract):
		- `verify` / `install` subcommands,
		- `--format text|json` (default `text`),
		- `--dry-run` (for install preview mode),
		- `--precheck` and `--postcheck` toggles for install flow,
		- optional `--only <dependency>` filter for targeted operation.
	- Source files used for baseline extraction:
		- `.devcontainer/local/Dockerfile`,
		- `.devcontainer/local/devcontainer.json`.
	- Environment assumptions:
		- host shell availability,
		- access to package manager(s) appropriate to host OS,
		- network access for install operations.
- Outputs (artifacts, logs, telemetry)
	- Console summary table with dependency status and next actions.
	- Optional JSON report containing:
		- dependency name,
		- required version/constraint,
		- detected version,
		- status,
		- install action attempted,
		- failure reason/remediation.
	- Exit codes:
		- `0` success,
		- non-zero for missing required dependencies, install failure, or unsupported environment.
- Config keys and defaults:
	- Default output format: `text`.
	- Default install mode: apply (unless `--dry-run` provided).
	- Default install check behavior: pre-check enabled, post-check enabled.
	- Default scope: all required dependencies inferred from baseline files.
- Versioning or backward-compatibility constraints:
	- PowerShell baseline must align with devcontainer expectation (`7.5+`).
	- Poetry should align with pinned devcontainer baseline (`2.2.1`) unless policy updates baseline.
	- The checker must tolerate newer compatible versions while flagging known-incompatible older versions.

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Proposed command surface (host bootstrap):
	- `... verify [--format text|json] [--only <dependency>]`
	- `... install [--dry-run] [--format text|json] [--precheck] [--postcheck] [--only <dependency>]`
- Example invocations with expected outputs (concise):
	- Verify all dependencies (text): returns summary with statuses and exits non-zero if any required dependency missing.
	- Verify all dependencies (json): returns structured JSON suitable for automation gates.
	- Install dry-run: prints planned install actions without changing host state.
	- Install apply: installs missing dependencies, prints result summary, reruns post-check, and exits non-zero if unresolved blockers remain.
- Contracts and validation rules:
	- Dependency name matching for `--only` must be exact and case-insensitive.
	- Unknown dependency filter values must produce a clear validation error.
	- JSON output schema must be stable across runs for automation consumers.
	- Install command must never silently ignore failed installation steps.

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
	- Parse baseline dependency requirements from devcontainer definitions into normalized dependency records.
	- Map OS-specific installation strategies to each dependency.
	- Invariant: each dependency record always resolves to exactly one terminal status per run (`present`, `missing`, `installed`, `failed`, `skipped`).
	- Invariant: `install --dry-run` performs no host mutations.
- Caching or persistence details:
	- No required long-term persistence; status is recomputed per run from current host state.
	- Optional ephemeral report file generation is allowed only when explicitly requested by CLI flag.
- Migration or backfill requirements (if any):
	- None for repository data.
	- Existing contributors can adopt scripts incrementally without migrating existing environments.

## Constraints & Risks

- Do not assume administrator privileges; document when elevation is required and continue with best-effort installs for the rest.
- Keep host bootstrap scoped to dependencies required for repository workflows; avoid installing unrelated tools.
- Preserve deterministic behavior by pinning versions where the repo requires known-good versions.
- Risk: package manager differences across Windows/macOS/Linux may make full automation uneven.
- Risk: some dependencies (or versions) may be unavailable on certain hosts; scripts must provide manual fallback instructions.
- Risk: host environment drift over time if devcontainer dependency updates are not reflected in bootstrap requirements.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
	- Add host bootstrap verify/install command implementation under existing repository tooling structure.
	- Add dependency baseline mapping logic driven by `.devcontainer/local/Dockerfile` and `.devcontainer/local/devcontainer.json`.
	- Add user-facing documentation for command usage, supported platforms, and remediation paths.
- New classes/functions/commands to add or update:
	- Dependency detection function set (command existence + version extraction).
	- OS/package-manager strategy selection function set.
	- Install executor functions with idempotent behavior and status aggregation.
	- CLI entrypoints for `verify` and `install` including JSON/text output serialization.
- Dependency changes (new/removed packages) and rationale:
	- Prefer existing standard library and already-approved repo dependencies.
	- Add new runtime dependencies only if required for robust cross-platform process execution or JSON/report formatting beyond existing capability.
- Logging/telemetry additions and locations:
	- Structured command output to stdout/stderr with clear status blocks.
	- Optional verbose mode for detailed command traces and install action diagnostics.
	- No external telemetry required for initial delivery.
- Rollout plan (feature flags, staged deploys, fallback path):
	- Stage 1: deliver verifier + dry-run installer with full reporting.
	- Stage 2: enable apply mode for supported platforms.
	- Fallback: if unsupported platform or package manager is detected, provide manual setup checklist and non-zero exit.

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos (traceability table from ACs to test names/commands added to feature artifacts)
- [ ] Behavior matches acceptance criteria in all documented environments (at minimum one supported host OS validated end-to-end)
- [ ] Tests updated/added (unit/integration as applicable) (dependency detection + install decision logic + end-to-end verify/install/post-verify scenarios)
- [ ] Edge cases and error handling covered by tests (unsupported OS, missing admin rights, offline failure, partial install failure)
- [ ] Docs updated (README, docs/features/active/... links) (bootstrap usage, flags, examples, known limitations)
- [ ] Telemetry/logging added or updated (if applicable) (structured status output for each dependency and final summary)
- [ ] Toolchain pass completed (format → lint → type-check → test) (commands and successful final pass evidence captured)

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas: dependency detection functions, version parsing, OS/package-manager routing, and status aggregation.
- [ ] Unit coverage areas: installer decision logic (install vs skip vs fail) and idempotency checks.
- [ ] Integration scenarios: run verifier on a host with missing tools; confirm expected missing list and non-zero exit code.
- [ ] Integration scenarios: run installer, then verifier; confirm missing auto-installable dependencies are resolved.
- [ ] Integration scenarios: simulate partial install failures and verify actionable failure summary is emitted.
- [ ] CLI/API examples: `verify --format json` for machine-readable output and `install --dry-run` for preview.
