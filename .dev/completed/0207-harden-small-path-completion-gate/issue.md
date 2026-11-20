# harden-small-path-completion-gate (Issue #207)

- Date captured: 2026-06-19
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/harden-small-path-completion-gate/ (Issue #207)

- Issue: #207
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/207
- Last Updated: 2026-06-19
- Work Mode: minor-audit

## Problem / Why

A small-path orchestration run (issue #205) recorded a checkpoint asserting completion
(`next_step: "complete"`, step8/9/10 = complete) while the supporting evidence did not exist:
no promotion, no feature folder, no plan, no commit, no feature-review artifacts, no PR, and no
CI gate. The false-complete passed because the orchestration completion gate is not enforced for
the main-session orchestrator:

- The completion gate `.claude/hooks/validate-orchestrator-output.ps1` is registered only as a
  `SubagentStop` hook scoped to the `orchestrator` subagent. The orchestrate skill runs the
  orchestrator in the main session, where `SubagentStop` does not fire, so the gate never runs.
- Even when it runs, the gate validates only structural fields (objective, completed_steps,
  next_step, last_updated, human_interaction shape). It does not verify that a checkpoint asserting
  completion is backed by the required small-path evidence (promotion variables, review artifacts,
  PR, populated `ci_gate`).
- The monotonic-order hook treats non-canonical `completed_steps` entries as informational, so an
  ad-hoc step vocabulary makes it a no-op, and it never requires predecessors of `S12_complete`.

## Proposed Behavior

Add a `PreToolUse` completion-consistency gate on writes to
`artifacts/orchestration/orchestrator-state.json`. PreToolUse fires in the main session, so it
covers main-session orchestration. When a written checkpoint asserts completion (for example
`next_step == "complete"` / `S12_complete` present / any of step8-10 == `completed`), the gate
blocks the write unless the checkpoint carries verifiable completion evidence:

- non-empty canonical `issue-num` and `feature-folder`;
- a populated `ci_gate` with `conclusion == "success"` and a non-empty `head_sha`;
- a recorded PR reference.

The gate must fail closed (block on assertion-without-evidence) and stay backward-compatible
(no effect on checkpoints that do not assert completion).

## Acceptance Criteria

- [x] A new `PreToolUse` hook activates only for writes to `artifacts/orchestration/orchestrator-state.json`.
- [x] When the written checkpoint asserts completion without a populated `ci_gate.conclusion == "success"`, a non-empty `issue-num`, and a non-empty `feature-folder`, the hook blocks the write with a specific reason.
- [x] When the written checkpoint asserts completion and all required evidence fields are present, the hook allows the write.
- [x] A checkpoint that does not assert completion is always allowed (backward compatibility).
- [x] The hook is registered in `.claude/settings.json` under `PreToolUse` for `Write|Edit`.
- [x] Pester tests cover the block path, the allow-on-evidence path, and the backward-compatible non-assertion path.

## Constraints & Risks

- Must not break existing valid checkpoints (additive, fail-closed only on completion assertion).
- PowerShell 7+, PSScriptAnalyzer clean, follows the existing hook structure (dot-source guard, mockable IO seam).

## Test Conditions to Consider

- [ ] Unit coverage areas: assertion detection, evidence presence checks, path matching, Edit vs Write handling
- [ ] Integration scenarios: a completion-asserting checkpoint with and without ci_gate
- [ ] CLI/API examples: hook invoked via CLAUDE_TOOL_INPUT JSON

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/harden-small-path-completion-gate/` folder from the template