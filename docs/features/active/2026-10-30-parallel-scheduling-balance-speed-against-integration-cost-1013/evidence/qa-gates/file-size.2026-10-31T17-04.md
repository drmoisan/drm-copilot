# QA Gate — File Size

Timestamp: 2026-10-31T17-04
Command: poetry run python SCRATCH/issue-1013-sizes.py (physical line count, `len(text.splitlines())`, of every new or edited .py, .ps1, .psm1, .ts, and .sh file in `git diff --name-status MB HEAD` and `git status --porcelain`, MB = merge base of origin/main and HEAD)
EXIT_CODE: 0
Output Summary: every new file is at or below 500 lines (largest 406, `test_parallel_issue_combination_contracts.py`); every edited code file is below 700 lines (largest 561, `scripts/dev_tools/_blast_radius_scheduling.py`).

| File | Status | Lines | Result |
|---|---|---|---|
| `.claude/lib/blast-radius/BlastRadius.psm1` | edited | 481 | PASS |
| `.claude/lib/blast-radius/BlastRadiusAggregate.psm1` | new | 154 | PASS |
| `.claude/lib/blast-radius/BlastRadiusCombination.psm1` | new | 228 | PASS |
| `.claude/lib/blast-radius/BlastRadiusScheduling.psm1` | edited | 530 | PASS |
| bundle copies of the four modules above | as source | 481, 154, 228, 530 | PASS |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-default-tolerance.test.ts` | new | 75 | PASS |
| `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-tolerance-keys.test.ts` | edited | 177 | PASS |
| `extensions/drm-copilot/test/lib/push-down/config-carriage.test-helpers.ts` | edited | 279 | PASS |
| `extensions/drm-copilot/test/lib/validate/parallel-state-tolerated-edge-fields.test.ts` | edited | 261 | PASS |
| `scripts/dev_tools/_blast_radius_aggregate.py` | new | 122 | PASS |
| `scripts/dev_tools/_blast_radius_combination.py` | new | 247 | PASS |
| `scripts/dev_tools/_blast_radius_scheduling.py` | edited | 561 | PASS |
| `tests/scripts/claude-hooks/enforce-model-routing-receipt.AuthorAsserted.Tests.ps1` | edited | 291 | PASS |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.HistoricalRuns.Tests.ps1` | edited | 143 | PASS |
| `tests/scripts/claude-lib/blast-radius/BlastRadius.Tests.ps1` | edited | 492 | PASS |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusAggregate.Tests.ps1` | new | 136 | PASS |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusCombination.Tests.ps1` | new | 184 | PASS |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.ContractWeight.Tests.ps1` | new | 281 | PASS |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.PairCost.Tests.ps1` | edited | 74 | PASS |
| `tests/scripts/claude-lib/blast-radius/BlastRadiusScheduling.Tests.ps1` | edited | 372 | PASS |
| `tests/scripts/dev_tools/test_blast_radius_aggregate.py` | new | 330 | PASS |
| `tests/scripts/dev_tools/test_blast_radius_aggregate_properties.py` | new | 261 | PASS |
| `tests/scripts/dev_tools/test_blast_radius_combination.py` | new | 287 | PASS |
| `tests/scripts/dev_tools/test_blast_radius_combination_threshold.py` | new | 152 | PASS |
| `tests/scripts/dev_tools/test_blast_radius_config_tolerance_keys.py` | edited | 167 | PASS |
| `tests/scripts/dev_tools/test_blast_radius_contract_weight.py` | new | 377 | PASS |
| `tests/scripts/dev_tools/test_blast_radius_historical_runs.py` | edited | 272 | PASS |
| `tests/scripts/dev_tools/test_blast_radius_scheduling.py` | edited | 442 | PASS |
| `tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py` | edited | 200 | PASS |
| `tests/scripts/dev_tools/test_parallel_drift_scheduling.py` | edited | 256 | PASS |
| `tests/scripts/dev_tools/test_parallel_issue_combination_contracts.py` | new | 406 | PASS |
| `tests/scripts/dev_tools/test_push_down_claude_blast_radius_default_tolerance.py` | new | 62 | PASS |
| `tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py` | edited | 150 | PASS |

Two edited modules exceed the 500-line guidance tier (`_blast_radius_scheduling.py` 561, `BlastRadiusScheduling.psm1` 530); both are below the 700-line advisory tier, and the new logic is in the four new modules.
