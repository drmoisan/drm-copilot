---
Timestamp: 2026-09-30T11-20
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py --collect-only -q
EXIT_CODE: 0
Output Summary:
  - Collected tests: 20
  - Old test name present: test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion
---

# Baseline — Pytest Collect

Collects the test nodes to establish baseline count and verify the presence of the old test name.

## Observed Output

20 tests collected in 0.09s

Node IDs collected:
- test_unrelated_claude_citations_do_not_contend_under_the_bundled_table
- test_two_items_editing_the_same_root_surface_contend_under_the_bundled_table
- test_class_one_keys_are_equal_across_both_committed_copies[version]
- test_class_one_keys_are_equal_across_both_committed_copies[over_breadth_fraction]
- test_class_one_keys_are_equal_across_both_committed_copies[mandate_reads]
- test_class_one_keys_are_equal_across_both_committed_copies[mergeable_paths]
- test_class_one_keys_are_equal_across_both_committed_copies[conflict_tolerance]
- test_class_one_keys_are_equal_across_both_committed_copies[write_intent_extraction]
- test_every_top_level_key_is_classified_and_shared_by_both_copies
- test_class_two_bundled_shared_surfaces_are_the_portable_set
- test_class_two_bundled_shared_surface_globs_are_empty
- test_every_separator_free_self_hosted_shared_surface_reaches_the_bundle
- test_class_three_bundled_modules_are_payload_modules_only
- **test_every_class_two_and_class_three_key_is_consumed_by_its_registered_assertion** (OLD NAME)
- test_no_committed_copy_declares_an_umbrella_module[config/blast-radius.json-path0]
- test_no_committed_copy_declares_an_umbrella_module[extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json-path1]
- test_every_separator_free_bundled_shared_surface_is_wildcard_free
- test_the_gate_compares_non_empty_collections
- test_every_committed_copy_parses_and_declares_schema_version_one[config/blast-radius.json-path0]
- test_every_committed_copy_parses_and_declares_schema_version_one[extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json-path1]

**Total: 20 tests collected**
