# Final Pester line coverage — issue #598

Timestamp: 2026-08-30T02-24
Task: [P10-T4]

Command:
`pwsh -NoProfile -Command "$x = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml'); $c = @($x.report.counter) | Where-Object { $_.type -eq 'LINE' }; '{0:N2}' -f (100 * ([double]$c.covered) / (([double]$c.covered) + ([double]$c.missed)))"`

This is the same command and the same report-level `counter type="LINE"` derivation as `[P0-T8]` and
`[P0-T17]`. It reads the coverage file produced by the `[P10-T3]` run.

EXIT_CODE: 0

Output Summary:

FinalLineCoveredCount: 7337
FinalLineMissedCount: 403
FinalLineCoveragePercent: 94.79
PostMergeBaselineLineCoveragePercent: 94.78
SupersededPreMergeLineCoveragePercent: 94.72
LineCoverageDelta: 0.01

`PostMergeBaselineLineCoveragePercent:` is copied verbatim from
`evidence/baseline/pester-line-coverage-postmerge.2026-08-29T23-10.md:22`, written by `[P0-T17]`,
whose recorded counts are covered 7317 and missed 403.

`SupersededPreMergeLineCoveragePercent:` is copied verbatim from
`evidence/baseline/pester-line-coverage.2026-08-29T20-30.md`, written by `[P0-T8]`. It is recorded
for audit only and is not the comparand.

`LineCoverageDelta:` is the final percent minus the post-merge baseline percent:
94.79 - 94.78 = 0.01.

## Movement

Covered lines rose from 7317 to 7337, an increase of 20. Missed lines are unchanged at 403. The
increase is attributable to the 8 tests this feature added, which execute additional lines in the
modules under test; no previously covered line became uncovered, which is consistent with the
missed count holding constant.

## Comparand selection

The delta is computed against the post-merge baseline, not the pre-merge figure of 94.72, because
the pre-merge figure was measured on a tree without the merged-in suites and a delta against it
would report the merge's effect on coverage rather than this feature's.

The `[P8-T3]` batch-gate coverage headline of `94.25%` is likewise not the comparand and is not used
here. That gate ran with `-ScanFolders @('tests/scripts')` and reported Pester's command-coverage
percentage, whereas both the `[P0-T17]` baseline and this task derive line coverage from an
unscoped full-suite run. The two figures measure different things over different denominators.

Pester measures line and command coverage only. It does not measure branch coverage, so no
branch-coverage threshold applies and none is asserted here. `.claude/rules/quality-tiers.md` records
the same exemption.

## Acceptance evaluation

- `FinalLineCoveragePercent:` is `94.79`, which is at least `85.00`.
- `LineCoverageDelta:` is `0.01`, which is not negative.

Both acceptance conditions hold.
