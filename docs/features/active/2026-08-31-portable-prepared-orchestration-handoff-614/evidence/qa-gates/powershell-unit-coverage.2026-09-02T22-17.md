# PowerShell Unit and Coverage QA

- Timestamp: `2026-09-02T23:23:11.4150483-04:00`
- MCP input: `mcp__drm_copilot__run_poshqc_test({"workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-31T07-29"})`
- `scan_folders`: omitted
- MCP result: `ok: true`
- Exit code: `0`
- Configured JUnit artifact: `artifacts/pester/pester-junit.xml`
- Configured coverage artifact: `artifacts/pester/powershell-coverage.xml`

PASSED: 3923
FAILED: 0
ERRORS: 0
SKIPPED: 9
TOTAL: 3932
COVERED_LINES: 7437
TOTAL_LINES: 7848
LINE_COVERAGE: 94.762997%

## Artifact parser

- Command: `$j=[xml](Get-Content -LiteralPath 'artifacts/pester/pester-junit.xml' -Raw); $c=[xml](Get-Content -LiteralPath 'artifacts/pester/powershell-coverage.xml' -Raw); $cases=@($j.SelectNodes('//testcase')); $skipped=@($j.SelectNodes('//testcase/skipped')); $failures=@($j.SelectNodes('//testcase/failure')); $errors=@($j.SelectNodes('//testcase/error')); $line=@($c.report.counter | Where-Object { $_.type -eq 'LINE' })[0]; $covered=[int]$line.covered; $missed=[int]$line.missed; [pscustomobject]@{Total=$cases.Count;Passed=($cases.Count-$skipped.Count-$failures.Count-$errors.Count);Failed=$failures.Count;Errors=$errors.Count;Skipped=$skipped.Count;CoveredLines=$covered;MissedLines=$missed;TotalLines=($covered+$missed);LineCoverage=[math]::Round(100*$covered/($covered+$missed),6)} | ConvertTo-Json -Compress`
- Parser exit code: `0`
- Parsed result: `{"Total":3932,"Passed":3923,"Failed":0,"Errors":0,"Skipped":9,"CoveredLines":7437,"MissedLines":411,"TotalLines":7848,"LineCoverage":94.762997}`

## Configuration verification

- `config/poshqc-scan.json` supplies the complete configured scan scope: `scripts`, `tests/powershell`, and `tests/scripts`.
- Repository runsettings: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- Bundled runsettings: `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
- Both runsettings SHA-256: `399d6ce69c821ad47cbd33957bebe9eb8076fb622f84f686728d42d8862d9fb1`
- Both runsettings specify the configured JUnit and coverage artifact paths above.

## Acceptance verification

- No collected test failed or errored; 9 cases were intentionally skipped/disabled.
- Line coverage `94.762997%` exceeds the `85%` threshold.
- The MCP input omitted `scan_folders`, so no narrowed scan was supplied.
- Fresh artifact write times were `2026-09-02T23:22:41.9691216-04:00` for JUnit and `2026-09-02T23:20:57.3419808-04:00` for coverage.
