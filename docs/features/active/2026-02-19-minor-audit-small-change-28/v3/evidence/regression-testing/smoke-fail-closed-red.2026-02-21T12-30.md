Timestamp: 2026-02-21T12-30
Command: poetry run pytest tests/unit/test_minor_audit_mode_smoke.py -k "fails_closed_to_full_for_missing_or_malformed_marker"
EXIT_CODE: 1
Output Summary:
- Selected smoke test failed as expected in red phase.
- Failure cause: missing fixture file `tests/fixtures/minor_audit_mode/issue.missing-marker.md`.
- Pytest result: 1 failed, 2 deselected.
