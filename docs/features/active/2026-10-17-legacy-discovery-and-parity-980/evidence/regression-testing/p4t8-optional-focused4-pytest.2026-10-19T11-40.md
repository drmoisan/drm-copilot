# p4t8-optional-focused4 pytest

Timestamp: 2026-10-19T11-39
Command: .\.venv\Scripts\python.exe -m pytest -o addopts= tests/discovery_runtime/analyzer/test_optional_adapter.py tests/discovery_runtime/analyzer/test_optional_limits.py -v --tb=short --cov=drm_copilot_discovery.analyzer.optional --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\issue-980-p4t8-optional-focused4-coverage.json
EXIT_CODE: 1
Output Summary: scoped pytest, 25.493 seconds; source changed=False. Separate exact raw streams qualify sanitized presentation.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 94 items

tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[class R : IRibbonExtensibility {}-ribbon_extensibility-IRibbonExtensibility] PASSED [  1%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[class R : Microsoft.Office.Core.IRibbonExtensibility {}-ribbon_extensibility-IRibbonExtensibility] PASSED [  2%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[class R : Microsoft.Office.Tools.Ribbon.RibbonBase {}-ribbon_extensibility-Microsoft.Office.Tools.Ribbon] PASSED [  3%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[class R { string GetCustomUI(string id) { return null; } }-ribbon_extensibility-GetCustomUI] PASSED [  4%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[class ThisAddIn { void ThisAddIn_Startup() {} void Shutdown() {} }-addin_lifecycle-ThisAddIn_Startup] PASSED [  5%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[[ComImport] class C {}-com_attribute-ComImport] PASSED [  6%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[[ComVisible(false)] class C {}-com_attribute-ComVisible] PASSED [  7%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[Marshal.ReleaseComObject(secret);-marshal_call-ReleaseComObject] PASSED [  8%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[Type.GetTypeFromProgID(secret);-progid_activation-GetTypeFromProgID] PASSED [  9%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[using Microsoft.Office.Interop.GenericHost;-interop_using-Microsoft.Office.Interop.GenericHost] PASSED [ 10%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[using static Microsoft.Office.Interop.GenericHost.Values;-interop_using-Microsoft.Office.Interop.GenericHost.Values] PASSED [ 11%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_csharp_markers_keep_anchors_and_explicitly_unresolved_binding[using Host = Microsoft.Office.Interop.GenericHost;-interop_using-Microsoft.Office.Interop.GenericHost] PASSED [ 12%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[// IRibbonExtensibility Marshal.ReleaseComObject(x)] PASSED [ 13%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[var x = "IRibbonExtensibility Marshal.ReleaseComObject(x)";] PASSED [ 14%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[[Guid("masked-first")] class C {}] PASSED [ 15%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[Marshal.AddRef(x); Activator.CreateInstance(x);] PASSED [ 17%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[Take([ComImport]); Take(0, [ComVisible]);] PASSED [ 18%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[class C { bool Marshal.IsComObject(object x) => false; }] PASSED [ 19%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[class C { void Startup() {} }] PASSED [ 20%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[var x = Microsoft.Office.Interop.GenericHost;] PASSED [ 21%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_lookalikes_and_values_do_not_become_optional_behavior[static Microsoft.Office.Interop.GenericHost;] PASSED [ 22%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_valid_ribbon_generation_fixtures_and_unchanged_invalid_original[2006] PASSED [ 23%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_valid_ribbon_generation_fixtures_and_unchanged_invalid_original[2009] PASSED [ 24%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_ribbon_opaque_and_nonliteral_callbacks_are_ignored[<!-- <button onAction="Trap"/> -->] PASSED [ 25%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_ribbon_opaque_and_nonliteral_callbacks_are_ignored[<opaque><button onAction="Trap"/></opaque>] PASSED [ 26%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_ribbon_opaque_and_nonliteral_callbacks_are_ignored[<button xmlns="urn:foreign" onAction="Trap"/>] PASSED [ 27%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_ribbon_opaque_and_nonliteral_callbacks_are_ignored[<button onAction="{Binding Trap}"/>] PASSED [ 28%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_ribbon_opaque_and_nonliteral_callbacks_are_ignored[<button onAction="A..Trap"/>] PASSED [ 29%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_ribbon_opaque_and_nonliteral_callbacks_are_ignored[<button onAction="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"/>] PASSED [ 30%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_project_opaque_payloads_and_targets_are_not_emitted[<ProjectExtensions><ItemGroup><COMReference Include="SECRET"/></ItemGroup></ProjectExtensions>] PASSED [ 31%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_project_opaque_payloads_and_targets_are_not_emitted[<PropertyGroup><ItemGroup><COMReference Include="SECRET"/></ItemGroup></PropertyGroup>] PASSED [ 32%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_project_opaque_payloads_and_targets_are_not_emitted[<ItemGroup><Reference Include="C:/SECRET"/></ItemGroup>] PASSED [ 34%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_project_uses_shared_com_and_preserves_false_and_condition_presence PASSED [ 35%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_adapter_retains_original_xml_bytes_schema_and_unresolved_relationships[utf-8] PASSED [ 36%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_adapter_retains_original_xml_bytes_schema_and_unresolved_relationships[utf-16] PASSED [ 37%]
tests/discovery_runtime/analyzer/test_optional_adapter.py::test_unverified_pins_exclusions_and_unreadable_inputs_remain_distinct PASSED [ 38%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[absent-csharp] PASSED [ 39%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[absent-xml] PASSED [ 40%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[absent-project] PASSED [ 41%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[absent-direct-csharp] PASSED [ 42%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[absent-direct-xml] PASSED [ 43%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[absent-analyze] PASSED [ 44%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[disabled-csharp] PASSED [ 45%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[disabled-xml] PASSED [ 46%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[disabled-project] PASSED [ 47%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[disabled-direct-csharp] PASSED [ 48%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[disabled-direct-xml] PASSED [ 50%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[disabled-analyze] PASSED [ 51%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[draft-csharp] PASSED [ 52%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[draft-xml] PASSED [ 53%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[draft-project] PASSED [ 54%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[draft-direct-csharp] PASSED [ 55%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[draft-direct-xml] PASSED [ 56%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_consent_fails_before_source_processing[draft-analyze] PASSED [ 57%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[0-csharp-max_tokens] PASSED [ 58%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[0-csharp-max_candidates] PASSED [ 59%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[0-xml-max_bytes] PASSED [ 60%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[0-xml-max_elements] PASSED [ 61%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[0-xml-max_depth] PASSED [ 62%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[0-xml-max_candidates] PASSED [ 63%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[-1-csharp-max_tokens] PASSED [ 64%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[-1-csharp-max_candidates] PASSED [ 65%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[-1-xml-max_bytes] PASSED [ 67%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[-1-xml-max_elements] PASSED [ 68%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[-1-xml-max_depth] PASSED [ 69%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[-1-xml-max_candidates] PASSED [ 70%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[True-csharp-max_tokens] PASSED [ 71%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[True-csharp-max_candidates] PASSED [ 72%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[True-xml-max_bytes] PASSED [ 73%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[True-xml-max_elements] PASSED [ 74%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[True-xml-max_depth] PASSED [ 75%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[True-xml-max_candidates] PASSED [ 76%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[1.5-csharp-max_tokens] PASSED [ 77%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[1.5-csharp-max_candidates] PASSED [ 78%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[1.5-xml-max_bytes] PASSED [ 79%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[1.5-xml-max_elements] PASSED [ 80%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[1.5-xml-max_depth] PASSED [ 81%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_invalid_public_limits_fail_before_processing[1.5-xml-max_candidates] PASSED [ 82%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_encoded_bytes_are_bounded_before_buffer_allocation[\xe9-1] PASSED [ 84%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_encoded_bytes_are_bounded_before_buffer_allocation[\U0001f600-3] PASSED [ 85%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_encoded_bytes_are_bounded_before_buffer_allocation[\ud800-10] PASSED [ 86%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_encoded_bytes_are_bounded_before_buffer_allocation[xxxxxxxxxx-9] PASSED [ 87%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_runtime_parser_failures_are_fixed_and_source_bound[src/a.cs-\xff-source-encoding] PASSED [ 88%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_runtime_parser_failures_are_fixed_and_source_bound[src/a.xml-<customUI-xml-malformed] PASSED [ 89%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_runtime_parser_failures_are_fixed_and_source_bound[src/a.xml-<!DOCTYPE r [<!ENTITY x "secret">]><r/>-xml-dtd] PASSED [ 90%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_runtime_parser_failures_are_fixed_and_source_bound[src/a.csproj-<Wrong/>-xml-root] PASSED [ 91%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_runtime_parser_failures_are_fixed_and_source_bound[src/a.cs-class C {-source-delimiter] PASSED [ 92%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_aggregate_exhaustion_discards_all_partial_rows[1-16777216--analysis-limit] PASSED [ 93%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_aggregate_exhaustion_discards_all_partial_rows[4-16777216--analysis-limit] PASSED [ 94%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_aggregate_exhaustion_discards_all_partial_rows[6-16777216-[ComImport, ComVisible] class C {}-analysis-limit] FAILED [ 95%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_aggregate_exhaustion_discards_all_partial_rows[100-1024--analysis-text-limit] PASSED [ 96%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_aggregate_exhaustion_discards_all_partial_rows[100-60000--analysis-text-limit] PASSED [ 97%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_aggregate_exhaustion_discards_all_partial_rows[100-16777216-//<synthetic-payload-run: bytes=2200000; sha256=c563597e86f7c4f8870c310a8630b2f5d4af0c8d89a1cb6e9b7005d2f1e89b60>-analysis-work-limit] ERROR [ 98%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_aggregate_exhaustion_discards_all_partial_rows[100-16777216-//<synthetic-payload-run: bytes=2200000; sha256=c563597e86f7c4f8870c310a8630b2f5d4af0c8d89a1cb6e9b7005d2f1e89b60>-analysis-work-limit] ERROR [ 98%]
tests/discovery_runtime/analyzer/test_optional_limits.py::test_adapter_rejects_untyped_capture_and_insufficient_fallback PASSED [100%]

=================================== ERRORS ====================================
_ ERROR at setup of test_aggregate_exhaustion_discards_all_partial_rows[100-16777216-//<synthetic-payload-run: bytes=2200000; sha256=c563597e86f7c4f8870c310a8630b2f5d4af0c8d89a1cb6e9b7005d2f1e89b60>-analysis-work-limit] _
.venv\Lib\site-packages\_pytest\runner.py:353: in from_call
    result: TResult | None = func()
                             ^^^^^^
.venv\Lib\site-packages\_pytest\runner.py:245: in <lambda>
    lambda: runtest_hook(item=item, **kwds),
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.venv\Lib\site-packages\pluggy\_hooks.py:512: in __call__
    return self._hookexec(self.name, self._hookimpls.copy(), kwargs, firstresult)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.venv\Lib\site-packages\pluggy\_manager.py:120: in _hookexec
    return self._inner_hookexec(hook_name, methods, kwargs, firstresult)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.venv\Lib\site-packages\_pytest\logging.py:843: in pytest_runtest_setup
    yield
.venv\Lib\site-packages\_pytest\capture.py:895: in pytest_runtest_setup
    return (yield)
            ^^^^^
.venv\Lib\site-packages\_pytest\runner.py:164: in pytest_runtest_setup
    _update_current_test_var(item, "setup")
.venv\Lib\site-packages\_pytest\runner.py:210: in _update_current_test_var
    os.environ[var_name] = value
    ^^^^^^^^^^^^^^^^^^^^
<frozen os>:723: in __setitem__
    ???
E   ValueError: the environment variable is longer than 32767 characters
_ ERROR at teardown of test_aggregate_exhaustion_discards_all_partial_rows[100-16777216-//<synthetic-payload-run: bytes=2200000; sha256=c563597e86f7c4f8870c310a8630b2f5d4af0c8d89a1cb6e9b7005d2f1e89b60>-analysis-work-limit] _
.venv\Lib\site-packages\_pytest\runner.py:353: in from_call
    result: TResult | None = func()
                             ^^^^^^
.venv\Lib\site-packages\_pytest\runner.py:245: in <lambda>
    lambda: runtest_hook(item=item, **kwds),
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.venv\Lib\site-packages\pluggy\_hooks.py:512: in __call__
    return self._hookexec(self.name, self._hookimpls.copy(), kwargs, firstresult)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.venv\Lib\site-packages\pluggy\_manager.py:120: in _hookexec
    return self._inner_hookexec(hook_name, methods, kwargs, firstresult)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.venv\Lib\site-packages\_pytest\logging.py:858: in pytest_runtest_teardown
    yield
.venv\Lib\site-packages\_pytest\capture.py:905: in pytest_runtest_teardown
    return (yield)
            ^^^^^
.venv\Lib\site-packages\_pytest\runner.py:193: in pytest_runtest_teardown
    _update_current_test_var(item, "teardown")
.venv\Lib\site-packages\_pytest\runner.py:210: in _update_current_test_var
    os.environ[var_name] = value
    ^^^^^^^^^^^^^^^^^^^^
<frozen os>:723: in __setitem__
    ???
E   ValueError: the environment variable is longer than 32767 characters
================================== FAILURES ===================================
_ test_aggregate_exhaustion_discards_all_partial_rows[6-16777216-[ComImport, ComVisible] class C {}-analysis-limit] _
tests\discovery_runtime\analyzer\test_optional_limits.py:195: in test_aggregate_exhaustion_discards_all_partial_rows
    assert [item["code"] for item in result.diagnostics] == [code]
E   AssertionError: assert ['source-token-limit'] == ['analysis-limit']
E
E     At index 0 diff: 'source-token-limit' != 'analysis-limit'
E
E     Full diff:
E       [
E     -     'analysis-limit',
E     +     'source-token-limit',
E       ]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                                      Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\__init__.py            0      0      0      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\vsto_office.py       129      5     36      5    94%   218, 227, 235, 274, 312
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\vsto_patterns.py      16      0      0      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\vsto_syntax.py       164      6     94      5    96%   114, 118, 225-226, 318, 351
-------------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                       309     11    130     10    95%
Coverage JSON written to file SCRATCH\issue-980-p4t8-optional-focused4-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/analyzer/test_optional_limits.py::test_aggregate_exhaustion_discards_all_partial_rows[6-16777216-[ComImport, ComVisible] class C {}-analysis-limit]
ERROR tests/discovery_runtime/analyzer/test_optional_limits.py::test_aggregate_exhaustion_discards_all_partial_rows[100-16777216-//<synthetic-payload-run: bytes=2200000; sha256=c563597e86f7c4f8870c310a8630b2f5d4af0c8d89a1cb6e9b7005d2f1e89b60>-analysis-work-limit]
ERROR tests/discovery_runtime/analyzer/test_optional_limits.py::test_aggregate_exhaustion_discards_all_partial_rows[100-16777216-//<synthetic-payload-run: bytes=2200000; sha256=c563597e86f7c4f8870c310a8630b2f5d4af0c8d89a1cb6e9b7005d2f1e89b60>-analysis-work-limit]
=================== 1 failed, 92 passed, 2 errors in 24.88s ===================
```
