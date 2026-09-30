---
Timestamp: 2026-09-30T14-23
Command: grep -rn -F --include=*.py "test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion" tests/
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: No match; the old function name is not present in any Python file under tests/
---

# Regression Test — Old Name Absence

Verifies that the old function name has been completely removed from the test suite.

## Result

Exit code: 1 (no match found)

The old function name `test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion` does not appear in any Python file under the `tests/` directory. The rename was successful and complete.
