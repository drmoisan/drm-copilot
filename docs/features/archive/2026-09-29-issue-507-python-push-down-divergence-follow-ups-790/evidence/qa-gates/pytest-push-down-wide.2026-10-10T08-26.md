# Final QC Wide Push-Down Pytest (P6-T6)

Timestamp: 2026-10-10T08-26
Command: poetry run pytest tests/scripts/dev_tools -k push_down
EXIT_CODE: 0
Output Summary:
- Loop iteration: 1.
- Collection: `collected 6701 items / 6120 deselected / 581 selected`.
- Summary line: `581 passed, 6120 deselected in 1.65s`. No failed test.
- Passed count check: P0-T11 passed (539) + 42 = 581. Meets the "at least" condition exactly.
- No PRE-EXISTING ONLY outcome.
- Execution note: a preceding invocation with extra flags (`-q -p no:randomly`) also reported 581 passed; it was discarded and the exact plan command above was run for this record.
