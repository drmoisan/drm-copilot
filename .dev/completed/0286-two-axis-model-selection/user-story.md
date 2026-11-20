# `two-axis-model-selection` — User Story

- Issue: #286
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-07-03
- Work Mode: full-feature

## Story Statement

- As an orchestration maintainer, I want model-tier selection driven by a judgment-based `complexity_band` that is separate from the file-count-driven `route`, so that a small but hard change can be assigned a capable model and a large but mechanical change is not over-provisioned.
- As an orchestration maintainer, I want deterministic floors and a table-plus-clamp resolution recorded as auditable receipts, so that every model choice is reproducible and reviewable and cannot silently exceed the session's `fable_policy` budget.
- As a cost-conscious operator, I want low-complexity commit-message generation and exception-runbook authoring delegated to smaller-tier agents (`haiku`, `sonnet`), so that situational tasks do not consume the orchestrator's more capable and costly model.

## Problem / Why

The orchestration runtime selects a workflow `route` (small, large, remediation, epic) deterministically by file count. File count is a size measure, not a complexity measure: a one-file classifier-logic change can be harder to reason about than a fifteen-file rename. The runtime has no mechanism to select the delegation model tier as a function of judged task complexity, so model tier is either fixed by frontmatter pins or coupled implicitly to size. In addition, two low-complexity skill invocations (`commit-message` and `human-exception-runbook`) currently run inline on the orchestrator's model, which is more capable and costly than those situational tasks require.

## Personas & Scenarios

- **Persona: Orchestration maintainer.**
  - Who: an engineer who maintains the Claude Code orchestration runtime and its checkpoint contract.
  - What they care about: deterministic, auditable model selection; a clean separation between workflow governance and model governance; backward compatibility for existing checkpoints.
  - Constraints: changes must be additive; existing routes and checkpoints must validate unchanged; bundle mirrors must stay in lockstep.
  - Goals and frustrations: wants model tier to reflect judged difficulty rather than file count; frustrated that today model tier is coupled to size or pinned in frontmatter.
  - Context and motivations: reviews orchestration checkpoints and needs receipts that make each model choice reproducible.

- **Scenario: Assessing a small but complex change.**
  - Who is acting: the orchestrator (and the maintainer reviewing its checkpoint).
  - Trigger: a one-file change to classifier logic enters the pipeline as `route == small`.
  - Steps: the orchestrator assesses `complexity_band` from the signal catalog; a `[floor]` signal is present, so `compute_complexity_floor` yields a `C3` floor; the assessed band is `C3`, satisfying `band >= floor`; `resolve_delegation_model` maps `C3` to `opus` under the default `disabled` policy; a `complexity_assessments[]` entry and a `model_routing_receipts[]` entry are recorded.
  - Obstacles/decisions: the maintainer confirms `route` did not influence the model choice and that the floor was not exceeded.
  - Expected outcome: a capable model is assigned to a small-but-hard change, with an auditable, reproducible receipt.

- **Scenario: Enabling the fable budget for reasoning nodes.**
  - Who is acting: an operator kicking off a session.
  - Trigger: the operator sets `model_budget.fable_policy: preferred` at session kickoff.
  - Steps: for a C3 phase delegated to `atomic-planner`, `prd-feature`, `feature-review`, or `task-researcher`, the `preferred_overlay` resolves the model to `fable`; for the same C3 phase delegated to `atomic-executor` or `pr-author`, the model remains `opus`; each choice is recorded in a routing receipt.
  - Obstacles/decisions: the operator confirms the overlay applies only to the four reasoning agents at C3.
  - Expected outcome: reasoning-heavy nodes use the higher tier only when the budget explicitly permits it; the default `disabled` policy clamps any `fable` cell to `opus` with a recorded `clamped_from: "fable"`.

- **Scenario: Delegating situational tasks to smaller tiers.**
  - Who is acting: the orchestrator at a commit point and at an exception path.
  - Trigger: a pre-review commit and a human-exception runbook emission.
  - Steps: the orchestrator delegates commit-message generation to `Agent(commit-message)` (`haiku`) and keeps `git commit` on itself; for the exception path it delegates runbook authoring to `Agent(human-exception-runbook)` (`sonnet`) and records the returned `runbook_path`.
  - Expected outcome: low-complexity work runs on smaller-tier agents while the orchestrator retains control of the commit and the checkpoint record.

## Acceptance Criteria

### WS1 — Model-selection machinery

- [x] `route` is not a model-selection input anywhere in config, reference implementations, validators, or skill documentation; `complexity_band` is the sole feature-level input to model tier.
- [x] `config/orchestration-routing.json` contains a `model_policy` block (`complexity` sub-block with scale text, signal catalog with `[floor]` flags, and anchors; `tier_order`; `complexity_to_model`; `preferred_overlay`) and a `model_budget.fable_policy` switch defaulting to `disabled`.
- [x] `compute_complexity_floor` is deterministic: each `[floor]` guard contributes `C3`, `floor` is the maximum triggered band, floors never exceed `C3`, and C4 is never floor-forced; the assessed band is always `>= floor`.
- [x] `resolve_delegation_model` is deterministic: the resolved model equals the `complexity_to_model` lookup under the active `fable_policy`; in `disabled` mode no receipt's model is `fable` and any `fable` cell records a clamp to `opus` (`clamped_from: "fable"`); in `preferred` mode the four reasoning agents' C3 resolves to `fable` while `atomic-executor`/`pr-author` are unchanged.
- [x] The complexity and model-routing validators pass on well-formed receipts and fail closed on band/floor/rationale/enum/budget violations with literal, checkpoint-context messages; routes and checkpoints lacking the new fields validate unchanged.
- [x] The two validators are wired into the Python `validate_orchestration_artifacts` path via key-gated blocks inside `validate_orchestrator_state_text`.
- [x] The `orchestrate` and `epic-orchestrate` skills each document model selection and the `model_budget.fable_policy` kickoff marker.

### WS2 — `commit-message` agent

- [x] `.claude/agents/commit-message.md` exists (`model: haiku`, read-only tools), is valid, and is authorized as `Agent(commit-message)` in the orchestrator allowlist.
- [x] Both commit points in `orchestrate/SKILL.md` delegate message text to `Agent(commit-message)` while `git commit` stays on the orchestrator.

### WS3 — `human-exception-runbook` agent

- [x] `.claude/agents/human-exception-runbook.md` exists (`model: sonnet`), is valid, and is authorized as `Agent(human-exception-runbook)` in the orchestrator allowlist.
- [x] The exception-runbook path delegates authoring to `Agent(human-exception-runbook)` while the orchestrator still records `runbook_path`.

### Cross-cutting

- [x] All new fields are additive and optional; existing routes and checkpoints validate unchanged.
- [x] Bundle sync is complete; pytest and Pester are green.

## Non-Goals

- `route` remains file-count driven and is never made model-aware.
- No JSON Schema file is introduced for `config/orchestration-routing.json`; enforcement is prose plus validator code.
- The reference implementations are not wired into a runtime call path; they are canonical, tested formulas applied by judgment and documented in the skills.
- The TypeScript MCP-port validators are not updated in this feature (deferred to a follow-up; see spec Design Decision DD-1 and Risks).
- Codex/`.agents` TOML agent wrappers for the two new agents are not authored in this feature.
- No callable MCP documentation tool is added for the runbook agent's MCP-first sourcing clause.
