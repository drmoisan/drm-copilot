# `epic-progress-report-skill` — User Story

- Issue: #1093
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-11-06T17-53

## Story Statement

- As a ..., I want ..., so that ...
- As a ..., I want ..., so that ...

## Problem / Why

While running epic 1019 the coordinator posted two recurring reports that the owner specified in detail: a four-line TL;DR every few minutes and a fuller hourly status update with a push notification. The owner's instructions on what the reports contain and how every number is calculated existed only in a conversation and in a throwaway script. The script was lost twice (container restarts) and had to be recreated from the session transcript. Issue #1080 (merged as PR #1087) put the script in the repository as `scripts/dev-tools/Get-EpicProgressReport.ps1` with `Get-EpicProgressReport.Logic.ps1`. What is still missing is the procedure: the report specification, the calculation rules, the scheduling prompts, the baseline-reset and cadence-change handling, and a copy of the script that reaches destination repositories through the push-down. Create a skill that carries all of it, so any coordinator in any repository can start the same reports without the original conversation.


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

- [ ] The skill exists at `.claude/skills/epic-progress-report/SKILL.md` with valid frontmatter, is invocable as `/epic-progress-report`, and documents: purpose, inputs, the exact TL;DR template, the Full report contents, every calculation rule above, the two scheduling prompts, the baseline reset, the cadence change with pairing, stopping the reports, and the known behaviors.
- [ ] The script is bundled with the skill following the repository's skill-with-scripts convention, listed in the pack manifest, and reaches a destination repository after a push-down; there is one source of truth with a parity test between any two copies (including the `scripts/dev-tools` copy from #1080, whose path and tests must keep working).
- [ ] The script supports the baseline reset, sample pairing and persistent state described above, with unit tests using fixed inputs (no temp files, no network, no wall clock): average, recent, SD with 2 and 3 or more intervals, the range and no-upper-bound wording, pairing arithmetic (including the 26.2/31.5 to 27.3/23.2 example), baseline reset, n/a handling, and both modes.
- [ ] A skill contract test checks the frontmatter, that every file the skill references exists, and that the manifest lists them.
- [ ] The TL;DR and Full outputs are byte-for-byte unchanged from the merged tool for the same inputs (regression test).
- [ ] No hard-coded epic, drive, host path, account name or token appears in the skill or script; the script remains read-only toward git and GitHub.
- [ ] Any repository documentation that enumerates skills or required checks is updated; the full toolchain, coverage threshold (85 percent lines for the new and changed PowerShell) and file-size limits pass.


## Non-Goals

Call out what is explicitly excluded from this feature.
