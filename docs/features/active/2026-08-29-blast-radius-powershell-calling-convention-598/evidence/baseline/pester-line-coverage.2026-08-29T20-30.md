# Pester line-coverage baseline — issue #598

Timestamp: 2026-08-29T20-30
Task: [P0-T8]

Command:
`pwsh -NoProfile -Command "$x = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/powershell-coverage.xml'); $c = @($x.report.counter) | Where-Object { $_.type -eq 'LINE' }; '{0:N2}' -f (100 * ([double]$c.covered) / (([double]$c.covered) + ([double]$c.missed)))"`

A companion invocation of the same shape printed the two component counts
(`'covered=' + $c.covered; 'missed=' + $c.missed`) so the percentage below is reproducible from its
inputs.

The report-level `counter` element of type `LINE` is a direct child of the `report` root in Pester's
CoverageGutters output. It reads the coverage file produced by `[P0-T7]`.

EXIT_CODE: 0

Output Summary:

BaselineLineCoveredCount: 7236
BaselineLineMissedCount: 403
BaselineLineCoveragePercent: 94.72

## Acceptance evaluation

- `BaselineLineCoveragePercent:` is the number 94.72, recorded to two decimal places, not a
  placeholder.
- `BaselineLineCoveredCount:` is 7236, which is greater than zero.
- 94.72 is at or above the 85.00 policy floor in `.claude/rules/quality-tiers.md:33`, so the
  `BLOCKED: pre-existing line coverage below the policy floor` branch of `[P0-T8]` does not fire and
  no report to the caller is required on that ground.
