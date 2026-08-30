# Post-merge Pester line-coverage baseline — issue #598

Timestamp: 2026-08-29T23-10
Task: [P0-T17]

Command:
`pwsh -NoProfile -Command "$x = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml'); $c = @($x.report.counter) | Where-Object { $_.type -eq 'LINE' }; '{0:N2}' -f (100 * ([double]$c.covered) / (([double]$c.covered) + ([double]$c.missed)))"`

This is the same command and the same report-level `counter type="LINE"` derivation as `[P0-T8]`.
It reads the coverage file that `[P0-T16]` produced. The covered and missed component values were
read from the same element in the same invocation so the percentage and its inputs are consistent.

EXIT_CODE: 0

Output Summary:

The command printed `94.78`. The covered and missed values of the same report-level
`counter type="LINE"` element are 7317 and 403.

PostMergeBaselineLineCoveredCount: 7317
PostMergeBaselineLineMissedCount: 403
PostMergeBaselineLineCoveragePercent: 94.78

SupersededPreMergeLineCoveragePercent: 94.72

The superseded value is copied from `evidence/baseline/pester-line-coverage.2026-08-29T20-30.md`,
whose components were 7236 covered and 403 missed. The covered count rose by 81 and the missed count
is unchanged, so the merge added covered lines without adding uncovered ones, and the percentage rose
by 0.06 points.

## Acceptance evaluation

- `PostMergeBaselineLineCoveragePercent:` is the number `94.78`, recorded to two decimal places. It
  is a measured value, not a placeholder.
- `PostMergeBaselineLineCoveredCount:` is `7317`, which is greater than zero.
- `94.78` is at or above the 85.00 policy floor in `.claude/rules/quality-tiers.md`, so the
  `BLOCKED: post-merge line coverage below the policy floor` branch does not fire and no
  report-to-caller is required before Phase 4 resumes.

Acceptance holds. `PostMergeBaselineLineCoveragePercent:` is the comparand for `[P10-T4]`; the
`[P0-T8]` figure of 94.72 is not.
