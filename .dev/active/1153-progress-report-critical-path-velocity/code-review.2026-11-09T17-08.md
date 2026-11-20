# Code Review: Progress Report Critical Path and Velocity (Issue #1153)

- **Branch:** `feature/progress-report-critical-path` @ `afdf04d0bbb460701984b63bd00e60949ca106b2`
- **Base:** `main`, merge base `bfae0c0b79b87d06bbaee2c9bcea0e38c4e7c864` (equal to `origin/main`)
- **Scope:** full branch diff, 54 files: 9 skill files under `.claude/skills/epic-progress-report/` and their bundle copies, `core.json`, 13 Pester files, and the feature folder
- **Reviewer:** feature-review agent, 2026-11-09

## Executive Summary

- **Design matches the spec.** The pure calculations are in two new host-neutral files: `Get-EpicProgressReport.Velocity.ps1` (E2, E3, E11) and `Get-EpicProgressReport.Schedule.ps1` (E5 to E9). Neither file reads the clock or calls an I/O seam, and a test pins this. The manifest and routing-config reads are in Gather, and they go through the existing `Read-EpicProgressText`, `Test-EpicProgressPath`, and `Read-EpicProgressFile` seams. The entry script receives wiring only and defines the same 10 functions as at the merge base.
- **The list schedule is correct on the probes run.** The reviewer ran in-memory probes against the dot-sourced Logic hub. The diamond gives 5 h at cap 4 with chain `#1 -> #3 -> #4 -> tail` and 7 h at cap 1. With three running features at cap 2, all three hold their slots, and the pending feature starts at 2 h, when the running count falls below 2, with the slot-freeing feature as its predecessor. Zero-duration chains terminate. A feature with infinite duration yields an infinite headline, and the run terminates. In the dependency graph, a `docs/features/active/` folder hint and an integer reference both resolve. `ConvertFrom-Json` integers arrive as Int64, and `Resolve-EpicProgressParallelCap` accepts them.
- **The shipped path works end to end.** The reviewer ran `Get-EpicProgressReport.ps1 -Issue 1153 -Mode Full` with a scratch `-StatePath`. It printed the five TL;DR lines, the per-feature table (`own` rate 14.1 tasks / hr), the critical-path section, the range `n/a` with its reason, and the step-type table, and it wrote a version-3 state file.
- **Mirrors and manifest are complete.** All 9 changed skill files are byte-identical with their bundle copies. `core.json` gains exactly the two new scripts.
- **No blocking finding.** There is one advisory Warning (`Schedule.ps1` at 783 lines) and five non-blocking items, CR1 to CR5.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Warning | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Schedule.ps1` | whole file | 783 logical lines, at or above the 700-line advisory tier and below the 800-line hard limit. | See CR1. | File-size advisory tier; non-blocking. | Reviewer logical line count (`splitlines`, no trailing-terminator line) |
| Minor | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Schedule.ps1` | `Get-EpicProgressCriticalPathReport`, `Get-EpicProgressScheduleRange`, `Get-EpicProgressEpicTail` | CR1. The file is 17 lines below the hard block, so a small later change to the schedule will be refused by the size hook. | In a later change, move the report composition (`Get-EpicProgressCriticalPathReport`, `Get-EpicProgressScheduleRange`, `Get-EpicProgressEpicTail`, `Get-EpicProgressFeatureRemainingSecond`) into a third file such as `Get-EpicProgressReport.CriticalPath.ps1`, dot-sourced by the Logic hub. Update the bundle copy, `core.json`, and the path-list pins. | The graph and scheduling core (about 490 lines) and the composition layer (about 290 lines) separate cleanly along the existing function boundary. | File text |
| Nit | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Velocity.ps1` | `Get-EpicProgressAggregateVelocity`, average | CR2. On the first run after a version-2 migration, or after `-ResetBaseline`, `baselineDoneTasks` equals the current done count, so the line prints `aggregate 0 tasks / hr average`. No task can have been counted yet, so `n/a` would describe this state more accurately. Real-process run: `aggregate 0 tasks / hr average, n/a recent, SD n/a over 0 intervals`. | Optionally return NaN for the average while no combined interval exists, or state the rule in SKILL.md. | The figure is labelled informational, and the value is arithmetically correct. The headline and range do not use it. | Item-mode run output |
| Nit | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Schedule.ps1` | `Get-EpicProgressDependencyGraph`, `ConvertTo-EpicProgressFolderHint` | CR3. Reference resolution differs from the canonical resolver `scripts/dev_tools/_epic_orchestrator_state_resolution.py` in two ways. (a) A string reference whose text is an issue number, such as `"12"`, resolves as an issue here. Python treats every string reference as a folder hint. (b) The folder hint here is the last path segment of any path, while Python strips only the four lifecycle prefixes. | Document the difference in the Schedule help, or align it with the Python rule. | Both differences affect only references that `validate_epic_orchestrator_state.py` already rejects as unresolved, or folder names made only of digits. Valid checkpoints resolve the same way in both. | Source comparison; probe of `docs/features/active/<folder>` and integer references |
| Nit | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.Logic.ps1` | file help, line 10 | CR5. The hub description still lists Metrics as holding the "wave-parallel figure". That function was removed (E10), and the Metrics help now says the figure was retired. | Change the parenthetical to "(per-type estimate and formatting)" in a later change, together with the bundle copy. | Help text only. AC-06 concerns output lines and function definitions, and both hold. | `grep -rn wave-parallel` over the scripts folder |
| Nit | `.claude/skills/epic-progress-report/scripts/Get-EpicProgressReport.ps1` and `State.ps1` | `pauses[]` | CR4. Pause spans are appended and never pruned. The spec permits pruning spans that end before the oldest stored anchor ("may be pruned"), but does not require it. | Optionally prune in the writer. | Each span needs a gap longer than 1 h, so growth is at most a few entries per day. Neither the state size nor the overlap arithmetic is affected in practice. | `ConvertTo-EpicProgressStateJson`; entry wiring |

One covered file reaches the 700-line advisory tier (the Warning row above). The next largest are the test file `Get-EpicProgressReport.Tests.ps1` at 698 lines and the entry script at 530 lines. `config/file-size-baseline.json` is not in the branch diff.

## Detailed Review

### Velocity (E2, E3, E11)

- Sequential velocity counts only ledger samples whose key starts with `<issue>|exec|`, using an ordinal comparison. Zero active seconds gives NaN, and NaN renders `n/a`. A feature qualifies at `Tasks >= 5` and `ActiveSeconds >= 900`.
- The pooled median and the n-1 SD are taken over qualifying features only. The SD is NaN when fewer than 2 features qualify. Each feature's rate comes from the first available source: its own rate, then the pooled median, then the default (3600 / execution default).
- Aggregate intervals use only samples that carry `tasks`, so migrated v2 samples are ignored. An interval closes once at least 600 s have elapsed. An interval that overlaps a pause is dropped, while one that ends exactly where a pause starts is kept, because the comparison is strict. A trailing remainder is skipped.
- A pause is a gap strictly longer than 3600 s. The entry script compares the newest stored sample with now, which is sound because `Select-EpicProgressSample` adds a sample on every run that is at least 90 s after the previous one.
- `Get-EpicProgressExcludedSecond` merges the pause and blocked segments before summing them, so a span that overlaps both is not subtracted twice.

### Schedule (E5 to E9)

- The source of each feature's dependencies is chosen per feature. The checkpoint row wins when it carries a `depends_on` key; otherwise the manifest row is used. The waves fallback applies only when no feature has the key in either source. A self-loop, an unresolved reference, and a cycle each produce a distinct message, and the schedule then falls back to waves.
- Done features finish at 0 and hold no slot. Running features start at 0 even beyond the cap. Ready features start while the running count is below the cap, in descending order of longest remaining path, with ties broken by ascending issue number (`Compare-EpicProgressIssue`, which is numeric when both values parse and ordinal otherwise).
- Predecessor attribution: a start that waited only for its dependency names the dependency that finished last. A start that waited for a slot names the node whose finish freed it. `readyAt < now` is reached only when the cap was full at `readyAt`, because every ready node is considered at each event.
- The epic tail adds the predicted `main-sync` only when no open sync row exists and `integration-pr` is remaining. It is 0 when `integration-pr` is done, and it does not change the step totals.
- The range re-runs the schedule at rate +/- 2.05 SD. A rate at or below 0 is priced as infinite per task. `no upper bound` is triggered only by a feature that has a remaining or in-progress execution step.

### State (E12)

- A v2 document keeps `startUnixSeconds`, `baselineWeeklyPct`, `baselineDone`, `durations`, and `items`, and its samples lose any `tasks` value. A v3 document round-trips. Version 4 and higher, blank text, and unparseable text read as empty state. The writer sorts `features` keys, so the output is stable.

### Gather and entry wiring

- `Read-EpicProgressManifestFeature` makes no git call when every kickoff issue carries a checkpoint `depends_on` key. A block-style list makes it return no rows, and that is documented. `Read-EpicProgressRoutingCap` reads `codex_topology_policy.parallelism.default_max_parallel_features`, which is where `config/orchestration-routing.json` holds the key. The spec text abbreviates the path as `parallelism.default_max_parallel_features`, and SKILL.md states the full path.
- The pause span this run closes is computed before a reset discards the samples, and it is passed to the tick split of the same run. The state is also written when only a pause span was appended.

### Security and correctness

There is no new process call outside the wrappers and no new file write outside `Write-EpicProgressState`. The repository-constraint tests pin both. The manifest path is built from `-EpicFolder` and is passed to `git show` as an argument.

## Verification Performed

- Read the full diff of the production scripts. Read `Velocity.ps1` and `Schedule.ps1` in full.
- Parsed `artifacts/pester/powershell-coverage.xml` to get per-file and repo-wide LINE coverage.
- Counted logical lines. Compared each skill file with its bundle copy using `cmp`. Read the `core.json` diff.
- Ran the shipped script for real in item mode with a scratch state path.
- Ran in-memory probes of the schedule, chain, graph, and cap functions.
- Grepped the tests for temporary-file, clock, sleep, and global-function use, and grepped the pure files for I/O and clock use.
- Ran `check_quality_tiers`, `validate_evidence_locations.py`, and `git merge-tree` against `origin/main`.
- Limitation: the reviewer did not run mutants of the boundary rules. The boundary cases name both sides of each threshold (for example 3600 versus 3601 s, and 599, 600, and 601 s), and the reviewer read their assertions.

## Verdict

PASS. No blocking finding. The Schedule.ps1 Warning and CR1 to CR5 are non-blocking.
