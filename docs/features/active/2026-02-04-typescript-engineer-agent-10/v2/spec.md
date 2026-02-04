# 2026-02-04-typescript-engineer-agent — Spec

- **Issue:** #10
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-04T12-35
- **Status:** Draft
- **Version:** 1.0

## Overview

This repo has strong TypeScript quality gates (Prettier, ESLint, strict TSC, Jest unit tests) and explicit suppression policies, but it does not have a dedicated “TypeScript engineer” agent definition that encodes those rules in one place. As a result, agent-assisted TypeScript changes can be inconsistent (toolchain order drift), overly reliant on suppressions, or inadvertently couple unit tests to the VS Code extension host.

This feature adds a repo-aligned TypeScript engineer agent definition under `.github/agents/` that:

- cites the exact governing policy docs and their precedence
- enforces the repo’s TypeScript toolchain loop and ordering
- enforces suppression governance (only the pre-authorized single-line patterns)
- reinforces the repo’s unit test boundary (Jest-only, no VS Code host)

This spec is intentionally limited to delivering the agent definition file only.


## Behavior

At a high level, the feature provides a standardized “contract” for TypeScript engineering work in this repo:

- A new agent template exists under `.github/agents/` alongside the existing agent templates.
- The agent definition is prescriptive about:
	- policy precedence (general policies → TypeScript-specific policies → unit-test policies)
	- safe TypeScript defaults (avoid `any`, prefer `unknown` + narrowing, runtime guards at trust boundaries)
	- separation of concerns (thin VS Code/I/O boundaries; pure logic unit-testable under Node)
	- suppression usage (allowed formats only; discourage suppressions by default)
	- deterministic verification (repeat toolchain loop until green).



## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
- Outputs (artifacts, logs, telemetry)
- Config keys and defaults:
- Versioning or backward-compatibility constraints:

Inputs

- Files (source of truth for repo rules):
	- `.github/instructions/general-code-change.instructions.md`
	- `.github/instructions/general-unit-test.instructions.md`
	- `.github/instructions/typescript-code-change.instructions.md`
	- `.github/instructions/typescript-unit-test.instructions.md`
	- `.github/instructions/typescript-suppressions.instructions.md`
- Toolchain scripts (must be referenced verbatim): `package.json` scripts
	- `format`, `lint`, `typecheck`, `test:unit`
- No new CLI flags or environment variables are introduced by this feature.

Outputs

- A new agent definition file under `.github/agents/` describing the TypeScript engineer agent (policy-aligned, toolchain-aligned).


Config keys and defaults

- No new runtime configuration keys are introduced.

Versioning / backward compatibility

- No changes to published runtime APIs are required. The primary outcome is developer workflow and agent-template behavior.


## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Example invocations with expected outputs (concise):
- Contracts and validation rules:

No new runtime API surface or end-user CLI commands are introduced.

Developer commands (repo-standard; must be used in this order for the toolchain loop)

- Formatting:
	- `npm run format`
- Linting:
	- `npm run lint`
- Type checking:
	- `npm run typecheck`
- Unit tests:
	- `npm run test:unit`

Example invocations (expected outcome is success exit code)

- Full toolchain loop (single pass when green):
	- `npm run format`
	- `npm run lint`
	- `npm run typecheck`
	- `npm run test:unit`

Contracts and validation rules (agent definition)

- Policy precedence: general code-change + unit-test policies apply first, then TypeScript-specific policy docs.
- Unit test boundary: Jest-only unit tests under `tests/unit/` must not require the VS Code extension host.
- Suppressions:
	- ESLint: only single-line, single-rule disables are allowed without explicit approval:
		- `// eslint-disable-next-line <rule-name> -- <reason>`
	- TypeScript: only single-line `@ts-expect-error` is allowed without explicit approval:
		- `// @ts-expect-error -- <reason>`
	- Prohibited without explicit approval: file-level ESLint disables, `@ts-ignore`, `@ts-nocheck`.

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
- Caching or persistence details:
- Migration or backfill requirements (if any):

This feature does not introduce new runtime data flows, persistence, or user state.

Data transformations and invariants

- The agent definition will describe TypeScript invariants expected in this repo:
	- avoid `any` (implicit or explicit)
	- prefer `unknown` + narrowing and runtime guards at trust boundaries
	- use explicit domain types and discriminated unions when modeling stateful flows.

Caching / persistence details

- No new repo-managed caches or persistent files are introduced.

Migration / backfill

- No migrations or backfills are required.

## Constraints & Risks

Constraints and risks to account for:

- Scope control: This feature is documentation-only (agent definition markdown) and must not expand into code/config changes.
- Suppression governance: The agent definition must enforce the repo suppression policy and prohibit broad suppressions.
- Test boundary: The agent definition must state and enforce that unit tests remain Node/Jest-only and must not require the VS Code extension host.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
- New classes/functions/commands to add or update:
- Dependency changes (new/removed packages) and rationale:
- Logging/telemetry additions and locations:
- Rollout plan (feature flags, staged deploys, fallback path):

Implementation scope (what changes)

- Add a new agent definition template under `.github/agents/` for a “TypeScript engineer” role.
- Ensure the agent template mirrors existing agent rigor where appropriate (policy precedence, toolchain loop, and quality gates), but uses the TypeScript-specific policies and scripts.

New classes/functions/commands

- No new runtime commands are required. This is a documentation + configuration feature.


Dependency changes

- No new dependencies are required. The repo already contains `typescript`, `eslint`, `typescript-eslint`, `jest`, `ts-jest`, and `prettier` in `package.json`.

Logging/telemetry

- No new runtime telemetry is introduced.


Rollout plan

- No feature flag is required (this is a developer workflow change).


## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

Evidence expectations for this feature (how DoD will be verified)

- Agent definition exists and is reviewable under `.github/agents/`.
- The agent definition text explicitly names the required repo scripts and the suppression patterns.


## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas
	- [ ] None required (markdown-only agent definition).
- [ ] Integration scenarios
	- [ ] None required for the agent definition itself; integration tests remain owned by the existing VS Code test harness (`npm test`) and are out of scope unless a change unintentionally affects them.
- [ ] CLI/API examples
	- [ ] The spec and agent definition include the copy/paste toolchain command sequence using repo scripts.
