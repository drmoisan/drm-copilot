# Final QC: no fixture lines in the final format:check output (AC-2, check script)

Timestamp: 2026-10-09T06-30
Command: grep -cF "tests/fixtures/" docs/features/active/2026-10-08-root-format-check-fails-on-test-fixtures-848/evidence/qa-gates/root-format-check.2026-10-09T06-30.md
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: grep printed 0 with exit 1; the final format:check output names no path under the fixtures directory. Contrast: the P0-T7 baseline artifact prints the token on every warn line.
