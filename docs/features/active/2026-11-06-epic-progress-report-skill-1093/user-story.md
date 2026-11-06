# `epic-progress-report-skill` — User Story

- Issue: #1093
- Owner: drmoisan
- Status: Ready for planning
- Last Updated: 2026-11-06
- Spec: `spec.md` in this folder (decisions, formats, rules and acceptance criteria AC-01 to AC-31)

## Story Statement

- As an epic coordinator, I want to start the recurring TL;DR and hourly full progress reports for an epic with one skill, so that I do not depend on a past conversation or a script that can be lost on a container restart.
- As an epic coordinator, I want each report line and number explained in the skill, so that I can read the reports and judge how far to trust the estimates.
- As an epic coordinator, I want to reset the velocity baseline after a pause or outage, so that time when no work ran does not distort the averages.
- As an epic coordinator, I want to change the TL;DR cadence and recombine the earlier samples in pairs, so that the average and SD match the new interval.
- As an epic coordinator, I want to stop the scheduled jobs and recreate them after a restart or before they expire, so that reporting continues across sessions.
- As a destination-repository user, I want the skill and its script delivered by the push-down, so that I can run the same reports without copying files by hand.
- As a maintainer of this repository, I want the existing `scripts/dev-tools/Get-EpicProgressReport.ps1` path to keep working, so that existing commands and notes stay valid.

## Problem / Why

While epic 1019 ran, the coordinator posted a four-line TL;DR every few minutes and an hourly full status update with a push notification, both specified in detail by the owner. The specification, the calculation rules and the scheduling prompts existed only in a conversation and a throwaway script, which was lost twice on container restarts. Issue #1080 placed the script in `scripts/dev-tools/`, but the procedure is still undocumented, the script cannot reset a baseline or pair samples, its state file is lost when the container stops, and it does not reach destination repositories.

## Personas & Scenarios

- Persona: epic coordinator
  - A Claude Code main session (directed by the repository owner) that runs an epic of several features in waves.
  - Cares about accurate progress, a credible time-remaining range and weekly-quota burn.
  - Constraints: scheduled jobs are session-only and expire after 7 days; the container can restart; interval velocity is bursty.
  - Goal: post reports on schedule without manual composition; avoid misleading estimates after pauses.
- Persona: destination-repository user
  - A repository that receives the drm-copilot Claude customizations through the extension's push-down.
  - Cares that the skill works without files from this repository and contains nothing specific to this repository's host or epics.
  - Constraint: receives changes only after the extension is rebuilt and reinstalled.
- Persona: repository maintainer
  - Uses the #1080 path `scripts/dev-tools/Get-EpicProgressReport.ps1` in commands and notes.
- Scenario: starting reports
  1. The coordinator invokes `/epic-progress-report` for epic folder `example-epic`.
  2. It runs the script once with `-StartUtc` and `-BaselineDone`, or with `-ResetBaseline` to start from now.
  3. It creates the TL;DR job (`*/10 * * * *`) and the hourly job (`7 * * * *`) with `CronCreate`, using the skill's prompts.
  4. Each TL;DR run posts four lines verbatim; each hourly run posts the full report and sends a push notification with the TL;DR line.
- Scenario: resume after an outage
  1. Work resumes after several hours with no progress.
  2. The coordinator runs the script once with `-ResetBaseline` (with `-StartUtc` and `-BaselineDone` when the resume instant is in the past).
  3. The scheduled prompts are unchanged; the next reports measure from the resume point and show `n/a` estimates until enough intervals exist.
- Scenario: cadence change
  1. The owner asks for TL;DR check-ins every 10 minutes instead of 5.
  2. The coordinator runs the script once with `-PairSamples`, deletes the TL;DR job and recreates it at the new interval.
- Scenario: restart
  1. The container restarts. The coordinator resumes the session and runs `CronList`.
  2. It recreates any missing job; the state file under `.claude/state/` still holds the samples and baseline.

## Acceptance Criteria

Coordinator: start and read the reports

