# Write-Intent Python Tests and Blast-Radius Regression (P8-T8)

Timestamp: 2026-09-27T17-02
Command: poetry run pytest -v tests/scripts/dev_tools/test_blast_radius_write_intent.py
EXIT_CODE: 0
Output Summary: The first run exited 0 with 28 passed and no FAILED or ERROR line: one PASSED line for every block B32 test, including the eight fixture stems of test_write_intent_fixture_reproduces_expected_radius and the four reader-rejection cases. The second run (poetry run pytest -v tests/scripts/dev_tools -k blast_radius) exited 0 with 577 passed, 4593 deselected, and no FAILED node; the P0-T18 baseline failure set is empty, so the acceptance (every FAILED node is in that set) holds with zero failures.

## Second command

Command: poetry run pytest -v tests/scripts/dev_tools -k blast_radius
EXIT_CODE: 0
Summary line: `577 passed, 4593 deselected in 8.43s`. No line begins "FAILED" or "ERROR".

## PASSED lines of the first run (28)

```text
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_w1_glob_mention_tokens_are_dropped PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_w1_feature_folder_glob_is_never_dropped PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_w2_multi_word_span_tokens_are_dropped PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_w3_read_task_tokens_are_dropped PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_w3_write_verb_overrides_read_verb PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_w4_tokens_outside_path_roots_are_dropped PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_w4_disabled_when_path_roots_empty PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_w5_spec_contributes_contracts_only PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_w6_placeholder_stem_tokens_are_dropped PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_shared_surface_read_citation_is_not_hard PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_flag_absent_matches_current_behavior PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_flag_false_matches_current_behavior PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_derived_radius_passes_v1_v2_in_write_intent_mode PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_write_intent_vocabularies_match_powershell PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_property_write_intent_rules_never_add_a_token PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_write_intent_fixture_reproduces_expected_radius[write-intent-glob-mention] PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_write_intent_fixture_reproduces_expected_radius[write-intent-command-span] PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_write_intent_fixture_reproduces_expected_radius[write-intent-read-task] PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_write_intent_fixture_reproduces_expected_radius[write-intent-root-anchoring] PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_write_intent_fixture_reproduces_expected_radius[write-intent-spec-contracts-only] PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_write_intent_fixture_reproduces_expected_radius[write-intent-placeholder-stem] PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_write_intent_fixture_reproduces_expected_radius[write-intent-shared-surface-read-citation] PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_write_intent_fixture_reproduces_expected_radius[write-intent-flag-absent-matches-current] PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_write_intent_reader_rejects_invalid_shape[flag-string] PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_write_intent_reader_rejects_invalid_shape[flag-int] PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_write_intent_reader_rejects_invalid_shape[path-roots-string] PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_write_intent_reader_rejects_invalid_shape[path-roots-non-string-entry] PASSED
tests/scripts/dev_tools/test_blast_radius_write_intent.py::test_normalization_keeps_feature_folder_glob_in_write_intent_mode PASSED
```

Summary line of the first run: `28 passed in 0.10s`.

## Notes

- 500-line stop conditions of P8-T6 and P8-T7 were not reached: after black, compute_blast_radius.py
  is 473 lines and _blast_radius_validation.py is 468 lines, so no logic was relocated into the
  write-intent module beyond what P8-T5 already places there.
- test_write_intent_vocabularies_match_powershell pins the three Python vocabularies to the B33
  lists. The PowerShell module does not exist until P10-T4, so the direct cross-runtime comparison
  is made by the Pester twin ('pins the same read-verb, write-verb, and placeholder-stem sets as the
  Python module'), which reads the committed Python module source and compares the PowerShell
  constants with it.
- An earlier run of the first command (before this recorded run) failed one test,
  test_shared_surface_read_citation_is_not_hard, because the test derived all three radii for the
  same feature folder, so their feature-folder globs overlapped. The test was corrected to use
  distinct folders; the production module was not changed for it.
