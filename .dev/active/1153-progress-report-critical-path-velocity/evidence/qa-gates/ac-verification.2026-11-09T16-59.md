# Acceptance-criteria verification (P6-T5)

Timestamp: 2026-11-09T16-59
Command: test-name mapping against the final gates (evidence/qa-gates/pester.2026-11-09T16-54.md: 21204 tests, 0 failures; evidence/qa-gates/pytest.2026-11-09T16-59.md: 16590 passed, 0 failed; evidence/qa-gates/poshqc-static.2026-11-09T16-46.md; evidence/qa-gates/coverage-comparison.2026-11-09T16-54.md) plus sh SCRATCH/run-ps.sh SCRATCH/issue-1153-acchecks.ps1 (entry function-name set at the merge base of origin/main and HEAD versus HEAD, script line counts, It-block text identity at the merge base for the tests that must stay unmodified, forwarder diff, added Python files)
EXIT_CODE: 0
Output Summary:
  71 rows: 70 verified, 1 pending-CI (AC-58).
  AC-51 function-name set: the entry script defines the same 10 functions at the merge base and at HEAD (Get-EpicProgressLastExitCode, Get-EpicProgressUtcNow, Invoke-CswapExe, Invoke-EpicProgressReport, Invoke-GhExe, Invoke-GitExe, Read-EpicProgressFile, Test-EpicProgressCommand, Test-EpicProgressPath, Write-EpicProgressState); every script is at or below 800 lines (largest Schedule.ps1 783).
  Unmodified at the merge base (It-block text identical): `documents every parameter in comment-based help`, `keeps the name, type, default, mandatory status and validation of every existing parameter`, `keeps the durations ledger and anchors with -ResetBaseline`, both cswap quota cases, the nine existing Get-EpicProgressTypeEstimate cases, `returns the eleven catalog types`, `returns the built-in default for every type`. Forwarder and its test: no diff. Added Python files: 0.
  All named tests pass in the final Pester gate (0 failures across 21204 tests).

