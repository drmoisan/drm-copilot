---
name: feature-review
description: 'Review a feature branch relative to a base branch and write audit artifacts into the active feature folder. Use when Codex must produce policy, code, and feature audits and trigger remediation planning when needed.'
---

# Feature Review

Workflow skill for PR-style feature review in Codex.

## Required Shared Skills

Always apply:
- `policy-compliance-order`
- `evidence-and-timestamp-conventions`
- `policy-audit-template-usage`
- `pr-context-artifacts`
- `acceptance-criteria-tracking`
- `remediation-handoff-atomic-planner`

Use as needed:
- `pr-base-branch-merge-base`
- `repo-automation-adapter`

## Role

- Review the feature branch relative to the correct base.
- Produce audit-grade artifacts, not code fixes.
- Prefer deterministic evidence from PR-context artifacts and exact diff anchors.
- Trigger remediation planning when blockers or unmet acceptance criteria exist.

## Required Outputs

Write timestamped artifacts into the active feature folder:
- `policy-audit.<timestamp>.md`
- `code-review.<timestamp>.md`
- `feature-audit.<timestamp>.md`
- `remediation-inputs.<timestamp>.md` only when the aggregate review result permits an autonomous remediation handoff
- `remediation-plan.<timestamp>.md` only when the aggregate review result permits an autonomous remediation handoff

The final review report MUST end with these exact single-line fields:
- `REVIEW_VERDICT: PASS` or `REVIEW_VERDICT: BLOCKED`
- `REMEDIATION_ACTION: NONE`, `AUTONOMOUS`, `NO_CANDIDATE`, `EXTERNAL_RUNTIME`, `AWAITING_CI`, or `HUMAN_DECISION`
- `BLOCKER_FINGERPRINT: NONE` or `BLOCKER_FINGERPRINT: sha256:<64-lowercase-hex>`
- `FEATURE_FOLDER: <path>`
- `POLICY_AUDIT: <path>`
- `CODE_REVIEW: <path>`
- `FEATURE_AUDIT: <path>`
- `REMEDIATION_INPUTS: <path-or-NONE>`
- `REMEDIATION_PLAN: <path-or-NONE>`

Each required review artifact MUST pass the matching validator command before review can be reported as complete:
- the `validate_orchestration_artifacts` MCP tool with `artifact_type: "policy-audit"` and `artifact_path: <path>`
- the `validate_orchestration_artifacts` MCP tool with `artifact_type: "code-review"` and `artifact_path: <path>`
- the `validate_orchestration_artifacts` MCP tool with `artifact_type: "feature-audit"` and `artifact_path: <path>`

## Review Flow

1. Resolve the base branch.
   - Use the supplied base when present.
  - If the supplied base is missing or ambiguous, use `pr-base-branch-merge-base`.
  - Do not default to the repository default branch unless merge-base resolution fails for all candidates.
2. Load PR context from the canonical artifacts defined by `pr-context-artifacts`.
3. If PR context is missing or stale, refresh it through `repo-automation-adapter` using the resolved base branch.
4. Determine the active feature folder deterministically from the scoping docs and PR context.
5. Create the policy audit, code review, and feature audit.
   - validate each artifact immediately after writing it
6. Check off passing acceptance criteria in the authoritative requirement sources per `acceptance-criteria-tracking`.
7. Aggregate every known blocking finding from the completed policy audit, code review, and feature audit before deriving any terminal result field.
   - Do not return after the first failing audit, toolchain failure, blocking code finding, or unmet acceptance criterion.
   - Do not compute or emit a fingerprint from a partial audit or any blocker subset.
8. If the aggregate result permits autonomous remediation, create remediation inputs first and then hand off plan creation using `remediation-handoff-atomic-planner`.
9. In the final report, emit the canonical aggregate result and include every required artifact-path field exactly once.

### Canonical Aggregate Review Result

Complete and validate the policy audit, code review, and feature audit before emitting any of the five terminal result fields. Normalize every known blocking finding to stable `audit_kind`, `rule_id`, workspace-relative `path`, and `message` values; sort the complete set deterministically; and compute one SHA-256 fingerprint over its UTF-8 canonical JSON. Exclude timestamps, generated artifact names, and discovery order. A fingerprint computed before all three audits are complete, or from an early-return subset, is invalid.

Use this exact enum and path grammar:

```text
REVIEW_VERDICT: PASS | BLOCKED
REMEDIATION_ACTION: NONE | AUTONOMOUS | NO_CANDIDATE | EXTERNAL_RUNTIME | AWAITING_CI | HUMAN_DECISION
BLOCKER_FINGERPRINT: NONE | sha256:<64-lowercase-hex>
REMEDIATION_INPUTS: <feature-local-path> | NONE
REMEDIATION_PLAN: <feature-local-path> | NONE
```

`NONE` is the literal uppercase token. A feature-local path MUST resolve beneath the active feature folder. `PASS` uses `BLOCKER_FINGERPRINT: NONE`; `BLOCKED` uses the fingerprint of the complete aggregated blocker set.

Preserve the review-level pre-R4 no-delta terminal architecture: when the complete aggregate is blocked but yields no actionable repository candidate, emit `BLOCKED` with `NO_CANDIDATE` and both remediation paths as `NONE`. This result terminates before R1, creates no remediation plan, and consumes neither a remediation attempt nor a completed cycle.

### Verdict/Action/Path and Remediation-Handoff Matrix

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

### Enforced Remediation Handoff Contract

Only for a matrix-valid `BLOCKED` plus `AUTONOMOUS` result:

- create `remediation-inputs.<timestamp>.md` before any remediation planning handoff,
- create the remediation plan target file on disk before delegating plan creation,
- automatically delegate remediation planning to `atomic-planner`,
- treat `remediation-inputs.<timestamp>.md` as the primary requirements source,
- include the canonical PR-context summary and appendix, the review artifacts, and the original feature plan file(s) in the delegated context package,
- if the remediation planning handoff cannot be started or does not return a receipt, stop and report blocked state,
- do not claim review completion until the remediation plan file exists on disk.

## Required Artifact Shapes

- `policy-audit.<timestamp>.md`
  - MUST be copied from the canonical template and MUST NOT retain the template instruction block.
  - MUST contain the canonical major headings and Appendix B command reference.
- `code-review.<timestamp>.md`
  - MUST contain `## Executive Summary`.
  - MUST contain `## Findings Table`.
  - MUST contain a Markdown table header with `Severity | File | Location | Finding | Recommendation | Rationale | Evidence`.
- `feature-audit.<timestamp>.md`
  - MUST contain `## Scope and Baseline`.
  - MUST contain `## Acceptance Criteria Inventory`.
  - MUST contain `## Acceptance Criteria Evaluation`.
  - MUST contain `## Summary`.
  - MUST contain `## Acceptance Criteria Check-off`.

## Review Constraints

- Do not silently fix code during review.
- Prefer check-only commands.
- If a tool cannot be run, mark the related section as unverified or partial with a concrete reason.
- Do not claim completion until every required artifact exists on disk and its validator passes.
- Do not omit any required final result field from the review report.
