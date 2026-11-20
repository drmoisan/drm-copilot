# Pester JUnit Baseline (P0-T24)

Timestamp: 2026-10-16T01-06

Command: sh SCRATCH/issue-929/P0-T24-1.sh
Script: `[xml]$j = Get-Content -LiteralPath artifacts/pester/pester-junit.xml -Raw; $root = [regex]::Escape(((Get-Location).Path -replace '\\', '/')); $s = $j.SelectSingleNode('/testsuites'); 'TESTS=' + $s.GetAttribute('tests') + ' FAILURES=' + $s.GetAttribute('failures') + ' ERRORS=' + $s.GetAttribute('errors'); $j.SelectNodes('//testcase[failure or error]') | ForEach-Object { 'FAILED_CASE | ' + (($_.GetAttribute('classname') -replace '\\', '/') -replace $root, 'WORKTREE_ROOT') + ' | ' + $_.GetAttribute('name') }; 'COVERAGE_XML_WRITE_UTC=' + (Get-Item -LiteralPath artifacts/pester/powershell-coverage.xml).LastWriteTimeUtc.ToString('o')`
EXIT_CODE: 0
Output:
```
TESTS=5319 FAILURES=0 ERRORS=0
COVERAGE_XML_WRITE_UTC=2026-10-16T01:04:51.7872413Z
```

Output Summary: baseline `FAILURES=0` and `ERRORS=0`; no `FAILED_CASE |` line, so the pre-existing failed-case set is empty. UNATTRIBUTED-BLOCK-OR-CONTAINER-FAILURES: 0. `COVERAGE_XML_WRITE_UTC` (2026-10-16T01:04:51Z) is later than the P0-T23 `RUN_START_UTC` (2026-10-16T00:46:26Z). No recorded line contains a host absolute path.
