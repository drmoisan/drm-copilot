# `2026-02-04-typescript-engineer-agent` — User Story

- Issue: #10
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-02-04T12-35

## Story Statement

- As a repo maintainer, I want a first-class TypeScript engineer agent definition that follows this repo’s policies and toolchain, so that agent-assisted TS changes are consistent, reviewable, and don’t regress quality.
- As a contributor making TypeScript changes, I want clear, repo-specific rules (toolchain order, suppressions, and unit test boundaries), so that I can ship TS changes quickly without fighting lint/typecheck/test surprises.

## Problem / Why

TypeScript work in this repo is held to strict compiler settings and an explicit toolchain, but there is no dedicated “TypeScript engineer” agent definition that encodes those constraints and the repo’s suppression rules. Without a repo-aligned agent definition, agent-driven changes can drift into unsafe typing (`any`/unchecked indexing), ad-hoc suppressions, or tests that accidentally depend on the VS Code extension host.

This feature defines a TypeScript engineer agent that makes “how we do TS here” explicit and enforceable: toolchain order, strong typing expectations, suppression governance, and a Jest-only unit test boundary.


## Personas & Scenarios

- Persona: Repository maintainer / reviewer
  - who the user is: Maintains `drm-copilot`, reviews PRs, and ensures changes comply with repo policy.
  - what they care about: Predictable toolchain outcomes (`npm run format` → `npm run lint` → `npm run typecheck` → `npm run test:unit`), minimal suppressions, and strict typing.
  - their constraints: Limited review time; needs guardrails that prevent broad “fix by disabling rules.”
  - their goals and frustrations: Wants fast, low-drama PRs; frustrated by changes that pass tests but fail lint/typecheck later, or that introduce unsafe casts.
  - their context and motivations: Repo policies already exist; the maintainer wants an agent to consistently apply them.

- Persona: Contributor (human or agent) making TypeScript changes
  - who the user is: Works in `src/` and `tests/unit/`, shipping incremental improvements.
  - what they care about: Clear guidance on “great TS” for this repo and a deterministic local verification loop.
  - their constraints: Unit tests must not require a VS Code host; suppressions must be narrowly scoped and justified.
  - their goals and frustrations: Wants to avoid the loop of “fix lint → now typecheck fails → now tests fail.”
  - their context and motivations: Prefers explicit contracts, stable CI outcomes, and small, testable steps.

- Scenario: Implement a small TS change with deterministic verification
  - A concrete, step-by-step narrative that describes how a user accomplishes a goal in a real-world context using the system.
  - who is acting? A contributor.
  - what triggered the action? A need to modify a command mapping or utility used by the extension.
  - what steps do they take?
    - Use the TypeScript engineer agent definition as the working agreement for changes.
    - Keep VS Code API usage behind thin boundaries so core logic remains unit-testable.
    - Run the repo toolchain in order and repeat the loop until green:
      - `npm run format`
      - `npm run lint`
      - `npm run typecheck`
      - `npm run test:unit`
  - what obstacles or decisions occur?
    - Decide whether a failure is a typing issue (fix with narrowing/guards) vs a boundary issue (wrap VS Code API interactions).
    - Decide whether a suppression is allowed (single-line, single-rule ESLint disable or single-line `@ts-expect-error` with a specific reason).
  - what outcome do they expect? A PR that is easy to review and passes the full toolchain loop without broad suppressions.


## Acceptance Criteria

- [ ] A new TypeScript engineer agent definition exists under `.github/agents/` and is discoverable alongside existing agent templates.
- [ ] The agent definition explicitly references the repo’s governing instruction files for TypeScript (`.github/instructions/typescript-*.instructions.md`) and the general code/unit-test policies.
- [ ] The agent definition mandates the repo’s TypeScript toolchain order and uses the exact repo scripts:
  - [ ] `npm run format`
  - [ ] `npm run lint`
  - [ ] `npm run typecheck`
  - [ ] `npm run test:unit`
- [ ] The agent definition enforces the repo’s suppression policy:
  - [ ] ESLint suppressions are single-line, single-rule only: `// eslint-disable-next-line <rule-name> -- <reason>`
  - [ ] TypeScript suppressions use `// @ts-expect-error -- <reason>` and prohibit `@ts-ignore` / `@ts-nocheck`.
- [ ] The agent definition states and enforces the unit-test boundary: TypeScript unit tests run via Jest in `tests/unit/` and must not require a live VS Code extension host.
- [ ] The agent definition requires strong typing practices consistent with the repo’s strict TS posture (avoid `any`, prefer `unknown` + narrowing, and use runtime guards at trust boundaries).
- [ ] Documentation in this feature folder (`spec.md` and `user-story.md`) is complete and uses repo-accurate names (scripts, folders, and policies).


## Non-Goals

Call out what is explicitly excluded from this feature.

- Defining a new end-user feature for the VS Code extension (this is a developer workflow / agent-definition improvement).
- Changing TypeScript compiler strictness settings in `tsconfig.json`.
- Replacing Jest with another unit test runner or requiring the VS Code extension host for unit tests.
- Introducing broad suppression mechanisms (file-level ESLint disables, `@ts-ignore`, `@ts-nocheck`).
