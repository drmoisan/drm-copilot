# Review of isolated_import_state (#1048, P2-T3)

Timestamp: 2026-10-31T18-18
Command: read `isolated_import_state` in tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py; poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
RESTORES-ON-EXIT: yes

- Before the block, the helper keeps a reference to the original `sys.path` list object and a dictionary of every `sys.modules` entry for which `is_scripts_module` is true (`scripts` and every `scripts.*` name), then rebinds `sys.path` to a filtered copy and deletes those entries.
- The `finally` clause runs on normal exit and on an exception: it rebinds `sys.path` to the original list object (the filtered copy is discarded, so no entry is lost or added), deletes every `scripts`/`scripts.*` entry imported inside the block, and puts the saved module objects back with `sys.modules.update(saved_modules)`.
- No fix was needed. The test module passes: 6 passed.
