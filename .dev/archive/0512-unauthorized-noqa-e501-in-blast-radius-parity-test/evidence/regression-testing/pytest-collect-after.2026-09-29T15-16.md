---
Timestamp: 2026-09-30T11-27
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py --collect-only -q
EXIT_CODE: 0
Output Summary:
  - Collected tests: 20 (matches baseline)
  - New test name present: test_every_class_two_and_three_key_is_consumed_by_its_registered_assertion
  - Old test name absent
---

# Regression Test — Pytest Collect After Rename

Verifies that pytest collect shows the new test name and still collects exactly 20 tests.

## Key Observations

The new test name `test_every_class_two_and_three_key_is_consumed_by_its_registered_assertion` appears in the collection (was previously named `test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion`).

The old name no longer appears in the collected tests.

**Total collected: 20 tests** (matches baseline count from P0-T8)

Complete list of collected tests:
1. test_unrelated_claude_citations_do_not_contend_under_the_bundled_table
2. test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table
3-8. test_class_one_keys_are_equal_across_both_committed_copies (6 parametrized)
9. test_every_top_level_key_is_classified_and_shared_by_both_copies
10. test_class_two_bundled_shared_surfaces_are_the_portable_set
11. test_class_two_bundled_shared_surface_globs_are_empty
12. test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle
13. test_class_three_bundled_modules_are_payload_modules_only
14. **test_every_class_two_and_three_key_is_consumed_by_its_registered_assertion** (RENAMED)
15-16. test_no_committed_copy_declares_an_umbrella_module (2 parametrized)
17. test_every_separator_free_bundled_shared_surface_is_wildcard_free
18. test_the_gate_compares_non_empty_collections
19-20. test_every_committed_copy_parses_and_declares_schema_version_one (2 parametrized)
