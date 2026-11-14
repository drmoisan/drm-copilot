# regenerate-after-integration-merge (Issue #1156)

- Date captured: 2026-11-09
- Author: Dan Moisan
- Status: Adopted -> docs/features/active/regenerate-after-integration-merge-1156/ (Issue #1156, filed before orchestration)

- Issue: #1156
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1156
- Last Updated: 2026-11-09
- Work Mode: full-feature

Mirror of the GitHub issue body, read with `gh issue view 1156` on 2026-11-09. The issue is authoritative.

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

## Acceptance Criteria
- [ ] Orchestration config accepts `regeneration.command`, `regeneration.paths`, and an idempotency check; absent config preserves today's behavior; the keys are documented and validated.
- [ ] A pure classifier decides regenerate-path versus remediation-loop from the set of conflicted and auto-merged paths and the declared globs, with unit tests (all-match, partial-match, no config, empty set).
- [ ] The regenerate path runs the command, verifies idempotency (second run leaves no diff), runs the local unit gate, then CI, and records a delta review of the merge commit's non-generated changes as a review outcome.
- [ ] The regenerate path does not consume a remediation attempt; the three-attempt limit is otherwise unchanged.
- [ ] The epic orchestrator runs the regeneration command on the integration branch after each feature merge (when declared), commits any diff, and verifies CI before the next feature syncs.
- [ ] The orchestrate and epic-orchestrate skills, the remediation-loop documentation, the checkpoint schema (new cycle kind or field, tolerated by validators), and the merge gates are updated to accept the regenerate path's evidence.
- [ ] The CI-green merge rule and every existing gate decision for non-generated changes are unchanged, shown by regression tests.

## Constraints & Risks
(not provided in potential file)

## Test Conditions
(not provided in potential file)

## Source
From: docs/features/potential/2026-11-09-regenerate-after-integration-merge.md (lifecycle record not present in the repository; the GitHub issue is the source)
