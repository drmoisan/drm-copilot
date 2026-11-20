# P4-T8 final tests-optional-reverse

Timestamp: 2026-10-19T12-24
Command: `poetry run python -m pytest -v -o addopts= tests/discovery_runtime/analyzer/test_optional_limits.py tests/discovery_runtime/analyzer/test_optional_adapter.py --cov=drm_copilot_discovery.analyzer.optional --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p4t8-final-optional-coverage.raw.json`
EXIT_CODE: 0
Output Summary: Stage 5 of 7; exact source bindings, elapsed time and separate raw stream hashes are in the adjacent JSON.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 100 items

tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[absent-csharp] PASSED [  1%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[absent-xml] PASSED [  2%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[absent-project] PASSED [  3%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[absent-direct-csharp] PASSED [  4%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[absent-direct-xml] PASSED [  5%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[absent-analyze] PASSED [  6%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[disabled-csharp] PASSED [  7%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[disabled-xml] PASSED [  8%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[disabled-project] PASSED [  9%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[disabled-direct-csharp] PASSED [ 10%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[disabled-direct-xml] PASSED [ 11%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[disabled-analyze] PASSED [ 12%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[draft-csharp] PASSED [ 13%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[draft-xml] PASSED [ 14%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[draft-project] PASSED [ 15%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[draft-direct-csharp] PASSED [ 16%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[draft-direct-xml] PASSED [ 17%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[draft-analyze] PASSED [ 18%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[0-csharp-max_tokens] PASSED [ 19%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[0-csharp-max_candidates] PASSED [ 20%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[0-xml-max_bytes] PASSED [ 21%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[0-xml-max_elements] PASSED [ 22%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[0-xml-max_depth] PASSED [ 23%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[0-xml-max_candidates] PASSED [ 24%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[-1-csharp-max_tokens] PASSED [ 25%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[-1-csharp-max_candidates] PASSED [ 26%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[-1-xml-max_bytes] PASSED [ 27%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[-1-xml-max_elements] PASSED [ 28%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[-1-xml-max_depth] PASSED [ 29%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[-1-xml-max_candidates] PASSED [ 30%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[True-csharp-max_tokens] PASSED [ 31%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[True-csharp-max_candidates] PASSED [ 32%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[True-xml-max_bytes] PASSED [ 33%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[True-xml-max_elements] PASSED [ 34%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[True-xml-max_depth] PASSED [ 35%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[True-xml-max_candidates] PASSED [ 36%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[1.5-csharp-max_tokens] PASSED [ 37%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[1.5-csharp-max_candidates] PASSED [ 38%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[1.5-xml-max_bytes] PASSED [ 39%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[1.5-xml-max_elements] PASSED [ 40%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[1.5-xml-max_depth] PASSED [ 41%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[1.5-xml-max_candidates] PASSED [ 42%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_encoded_bytes_are_bounded_before_buffer_allocation[\xe9-1] PASSED [ 43%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_encoded_bytes_are_bounded_before_buffer_allocation[\U0001f600-3] PASSED [ 44%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_encoded_bytes_are_bounded_before_buffer_allocation[\ud800-10] PASSED [ 45%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_encoded_bytes_are_bounded_before_buffer_allocation[xxxxxxxxxx-9] PASSED [ 46%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_runtime_parser_failures_are_fixed_and_source_bound[src/a.cs-\xff-source-encoding] PASSED [ 47%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_runtime_parser_failures_are_fixed_and_source_bound[src/a.xml-<customUI-xml-malformed] PASSED [ 48%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_runtime_parser_failures_are_fixed_and_source_bound[src/a.xml-<!DOCTYPE r [<!ENTITY x "secret">]><r/>-xml-dtd] PASSED [ 49%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_runtime_parser_failures_are_fixed_and_source_bound[src/a.csproj-<Wrong/>-xml-root] PASSED [ 50%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_runtime_parser_failures_are_fixed_and_source_bound[src/a.cs-class C {-source-delimiter] PASSED [ 51%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_aggregate_exhaustion_discards_all_partial_rows[base-records] PASSED [ 52%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_aggregate_exhaustion_discards_all_partial_rows[no-candidate-capacity] PASSED [ 53%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_aggregate_exhaustion_discards_all_partial_rows[candidate-records] PASSED [ 54%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_aggregate_exhaustion_discards_all_partial_rows[base-bytes] PASSED [ 55%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_aggregate_exhaustion_discards_all_partial_rows[candidate-bytes] PASSED [ 56%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_aggregate_exhaustion_discards_all_partial_rows[aggregate-work] PASSED [ 57%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_candidate_and_profile_byte_caps_cannot_be_enlarged[csharp] PASSED [ 58%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_candidate_and_profile_byte_caps_cannot_be_enlarged[xml] PASSED [ 59%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_candidate_and_profile_byte_caps_cannot_be_enlarged[project] PASSED [ 60%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_retained_pin_budgets_are_independent[count] PASSED [ 61%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_retained_pin_budgets_are_independent[bytes] PASSED [ 62%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_long_chains_unsupported_xml_and_nonboolean_dialect PASSED [ 63%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_adapter_rejects_untyped_capture_and_insufficient_fallback PASSED [ 64%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[class R : IRibbonExtensibility {}-ribbon_extensibility-IRibbonExtensibility] PASSED [ 65%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[class R : Microsoft.Office.Core.IRibbonExtensibility {}-ribbon_extensibility-IRibbonExtensibility] PASSED [ 66%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[class R : Microsoft.Office.Tools.Ribbon.RibbonBase {}-ribbon_extensibility-Microsoft.Office.Tools.Ribbon] PASSED [ 67%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[class R { string GetCustomUI(string id) { return null; } }-ribbon_extensibility-GetCustomUI] PASSED [ 68%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[class ThisAddIn { void ThisAddIn_Startup() {} void Shutdown() {} }-addin_lifecycle-ThisAddIn_Startup] PASSED [ 69%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[[ComImport] class C {}-com_attribute-ComImport] PASSED [ 70%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[[ComVisible(false)] class C {}-com_attribute-ComVisible] PASSED [ 71%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[Marshal.ReleaseComObject(secret);-marshal_call-ReleaseComObject] PASSED [ 72%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[Type.GetTypeFromProgID(secret);-progid_activation-GetTypeFromProgID] PASSED [ 73%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[using Microsoft.Office.Interop.GenericHost;-interop_using-Microsoft.Office.Interop.GenericHost] PASSED [ 74%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[using static Microsoft.Office.Interop.GenericHost.Values;-interop_using-Microsoft.Office.Interop.GenericHost.Values] PASSED [ 75%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[using Host = Microsoft.Office.Interop.GenericHost;-interop_using-Microsoft.Office.Interop.GenericHost] PASSED [ 76%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[// IRibbonExtensibility Marshal.ReleaseComObject(x)] PASSED [ 77%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[var x = "IRibbonExtensibility Marshal.ReleaseComObject(x)";] PASSED [ 78%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[[Guid("masked-first")] class C {}] PASSED [ 79%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[Marshal.AddRef(x); Activator.CreateInstance(x);] PASSED [ 80%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[Take([ComImport]); Take(0, [ComVisible]);] PASSED [ 81%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[class C { bool Marshal.IsComObject(object x) => false; }] PASSED [ 82%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[class C { void Startup() {} }] PASSED [ 83%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[var x = Microsoft.Office.Interop.GenericHost;] PASSED [ 84%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[static Microsoft.Office.Interop.GenericHost;] PASSED [ 85%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_valid_ribbon_generation_fixtures_and_unchanged_invalid_original[2006] PASSED [ 86%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_valid_ribbon_generation_fixtures_and_unchanged_invalid_original[2009] PASSED [ 87%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_ribbon_opaque_and_nonliteral_callbacks_are_ignored[<!-- <button onAction="Trap"/> -->] PASSED [ 88%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_ribbon_opaque_and_nonliteral_callbacks_are_ignored[<opaque><button onAction="Trap"/></opaque>] PASSED [ 89%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_ribbon_opaque_and_nonliteral_callbacks_are_ignored[<button xmlns="urn:foreign" onAction="Trap"/>] PASSED [ 90%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_ribbon_opaque_and_nonliteral_callbacks_are_ignored[<button onAction="{Binding Trap}"/>] PASSED [ 91%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_ribbon_opaque_and_nonliteral_callbacks_are_ignored[<button onAction="A..Trap"/>] PASSED [ 92%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_ribbon_opaque_and_nonliteral_callbacks_are_ignored[<button onAction="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"/>] PASSED [ 93%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_project_opaque_payloads_and_targets_are_not_emitted[<ProjectExtensions><ItemGroup><COMReference Include="SECRET"/></ItemGroup></ProjectExtensions>] PASSED [ 94%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_project_opaque_payloads_and_targets_are_not_emitted[<PropertyGroup><ItemGroup><COMReference Include="SECRET"/></ItemGroup></PropertyGroup>] PASSED [ 95%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_project_opaque_payloads_and_targets_are_not_emitted[<ItemGroup><Reference Include="C:/SECRET"/></ItemGroup>] PASSED [ 96%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_project_uses_shared_com_and_preserves_false_and_condition_presence PASSED [ 97%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_adapter_retains_original_xml_bytes_schema_and_unresolved_relationships[utf-8] PASSED [ 98%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_adapter_retains_original_xml_bytes_schema_and_unresolved_relationships[utf-16] PASSED [ 99%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_unverified_pins_exclusions_and_unreadable_inputs_remain_distinct PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                                      Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\__init__.py            0      0      0      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\vsto_office.py       127      0     34      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\vsto_patterns.py      16      0      0      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\vsto_syntax.py       162      0     92      0   100%
-------------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                       305      0    126      0   100%
Coverage JSON written to file SCRATCH/issue-980-p4t8-final-optional-coverage.raw.json
============================ 100 passed in 29.51s =============================

```
