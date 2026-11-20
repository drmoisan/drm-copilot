# Preflight Fixes — Issue 1080 remediation cycle 3

Timestamp: 2026-11-06T13-03
Plan: docs/features/active/2026-11-04-epic-progress-report-script-1080/remediation-plan.2026-11-06T12-43.md
Signal: PREFLIGHT: ALL CLEAR

## Fixes

1. [P2-T9] | stale or ambiguous anchor | `scripts/dev-tools/Get-EpicProgressReport.ps1` carries three `.PARAMETER KickoffPath` help blocks (script-level help, `Resolve-EpicProgressSetting`, `Invoke-EpicProgressReport`). The task text now names the script-level block, which already carries the cycle-2 feature-summary header sentence that the new sentence refers to as "that header", and states that the other two blocks are unchanged. The asserted behavior and the file set are unchanged.

## Checks performed without a fix

- Both validators pass (installed MCP validator and the branch-current Python CLI `plan` subcommand).
- Four change-set line counts match the plan (475, 670, 455, 651).
- Eight launchers exist under SCRATCH; reference artifacts `kickoff-sweep-after.*.md` and `isolation-fresh-tests-scripts.*.md` exist.
- The three mutant predictions in `## Design` were traced against the planned fixtures: mutant A fails exactly the two NB-1 throw tests, mutant B fails only the indented-row test, mutant C fails only the four-cell test.
- The new messages contain no literal forbidden by `It 'contains no recovered hardcoded value'` and no drive-letter pattern.
- No repository kickoff has an indented table line.
