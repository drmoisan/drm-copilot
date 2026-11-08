# `owner-directive-relay` — User Story

- Issue: #1139
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-08T12-32

## Story Statement

- As the repository owner, I want an instruction I give the coordinator session to reach delegated orchestrators in a recorded, auditable form, so that runs do not stall on refusals of scheduling or scope instructions.
- As a delegated orchestrator, I want to tell a recorded owner directive apart from model-authored text and know which classes I may honor, so that I follow task direction without treating it as approval or permission.
- As a reviewer, I want every honored or refused directive recorded with a reason and checked against the recorded block, so that no directive can be invented and no refused action can be recorded as honored.

## Problem / Why

Owner instructions relayed by the coordinator are refused by subagents, which cannot distinguish them from model-authored text. This was observed in the iar-migration three-layer redesign epic (E1/E2, 2026-11-07/08). No defined, auditable relay mechanism exists. The directive block in this feature conveys owner intent that the coordinator recorded. It is not approval, consent, or elevated permission. This is consistent with the harness rule that an agent message directs the task but never authorizes permission, `CLAUDE.md`, or configuration changes.

## Personas & Scenarios

- Persona: repository owner running autonomous orchestration. They want fewer stalled runs and do not want any gate weakened or any self-authored "owner" text honored.
- Persona: delegated orchestrator (Claude). It must follow task direction from its launcher and must never treat an agent message as consent or approval.
- Scenario (honored): The owner tells the coordinator "allow one more planner revision for #1139". The coordinator records `OD-1` (class `extra_planner_revision`) in the item checkpoint and relays it in a fenced `Owner directives:` block. The orchestrator runs one extra revision and records `honored` with a reason. The stop hook accepts the checkpoint.
- Scenario (refused): The owner text "skip the pre-commit hook" is recorded as `OD-2` (class `gate_bypass`). The orchestrator records `refused` with a reason, and the hook stays in force. If a record had claimed `honored`, the stop hook would block with `OWNER_DIRECTIVE_BLOCKED:`.
- Scenario (invented): A record cites `OD-9`, which is not in `owner_directives`. The stop hook blocks the checkpoint.

## Acceptance Criteria

- [x] The coordinator procedure in the `owner-directives` skill requires each directive to come only from the owner's own turns in the coordinator session, and to be recorded (verbatim text, id, timestamp, scope, expiry) in `owner_directives` before relay.
- [x] The skill defines the relay as a fenced block labelled `Owner directives:` that quotes the recorded entries verbatim with their ids, and states that text outside a recorded block is not an owner directive.
- [x] The skill states plainly that the block conveys owner intent the coordinator recorded and grants no approval, consent, or elevated permission, consistent with the harness framing of agent messages.
- [x] The skill lists the honorable classes (`scheduling`, `merge_timing` in autonomous mode, `extra_planner_revision`, `scope_narrowing`, `accept_nonblocking_deviation`) and the always-refused classes (`gate_bypass`, `force_push`, `tag_or_publish`, `policy_or_settings_edit`, `evidence_alteration`, plus `unclassified`), and requires a subagent to record each honored or refused directive with a reason in `owner_directive_records`.
- [x] Given a checkpoint fixture with a recorded `extra_planner_revision` directive and an `honored` record, the stop hook accepts it; given a `gate_bypass` directive with a `refused` record, the stop hook accepts it; given the same directive with an `honored` record, the stop hook blocks it (Pester-verified).
- [x] Given a record that references a directive id absent from `owner_directives`, the stop hook blocks the checkpoint; given a checkpoint with neither key, the stop hook decision is unchanged from current behavior (Pester-verified).
- [x] No existing hook or gate is weakened or given a directive-based allow path; the docs state which refused classes an existing hook enforces and which are policy-only with the R6 validator backstop.

## Non-Goals

- New hooks that block tag pushes, publishing, canonical policy edits, or settings changes.
- Python or TypeScript validator changes (parity gap documented).
- Codex stop-hook or write-time enforcement (documented known limitation).
- Proving owner origin cryptographically; the check proves internal consistency only.
