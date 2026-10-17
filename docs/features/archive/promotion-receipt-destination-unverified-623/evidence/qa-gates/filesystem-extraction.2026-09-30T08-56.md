# Filesystem Extraction (AC-9) (#623)

Timestamp: 2026-09-30T08-56
Command: grep -c -E "^class (FileSystem|RealFileSystem)\b" "scripts/dev_tools/potential_to_issue_filesystem.py"; grep -c -E "^class (FileSystem|RealFileSystem)\b" "scripts/dev_tools/potential_to_issue.py"
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary: Printed integers 2 (new module) and 0 (original module; grep exits 1 for a zero count, expected). The re-export identity test `test_filesystem_names_are_reexported` PASSED in P5-T4 (py-move-verification-pass-after.2026-09-30T08-43.md). P8-T5 (py-test-coverage.2026-09-30T08-54.md, case (a)) reported no failing node under tests/scripts/dev_tools/test_potential_to_issue.

- scripts/dev_tools/potential_to_issue_filesystem.py: 2
- scripts/dev_tools/potential_to_issue.py: 0
