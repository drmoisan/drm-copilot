# p4t7-integration-focused7-unit

Timestamp: 2026-10-19T10-52
Command: poetry run pytest tests/discovery_runtime/analyzer/test_dependencies.py tests/discovery_runtime/analyzer/test_dependency_projection_limits.py -o addopts= -v --cov=drm_copilot_discovery.analyzer.dependencies --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/p4t7-integration-focused7-coverage.json
EXIT_CODE: 0
Output Summary: scoped unit; duration 66.633 seconds. Separate exact stdout/stderr hashes and SCRATCH-relative locations qualify sanitized presentation.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 66 items

tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/package.json-package-json] PASSED [  1%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/PACKAGE-LOCK.JSON-package-lock] PASSED [  3%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/npm-shrinkwrap.json-package-lock] PASSED [  4%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/setup.cfg-setup-cfg] PASSED [  6%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/requirements.txt-requirements] PASSED [  7%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/requirements-dev.txt-requirements] PASSED [  9%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/app.csproj-project] PASSED [ 10%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/app.vbproj-project] PASSED [ 12%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/app.fsproj-project] PASSED [ 13%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/app.proj-project] PASSED [ 15%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/Directory.Packages.props-project] PASSED [ 16%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/app.targets-project] PASSED [ 18%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/packages.config-packages-config] PASSED [ 19%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/packages.lock.json-packages-lock] PASSED [ 21%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/setup.py-unsupported] PASSED [ 22%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/pyproject.toml-unsupported] PASSED [ 24%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/poetry.lock-unsupported] PASSED [ 25%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/yarn.lock-unsupported] PASSED [ 27%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/pnpm-lock.yaml-unsupported] PASSED [ 28%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/readme.txt-None] PASSED [ 30%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_dispatch_passes_exact_bytes_and_limits[package-json-parse_node_dependencies] PASSED [ 31%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_dispatch_passes_exact_bytes_and_limits[package-lock-parse_node_dependencies] PASSED [ 33%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_dispatch_passes_exact_bytes_and_limits[requirements-parse_python_dependencies] PASSED [ 34%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_dispatch_passes_exact_bytes_and_limits[setup-cfg-parse_python_dependencies] PASSED [ 36%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_dispatch_passes_exact_bytes_and_limits[project-parse_dotnet_dependencies] PASSED [ 37%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_dispatch_passes_exact_bytes_and_limits[packages-config-parse_dotnet_dependencies] PASSED [ 39%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_dispatch_passes_exact_bytes_and_limits[packages-lock-parse_dotnet_dependencies] PASSED [ 40%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_projected_facts_and_edges_preserve_source_semantics PASSED [ 42%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_redacted_edge_and_repeated_container_identity PASSED [ 43%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_pin_identity_controls_confidence[absent] PASSED [ 45%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_pin_identity_controls_confidence[wrong-bytes] PASSED [ 46%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_pin_identity_controls_confidence[wrong-revision] PASSED [ 48%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_pin_identity_controls_confidence[wrong-path] PASSED [ 50%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_pin_identity_controls_confidence[wrong-repository] PASSED [ 51%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_pin_identity_controls_confidence[duplicate] PASSED [ 53%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_unavailable_excluded_and_unsupported_inputs_do_not_parse PASSED [ 54%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_parser_failures_use_fixed_diagnostics[dependency-malformed] PASSED [ 56%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_parser_failures_use_fixed_diagnostics[dependency-encoding] PASSED [ 57%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_parser_failures_use_fixed_diagnostics[dependency-unsupported] PASSED [ 59%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_parser_failures_use_fixed_diagnostics[dependency-limit] PASSED [ 60%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_analysis_is_deterministic_and_schema_valid PASSED [ 62%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_empty_capture_and_irrelevant_inputs_have_no_fabricated_fact PASSED [ 63%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_real_parser_families_compose_with_inventory_schema PASSED [ 65%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_all_diagnostics_and_error_fallbacks_share_output_limits PASSED [ 66%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_impossible_error_envelope_raises_instead_of_emitting_over_budget[1] PASSED [ 68%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_impossible_error_envelope_raises_instead_of_emitting_over_budget[1023] PASSED [ 69%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_complete_output_budget_precedes_projection[artifact_records-1] PASSED [ 71%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_complete_output_budget_precedes_projection[document_bytes-1024] PASSED [ 72%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_complete_output_budget_precedes_projection[document_bytes-4096] PASSED [ 74%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_independent_aggregate_resource_limits[pin-count] PASSED [ 75%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_independent_aggregate_resource_limits[pin-bytes] PASSED [ 77%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_independent_aggregate_resource_limits[input-bytes] PASSED [ 78%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_independent_aggregate_resource_limits[scan-work] PASSED [ 80%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_independent_aggregate_resource_limits[path-work] PASSED [ 81%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_parser_contract_violations_cannot_escape[candidates] PASSED [ 83%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_parser_contract_violations_cannot_escape[diagnostics] PASSED [ 84%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_parser_contract_violations_cannot_escape[nodes] PASSED [ 86%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_parser_contract_violations_cannot_escape[text] PASSED [ 87%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_parser_contract_violations_cannot_escape[ordinal] PASSED [ 89%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_parser_contract_violations_cannot_escape[line] PASSED [ 90%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_invalid_public_capture_and_internal_reservations PASSED [ 92%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_pin_lookup_visits_only_each_inputs_retained_group PASSED [ 93%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_remaining_parser_resources_are_independent PASSED [ 95%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_exhausted_parser_budget_stops_before_next_call[maximum-file] PASSED [ 96%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_exhausted_parser_budget_stops_before_next_call[nodes] PASSED [ 98%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_exhausted_parser_budget_stops_before_next_call[retained-text] PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                            Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependencies.py     149      0     62      0   100%
---------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                             149      0     62      0   100%
Coverage JSON written to file SCRATCH/p4t7-integration-focused7-coverage.json
======================== 66 passed in 64.90s (0:01:04) ========================
```
