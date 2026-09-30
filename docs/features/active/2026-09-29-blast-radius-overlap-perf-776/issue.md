# blast-radius-overlap-perf (Issue #776)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/blast-radius-overlap-perf/ (Issue #776)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #776
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/776
- Last Updated: 2026-09-29
- Work Mode: minor-audit

## Summary

The PowerShell blast-radius path-overlap computation in `.claude/lib/blast-radius/` is slow enough to set the CI critical path. `BlastRadius.HistoricalRuns.Tests.ps1` alone takes 369s of the 698s Pester step in the PowerShell QC job, which makes the whole CI run take about 14 minutes.

## Environment

- OS/version: GitHub Actions `windows-latest` (PowerShell QC job); reproduced locally on Windows 11 Pro 10.0.26200
- Python version: not applicable (PowerShell 7, Pester 5.6.1)
- Command/flags used: `Invoke-PoshQCTest` (CI); `Invoke-Pester` against the single test file (local)
- Data source or fixture: `tests/fixtures/blast_radius/historical-runs/followups-2026-09-27.json` (11 items, 55 pairs, about 160 path entries per item)

## Steps to Reproduce

1. Check out `main` and import Pester 5.6.1.
2. Run `Invoke-Pester` on `tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1` with code coverage disabled.
3. Observe the elapsed time.

## Expected Behavior

Nine pairwise-comparison tests over three committed fixtures complete in seconds, and the file does not set the CI critical path.

## Actual Behavior

- CI run 1043 (run id 36622810274): total 14m04s. The PowerShell QC job took 838s; every other job completed in 407s or less.
- In `pester-junit.xml`, the test file took 369s for 9 tests (56% of Pester time). The single test "matches detection at tolerance 0 for followups-2026-09-27" took 178s.
- Local timing of the file alone: no coverage 190s; profiler coverage 300s; breakpoint coverage (the current CI setting) 381s. Both coverage modes reported 66.58%. The algorithm is the dominant cost, not coverage instrumentation.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `369.1s    9 tests\scripts\claude-lib\blast-radius\BlastRadius.HistoricalRuns.Tests.ps1` (ranked first of 232 Pester suites in run 1043)

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Every CI run on every PR and push to `main` waits on this file. Production scheduling calls (`Get-BlastRadiusConflictEdge`, `Test-BlastRadiusConflict`) use the same code path and slow down the same way for large parallel runs.

## Suspected Cause / Notes

- `Get-SmallestPathOverlap` (`BlastRadiusConflict.psm1`) is an O(|A| x |B|) nested loop. For the largest fixture that is about 25,000 `Test-EntryOverlap` calls per pair, and each historical test performs the full pairwise pass up to four times.
- Each inner-loop step invokes `[CmdletBinding()]` advanced functions, which carry a high per-call cost: `Test-EntryOverlap` calls `Test-GlobEntry` twice; `Get-LiteralPrefix` (`BlastRadiusGlob.psm1`) calls `Test-GlobEntry` once per character; `Test-GlobMatch` rebuilds its regex through `ConvertTo-GlobRegexText` character by character on every call and does not cache it.
- `Get-SmallestPathOverlap` accumulates every overlapping pair into a list and then takes the ordinal minimum instead of tracking the minimum directly.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: behaviour-preserving optimisation of the overlap path. Precompute each entry's glob classification and literal prefix once per collection outside the inner loop; replace the per-character `Test-GlobEntry` scan in `Get-LiteralPrefix` with one `IndexOfAny` over the wildcard set; cache compiled glob regexes in a script-scoped dictionary keyed by pattern; track the ordinally smallest overlap pair directly. Exported function signatures and outputs stay unchanged, and results stay identical to the Python port in `scripts/dev_tools/compute_blast_radius.py`.
- [ ] Integration scenario to retest: `BlastRadius.HistoricalRuns.Tests.ps1`, `BlastRadius.Parity.Tests.ps1`, and every other blast-radius Pester suite pass with no edits to their fixtures or assertions.
- [ ] Manual verification notes: record a before/after local timing of `BlastRadius.HistoricalRuns.Tests.ps1` with coverage disabled (baseline 190s), and compare the CI PowerShell QC job duration with run 1043 (838s).

## Acceptance Criteria

- [x] `BlastRadius.HistoricalRuns.Tests.ps1`, `BlastRadius.Parity.Tests.ps1`, and every other blast-radius Pester suite pass with no edits to their fixtures or assertions.
- [x] A before/after local timing of `BlastRadius.HistoricalRuns.Tests.ps1` with coverage disabled is recorded as evidence and shows a material reduction from the 190s baseline.
- [ ] The CI PowerShell QC job duration on the PR head is measurably lower than in run 1043 (838s).
- [x] Exported function signatures and return values of the blast-radius modules are unchanged.
- [x] Line coverage stays at or above 85% for every touched production file, and no touched file exceeds 500 lines.

Out of scope: changing Pester's `CodeCoverage.UseBreakpoints` setting, sharding Pester across jobs, and shell-coverage parallelisation.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
