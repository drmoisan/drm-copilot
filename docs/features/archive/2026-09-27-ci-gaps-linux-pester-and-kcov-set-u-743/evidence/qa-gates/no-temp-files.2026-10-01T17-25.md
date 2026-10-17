# No Temporary Files in New or Modified Tests (P7-T14, AC-22)

Timestamp: 2026-10-01T17-25
Command: git diff -U0 41217012d31d35c2ee33a50be50684affd2f5f43 -- tests/ | grep -c -E '^\+.*(mktemp|BATS_TEST_TMPDIR|BATS_TMPDIR|BATS_FILE_TMPDIR|New-TemporaryFile|GetTempFileName|GetTempPath|TestDrive)'
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `0`; no added line under `tests/` references a temporary-file API.
