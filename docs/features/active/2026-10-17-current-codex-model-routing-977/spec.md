# 2026-10-17-current-codex-model-routing — Spec

- **Issue:** #977
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-17T13-21
- **Status:** Draft
- **Version:** 0.1

## Overview

Codex routing pins unavailable GPT-5.6 models and prevents required specialist delegation. Replace current Codex routing identifiers with the authorized equivalents across policy, profiles, runtime defaults, validators, distribution bundles, tests, and current operational guidance. Preserve routing decisions, reasoning effort, receipt validation, and historical evidence.

The supplied [research](research/2026-10-17T17-22-current-codex-model-routing-research.md) is sufficient to complete this bounded specification. Installed-validator readiness and truthful transition of live launch receipts remain orchestration responsibilities.


## Behavior

Use the current equivalent Codex models: `gpt-5.6-luna` becomes `gpt-6-luna`, `gpt-5.6-terra` becomes `gpt-6.1-sol`, and `gpt-5.6-sol` becomes `gpt-6-astra`.

| Deployment condition | Model | Reasoning effort | Profile suffix |
| --- | --- | --- | --- |
| C1 | `gpt-6-luna` | `low` | `c1` |
| C2 | `gpt-6.1-sol` | `medium` | `c2` |
| C3 standalone with C3 ceiling | `gpt-6.1-sol` | `high` | `c3` |
| C3 in either epic-child context, or under a C4 ceiling | `gpt-6-astra` | `high` | `c3-elevated` |
| C4 | `gpt-6-astra` | `max` | `c4` |
| Root `epic-planner` or `epic-orchestrator` | `gpt-6-astra` | `ultra` | Existing unsuffixed forced persona |

Resolve topology before model selection and preserve the current language budgets and execution-context rules. Preserve the `feature-review` logical-agent alias, generated family names, and monotonic ceiling transitions. Base agent defaults use the corresponding replacement for their existing model and retain their existing reasoning effort.

Persist the resolved topology and model receipt before launching the exact generated profile. Profile name, model, effort, path, SHA-256, and start attestation remain required. Missing or inconsistent policy, malformed inputs, absent profiles, unavailable exact models, and invalid receipts continue to fail closed; no silent fallback is introduced.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars): existing topology and deployment CLI arguments; `config/orchestration-routing.json`; base `.codex/agents/*.toml`; current Python, PowerShell, and TypeScript routing defaults; existing checkpoint receipt data. No new environment variable or CLI flag is required.
- Outputs (artifacts, logs, telemetry): the existing topology/deployment JSON shapes, generated profile TOML, generated Codex pack manifests and bundled mirrors, and existing validation results. Evidence is stored under this feature's `evidence/<kind>/` directories.
- Config keys and defaults: update model identifiers under `codex_model_policy.complexity_to_profile`, `c3_elevated_profile`, and `forced_personas`; retain suffixes, efforts, activation conditions, aliases, and generated families.
- Versioning or backward-compatibility constraints: keep routing schema and receipt shapes unchanged. Historical receipts are not rewritten; a resumed current delegation must obtain a fresh receipt for the actual current profile rather than claim an old hash or model is current.

## API / CLI Surface

The existing `.codex/scripts/Resolve-CodexTopology.ps1` and `.codex/scripts/Resolve-CodexDeployment.ps1` command surfaces remain available with their existing arguments and JSON result fields.

- Example invocations with expected outputs (concise): `pwsh -NoProfile -File .codex/scripts/Resolve-CodexDeployment.ps1 --logical-agent prd-feature --complexity-band C3 --execution-context standalone --orchestration-complexity-ceiling C3` resolves `prd-feature-c3`, `gpt-6.1-sol`, and `high`; changing the ceiling to C4 resolves `prd-feature-c3-elevated`, `gpt-6-astra`, and `high`.
- Contracts and validation rules: root epic personas resolve Astra/ultra regardless of the ordinary complexity profile. Python, PowerShell, and TypeScript agree for the shared routing corpus. Missing inputs, unknown values, invalid topology, profile/model/effort/hash mismatches, and unavailable models preserve their existing rejection behavior.

## Data & State

The policy remains the source for current routing, with base agents as generator inputs. Generation refreshes profile variants, bundled copies, and Codex pack metadata through `scripts/dev_tools/generate_codex_agent_variants.py`.

- Data transformations and invariants: replace only the three authorized Codex model identities in active routing surfaces. Preserve provider-independent complexity rules, file-count topology, effort values, ceiling monotonicity, and receipt validation.
- Caching or persistence details: retain existing checkpoint locations and receipt collections. Deployment receipts must describe the generated profile actually launched, including its current hash.
- Migration or backfill requirements (if any): regenerate current distribution artifacts. Do not backfill historical checkpoint or fixture evidence and do not alter unrelated provider settings.

