# Fresh Single-Process Pester Run over tests/scripts (issue #1001)

Timestamp: 2026-10-31T06-50
Command: sh SCRATCH/issue-1001-run.sh SCRATCH/issue-1001-pester.ps1 -Paths tests/scripts -Tag single (one fresh PowerShell 7 process; Invoke-Pester with Run.Path = tests/scripts; JUnit to artifacts/pester/pester-junit.xml)
EXIT_CODE: 0

Output Summary (read from artifacts/pester/pester-junit.xml): tests=13518, failures=0, errors=0, skipped=10, suites=478. Pester PassThru agrees: 13508 passed, 0 failed, 10 skipped, 0 not run, 0 failed containers.

Failing tests: none.
Pre-existing failures recorded: none (no failure occurred, so no comparison against the MERGE_BASE tree was required).
