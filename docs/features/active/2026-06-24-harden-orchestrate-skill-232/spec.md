# 2026-06-24-harden-orchestrate-skill — Spec

- **Issue:** #232
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-24T15-45
- **Status:** Draft
- **Version:** 0.1

## Overview

The `orchestrate` skill currently states the overall orchestration lifecycle but
does not explicitly define the hardened pre-edit sequence needed to prevent an
agent from moving directly from policy reads into implementation. A recent
session demonstrated that a direct code edit can occur before scope assessment,
route selection, checkpoint state, and lifecycle setup are complete.

This feature hardens the orchestration instructions by making the required
sequence explicit across `.agents/skills/orchestrate/SKILL.md` and, where the
lifecycle contract owns branch behavior, `.agents/skills/feature-promotion-lifecycle/SKILL.md`.
The scope is requirements and instruction hardening only; no runtime command
surface or MCP protocol changes are expected.

## Behavior

Update `.agents/skills/orchestrate/SKILL.md` so it explicitly requires the
following sequence before any implementation edits, formatters, tests, staging,
commits, or implementation delegation:

- the already-active main session to serve as the canonical orchestrator runtime;
- read-only scope assessment and route selection before lifecycle MCP calls;
- pre-issue branch creation before potential-entry creation, using a slug-only
  branch name that does not require an issue number;
- checkpoint state with route metadata before implementation edits or delegated
  implementation;
- ordered lifecycle MCP calls after route selection and pre-issue branch setup;
- branch rename after issue promotion so the final branch includes the numeric
  issue number;
- clear pre-implementation and violation-handling gates;
- review delegate naming aligned with `config/orchestration-routing.json`.

The hardened flow is:

1. Read policy and applicable skills, then perform read-only scope assessment.
2. Select the route from `config/orchestration-routing.json` and derive
   `work-mode` from the selected route.
3. Persist route metadata to `artifacts/orchestration/orchestrator-state.json`,
   including `route_id`, `required_agents`, `required_skills`, and
   `required_mcp_tools`.
4. Create or verify the pre-issue branch before calling promotion MCP tools.
5. Run lifecycle MCP tools in order:
   `new_potential_entry` or `new_potential_bug_entry`,
   `potential_to_issue`, and `new_active_feature_folder`.
6. Rename the branch after promotion to include the returned issue number.
7. Confirm the pre-implementation gate before any implementation action.
8. Delegate review work to `feature-reviewer`, while treating `feature-review`
   as the review skill/workflow name where that distinction is needed.

Violation handling must require the orchestrator to stop, record a blocked
checkpoint state, and document remediation when implementation work begins
before route metadata, lifecycle readiness, or branch sequencing is complete.

## Inputs / Outputs

- Inputs:
  - User objective or active feature request.
  - `AGENTS.md` and applicable `.agents/skills/**/SKILL.md` policy files.
  - `.agents/skills/orchestrate/SKILL.md`.
  - `.agents/skills/feature-promotion-lifecycle/SKILL.md`.
  - `config/orchestration-routing.json`.
  - Current git branch name and workspace status.
  - MCP tool availability for `new_potential_entry`,
    `new_potential_bug_entry`, `potential_to_issue`, and
    `new_active_feature_folder`.
- Outputs:
  - Hardened instruction text in `.agents/skills/orchestrate/SKILL.md`.
  - Companion lifecycle wording in
    `.agents/skills/feature-promotion-lifecycle/SKILL.md` if needed to define
    pre-issue branch creation and post-promotion branch rename.
  - Updated checkpoint requirements for
    `artifacts/orchestration/orchestrator-state.json`, including route metadata
    before implementation and lifecycle operation receipts after MCP calls.
  - Clear violation-handling instructions for blocked checkpoint state and
    remediation reporting.
- Config keys and defaults:
  - `route_id` must be selected from `config/orchestration-routing.json`.
  - `required_agents`, `required_skills`, and `required_mcp_tools` must be copied
    exactly from the selected route.
  - `work-mode` is derived from the selected route: small route uses
    `minor-audit`; large feature route uses `full-feature`; large bug route uses
    `full-bug`.
- Versioning or backward-compatibility constraints:
  - Existing MCP tool names and payload shapes remain unchanged.
  - Existing validator-backed completion gates remain stricter than prose-only
    completion claims.
  - Existing active feature folders and already-correct issue-number branches
    remain valid; the new branch rule applies to new lifecycle starts and resume
    checks.

## API / CLI Surface

No new CLI command, flag, environment variable, or MCP API is introduced. The
change updates repository skill contracts consumed by Codex sessions.

- Example invocation:
  - User requests orchestration for a new feature.
  - The main session reads policy, performs read-only scope assessment, selects
    the `large` route, persists route metadata, creates a pre-issue branch,
    runs lifecycle MCP calls in order, renames the branch to include the issue
    number, and only then allows requirements, planning, or implementation work.
- Contracts and validation rules:
  - The main session is the orchestrator runtime; a named orchestrator profile is
    optional and cannot replace the active main session for downstream
    delegation.
  - Route selection and checkpoint metadata persistence must happen before
    lifecycle MCP calls.
  - Pre-issue branch creation must happen before potential-entry creation.
  - `potential_to_issue` must complete and return a numeric issue number before
    final branch rename or active feature folder creation.
  - `new_active_feature_folder` must not run before the numeric issue number is
    available.
  - The pre-implementation gate fails closed when checkpoint metadata, lifecycle
    readiness, branch state, or required MCP receipts are missing.
  - Required review delegation names must use `feature-reviewer` where route
    receipts are recorded; references to `feature-review` must be limited to the
    skill/workflow name.

