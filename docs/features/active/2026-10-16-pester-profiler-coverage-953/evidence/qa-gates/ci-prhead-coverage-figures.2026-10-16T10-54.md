# CI PR-Head Coverage Figures (P7-T6)

Timestamp: 2026-10-16T10-54
Command: gh run download 38887178530 -n poshqc-test-results -D "SCRATCH/issue-953-prhead-artifact" ; sh SCRATCH/issue-953-compare.sh <baseline> SCRATCH/issue-953-prhead-artifact/powershell-coverage.xml SCRATCH/issue-953-prhead-artifact/pester-junit.xml (CRP steps 1-7 and JRP step 2)
EXIT_CODE: 0
Output Summary: Every CRP step passed on the PR-head file. LINE 16699/18170 = 91.9%; 204 sourcefiles; JUnit 10488 tests, 0 failures, 0 errors.

LINE_COVERED: 16699
LINE_MISSED: 1471
LINE_TOTAL: 18170
LINE_PERCENT: 91.9
SOURCEFILE_COUNT: 204
JUNIT_TESTS: 10488
JUNIT_FAILURES: 0
SHA256 powershell-coverage.xml: 3d8b1ae0eec7acac79fcc4b4280e61c2bc6a9bdcfc905b2888455dea384899c6
