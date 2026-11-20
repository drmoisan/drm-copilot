# progress-report-orchestration-step-model (Issue #1118)

- Date captured: 2026-11-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/progress-report-orchestration-step-model/ (Issue #1118)

- Issue: #1118
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1118
- Last Updated: 2026-11-07
## Problem / Why

`.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` measures only plan checkboxes (`- [x] [P#-T#]`) in each feature's original plan. On Epic #1019 on 2026-11-07 this caused three problems:

- Review, PR, CI, merge, and main-sync time showed as zero progress, so the report looked stalled while work was running. For example, 18:09Z to 20:20Z showed nine zero intervals while #1037 was in review and CI and the fourth main sync ran.
- Remediation cycles were invisible: #1034's four cycles added work the report never counted.
- Executors tick tasks in batches, so 10-minute intervals swing between 0 and 161 tasks per hour, and the time estimates ranged from 3 to 296 hours.

The owner defined the replacement model on 2026-11-07.

## Proposed Behavior

### Unit of work: typed steps

Each unit of work is a step with a type:

- Each orchestration step is one step of its own type: research, spec, plan, preflight, review, PR, CI, merge, and, at epic level, main sync and the integration PR.
- Each plan task is one step of type `execution`. The execution phase adds its plan tasks to the total.
- A remediation cycle adds one step for each orchestration step it runs (plan, preflight, re-review, CI, and so on), typed the same as the normal step, plus one `execution` step for every task in its remediation plan.

Totals grow when a remediation cycle opens, so the completion percentage can fall. That is intended.

### Estimate: median per type

- Measure the duration of each completed step and keep it by type. An execution step's duration comes from tick times; for batched ticks, divide the batch's elapsed time across the tasks ticked.
- Remaining time is the sum, over each step type, of the remaining steps of that type multiplied by the median duration of that type.
- Show the per-type breakdown: remaining count, median, and subtotal.
- When a type has no measured duration yet, say so and use a stated default or a configured value, not a silent zero.

### Data sources

- Item checkpoints: `completed_steps`, `step5_status` to `step10_status`, `remediation_loop.cycles`, and the `stage_timing` record added by #1097.
- Plan and remediation-plan checkboxes.
- The epic checkpoint for epic-level steps.
- Durations persist across runs in the state file, so history is not lost to the 14-sample cap.

### Blockage

A step that is waiting on the owner or on a missed handoff is excluded by its recorded state, such as `blocked_reason` or `human_decision_required`, not inferred from zero ticks.

### Scope

- Epic reports and standalone items.
- Keep the TL;DR and full report formats as close as the new model allows, and update the skill's documentation.

## Acceptance Criteria (early draft)

- [ ] Every counted step has a type, and remediation steps and tasks add to the total.
- [ ] The estimate is the sum of remaining steps by type multiplied by the median duration of that type, and the report shows the per-type breakdown.
- [ ] A type with no measured duration is reported as such, with the default stated.
- [ ] Blocked time is excluded by recorded state.
- [ ] Review, CI, and main-sync periods show as progress on their steps, not as zero velocity.
- [ ] Durations persist across runs beyond the sample cap.
- [ ] Unit tests use in-memory fixtures, with no temporary files.
- [ ] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.

## Constraints & Risks

- PowerShell only, matching the existing script.
- Checkpoints written before #1097 have no `stage_timing`. Derive what is possible from commit times and mark those durations as approximate.
- The state file is per checkout and gitignored. A format change must read the existing version 1 file, or reset it cleanly.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/progress-report-orchestration-step-model/` folder from the template
