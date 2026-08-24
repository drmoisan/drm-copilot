Timestamp: 2026-08-22T03-37
Command: git checkout -- config/blast-radius.json && git status --short -- config/blast-radius.json && poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_every_top_level_key_is_classified_and_shared_by_both_copies
EXIT_CODE: 0
Output Summary: git status --short for the restored path produced no output, confirming a clean
restore. The rerun collected 1 item and reported "1 passed", confirming the new Python
exhaustiveness case passes again once config/blast-radius.json is restored.