- [ ] US-AC-01: `/epic-progress-report` is available and its frontmatter grants the canonical script invocation, `CronCreate`, `CronList`, `CronDelete` and `PushNotification` (spec AC-01, AC-02).
- [ ] US-AC-02: The skill carries the TL;DR template and its variants, the Full report contents and every calculation rule in the merged tool's wording, including the range as average velocity plus and minus 2.05 SD (spec AC-03, AC-04).
- [ ] US-AC-03: The skill carries both scheduling prompts with their cron expressions, parameterized by `<epic-folder>`, invoking only the canonical script, with no baseline or pairing arguments, and states the push-notification text rule (spec AC-05).
- [ ] US-AC-04: After the first run, scheduled runs need no `-StartUtc` because the start is read from the state file; a run with no passed and no stored start stops with an error naming `-StartUtc` and `-ResetBaseline` before any git call (spec AC-16).
- [ ] US-AC-05: The TL;DR and Full outputs are byte-for-byte unchanged from the merged tool for the same inputs, and no report prints `NaN` or `Infinity` (spec AC-21, AC-22, AC-23).
- [ ] US-AC-06: The skill documents the known behaviors and measured rates, including bursty interval velocity, unreliable estimates for about two hours after a baseline, total drift, normal flat stretches, and the extra shorter interval from the hourly run (spec AC-07).

Coordinator: reset after a pause

- [ ] US-AC-07: `-ResetBaseline` discards earlier samples, records the resume start and baseline done, and leaves the weekly-quota baseline unchanged; the skill tells the coordinator to reset whenever work resumes after a pause and not to change the scheduled prompts (spec AC-06, AC-14).

Coordinator: change cadence

- [ ] US-AC-08: `-PairSamples` combines the stored samples in pairs, newest first, so that the recorded 5-minute example (mean 26.2, SD 31.4) becomes mean 27.3 and SD 23.2; the skill presents it as a one-shot command followed by recreating the TL;DR job, and notes that the conversation quoted 31.5 (spec AC-06, AC-15).

Coordinator: stop and recreate jobs

- [ ] US-AC-09: The skill explains stopping the reports with `CronList` and `CronDelete`, that `CronCreate` jobs are session-only, that `claude --resume` or `--continue` restores unexpired jobs, that recurring jobs expire 7 days after creation, and how to recreate missing jobs (spec AC-06).
- [ ] US-AC-10: The default state file `<repository root>/.claude/state/epic-progress-<EpicFolder>.json` persists the samples and baseline across a container stop where the checkout persists, is never committed, can be overridden with `-StatePath`, and still reads the merged tool's array format (spec AC-17, AC-18).

Destination-repository user

- [ ] US-AC-11 (CI-dependent): The skill folder, including its scripts, is mirrored byte-identically in the Claude bundle and listed in the `core` pack manifest, so a push-down delivers it once the extension is rebuilt and reinstalled; the skill states the rebuild-and-reinstall requirement; the push-down contract tests pass on the PR head, verified by the `CI Required Gate` and the full-run jobs (spec AC-07, AC-11, AC-12).
- [ ] US-AC-12: The skill and scripts contain no epic number, epic folder name, host path, drive letter, account name or token, and the script remains read-only toward git and GitHub (spec AC-08, AC-26).
- [ ] US-AC-13: The skill lists its prerequisites (PowerShell 7, `git`, optional `gh` and `cswap`, the kickoff and checkpoint locations) and works in a destination where `scripts/dev-tools` does not exist (spec AC-09, AC-11).

Repository maintainer

- [ ] US-AC-14: `scripts/dev-tools/Get-EpicProgressReport.ps1` forwards every argument to the canonical script and propagates a non-zero exit status (spec AC-10).
- [ ] US-AC-15 (CI-dependent): The #1080 test cases are preserved in the relocated suites, the new and changed PowerShell reaches at least 85 percent line coverage, every file stays below 700 lines, and the full toolchain passes on the PR head, verified by the `CI Required Gate` and the full-run jobs (spec AC-24, AC-27, AC-30, AC-31).

## Non-Goals

- No change to TL;DR or Full output wording, order or punctuation.
- No change to the `epic-run`, `epic-plan` or `epic-orchestrate` skills or their mirrors.
- No `.agents/skills` or `.github/skills` copy of the skill.
- No migration of a state file under the system temporary directory.
- No change to the coordinator's 93 percent quota policy or to `quota-throttling`.
- No new or edited Python.
