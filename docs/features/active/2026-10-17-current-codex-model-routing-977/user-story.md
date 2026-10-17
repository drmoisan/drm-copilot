# `2026-10-17-current-codex-model-routing` — User Story

- Issue: #977
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-17T13-21

## Story Statement

- As a Codex orchestration operator, I want each existing complexity tier to resolve its authorized current model, so that specialist delegation can proceed with the required reasoning effort and profile attestation.
- As a maintainer distributing Codex customizations, I want policy, generated agents, validators, and bundles to agree, so that repository and installed customization surfaces enforce the same routing contract.

## Problem / Why

Codex routing pins unavailable GPT-5.6 models and prevents required specialist delegation. Replacing the model identities must preserve the established topology, reasoning tiers, and validation rules so operators can distinguish a supported migration from an unauthorized fallback.


## Personas & Scenarios

- Persona: Codex orchestration operator responsible for a feature or epic.
  - The operator must launch an exact approved profile and persist its routing receipt before delegation.
  - The operator needs the existing complexity assessment, file-count budgets, and ceiling rules to remain stable.
  - Model unavailability and invalid attestation must remain explicit blocking conditions.
- Persona: Customization maintainer responsible for generated agents and bundled deployment surfaces.
  - The maintainer needs a reproducible generator, synchronized mirrors, and evidence that current validators agree across languages.
  - Historical receipts and unrelated provider settings must retain their meaning.
- Scenario: A standalone C3 feature requires a specialist.
  - The operator resolves topology and then the model profile using the existing CLI.
  - The resolver selects the existing C3 agent family with `gpt-6.1-sol` and high reasoning; the operator persists the exact receipt and launches that profile.
  - If the ceiling rises to C4 or the work becomes an epic child, the operator re-resolves affected C3 delegations to the elevated profile with `gpt-6-astra` and high reasoning.
  - Root epic personas resolve `gpt-6-astra` with ultra reasoning. A missing model or invalid profile receipt blocks delegation with the existing diagnostic.
- Scenario: The maintainer distributes the updated routing policy.
  - The maintainer updates current inputs, regenerates variants and bundles, runs local contracts/toolchains, and creates a PR.
  - The item's orchestrator verifies required checks against the final PR head before reporting completion.


## Acceptance Criteria

- [x] STORY-01: Operators resolve C1 to `gpt-6-luna`/low, C2 to `gpt-6.1-sol`/medium, and standalone C3 under a C3 ceiling to `gpt-6.1-sol`/high through the existing command surface.
- [x] STORY-02: Elevated C3 resolves `gpt-6-astra`/high under the existing epic-child or C4-ceiling conditions, C4 resolves Astra/max, and both root epic personas resolve Astra/ultra without changing file-count topology or ceiling rules.
- [x] STORY-03: Missing/unavailable exact models and invalid profile/model/effort/hash receipts still block delegation; operators receive the existing diagnostic and no silent fallback occurs.
- [x] STORY-04: Maintainers can regenerate a synchronized current policy/profile/bundle set that passes routing, generator, mirror, and manifest checks while preserving historical evidence and unrelated provider settings.
- [ ] STORY-05 (CI-dependent): Completion includes applicable local toolchain evidence and required CI success recorded for the final PR head, with any CI check-off push reverified at its resulting head.


## Non-Goals

Changing complexity classification, language budgets, topology selection, profile suffixes, logical-agent aliases, ceiling monotonicity, or reasoning effort is outside scope. Adding providers, dependencies, public commands, telemetry services, or automatic model fallback is outside scope. Historical checkpoints and historical fixture evidence are not migrated, and unrelated provider model settings are not changed.
