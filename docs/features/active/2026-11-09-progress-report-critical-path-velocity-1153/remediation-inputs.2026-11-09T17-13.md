# Remediation Inputs — Issue #1153 (related non-blocking rows)

Timestamp: 2026-11-09T17-13
Issue: #1153
Branch: feature/progress-report-critical-path
Head at entry: 588e1e5757c572c611f01710b8a3c27d0a02513a
Remediation-Mode: design

## Source

The feature review recorded at `code-review.2026-11-09T17-08.md` (with `policy-audit.2026-11-09T17-08.md` and `feature-audit.2026-11-09T17-08.md`) returned PASS with no blocking finding. The rows below are the review's non-blocking items, all related to this feature. The orchestrator opens this cycle to fix them inside the item before merge rather than filing follow-up issues. None of them is blocking, and this cycle is not opened by a REMEDIATION_REQUIRED review.

The mode is design because CR1 adds a new production file (a change to the file inventory beyond the files already in the branch diff).

## Findings in scope

1. CR1 (Warning plus Minor), `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Schedule.ps1`: the file is 783 logical lines, 17 below the 800-line hard block. Move the report-composition layer (`Get-EpicProgressCriticalPathReport`, `Get-EpicProgressScheduleRange`, `Get-EpicProgressEpicTail`, `Get-EpicProgressFeatureRemainingSecond`, and any private helpers used only by them) into a new pure file `Get-EpicProgressReport.CriticalPath.ps1`, dot-sourced by the Logic hub after `Get-EpicProgressReport.Schedule.ps1`. Add its bundle copy and `core.json` entry, and move the path-list and file-count pins by one. The new file must keep the purity rules of the other pure files (no I/O seam, no clock read), and the AC-50 purity test must cover it. Behavior is unchanged: every existing test passes without assertion changes other than path-list and count pins.
2. CR2 (Nit), `Get-EpicProgressReport.Velocity.ps1` `Get-EpicProgressAggregateVelocity`: on the first run after a v2 migration or `-ResetBaseline`, the average prints `0 tasks / hr` although no task can have been counted. Return a non-finite average (rendered `n/a`) while no combined interval exists, with discriminating tests (no interval gives n/a; one interval gives the computed average). Update any golden or test that asserts the `0 tasks / hr average` text, and state the rule in SKILL.md where the velocity line is described.
3. CR3 (Nit), `Get-EpicProgressDependencyGraph` / `ConvertTo-EpicProgressFolderHint`: reference resolution differs from `scripts/dev_tools/_epic_orchestrator_state_resolution.py` for string references made only of digits and for paths outside the four lifecycle prefixes. Document both differences in the function help (no behavior change), because both affect only references the epic validator already rejects.
4. CR4 (Nit), `pauses[]` is never pruned: the spec permits pruning spans that end before the oldest stored anchor. Prune such spans when the state is written, with tests (a span ending before the oldest anchor is dropped; a span ending at or after it is kept).
5. CR5 (Nit), `Get-EpicProgressReport.Logic.ps1` file help: replace the stale "wave-parallel figure" parenthetical for Metrics with "(per-type estimate and formatting)", with its bundle copy.

## Constraints

- PowerShell only; no new Python. Injected clock; no temp files in tests. File-size tiers (801 lines blocks).
- Every `.claude` change gets its bundle copy and pack-manifest entry in the same task; run the mirror contract tests.
- Parallel gates only: one `Invoke-PoshQCParallelTest` and one `pytest -n auto`, compared with the Phase 0 baseline and the final-gate figures in `evidence/qa-gates/`; no per-file coverage drop; new code at 90% or more.
- Records are append-only; per-task commit and push; no tags, no force pushes.
- Final self-review task per the atomic-plan-contract.
