# Current Codex model routing (Issue #977)

- Date captured: 2026-10-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/2026-10-17-current-codex-model-routing-977/ (Issue #977)

- Issue: #977
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/977
- Last Updated: 2026-10-17
- Work Mode: full-feature

## Problem / Why

Codex routing pins unavailable GPT-5.6 models and prevents required specialist delegation. Current policy, generated agents, validators, and distribution bundles must agree on the replacement model identifiers so a valid delegation can pass the existing exact-profile checks.

## Proposed Behavior

Use the current equivalent Codex models while preserving complexity bands, tier roles, overlays, and supported reasoning effort: `gpt-5.6-luna` becomes `gpt-6-luna`, `gpt-5.6-terra` becomes `gpt-6.1-sol`, and `gpt-5.6-sol` becomes `gpt-6-astra`.

C1 uses Luna with low reasoning; C2 uses Sol with medium reasoning; C3 uses Sol with high reasoning. The existing elevated C3 conditions use Astra with high reasoning, C4 uses Astra with max reasoning, and the two root epic personas use Astra with ultra reasoning. File-count topology and the monotonic complexity ceiling retain their current behavior.

## Acceptance Criteria (early draft)

- [x] Current routing policy, base/generated Codex agents, runtime defaults, validators, current documentation and skills, and bundled mirrors agree on the approved model/effort table in `spec.md`.
- [x] Routing preserves production-file topology, C3 elevated activation, monotonic ceilings, exact-profile receipts and hashes, epic ultra reasoning, and rejection of invalid or unavailable deployments.
- [ ] Applicable local toolchains and routing/generator/mirror contracts pass; the item's orchestrator separately verifies required CI at the final PR head before completion.

## Constraints & Risks

Preserve historical checkpoint evidence, historical fixture evidence, and unrelated provider model settings. Add no dependencies. The supplied Codex host capability confirms Astra ultra reasoning; the public API's different effort list must not reduce the Codex root epic setting. An unavailable exact replacement remains a blocking deployment failure rather than a reason to substitute another model.

## Test Conditions to Consider

- [x] C1-C4, all three execution contexts, C3/C4 ceiling boundaries, logical-agent aliases, and both root epic personas.
- [x] Fresh generated profiles and bundles; absent profiles, wrong model/effort/hash, invalid topology, and unavailable exact models remain rejected.
- [ ] Complete applicable Python, PowerShell, and TypeScript toolchains, mirror/manifest contracts, and CI-dependent final-head verification.

## Next Step

- [x] Promote to GitHub issue (feature request template).
- [x] Create the associated active feature folder.
