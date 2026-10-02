# copilot-surface-review-verdict-contract (Potential)

- Date captured: 2026-10-01
- Author: Dan Moisan
- Status: Draft
- Source: follow-up 4 of issue #484 (`docs/features/active/2026-09-29-orchestrator-remediation-loop-control-484/spec.md`, `## Rollout & Follow-up`; research section 6)

## Problem / Why

Issue #484 replaced the two-value review verdict with four values: `PASS`, `REMEDIATION_REQUIRED`, `HALT_NON_REMEDIABLE`, `AWAITING_CI`. It added five remediability classes and consistent remediation-cycle accounting (`completed_attempts`, `review_outcomes`, `candidate_applied`, `opened_by_review`). The change covers the Claude, `.agents`, and Codex surfaces. The Copilot-native `.github/` surface (agents, prompts, skills, and their mirrors) was out of scope, so it still describes the two-value verdict and the earlier cycle accounting.

## Proposed Behavior

Update the Copilot `.github/` orchestration and feature-review documents and their mirrors to the #484 verdict and accounting contract. Use the same line prefixes (`Review-Verdict:`, `Remediability:`, `Remediability-Evidence:`), the same halt precedence, and the three-completed-attempts cap.

## Acceptance Criteria (early draft)

- [ ] Every Copilot orchestration and review document states the four-value verdict and the five remediability classes.
- [ ] Halt and wait conditions are documented as not consuming a remediation cycle.
- [ ] Mirrors are byte-identical and the mirror suites pass.
- [ ] `.github/instructions/` policy files are not modified unless separately authorized.

## Constraints & Risks

- `.github/instructions/` is canonical policy and must not be edited without operator authorization.
- Wording must stay in sync with `.claude/rules/orchestrator-state.md` `## Invariants (remediation_loop.review_outcomes)`.

## Test Conditions to Consider

- [ ] Unit coverage areas: documentation drift tests for the fixed tokens used in #484 (`Halt precedence:`, `three completed attempts`, `completed_attempts + 1`)
- [ ] Integration scenarios: a Copilot-surface review that produces `HALT_NON_REMEDIABLE`
- [ ] CLI/API examples: none

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/copilot-surface-review-verdict-contract/` folder from the template
