# harden-orchestrate-skill (Issue #232)

- Date captured: 2026-06-24
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/harden-orchestrate-skill/ (Issue #232)

- Issue: #232
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/232
- Last Updated: 2026-06-24
- Work Mode: full-feature

## Problem / Why

The `orchestrate` skill currently states the overall orchestration lifecycle but
does not explicitly define the hardened pre-edit sequence needed to prevent an
agent from moving directly from policy reads into implementation. A recent
session demonstrated that a direct code edit can occur before scope assessment,
route selection, checkpoint state, and lifecycle setup are complete.

## Proposed Behavior

Update `.agents/skills/orchestrate/SKILL.md` so it explicitly requires:

- the already-active main session to serve as the canonical orchestrator runtime;
- read-only scope assessment and route selection before lifecycle MCP calls;
- checkpoint state with route metadata before implementation edits or delegated
  implementation;
- ordered lifecycle MCP calls after route selection;
- clear pre-implementation and violation-handling gates;
- review delegate naming aligned with `config/orchestration-routing.json`.

## Acceptance Criteria (early draft)

- [ ] The skill defines an entry-point contract that identifies the main
      session as the orchestrator runtime and distinguishes that from any
      optional orchestrator profile.
- [ ] The skill requires read-only scope assessment and route selection before
      lifecycle MCP tools such as `new_potential_entry`, `potential_to_issue`,
      and `new_active_feature_folder`.
- [ ] The skill defines a pre-implementation gate requiring matching checkpoint
      state, route metadata, and lifecycle readiness before edits, formatters,
      tests, staging, commits, or implementation delegation.
- [ ] The skill defines ordered lifecycle MCP usage and derives work mode from
      the selected route.
- [ ] The skill defines violation handling when implementation work occurs
      before the required orchestration gates.
- [ ] The skill aligns review-delegate naming with route-required
      `feature-reviewer` receipts.

## Constraints & Risks

- Keep changes scoped to the orchestrate skill unless validation identifies a
  required companion update.
- Preserve existing hard completion boundary requirements.
- Avoid weakening mandatory delegation or MCP validation requirements.
- Do not rely on prose alone for future enforcement; the skill should identify
  which gates are suitable for hooks or validators.

## Test Conditions to Consider

- [ ] Validate the updated skill text for internal consistency against
      `orchestrator-workflow` and `config/orchestration-routing.json`.
- [ ] Verify no remaining `feature-review` delegate references conflict with
      route-required `feature-reviewer` receipts.
- [ ] Verify the lifecycle order clearly places scope assessment before
      potential-entry creation and promotion.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/harden-orchestrate-skill/` folder from the template