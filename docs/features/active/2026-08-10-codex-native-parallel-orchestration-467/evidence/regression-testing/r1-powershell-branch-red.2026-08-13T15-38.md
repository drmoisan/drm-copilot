# R1 PowerShell Branch Coverage Expected-Red Evidence

Timestamp: 2026-08-13T17-41-04:00
Command: `pwsh -NoProfile -Command '$coveragePath = "artifacts/pester/powershell-coverage.xml"; [xml]$coverage = Get-Content -Raw -LiteralPath $coveragePath; $branchCounters = @($coverage.SelectNodes("//counter[@type=''BRANCH'']")); $missed = [int](($branchCounters | Measure-Object -Property missed -Sum).Sum); $covered = [int](($branchCounters | Measure-Object -Property covered -Sum).Sum); $total = $covered + $missed; $percent = if ($total -gt 0) { 100.0 * $covered / $total } else { 0.0 }; "BRANCH_COUNTER_COUNT=$($branchCounters.Count)"; "BRANCH_COVERED=$covered"; "BRANCH_MISSED=$missed"; "BRANCH_TOTAL=$total"; "BRANCH_PERCENT=$(''{0:F6}'' -f $percent)"; if ($total -le 0) { Write-Error "PowerShell coverage has no source-attributable branch denominator."; exit 1 }; if ($percent -lt 75) { Write-Error "PowerShell branch coverage $percent% is below 75%."; exit 1 }; exit 0'`
EXIT_CODE: 1
Output Summary: The isolated assertion failed for the expected reason. The coverage XML contained zero `BRANCH` counters, zero covered branches, zero missed branches, and a zero branch denominator. No source-attributable percentage can be computed, so the required >=75% branch gate remains not PASS.

- Branch counter count: 0
- Covered branches: 0
- Missed branches: 0
- Branch denominator: 0
- Displayed branch percentage: 0.000000% (not a measured percentage; denominator is zero)
- Failure: `PowerShell coverage has no source-attributable branch denominator.`

Acceptance result: PASS for `[expect-fail]`; the named absent-counter defect produced the required non-zero exit.
