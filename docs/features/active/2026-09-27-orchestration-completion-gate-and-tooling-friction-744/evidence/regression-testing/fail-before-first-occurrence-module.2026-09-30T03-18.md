# Fail-Before: First-Occurrence Regression Module

Timestamp: 2026-10-02T01-17
Command: poetry run pytest tests/scripts/dev_tools/pr_context/test_verification_evidence_first_occurrence.py -q
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Run against the unmodified parser.
- Result line: `5 failed, 10 passed in 0.13s`
- FAILED nodes (exactly the five first-occurrence tests):
  - test_two_gate_file_pairs_first_command_with_first_expectation
  - test_duplicated_timestamp_takes_first_occurrence
  - test_duplicated_command_takes_first_occurrence
  - test_duplicated_exit_code_takes_first_occurrence
  - test_empty_second_command_does_not_make_record_unparseable
- The ten `test_single_occurrence_record_is_unchanged` cases (shape-01..05, 07..11) passed.
