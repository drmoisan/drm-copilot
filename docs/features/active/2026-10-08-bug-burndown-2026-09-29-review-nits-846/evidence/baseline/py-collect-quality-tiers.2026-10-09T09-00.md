# Baseline: quality-tiers contract collect-only ([P0-T9], deviation D-1)

Timestamp: 2026-10-09T20-58
Command: poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py --collect-only -q
EXIT_CODE: 0
Output Summary: final line "47 tests collected in 0.08s". Matches the research derivation of 47 (23 non-parametrized + 24 parameter cases). Only the pre-split file is named (D-1: the classification file does not exist at baseline).

Baseline-Collected: 47
