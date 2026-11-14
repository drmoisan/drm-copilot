Timestamp: 2026-11-07T20-34
Plan: docs/features/active/2026-11-07-epic-main-sync-plain-merge-1117/plan.2026-11-07T15-24.md

## Fixes

- P0-T5: the pytest baseline asked for separate repo-wide line and branch coverage, but the terminal table prints one combined column and `addopts` supplies only an LCOV reporter. Added `--cov-report=json:SCRATCH/issue-1117-coverage-baseline.json` and stated that line and branch percentages are computed from the JSON `totals` object. Meaning of the acceptance condition is unchanged.
- P2-T4: same defect and same correction for the final gate (`--cov-report=json:SCRATCH/issue-1117-coverage-final.json`), so the comparison with the Phase 0 baseline uses the same source.

## Checked, no defect

- `contains_phrase` casefold: the three negative tests (`test_contract_fails_when_claude_main_sync_step_removed`, `test_contract_fails_when_codex_main_sync_paragraph_removed`, `test_contract_fails_on_pre_change_lifecycle_text`) still raise, because the remaining section text holds no case variant of the fragments after the block removal.
- `NUMBERED_STEP_PATTERN` is `^(\d+)\. ` with no leading-whitespace allowance, so continuation lines indented three spaces cannot read as step numbers.
- P1-T4 names the only consumer, `test_frozen_epic_surface_matches_pinned_baseline_digest`; no other test or Pester suite pins the skill digest or the removed phrases.
- Ledger entry shape satisfies `Test-ProcessReductionEntry` (Merge commit stand-in matches the pending form); no committed-ledger test pins the row or entry count.
