# Pass-After — Python Implementation (Phase 3 gate)

Timestamp: 2026-10-31T15-33
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_aggregate.py tests/scripts/dev_tools/test_blast_radius_aggregate_properties.py tests/scripts/dev_tools/test_blast_radius_combination.py tests/scripts/dev_tools/test_blast_radius_combination_threshold.py tests/scripts/dev_tools/test_blast_radius_contract_weight.py <the twelve P0-T6 modules> -q -p no:cacheprovider --no-cov
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: 443 passed, 5 skipped, 2 failed. The only failures are the two committed-value cases pending P4-T1.

Failing nodes (pending P4-T1, which adds `combination_threshold_percent` 400 to both committed truth tables):

- `tests/scripts/dev_tools/test_blast_radius_combination_threshold.py::test_committed_tables_carry_the_threshold_400[repository]`
- `tests/scripts/dev_tools/test_blast_radius_combination_threshold.py::test_committed_tables_carry_the_threshold_400[bundled]`

Every other test passes, including every test in `test_blast_radius_aggregate.py`, `test_blast_radius_aggregate_properties.py`, `test_blast_radius_combination.py` (including the `combination-contract-only.json` cases, AC-28), and `test_blast_radius_contract_weight.py`, and the existing strict-identity and historical-run modules. The five skips are the `manifest_m1_*` accessor-expectation skips of `test_parallel_manifest_bash_parity.py`.
