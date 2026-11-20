# remediation-inputs-layout-reconciliation (Potential)

- Date captured: 2026-10-01
- Author: Dan Moisan
- Status: Draft
- Source: follow-up 2 of issue #484 (`docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/spec.md`, `## Rollout & Follow-up`; research section 1.3)

## Problem / Why

Two layouts for remediation inputs are in use. The orchestrator agent and checkpoint protocol name a flat `remediation-inputs.<timestamp>.md` file in the feature folder. The remediation-handoff skills prescribe `remediation/<entry-ts>/remediation-inputs.md`. Producers, reviewers, and validators can disagree about where a cycle's inputs live, and `remediation_loop.cycles[].inputs_path` has no single canonical shape.

## Proposed Behavior

Choose one canonical layout. Update the orchestrator agent, both orchestrate skills, the remediation-handoff skills, and their bundle mirrors to that layout, and document a transition rule for existing feature folders.

## Acceptance Criteria (early draft)

- [ ] One layout is named canonical in the orchestrator-state rules and every remediation skill.
- [ ] All document mirrors are updated in the same change, and the mirror suites pass.
- [ ] Existing checkpoints whose `inputs_path` uses the other form still validate, or a documented migration exists.

## Constraints & Risks

- Documentation and skill surfaces across `.claude/`, `.agents/`, Codex, and the bundled payload.
- Existing feature folders already contain both forms.

## Test Conditions to Consider

- [ ] Unit coverage areas: documentation drift tests that assert the canonical path literal
- [ ] Integration scenarios: a remediation cycle run end to end with the canonical layout
- [ ] CLI/API examples: none

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/remediation-inputs-layout-reconciliation/` folder from the template
