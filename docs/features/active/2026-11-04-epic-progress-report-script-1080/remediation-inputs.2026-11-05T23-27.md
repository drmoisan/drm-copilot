# Remediation Inputs — Issue 1080 (cycle 1)

Timestamp: 2026-11-05T23-27
Remediation-Mode: proportionate
Source review: code-review.2026-11-05T23-23.md, policy-audit.2026-11-05T23-23.md, feature-audit.2026-11-05T23-23.md
Review verdict: PASS (no blocking findings)

## Why this cycle exists

The review verdict is PASS. The repository owner's standing instruction is that findings related to the item are fixed inside the item before merge, and that follow-up issues are filed only for unrelated findings. The findings below concern the two change-set production files and their tests, so they are fixed in this cycle rather than deferred.

## Findings in scope

1. Minor — `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1`, `Describe 'Get-EpicProgressRecentVelocityInterval'`: the inclusive 2-minute boundary (`$hours -ge (2 / 60)` in `Get-EpicProgressRecentVelocityInterval`) is not asserted. A reviewer mutant changing `-ge` to `-gt` survived. Required: add a fixture with a pair exactly 120 seconds apart and assert it is counted; the `-gt` mutant must then fail.
   Remediability: autonomous
2. Minor — `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`, `Format-EpicProgressHour` and its use in `Get-EpicProgressSummary`: a negative elapsed time (start after now) prints as `-1 h 30 min` for -0.5 h. Required: reject a future `-StartUtc` with a clear terminating error in the main script, or clamp elapsed hours at 0 in the logic; choose one, and add a test that pins the chosen behavior.
   Remediability: autonomous
3. Nit — `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`, `ConvertFrom-EpicProgressKickoffRow`: the row match requires exactly one space around the issue cell, and `[int] $cells[3]` throws on a non-numeric wave cell. Required: tolerate variable whitespace around cells and handle a non-numeric wave cell explicitly (skip the row or raise a clear error); add tests for both.
   Remediability: autonomous
4. Info — `scripts/dev-tools/Get-EpicProgressReport.ps1`, `Invoke-EpicProgressReport`: a failed `git fetch` is not reported. Required: emit `Write-Warning` when the fetch wrapper reports failure; add a test.
   Remediability: autonomous

## Out of scope (no change)

- Info: `-StatePath` directory existence (default path exists); wrappers using `2>$null` (correct for parsed output); evidence launcher naming deviation (reviewer reproduced results).

## Constraints

- File inventory stays within the four change-set files: `scripts/dev-tools/Get-EpicProgressReport.ps1`, `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`, `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`, `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1`.
- No acceptance criterion in `issue.md` changes. No new Python.
- Per-file line coverage stays at or above 85%; no file above 800 lines.
