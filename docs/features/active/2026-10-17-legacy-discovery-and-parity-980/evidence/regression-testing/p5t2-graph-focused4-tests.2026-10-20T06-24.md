# P5-T2 graph tests

Timestamp: 2026-10-20T06-24

Command: `poetry run coverage run --branch --source=drm_copilot_discovery.parity_report,drm_copilot_discovery.parity_metrics,drm_copilot_discovery.report_models -m pytest -v --tb=short -o addopts= -p no:cacheprovider tests/discovery_runtime/test_parity_metrics.py tests/discovery_runtime/test_parity_report.py::test_graph_entrypoints_reject_non_snapshot_inputs tests/discovery_runtime/test_parity_report.py::test_graph_preflight_reserves_input_before_projection tests/discovery_runtime/test_parity_report.py::test_public_builder_reuses_complete_projection_with_independent_root_mode tests/discovery_runtime/test_report_models.py::test_heading_uses_only_closed_artifact_kind`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 16.008 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 34 items

tests/discovery_runtime/test_parity_metrics.py::test_verified_full_parity_keeps_four_population_units FAILED [  2%]
tests/discovery_runtime/test_parity_metrics.py::test_undeclared_optional_axis_is_not_required_and_never_passed[offline] FAILED [  5%]
tests/discovery_runtime/test_parity_metrics.py::test_undeclared_optional_axis_is_not_required_and_never_passed[mobile] FAILED [  8%]
tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[unassessed] FAILED [ 11%]
tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[partial] FAILED [ 14%]
tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[missing] FAILED [ 17%]
tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[conflicting] FAILED [ 20%]
tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[intentionally-changed] FAILED [ 23%]
tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[retired] FAILED [ 26%]
tests/discovery_runtime/test_parity_metrics.py::test_invalid_source_stays_visible_without_verified_numerator[repository_id-wrong] FAILED [ 29%]
tests/discovery_runtime/test_parity_metrics.py::test_invalid_source_stays_visible_without_verified_numerator[artifact_sha256-0000000000000000000000000000000000000000000000000000000000000000] FAILED [ 32%]
tests/discovery_runtime/test_parity_metrics.py::test_invalid_source_stays_visible_without_verified_numerator[feature_id-absent] FAILED [ 35%]
tests/discovery_runtime/test_parity_metrics.py::test_duplicate_rows_are_all_invalid_and_count_one_missing_completion FAILED [ 38%]
tests/discovery_runtime/test_parity_metrics.py::test_multiple_clients_do_not_multiply_source_feature_identity FAILED [ 41%]
tests/discovery_runtime/test_parity_metrics.py::test_current_unresolved_decisions_exclude_historical_proposals[proposed-1] FAILED [ 44%]
tests/discovery_runtime/test_parity_metrics.py::test_current_unresolved_decisions_exclude_historical_proposals[blocked-1] FAILED [ 47%]
tests/discovery_runtime/test_parity_metrics.py::test_current_unresolved_decisions_exclude_historical_proposals[approved-1] FAILED [ 50%]
tests/discovery_runtime/test_parity_metrics.py::test_current_unresolved_decisions_exclude_historical_proposals[rejected-0] FAILED [ 52%]
tests/discovery_runtime/test_parity_metrics.py::test_current_unresolved_decisions_exclude_historical_proposals[superseded-0] FAILED [ 55%]
tests/discovery_runtime/test_parity_metrics.py::test_all_authored_blockers_preserve_row_location FAILED [ 58%]
tests/discovery_runtime/test_parity_metrics.py::test_missing_source_authority_is_unavailable_not_zero[coverage-ledger] FAILED [ 61%]
tests/discovery_runtime/test_parity_metrics.py::test_missing_source_authority_is_unavailable_not_zero[inventory-snapshot] FAILED [ 64%]
tests/discovery_runtime/test_parity_metrics.py::test_confirmed_empty_scope_has_real_zeros_and_null_percentages PASSED [ 67%]
tests/discovery_runtime/test_parity_metrics.py::test_present_optional_or_contradictory_claims_remain_independent[changes0] FAILED [ 70%]
tests/discovery_runtime/test_parity_metrics.py::test_present_optional_or_contradictory_claims_remain_independent[changes1] FAILED [ 73%]
tests/discovery_runtime/test_parity_metrics.py::test_present_optional_or_contradictory_claims_remain_independent[changes2] FAILED [ 76%]
tests/discovery_runtime/test_parity_report.py::test_graph_entrypoints_reject_non_snapshot_inputs[None] PASSED [ 79%]
tests/discovery_runtime/test_parity_report.py::test_graph_entrypoints_reject_non_snapshot_inputs[value1] PASSED [ 82%]
tests/discovery_runtime/test_parity_report.py::test_graph_entrypoints_reject_non_snapshot_inputs[1] PASSED [ 85%]
tests/discovery_runtime/test_parity_report.py::test_graph_preflight_reserves_input_before_projection PASSED [ 88%]
tests/discovery_runtime/test_parity_report.py::test_public_builder_reuses_complete_projection_with_independent_root_mode PASSED [ 91%]
tests/discovery_runtime/test_report_models.py::test_heading_uses_only_closed_artifact_kind[parity-report-parity] PASSED [ 94%]
tests/discovery_runtime/test_report_models.py::test_heading_uses_only_closed_artifact_kind[coverage-report-coverage] PASSED [ 97%]
tests/discovery_runtime/test_report_models.py::test_heading_uses_only_closed_artifact_kind[authored\n# misleading-coverage] PASSED [100%]

================================== FAILURES ===================================
____________ test_verified_full_parity_keeps_four_population_units ____________
tests\discovery_runtime\test_parity_metrics.py:184: in test_verified_full_parity_keeps_four_population_units
    snapshot = report_graph(report_profile, snapshot_catalog)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
___ test_undeclared_optional_axis_is_not_required_and_never_passed[offline] ___
tests\discovery_runtime\test_parity_metrics.py:207: in test_undeclared_optional_axis_is_not_required_and_never_passed
    axes(summary(report_graph(report_profile, snapshot_catalog)))[name]
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
___ test_undeclared_optional_axis_is_not_required_and_never_passed[mobile] ____
tests\discovery_runtime\test_parity_metrics.py:207: in test_undeclared_optional_axis_is_not_required_and_never_passed
    axes(summary(report_graph(report_profile, snapshot_catalog)))[name]
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
______ test_authored_states_do_not_imply_approved_completion[unassessed] ______
tests\discovery_runtime\test_parity_metrics.py:231: in test_authored_states_do_not_imply_approved_completion
    value = summary(report_graph(report_profile, snapshot_catalog, state=state))
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
_______ test_authored_states_do_not_imply_approved_completion[partial] ________
tests\discovery_runtime\test_parity_metrics.py:231: in test_authored_states_do_not_imply_approved_completion
    value = summary(report_graph(report_profile, snapshot_catalog, state=state))
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
_______ test_authored_states_do_not_imply_approved_completion[missing] ________
tests\discovery_runtime\test_parity_metrics.py:231: in test_authored_states_do_not_imply_approved_completion
    value = summary(report_graph(report_profile, snapshot_catalog, state=state))
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
_____ test_authored_states_do_not_imply_approved_completion[conflicting] ______
tests\discovery_runtime\test_parity_metrics.py:231: in test_authored_states_do_not_imply_approved_completion
    value = summary(report_graph(report_profile, snapshot_catalog, state=state))
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
_ test_authored_states_do_not_imply_approved_completion[intentionally-changed] _
tests\discovery_runtime\test_parity_metrics.py:231: in test_authored_states_do_not_imply_approved_completion
    value = summary(report_graph(report_profile, snapshot_catalog, state=state))
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
_______ test_authored_states_do_not_imply_approved_completion[retired] ________
tests\discovery_runtime\test_parity_metrics.py:231: in test_authored_states_do_not_imply_approved_completion
    value = summary(report_graph(report_profile, snapshot_catalog, state=state))
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
_ test_invalid_source_stays_visible_without_verified_numerator[repository_id-wrong] _
tests\discovery_runtime\test_parity_metrics.py:256: in test_invalid_source_stays_visible_without_verified_numerator
    snapshot = report_graph(report_profile, snapshot_catalog)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
_ test_invalid_source_stays_visible_without_verified_numerator[artifact_sha256-0000000000000000000000000000000000000000000000000000000000000000] _
tests\discovery_runtime\test_parity_metrics.py:256: in test_invalid_source_stays_visible_without_verified_numerator
    snapshot = report_graph(report_profile, snapshot_catalog)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
_ test_invalid_source_stays_visible_without_verified_numerator[feature_id-absent] _
tests\discovery_runtime\test_parity_metrics.py:256: in test_invalid_source_stays_visible_without_verified_numerator
    snapshot = report_graph(report_profile, snapshot_catalog)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
____ test_duplicate_rows_are_all_invalid_and_count_one_missing_completion _____
tests\discovery_runtime\test_parity_metrics.py:284: in test_duplicate_rows_are_all_invalid_and_count_one_missing_completion
    snapshot = report_graph(report_profile, snapshot_catalog)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
________ test_multiple_clients_do_not_multiply_source_feature_identity ________
tests\discovery_runtime\test_parity_metrics.py:312: in test_multiple_clients_do_not_multiply_source_feature_identity
    value = summary(report_graph(profile, snapshot_catalog))
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
_ test_current_unresolved_decisions_exclude_historical_proposals[proposed-1] __
tests\discovery_runtime\test_parity_metrics.py:350: in test_current_unresolved_decisions_exclude_historical_proposals
    value = summary(report_graph(report_profile, snapshot_catalog, extra=(decision,)))
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
__ test_current_unresolved_decisions_exclude_historical_proposals[blocked-1] __
tests\discovery_runtime\test_parity_metrics.py:350: in test_current_unresolved_decisions_exclude_historical_proposals
    value = summary(report_graph(report_profile, snapshot_catalog, extra=(decision,)))
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
_ test_current_unresolved_decisions_exclude_historical_proposals[approved-1] __
tests\discovery_runtime\test_parity_metrics.py:350: in test_current_unresolved_decisions_exclude_historical_proposals
    value = summary(report_graph(report_profile, snapshot_catalog, extra=(decision,)))
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
_ test_current_unresolved_decisions_exclude_historical_proposals[rejected-0] __
tests\discovery_runtime\test_parity_metrics.py:350: in test_current_unresolved_decisions_exclude_historical_proposals
    value = summary(report_graph(report_profile, snapshot_catalog, extra=(decision,)))
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
_ test_current_unresolved_decisions_exclude_historical_proposals[superseded-0] _
tests\discovery_runtime\test_parity_metrics.py:350: in test_current_unresolved_decisions_exclude_historical_proposals
    value = summary(report_graph(report_profile, snapshot_catalog, extra=(decision,)))
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
______________ test_all_authored_blockers_preserve_row_location _______________
tests\discovery_runtime\test_parity_metrics.py:360: in test_all_authored_blockers_preserve_row_location
    report_graph(
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
___ test_missing_source_authority_is_unavailable_not_zero[coverage-ledger] ____
tests\discovery_runtime\test_parity_metrics.py:380: in test_missing_source_authority_is_unavailable_not_zero
    snapshot = report_graph(report_profile, snapshot_catalog)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
__ test_missing_source_authority_is_unavailable_not_zero[inventory-snapshot] __
tests\discovery_runtime\test_parity_metrics.py:380: in test_missing_source_authority_is_unavailable_not_zero
    snapshot = report_graph(report_profile, snapshot_catalog)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
_ test_present_optional_or_contradictory_claims_remain_independent[changes0] __
tests\discovery_runtime\test_parity_metrics.py:426: in test_present_optional_or_contradictory_claims_remain_independent
    value = summary(report_graph(report_profile, snapshot_catalog, row_changes=changes))
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
_ test_present_optional_or_contradictory_claims_remain_independent[changes1] __
tests\discovery_runtime\test_parity_metrics.py:426: in test_present_optional_or_contradictory_claims_remain_independent
    value = summary(report_graph(report_profile, snapshot_catalog, row_changes=changes))
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
_ test_present_optional_or_contradictory_claims_remain_independent[changes2] __
tests\discovery_runtime\test_parity_metrics.py:426: in test_present_optional_or_contradictory_claims_remain_independent
    value = summary(report_graph(report_profile, snapshot_catalog, row_changes=changes))
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\test_parity_metrics.py:103: in report_graph
    return replace(
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:212: in __post_init__
    check_path_collisions(item.path for item in artifacts)
packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: in check_path_collisions
    raise PathPolicyError(
E   drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/workspace-example/evidence-reference/capture.json': Remove duplicate or aliased paths.
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_parity_metrics.py::test_verified_full_parity_keeps_four_population_units
FAILED tests/discovery_runtime/test_parity_metrics.py::test_undeclared_optional_axis_is_not_required_and_never_passed[offline]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_undeclared_optional_axis_is_not_required_and_never_passed[mobile]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[unassessed]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[partial]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[missing]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[conflicting]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[intentionally-changed]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_authored_states_do_not_imply_approved_completion[retired]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_invalid_source_stays_visible_without_verified_numerator[repository_id-wrong]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_invalid_source_stays_visible_without_verified_numerator[artifact_sha256-0000000000000000000000000000000000000000000000000000000000000000]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_invalid_source_stays_visible_without_verified_numerator[feature_id-absent]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_duplicate_rows_are_all_invalid_and_count_one_missing_completion
FAILED tests/discovery_runtime/test_parity_metrics.py::test_multiple_clients_do_not_multiply_source_feature_identity
FAILED tests/discovery_runtime/test_parity_metrics.py::test_current_unresolved_decisions_exclude_historical_proposals[proposed-1]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_current_unresolved_decisions_exclude_historical_proposals[blocked-1]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_current_unresolved_decisions_exclude_historical_proposals[approved-1]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_current_unresolved_decisions_exclude_historical_proposals[rejected-0]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_current_unresolved_decisions_exclude_historical_proposals[superseded-0]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_all_authored_blockers_preserve_row_location
FAILED tests/discovery_runtime/test_parity_metrics.py::test_missing_source_authority_is_unavailable_not_zero[coverage-ledger]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_missing_source_authority_is_unavailable_not_zero[inventory-snapshot]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_present_optional_or_contradictory_claims_remain_independent[changes0]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_present_optional_or_contradictory_claims_remain_independent[changes1]
FAILED tests/discovery_runtime/test_parity_metrics.py::test_present_optional_or_contradictory_claims_remain_independent[changes2]
======================== 25 failed, 9 passed in 14.26s ========================
```
