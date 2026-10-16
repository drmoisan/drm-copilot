# P1-T7 Pester result counts of the direct run

Timestamp: 2026-10-13T11-17
TIMESTAMP_RECONSTRUCTED: true
TIMESTAMP_ORIGINAL: 2026-10-13T11-34
TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-14 .. 2026-10-13T11-17
TIMESTAMP_DERIVATION: lower: first direct-run XML mtime epoch 1791890071 (2026-10-13T11:14:31Z); upper: committer time of ff1b7cbd4 confirmed in the #927 pa-n3-commit-confirmation evidence
Command: grep -c -E '^<testsuites [^>]*failures="0"' artifacts/pester/pester-junit.xml
EXIT_CODE: 0
CMD2_EXIT_CODE: 0 (grep -c -E '^<testsuites [^>]*errors="0"')
CMD3_EXIT_CODE: 0 (grep -o -E '^<testsuites [^>]*tests="[1-9][0-9]*"'; one line printed)
Output Summary: Root testsuites element reports tests="10322", failures="0", errors="0".
JUNIT_FAILURES_ZERO_MATCHES: 1
JUNIT_ERRORS_ZERO_MATCHES: 1
