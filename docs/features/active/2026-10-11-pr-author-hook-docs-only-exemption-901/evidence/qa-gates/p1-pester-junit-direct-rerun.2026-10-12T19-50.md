# P1-T7 Pester result counts of the direct run (re-evaluated after the P1-T5 re-run, second invocation)

Timestamp: 2026-10-13T11-36
Command: grep -c -E '^<testsuites [^>]*failures="0"' artifacts/pester/pester-junit.xml
EXIT_CODE: 0
CMD2_EXIT_CODE: 0 (grep -c -E '^<testsuites [^>]*errors="0"')
CMD3_EXIT_CODE: 0 (grep -o -E '^<testsuites [^>]*tests="[1-9][0-9]*"'; one line printed)
Output Summary: Root testsuites element of the re-run reports tests="10322", failures="0", errors="0".
JUNIT_FAILURES_ZERO_MATCHES: 1
JUNIT_ERRORS_ZERO_MATCHES: 1
