# `2026-02-23-minor-audit-planning` — User Story

- Issue: #58
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-02-23T13-54

## Story Statement

- As a feature author using `generate-atomic-plan`, I want work mode (`minor-audit` or `full`) to be resolved deterministically from the feature context, so that the generated plan and follow-on prompts enforce the same governance path.
- As an execution operator using hard-lock/resume flows, I want execute and resume prompt resolution to consume the same mode + plan-path contract, so that resumed execution cannot drift from the original plan intent.

## Problem / Why

Current planning/execution tooling does not consistently model the selected work mode (`minor-audit` vs `full`) across agent prompts, generated atomic plans, and resume/hard-lock prompt resolution. This creates drift between feature intent and execution behavior, especially when users need a lighter audit path for small changes but strict full-process handling for larger scope work. We need deterministic, mode-aware routing so planning, prompt resolution, and execution all use the same source of truth and fail closed safely.


## Personas & Scenarios

- Persona: Repository maintainer coordinating mixed-scope changes through Copilot agents
  - Who the user is: A maintainer who runs prompt-generation/resolution scripts and agent workflows for planning and hard-lock execution.
  - What they care about: Deterministic behavior, auditability, and avoiding mode drift between planning and execution.
  - Their constraints: Must obey strict repo policy and cannot rely on implicit memory; prompts and scripts must resolve from repository files.
  - Their goals and frustrations: Wants small-scope work to use minor-audit when eligible, but needs guaranteed fail-closed fallback to `full` when eligibility is unclear.
  - Their context and motivations: Works across `.github` prompt templates, resolver scripts in `scripts/dev_tools`, and VS Code tasks; needs consistent outcomes across all entry points.
- Scenario: Minor-audit requested, resume flow invoked later
  - Who is acting: The maintainer.
  - Trigger: They run planning for a feature with a requested `minor-audit` mode, then later resume hard-lock execution.
  - Steps: (1) `generate-atomic-plan` is resolved from feature docs, (2) mode is selected using canonical precedence, (3) execute-hard-lock prompt is resolved from the selected plan path, (4) resume-hard-lock prompt is resolved for the same plan/mode.
  - Obstacles/decisions: If the mode marker is missing/malformed or eligibility fails, tooling must explicitly fall back to `full` with a concrete reason.
  - Expected outcome: Both execute and resume prompts reference the same authoritative plan path and resolved mode; no divergent task set or contradictory messaging appears.


## Acceptance Criteria

- [ ] `generate-atomic-plan` resolves mode using canonical precedence (issue marker → reconciled override when allowed → fail-closed `full`) and emits resolved mode in generated planning context.
- [ ] Execute and resume hard-lock prompt flows both resolve from dynamic plan-path input (no hardcoded feature path) and include mode-consistent instructions for the same plan-of-record.
- [ ] Prompt resolver scripts share a single observable mode contract (`minor-audit`/`full` + fallback reason when applicable) so resolved outputs are identical for equivalent inputs across entry points.
- [ ] If `minor-audit` is requested but eligibility is not met, output explicitly states fallback to `full` and includes a deterministic, user-visible fallback reason.
- [ ] Existing full-mode workflows remain backward compatible: prior command signatures continue to work, and resolved prompts are still valid when no mode marker exists.
- [ ] Python changes introduced for this feature pass repo quality gates (Black, Ruff, Pyright, Pytest) and include required docstrings and intent-level control-flow comments.
- [ ] Feature rollout and validation are treated as `full` process work for this issue because scope spans prompts, scripts, tasks, and agent/skill guidance.


## Non-Goals

- Adding new product-facing runtime modes beyond `minor-audit` and `full`.
- Rewriting the broader atomic planner/executor architecture outside mode-contract consistency and hard-lock/resume parity.
- Changing unrelated agent personas, prompts, or skills that do not participate in plan generation or hard-lock/resume resolution.
- Introducing external services, remote state stores, or telemetry backends; this feature remains repository-local.
