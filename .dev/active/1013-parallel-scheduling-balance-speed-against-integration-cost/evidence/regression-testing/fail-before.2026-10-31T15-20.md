# Fail-Before Run — New Python Test Modules

Timestamp: 2026-10-31T15-20
Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_aggregate.py tests/scripts/dev_tools/test_blast_radius_aggregate_properties.py tests/scripts/dev_tools/test_blast_radius_combination.py tests/scripts/dev_tools/test_blast_radius_combination_threshold.py tests/scripts/dev_tools/test_blast_radius_contract_weight.py -q -p no:cacheprovider -rA --no-cov
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: collection succeeded (0 collection errors); 145 failed, 8 passed against the pre-change production code.

## Failing nodes per module

| Module | Failed | Passed |
|---|---|---|
| `tests/scripts/dev_tools/test_blast_radius_aggregate.py` | 39 | 0 |
| `tests/scripts/dev_tools/test_blast_radius_aggregate_properties.py` | 26 | 0 |
| `tests/scripts/dev_tools/test_blast_radius_combination.py` | 25 | 0 |
| `tests/scripts/dev_tools/test_blast_radius_combination_threshold.py` | 10 | 6 |
| `tests/scripts/dev_tools/test_blast_radius_contract_weight.py` | 45 | 2 |

Every test that exercises a new symbol (`select_capped_pairs`, `find_combinations`, `has_same_file_overlap`, `COMBINATION_THRESHOLD_DEFAULT`, `ConflictTolerance.combination_threshold_percent`), the `contract` weight, or a committed `combination_threshold_percent` or `contract` value fails. The purity tests fail on the missing modules, and `test_aggregate_module_has_no_runtime_import_of_scheduling` fails because `scripts/dev_tools/_blast_radius_aggregate.py` does not exist yet.

## Nodes passing at the branch base (regression guards)

- `tests/scripts/dev_tools/test_blast_radius_combination_threshold.py::test_reader_rejects_an_invalid_value[negative]`
- `tests/scripts/dev_tools/test_blast_radius_combination_threshold.py::test_reader_rejects_an_invalid_value[float]`
- `tests/scripts/dev_tools/test_blast_radius_combination_threshold.py::test_reader_rejects_an_invalid_value[string]`
- `tests/scripts/dev_tools/test_blast_radius_combination_threshold.py::test_reader_rejects_an_invalid_value[true]`
- `tests/scripts/dev_tools/test_blast_radius_combination_threshold.py::test_reader_rejects_an_invalid_value[false]`
- `tests/scripts/dev_tools/test_blast_radius_combination_threshold.py::test_reader_still_rejects_an_unknown_sibling_name`
- `tests/scripts/dev_tools/test_blast_radius_contract_weight.py::test_reader_rejects_an_unknown_extra_weight_name`

The pre-change reader rejects `combination_threshold_percent` as an unknown member with a `ValueError` whose message contains that name, and rejects the extra weight name (with `contract`) as unknown with a `ValueError` naming `config["conflict_tolerance"]["weights"]`.

One further node passes at the base: `tests/scripts/dev_tools/test_blast_radius_contract_weight.py::test_invariant_domain_carries_shared_contracts`. It asserts only that the fixed invariant item set contains pairs sharing zero, one, and two contract identifiers (a property of the test's own data), and calls no production function; it exercises no new symbol, weight, or committed value.
