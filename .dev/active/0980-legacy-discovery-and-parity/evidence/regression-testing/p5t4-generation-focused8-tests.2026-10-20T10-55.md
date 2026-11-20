# P5-T4 generation tests

Timestamp: 2026-10-20T10-51

Command: `poetry run coverage run --branch --source=drm_copilot_discovery.acceptance_generation,drm_copilot_discovery.acceptance_generation_context -m pytest -v --tb=short --maxfail=3 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_acceptance_generation.py tests/discovery_runtime/test_acceptance_decisions.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 214.574 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 45 items

tests/discovery_runtime/test_acceptance_generation.py::test_generation_retains_exact_identity_refs_and_rule_authority[False] PASSED [  2%]
tests/discovery_runtime/test_acceptance_generation.py::test_generation_retains_exact_identity_refs_and_rule_authority[True] PASSED [  4%]
tests/discovery_runtime/test_acceptance_generation.py::test_identity_survives_source_changes_while_provenance_changes[statement] PASSED [  6%]
tests/discovery_runtime/test_acceptance_generation.py::test_identity_survives_source_changes_while_provenance_changes[expected] PASSED [  8%]
tests/discovery_runtime/test_acceptance_generation.py::test_identity_survives_source_changes_while_provenance_changes[revision] PASSED [ 11%]
tests/discovery_runtime/test_acceptance_generation.py::test_identity_survives_source_changes_while_provenance_changes[whitespace] PASSED [ 13%]
tests/discovery_runtime/test_acceptance_generation.py::test_pending_criteria_preserve_questions_and_never_invent_then[The observed result is unknown.] PASSED [ 15%]
tests/discovery_runtime/test_acceptance_generation.py::test_pending_criteria_preserve_questions_and_never_invent_then[Unicode \u7d50\u679c remains unverified.] PASSED [ 17%]
tests/discovery_runtime/test_acceptance_generation.py::test_unknown_filters_fail_explicitly_without_default_selection[feature_ids-selection0] PASSED [ 20%]
tests/discovery_runtime/test_acceptance_generation.py::test_unknown_filters_fail_explicitly_without_default_selection[client_ids-selection1] PASSED [ 22%]
tests/discovery_runtime/test_acceptance_generation.py::test_unknown_filters_fail_explicitly_without_default_selection[mode_ids-selection2] PASSED [ 24%]
tests/discovery_runtime/test_acceptance_generation.py::test_integrity_failures_remain_blocking_before_generation_authority[malformed] PASSED [ 26%]
tests/discovery_runtime/test_acceptance_generation.py::test_integrity_failures_remain_blocking_before_generation_authority[missing-profile] PASSED [ 28%]
tests/discovery_runtime/test_acceptance_generation.py::test_integrity_failures_remain_blocking_before_generation_authority[pins] PASSED [ 31%]
tests/discovery_runtime/test_acceptance_generation.py::test_integrity_failures_remain_blocking_before_generation_authority[draft] PASSED [ 33%]
tests/discovery_runtime/test_acceptance_generation.py::test_integrity_failures_remain_blocking_before_generation_authority[duplicate] PASSED [ 35%]
tests/discovery_runtime/test_acceptance_generation.py::test_empty_actual_population_does_not_create_fallback_scenarios[no-criteria] PASSED [ 37%]
tests/discovery_runtime/test_acceptance_generation.py::test_empty_actual_population_does_not_create_fallback_scenarios[no-modes] FAILED [ 40%]
tests/discovery_runtime/test_acceptance_generation.py::test_empty_actual_population_does_not_create_fallback_scenarios[no-platforms] PASSED [ 42%]
tests/discovery_runtime/test_acceptance_decisions.py::test_only_current_approved_scoped_policy_can_supply_target_expectations[approved] FAILED [ 44%]
tests/discovery_runtime/test_acceptance_decisions.py::test_only_current_approved_scoped_policy_can_supply_target_expectations[proposed] PASSED [ 46%]
tests/discovery_runtime/test_acceptance_decisions.py::test_only_current_approved_scoped_policy_can_supply_target_expectations[rejected] PASSED [ 48%]
tests/discovery_runtime/test_acceptance_decisions.py::test_only_current_approved_scoped_policy_can_supply_target_expectations[superseded] PASSED [ 51%]
tests/discovery_runtime/test_acceptance_decisions.py::test_scope_conflicts_and_broken_links_never_create_ready_target_claims[scope] PASSED [ 53%]
tests/discovery_runtime/test_acceptance_decisions.py::test_scope_conflicts_and_broken_links_never_create_ready_target_claims[conflict] PASSED [ 55%]
tests/discovery_runtime/test_acceptance_decisions.py::test_scope_conflicts_and_broken_links_never_create_ready_target_claims[invalid-ref] PASSED [ 57%]
tests/discovery_runtime/test_acceptance_decisions.py::test_scope_conflicts_and_broken_links_never_create_ready_target_claims[identity-conflict] PASSED [ 60%]
tests/discovery_runtime/test_acceptance_decisions.py::test_linked_scenarios_discriminate_ids_without_replacing_criterion_expectations FAILED [ 62%]

================================== FAILURES ===================================
__ test_empty_actual_population_does_not_create_fallback_scenarios[no-modes] __
tests\discovery_runtime\test_acceptance_generation.py:444: in test_empty_actual_population_does_not_create_fallback_scenarios
    snapshot = generation_snapshot(
tests\discovery_runtime\test_acceptance_generation.py:128: in generation_snapshot
    profile = ProfileV2(json.dumps(document), format="json", catalog=catalog)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py:175: in __init__
    raise ProfileError(result.findings)
E   drm_copilot_discovery.profile_v2.ProfileError: /required_modes: [] should be non-empty
_ test_only_current_approved_scoped_policy_can_supply_target_expectations[approved] _
tests\discovery_runtime\test_acceptance_decisions.py:136: in test_only_current_approved_scoped_policy_can_supply_target_expectations
    assert target.document["then"] == (
E   AssertionError: assert None == ('Active state is visible before activation returns.',)
_ test_linked_scenarios_discriminate_ids_without_replacing_criterion_expectations _
tests\discovery_runtime\test_acceptance_decisions.py:227: in test_linked_scenarios_discriminate_ids_without_replacing_criterion_expectations
    assert len(result.ready) == 2 and result.findings == (), result.findings
E   AssertionError: (Finding(code='SCHEMA_INVALID', message='[] should be non-empty', next_action='Correct the field against the expected schema.', severity='error', artifact_path='docs/migration/discovery/scenario-alpha.json', pointer='/runs', related_ids=(), related_paths=()), Finding(code='SCHEMA_INVALID', message='[] should be non-empty', next_action='Correct the field against the expected schema.', severity='error', artifact_path='docs/migration/discovery/scenario-beta.json', pointer='/runs', related_ids=(), related_paths=()))
E   assert (0 == 2)
E    +  where 0 = len(())
E    +    where () = AcceptanceGeneration(specifications=(), ready=(), findings=(Finding(code='SCHEMA_INVALID', message='[] should be non-empty', next_action='Correct the field against the expected schema.', severity='error', artifact_path='docs/migration/discovery/scenario-alpha.json', pointer='/runs', related_ids=(), related_paths=()), Finding(code='SCHEMA_INVALID', message='[] should be non-empty', next_action='Correct the field against the expected schema.', severity='error', artifact_path='docs/migration/discovery/scenario-beta.json', pointer='/runs', related_ids=(), related_paths=())), limits=ParseLimits(document_bytes=16777216, nesting_depth=64, artifact_records=100000, findings=100)).ready
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_acceptance_generation.py::test_empty_actual_population_does_not_create_fallback_scenarios[no-modes]
FAILED tests/discovery_runtime/test_acceptance_decisions.py::test_only_current_approved_scoped_policy_can_supply_target_expectations[approved]
FAILED tests/discovery_runtime/test_acceptance_decisions.py::test_linked_scenarios_discriminate_ids_without_replacing_criterion_expectations
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 3 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
================== 3 failed, 25 passed in 212.63s (0:03:32) ===================

```