| ID | Verified by | Status |
|---|---|---|
| AC-01 | Render.CriticalPath `prints exactly five TL;DR lines with the E1 prefixes in order, and the same five before the Full report (AC-01)`; entry `prints the five TL;DR lines in TLDR mode`; item mode `prints the five TL;DR lines in item mode` | verified |
| AC-02 | Render.CriticalPath `states tasks first and steps second with the step percentage (AC-02)` (31 of 60 tasks, 19 of 35 steps, 54.3%) | verified |
| AC-03 | Render.CriticalPath `prints the elapsed time, headline, chain and cap, and ends with the weekly quota (AC-03)`; entry cswap quota cases on `$lines[1]` unmodified and passing | verified |
| AC-04 | Render.CriticalPath `prints the sequential rate with its source, count and SD, then the aggregate figures (AC-04)` and `prints a single feature with its own rate and source (AC-04)` | verified |
| AC-05 | Render.CriticalPath `prints the range with its SD source and the labelled serial sum (AC-05)` and `prints no upper bound for the slow end and n/a with the reason when no SD exists (AC-05)` | verified |
| AC-06 | Render.CriticalPath `prints no wave-parallel text in either mode, and the retired function is not defined (AC-06)`; Render `prints the velocity and range lines in both modes` | verified |
| AC-07 | Render.CriticalPath `prints the per-feature table, the critical-path section and the step-type table in Full mode (AC-07)` and `prints no graph message line for a valid graph (AC-07)` | verified |
| AC-08 | Render.CriticalPath Context `push-notification text (AC-08)`: 199 keeps, 200 drops, eight features with five-digit counts under 200 | verified |
| AC-09 | Render.CriticalPath `prints the item chain with no tail and no cap, and the headline equal to the item remaining time (AC-09)`; Schedule.Range `reports an item headline equal to its remaining time with no cap and no tail` | verified |
| AC-10 | Render.CriticalPath `prints n/a for NaN, positive and negative infinity in every new figure (AC-10)`; Render `prints no NaN or Infinity before the first task completes` | verified |
| AC-11 | Velocity `counts only ledger keys that start with the issue exec prefix`, `returns a non-finite rate that prints n/a for zero active seconds` | verified |
| AC-12 | Velocity `applies the qualification boundaries of 5 tasks and 900 seconds` | verified |
| AC-13 | Velocity `pools 6, 8 and 10 tasks per hour into median 8, SD 2 and count 3`, `returns a non-finite SD for one qualifier and a finite SD for two`, `ignores a non-qualifying feature at 30 tasks per hour` | verified |
| AC-14 | Velocity `labels a qualifying feature own and a short feature pooled`, `labels every feature default with rate 12 when none qualifies` | verified |
| AC-15 | Velocity `derives 12 tasks per hour from the built-in 5-minute execution default`, `derives 10 tasks per hour from an execution override of 6 minutes`; both parameter pins unmodified and passing | verified |
| AC-16 | Velocity `averages done tasks since the baseline over elapsed hours minus the pause span`, `prints n/a for the SD of 2 intervals and a finite SD for 3` | verified |
| AC-17 | Velocity `combines consecutive samples until 600 seconds have elapsed`, `forms exactly 0-20 and 20-40 from samples at 0, 7, 20, 27 and 40 minutes`, `skips a trailing remainder under 600 seconds`, `drops an interval overlapping a pause span and keeps one ending where it starts` | verified |
| AC-18 | Velocity `records a span only for a gap strictly longer than 3600 seconds`, `records the span from the earlier to the later sample of a 3601-second gap` | verified |
| AC-19 | CriticalPath `appends the reset span from the newest stored sample and keeps the ledger and anchors (AC-19)`, `appends no reset span when no sample is stored (AC-19)`; entry `keeps the durations ledger and anchors with -ResetBaseline` unmodified and passing | verified |
| AC-20 | Gather Context `tick batches exclude pause and blocked spans (issue #1153, AC-20)` (no span, pause, blocked, overlap) | verified |
| AC-21 | Metrics `prices remaining execution tasks at the override and other steps at their median` (44 min) | verified |
| AC-22 | Metrics `credits max(0, override - elapsed) at the in-progress boundaries` | verified |
| AC-23 | the nine existing Get-EpicProgressTypeEstimate cases unmodified at the merge base and passing | verified |
| AC-24 | Schedule `schedules the serial chain A -> B -> C with a 1-hour tail at 7 h (AC-24)` | verified |
| AC-25 | Schedule `schedules the diamond at 5 h with cap 4 and 7 h with cap 1 (AC-25)` | verified |
| AC-26 | Schedule `schedules four independent features at 10, 5 and 4 h for caps 1, 2 and 4 (AC-26)` | verified |
| AC-27 | Schedule `schedules three 1-hour features at cap <Cap> in <Hours> h (AC-27)`, `names the feature whose finish freed the slot at cap 2 (AC-27, AC-29)` | verified |
| AC-28 | Schedule `keeps running features beyond the cap and starts a ready feature below it (AC-28)` | verified |
| AC-29 | Schedule `starts the longest remaining path first and breaks ties by ascending issue number (AC-29)` | verified |
| AC-30 | Schedule `finishes done features at 0 without holding a slot and satisfies a dependency on them (AC-30)` | verified |
| AC-31 | Schedule `uses a checkpoint value of <Value>`, `falls back to the config value for checkpoint value <Label>`, `uses the built-in 4 when the config value is <Label>`; CriticalPath `prints the built-in cap source with no routing config and the config source with one (AC-31)`; Gather routing-cap cases | verified |
| AC-32 | Schedule source cases (checkpoint over manifest, checkpoint+manifest, manifest only, explicit empty versus waves, issue and folder-hint references, merged reference); CriticalPath AC-55 golden (`checkpoint+manifest`) and `reads no epic.md when every kickoff feature carries a checkpoint depends_on key (E5)` | verified |
| AC-33 | Schedule `reports a <Kind> with a distinct message and falls back to the waves`, `gives three different messages for the three defects`; Render.CriticalPath AC-07 graph-message line | verified |
| AC-34 | Schedule `excludes a blocked feature and its transitive dependent and keeps an independent feature`; Schedule.Range `excludes a blocked feature and its dependent and lists them with their remaining time`; Render.CriticalPath `states the blocked exclusion on the Elapsed line, and nothing when no feature is excluded (AC-34)` | verified |
| AC-35 | Schedule.Range tail cases (60 and 45 min defaults, ledger medians, in progress, done, recorded sync row in progress and done, in-progress credit, step total unchanged) | verified |
| AC-36 | `returns the eleven catalog types` and `returns the built-in default for every type` unmodified at the merge base and passing | verified |
| AC-37 | Schedule `equals the serial sum at cap 1 and never exceeds it at any cap (AC-37)` | verified |
| AC-38 | Schedule.Range `uses the across-feature SD with 2 qualifiers even when 3 intervals exist`, `uses the aggregate interval SD with 1 qualifier and 3 intervals`, `prints n/a with a reason for 1 qualifier and 2 intervals` | verified |
| AC-39 | Schedule.Range `re-runs the schedule at 12.1 and 3.9 tasks per hour for rate 8 and SD 2` | verified |
| AC-40 | Schedule.Range `has no upper bound at a slow rate of <Rate> with remaining tasks: <Expected>`, `keeps an upper bound when the slow feature has no remaining task` | verified |
| AC-41 | State.V3 `writes version 3 with the task baseline, task samples, and pauses`, `writes the features of a sample given as an object, sorted by issue` | verified |
| AC-42 | State.V3 `keeps the baselines, ledger, anchors, and samples and starts pauses empty`, `does not reset the step baseline for version 2 but still resets it for version 1`, `sets UseCurrentDoneTasks for a version-2 document`, `keeps a stored task baseline for version 3 and resets it with -ResetBaseline` | verified |
| AC-43 | State.V3 `round-trips a version-3 document unchanged`, `migrates a version-1 document and the legacy array as before`, `reads version 4, blank text, and unparseable text as empty state` | verified |
| AC-44 | CriticalPath `keeps the stored span, appends the reset span, replaces the samples and restarts the blocked span (AC-44)`; State.V3 `keeps the tasks and features values of each kept sample` | verified |
| AC-45 | SkillContract `carries both scheduling prompts with their cron expressions` (`*/20`, `7 * * * *`, no `*/10`), `describes a five-line TL;DR every 20 minutes (issue #1153, AC-45)` | verified |
| AC-46 | SkillContract `states the push-notification text rule, local cron time and jitter` (0 to 10 and 0 to 30 minutes late, the scheduled-tasks URL, no `up to 5 minutes late`) | verified |
| AC-47 | SkillContract `documents reset, cadence change, stopping and restart recovery` ("from 10 to 20 minutes", one doubling; the SD assertion replaced) | verified |
| AC-48 | SkillContract `states the report format fragments`, `states the calculation rule values`, `documents known behaviors, rates, delivery and quota policy` (version 3), `states the step model, default durations and decisions` (D1 to D13, E1 to E15, superseded and amended markers) | verified |
| AC-49 | SkillContract `stays under 500 lines` (SKILL.md 497 lines); pytest `test_epic_skill_script_citations_shipped.py` passing | verified |
| AC-50 | Schedule `calls no I/O seam and reads no clock in the Velocity and Schedule files`; entry `confines file writes to Write-EpicProgressState`, `confines native commands to their wrappers`, `contains no recovered hardcoded value` (11 production paths, 13 scan paths) | verified |
| AC-51 | SCRATCH/issue-1153-acchecks.ps1: entry function-name set equal to the merge-base set; every script at or below 800 lines | verified |
| AC-52 | evidence/qa-gates/poshqc-static.2026-11-09T16-46.md: Invoke-PoshQCLeakScan 0 failures; new tests mock Get-EpicProgressUtcNow, use in-memory fixtures and mocked seams, and define functions only inside BeforeAll | verified |
| AC-53 | SkillContract `lists every skill-folder file exactly once in core.json`, `mirrors every skill-folder file byte-identically in the bundle`; pytest push-down contract tests passing | verified |
| AC-54 | CriticalPath `prints the five TL;DR lines and the Full report through the forwarder`; forwarder and its test unchanged (no diff since the merge base) and passing | verified |
| AC-55 | CriticalPath `prints the Full golden from checkpoints with max_parallel_features and depends_on and a fixture epic.md (AC-55)` | verified |
| AC-56 | Render, entry, item-mode, State, Gather, Metrics, and SkillContract updates per the plan; `prints the velocity and range lines in both modes` replaces `prints no velocity, SD or range line in either mode` | verified |
| AC-57 | evidence/qa-gates/poshqc-static.2026-11-09T16-46.md (0 format changes, 0 findings), evidence/qa-gates/pester.2026-11-09T16-54.md (ExitCode 0), evidence/qa-gates/coverage-comparison.2026-11-09T16-54.md (every changed and new script at least 96.4%); 0 Python files added | verified |
| AC-58 | CI on the pull request head (Linux and Windows Pester shards, push-down contract tests) | pending-CI |
| US-01 | AC-01 to AC-05 rows; entry and item-mode goldens | verified |
| US-02 | Schedule `finishes five equal running features at cap 5 together (US-02)` | verified |
| US-03 | AC-12 to AC-15 rows; CriticalPath `reads the per-feature rate from the ledger merged this run (E3)` (own versus default in the per-feature table) | verified |
| US-04 | AC-24 to AC-32 and AC-35 rows | verified |
| US-05 | AC-34 row | verified |
| US-06 | AC-18 and AC-19 rows; CriticalPath `excludes a gap closed this run from the tick batch and appends one span (US-06)`, `keeps the full interval and appends no span for a gap of 3000 s (US-06)`, `excludes the reset span from the tick batch under -ResetBaseline (US-06)` | verified |
| US-07 | AC-38 to AC-40 rows | verified |
| US-08 | AC-10 row | verified |
| US-09 | AC-08 row (eight running features with five-digit task counts under 200 characters) | verified |
| US-10 | AC-45 to AC-47 rows | verified |
| US-11 | AC-42 row; CriticalPath `prints the aggregate over 0 intervals and writes the current task baseline on the first run after a version-2 migration (E12)` (written version 3) | verified |
| US-12 | AC-15 and AC-54 rows | verified |
| US-13 | AC-06 and AC-07 rows; CriticalPath `prints identical lines with and without -WaveOverheadHours (E10)` | verified |
