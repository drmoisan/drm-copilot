# Remediation Inputs — Issue 1080 (cycle 3)

Timestamp: 2026-11-06T12-43
Remediation-Mode: proportionate
Source review: code-review.2026-11-06T12-43.md, policy-audit.2026-11-06T12-43.md, feature-audit.2026-11-06T12-43.md
Review verdict: PASS (no blocking findings; CR-1 and the overflow Nit resolved)

## Why this cycle exists

The re-audit verdict is PASS. The repository owner's standing instruction is that findings related to the item are fixed inside the item before merge. NB-1 to NB-3 all concern silent understatement in `ConvertFrom-EpicProgressKickoffRow`, and NB-1 was introduced by the cycle-2 fix, so they are fixed here as one coherent change: the parser either reads the feature table completely or fails with a clear error. This is the last remediation cycle available under the three-attempt guard; the plan must close every finding in one pass.

## Findings in scope

1. NB-1 (Minor) — `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`, `ConvertFrom-EpicProgressKickoffRow`: a non-empty kickoff with no recognized feature-summary header returns zero rows, and the report prints a plausible 0-task report. Required: throw a clear terminating error when the kickoff text is non-empty (contains any non-whitespace) and no feature-summary header is found, naming the accepted header spellings (`issue_num`, `Issue`); keep `returns no rows for an empty kickoff` unchanged; add a logic test for an unrecognized header (for example `Issue #`) and for a headerless table. Name and update any existing test that relies on the headerless behavior.
   Remediability: autonomous
2. NB-2 (Nit) — same function: inconsistent anchoring. Required: one rule for header, row, and end-of-table matches that allows leading whitespace before the first `|` (trim before splitting so cell indices stay correct); add tests for an indented header and an indented row, both read.
   Remediability: autonomous
3. NB-3 (Nit, pre-existing) — same function: a feature row with fewer than five cells, or an empty plan cell, returns `$null`/empty `PlanPath` and the feature is reported Pending with 0 tasks. Required: throw a clear error naming the issue number when a feature-table row has fewer than five cells or a blank plan cell; add tests for both.
   Remediability: autonomous

## Verification required

- Re-run the kickoff sweep over every `docs/features/epics/*/epic-kickoff.md`: no file throws, and no returned row has an empty plan path.
- Mutant demonstrations: (a) remove the no-header throw and show the new NB-1 test fails; (b) restore column-0 anchoring in the row match and show the indented-row test fails; (c) remove the short-row check and show the NB-3 test fails. Restore each and confirm a clean tree.

## Constraints

- File inventory stays within the four change-set files: `scripts/dev-tools/Get-EpicProgressReport.ps1`, `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`, `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`, `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1`.
- No acceptance criterion in `issue.md` changes. No new Python.
- Per-file line coverage stays at or above 85%; no file above 800 lines; if the logic file reaches 700 lines, record the advisory-tier disposition.
- Update the function help and `.PARAMETER KickoffPath` help to state the error behavior.
