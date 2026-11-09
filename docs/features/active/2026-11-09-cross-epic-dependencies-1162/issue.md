# cross-epic-dependencies (Issue #1162)

- Date captured: 2026-11-09
- Status: Adopted from existing GitHub issue #1162 (filed before orchestration)

- Issue: #1162
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1162
- Last Updated: 2026-11-09
- Work Mode: full-feature

## Problem / Why

An epic manifest lists only edges inside the epic and assumes earlier epics have merged. Starting a dependent epic early (to overlap epics) would launch features whose prerequisites in the earlier epic have not merged.

## Proposed Behavior

- Manifest support for cross-epic depends-on edges naming a feature of another epic and that epic's integration branch.
- The epic orchestrator holds such a feature until the named prerequisite has merged into the other epic's integration branch (verified with gh and ancestry), then merges that integration branch into its own integration branch (a direct merge commit) before starting the feature.
- The epic progress report's critical-path calculation includes cross-epic edges.
- The epic's integration-to-main PR is held until the prerequisite epic's integration-to-main PR has merged.

## Acceptance Criteria

- [ ] The epic manifest schema accepts cross-epic depends-on edges (feature + other epic + its integration branch); validated and documented; manifests without them behave as today.
- [ ] Pure readiness logic decides hold/release from prerequisite merge state, with unit tests; the gh and ancestry checks are thin adapters.
- [ ] On release the orchestrator merges the other epic's integration branch into its own (direct merge commit) before starting the feature.
- [ ] The epic-progress-report critical path includes cross-epic edges.
- [ ] The integration-to-main PR is held until the prerequisite epic's integration-to-main PR has merged.
- [ ] epic-plan, epic-orchestrate, epic-progress-report skills and agents updated.

## Constraints & Risks

(not provided in potential file)

## Test Conditions

(not provided in potential file)

## Source

Mirrored read-only from GitHub issue #1162 (`gh issue view 1162`, 2026-11-09T21:33Z). The issue body names `docs/features/potential/2026-11-09-cross-epic-dependencies.md` as its origin; that file is not present on `origin/main` or under `docs/features/potential/promoted/`.
