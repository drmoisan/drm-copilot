# Fail-before: Claude EditSemantics suite ([P1-T13])

Timestamp: 2026-10-08T17-49
Command: PESTER_RUN with PESTER_PATHS tests/scripts/claude-hooks/enforce-completion-consistency.EditSemantics.Tests.ps1 (unmodified hook)
EXIT_CODE: 32
ExpectedExitCode: 32
Output Summary: PASSED=4 FAILED=32 FAILED_BLOCKS=0 FAILED_CONTAINERS=0. The four passing rows are D2, D3, D5, and D8; no FAILED_TEST line carries one of those four titles. Failures are 8 flag rows, 15 edit-table rows, 5 single rows, and decision rows D1, D4, D6, D7.

Addendum (recorded at [P5-T7] remediation, 2026-10-08T18-20): the run above is the original fail-before run against the 36-test suite. One further row, `returns Failure no-old_string when old_string is empty`, was added to this suite at [P5-T7] to cover the empty-old_string branch of Invoke-SingleOccurrenceEdit (the suite now holds 37 tests and 16 It lines; the plan expectations were updated to ExpectedExitCode 33, PASSED=4, FAILED=33). The added row fails against the unmodified hook for the same reason as the other helper rows: `git show 991aae0a180a09d504b59bc9460ec4b00b85d11b:.claude/hooks/enforce-completion-helpers.ps1` contains 0 occurrences of Invoke-SingleOccurrenceEdit, so the call raises command-not-found inside the It block. The original run was not repeated against the unmodified tree because the production files had already been changed.
