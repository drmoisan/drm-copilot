# Fail-Before: Two-Gate First-Occurrence Regression Test

Timestamp: 2026-10-02T01-17
Command: poetry run pytest "tests/scripts/dev_tools/pr_context/test_verification_evidence_first_occurrence.py::test_two_gate_file_pairs_first_command_with_first_expectation" -q
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Run against the unmodified parser (`scripts/dev_tools/pr_context/verification_evidence.py` at base b080a69e).
- Result line: `1 failed in 0.08s`
- Assertion message: `AssertionError: expected first command 'a', got 'b'` (`assert 'b' == 'a'`), showing the parser paired the last command `b` with the first expectation `1`.
