# p4t9-registry-focused7-unit

Timestamp: 2026-10-19T12-58
Command: poetry run pytest tests/discovery_runtime/analyzer/test_registry.py tests/discovery_runtime/analyzer/test_registry_dispatch.py tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py -o addopts= -v --cov=drm_copilot_discovery.analyzer --cov-config=SCRATCH/coverage.ini --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/coverage.json
EXIT_CODE: 0
Output Summary: scoped unit; duration 35.79 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 77 items

tests/discovery_runtime/analyzer/test_registry.py::test_registry_loads_only_explicit_core_adapters PASSED [  1%]
tests/discovery_runtime/analyzer/test_registry.py::test_registry_rejects_unavailable_selections_without_fallback[enabled0] PASSED [  2%]
tests/discovery_runtime/analyzer/test_registry.py::test_registry_selects_only_consented_fixed_optional_adapter[enabled0] PASSED [  3%]
tests/discovery_runtime/analyzer/test_registry.py::test_registry_selects_only_consented_fixed_optional_adapter[enabled1] PASSED [  5%]
tests/discovery_runtime/analyzer/test_registry.py::test_registry_selects_only_consented_fixed_optional_adapter[enabled2] PASSED [  6%]
tests/discovery_runtime/analyzer/test_registry.py::test_registry_rejects_wrong_profile_type PASSED [  7%]
tests/discovery_runtime/analyzer/test_registry.py::test_registry_requires_configured_consent_before_any_import PASSED [  9%]
tests/discovery_runtime/analyzer/test_registry.py::test_input_model_rejects_dishonest_or_ambiguous_accounting[bad-None-None] PASSED [ 10%]
tests/discovery_runtime/analyzer/test_registry.py::test_input_model_rejects_dishonest_or_ambiguous_accounting[inspected-None-None] PASSED [ 11%]
tests/discovery_runtime/analyzer/test_registry.py::test_input_model_rejects_dishonest_or_ambiguous_accounting[inspected-Not allowed-file2] PASSED [ 12%]
tests/discovery_runtime/analyzer/test_registry.py::test_input_model_rejects_dishonest_or_ambiguous_accounting[excluded-None-None] PASSED [ 14%]
tests/discovery_runtime/analyzer/test_registry.py::test_input_model_rejects_dishonest_or_ambiguous_accounting[unreadable- -None] PASSED [ 15%]
tests/discovery_runtime/analyzer/test_registry.py::test_input_model_rejects_dishonest_or_ambiguous_accounting[excluded-Excluded-file5] PASSED [ 16%]
tests/discovery_runtime/analyzer/test_registry.py::test_models_reject_untyped_rows_profile_inputs_and_collisions PASSED [ 18%]
tests/discovery_runtime/analyzer/test_registry.py::test_draft_and_input_count_limits_fail_closed PASSED [ 19%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_public_metadata_is_complete_fresh_and_import_free PASSED [ 20%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[com-interop] PASSED [ 22%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[configuration] PASSED [ 23%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[csharp-symbols] PASSED [ 24%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[dependencies] PASSED [ 25%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[dotnet] PASSED [ 27%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[event-subscriptions] PASSED [ 28%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[filesystem-access] PASSED [ 29%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[office-vsto] PASSED [ 31%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[registry-access] PASSED [ 32%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[repository] PASSED [ 33%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[test-references] PASSED [ 35%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_each_fixed_selector_resolves_its_public_class[ui-callbacks] PASSED [ 36%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_invalid_complete_selection_never_imports_optional[unknown] PASSED [ 37%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_invalid_complete_selection_never_imports_optional[module.path] PASSED [ 38%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_invalid_complete_selection_never_imports_optional[python -c command] PASSED [ 40%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_registry_checks_complete_metadata_before_optional_loading PASSED [ 41%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_combined_dispatch_preserves_accounting_identity_and_provenance[False] PASSED [ 42%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_combined_dispatch_preserves_accounting_identity_and_provenance[True] PASSED [ 44%]
tests/discovery_runtime/analyzer/test_registry_dispatch.py::test_combined_unavailable_inputs_preserve_blockers PASSED [ 45%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_production_modules_exist PASSED [ 46%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[__init__.py0] PASSED [ 48%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[api_access.py] PASSED [ 49%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[api_syntax.py] PASSED [ 50%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[com_interop.py] PASSED [ 51%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[com_syntax.py] PASSED [ 53%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[configuration.py] PASSED [ 54%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[configuration_input.py] PASSED [ 55%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[csharp_declarations.py] PASSED [ 57%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[csharp_tokens.py] PASSED [ 58%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[dependencies.py] PASSED [ 59%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[dependency_dotnet.py] PASSED [ 61%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[dependency_inputs.py] PASSED [ 62%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[dependency_node.py] PASSED [ 63%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[dependency_python.py] PASSED [ 64%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[dependency_values.py] PASSED [ 66%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[dotnet_projects.py] PASSED [ 67%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[emitter.py0] PASSED [ 68%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[event_subscriptions.py] PASSED [ 70%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[filesystem_access.py] PASSED [ 71%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[findings.py] PASSED [ 72%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[input_capture.py] PASSED [ 74%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[inventory.py0] PASSED [ 75%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[models.py0] PASSED [ 76%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[pipeline.py0] PASSED [ 77%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[registry.py] PASSED [ 79%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[registry_access.py] PASSED [ 80%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[solution_input.py] PASSED [ 81%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[test_reference_syntax.py] PASSED [ 83%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[test_references.py] PASSED [ 84%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[ui_callbacks.py] PASSED [ 85%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[xml_input.py] PASSED [ 87%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[__init__.py1] PASSED [ 88%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[__main__.py] PASSED [ 89%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[cli.py] PASSED [ 90%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[emitter.py1] PASSED [ 92%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[inventory.py1] PASSED [ 93%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[models.py1] PASSED [ 94%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_module_contains_no_banned_identifier[pipeline.py1] PASSED [ 96%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_registry_allowance_preserves_unrelated_source[\n# vsto product behavior\n] PASSED [ 97%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_registry_allowance_preserves_unrelated_source[\nUNRELATED = "outlook"\n] PASSED [ 98%]
tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py::test_registry_allowance_rejects_business_logic_inside_optional_branch PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                        Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\__init__.py       3      0      0      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\registry.py      60      0     28      0   100%
-----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                          63      0     28      0   100%
Coverage JSON written to file SCRATCH/coverage.json
============================= 77 passed in 34.04s =============================
```
