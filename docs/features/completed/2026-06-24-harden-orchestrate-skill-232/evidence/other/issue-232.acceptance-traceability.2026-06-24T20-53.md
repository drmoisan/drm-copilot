Timestamp: 2026-06-24T20-53
Issue: #232

# Acceptance Traceability

## Completed Task Mappings

- P1-T1: Added the `orchestrate` entry-point contract defining the already-active main session as the canonical orchestrator runtime.
- P1-T2: Added the read-only intake and route-selection gate before lifecycle MCP calls.
- P1-T3: Added selected-route `${work-mode}` derivation and checkpoint persistence requirements.
- P1-T4: Added pre-issue branch creation before potential-entry creation.
- P1-T5: Added post-promotion branch rename before active feature folder creation.
- P1-T6: Added the pre-implementation gate before edits, formatters, tests, staging, commits, and implementation delegation.
- P1-T7: Added pre-implementation violation handling and blocked checkpoint state requirements.
- P1-T8: Updated orchestration-facing review delegation to use `feature-reviewer`.
- P2-T1: Added `${pre-issue-branch}` and `${final-branch}` lifecycle variables.
- P2-T2: Replaced promotion-before-branch lifecycle wording with the Issue #232 order.
- P2-T3: Limited MCP-only lifecycle requirements to MCP-backed lifecycle operations and recorded branch operations as checkpoint evidence.
- P2-T4: Updated the repo automation adapter feature-promotion chain to the Issue #232 order.
- P2-T5: Updated small-path lifecycle preconditions.
- P2-T6: Updated large-path lifecycle preconditions.
- P2-T7: Added checkpoint fields for branch sequencing and pre-implementation violation state.
- P2-T8: Updated orchestrator workflow completion gates and hard constraints.

## Evidence Paths

- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/baseline/phase0-instructions-read.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/baseline/phase0-requirements-read.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/baseline/baseline-git-status.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/baseline/baseline-review-delegate-naming.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/baseline/baseline-lifecycle-order.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/baseline/baseline-route-matrix.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.2026-06-24T20-53.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/qa-gates/final-git-diff-check.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/qa-gates/final-review-delegate-naming.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/qa-gates/final-lifecycle-order.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/qa-gates/final-pre-implementation-gate.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/qa-gates/final-branch-sequencing.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/qa-gates/final-plan-validator.md`
- `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/qa-gates/final-git-status.md`

## `spec.md` Acceptance Criteria Mapping

- Entry-point contract: P1-T1, P3-T1. Evidence: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.2026-06-24T20-53.md`.
- Read-only scope assessment and route selection before lifecycle MCP tools: P1-T2, P1-T3, P3-T1. Evidence: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.2026-06-24T20-53.md`.
- Lifecycle pre-issue branch and post-promotion branch rename: P1-T4, P1-T5, P2-T1, P2-T2, P2-T4, P2-T5, P2-T6, P2-T8, P3-T1. Evidence: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.2026-06-24T20-53.md`.
- Checkpoint state and derived work mode before implementation actions: P1-T3, P1-T6, P2-T7, P2-T8, P3-T1. Evidence: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.2026-06-24T20-53.md`.
- Ordered lifecycle MCP usage: P1-T3, P1-T4, P1-T5, P2-T2, P2-T3, P2-T4, P2-T5, P2-T6, P2-T8, P3-T1. Evidence: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.2026-06-24T20-53.md`.
- Violation handling for premature implementation work: P1-T7, P2-T7, P2-T8, P3-T1. Evidence: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.2026-06-24T20-53.md`.
- Review delegation naming aligned to `feature-reviewer`: P1-T8, P3-T1. Evidence: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.2026-06-24T20-53.md`.

## `user-story.md` Acceptance Criteria Mapping

- Entry-point contract: P1-T1, P3-T1. Evidence: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.2026-06-24T20-53.md`.
- Read-only scope assessment and route selection before lifecycle MCP tools: P1-T2, P1-T3, P3-T1. Evidence: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.2026-06-24T20-53.md`.
- Lifecycle pre-issue branch and post-promotion branch rename: P1-T4, P1-T5, P2-T1, P2-T2, P2-T4, P2-T5, P2-T6, P2-T8, P3-T1. Evidence: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.2026-06-24T20-53.md`.
- Pre-implementation gate before implementation actions: P1-T6, P2-T7, P2-T8, P3-T1. Evidence: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.2026-06-24T20-53.md`.
- Ordered lifecycle MCP usage and derived `work-mode`: P1-T3, P1-T4, P1-T5, P2-T2, P2-T3, P2-T4, P2-T5, P2-T6, P3-T1. Evidence: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.2026-06-24T20-53.md`.
- Violation handling for premature implementation work: P1-T7, P2-T7, P2-T8, P3-T1. Evidence: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.2026-06-24T20-53.md`.
- Review delegation naming aligned to `feature-reviewer`: P1-T8, P3-T1. Evidence: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.2026-06-24T20-53.md`.
- Companion lifecycle skill update: P2-T1, P2-T2, P2-T3, P2-T4, P2-T5, P2-T6, P2-T8, P3-T1. Evidence: `docs/features/active/2026-06-24-harden-orchestrate-skill-232/evidence/other/issue-232.acceptance-traceability.2026-06-24T20-53.md`.
