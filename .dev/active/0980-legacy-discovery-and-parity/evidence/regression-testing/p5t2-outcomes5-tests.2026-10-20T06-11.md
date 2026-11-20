# P5-T2 outcomes5-tests

Timestamp: 2026-10-20T06-11

Command: poetry run pytest -o addopts= -vv tests/discovery_runtime/test_parity_clients.py tests/discovery_runtime/test_parity_rules.py tests/discovery_runtime/test_parity_models.py --cov=drm_copilot_discovery.parity_rules --cov=drm_copilot_discovery.parity_entry_rules --cov=drm_copilot_discovery.parity_models --cov=drm_copilot_discovery.parity_target_rules --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/outcomes5-coverage.json

EXIT_CODE: 1

Output Summary: Exact scoped stage completed in 9.271s; raw bytes are retained in the JSON receipt.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 87 items

tests/discovery_runtime/test_parity_clients.py::test_optional_rows_do_not_block_required_completion[partial] PASSED [  1%]
tests/discovery_runtime/test_parity_clients.py::test_optional_rows_do_not_block_required_completion[missing] PASSED [  2%]
tests/discovery_runtime/test_parity_clients.py::test_optional_rows_do_not_block_required_completion[conflicting] PASSED [  3%]
tests/discovery_runtime/test_parity_clients.py::test_optional_rows_do_not_block_required_completion[unassessed] PASSED [  4%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[applicability-online] PASSED [  5%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[applicability-offline] PASSED [  6%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[applicability-mobile] PASSED [  8%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[verification-online] PASSED [  9%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[verification-offline] PASSED [ 10%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[verification-mobile] PASSED [ 11%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[proof-online] PASSED [ 12%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[proof-offline] PASSED [ 13%]
tests/discovery_runtime/test_parity_clients.py::test_both_mode_representations_must_agree_and_have_valid_proof[proof-mobile] PASSED [ 14%]
tests/discovery_runtime/test_parity_clients.py::test_matching_duplicate_online_classifications_are_valid PASSED [ 16%]
tests/discovery_runtime/test_parity_clients.py::test_required_dimension_cannot_be_absent_or_unverified[True] PASSED [ 17%]
tests/discovery_runtime/test_parity_clients.py::test_required_dimension_cannot_be_absent_or_unverified[False] PASSED [ 18%]
tests/discovery_runtime/test_parity_clients.py::test_target_dispositions_need_current_covering_approval[True-intentionally-changed] PASSED [ 19%]
tests/discovery_runtime/test_parity_clients.py::test_target_dispositions_need_current_covering_approval[True-retired] PASSED [ 20%]
tests/discovery_runtime/test_parity_clients.py::test_target_dispositions_need_current_covering_approval[False-intentionally-changed] PASSED [ 21%]
tests/discovery_runtime/test_parity_clients.py::test_target_dispositions_need_current_covering_approval[False-retired] PASSED [ 22%]
tests/discovery_runtime/test_parity_clients.py::test_retirement_does_not_hide_present_false_mode_claims[conflict] PASSED [ 24%]
tests/discovery_runtime/test_parity_clients.py::test_retirement_does_not_hide_present_false_mode_claims[proof] PASSED [ 25%]
tests/discovery_runtime/test_parity_clients.py::test_required_nonapplicability_needs_explicit_scoped_waiver[True] PASSED [ 26%]
tests/discovery_runtime/test_parity_clients.py::test_required_nonapplicability_needs_explicit_scoped_waiver[False] PASSED [ 27%]
tests/discovery_runtime/test_parity_clients.py::test_mobile_dimension_uses_configured_portable_platform PASSED [ 28%]
tests/discovery_runtime/test_parity_clients.py::test_passing_tests_cannot_cover_an_unrelated_coordinate[modes-value0] PASSED [ 29%]
tests/discovery_runtime/test_parity_clients.py::test_passing_tests_cannot_cover_an_unrelated_coordinate[platforms-value1] PASSED [ 31%]
tests/discovery_runtime/test_parity_clients.py::test_each_configured_client_has_an_independent_required_row PASSED [ 32%]
tests/discovery_runtime/test_parity_clients.py::test_combined_repository_source_test_proof_is_not_target_execution[False] PASSED [ 33%]
tests/discovery_runtime/test_parity_clients.py::test_combined_repository_source_test_proof_is_not_target_execution[True] PASSED [ 34%]
tests/discovery_runtime/test_parity_clients.py::test_imported_historical_source_is_resolved_at_its_own_pin PASSED [ 35%]
tests/discovery_runtime/test_parity_clients.py::test_reused_assessments_and_artifact_order_have_identical_findings PASSED [ 36%]
tests/discovery_runtime/test_parity_clients.py::test_target_proof_helpers_reject_invalid_direct_context PASSED [ 37%]
tests/discovery_runtime/test_parity_rules.py::test_full_parity_uses_target_proof_and_preserves_snapshot PASSED [ 39%]
tests/discovery_runtime/test_parity_rules.py::test_source_link_must_match_exact_identity_and_bytes[artifact_sha256-0000000000000000000000000000000000000000000000000000000000000000] PASSED [ 40%]
tests/discovery_runtime/test_parity_rules.py::test_source_link_must_match_exact_identity_and_bytes[revision-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb] PASSED [ 41%]
tests/discovery_runtime/test_parity_rules.py::test_source_link_must_match_exact_identity_and_bytes[feature_id-absent] PASSED [ 42%]
tests/discovery_runtime/test_parity_rules.py::test_source_link_must_match_exact_identity_and_bytes[repository_id-foreign] PASSED [ 43%]
tests/discovery_runtime/test_parity_rules.py::test_source_link_must_match_exact_identity_and_bytes[artifact_path-missing.json] PASSED [ 44%]
tests/discovery_runtime/test_parity_rules.py::test_incomplete_states_are_truthful_drafts_but_not_required_completion[unassessed] PASSED [ 45%]
tests/discovery_runtime/test_parity_rules.py::test_incomplete_states_are_truthful_drafts_but_not_required_completion[partial] PASSED [ 47%]
tests/discovery_runtime/test_parity_rules.py::test_incomplete_states_are_truthful_drafts_but_not_required_completion[missing] PASSED [ 48%]
tests/discovery_runtime/test_parity_rules.py::test_incomplete_states_are_truthful_drafts_but_not_required_completion[conflicting] PASSED [ 49%]
tests/discovery_runtime/test_parity_rules.py::test_entry_requires_configured_target_identity[target_repository-value0] PASSED [ 50%]
tests/discovery_runtime/test_parity_rules.py::test_entry_requires_configured_target_identity[client_id-absent] PASSED [ 51%]
tests/discovery_runtime/test_parity_rules.py::test_invalid_or_foreign_capture_cannot_support_full_parity[checksum-value0] PASSED [ 52%]
tests/discovery_runtime/test_parity_rules.py::test_invalid_or_foreign_capture_cannot_support_full_parity[path-None] PASSED [ 54%]
tests/discovery_runtime/test_parity_rules.py::test_invalid_or_foreign_capture_cannot_support_full_parity[revision-bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb] PASSED [ 55%]
tests/discovery_runtime/test_parity_rules.py::test_invalid_or_foreign_capture_cannot_support_full_parity[repository-foreign] PASSED [ 56%]
tests/discovery_runtime/test_parity_rules.py::test_invalid_or_foreign_capture_cannot_support_full_parity[environment-value4] PASSED [ 57%]
tests/discovery_runtime/test_parity_rules.py::test_nonexecution_payload_cannot_be_target_execution[source] PASSED [ 58%]
tests/discovery_runtime/test_parity_rules.py::test_nonexecution_payload_cannot_be_target_execution[documentation] PASSED [ 59%]
tests/discovery_runtime/test_parity_rules.py::test_nonexecution_payload_cannot_be_target_execution[inventory] PASSED [ 60%]
tests/discovery_runtime/test_parity_rules.py::test_nonexecution_payload_cannot_be_target_execution[decision] PASSED [ 62%]
tests/discovery_runtime/test_parity_rules.py::test_implementation_claims_have_independent_integrity[client_id-absent] PASSED [ 63%]
tests/discovery_runtime/test_parity_rules.py::test_implementation_claims_have_independent_integrity[target_repository-None] PASSED [ 64%]
tests/discovery_runtime/test_parity_rules.py::test_implementation_claims_have_independent_integrity[implementation_paths-value2] PASSED [ 65%]
tests/discovery_runtime/test_parity_rules.py::test_implementation_claims_have_independent_integrity[feature_refs-value3] PASSED [ 66%]
tests/discovery_runtime/test_parity_rules.py::test_implementation_claims_have_independent_integrity[verification_state-failed] PASSED [ 67%]
tests/discovery_runtime/test_parity_rules.py::test_implementation_claims_have_independent_integrity[test_references-value5] PASSED [ 68%]
tests/discovery_runtime/test_parity_rules.py::test_passing_component_cannot_mask_another_linked_incomplete_component[failed] PASSED [ 70%]
tests/discovery_runtime/test_parity_rules.py::test_passing_component_cannot_mask_another_linked_incomplete_component[not-run] PASSED [ 71%]
tests/discovery_runtime/test_parity_rules.py::test_full_result_cannot_hide_explicit_blockers[blockers-value0] PASSED [ 72%]
tests/discovery_runtime/test_parity_rules.py::test_full_result_cannot_hide_explicit_blockers[validation_status-fail] PASSED [ 73%]
tests/discovery_runtime/test_parity_rules.py::test_duplicate_entries_and_missing_required_entries_are_not_complete PASSED [ 74%]
tests/discovery_runtime/test_parity_rules.py::test_unexecuted_implementation_requires_an_explicit_reason[None-blocked] PASSED [ 75%]
tests/discovery_runtime/test_parity_rules.py::test_unexecuted_implementation_requires_an_explicit_reason[None-not-applicable] PASSED [ 77%]
tests/discovery_runtime/test_parity_rules.py::test_unexecuted_implementation_requires_an_explicit_reason[Unavailable in the captured environment.-blocked] PASSED [ 78%]
tests/discovery_runtime/test_parity_rules.py::test_unexecuted_implementation_requires_an_explicit_reason[Unavailable in the captured environment.-not-applicable] PASSED [ 79%]
tests/discovery_runtime/test_parity_rules.py::test_test_byte_ownership_cannot_be_substituted[None] PASSED [ 80%]
tests/discovery_runtime/test_parity_rules.py::test_test_byte_ownership_cannot_be_substituted[test_source1] PASSED [ 81%]
tests/discovery_runtime/test_parity_rules.py::test_test_byte_ownership_cannot_be_substituted[test_source2] PASSED [ 82%]
tests/discovery_runtime/test_parity_rules.py::test_one_passing_test_cannot_hide_an_explicit_failed_test PASSED [ 83%]
tests/discovery_runtime/test_parity_rules.py::test_capture_context_must_match_the_required_coordinate[other-online] PASSED [ 85%]
tests/discovery_runtime/test_parity_rules.py::test_capture_context_must_match_the_required_coordinate[browser-offline] PASSED [ 86%]
tests/discovery_runtime/test_parity_rules.py::test_wrong_target_revision_and_malformed_dimension_fail_without_exceptions PASSED [ 87%]
tests/discovery_runtime/test_parity_rules.py::test_non_evidence_source_links_do_not_disqualify_independent_target_capture PASSED [ 88%]
tests/discovery_runtime/test_parity_models.py::test_existing_findings_constructor_and_reexport_preserve_identity PASSED [ 89%]
tests/discovery_runtime/test_parity_models.py::test_completed_outcome_keeps_authored_state_and_actual_proof_distinct ERROR [ 90%]
tests/discovery_runtime/test_parity_models.py::test_incomplete_authored_states_never_become_complete[missing] ERROR [ 91%]
tests/discovery_runtime/test_parity_models.py::test_incomplete_authored_states_never_become_complete[unassessed] ERROR [ 93%]
tests/discovery_runtime/test_parity_models.py::test_incomplete_authored_states_never_become_complete[partial] ERROR [ 94%]
tests/discovery_runtime/test_parity_models.py::test_incomplete_authored_states_never_become_complete[conflicting] ERROR [ 95%]
tests/discovery_runtime/test_parity_models.py::test_every_duplicate_row_is_excluded_from_validated_completion ERROR [ 96%]
tests/discovery_runtime/test_parity_models.py::test_invalid_source_preserves_an_invalid_authored_row ERROR [ 97%]
tests/discovery_runtime/test_parity_models.py::test_upstream_findings_truncation_cannot_certify_complete_parity ERROR [ 98%]
tests/discovery_runtime/test_parity_models.py::test_missing_target_proof_is_retained_even_when_authored_state_is_full ERROR [100%]

=================================== ERRORS ====================================
_ ERROR at setup of test_completed_outcome_keeps_authored_state_and_actual_proof_distinct _
file WORKSPACE\tests\discovery_runtime\test_parity_models.py, line 44
  def test_completed_outcome_keeps_authored_state_and_actual_proof_distinct(
file WORKSPACE\tests\discovery_runtime\test_dimension_rules.py, line 64
  @pytest.fixture(scope="module")
  def obligation_profile(
E       fixture 'snapshot_profile' not found
>       available fixtures: anyio_backend, anyio_backend_name, anyio_backend_options, cache, capfd, capfdbinary, caplog, capsys, capsysbinary, capteesys, cov, doctest_namespace, free_tcp_port, free_tcp_port_factory, free_udp_port, free_udp_port_factory, guard_unmocked_code_launcher_subprocess, mem_fs_path, monkeypatch, no_cover, obligation_profile, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, snapshot_catalog, subtests, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

WORKSPACE\tests\discovery_runtime\test_dimension_rules.py:64
_ ERROR at setup of test_incomplete_authored_states_never_become_complete[missing] _
file WORKSPACE\tests\discovery_runtime\test_parity_models.py, line 71
  @pytest.mark.parametrize("state", ["missing", "unassessed", "partial", "conflicting"])
  def test_incomplete_authored_states_never_become_complete(
file WORKSPACE\tests\discovery_runtime\test_dimension_rules.py, line 64
  @pytest.fixture(scope="module")
  def obligation_profile(
E       fixture 'snapshot_profile' not found
>       available fixtures: anyio_backend, anyio_backend_name, anyio_backend_options, cache, capfd, capfdbinary, caplog, capsys, capsysbinary, capteesys, cov, doctest_namespace, free_tcp_port, free_tcp_port_factory, free_udp_port, free_udp_port_factory, guard_unmocked_code_launcher_subprocess, mem_fs_path, monkeypatch, no_cover, obligation_profile, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, snapshot_catalog, subtests, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

WORKSPACE\tests\discovery_runtime\test_dimension_rules.py:64
_ ERROR at setup of test_incomplete_authored_states_never_become_complete[unassessed] _
file WORKSPACE\tests\discovery_runtime\test_parity_models.py, line 71
  @pytest.mark.parametrize("state", ["missing", "unassessed", "partial", "conflicting"])
  def test_incomplete_authored_states_never_become_complete(
file WORKSPACE\tests\discovery_runtime\test_dimension_rules.py, line 64
  @pytest.fixture(scope="module")
  def obligation_profile(
E       fixture 'snapshot_profile' not found
>       available fixtures: anyio_backend, anyio_backend_name, anyio_backend_options, cache, capfd, capfdbinary, caplog, capsys, capsysbinary, capteesys, cov, doctest_namespace, free_tcp_port, free_tcp_port_factory, free_udp_port, free_udp_port_factory, guard_unmocked_code_launcher_subprocess, mem_fs_path, monkeypatch, no_cover, obligation_profile, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, snapshot_catalog, subtests, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

WORKSPACE\tests\discovery_runtime\test_dimension_rules.py:64
_ ERROR at setup of test_incomplete_authored_states_never_become_complete[partial] _
file WORKSPACE\tests\discovery_runtime\test_parity_models.py, line 71
  @pytest.mark.parametrize("state", ["missing", "unassessed", "partial", "conflicting"])
  def test_incomplete_authored_states_never_become_complete(
file WORKSPACE\tests\discovery_runtime\test_dimension_rules.py, line 64
  @pytest.fixture(scope="module")
  def obligation_profile(
E       fixture 'snapshot_profile' not found
>       available fixtures: anyio_backend, anyio_backend_name, anyio_backend_options, cache, capfd, capfdbinary, caplog, capsys, capsysbinary, capteesys, cov, doctest_namespace, free_tcp_port, free_tcp_port_factory, free_udp_port, free_udp_port_factory, guard_unmocked_code_launcher_subprocess, mem_fs_path, monkeypatch, no_cover, obligation_profile, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, snapshot_catalog, subtests, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

WORKSPACE\tests\discovery_runtime\test_dimension_rules.py:64
_ ERROR at setup of test_incomplete_authored_states_never_become_complete[conflicting] _
file WORKSPACE\tests\discovery_runtime\test_parity_models.py, line 71
  @pytest.mark.parametrize("state", ["missing", "unassessed", "partial", "conflicting"])
  def test_incomplete_authored_states_never_become_complete(
file WORKSPACE\tests\discovery_runtime\test_dimension_rules.py, line 64
  @pytest.fixture(scope="module")
  def obligation_profile(
E       fixture 'snapshot_profile' not found
>       available fixtures: anyio_backend, anyio_backend_name, anyio_backend_options, cache, capfd, capfdbinary, caplog, capsys, capsysbinary, capteesys, cov, doctest_namespace, free_tcp_port, free_tcp_port_factory, free_udp_port, free_udp_port_factory, guard_unmocked_code_launcher_subprocess, mem_fs_path, monkeypatch, no_cover, obligation_profile, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, snapshot_catalog, subtests, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

WORKSPACE\tests\discovery_runtime\test_dimension_rules.py:64
_ ERROR at setup of test_every_duplicate_row_is_excluded_from_validated_completion _
file WORKSPACE\tests\discovery_runtime\test_parity_models.py, line 97
  def test_every_duplicate_row_is_excluded_from_validated_completion(
file WORKSPACE\tests\discovery_runtime\test_dimension_rules.py, line 64
  @pytest.fixture(scope="module")
  def obligation_profile(
E       fixture 'snapshot_profile' not found
>       available fixtures: anyio_backend, anyio_backend_name, anyio_backend_options, cache, capfd, capfdbinary, caplog, capsys, capsysbinary, capteesys, cov, doctest_namespace, free_tcp_port, free_tcp_port_factory, free_udp_port, free_udp_port_factory, guard_unmocked_code_launcher_subprocess, mem_fs_path, monkeypatch, no_cover, obligation_profile, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, snapshot_catalog, subtests, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

WORKSPACE\tests\discovery_runtime\test_dimension_rules.py:64
___ ERROR at setup of test_invalid_source_preserves_an_invalid_authored_row ___
file WORKSPACE\tests\discovery_runtime\test_parity_models.py, line 122
  def test_invalid_source_preserves_an_invalid_authored_row(
file WORKSPACE\tests\discovery_runtime\test_dimension_rules.py, line 64
  @pytest.fixture(scope="module")
  def obligation_profile(
E       fixture 'snapshot_profile' not found
>       available fixtures: anyio_backend, anyio_backend_name, anyio_backend_options, cache, capfd, capfdbinary, caplog, capsys, capsysbinary, capteesys, cov, doctest_namespace, free_tcp_port, free_tcp_port_factory, free_udp_port, free_udp_port_factory, guard_unmocked_code_launcher_subprocess, mem_fs_path, monkeypatch, no_cover, obligation_profile, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, snapshot_catalog, subtests, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

WORKSPACE\tests\discovery_runtime\test_dimension_rules.py:64
_ ERROR at setup of test_upstream_findings_truncation_cannot_certify_complete_parity _
file WORKSPACE\tests\discovery_runtime\test_parity_models.py, line 142
  def test_upstream_findings_truncation_cannot_certify_complete_parity(
file WORKSPACE\tests\discovery_runtime\test_dimension_rules.py, line 64
  @pytest.fixture(scope="module")
  def obligation_profile(
E       fixture 'snapshot_profile' not found
>       available fixtures: anyio_backend, anyio_backend_name, anyio_backend_options, cache, capfd, capfdbinary, caplog, capsys, capsysbinary, capteesys, cov, doctest_namespace, free_tcp_port, free_tcp_port_factory, free_udp_port, free_udp_port_factory, guard_unmocked_code_launcher_subprocess, mem_fs_path, monkeypatch, no_cover, obligation_profile, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, snapshot_catalog, subtests, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

WORKSPACE\tests\discovery_runtime\test_dimension_rules.py:64
_ ERROR at setup of test_missing_target_proof_is_retained_even_when_authored_state_is_full _
file WORKSPACE\tests\discovery_runtime\test_parity_models.py, line 165
  def test_missing_target_proof_is_retained_even_when_authored_state_is_full(
file WORKSPACE\tests\discovery_runtime\test_dimension_rules.py, line 64
  @pytest.fixture(scope="module")
  def obligation_profile(
E       fixture 'snapshot_profile' not found
>       available fixtures: anyio_backend, anyio_backend_name, anyio_backend_options, cache, capfd, capfdbinary, caplog, capsys, capsysbinary, capteesys, cov, doctest_namespace, free_tcp_port, free_tcp_port_factory, free_udp_port, free_udp_port_factory, guard_unmocked_code_launcher_subprocess, mem_fs_path, monkeypatch, no_cover, obligation_profile, pytestconfig, record_property, record_testsuite_property, record_xml_attribute, recwarn, snapshot_catalog, subtests, tmp_path, tmp_path_factory, tmpdir, tmpdir_factory
>       use 'pytest --fixtures [testpath]' for help on them.

WORKSPACE\tests\discovery_runtime\test_dimension_rules.py:64
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                          Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\parity_entry_rules.py      139      2     56      3    97%   218->191, 266, 319
packages\discovery-runtime\src\drm_copilot_discovery\parity_models.py            35      0      0      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\parity_rules.py            104      2     38      1    98%   340-342
packages\discovery-runtime\src\drm_copilot_discovery\parity_target_rules.py      99      0     50      2    99%   101->98, 157->164
-------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                           377      4    144      6    98%
Coverage JSON written to file SCRATCH/outcomes5-coverage.json
=========================== short test summary info ===========================
ERROR tests/discovery_runtime/test_parity_models.py::test_completed_outcome_keeps_authored_state_and_actual_proof_distinct
ERROR tests/discovery_runtime/test_parity_models.py::test_incomplete_authored_states_never_become_complete[missing]
ERROR tests/discovery_runtime/test_parity_models.py::test_incomplete_authored_states_never_become_complete[unassessed]
ERROR tests/discovery_runtime/test_parity_models.py::test_incomplete_authored_states_never_become_complete[partial]
ERROR tests/discovery_runtime/test_parity_models.py::test_incomplete_authored_states_never_become_complete[conflicting]
ERROR tests/discovery_runtime/test_parity_models.py::test_every_duplicate_row_is_excluded_from_validated_completion
ERROR tests/discovery_runtime/test_parity_models.py::test_invalid_source_preserves_an_invalid_authored_row
ERROR tests/discovery_runtime/test_parity_models.py::test_upstream_findings_truncation_cannot_certify_complete_parity
ERROR tests/discovery_runtime/test_parity_models.py::test_missing_target_proof_is_retained_even_when_authored_state_is_full
======================== 78 passed, 9 errors in 7.47s =========================
```
