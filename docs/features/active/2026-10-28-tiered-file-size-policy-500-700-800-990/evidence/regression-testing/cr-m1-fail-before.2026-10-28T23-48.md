# CR-M1 fail-before ([expect-fail], cycle 2)

Timestamp: 2026-10-28T23-48
Command: Pester 5 run (no coverage) over `tests/scripts/claude-lib/file-size-policy/FileSizePolicy.Tests.ps1` and `tests/scripts/codex-hooks/file-size-policy.Tests.ps1` after the test edits of [P1-T1] and [P1-T2] and before any production edit; launched from a `sh` script under `SCRATCH`; JUnit at `artifacts/pester/pester-junit.xml`.
EXIT_CODE: 1 (expected: the new accessor tests fail)
ExpectedExitCode: 1
Output Summary:
- total=236 passed=192 failed=44.
- All 44 failures are the new accessor tests, each failing with "The term 'Get-FileSizeExcludedSegment' is not recognized as a name of a cmdlet, function, script file, or executable program": 23 in `Describe 'Get-FileSizeExcludedSegment'` (20 name rows, the fixture-count row, the fresh-array row, the covered-path row) and 21 in the twin behavior Describe (20 name rows and the count row).
- Every other test in the two files passes: 192 passed, with the failed count (44) equal to the number of newly added tests.
