# Fail-Before: UnknownEnumMemberError Member Selection (Issue #890)

Timestamp: 2026-10-12T20-20
Task: P1-T2 [expect-fail]
Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_errors.py`
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `3 failed, 2 passed in 0.11s` against the unfixed `scripts/dev_tools/_parallel_mutation_errors.py`.

Failing node IDs (exactly the three expected):

- `tests/scripts/dev_tools/test_parallel_mutation_errors.py::test_unknown_disposition_lists_disposition_members` (message listed merge-status members)
- `tests/scripts/dev_tools/test_parallel_mutation_errors.py::test_decide_removal_disposition_rejection_lists_dispositions` (message listed merge-status members)
- `tests/scripts/dev_tools/test_parallel_mutation_errors.py::test_unmapped_field_name_is_rejected_explicitly` (`Failed: DID NOT RAISE <class 'ValueError'>`)

Passing: `test_unknown_state_lists_item_state_members`, `test_unknown_merge_status_lists_merge_status_members`.
