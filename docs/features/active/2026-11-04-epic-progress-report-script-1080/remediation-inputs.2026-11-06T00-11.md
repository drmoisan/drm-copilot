# Remediation Inputs - Issue 1080 (re-audit after cycle 1)

Timestamp: 2026-11-06T00-11
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate
Head reviewed: 79d4e3de07731e97e8dcd9e52c44d08a116bab8d
Source review artifacts:
- `docs/features/active/2026-11-04-epic-progress-report-script-1080/policy-audit.2026-11-06T00-11.md`
- `docs/features/active/2026-11-04-epic-progress-report-script-1080/code-review.2026-11-06T00-11.md`
- `docs/features/active/2026-11-04-epic-progress-report-script-1080/feature-audit.2026-11-06T00-11.md`

## Cycle-1 findings

All four findings of `remediation-inputs.2026-11-05T23-27.md` are resolved and verified by mutants (six of six killed). No cycle-1 finding carries forward.

## Blocking findings

### CR-1 (Blocking, code review severity Major): kickoff parser returns phantom feature rows from non-feature tables

Remediability: autonomous
Remediability-Evidence: The fix is confined to one function in a change-set file plus tests in the mirrored test file; no external system, policy decision, or owner input is needed.

- File: `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`, `ConvertFrom-EpicProgressKickoffRow` (lines 29-57; match at line 49).
- Defect: every Markdown table row whose first cell is numeric, in any table of the kickoff, is returned as a feature. The wave-summary table (`| wave | features | width |`) yields features `#0`, `#1`, `#2` with the `width` cell read as the wave and an empty plan path. Present in 3 of 9 repository kickoff files: `docs/features/epics/cleanup-merged-worktrees-hardening/epic-kickoff.md`, `docs/features/epics/orchestrator-state-contract-correctness/epic-kickoff.md`, `docs/features/epics/worktree-scoped-state-resolution/epic-kickoff.md`. Pre-existing at `52224c60c`.
- Impact (stubbed run on `cleanup-merged-worktrees-hardening`): TL;DR reports 11 features instead of 8; State table lists phantom Pending `#0`, `#1`, `#2`; Wave table gains a wave-4 row; wave-parallel estimate is 8 h 45 min instead of 7 h 30 min. Since cycle 1, a numeric-first-cell row in another table with a non-digit fourth cell would also abort the report with the new wave-cell error.
- Required:
  1. Parse only the feature-summary table: find its header row (first cell `issue_num` or `Issue`, case-insensitive), skip the separator row, and read rows until the first line that is not a table row. Ignore all other tables. Keep the existing whitespace tolerance and the clear non-numeric wave error for rows inside the feature table. Update the function help to describe the table it reads.
  2. Add a logic test whose kickoff fixture contains the feature table followed by a `| wave | features | width |` table with numeric first cells; assert only the feature rows are returned.
  3. Add a test that a numeric-first-cell row with a non-digit fourth cell in a non-feature table does not throw.
  4. Update existing fixtures if they rely on a header the new rule does not recognize (the logic fixture header is `| Issue | Title | Wave | Band | Plan |`; the repository kickoffs use `| issue_num | feature_folder | wave | complexity | plan-path |`); cover both header spellings.
  5. Verify by re-running the parser over every `docs/features/epics/*/epic-kickoff.md` and recording that no returned row has an empty plan path; record a mutant that removes the table restriction and show the new test fails.

## Related non-blocking item included in this cycle

Per the owner's standing instruction to fix related findings inside the item before merge, this Nit is in scope for cycle 2:

- Nit: `[int]::Parse` overflow on an all-digit wave cell longer than `Int32` gives a generic message (`ConvertFrom-EpicProgressKickoffRow`). Required: use `TryParse` and raise the same clear wave-cell error; add a test with an over-length all-digit wave cell.
  Remediability: autonomous

## Non-blocking items (no remediation required)
- Info: `returns the last native exit code` proves pass-through only; real-seam behavior was verified by the reviewer.
- Info: the fetch warning prints an empty code when `$LASTEXITCODE` is `$null` (git absent); no practical effect.

## Constraints

- File inventory stays within the four change-set files: `scripts/dev-tools/Get-EpicProgressReport.ps1`, `scripts/dev-tools/Get-EpicProgressReport.Logic.ps1`, `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`, `tests/scripts/dev-tools/Get-EpicProgressReport.Logic.Tests.ps1`.
- No acceptance criterion in `issue.md` changes. No new Python.
- Per-file line coverage stays at or above 85%; no file reaches 700 logical lines (the logic file is at 661, so keep the change compact or account for the advisory tier).
