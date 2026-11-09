# progress-report-critical-path-velocity — Spec

- **Issue:** #1153
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-09T09-45
- **Status:** Draft
- **Version:** 0.1

## Overview

Observed in a live epic on 2026-11-09:

- The v2 rewrite of the `epic-progress-report` skill (typed steps) removed task-based progress and velocity. The report has no tasks per hour, no recent velocity, no SD, and no range.
- The headline "about N hours left" is the serial sum over step types (remaining steps times their median, summed), decision D7. It ignores parallelism. With 5 features running at once it read 20 to 22 h. The wave-parallel figure on the same line read 12.5 h, and measured throughput implied about 6 to 8 h.
- The wave-parallel figure takes the slowest feature in each wave. It ignores the actual dependency edges, the concurrency cap, and each feature's own pace.
- Aggregate (parallel) velocity is not a stable measure. It scales with the number of running features and drops to zero during contention or stalls. Per-step medians measured during contention, such as 100-minute test runs, inflate every estimate.


## Behavior

Revise `.claude/skills/epic-progress-report/` and its scripts (`scripts/Get-EpicProgressReport*.ps1`, and the forwarder `scripts/dev-tools/Get-EpicProgressReport.ps1`). The time estimate must account for parallelism, task-based velocity must come back, and the headline must be a dependency-aware critical path. This replaces the D7 serial sum as the primary estimate. The default TL;DR cadence becomes 20 minutes.

1. **Task progress and aggregate velocity.**
   - Report done and total `[P#-T#]` plan tasks for each feature and for the epic. Keep the typed-step totals as a second measure.
   - Report aggregate velocity: the average since the baseline, the recent value (last interval), and the SD of interval velocities with the interval count. Label it aggregate and informational.
2. **Sequential (per-branch) velocity as the primary rate.**
   - Each feature's own velocity is tasks per hour of its active execution time. Time when the feature is blocked, waiting for the machine, or not started is excluded. The sources are checkpoint `stage_timing` and plan-checkbox samples.
   - The pooled value is the median over features with enough data (at least 5 tasks and at least 15 active minutes), reported with its SD across features.
   - A feature without enough data uses the pooled value. If there is no pooled value, a configurable default applies.
3. **Per-branch remaining time.**
   - Remaining time = remaining tasks / sequential velocity + the sum of remaining non-execution steps, each at its per-type median.
   - An in-progress step counts as max(0, median - elapsed).
   - Blocked features are reported separately.
4. **Critical path.**
   - Build the dependency DAG from the kickoff or manifest: each feature's depends-on edges, with waves used only as a fallback.
   - Add the epic-level tail steps that run after every feature merges: main sync, integration-to-main PR, its CI, and the merge.
   - Simulate list scheduling under `max_parallel_features`. The headline is the resulting finish time, together with the named critical chain.
   - Also report:
     - the serial sum, labelled "upper bound, no parallelism";
     - a range at velocity plus or minus 2.05 SD, with no upper bound when the slow velocity is at or below a threshold.
5. **Report format.**
   - The TL;DR has 4 lines plus a velocity line: progress; elapsed time and headline with the chain and quota; velocity; range.
   - The full report adds a per-feature table and a critical-path section, and keeps the step-type table.
   - Push notification text is under 200 characters.
6. **Cadence.**
   - The TL;DR cron becomes `*/20 * * * *`. The hourly full report stays at `7 * * * *`.
   - Update the scheduling prompts, the jitter notes, the `-PairSamples` guidance, and any interval filters that assumed 5 or 10 minutes.
7. **Engineering.**
   - Pure calculations go in a host-neutral module, separate from I/O.
   - Pester tests use fixtures for:
     - a serial chain;
     - a diamond DAG;
     - a cap of 1 versus N;
     - a blocked feature;
     - the pooled fallback;
     - a pause;
     - non-finite inputs printing `n/a`.
   - The clock is injected, and tests use no temporary files.
   - The state file version is bumped, with a migration from v2 that keeps the baseline start and the weekly baseline and adds per-feature samples.
   - SKILL.md is updated, and the forwarder keeps working.


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

- PowerShell only. No new Python.
- File-size limits apply: 800 lines is a hard block and 500 lines is guidance. Split modules as needed.
- Each `.claude` change needs its bundle copy and a manifest entry.
- The state migration must not lose the v2 baseline or weekly baseline.


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
- [ ] Unit coverage areas: velocity (per-feature, pooled, aggregate), remaining time, DAG list scheduling, range, and state migration.
- [ ] Integration scenarios: the full report rendered from fixture checkpoints and a fixture manifest.
- [ ] CLI/API examples: the TL;DR and full-report output from the forwarder script.
