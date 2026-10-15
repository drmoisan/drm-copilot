# Python Fixture Suites After the Re-Pin (P4-T10)

Timestamp: 2026-10-09T04-00
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_historical_runs.py tests/scripts/dev_tools/test_blast_radius_verification_integrity.py tests/scripts/dev_tools/test_blast_radius_parity.py -q
EXIT_CODE: 0
Output Summary: `109 passed in 5.81s`; 0 failed. Passed count equals the P0-T12 count (107) plus 2, the two parametrized parity cases the new derivation-file-shaped-tokens fixture adds.
