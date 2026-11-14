# `2026-10-31-push-down-integration-mcp-tools-and-skill` — User Story

- Issue: #1051
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-14T10-43

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

A push-down into a destination that already has workflows, a different version matrix, existing hooks or a different layout requires integration decisions. The push-down is a deterministic TypeScript extension command; it should not make those decisions, and it should not call a language model itself. A model call inside the extension bypasses the repository's hooks, the model-routing and preimplementation gates and the review step; it needs credentials and quota that the coordinator cannot see; it fails wherever no model is signed in; and it leaves no transcript or receipt.

The integration judgment belongs in an agent session, where the model is already governed and visible. The session needs structured facts to work from and a deterministic check that the result is correct.


## Personas & Scenarios

- Persona: ...
  - who the user is
  - what they care about
  - their constraints
  - their goals and frustrations
  - their context and motivations
- Scenario: ...
  - A concrete, step-by-step narrative that describes how a user accomplishes a goal in a real-world context using the system.
  - who is acting?
  - what triggered the action?
  - what steps do they take?
  - what obstacles or decisions occur?
  - what outcome do they expect?


## Acceptance Criteria

- [ ] The push-down writes an `integration-needed` file listing each unresolved decision, and makes no model call.
- [ ] The detect tool returns the destination's ecosystems, workflows and structured conflicts, and modifies nothing.
- [ ] The validate tool fails on unparsable YAML, missing required check names, mismatched artifact paths and inconsistent manifest hashes, and passes on a correct integration.
- [ ] The skill documents the read, resolve, validate loop and names both tools.
- [ ] Both tools follow the existing MCP tool conventions (explicit `workspace_root`, structured results) and have unit tests with injected file-system seams.
- [ ] No new Python; the tools are TypeScript (MCP) and any helper is PowerShell or bash.


## Non-Goals

Call out what is explicitly excluded from this feature.
