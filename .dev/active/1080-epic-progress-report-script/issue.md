# epic-progress-report-script (Issue #1080)

- Date captured: 2026-11-04
- Author: drmoisan
- Status: Promoted -> docs/features/active/epic-progress-report-script/ (Issue #1080)

- Issue: #1080
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1080
- Last Updated: 2026-11-04
- Work Mode: minor-audit

## Problem / Why

During epic 1019 the coordinator produced a TL;DR and an hourly progress update (tasks done, per-feature status, average and recent velocity, SD, time-remaining range, weekly quota) with an ad hoc PowerShell script that lived in a temporary scratchpad. The script was lost twice (container restarts) and had to be recreated from the session transcript. It hardcoded the epic, the start time and the baseline. A reusable, tested tool in the repository removes that loss and lets any coordinator run the same report for any epic.

## Proposed Behavior

Add `scripts/dev-tools/Get-EpicProgressReport.ps1` (PowerShell 7, advanced function style, `-Mode TLDR|Full`) that is read-only (git, gh and cswap queries only) and prints the same TL;DR block and full hourly report as the recovered script. The pure logic (task counting from plan checkboxes, phase detection, velocity average, recent velocity, sample SD, the 2.05 x SD range, critical-path wave estimate, formatting) lives in functions that take data in and return data, separate from the I/O (git, gh, cswap, files, clock) behind small wrapper seams. Parameters replace the hardcoded values: epic folder name or kickoff path, integration branch, baseline start time (UTC) and baseline task count, wave overhead hours (default 1.25), state file path (default under the system temp directory, never inside the repository), and an optional sample cap (default 14). The state file keeps one sample per check-in at least 90 seconds apart. The recovered original is at `scratchpad/recovered/epic-progress.recovered.ps1` of the coordinator session (also described in `.claude/agent-memory/epic-orchestrator/epic-1019-velocity-history.md`); the implementer will be given its source.

## Acceptance Criteria

Finalized by the orchestrator from the early draft in the promoted record. The recovered coordinator script (outside every repository) is the behavioral reference; its output wording is kept except where a criterion below changes it.

- [x] AC1: The script lives at `scripts/dev-tools/Get-EpicProgressReport.ps1` with a mirrored Pester 5 test at `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`; at most three production files are added (a split into a small module is used only when the file-size tiers require it); every production and test file stays at or below 800 lines; and the branch passes PoshQC format, analyze and test with zero analyzer findings, zero failed tests, and line coverage of at least 85 percent for each new production file.
- [x] AC2: `-Mode TLDR` prints exactly the four-line block of the recovered script (the `**TL;DR:**` line, the `**Elapsed:**` line with the wave-parallel hours and the weekly quota, the `**Avg Velocity:**` and `**Recent Velocity:**` line with the SD and the interval count, and the `**Estimated time remaining:**` line); `-Mode Full` (the default) prints the same block followed by the status heading, the Elapsed and Progress line, the State table, the Wave table with its Total row, the Velocity and Remaining line, the straight-line and wave-parallel lines, and the weekly-quota line, with the recovered wording. The epic issue number and epic name in the text come from the parameters (or the kickoff file), not from literals.
- [x] AC3: No hardcoded epic name, epic issue, integration branch, kickoff path, coordinator path, start time, baseline task count, weekly baseline, wave overhead, sample cap or drive path remains. They are parameters, each mandatory or with a default documented in the comment-based help: `-EpicFolder` (mandatory), `-StartUtc` (mandatory), `-EpicIssue` (default: parsed from the kickoff line `Epic issue: #<n>`), `-IntegrationBranch` (default `origin/epic/<EpicFolder>-integration`), `-KickoffPath` (default `docs/features/epics/<EpicFolder>/epic-kickoff.md`), `-RepositoryRoot` (default: current location), `-CheckpointPath` (default `artifacts/orchestration/epic-orchestrator-state.json` under the repository root), `-BaselineDone` (default 0), `-BaselineWeeklyPct` (default 0), `-WaveOverheadHours` (default 1.25), `-StatePath` (default: a file under the system temporary directory, never inside the repository), `-SampleCap` (default 14) and `-Mode` (`TLDR` or `Full`). Paths are built with `Join-Path`; the kickoff feature-row parser accepts any numeric issue number.
- [x] AC4: The pure logic is in functions that take data in and return data, with Pester unit tests on fixed inputs: plan task counting from `- [ ]`/`- [x] [P#-T#]` checkboxes, current-phase detection, state classification (Completed, Running, Pending), average velocity since the baseline, recent velocity (intervals of at least 2 minutes, negative rates clamped to 0), sample SD (only with at least 3 intervals), the range of average velocity plus or minus 2.05 SD (with the 0.5 tasks per hour threshold and the no-upper-bound wording), the critical-path wave estimate, the sample-retention rule (a new sample only when at least 90 seconds after the last, capped at `-SampleCap`), and the two hours formatters.
- [x] AC5: Every value the recovered script printed as `NaN` (zero elapsed time, zero velocity before any task completes, missing quota) prints `n/a`, including the straight-line and wave-parallel hours, the `about <n> hours left` figure, the range and the weekly quota and its delta; a unit test covers each case.
- [x] AC6: All I/O is behind wrapper functions: `Invoke-GitExe`, `Invoke-GhExe` and `Invoke-CswapExe`, each taking a single array parameter, plus wrappers for file existence, file read, state-file write and the UTC clock. Tests mock these wrappers with matching signatures; no test creates temporary files, calls the network, starts git, gh or cswap, or reads the wall clock.
- [x] AC7: When `cswap` or `gh` is not installed, or returns no parseable output, the report still prints: the quota shows `n/a` and the PR state is empty, with no terminating error; a test covers each absence.
- [x] AC8: The tool is read-only toward the repository and GitHub: the only git commands are `fetch`, `show` and `worktree list`; the only gh command is `pr list`; the only file it writes is the state file at `-StatePath`. A test asserts the git and gh argument lists the wrappers receive.
- [x] AC9: The script carries comment-based help (synopsis, description, every parameter, and at least one `.EXAMPLE`); no dev-tools documentation page exists under `scripts/dev-tools/`, so the help is the usage documentation. The script is not added to any push-down pack manifest.

## Constraints & Risks

- PowerShell only (no new Python). File size under the repository limits. Public repository: no host paths, tokens or account names in the script, tests or fixtures.
- cswap and gh may be absent in a destination environment: the script must degrade (quota shown as n/a) instead of failing.
- Linux and Windows path handling: build paths with Join-Path; do not rely on drive letters.
- The script must not be added to any push-down pack manifest unless the plan shows it is required; keep it a dev-tools script.

## Test Conditions to Consider

- [ ] Unit coverage areas: checkbox counting, phase heading detection, state classification (Completed, Running, Pending), velocity and SD math, range formatting, hours formatting, sample-cap and 90-second spacing rules.
- [ ] Integration scenarios: a Full and a TLDR run against mocked git, gh and cswap output.
- [ ] CLI examples: `pwsh -NoProfile -File scripts/dev-tools/Get-EpicProgressReport.ps1 -EpicFolder documentation-estate-tooling -Mode TLDR -StartUtc 2026-11-04T13:55:00Z -BaselineDone 261`.

## Next Step

- [x] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/epic-progress-report-script/` folder from the template
