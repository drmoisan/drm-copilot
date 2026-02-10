# `2026-02-10-agents-skills-and-sync` — User Story

- Issue: #14
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-02-10T09-08

## Story Statement

- As a repo maintainer for agentic tooling, I want skills to be discoverable and canonicalized, so that guidance does not drift between agents and prompts.
- As a contributor updating agent workflows, I want a repeatable sync path between repos, so that MVP updates are reliable without manual diff hunting.

## Problem / Why

Skills, agent instructions, and prompt scaffolding live in multiple places with overlapping guidance. This creates drift, increases onboarding time, and makes it harder to reason about which source is canonical. The lack of a repeatable synchronization path between repos forces manual updates and makes MVP-level coordination brittle.


## Personas & Scenarios

- Persona: Agent tooling maintainer
  - Maintains agent/prompt instructions across multiple repos.
  - Cares about consistent guidance and minimizing drift across teams.
  - Constrained by limited time and mixed repo layouts.
  - Goal: make updates once and keep all repos aligned.
  - Frustration: duplicated rules diverge and cause inconsistent behavior.
- Scenario: Syncing a skill update across repos
  - Trigger: the maintainer updates a workflow rule in the feature review skill.
  - Steps: they confirm the skill is the canonical source, run the MVP sync script against two local repos, and review the generated sync artifact.
  - Decision: if a conflict is detected, they choose the forced direction and rerun the sync.
  - Outcome: both repos share identical `.github` governance files and a traceable audit artifact exists.


## Acceptance Criteria

- [ ] SKILL taxonomy is documented and used to locate and load skills consistently across agent flows.
- [ ] Canonical locations are defined for repeatable guidance, with explicit references to prevent drift.
- [ ] MVP synchronization workflow can pull/push agentic files between repos without manual diff hunting.
- [ ] Failure cases (missing skill, conflicting canonical location, sync conflict) produce actionable messages.
- [ ] Edge cases (renamed skill folder, deleted canonical file, partial sync) are handled deterministically.


## Non-Goals

- Building the full extension-based automation for cross-repo synchronization.
- Syncing non-`.github` content or arbitrary workspace files.
- Automatic conflict resolution beyond explicit forced direction flags.
- Network-only synchronization or SaaS-backed storage.
