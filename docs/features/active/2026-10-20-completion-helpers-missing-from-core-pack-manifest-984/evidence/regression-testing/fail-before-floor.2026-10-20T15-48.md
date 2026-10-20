Timestamp: 2026-10-20T15-48
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_pack_manifest_dependency_closure.py -k test_scanned_source_floor_rejects_narrowed_scan -q -p no:cacheprovider --no-cov
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: expect-fail. 1 failed, 16 deselected. Failure is "Failed: DID NOT RAISE <class 'AssertionError'>": the unchanged weak floor (len(scanned) >= 1) accepts a scan narrowed to one non-anchor source.
