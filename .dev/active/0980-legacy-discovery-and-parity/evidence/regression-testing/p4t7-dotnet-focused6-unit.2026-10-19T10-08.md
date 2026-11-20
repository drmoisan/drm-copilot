# P4-T7 .NET parser scoped gate

Timestamp: 2026-10-19T10-08
Command: poetry run pytest tests/discovery_runtime/analyzer/test_dependency_dotnet.py -o addopts= -v --cov=drm_copilot_discovery.analyzer.dependency_dotnet --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p4t7-dotnet-focused6-coverage.json
EXIT_CODE: 0

Path rendering uses WORKSPACE and SCRATCH tokens; exact streams are preserved by hash.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 63 items

tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_project_operations[-PackageReference-Include] PASSED [  1%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_project_operations[-PackageReference-Update] PASSED [  3%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_project_operations[-PackageReference-Remove] PASSED [  4%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_project_operations[-PackageVersion-Include] PASSED [  6%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_project_operations[-PackageVersion-Update] PASSED [  7%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_project_operations[-PackageVersion-Remove] PASSED [  9%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_project_operations[ xmlns="http://schemas.microsoft.com/developer/msbuild/2003"-PackageReference-Include] PASSED [ 11%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_project_operations[ xmlns="http://schemas.microsoft.com/developer/msbuild/2003"-PackageReference-Update] PASSED [ 12%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_project_operations[ xmlns="http://schemas.microsoft.com/developer/msbuild/2003"-PackageReference-Remove] PASSED [ 14%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_project_operations[ xmlns="http://schemas.microsoft.com/developer/msbuild/2003"-PackageVersion-Include] PASSED [ 15%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_project_operations[ xmlns="http://schemas.microsoft.com/developer/msbuild/2003"-PackageVersion-Update] PASSED [ 17%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_project_operations[ xmlns="http://schemas.microsoft.com/developer/msbuild/2003"-PackageVersion-Remove] PASSED [ 19%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_metadata_conditions_remain_separate_ambiguous_declarations PASSED [ 20%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_repeated_declarations_and_missing_version_are_preserved PASSED [ 22%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_packages_config_keeps_versions_and_tag_lines PASSED [ 23%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_lock_records_and_declared_edges[Direct] PASSED [ 25%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_lock_records_and_declared_edges[Transitive] PASSED [ 26%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_lock_records_and_declared_edges[Project] PASSED [ 28%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_json_order_is_deterministic_and_unused_metadata_is_bounded PASSED [ 30%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_values_and_locations_are_redacted[https://user:SECRET@host/file?q=SECRET] PASSED [ 31%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_values_and_locations_are_redacted[$(SECRET)] PASSED [ 33%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_values_and_locations_are_redacted[../SECRET] PASSED [ 34%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_values_and_locations_are_redacted[token:SECRET] PASSED [ 36%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_project_never_returns_partial_candidates[<] PASSED [ 38%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_project_never_returns_partial_candidates[<Wrong/>] PASSED [ 39%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_project_never_returns_partial_candidates[<Project xmlns="urn:SECRET"/>] PASSED [ 41%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_project_never_returns_partial_candidates[<Project><PackageReference Include="A"/></Project>] PASSED [ 42%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_project_never_returns_partial_candidates[<Project><ItemGroup><PackageReference/></ItemGroup></Project>] PASSED [ 44%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_project_never_returns_partial_candidates[<Project><ItemGroup><PackageReference Include=" "/></ItemGroup></Project>] PASSED [ 46%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_project_never_returns_partial_candidates[<Project><ItemGroup><PackageReference Include="A" Update="B"/></ItemGroup></Project>] PASSED [ 47%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_project_never_returns_partial_candidates[<Project><ItemGroup><PackageReference Include="A"><Version><Value>1</Value></Version></PackageReference></ItemGroup></Project>] PASSED [ 49%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_project_never_returns_partial_candidates[<!DOCTYPE Project [<!ENTITY x "SECRET">]><Project/>] PASSED [ 50%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_project_never_returns_partial_candidates[<Project xmlns:x="http://www.w3.org/2001/XInclude"><x:include href="SECRET"/></Project>] PASSED [ 52%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_packages_config[<packages xmlns="urn:SECRET"/>] PASSED [ 53%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_packages_config[<packages><other/></packages>] PASSED [ 55%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_packages_config[<packages><package/></packages>] PASSED [ 57%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_packages_config[<packages><package id=" "/></packages>] PASSED [ 58%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_packages_config[<packages><package id="A"><package id="B"/></package></packages>] PASSED [ 60%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_lock_shapes_and_duplicate_members[{] PASSED [ 61%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_lock_shapes_and_duplicate_members[[]] PASSED [ 63%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_lock_shapes_and_duplicate_members[{"version":1,"version":1,"dependencies":{}}] PASSED [ 65%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_lock_shapes_and_duplicate_members[{"version":true,"dependencies":{}}] PASSED [ 66%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_lock_shapes_and_duplicate_members[{"version":2,"dependencies":{}}] PASSED [ 68%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_lock_shapes_and_duplicate_members[{"version":1}] PASSED [ 69%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_lock_shapes_and_duplicate_members[{"version":1,"dependencies":{"net":[]}}] PASSED [ 71%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_lock_shapes_and_duplicate_members[{"version": 1, "dependencies": {"net8.0": {"Alpha": []}}}] PASSED [ 73%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_lock_shapes_and_duplicate_members[{"version": 1, "dependencies": {"net8.0": {"Alpha": {"type": "SECRET"}}}}] PASSED [ 74%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_lock_shapes_and_duplicate_members[{"version": 1, "dependencies": {"net8.0": {"Alpha": {"type": "Direct", "resolved": 42}}}}] PASSED [ 76%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_lock_shapes_and_duplicate_members[{"version": 1, "dependencies": {"net8.0": {"Alpha": {"type": "Direct", "dependencies": {"A": []}}}}}] PASSED [ 77%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_invalid_lock_shapes_and_duplicate_members[{"version": 1, "dependencies": {"net8.0": {"Alpha": {"type": "Direct", "dependencies": null}}}}] PASSED [ 79%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_limits_discard_the_entire_population[max_bytes-1-project-<Project><ItemGroup><PackageReference Include="A"/><PackageReference Include="B"/></ItemGroup></Project>] PASSED [ 80%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_limits_discard_the_entire_population[max_bytes-1-packages-lock-{"version": 1, "dependencies": {"net8.0": {"Alpha": {"type": "Direct", "dependencies": {"B": "1"}}}}}] PASSED [ 82%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_limits_discard_the_entire_population[max_nodes-1-project-<Project><ItemGroup><PackageReference Include="A"/><PackageReference Include="B"/></ItemGroup></Project>] PASSED [ 84%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_limits_discard_the_entire_population[max_nodes-1-packages-lock-{"version": 1, "dependencies": {"net8.0": {"Alpha": {"type": "Direct", "dependencies": {"B": "1"}}}}}] PASSED [ 85%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_limits_discard_the_entire_population[max_depth-1-project-<Project><ItemGroup><PackageReference Include="A"/><PackageReference Include="B"/></ItemGroup></Project>] PASSED [ 87%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_limits_discard_the_entire_population[max_depth-1-packages-lock-{"version": 1, "dependencies": {"net8.0": {"Alpha": {"type": "Direct", "dependencies": {"B": "1"}}}}}] PASSED [ 88%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_limits_discard_the_entire_population[max_candidates-1-project-<Project><ItemGroup><PackageReference Include="A"/><PackageReference Include="B"/></ItemGroup></Project>] PASSED [ 90%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_limits_discard_the_entire_population[max_candidates-1-packages-lock-{"version": 1, "dependencies": {"net8.0": {"Alpha": {"type": "Direct", "dependencies": {"B": "1"}}}}}] PASSED [ 92%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_limits_discard_the_entire_population[max_text_bytes-1-project-<Project><ItemGroup><PackageReference Include="A"/><PackageReference Include="B"/></ItemGroup></Project>] PASSED [ 93%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_limits_discard_the_entire_population[max_text_bytes-1-packages-lock-{"version": 1, "dependencies": {"net8.0": {"Alpha": {"type": "Direct", "dependencies": {"B": "1"}}}}}] PASSED [ 95%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_line_limit_encoding_and_late_json_work_failure PASSED [ 96%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_empty_documents_bom_and_invalid_selector PASSED [ 98%]
tests/discovery_runtime/analyzer/test_dependency_dotnet.py::test_xml_selected_values_are_redacted_and_exact_limits_succeed PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                                 Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_dotnet.py     126      0     66      0   100%
--------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                  126      0     66      0   100%
Coverage JSON written to file SCRATCH\p4t7-dotnet-focused6-coverage.json
============================= 63 passed in 0.23s ==============================

```
