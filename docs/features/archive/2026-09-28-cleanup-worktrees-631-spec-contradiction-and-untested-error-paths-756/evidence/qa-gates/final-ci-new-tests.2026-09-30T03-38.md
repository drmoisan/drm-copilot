# Final CI new-test results (P2-T12)

Timestamp: 2026-10-08T02:15:00Z
Command: gh run view 37716284664 --log --job 113113368962, searched for TAP lines (Grep tool equivalents of grep -cF 'run_report_scans: ', grep -cF 'classify_all_branches: a hard pairwise probe', grep -cE 'not ok [0-9]+ ')
EXIT_CODE: 0
Output Summary: TAP ok lines for the new tests: "ok 452" and "ok 453" classify_all_branches: a hard pairwise probe (count 2, expected 2); "ok 454" through "ok 459" run_report_scans: (count 6, expected 6). Search for 'not ok [0-9]+ ' returned 0 matches (expected 1 (zero matches) for grep exit code). The bats suite ran the full tests/shell tree in the CI job, so global TAP numbers are 452-459 rather than 11-18.
