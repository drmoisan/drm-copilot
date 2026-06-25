# `2026-06-24-harden-orchestrate-skill` — User Story

- Issue: #232
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-06-24T15-45

## Story Statement

- As an orchestrating agent, I want the required pre-implementation sequence
  stated explicitly, so that I cannot proceed from policy reads into edits before
  route selection, checkpoint state, branch setup, and lifecycle MCP readiness
  are complete.
- As a repository maintainer, I want the orchestration and lifecycle skills to
  use the same branch and review-delegate contract, so that future sessions
  produce route-valid receipts and issue-numbered branches consistently.

## Problem / Why

The `orchestrate` skill currently states the overall orchestration lifecycle but
does not explicitly define the hardened pre-edit sequence needed to prevent an
agent from moving directly from policy reads into implementation. A recent
session demonstrated that a direct code edit can occur before scope assessment,
route selection, checkpoint state, and lifecycle setup are complete.


## Personas & Scenarios

- Persona: Repository maintainer
  - Maintains the Codex orchestration skill surface and expects agent sessions
    to follow deterministic promotion, planning, execution, and review gates.
  - Cares about reproducible route selection, checkpoint evidence, branch names,
    and review receipts.
  - Is constrained by existing MCP tool contracts, the canonical checkpoint path,
    and the routing matrix in `config/orchestration-routing.json`.
  - Wants future changes to fail closed when orchestration setup is incomplete
    instead of allowing untracked implementation work.
- Persona: Orchestrating agent session
  - Runs as the already-active main session and coordinates downstream
    specialists.
  - Must distinguish read-only assessment from lifecycle automation and
    implementation.
  - Needs explicit stop conditions when branch state, route metadata, lifecycle
    receipts, or delegate names do not match policy.
- Scenario: New full-feature request
  - A user asks the active session to deliver a new feature.
  - The session reads policy, performs read-only scope assessment, selects the
    large route, and persists route metadata to the canonical checkpoint.
  - Before creating a potential entry, the session creates or verifies a
    pre-issue branch based on the selected promotion type and short name.
  - The session calls lifecycle MCP tools in order, promotes the potential entry
    to an issue, renames the branch to include the returned issue number, creates
    the active feature folder, and verifies the pre-implementation gate.
  - If any step is missing or out of order, the session records blocked state
    and stops instead of editing implementation files.
  - After implementation, the session delegates review to `feature-reviewer` so
    route-required receipts match the routing matrix.


## Acceptance Criteria

- [x] The skill defines an entry-point contract that identifies the already-active main session as the orchestrator runtime and distinguishes that runtime from any optional orchestrator profile.
- [x] The skill requires read-only scope assessment and route selection before lifecycle MCP tools such as `new_potential_entry`, `potential_to_issue`, and `new_active_feature_folder`.
- [x] The lifecycle contract requires pre-issue branch creation before potential-entry creation and branch rename after promotion so the final branch includes the numeric issue number.
- [x] The skill defines a pre-implementation gate requiring matching checkpoint state, route metadata, and lifecycle readiness before edits, formatters, tests, staging, commits, or implementation delegation.
- [x] The skill defines ordered lifecycle MCP usage and derives `work-mode` from the selected route.
- [x] The skill defines violation handling when implementation work occurs before the required orchestration gates.
- [x] The skill aligns review-delegate naming with route-required `feature-reviewer` receipts while preserving `feature-review` as the skill/workflow name.
- [x] The companion lifecycle skill is updated when branch sequencing belongs in `feature-promotion-lifecycle` rather than only in `orchestrate`.


## Non-Goals

- Changing MCP tool names, payload shapes, or server implementation.
- Changing `config/orchestration-routing.json` route membership unless later
  validation identifies an actual matrix defect.
- Editing implementation source files outside the two orchestration instruction
  skills.
- Creating new research artifacts for Issue #232.
- Rewriting unrelated orchestration, review, or remediation requirements.
