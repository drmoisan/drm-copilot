# Lighter path for merging integration code into a feature, and regenerate-after-merge (Issue #1156)

- Date captured: 2026-11-09
- Author: Dan Moisan (owner request), captured by Claude
- Status: Promoted -> docs/features/active/Lighter_path_for_merging_integration_code_into_a_feature_and_regenerate-after-merge/ (Issue #1156)

- Issue: #1156
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1156
- Last Updated: 2026-11-09
## Problem / Why

- In an epic, features that touch the same generated artifacts or derived summary files (counts, inventories, generated code) all go stale whenever another feature merges into the integration branch.
- The current rules turn every such merge conflict into a synthetic Blocking finding that runs the full remediation loop: plan, preflight, execute, re-review, CI.
- That cycle also counts toward the three-attempt remediation limit, even when the only real work is regenerating artifacts on the merged tree.
- In practice this added a full cycle (1-2 hours) per feature, per merge, and pushed features toward the loop limit.

## Proposed Behavior

- A repository-declared regeneration command in orchestration config, for example `regeneration.command`, `regeneration.paths` (globs of generated or derived files) and an idempotency check.
- Conflict classification when merging the integration branch into a feature branch:
  - If every conflicted or auto-merged path matches `regeneration.paths`, take the regenerate path: run the command on the merged tree, confirm idempotency (a second run leaves no diff), run the local unit gate, then CI. No planner, no preflight, no full re-review; instead a delta review limited to the merge commit's non-generated changes, recorded as a review outcome. This path does not consume a remediation attempt.
  - Otherwise use today's remediation loop unchanged.
- After each feature merges into the integration branch, the epic orchestrator runs the regeneration command on the integration branch (when declared), commits any diff, and verifies CI before the next feature syncs.

## Acceptance Criteria (early draft)

- [ ] Orchestration config accepts `regeneration.command`, `regeneration.paths`, and an idempotency check; absent config preserves today's behavior; the keys are documented and validated.
- [ ] A pure classifier decides regenerate-path versus remediation-loop from the set of conflicted and auto-merged paths and the declared globs, with unit tests (all-match, partial-match, no config, empty set).
- [ ] The regenerate path runs the command, verifies idempotency (second run leaves no diff), runs the local unit gate, then CI, and records a delta review of the merge commit's non-generated changes as a review outcome.
- [ ] The regenerate path does not consume a remediation attempt; the three-attempt limit is otherwise unchanged.
- [ ] The epic orchestrator runs the regeneration command on the integration branch after each feature merge (when declared), commits any diff, and verifies CI before the next feature syncs.
- [ ] The orchestrate and epic-orchestrate skills, the remediation-loop documentation, the checkpoint schema (new cycle kind or field, tolerated by validators), and the merge gates are updated to accept the regenerate path's evidence.
- [ ] The CI-green merge rule and every existing gate decision for non-generated changes are unchanged, shown by regression tests.

## General Constraints (all harness-learnings workstreams)

- Keep pure logic (calculations, classification, scheduling, parsing) in host-neutral modules with unit tests; keep I/O (git, gh, filesystem, process inspection) in thin adapters.
- Inject clocks, randomness, filesystem and process seams; no temporary files and no wall-clock waits in tests.
- Every new configuration knob has a safe default that preserves today's behavior unless this entry states otherwise.
- Update the skill and agent documentation that describes each changed behavior, and keep the push-down payload consistent with it.
- New pushed-down code (skills, hooks, libs) is PowerShell or bash; TypeScript only for MCP or extension commands; no new Python.
- Existing gate decisions are unchanged except where this entry explicitly changes them, shown by parity or regression tests.
- New configuration keys are documented, validated, and default to today's behavior.
- The push-down payload carries every changed skill, agent, hook, and script.
- Delivered as its own issue and PR with unit tests for the pure logic, updated skill and agent documentation, and fully green CI.

## Source

Owner request of 2026-11-09: observations from a multi-feature epic with five features running in parallel on one shared development machine.
