---
title: "minor-audit-planning - Plan"
issue: "TBD"
parent: "none"
owner: "Dan Moisan"
last_updated: "2026-02-23T13-53"
status: "Draft"
status_color: "lightgrey"
version: "0.1"
---

# minor-audit-planning (Potential)

- Date captured: 2026-02-23
- Author: Dan Moisan
- Status: Draft

## Problem / Why

Current planning/execution tooling does not consistently model the selected work mode (`minor-audit` vs `full`) across agent prompts, generated atomic plans, and resume/hard-lock prompt resolution. This creates drift between feature intent and execution behavior, especially when users need a lighter audit path for small changes but strict full-process handling for larger scope work. We need deterministic, mode-aware routing so planning, prompt resolution, and execution all use the same source of truth and fail closed safely.

## Proposed Behavior

Implement minor-audit-aware behavior across the relevant `.github` agents, skills, and planning/prompt tooling, including atomic planning/execution variants. `generate-atomic-plan` and hard-lock/resume prompt resolution must explicitly choose and carry forward `minor-audit` or `full` mode, with clear fallback to `full` when eligibility is not met. Add/adjust prompt-resolver tasks for resume-hard-lock flow so resumed execution uses the same resolved mode and expected task set. Ensure all Python changes meet repo policy for typing, linting, and intent-level docstrings/comments.

## Acceptance Criteria (early draft)

- [ ] `generate-atomic-plan` supports mode-aware planning and can choose `minor-audit` or `full` based on requested mode plus eligibility checks, persisting/propagating the selected mode consistently.
- [ ] Hard-lock and resume prompt resolution tooling supports the same mode contract and resolves resume-hard-lock prompts with mode-correct tasks and messaging.
- [ ] Atomic planning/execution variants (including prompt resolvers and related skills/agent instructions) are wired so mode selection is deterministic and does not diverge between plan generation and plan execution.
- [ ] When `minor-audit` is requested but not eligible, tooling fails closed to `full`, emits a concrete fallback reason, and continues with full-process expectations.
- [ ] Python updates in this feature comply with repository policy: Black/Ruff/Pyright/Pytest pass, and new/changed Python code includes required docstrings and intent comments.
- [ ] Because scope spans multiple agents/skills/tooling paths, this feature is explicitly treated as full-process work (not minor-audit execution for this feature itself).

## Constraints & Risks

- Scope is cross-cutting (`.github` instructions/skills + Python prompt/planning tooling), so partial rollout can produce inconsistent mode behavior across commands.
- Backward compatibility risk: existing workflows that assume full-only behavior must continue to function without breaking command signatures or expected outputs.
- Policy risk: Python suppression/doc-comment requirements are strict; non-compliant changes may pass local logic checks but fail repo quality gates.
- Operational risk: mode selection ambiguity during resume/hard-lock could cause wrong task routing unless resolution precedence is explicit and shared.

## Test Conditions to Consider

- [ ] Unit coverage areas: mode parsing/validation, eligibility decision paths, fail-closed fallback behavior, and resume-hard-lock task selection logic.
- [ ] Integration scenarios: end-to-end generation -> hard-lock -> resume flow for both `minor-audit` and `full`, including mixed/invalid mode inputs.
- [ ] CLI/API examples: `generate-atomic-plan` and prompt resolver invocations demonstrating explicit mode selection, persisted mode reuse, and fallback-to-full outputs.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/minor-audit-planning/` folder from the template

