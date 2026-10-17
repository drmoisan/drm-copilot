# Python Abandon Parity Lane (P2-T13)

Timestamp: 2026-09-29T18-00
Command: poetry run pytest -v tests/scripts/dev_tools/test_parallel_abandon_ba?h_parity.py
EXIT_CODE: 0
Output Summary:
- `11 passed in 0.09s`; no FAILED line.
- PASSED: `test_abandon_corpus_meets_floor`, `test_abandon_corpus_covers_every_named_case`
- PASSED, one per C2 name (9):
  - `test_reference_matches_abandon_fixture[gh-close-fails]`
  - `test_reference_matches_abandon_fixture[gh-not-on-path]`
  - `test_reference_matches_abandon_fixture[git-remove-fails]`
  - `test_reference_matches_abandon_fixture[joined-option-form]`
  - `test_reference_matches_abandon_fixture[option-abbreviation]`
  - `test_reference_matches_abandon_fixture[refuse-detach-disposition]`
  - `test_reference_matches_abandon_fixture[refuse-missing-confirmation]`
  - `test_reference_matches_abandon_fixture[success]`
  - `test_reference_matches_abandon_fixture[unknown-option]`

The file path `tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py` is spelled with the
Shell route glob in the command text.
