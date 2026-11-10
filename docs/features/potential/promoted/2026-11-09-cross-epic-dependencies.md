# Cross-epic dependencies (Issue #1162)

- Date captured: 2026-11-09
- Author: Dan Moisan (owner request), captured by Claude
- Status: Promoted -> docs/features/active/Cross-epic_dependencies/ (Issue #1162)

- Issue: #1162
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1162
- Last Updated: 2026-11-09
## Problem / Why

An epic manifest lists only edges inside the epic and assumes earlier epics have merged. Starting a dependent epic early (to overlap epics) would launch features whose prerequisites in the earlier epic have not merged.

## Proposed Behavior

- Manifest support for cross-epic depends-on edges naming a feature of another epic and that epic's integration branch.
- The epic orchestrator holds such a feature until the named prerequisite has merged into the other epic's integration branch (verified with gh and ancestry), then merges that integration branch into its own integration branch (a direct merge commit) before starting the feature.
- The epic progress report's critical-path calculation includes cross-epic edges.
- The epic's integration-to-main PR is held until the prerequisite epic's integration-to-main PR has merged.

## Acceptance Criteria (early draft)

- [ ] The epic manifest schema accepts cross-epic depends-on edges (feature + other epic + its integration branch); validated and documented; manifests without them behave as today.
- [ ] Pure readiness logic decides hold/release from prerequisite merge state, with unit tests; the gh and ancestry checks are thin adapters.
- [ ] On release the orchestrator merges the other epic's integration branch into its own (direct merge commit) before starting the feature.
- [ ] The epic-progress-report critical path includes cross-epic edges.
- [ ] The integration-to-main PR is held until the prerequisite epic's integration-to-main PR has merged.
- [ ] epic-plan, epic-orchestrate, epic-progress-report skills and agents updated.

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
