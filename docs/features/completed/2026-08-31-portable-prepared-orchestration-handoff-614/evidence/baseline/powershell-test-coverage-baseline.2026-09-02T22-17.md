# PowerShell Test and Coverage Baseline

Timestamp: 2026-09-03T03-00
Command: `mcp__drm_copilot__run_poshqc_test({"workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-31T07-29"})`
EXIT_CODE: 0

Output Summary: The authoritative bundled PoshQC/Pester repository run returned `ok:true`. The MCP input omitted `scan_folders`; the configured repository scope from `config/poshqc-scan.json` was used. Fresh configured output artifacts were written under `artifacts/pester/`. JUnit reports 3,932 collected test cases: 3,923 passed, 0 failed, 0 errors, and 9 skipped/disabled. Coverage reports 7,437 of 7,848 lines covered (94.762997%).

PASSED: 3923
FAILED: 0
ERRORS: 0
SKIPPED: 9
TOTAL: 3932
COVERED_LINES: 7437
TOTAL_LINES: 7848
LINE_COVERAGE: 94.762997%

Repository runsettings path: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
Bundled parity path: `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
Runsettings SHA-256: `399d6ce69c821ad47cbd33957bebe9eb8076fb622f84f686728d42d8862d9fb1` for both paths.
Configured result: `artifacts/pester/pester-junit.xml` (last written 2026-09-03T03:00:18.5965924Z).
Configured coverage: `artifacts/pester/powershell-coverage.xml` (last written 2026-09-03T02:58:40.6808214Z).

Command: `$j=[xml](Get-Content -LiteralPath 'artifacts/pester/pester-junit.xml' -Raw); $c=[xml](Get-Content -LiteralPath 'artifacts/pester/powershell-coverage.xml' -Raw); $cases=@($j.SelectNodes('//testcase')); $skipped=@($j.SelectNodes('//testcase/skipped')); $failures=@($j.SelectNodes('//testcase/failure')); $errors=@($j.SelectNodes('//testcase/error')); $line=@($c.report.counter | Where-Object { $_.type -eq 'LINE' })[0]; $covered=[int]$line.covered; $missed=[int]$line.missed; [pscustomobject]@{Total=$cases.Count;Passed=($cases.Count-$skipped.Count-$failures.Count-$errors.Count);Failed=$failures.Count;Errors=$errors.Count;Skipped=$skipped.Count;CoveredLines=$covered;MissedLines=$missed;TotalLines=($covered+$missed);LineCoverage=[math]::Round(100*$covered/($covered+$missed),6)} | ConvertTo-Json -Compress`
EXIT_CODE: 0

Output Summary: Parsed the fresh configured JUnit and JaCoCo-compatible coverage outputs without mutating them.

```json
{"Total":3932,"Passed":3923,"Failed":0,"Errors":0,"Skipped":9,"CoveredLines":7437,"MissedLines":411,"TotalLines":7848,"LineCoverage":94.762997}
```

Command: `Get-FileHash -Algorithm SHA256 -LiteralPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1','extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1'`
EXIT_CODE: 0

Output Summary: The repository runsettings and bundled MCP resource mirror are byte-identical. No narrowed scan was supplied, no test failed, and line coverage exceeds the 85% threshold. PowerShell branch coverage is exempt because Pester does not measure it.
