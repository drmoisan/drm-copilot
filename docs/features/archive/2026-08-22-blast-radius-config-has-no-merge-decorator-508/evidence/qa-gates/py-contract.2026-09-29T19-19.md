# Python Contract Stage (P8-T7, iteration 1)

Timestamp: 2026-09-29T19-19
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py tests/scripts/dev_tools/test_push_down_claude_blast_radius_overlay.py -k "ac16 or ac11 or ac14"
Command actually executed: the same command with `-q -rA -p no:cacheprovider` appended (per-test PASSED lines; no pytest cache write). PARITY_TARGET = tests/scripts/dev_tools/test_push_down_claude_overlay_parity.py (507-contract-derivation.2026-09-29T18-41.md).
EXIT_CODE: 0
Output Summary:
- Result line: `6 passed, 48 deselected in 0.21s` (0 failed).
- PASSED test_push_down_claude_overlay_parity.py::test_ac16_merged_path_sets_match
- PASSED test_push_down_claude_overlay_parity.py::test_ac16_overlay_constants_match
- PASSED test_push_down_claude_overlay_parity.py::test_ac11_overlay_excluded_in_both_implementations
- PASSED test_push_down_claude_overlay_parity.py::test_ac16_corpus_composition_matches_expected
- PASSED test_push_down_claude_blast_radius_overlay.py::test_ac11_source_side_overlay_is_not_published
- PASSED test_push_down_claude_blast_radius_overlay.py::test_ac14_merged_paths_registry_shape
- Acceptance (>= 5 passed, 0 failed): PASS.
