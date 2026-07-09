# Regression — Legacy Validator Byte-Identical Output (#331)

Timestamp: 2026-07-07T21-08
Command: poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py -v
EXIT_CODE: 0
Output Summary: 34 passed (23 legacy + 11 new). The 23 legacy tests from the P0-T6
reference all pass unchanged, proving byte-identical output on the legacy
folder-basename-keyed shape.

Byte-identical guarantee evidence:
- `git diff --stat tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py`
  reports "196 insertions(+)" and 0 deletions — the legacy fixtures
  (`build_valid_epic_state`) and all 23 legacy test bodies are unchanged; only new
  tests/fixtures were appended alongside.
- New logic is additive and key-gated: on a checkpoint with folder-basename
  depends_on and no `intent` key, `resolve_feature_reference` is identity and
  `validate_intent_block` is a no-op.

Legacy test set (unchanged, all passing) matches the P0-T6 reference list of 23
validator tests.
