# P4-T6 final tests-ui-reverse

Timestamp: 2026-10-19T09-21
Command: `poetry run python -m pytest -v -o addopts= tests/discovery_runtime/analyzer/test_ui_callback_limits.py tests/discovery_runtime/analyzer/test_ui_callbacks.py --cov=drm_copilot_discovery.analyzer.ui_callbacks --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p4t6-final-ui-coverage.raw.json`
EXIT_CODE: 0
Output Summary: Stage 5 of 7; exact source bindings, elapsed time and separate raw stream hashes are in the adjacent JSON.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 107 items

tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_invalid_limits_precede_parser_calls[options0] PASSED [  0%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_invalid_limits_precede_parser_calls[options1] PASSED [  1%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_invalid_limits_precede_parser_calls[options2] PASSED [  2%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_invalid_limits_precede_parser_calls[options3] PASSED [  3%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_invalid_limits_precede_parser_calls[options4] PASSED [  4%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_invalid_limits_precede_parser_calls[options5] PASSED [  5%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_limits_reject_instead_of_returning_partial_candidates[options0-ui-candidate-limit] PASSED [  6%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_limits_reject_instead_of_returning_partial_candidates[options1-ui-candidate-limit] PASSED [  7%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_limits_reject_instead_of_returning_partial_candidates[options2-xml-limit] PASSED [  8%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_limits_reject_instead_of_returning_partial_candidates[options3-xml-limit] PASSED [  9%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_limits_reject_instead_of_returning_partial_candidates[options4-xml-limit] PASSED [ 10%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_pin_index_preserves_identity_and_bounds_aggregate_lookup PASSED [ 11%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_aggregate_limits_discard_partial_results_before_release[input-bytes] PASSED [ 12%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_aggregate_limits_discard_partial_results_before_release[scan] PASSED [ 13%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_aggregate_limits_discard_partial_results_before_release[rows] PASSED [ 14%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_aggregate_limits_discard_partial_results_before_release[output] PASSED [ 14%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_aggregate_limits_discard_partial_results_before_release[pin-count] PASSED [ 15%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_aggregate_limits_discard_partial_results_before_release[pin-bytes] PASSED [ 16%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_wrong_capture_type_fails_before_indexing PASSED [ 17%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_path_rejection_precedes_xml[../a.xaml] PASSED [ 18%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_path_rejection_precedes_xml[/a.xaml] PASSED [ 19%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_path_rejection_precedes_xml[C:/a.xaml] PASSED [ 20%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_non_bytes_are_rejected[<Window/>] PASSED [ 21%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_non_bytes_are_rejected[payload1] PASSED [ 22%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_public_non_bytes_are_rejected[None] PASSED [ 23%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_adapter_per_file_failures_are_redacted[src/a.xaml-<Window-1000-xml-malformed] PASSED [ 24%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_adapter_per_file_failures_are_redacted[src/a.xaml-<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" x:Class="Demo.View"><Button Click="OnClick"/></Window>-2-xml-limit] PASSED [ 25%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_adapter_per_file_failures_are_redacted[src/a.xaml.cs-class View {}-2-source-limit] PASSED [ 26%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_missing_code_pin_is_separate_from_pinned_markup PASSED [ 27%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_many_callbacks_are_bounded_before_candidate_allocation PASSED [ 28%]
tests/discovery_runtime/analyzer/test_ui_callback_limits.py::test_code_scan_exhaustion_discards_earlier_markup_rows PASSED [ 28%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_only_documented_element_event_pairs_become_declarations[Window-Loaded] PASSED [ 29%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_only_documented_element_event_pairs_become_declarations[Window-Unloaded] PASSED [ 30%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_only_documented_element_event_pairs_become_declarations[Window-Closing] PASSED [ 31%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_only_documented_element_event_pairs_become_declarations[Window-Closed] PASSED [ 32%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_only_documented_element_event_pairs_become_declarations[Page-Loaded] PASSED [ 33%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_only_documented_element_event_pairs_become_declarations[UserControl-Unloaded] PASSED [ 34%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_only_documented_element_event_pairs_become_declarations[Button-Click] PASSED [ 35%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_only_documented_element_event_pairs_become_declarations[CheckBox-Checked] PASSED [ 36%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_only_documented_element_event_pairs_become_declarations[CheckBox-Unchecked] PASSED [ 37%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_only_documented_element_event_pairs_become_declarations[CheckBox-Indeterminate] PASSED [ 38%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_only_documented_element_event_pairs_become_declarations[RadioButton-Checked] PASSED [ 39%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_only_documented_element_event_pairs_become_declarations[RadioButton-Unchecked] PASSED [ 40%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_only_documented_element_event_pairs_become_declarations[TextBox-TextChanged] PASSED [ 41%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_only_documented_element_event_pairs_become_declarations[ComboBox-SelectionChanged] PASSED [ 42%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_only_documented_element_event_pairs_become_declarations[ListBox-SelectionChanged] PASSED [ 42%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_supported_containers_retain_child_callback_facts[Grid] PASSED [ 43%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_supported_containers_retain_child_callback_facts[StackPanel] PASSED [ 44%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_supported_containers_retain_child_callback_facts[DockPanel] PASSED [ 45%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_supported_containers_retain_child_callback_facts[WrapPanel] PASSED [ 46%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_supported_containers_retain_child_callback_facts[Canvas] PASSED [ 47%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_supported_containers_retain_child_callback_facts[Border] PASSED [ 48%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_supported_containers_retain_child_callback_facts[ScrollViewer] PASSED [ 49%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_supported_containers_retain_child_callback_facts[ContentControl] PASSED [ 50%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_opaque_and_non_event_content_never_becomes_callback[<Grid Click="SECRET"/>] PASSED [ 51%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_opaque_and_non_event_content_never_becomes_callback[<Button Handler="SECRET" Command="SECRET"/>] PASSED [ 52%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_opaque_and_non_event_content_never_becomes_callback[<Window.Resources><Button Click="SECRET"/></Window.Resources>] PASSED [ 53%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_opaque_and_non_event_content_never_becomes_callback[<ResourceDictionary><Button Click="SECRET"/></ResourceDictionary>] PASSED [ 54%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_opaque_and_non_event_content_never_becomes_callback[<ControlTemplate><Button Click="SECRET"/></ControlTemplate>] PASSED [ 55%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_opaque_and_non_event_content_never_becomes_callback[<DataTemplate><Button Click="SECRET"/></DataTemplate>] PASSED [ 56%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_opaque_and_non_event_content_never_becomes_callback[<Style><Button Click="SECRET"/></Style>] PASSED [ 57%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_opaque_and_non_event_content_never_becomes_callback[<Custom><Button Click="SECRET"/></Custom>] PASSED [ 57%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_opaque_and_non_event_content_never_becomes_callback[<x:Code><![CDATA[void SECRET() {}]]></x:Code>] PASSED [ 58%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_opaque_and_non_event_content_never_becomes_callback[<foreign xmlns="urn:other"><Button xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Click="SECRET"/></foreign>] PASSED [ 59%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_opaque_and_non_event_content_never_becomes_callback[<!-- <Button Click="SECRET"/> --><Button Text="SECRET"/>] PASSED [ 60%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_handler_values_outside_literal_subset_fail_closed[] PASSED [ 61%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_handler_values_outside_literal_subset_fail_closed[ ] PASSED [ 62%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_handler_values_outside_literal_subset_fail_closed[Go()] PASSED [ 63%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_handler_values_outside_literal_subset_fail_closed[a.Go] PASSED [ 64%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_handler_values_outside_literal_subset_fail_closed[{Binding Go}] PASSED [ 65%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_handler_values_outside_literal_subset_fail_closed[{x:Static Go}] PASSED [ 66%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_handler_values_outside_literal_subset_fail_closed[Go;Run] PASSED [ 67%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_handler_values_outside_literal_subset_fail_closed[a/b] PASSED [ 68%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_handler_values_outside_literal_subset_fail_closed[\u03bb] PASSED [ 69%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_handler_values_outside_literal_subset_fail_closed[aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa] PASSED [ 70%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_class_is_a_bounded_literal_identity_not_a_filename[{Binding Name}] PASSED [ 71%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_class_is_a_bounded_literal_identity_not_a_filename[../file.cs] PASSED [ 71%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_class_is_a_bounded_literal_identity_not_a_filename[A..View] PASSED [ 72%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_class_is_a_bounded_literal_identity_not_a_filename[aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa] PASSED [ 73%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_unsafe_or_unsupported_xml_has_fixed_rejection[<Window><Button Click="Go"/></Window>-ui-dialect] PASSED [ 74%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_unsafe_or_unsupported_xml_has_fixed_rejection[<ResourceDictionary xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" x:Class="Demo.View"><Button Click="OnClick"/></ResourceDictionary>-ui-dialect] PASSED [ 75%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_unsafe_or_unsupported_xml_has_fixed_rejection[<Window xmlns="urn:other" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" x:Class="Demo.View"><Button Click="OnClick"/></Window>-ui-dialect] PASSED [ 76%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_unsafe_or_unsupported_xml_has_fixed_rejection[<Window-xml-malformed] PASSED [ 77%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_unsafe_or_unsupported_xml_has_fixed_rejection[<!DOCTYPE Window [<!ENTITY x "SECRET">]><Window/>-xml-dtd] PASSED [ 78%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_unsafe_or_unsupported_xml_has_fixed_rejection[<!DOCTYPE Window SYSTEM "https://invalid.example/a"><Window/>-xml-dtd] PASSED [ 79%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_unsafe_or_unsupported_xml_has_fixed_rejection[\xff-xml-malformed] PASSED [ 80%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_explicit_names_and_inferred_code_relevance_validate_together PASSED [ 81%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_lexical_matches_never_resolve_missing_or_ambiguous_methods[class Other { void OnClick() {} }-missing-class] PASSED [ 82%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_lexical_matches_never_resolve_missing_or_ambiguous_methods[class View {}-missing-method] PASSED [ 83%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_lexical_matches_never_resolve_missing_or_ambiguous_methods[class View { void OnClick() {} void OnClick(int x) {} }-ambiguous] PASSED [ 84%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_lexical_matches_never_resolve_missing_or_ambiguous_methods[partial class View { void OnClick() {} } partial class View {}-ambiguous] PASSED [ 85%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_lexical_matches_never_resolve_missing_or_ambiguous_methods[class View { string x = "void OnClick() {}"; }-missing-method] PASSED [ 85%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_lexical_matches_never_resolve_missing_or_ambiguous_methods[class View { /* void OnClick() {} */ }-missing-method] PASSED [ 86%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_lexical_matches_never_resolve_missing_or_ambiguous_methods[class View { int OnClick; }-missing-method] PASSED [ 87%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_class_and_filename_association_are_independent[-src/a.xaml.cs] PASSED [ 88%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_class_and_filename_association_are_independent[Demo.View-src/Demo.View.cs] PASSED [ 89%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_repeated_and_multiline_elements_have_stable_containing_anchors[\n-3] PASSED [ 90%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_repeated_and_multiline_elements_have_stable_containing_anchors[\r\n-3] PASSED [ 91%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_repeated_and_multiline_elements_have_stable_containing_anchors[\r-1] PASSED [ 92%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_distinct_single_line_element_retains_its_reported_line PASSED [ 93%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_xml_encoding_keeps_original_source_digest[utf-8-\xef\xbb\xbf] PASSED [ 94%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_xml_encoding_keeps_original_source_digest[utf-16-le-\xff\xfe] PASSED [ 95%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_unavailable_excluded_and_unrelated_inputs_do_not_leak_values PASSED [ 96%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_code_failures_preserve_declarations_without_false_binding[None] PASSED [ 97%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_code_failures_preserve_declarations_without_false_binding[\xff] PASSED [ 98%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_code_failures_preserve_declarations_without_false_binding[class View { void \uZZZZ() {} }] PASSED [ 99%]
tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_same_capture_order_has_deterministic_results_and_no_source_reads PASSED [100%]

=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                            Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\ui_callbacks.py     164      0     58      0   100%
---------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                             164      0     58      0   100%
Coverage JSON written to file SCRATCH/issue-980-p4t6-final-ui-coverage.raw.json
============================ 107 passed in 42.09s =============================

```
