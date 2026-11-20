# Python reversed-order isolation run (P3-T3)

Timestamp: 2026-10-31T17-49
Command: poetry run python SCRATCH/issue-1013-r1-reverse.py (helper file registers a pytest plugin whose pytest_collection_modifyitems reverses the collected items of tests/scripts/dev_tools/test_blast_radius_combination.py; one process, --no-cov)
EXIT_CODE: 0
Output Summary: Order reversed. First executed: test_combination_record_to_dict_shape; last executed: test_find_combinations_matches_fixture[combination-threshold-boundary-boundary]. 26 passed, 0 failed.
