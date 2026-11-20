# Current Codex model routing (Issue #977)

- Date captured: 2026-10-17
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/Current_Codex_model_routing/ (Issue #977)

- Issue: #977
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/977
- Last Updated: 2026-10-17
## Problem / Why

Codex routing pins unavailable GPT-5.6 models and prevents required specialist delegation.

## Proposed Behavior

Use the current equivalent Codex models while preserving complexity bands, tier roles, overlays, and supported reasoning effort: gpt-5.6-luna becomes gpt-6-luna, gpt-5.6-terra becomes gpt-6.1-sol, and gpt-5.6-sol becomes gpt-6-astra.

## Acceptance Criteria (early draft)

- [ ] Routing policy, generated profiles, runtime validators, active documentation, and bundled mirrors use the approved equivalents.
- [ ] C1-C4 topology, C3 overlay, epic ultra reasoning, and fail-closed deployment behavior are preserved.
- [ ] Relevant Python, TypeScript, PowerShell, generator, parity, and CI checks pass.

## Constraints & Risks

Preserve historical checkpoint evidence and unrelated provider model settings. Add no dependencies. Host capability confirms Codex Astra ultra reasoning.

## Test Conditions to Consider

- [ ] All complexity bands, execution contexts, and ceilings.
- [ ] Generated-profile freshness, bundle parity, exact-model mismatch rejection.
- [ ] Full applicable toolchains and exact PR head CI.

## Next Step

- [ ] Promote to GitHub issue (feature request template).
- [ ] Create the associated active feature folder.
