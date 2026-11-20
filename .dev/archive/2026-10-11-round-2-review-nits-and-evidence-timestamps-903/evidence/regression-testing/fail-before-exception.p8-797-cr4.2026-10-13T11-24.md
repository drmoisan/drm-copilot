# Fail-Before Exception: #797 CR-4 (P4-T10)

Timestamp: 2026-10-13T11-24

WhyFailingRunImpossible: CR-4 adds diagnostic messages to three assertions in `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` that already pass (`KNOWN_FILE_NAMES == adopted`, `len(KNOWN_FILE_NAMES) == 18`, `FILE_EXTENSION_PATTERN_TEXT == "[a-z][a-z0-9]*"`). The asserted conditions are unchanged, so no assertion can fail before the change.

## Alternative proof

- P4-T9 (`evidence/regression-testing/p8-797-py-pass-after.2026-10-13T11-24.md`): `test_known_file_names_are_the_adopted_set` and `test_file_extension_pattern_text_uses_explicit_ascii_classes` pass within the 138-passed run (EXIT_CODE 0).
- The literal `18` is unchanged in `assert (len(KNOWN_FILE_NAMES) == 18), f"expected 18 known file names; observed {len(KNOWN_FILE_NAMES)}"`.
