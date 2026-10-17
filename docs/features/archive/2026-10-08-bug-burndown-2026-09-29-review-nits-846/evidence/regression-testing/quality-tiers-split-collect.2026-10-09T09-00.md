# Regression: quality-tiers split collection and run ([P1-T4])

Timestamp: 2026-10-09T21-11
Command: poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py --collect-only -q
EXIT_CODE: 0
Output Summary: 47 tests collected in 0.13s. Equals Baseline-Collected 47 from [P0-T9]. The last three collected node IDs are the classification-module tests test_find_classification_errors_accumulates_qt004_and_qt008, test_committed_quality_tiers_yml_matches_live_tree, and test_committed_quality_tiers_yml_assigns_spec_tiers.

```
47 tests collected in 0.13s
```

## Block 2

Command: poetry run pytest tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py -q
EXIT_CODE: 0
Output Summary: 47 passed in 0.15s. N (47) equals the collected count and Baseline-Collected.

```
47 passed in 0.15s
```

Acceptance: collected count 47 == Baseline-Collected 47; second command exit 0 with 47 passed. PASS.
