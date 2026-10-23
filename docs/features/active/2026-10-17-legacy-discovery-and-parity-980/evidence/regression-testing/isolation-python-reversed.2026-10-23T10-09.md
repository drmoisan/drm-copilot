# P11-T6 Reversed-order run of the new or changed Python test modules

Timestamp: 2026-10-23T10-09
Command: poetry run python SCRATCH/issue-980-reversed.py SCRATCH/issue-980-changed-python-tests.txt (pytest.main in one process with -q -p no:cacheprovider --no-cov over the 229 test modules changed since the merge base of origin/main and HEAD, in reverse sorted path order: first tests/scripts/dev_tools/test_validate_discovery_schema_artifacts_more.py, last tests/discovery_runtime/analyzer/test_com_candidates.py)
EXIT_CODE: 0
Output Summary: 9329 passed, 0 failed, 0 skipped in 5702.35s (1:35:02) in one process, so no module depends on a module that normally runs before it. The first attempt through a shell launcher failed before collection with "The command line is too long" (229 paths exceed the Windows command-line limit) and was replaced by the in-process runner; no test ran in that attempt.
