# Final JUnit Read and Baseline Comparison (P9-T5, QA loop pass 1)

Timestamp: 2026-10-16T05-12

## Gate 1: JUnit read

Command: sh SCRATCH/929/P9-T5-1.sh
Script: `[xml]$j = Get-Content -LiteralPath artifacts/pester/pester-junit.xml -Raw; $root = [regex]::Escape(((Get-Location).Path -replace '\\', '/')); $s = $j.SelectSingleNode('/testsuites'); 'TESTS=' + $s.GetAttribute('tests') + ' FAILURES=' + $s.GetAttribute('failures') + ' ERRORS=' + $s.GetAttribute('errors'); $j.SelectNodes('//testcase[failure or error]') | ForEach-Object { 'FAILED_CASE | ' + (($_.GetAttribute('classname') -replace '\\', '/') -replace $root, 'WORKTREE_ROOT') + ' | ' + $_.GetAttribute('name') }; 'COVERAGE_XML_WRITE_UTC=' + (Get-Item -LiteralPath artifacts/pester/powershell-coverage.xml).LastWriteTimeUtc.ToString('o')`
EXIT_CODE: 0
Output:
```
TESTS=5358 FAILURES=0 ERRORS=0
COVERAGE_XML_WRITE_UTC=2026-10-16T05:10:49.4029503Z
```

## Gate 2: baseline comparison

Command: sh SCRATCH/929/P9-T5-2.sh
Script: the JUnit comparison body of P9-T5 verbatim (no `ADDITIONAL:` path was appended to `$ts`, because P8-T10 and P8-T17 recorded none).
EXIT_CODE: 0
Output:
```
BASELINE_ARTIFACT=pester-junit-baseline.2026-10-16T01-06.md
BASELINE_FAILED_CASES=0
FINAL_FAILED_CASES=0
NOT_IN_BASELINE=0
UNRESOLVED_CLASSNAME=0
TOUCH_SET_FAILED=0
BASELINE_ERRORS=0
FINAL_ERRORS=0
ERRORS_WITHIN_BASELINE=True
```

Output Summary: `CLEAN` (`TESTS=5358 FAILURES=0 ERRORS=0`). No final `FAILED_CASE |` line. UNATTRIBUTED-BLOCK-OR-CONTAINER-FAILURES: 0. `COVERAGE_XML_WRITE_UTC` (2026-10-16T05:10:49Z) is later than the P9-T4 `RUN_START_UTC` (2026-10-16T04:52:46Z). The comparison script exits 0 with `NOT_IN_BASELINE=0`, `UNRESOLVED_CLASSNAME=0`, `TOUCH_SET_FAILED=0`, and `ERRORS_WITHIN_BASELINE=True`. The run covered the four registration suites through its scan folders (AC-22).
