# Part B Configuration Tests (P9-T11)

Timestamp: 2026-09-27T17-06
Command: poetry run pytest -v tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py "tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_class_one_keys_are_equal_across_both_committed_copies[conflict_tolerance]" tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_every_top_level_key_is_classified_and_shared_by_both_copies "tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_class_one_keys_are_equal_across_both_committed_copies[write_intent_extraction]" tests/scripts/dev_tools/test_blast_radius_mandate_reads.py::test_derive_without_the_mandate_reads_key_includes_the_citations tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py::test_derive_blast_radius_keeps_a_cited_csproj_in_paths tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py::test_validate_blast_radius_findings_are_identical_with_and_without_the_key
EXIT_CODE: 0
Output Summary: pytest exited 0 with 17 passed and no FAILED or ERROR line. Every block B16 test of the tolerance-keys module passed (four Part A cases and seven Part B cases, including test_class_two_bundled_path_roots_are_empty and the registry consumption check test_tolerance_registry_keys_are_consumed). All three block B19 nodes passed, including the Part B byte-equal case for write_intent_extraction and the exhaustiveness case with path_roots and write_intent_extraction present in both copies. All three block B44 nodes passed with the P9-T8 and P9-T9 helper updates.

## PASSED lines (17)

```text
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py::test_committed_conflict_tolerance_values[self-hosted] PASSED
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py::test_committed_conflict_tolerance_values[bundled] PASSED
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py::test_committed_conflict_tolerance_reads_cleanly[self-hosted] PASSED
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py::test_committed_conflict_tolerance_reads_cleanly[bundled] PASSED
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py::test_committed_write_intent_extraction_is_true[self-hosted] PASSED
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py::test_committed_write_intent_extraction_is_true[bundled] PASSED
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py::test_mandate_reads_include_copilot_instructions[self-hosted] PASSED
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py::test_mandate_reads_include_copilot_instructions[bundled] PASSED
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py::test_self_hosted_path_roots_match_pinned_directory_list PASSED
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py::test_class_two_bundled_path_roots_are_empty PASSED
tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py::test_tolerance_registry_keys_are_consumed PASSED
tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_class_one_keys_are_equal_across_both_committed_copies[conflict_tolerance] PASSED
tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_every_top_level_key_is_classified_and_shared_by_both_copies PASSED
tests/scripts/dev_tools/test_blast_radius_config_parity.py::test_class_one_keys_are_equal_across_both_committed_copies[write_intent_extraction] PASSED
tests/scripts/dev_tools/test_blast_radius_mandate_reads.py::test_derive_without_the_mandate_reads_key_includes_the_citations PASSED
tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py::test_derive_blast_radius_keeps_a_cited_csproj_in_paths PASSED
tests/scripts/dev_tools/test_blast_radius_mergeable_paths.py::test_validate_blast_radius_findings_are_identical_with_and_without_the_key PASSED
============================= 17 passed in 0.11s ==============================
```
