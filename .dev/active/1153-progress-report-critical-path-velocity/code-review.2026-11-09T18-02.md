# Code Review: Progress Report Critical Path and Velocity (Issue #1153)

- **Branch:** `feature/progress-report-critical-path` @ `693b76d4f725549a8f2858ffe6ea42b886bafd78`
- **Base:** `main`, merge base `bfae0c0b79b87d06bbaee2c9bcea0e38c4e7c864` (equal to `origin/main`)
- **Scope:** full branch diff, 68 files: 11 skill files under `.claude/skills/epic-progress-report/` and their bundle copies, `core.json`, 13 Pester files, and the feature folder
- **Review type:** re-audit after remediation cycle 1 (CR1 to CR5 of `code-review.2026-11-09T17-08.md`)
- **Reviewer:** feature-review agent, 2026-11-09

## Executive Summary

- **All five prior rows are resolved, and each resolution was checked independently.**
- **CR1 is a verbatim move.** The lines removed from `Schedule.ps1` at `f33a952e0` are identical to `Get-EpicProgressReport.CriticalPath.ps1` from its first function onward. Schedule otherwise gained only its narrowed synopsis line, and CriticalPath is unchanged since that commit. Schedule is now 494 logical lines and CriticalPath 308. The Logic hub dot-sources CriticalPath directly after Schedule, with exact file-name case. The AC-50 purity test lists all three pure files.
- **CR2 and CR4 tests discriminate.** On scratch copies, five mutants were each killed by the new cases:
  - CR2 guard removed: 4 failing cases.
  - CR4 boundary `-ge` changed to `-gt`: 3.
  - CR4 tick-anchor term dropped: 1.
  - CR4 sample term dropped: 1.
  - Writer not calling the selector: 2.
  The unmutated control passed 71 of 71.
- **CR4 cutoff is sound.** Every later reader of time starts at or after the cutoff:
  - The aggregate elapsed time starts at `startUnixSeconds`.
  - Intervals start at stored samples.
  - Tick batches start at a stored `LastTickUnixSeconds`. Gather uses `$NowUnixSeconds` when a plan has no anchor.
  - The reset and gap spans start at the newest stored sample.
  A pruned span therefore cannot change any later figure. The CriticalPath neutrality case confirms this end to end with a finite average.
- **The shipped path works.** A real item-mode run prints `aggregate n/a tasks / hr average, n/a recent, SD n/a over 0 intervals` and writes a version-3 state.
- **No blocking finding.** No covered file reaches the 700-line advisory tier. Two informational observations, O1 and O2, need no action.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Velocity.ps1` | `Get-EpicProgressAggregateVelocity` | O1. AC-16 in `spec.md` defines the average as done tasks since the baseline over active hours. Since CR2, the average is `n/a` whenever the interval count is 0, which includes the case where every interval overlaps a pause span. AC-16 does not state that case. | None. SKILL.md `## Calculation Rules` states the rule, and the function help states it. | The rule refines AC-16 without contradicting it. AC-10 already requires non-finite figures to print `n/a`. The figure is labelled informational and feeds neither the headline nor the range. | Diff `d18c4e3f8`; Velocity CR2 cases; real-process run output |
| Info | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Velocity.ps1` | `Select-EpicProgressRetainedPauseSpan` | O2. `spec.md` permits pruning spans that end "before the oldest stored anchor". The cutoff used is the minimum of the start, the oldest sample, and the oldest tick anchor. When anchors exist, that cutoff is never later than the oldest anchor, so the code prunes a subset of what the spec permits. When no anchor is stored, it prunes spans that end before the start or the oldest sample. | None. The remediation plan `## Design Decisions` records the rule and its reason, and SKILL.md `## State File` states it. | No later calculation reads time before the cutoff (see Detailed Review). A narrower prune is required because a span between the start and the oldest anchor still enters the aggregate elapsed time. | Gather lines 393 to 397; State.V3 and CriticalPath CR4 cases; mutation probes |

No covered file is at or above 700 logical lines. The largest are the test file `Get-EpicProgressReport.Tests.ps1` at 699, the entry script at 530, and the test file `Render.Tests.ps1` at 506. `config/file-size-baseline.json` is not in the branch diff.

## Detailed Review

### Remediation cycle 1

- **CR1 (split).**
  - The five functions `Get-EpicProgressCriticalChain`, `Get-EpicProgressEpicTail`, `Get-EpicProgressFeatureRemainingSecond`, `Get-EpicProgressScheduleRange`, and `Get-EpicProgressCriticalPathReport` are defined only in CriticalPath.
  - The hub help, the entry `.DESCRIPTION`, and the Metrics header name the new file.
  - The pin updates are as follows:
    - `core.json` gains one sorted entry, for 13 skill-folder entries.
    - The SkillContract tests count 13 delivery files.
    - `productionPaths` gains the CriticalPath path.
    - The purity test iterates over Velocity, Schedule, and CriticalPath.
  - All 13 skill-folder files are byte-identical with their bundle copies (`cmp`).
- **CR2 (n/a average).** The elapsed-time computation now runs only when `$rates.Count -gt 0`. The prior NaN conditions (no task baseline, no active time) still hold inside the guard. The goldens moved from `0` to `n/a` in the entry, item-mode, and CriticalPath tests.
- **CR3 (resolver differences).** Both `ConvertTo-EpicProgressFolderHint` and `Get-EpicProgressDependencyGraph` now name `_epic_orchestrator_state_resolution.py` and state the digits-only and last-segment differences. The change is help only.
- **CR4 (pruning).**
  - `ConvertTo-EpicProgressStateJson` calls `Select-EpicProgressRetainedPauseSpan` over its own `-StartUnixSeconds`, `-Sample`, and `-Item` arguments.
  - The `-Item` value passed by the entry script is `$report.Items`, the post-run item table. Its anchors are at or after the stored ones, and merged items are removed from it. Neither change moves the cutoff past an instant that a later run reads.
  - A span that has no end is kept.
  - Span order is preserved.
- **CR5.** No file under the scripts folder contains `wave-parallel figure,`. The Metrics retired-figure sentence remains.

### Unchanged areas since the prior review

The Velocity rate rules (E2, E3, E11), the list schedule (E5 to E9), the v3 state with v2 migration (E12), and the Gather and entry wiring are unchanged apart from the lines above. Their observations in `code-review.2026-11-09T17-08.md` still hold at this head. The 21216-case Pester gate passes with 0 failures.

### Security and correctness

The cycle adds no process call and no file write. The repository-constraint tests pin both, with the moved counts.

## Verification Performed

- Read the cycle diff `afdf04d0b..693b76d4f` for every production file, and the remediation inputs, plan, preflight fixes, and gate evidence.
- Compared the moved function text between `Schedule.ps1` and `CriticalPath.ps1`.
- Parsed `artifacts/pester/powershell-coverage.xml` (repo-wide 95.80%; every skill script at or above 96.40%). Its write time (17:52 UTC) is after the last code commit.
- Counted logical lines of every added or modified covered file.
- Compared all skill-folder files with their bundle copies using `cmp`, and counted the `core.json` entries.
- Ran five mutants and a control against scratch copies of the skill and three test files.
- Ran the shipped script for real in item mode, twice, with a scratch state path.
- Ran `check_quality_tiers`, `validate_evidence_locations.py`, and `git merge-tree` against `origin/main`.

## Verdict

PASS. No blocking finding. CR1 to CR5 are resolved. O1 and O2 are informational and need no action.
