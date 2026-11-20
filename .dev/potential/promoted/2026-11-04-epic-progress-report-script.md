# epic-progress-report-script (Issue #1080)

- Date captured: 2026-11-04
- Author: drmoisan
- Status: Promoted -> docs/features/active/epic-progress-report-script/ (Issue #1080)

- Issue: #1080
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1080
- Last Updated: 2026-11-04
## Problem / Why

During epic 1019 the coordinator produced a TL;DR and an hourly progress update (tasks done, per-feature status, average and recent velocity, SD, time-remaining range, weekly quota) with an ad hoc PowerShell script that lived in a temporary scratchpad. The script was lost twice (container restarts) and had to be recreated from the session transcript. It hardcoded the epic, the start time and the baseline. A reusable, tested tool in the repository removes that loss and lets any coordinator run the same report for any epic.

## Proposed Behavior

Add `scripts/dev-tools/Get-EpicProgressReport.ps1` (PowerShell 7, advanced function style, `-Mode TLDR|Full`) that is read-only (git, gh and cswap queries only) and prints the same TL;DR block and full hourly report as the recovered script. The pure logic (task counting from plan checkboxes, phase detection, velocity average, recent velocity, sample SD, the 2.05 x SD range, critical-path wave estimate, formatting) lives in functions that take data in and return data, separate from the I/O (git, gh, cswap, files, clock) behind small wrapper seams. Parameters replace the hardcoded values: epic folder name or kickoff path, integration branch, baseline start time (UTC) and baseline task count, wave overhead hours (default 1.25), state file path (default under the system temp directory, never inside the repository), and an optional sample cap (default 14). The state file keeps one sample per check-in at least 90 seconds apart. The recovered original is at `scratchpad/recovered/epic-progress.recovered.ps1` of the coordinator session (also described in `.claude/agent-memory/epic-orchestrator/epic-1019-velocity-history.md`); the implementer will be given its source.

## Acceptance Criteria (early draft)

- [ ] The script lives at `scripts/dev-tools/Get-EpicProgressReport.ps1` with a mirrored test at `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`, and passes the full PoshQC format, analyze and test toolchain with line coverage of at least 85 percent for the new file.
- [ ] TLDR mode prints the four-line block (TL;DR, Elapsed and weekly quota, Avg and Recent Velocity with SD and interval count, Estimated time remaining) and Full mode adds the status tables, wave table, velocity lines and quota line, matching the recovered script's wording.
- [ ] No hardcoded epic, start time, baseline, coordinator path or drive path remains; all are parameters with documented defaults; no absolute paths are encoded.
- [ ] The velocity statistics (average since baseline, recent interval, sample SD with at least 3 intervals, range average plus or minus 2.05 SD with the no-upper-bound wording) have unit tests with fixed inputs, including the NaN and zero-velocity cases that the recovered script printed as NaN.
- [ ] Division by zero before any task completes prints `n/a` instead of NaN.
- [ ] I/O (git, gh, cswap, file system, clock) is behind wrapper functions that tests mock; no test uses temporary files, the network or the wall clock.
- [ ] The tool is read-only: it performs no git write, no gh write and no repository file write.
- [ ] A short usage section is added to the relevant dev-tools documentation if such a document exists; otherwise the script's comment-based help is sufficient.

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
