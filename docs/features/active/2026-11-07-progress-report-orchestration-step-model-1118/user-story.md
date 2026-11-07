# `progress-report-orchestration-step-model` — User Story

- Issue: #1118
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-07T15-48

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

`.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` measures only plan checkboxes (`- [x] [P#-T#]`) in each feature's original plan. On Epic #1019 on 2026-11-07 this caused three problems:

- Review, PR, CI, merge, and main-sync time showed as zero progress, so the report looked stalled while work was running. For example, 18:09Z to 20:20Z showed nine zero intervals while #1037 was in review and CI and the fourth main sync ran.
- Remediation cycles were invisible: #1034's four cycles added work the report never counted.
- Executors tick tasks in batches, so 10-minute intervals swing between 0 and 161 tasks per hour, and the time estimates ranged from 3 to 296 hours.

The owner defined the replacement model on 2026-11-07.


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

- [ ] Every counted step has a type, and remediation steps and tasks add to the total.
- [ ] The estimate is the sum of remaining steps by type multiplied by the median duration of that type, and the report shows the per-type breakdown.
- [ ] A type with no measured duration is reported as such, with the default stated.
- [ ] Blocked time is excluded by recorded state.
- [ ] Review, CI, and main-sync periods show as progress on their steps, not as zero velocity.
- [ ] Durations persist across runs beyond the sample cap.
- [ ] Unit tests use in-memory fixtures, with no temporary files.
- [ ] `Invoke-PoshQCParallelTest` and `pytest -n auto` pass with zero failures.


## Non-Goals

Call out what is explicitly excluded from this feature.
