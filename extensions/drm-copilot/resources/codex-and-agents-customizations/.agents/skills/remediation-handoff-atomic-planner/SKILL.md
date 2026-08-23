---
name: remediation-handoff-atomic-planner
description: 'Reusable remediation trigger and atomic_planner handoff steps. Use when audits require remediation inputs and a delegated remediation plan.'
---

# Remediation Handoff to atomic_planner

Shared remediation workflow and handoff expectations for agents that delegate to `atomic_planner`.

## When to Use This Skill

Use this skill only when the aggregate review result is `BLOCKED` plus `AUTONOMOUS`, its complete blocker set has an actionable repository-remediable disposition, and both remediation paths resolve beneath the active feature folder.

## Canonical Review Result Grammar

```text
REVIEW_VERDICT: PASS | BLOCKED
REMEDIATION_ACTION: NONE | AUTONOMOUS | NO_CANDIDATE | EXTERNAL_RUNTIME | AWAITING_CI | HUMAN_DECISION
BLOCKER_FINGERPRINT: NONE | sha256:<64-lowercase-hex>
REMEDIATION_INPUTS: <feature-local-path> | NONE
REMEDIATION_PLAN: <feature-local-path> | NONE
```

## Verdict/Action/Path and Remediation-Handoff Matrix

Validate the aggregate result against this exact matrix before creating remediation artifacts or delegating planning:

| Review verdict | Remediation action | `REMEDIATION_INPUTS` | `REMEDIATION_PLAN` | Required handling |
|---|---|---|---|---|
| `PASS` | `NONE` | `NONE` | `NONE` | Accept the review result; do not delegate `atomic-planner`. |
| `BLOCKED` | `AUTONOMOUS` | `<feature-local-path>` | `<feature-local-path>` | Permit `atomic-planner` handoff only when the complete blocker set has an actionable, repository-remediable disposition. |
| `BLOCKED` | `NO_CANDIDATE` | `NONE` | `NONE` | Stop for the non-remediable or no-delta disposition; do not delegate `atomic-planner`. |
| `BLOCKED` | `EXTERNAL_RUNTIME` | `NONE` | `NONE` | Stop for external-runtime remediation; do not delegate `atomic-planner`. |
| `BLOCKED` | `AWAITING_CI` | `NONE` | `NONE` | Wait for CI or other external state; do not delegate `atomic-planner`. |
| `BLOCKED` | `HUMAN_DECISION` | `NONE` | `NONE` | Stop for a human decision; do not delegate `atomic-planner`. |

Every combination not listed in the matrix is invalid and MUST fail closed without creating either remediation artifact or delegating a planner. Only `BLOCKED` plus `AUTONOMOUS`, with both paths resolving beneath the active feature folder and an actionable remediable disposition, permits remediation artifact creation and `atomic-planner` delegation.

## Trigger Conditions (Generic)

The following findings make the aggregate review `BLOCKED`; they do not by themselves authorize a planner handoff:
- Audit artifacts contain FAIL or meaningful PARTIAL findings.
- Toolchain checks fail.
- Acceptance criteria are not met.

## Required Remediation Inputs

For a matrix-valid autonomous result, create the feature-local `remediation/<timestamp>/remediation-inputs.md` (one timestamped `remediation/` folder per cycle; re-audit artifacts from a triggering or exit review live under the sibling `audit/<timestamp>/` folder) with:
- Enumerated fix list with file paths, expected behavior, and verification commands.
- A “do not do” list (no scope creep, no policy weakening, no silent skips).

## Plan Creation and Handoff

1) Create a remediation plan target file using the repo’s plan template.
2) Delegate to `atomic_planner` with:
   - `${spec}` pointing to remediation inputs (authoritative)
   - `${file}` pointing to the remediation plan target file
3) Require `atomic_planner` to output a deterministic, atomic plan with phases and `[P#-T#]` IDs.
4) Require the same `${file}` path to be updated in place across all remediation-plan revisions in the same remediation loop.
5) The caller owns the downstream clearance loop:
   - hand the resulting remediation plan to `atomic_executor` in preflight-validation mode,
   - if preflight returns `PREFLIGHT: REVISIONS REQUIRED`, re-delegate to `atomic_planner` against the same `${file}` path,
   - execute the remediation plan only after `PREFLIGHT: ALL CLEAR`.

## Context Package (When Required)

If the calling agent requires a context package, inline the specified audit artifacts, PR context artifacts, and any relevant plan files in the delegated prompt.
