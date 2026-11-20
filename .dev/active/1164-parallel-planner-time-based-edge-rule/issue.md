# parallel-planner-time-based-edge-rule (Issue #1164)

- Date captured: 2026-11-09
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-planner-time-based-edge-rule-1164/ (Issue #1164)

- Issue: #1164
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1164
- Last Updated: 2026-11-09
- Work Mode: full-feature

Source note: the promoted potential record was written in the coordinator's intake worktree and is not on this branch. This file reproduces the body of GitHub issue #1164 (read with `gh issue view 1164` on 2026-11-09), which is authoritative.

## Problem / Why

Owner directive (2026-11-09): "I want maximum parallelization. Therefore, features should be run sequentially if and only if the time lost to merge is greater than the time gained through parallel execution."

The parallel scheduler already has the right shape of rule (`cost * 100 > benefit * tolerance_percent`), but:

- The committed weights in `config/blast-radius.json` are not in time units. `same_file` is 8 while a C3 item's benefit is 4, so a single shared file serializes two half-day items even when the merge takes minutes. Measured on run bugs-1001-1002-1003-1006: total about 20 h at tolerance 100 versus about 8-11 h at higher tolerances, with every edge a `path_overlap`.
- Planners and coordinators add operator `--after` precedence flags for convenience, which serialize items without any cost/benefit test.
- The rule exists only as coordinator memory and per-run instructions; the parallel-planner agent and parallel-plan / parallel-add skills do not state it, so each run must be corrected by hand.

## Proposed Behavior

- State the rule in the parallel-plan, parallel-add and parallel-run skills, the parallel-planner and parallel-orchestrator agents, and `.claude/rules/parallel-orchestration.md`: two items run sequentially if and only if the expected merge time exceeds the expected time gained by running them in parallel.
- Express cost and benefit in the same unit (hours): band durations are expected item wall-clock hours, and each overlap weight is the expected resolution time for that overlap class (read-only on one side: 0; append-only or regenerated or separable docs-section writes: minutes; possible overlap: small; same function or rule edited on both sides: one remediation pass). Recalibrate the committed weights and default tolerance so that tolerance_percent 100 means exactly "edge iff merge time > gain".
- The planner records, per detected conflict pair, the two estimates and the verdict in its checkpoint and the manifest.
- Operator `--after` precedence flags and planner-proposed ordering must pass the same test; a flag whose recorded merge cost does not exceed the gain is rejected with a message naming the rule, unless the operator marks it as a correctness ordering (dependency) with a reason.
- Hard classes (`shared_surface_overlap`, `contract_dependency`) remain correctness guards; the planner records both estimates for them so the owner can see the cost of each hard edge.

## Acceptance Criteria

- [ ] The rule text is present and consistent in the parallel-plan, parallel-add, parallel-run skills, both parallel agents, and the parallel-orchestration rule (Claude surface and the parallel Copilot surface where it exists).
- [ ] Committed weights, band durations and default tolerance are recalibrated to time units; the scheduler at the default tolerance makes an edge iff estimated merge time > gain; unit tests cover read-only, append-only, same-file, same-function and hard-class pairs.
- [ ] Per-pair estimates and verdicts are recorded in the planner checkpoint and manifest; validators accept and check the new fields; older checkpoints without them remain valid.
- [ ] Precedence flags without a correctness reason are rejected when merge cost does not exceed gain; tests cover accepted, rejected and correctness-marked flags.
- [ ] Destination overrides through `config/blast-radius.local.json` still work; the push-down payload carries every changed file.
- [ ] Changing the default scheduling behaviour is intended for this item (owner-directed); the change is called out in the PR.

## Constraints & Risks

- Pushed-down code is PowerShell or bash; no new Python. Pure cost/benefit logic stays in host-neutral modules with unit tests.
- Narrowing a declared radius to suppress an edge remains prohibited.
- Test runs are parallel-only; evidence is append-only.
- This item edits the scheduler; it must not be batched into a parallel run whose radii it changes.

## Test Conditions

(not provided in potential file)

## Source

From: docs/features/potential/2026-11-09-parallel-planner-time-based-edge-rule.md