## Data & State

The feature clarifies orchestration state rather than introducing a new data
store.

- Data transformations and invariants:
  - User objective plus read-only scope assessment produce a selected `route_id`.
  - The selected route produces exact `required_agents`, `required_skills`, and
    `required_mcp_tools` checkpoint values.
  - The selected route produces the persisted `work-mode`.
  - Pre-issue branch name is derived from `${promotion-type}` and
    `${short-name}` before issue creation.
  - Final branch name is derived from `${promotion-type}`, `${short-name}`, and
    the numeric `${issue-num}` returned by promotion.
  - Lifecycle operation records must identify MCP as the execution surface.
- Caching or persistence details:
  - The canonical checkpoint remains
    `artifacts/orchestration/orchestrator-state.json`.
  - Route metadata must be persisted before lifecycle MCP calls or
    implementation work.
  - Lifecycle MCP receipts must be persisted under the existing checkpoint
    receipt fields.
- Migration or backfill requirements:
  - No backfill is required for completed work.
  - Resume logic should validate the current branch and checkpoint state against
    the hardened gate before continuing.
  - If an existing in-progress run lacks the new gate evidence, it must stop in
    blocked state rather than continuing with implementation.

## Constraints & Risks

- Keep changes scoped to the orchestrate skill unless validation identifies a
  required companion update.
- Preserve existing hard completion boundary requirements.
- Avoid weakening mandatory delegation or MCP validation requirements.
- Do not rely on prose alone for future enforcement; the skill should identify
  which gates are suitable for hooks or validators.
- Do not modify MCP tool behavior as part of this feature unless a later
  implementation plan identifies an unavoidable validator gap.
- Keep branch sequencing compatible with resumed branches that already include
  the issue number.


## Implementation Strategy

- Implementation scope:
  - Update `.agents/skills/orchestrate/SKILL.md` with an entry-point contract,
    read-only assessment phase, route metadata persistence gate,
    pre-implementation gate, lifecycle order, violation handling, and
    `feature-reviewer` delegate naming.
  - Update `.agents/skills/feature-promotion-lifecycle/SKILL.md` if branch
    lifecycle details need to move from orchestrator prose into the canonical
    lifecycle source.
- New classes/functions/commands:
  - None expected.
- Dependency changes:
  - None expected.
- Logging/telemetry additions:
  - None expected beyond existing checkpoint fields and MCP receipt records.
- Rollout plan:
  - Apply instruction updates in the active feature branch.
  - Validate the changed Markdown for completed template text and internal
    consistency with `config/orchestration-routing.json`.
  - Run any repository markdown or validator checks selected by the final plan.
  - Research sufficiency: the existing issue file, routing matrix, and skill
    instructions are sufficient to complete this requirements spec without new
    research artifacts.

## Acceptance Criteria

- [x] `orchestrate` defines the already-active main session as the canonical
      orchestrator runtime and distinguishes that runtime from any optional
      orchestrator profile.
- [x] `orchestrate` requires read-only scope assessment and route selection
      before lifecycle MCP tools such as `new_potential_entry`,
      `potential_to_issue`, and `new_active_feature_folder`.
- [x] The lifecycle contract requires a pre-issue branch before
      potential-entry creation and a branch rename after promotion so the final
      branch includes the numeric issue number.
- [x] `orchestrate` requires checkpoint state with `route_id`,
      `required_agents`, `required_skills`, `required_mcp_tools`, and derived
      `work-mode` before implementation edits, formatters, tests, staging,
      commits, or implementation delegation.
- [x] Lifecycle MCP usage is ordered as route metadata persistence, pre-issue
      branch setup, potential entry creation, potential-to-issue promotion,
      post-promotion branch rename, and active feature folder creation.
- [x] Violation handling requires blocked checkpoint state and remediation
      documentation when implementation work occurs before required
      orchestration gates.
- [x] Review delegation naming uses `feature-reviewer` for route-required
      receipts and preserves `feature-review` only for the skill/workflow name.

## Definition of Done

- [x] Acceptance criteria in `spec.md` and `user-story.md` are concrete,
      testable, and mapped to planned validation.
- [x] `.agents/skills/orchestrate/SKILL.md` contains the hardened
      pre-implementation sequence and violation-handling gate.
- [x] `.agents/skills/feature-promotion-lifecycle/SKILL.md` is updated when
      branch lifecycle details are needed in the canonical lifecycle source.
- [x] Validation confirms no `feature-review` delegate references conflict with
      route-required `feature-reviewer` receipts.
- [x] Validation confirms lifecycle ordering places read-only scope assessment,
      route metadata persistence, and pre-issue branch creation before
      potential-entry creation.
- [x] Validation confirms no implementation edit path exists before checkpoint
      route metadata and lifecycle readiness are established.
- [x] Relevant Markdown, validator, or repository checks pass for the changed
      instruction files.

## Seeded Test Conditions (from potential)
- [x] Validate the updated skill text for internal consistency against
      `orchestrator-workflow` and `config/orchestration-routing.json`.
- [x] Verify no remaining review-delegate references use `feature-review` where
      the route-required receipt must be `feature-reviewer`.
- [x] Verify the lifecycle order clearly places read-only scope assessment and
      route metadata persistence before lifecycle MCP calls.
- [x] Verify pre-issue branch creation clearly occurs before potential-entry
      creation.
- [x] Verify branch rename after promotion clearly requires a numeric issue
      number before active feature folder creation.
