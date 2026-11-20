# restore-pr-author-receipt-and-orchestrator-governance (Issue #261)

- Date captured: 2026-06-27
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/restore-pr-author-receipt-and-orchestrator-governance/ (Issue #261)

- Issue: #261
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/261
- Last Updated: 2026-06-28
- Work Mode: full-feature

## Problem / Why

Two orchestration-governance controls are currently in a weakened state in this repository and must be hardened.

1. PR-author provenance uses a forgeable authorization-sentinel model. The PreToolUse hook `enforce-pr-author-skill.ps1` currently gates `gh pr create` / `gh pr edit --body*` on a short-lived sentinel file `artifacts/pr_author_authorization.json` (`issued_by` / `issued_at` / `ttl_seconds`). The hook's own notes state the sentinel is "not a cryptographic or security control" and is forgeable by any actor with `Write(/artifacts/**)` access. The hardened model instead binds the PR body by content hash: a sibling SHA-256 receipt for `artifacts/pr_body_<N>.md`.

2. Remediation and CI governance risks being de-duplicated out of the always-loaded orchestrator agent definition (`.claude/agents/orchestrator.md`) into on-demand skills that may not be loaded. The agent contract must retain the remediation-loop checkpoint shape, the CI-monitoring/post-PR-remediation section (including the verbatim invariant that the orchestrator must not commit workflow-file changes outside the remediation loop), and the full Remediation Loop Protocol.

## Proposed Behavior

### Part A — SHA-256 receipt PR-author provenance
- `enforce-pr-author-skill.ps1` (PreToolUse) verifies, for a `gh pr create` / `gh pr edit --body-file` once the PR-context artifact exists, a sibling provenance receipt with ordered, specific deny reasons: PR_BODY_PATH_NONCANONICAL, PR_AUTHOR_RECEIPT_MISSING, PR_AUTHOR_RECEIPT_NUMBER_MISMATCH, PR_AUTHOR_RECEIPT_HASH_MISMATCH, PR_AUTHOR_RECEIPT_STALE. Existing shape blocks (inline --body, no body flag, --body-file with no context) are retained. The authorization-sentinel code path is removed. Filesystem/clock/hash access goes through injectable adapter seams. As a PreToolUse hook it emits deny via `hookSpecificOutput.permissionDecision='deny'`.
- `.claude/skills/orchestrate/SKILL.md`: the authoritative PR-author contract becomes the receipt handoff (`## PR Authoring (pr-author Handoff)`); the `## PR Creation Gate` lists six conditions, condition 5 being the receipt condition and condition 6 the CI-green gate. Any sentinel-as-gate "PR Creation Delegation" section is removed.
- `.claude/agents/orchestrator.md`: the PR section references the receipt handoff and points to the orchestrate skill as authoritative.
- Reconcile the pr-author agent and any `validate-pr-author-output` SubagentStop hook to the receipt model or remove sentinel assumptions.

### Part B — remediation + CI governance retained in the orchestrator agent
- `.claude/agents/orchestrator.md` retains `### Remediation Loop Checkpoint Shape`, `### CI Monitoring and Post-PR Remediation` (with the verbatim invariant "The orchestrator must not commit workflow-file changes outside the remediation loop."), and `## Remediation Loop Protocol` with its subsections (Prohibited Delegations, Required Artifacts Per Cycle, Preflight Sub-State Semantics, Scope-change Rule, Exit Gate, Citations).

## Acceptance Criteria (early draft)

- [x] `enforce-pr-author-skill.ps1` verifies the SHA-256 receipt and emits the five ordered deny reasons; the sentinel code path is removed; deny uses the PreToolUse `permissionDecision` shape.
- [x] No file references a forgeable PR authorization sentinel as the PR gate.
- [x] `## PR Creation Gate` in the orchestrate skill lists six conditions including the receipt condition; the orchestrator agent references the receipt handoff.
- [x] The orchestrator agent file contains the verbatim "must not commit workflow-file changes outside the remediation loop" invariant and the three governance sections.
- [x] Pester: pr-author hook tests cover all five receipt failure reasons plus the shape blocks; PoshQC format/analyze clean; 500-line cap respected.
- [x] Runtime files and all bundled mirrors (.claude, .codex, .agents, .github) remain in sync; bundle-parity contract tests pass.

## Constraints & Risks

- Cross-cutting change touching PowerShell hooks plus Markdown contracts and multiple ecosystem mirrors enforced by contract tests.
- 500-line file cap; PowerShell toolchain (PoshQC format -> PSScriptAnalyzer -> Pester); professional tonality.
- Must not weaken any SubagentStop hook.

## Test Conditions to Consider

- [ ] Receipt verification: canonical path, missing receipt, number mismatch, hash mismatch, staleness vs pr_context.summary.txt last-write.
- [ ] Retained shape blocks (inline --body, no body flag, --body-file without context).
- [ ] Grep proofs for the workflow-commit invariant and the six-condition PR gate.
- [ ] Bundle-parity contract tests across all mirrors.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create active feature folder from the template
