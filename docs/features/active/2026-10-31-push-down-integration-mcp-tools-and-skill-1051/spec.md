# 2026-10-31-push-down-integration-mcp-tools-and-skill — Spec

- **Issue:** #1051
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14T10-43
- **Status:** Draft
- **Version:** 0.1

## Overview

A push-down into a destination that already has workflows, a different version matrix, existing hooks or a different layout requires integration decisions. The push-down is a deterministic TypeScript extension command; it should not make those decisions, and it should not call a language model itself. A model call inside the extension bypasses the repository's hooks, the model-routing and preimplementation gates and the review step; it needs credentials and quota that the coordinator cannot see; it fails wherever no model is signed in; and it leaves no transcript or receipt.

The integration judgment belongs in an agent session, where the model is already governed and visible. The session needs structured facts to work from and a deterministic check that the result is correct.


## Behavior

1. **The push-down stays mechanical.** It copies files, writes the content-hash manifest (issue #1049) and writes new workflows beside existing ones. When it meets a decision it cannot make mechanically (an existing `ci.yml`, a different version matrix, a missing required check, a destination-edited hook), it records the item in an `integration-needed` file in the destination and does not guess.
2. **MCP tool: detect.** Reports the ecosystems present in the destination, the existing workflows and their job names, and a structured list of conflicts with the pushed content (for example, an existing job whose name overlaps a pushed job). Deterministic and read-only.
3. **MCP tool: validate.** Checks the integrated result: workflow YAML parses, the required check names exist, the coverage artifact paths match the toolchain rules, and manifest hashes are consistent. Returns a pass or a list of failures. Deterministic.
4. **Skill.** Tells an agent session how to integrate: read the `integration-needed` file, resolve each conflict, run the validate tool, and stop only when it passes. Resolution happens through ordinary edits under the destination's hooks and review.
5. **No model call in MCP tools.** MCP sampling is not used: client support is uneven, and it would reintroduce a hidden model inside a tool.


## Inputs / Outputs

- Inputs (CLI flags, files, env vars)
- Outputs (artifacts, logs, telemetry)
- Config keys and defaults:
- Versioning or backward-compatibility constraints:

## API / CLI Surface

List commands, flags, request/response shapes, and examples.
- Example invocations with expected outputs (concise):
- Contracts and validation rules:

## Data & State

Data flow, storage, or state changes introduced by this feature.
- Data transformations and invariants:
- Caching or persistence details:
- Migration or backfill requirements (if any):

## Constraints & Risks

- The tools report facts and verdicts only. Any judgment that is not mechanical stays with the agent session.
- The validate tool can pass an integration that is wrong in a way it does not check; its checks must be listed, and the skill must say what it does not cover.
- Depends on the CI push-down (the required-check data and templates) and on the manifest from issue #1049. Overlaps the shared agent-harness layer epic (#1018).
- A destination edit after integration shows as a manifest hash mismatch and returns the file to destination ownership.


## Implementation Strategy

- Implementation scope (what changes, not sequencing):
- New classes/functions/commands to add or update:
- Dependency changes (new/removed packages) and rationale:
- Logging/telemetry additions and locations:
- Rollout plan (feature flags, staged deploys, fallback path):

## Definition of Done

- [ ] Acceptance criteria documented and mapped to tests or demos
- [ ] Behavior matches acceptance criteria in all documented environments
- [ ] Tests updated/added (unit/integration as applicable)
- [ ] Edge cases and error handling covered by tests
- [ ] Docs updated (README, docs/features/active/... links)
- [ ] Telemetry/logging added or updated (if applicable)
- [ ] Toolchain pass completed (format → lint → type-check → test)

## Seeded Test Conditions (from potential)
- [x] Unit coverage areas: conflict detection from fixture file lists; each validation rule with a passing and a failing fixture; `integration-needed` file generation.
- [x] Integration scenarios: push to a scratch destination that has an existing `ci.yml`, run detect, resolve, and confirm validate passes.
- [ ] CLI/API examples
