# Remediation Inputs: harden-orchestrate-skill (Issue #232)

Timestamp: 2026-06-25T07-45
Issue: #232
Branch: feature/harden-orchestrate-skill-232
Feature Folder: docs/features/active/2026-06-24-harden-orchestrate-skill-232
Rejected Review Artifacts:
- docs/features/active/2026-06-24-harden-orchestrate-skill-232/policy-audit.2026-06-25T07-28.md
- docs/features/active/2026-06-24-harden-orchestrate-skill-232/code-review.2026-06-25T07-28.md
- docs/features/active/2026-06-24-harden-orchestrate-skill-232/feature-audit.2026-06-25T07-28.md

## Rejection Basis

The prior review outcome is rejected as a hard failure because it treated instruction-level hardening as sufficient even though the repository already has executable hook, validator, MCP exposure, and checkpoint validation surfaces relevant to Issue #232. Remediation must convert the affected gates into executable enforcement where the repository already supports that enforcement path.

All remediation artifacts, evidence, issue references, and branch references must use Issue #232, branch `feature/harden-orchestrate-skill-232`, and active folder `docs/features/active/2026-06-24-harden-orchestrate-skill-232`.

## Required Remediation Findings

### Finding 1: Pre-implementation gates remain instruction-level only

The prior branch documents read-only scope assessment, route metadata, checkpoint state, lifecycle readiness, and pre-implementation gates in `.agents/skills/orchestrate/SKILL.md`, but it does not add an executable gate that blocks implementation edits, formatters, tests, staging, commits, or implementation delegation when checkpoint route metadata and lifecycle readiness are absent.

Required remediation:
- Add executable hook enforcement for pre-implementation gate violations where repository hook support exists.
- Add tests that demonstrate a blocked write or command when Issue #232 route metadata, lifecycle readiness, or checkpoint state is missing.
- Preserve canonical paths and issue number 232 in all evidence.

### Finding 2: Lifecycle and branch sequencing are not validated as completion gates

The prior branch documents pre-issue branch creation, `potential_to_issue`, numeric issue resolution, final branch rename, and active folder creation order, but completion validation does not reject out-of-order or incomplete lifecycle evidence for the current Issue #232 branch.

Required remediation:
- Add checkpoint validation rules that fail closed when the state asserts completion without canonical lifecycle receipts and branch evidence for Issue #232.
- Add hook or validator tests for invalid ordering and missing branch evidence.

### Finding 3: MCP-only workflow failure paths can still be treated as successful fallbacks

The prior policy audit records that the MCP template resolver was not exposed and that a bundled template path was used instead. The artifact was still treated as PASS. This is invalid for the requested remediation scope.

Required remediation:
- Ensure `resolve_policy_audit_template_asset` is exposed through the MCP bridge and remains listed in repo automation tool definitions.
- Add validator enforcement that rejects policy-audit artifacts that report missing MCP template resolver exposure while still declaring PASS or review readiness.
- Add hook or validator coverage that prevents fallback review artifact generation from being treated as PASS.

### Finding 4: PR creation and live CI status are not required before DONE

The prior review states that no PR exists and CI status is unavailable, then recommends normal PR flow. The checkpoint validator does not currently require PR and current-head CI evidence before a complete state is accepted.

Required remediation:
- Extend checkpoint completion validation to require PR evidence and live CI evidence for the current PR head.
- Ensure `ci_gate.head_sha` and PR head evidence match the current branch head before DONE can be accepted.
- Add regression tests for missing PR evidence, missing CI evidence, stale CI head SHA, and non-success CI conclusion.

## Authoritative Requirements

The remediation plan must:
- Use atomic `[P#-T#]` tasks.
- Identify exact files to edit.
- Identify exact tests and validations to run.
- Include acceptance criteria evidence updates under `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/`.
- Include baseline and final QA evidence for Python, TypeScript, and PowerShell because the remediation touches Python validators, TypeScript MCP exposure, and PowerShell hook enforcement.
- Fail closed when required MCP workflow tools or template resolvers are not exposed.
- Keep Issue #232, branch `feature/harden-orchestrate-skill-232`, and the active feature folder canonical.
