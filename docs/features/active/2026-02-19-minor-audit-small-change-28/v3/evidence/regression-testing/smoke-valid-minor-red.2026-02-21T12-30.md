Timestamp: 2026-02-21T12-30
Command: poetry run pytest tests/unit/test_minor_audit_mode_smoke.py -k "selects_minor_audit_for_valid_marker"
EXIT_CODE: 1
Output Summary:
- Selected smoke test failed as expected in red phase.
- Failure cause: missing fixture file `tests/fixtures/minor_audit_mode/issue.valid-minor.md`.
- Pytest result: 1 failed, 2 deselected.
