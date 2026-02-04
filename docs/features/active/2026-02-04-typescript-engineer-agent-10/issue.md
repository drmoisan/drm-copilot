---
title: "typescript-engineer-agent - Issue"
issue: "10"
parent: "8"
owner: "Dan Moisan"
last_updated: "2026-02-04T12-47"
status: "Promoted"
status_color: "blue"
version: "1.0"
---

# typescript-engineer-agent (Issue #10)

- Date captured: 2026-02-04
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-02-04-typescript-engineer-agent-10/ (Issue #10)

- Issue: #10
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/10
- Last Updated: 2026-02-04
## Problem / Why

This repo has strict TypeScript quality gates and an explicit toolchain, but it lacks a dedicated “TypeScript engineer” agent definition that encodes those repo-specific rules.

Without a repo-aligned agent definition, agent-assisted TypeScript changes can drift into unsafe typing (e.g., `any`/unchecked indexing), ad-hoc suppressions, or unit tests that accidentally depend on the VS Code extension host—creating review friction and non-deterministic quality outcomes.

## Proposed Behavior

Add a first-class TypeScript engineer agent definition under `.github/agents/` that serves as the working agreement for TypeScript work in this repo.

At a minimum, the agent definition must:

- explicitly reference the governing repo instruction files (general + TypeScript-specific + unit test + suppressions)
- enforce the deterministic TypeScript toolchain loop (in order): `npm run format` → `npm run lint` → `npm run typecheck` → `npm run test:unit`
- enforce suppression governance (only narrowly-scoped, single-line suppressions with an explicit reason)
- enforce the unit-test boundary (Jest-only under `tests/unit/`, no live VS Code extension host)
- encourage strong typing (avoid `any`; prefer `unknown` + narrowing; add runtime guards at trust boundaries)

## Acceptance Criteria (early draft)

- [ ] A TypeScript engineer agent definition exists under `.github/agents/` and is discoverable alongside existing agent templates.
- [ ] The agent definition explicitly references the repo’s governing instruction files for TypeScript and the general code/unit-test policies.
- [ ] The agent definition mandates the repo’s TypeScript toolchain order and uses the exact repo scripts:
	- [ ] `npm run format`
	- [ ] `npm run lint`
	- [ ] `npm run typecheck`
	- [ ] `npm run test:unit`
- [ ] The agent definition enforces suppression policy:
	- [ ] ESLint: only `// eslint-disable-next-line <rule-name> -- <reason>`
	- [ ] TypeScript: only `// @ts-expect-error -- <reason>`; prohibit `@ts-ignore` / `@ts-nocheck`
- [ ] The agent definition states and enforces the unit-test boundary (Jest unit tests in `tests/unit/`; no VS Code host dependencies).
- [ ] The agent definition requires strong typing practices consistent with the repo’s strict TypeScript posture.
- [ ] Feature docs in this folder (`spec.md`, `user-story.md`) are complete and repo-accurate.

## Constraints & Risks

- Performance: enabling (or encouraging) type-aware ESLint rules can slow `npm run lint`; keep scope tight and changes minimal.
- Compatibility: any typed-linting configuration must be scoped to TS-family files so linting does not break on `.js` sources.
- Scope control: avoid broad refactors; fix only what’s needed to keep the toolchain green.
- Suppression governance: avoid file-level disables; prefer real fixes over suppressions.
- Test boundary: unit tests must remain deterministic under Node/Jest without requiring a VS Code extension host.

## Test Conditions to Consider

- [ ] Run the TypeScript toolchain loop in order and verify a clean pass: `npm run format` → `npm run lint` → `npm run typecheck` → `npm run test:unit`.
- [ ] Ensure Jest unit tests under `tests/unit/` do not import or require a live `vscode` extension host.
- [ ] If any new pure-logic helpers are introduced, add Jest unit tests for the new logic.

## Next Step

- [ ] Implement the agent definition under `.github/agents/` (TypeScript engineer role, repo-aligned).
- [ ] Cross-check it against the governing TypeScript instruction + suppression policy docs.
- [ ] (Optional) Evaluate type-aware ESLint setup for TS files only; keep `npm run lint` green.
- [ ] Re-run the full TypeScript toolchain loop until it passes in a single clean pass.
- Source: docs/features/potential/2026-02-04-typescript-engineer-agent.md
