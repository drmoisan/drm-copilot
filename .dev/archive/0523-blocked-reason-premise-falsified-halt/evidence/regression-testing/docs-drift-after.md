# P6-T8 Documentation drift tests after the documentation edits

Timestamp: 2026-09-30T10-55
Command: poetry run pytest tests/scripts/dev_tools/test_orchestrator_state_blocked_reason.py -k test_docs_
EXIT_CODE: 0
Output Summary:
- Final line: `32 passed, 22 deselected in 0.09s` (0 failed).
- 32 = 12 enumeration-member cases + 6 documentation-only-member cases + 12 rules-section-member cases + the #484 extension-line test + the partition-paragraph test.
- All 19 failures recorded in `docs-drift-expect-fail.md` now pass.
