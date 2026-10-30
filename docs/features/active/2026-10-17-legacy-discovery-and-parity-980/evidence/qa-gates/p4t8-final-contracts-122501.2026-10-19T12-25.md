# P4-T8 final contracts

Timestamp: 2026-10-19T12-25
Command: `poetry run python -m pytest -q -o addopts= --no-cov tests/schemas/discovery/test_v2_inventory_schemas.py tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_quality_tiers_contract_classification.py tests/discovery_runtime/test_package_contract.py::test_runtime_metadata_has_bounded_dependencies_and_minimum_python tests/discovery_runtime/test_package_contract.py::test_root_tooling_includes_the_local_runtime_for_types_and_coverage tests/scripts/dev_tools/discovery/test_domain_neutrality.py::test_domain_neutrality_templates_contain_no_disallowed_tokens`
EXIT_CODE: 0
Output Summary: Stage 6 of 7; exact source bindings, elapsed time and separate raw stream hashes are in the adjacent JSON.

```text
........................................................................ [ 40%]
........................................................................ [ 81%]
.................................                                        [100%]
177 passed in 1.28s

```