## Constraints & Risks

Preserve historical checkpoint evidence, historical fixture evidence, and unrelated provider model settings. Add no dependencies. The supplied Codex host supports Astra ultra; public API effort documentation does not override this Codex-specific capability.

Current routing fixtures that assert the new behavior must be updated, while fixtures retained as historical evidence remain unchanged. A repository-wide text replacement is insufficient because the same strings can appear in both categories. Generated files and pack manifests must remain fresh and mirrored runtime guidance must remain synchronized. Local validation does not establish remote CI success.

Existing validators compare every live model receipt against current policy. Preserve prior launch records verbatim as historical evidence; do not relabel an earlier launch, replace its historical hash, or add a compatibility exception to make it pass current validation. The installed MCP validator executes installed extension code and can still expect former models after this branch changes. Final authoritative completion therefore requires a matching installed validator; branch-current validation alone does not satisfy that operational requirement.


## Implementation Strategy

- Implementation scope (what changes, not sequencing): current Codex policy/configuration, twelve base aliases and sixty generated variants in source and bundle, two forced epic personas, Python/PowerShell/TypeScript routing defaults and validators, the epic attestation expectation, related current tests, and current documentation/skills. Explicit skill updates cover `codex-model-routing`, `epic-plan`, `epic-orchestrate`, `orchestrate`, and `orchestrator-workflow`, plus their Codex bundle mirrors; forced epic instruction prose must also match the new roles. Preserve the existing shared policy resource locations without adding a Codex-bundle policy copy.
- New classes/functions/commands to add or update: use the existing generator and resolver/validator boundaries, including `scripts/dev_tools/generate_codex_agent_variants.py`, Python Codex model validators, `extensions/drm-copilot/src/lib/validate/orchestrator-state-codex-model-routing.ts`, and existing Codex PowerShell routing surfaces. No new public command is required.
- Dependency changes (new/removed packages) and rationale: none.
- Logging/telemetry additions and locations: retain existing diagnostics, including `model_unavailable`, and receipt evidence; no new telemetry service is required.
- Rollout plan (feature flags, staged deploys, fallback path): publish the synchronized policy/profile/bundle update through the existing distribution mechanism. Validate branch-current code locally and verify final-head CI. Exact-model unavailability remains blocking and requires an explicit policy decision.

Map SPEC-01/02/03/06 to deployment-resolution, model-receipt, topology, epic persona, and attestation tests in the research inventory. Map SPEC-04/05 to generator freshness, resource/manifest parity, wrapper/handoff, and current skill contracts. Map SPEC-07 to ordered complete language gates, coverage reports, and isolation evidence; map SPEC-08 to the final PR-head CI gate. No new receipt-compatibility framework is required or authorized by this specification.

## Definition of Done

- [x] SPEC-01: Current policy, base agents, generated variants, runtime defaults, and validators use the exact model/effort table above, with no stale legacy default in an active Codex routing path.
- [x] SPEC-02: C1-C4 decisions, elevated C3 activation in both epic-child contexts and under a C4 ceiling, forced epic Astra/ultra, aliases, and monotonic ceilings are verified against the shared routing corpus without changing topology budgets.
- [x] SPEC-03: Invalid/absent inputs and profiles, wrong exact model/effort/path/hash, invalid topology, failed start attestation, and unavailable exact models retain fail-closed behavior without fallback.
- [x] SPEC-04: The Codex generator passes `--check`; resource, pack-manifest, wrapper, handoff, and routing parity contracts pass for affected distributable surfaces.
- [x] SPEC-05: Current model-routing documentation and skills describe the replacement table and Codex epic ultra capability; historical checkpoint/fixture evidence and unrelated provider settings are preserved.
- [x] SPEC-06: Receipt schema and diagnostic behavior remain unchanged; newly resolved receipts identify the actual current generated profile and hash, and validators continue to reject stale former-model receipts under current policy without a compatibility exception.
- [x] SPEC-07: Complete applicable local Python, PowerShell, and TypeScript toolchains pass in formatting → linting → type-checking → testing order, with PowerShell type checking omitted; required changed-file coverage and isolation checks have recorded evidence.
- [x] SPEC-08 (CI-dependent): The item's orchestrator records required CI success at the final PR head, then pushes any CI criterion check-off and verifies CI again so the recorded head equals the final PR head before completion.

## Seeded Test Conditions (from potential)
- [x] Boundary tests cover all four complexity bands, all three execution contexts, C3/C4 ceiling transitions, and both root epic personas.
- [x] Current generated-profile freshness and mirror parity tests pass, and exact-model mismatch rejection is tested independently of successful resolution.
- [x] CI-dependent: Local toolchain evidence and final PR-head CI evidence are recorded separately; CI remains pending until the remote gate succeeds.
