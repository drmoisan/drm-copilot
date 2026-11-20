# P4-T1 task note

Timestamp: 2026-11-09T16-09
Command: focused debug run of Get-EpicProgressReport.Gather.Tests.ps1 and Get-EpicProgressReport.Metrics.Tests.ps1 (Invoke-Pester from a SCRATCH sh launcher; debugging only, not a gate)
EXIT_CODE: 0
Output Summary: 43 passed, 0 failed. The P6-T2 parallel gate is the evidence for this task.

## Anchor correction (not a design change)

- The plan and spec name the routing-config cap as `parallelism.default_max_parallel_features`. In `config/orchestration-routing.json` the key sits at `codex_topology_policy.parallelism.default_max_parallel_features`, not at the top level.
- `Read-EpicProgressRoutingCap` reads that nested path. The test `reads the routing-config cap at codex_topology_policy.parallelism` proves it reads the nested key and ignores a top-level `parallelism` object.

## Cases added under the task

- `returns the checkpoint cap, depends_on rows and folder basename of the epic checkpoint` (step-report fields consumed by P4-T3).
- `counts overlapping pause and blocked time once` (AC-20 overlap, beside the pause-only, blocked-only, and no-span cases).

## Removed

- `Get-EpicProgressWaveParallelSecond` and its header sentence in `Get-EpicProgressReport.Metrics.ps1` (E10); the case `sums the largest remaining feature per open wave plus epic steps`; the Describe title now reads `Get-EpicProgressTypeEstimate (issue #1118)`.
- No script under `.claude/skills/epic-progress-report/scripts/` or its bundle copy defines `Get-EpicProgressWaveParallelSecond` (grep exit 1).
