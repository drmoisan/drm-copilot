# 2026-02-04-typescript-engineer-agent — Spec

- **Issue:** #10
- **Parent (optional):** 8
- **Owner:** drmoisan
- **Last Updated:** 2026-02-04T12-35
- **Status:** Superceded by version 2.0
- **Version:** 1.0

## Overview

This repo has strong TypeScript quality gates (Prettier, ESLint, strict TSC, Jest unit tests) and explicit suppression policies, but it does not have a dedicated “TypeScript engineer” agent definition that encodes those rules in one place. As a result, agent-assisted TypeScript changes can be inconsistent (toolchain order drift), overly reliant on suppressions, or inadvertently couple unit tests to the VS Code extension host.

This feature adds a repo-aligned TypeScript engineer agent definition under `.github/agents/` that:

- cites the exact governing policy docs and their precedence
- enforces the repo’s TypeScript toolchain loop and ordering
- enforces suppression governance (only the pre-authorized single-line patterns)
- reinforces the repo’s unit test boundary (Jest-only, no VS Code host)

As a supporting repo-alignment improvement, this feature also describes (and may implement) enabling type-aware ESLint rules for TypeScript files in `eslint.config.mjs` using typescript-eslint’s typed-linting configuration.


## Behavior

At a high level, the feature provides a standardized “contract” for TypeScript engineering work in this repo:

- A new agent template exists under `.github/agents/` alongside the existing agent templates.
- The agent definition is prescriptive about:
	- policy precedence (general policies → TypeScript-specific policies → unit-test policies)
	- safe TypeScript defaults (avoid `any`, prefer `unknown` + narrowing, runtime guards at trust boundaries)
	- separation of concerns (thin VS Code/I/O boundaries; pure logic unit-testable under Node)
	- suppression usage (allowed formats only; discourage suppressions by default)
	- deterministic verification (repeat toolchain loop until green).

If typed linting is enabled as part of the feature, ESLint should apply type-aware rules to TypeScript files without breaking linting for JavaScript files and without requiring file-level disables.


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
- Existing TypeScript sources/tests that may require adjustments when typed linting is enabled:
	- `src/drm-task-provider.ts`
	- `src/task-command-map.ts`
	- `src/utilities/utility-dispatcher.ts`
	- `src/utilities/utility-spec.ts`
- No new CLI flags or environment variables are introduced by this feature.

Outputs

- A new agent definition file under `.github/agents/` describing the TypeScript engineer agent (policy-aligned, toolchain-aligned).
- (Optional but in-scope if adopted) Updated `eslint.config.mjs` to enable typed linting for TypeScript files only.
- (If typed linting is enabled) Minimal code fixes to satisfy the newly enforced type-aware rules while preserving runtime behavior.

Config keys and defaults

- ESLint typed linting (if enabled): configure type-aware parsing/rules for TS-family files using `parserOptions.projectService: true` and `tsconfigRootDir` (per typescript-eslint guidance).

Versioning / backward compatibility

- No changes to published runtime APIs are required. The primary outcome is developer workflow and agent-template behavior.
- Enabling typed linting may introduce new lint failures until code is adjusted; the feature must keep `npm run lint` green at the end of the change.

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

- If typed linting is enabled, ESLint’s TypeScript project service may cache project graph information during lint runs (an implementation detail of the lint toolchain). No repo-managed cache files are introduced by this feature.

Migration / backfill

- No migrations or backfills are required.

## Constraints & Risks

Constraints and risks to account for:

- Performance: Type-aware ESLint rules require TypeScript project analysis; `npm run lint` may be slower when typed linting is enabled.
- Compatibility: The repo includes JavaScript files under `src/` and `tests/`; typed linting must be scoped to TS-family files so linting does not break on `.js`.
- Scope control: This feature should not become a broad refactor of TypeScript code. If enabling typed linting triggers many findings, address the minimal set required to keep the toolchain green.
- Suppression governance: The typed linting wave may tempt broad suppressions; the feature must remain aligned with `typescript-suppressions.instructions.md` and prefer real fixes.
- Test boundary: Unit tests must remain Node/Jest-only and must not require the VS Code extension host.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
- New classes/functions/commands to add or update:
- Dependency changes (new/removed packages) and rationale:
- Logging/telemetry additions and locations:
- Rollout plan (feature flags, staged deploys, fallback path):

Implementation scope (what changes)

- Add a new agent definition template under `.github/agents/` for a “TypeScript engineer” role.
- Ensure the agent template mirrors existing agent rigor where appropriate (policy precedence, toolchain loop, and quality gates), but uses the TypeScript-specific policies and scripts.
- If typed linting is adopted as part of this feature:
	- Update `eslint.config.mjs` to enable typescript-eslint typed linting scoped to TS-family files (avoid applying TS parser/rules to `.js`).
	- Fix the initial set of type-aware lint findings in the existing TypeScript sources while keeping behavior stable.

New classes/functions/commands

- No new runtime commands are required. This is a documentation + configuration feature.
- If enabling typed linting requires small code adjustments, prefer local type refinements and boundary guards rather than introducing new abstractions.

Dependency changes

- No new dependencies are required. The repo already contains `typescript`, `eslint`, `typescript-eslint`, `jest`, `ts-jest`, and `prettier` in `package.json`.

Logging/telemetry

- No new runtime telemetry is introduced.
- If code changes are required to satisfy typed linting, prefer improving error messages and invariants at existing boundaries rather than adding new logging.

Rollout plan

- No feature flag is required (this is a developer workflow change).
- If typed linting is enabled, rollout is “all at once” by updating `eslint.config.mjs`; success is measured by `npm run lint` returning success and the full toolchain pass staying green.

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
- If typed linting is enabled:
	- `npm run lint` passes with type-aware rules for TypeScript files.
	- The full toolchain loop completes successfully in a single pass:
		- `npm run format`
		- `npm run lint`
		- `npm run typecheck`
		- `npm run test:unit`

## Seeded Test Conditions (from potential)
- [ ] Unit coverage areas
	- [ ] New or modified pure-logic helpers (if any are introduced while fixing typed-lint errors) have Jest unit tests under `tests/unit/`.
	- [ ] Unit tests explicitly avoid VS Code extension host dependencies (mock `vscode` where needed).
- [ ] Integration scenarios
	- [ ] None required for the agent definition itself; integration tests remain owned by the existing VS Code test harness (`npm test`) and are out of scope unless a change unintentionally affects them.
- [ ] CLI/API examples
	- [ ] The spec and agent definition include the copy/paste toolchain command sequence using repo scripts.
