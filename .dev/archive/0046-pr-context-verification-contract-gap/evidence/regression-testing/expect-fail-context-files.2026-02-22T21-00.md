Timestamp: 2026-02-22T21-00
Command: poetry run pytest tests/scripts/dev_tools/test_collect_pr_context.py -q -k includes_canonical_evidence_paths_in_additional_context_files
EXIT_CODE: 1
Failure: Assertion failed because no `/evidence/` path was present in `FeatureDocExcerpt.context_files`.
