# P6-T1 core service tests

Timestamp: 2026-10-20T15-53

Command: `poetry run coverage run --branch --source=drm_copilot_discovery.service,drm_copilot_discovery.operations,drm_copilot_discovery.service_inspection,drm_copilot_discovery.service_reports,drm_copilot_discovery.service_mutations,drm_copilot_discovery.service_bootstrap -m pytest -v --tb=short --maxfail=8 -o addopts= -p no:cacheprovider tests/discovery_runtime/test_service.py tests/discovery_runtime/test_service_publication.py tests/discovery_runtime/test_service_boundaries.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 80.402 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- <WORKSPACE>\.venv\Scripts\python.exe
rootdir: <WORKSPACE>
configfile: pyproject.toml
collecting ... collected 109 items

tests/discovery_runtime/test_service.py::test_malformed_request_stops_before_authority[fields0] PASSED [  0%]
tests/discovery_runtime/test_service.py::test_malformed_request_stops_before_authority[fields1] PASSED [  1%]
tests/discovery_runtime/test_service.py::test_malformed_request_stops_before_authority[fields2] PASSED [  2%]
tests/discovery_runtime/test_service.py::test_malformed_request_stops_before_authority[fields3] PASSED [  3%]
tests/discovery_runtime/test_service.py::test_malformed_request_stops_before_authority[fields4] PASSED [  4%]
tests/discovery_runtime/test_service.py::test_explicit_host_or_spoofed_reference_never_falls_back[host] PASSED [  5%]
tests/discovery_runtime/test_service.py::test_explicit_host_or_spoofed_reference_never_falls_back[invocation_ref] PASSED [  6%]
tests/discovery_runtime/test_service.py::test_explicit_host_or_spoofed_reference_never_falls_back[authorization_ref] PASSED [  7%]
tests/discovery_runtime/test_service.py::test_installed_identity_failure_is_not_a_resource_only_success PASSED [  8%]
tests/discovery_runtime/test_service.py::test_profile_operations_preserve_v2_and_actual_manifest[profile] PASSED [  9%]
tests/discovery_runtime/test_service.py::test_profile_operations_preserve_v2_and_actual_manifest[validate-profile] PASSED [ 10%]
tests/discovery_runtime/test_service.py::test_true_v1_profile_uses_legacy_parser_without_inventing_v2_capture[True] PASSED [ 11%]
tests/discovery_runtime/test_service.py::test_true_v1_profile_uses_legacy_parser_without_inventing_v2_capture[False] PASSED [ 11%]
tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[list] FAILED [ 12%]
tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[read] FAILED [ 13%]
tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[search] FAILED [ 14%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-feature-contract] FAILED [ 15%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-coverage-ledger] FAILED [ 16%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-runtime-scenario] FAILED [ 17%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-parity-matrix] FAILED [ 18%]
tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-unspecified-behavior] FAILED [ 19%]

================================== FAILURES ===================================
_____ test_source_page_preserves_authorized_bytes_and_line_identity[list] _____
tests\discovery_runtime\test_service.py:351: in test_source_page_preserves_authorized_bytes_and_line_identity
    assert result.ok, result.findings
E   AssertionError: (Finding(code='PROFILE_DRAFT', message='Draft configuration cannot satisfy completion or planning prerequisites.', next_action='Supply roots, repository pins and clients, then configure the profile.', severity='error', artifact_path=None, pointer='/profile_state', related_ids=(), related_paths=()),)
E   assert False
E    +  where False = DiscoveryResult(operation='read-source', mode='structural', ok=False, exit_code=2, findings=(Finding(code='PROFILE_DRAFT', message='Draft configuration cannot satisfy completion or planning prerequisites.', next_action='Supply roots, repository pins and clients, then configure the profile.', severity='error', artifact_path=None, pointer='/profile_state', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation could not start.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=None, runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).ok
_____ test_source_page_preserves_authorized_bytes_and_line_identity[read] _____
tests\discovery_runtime\test_service.py:351: in test_source_page_preserves_authorized_bytes_and_line_identity
    assert result.ok, result.findings
E   AssertionError: (Finding(code='PROFILE_DRAFT', message='Draft configuration cannot satisfy completion or planning prerequisites.', next_action='Supply roots, repository pins and clients, then configure the profile.', severity='error', artifact_path=None, pointer='/profile_state', related_ids=(), related_paths=()),)
E   assert False
E    +  where False = DiscoveryResult(operation='read-source', mode='structural', ok=False, exit_code=2, findings=(Finding(code='PROFILE_DRAFT', message='Draft configuration cannot satisfy completion or planning prerequisites.', next_action='Supply roots, repository pins and clients, then configure the profile.', severity='error', artifact_path=None, pointer='/profile_state', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation could not start.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=None, runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).ok
____ test_source_page_preserves_authorized_bytes_and_line_identity[search] ____
tests\discovery_runtime\test_service.py:351: in test_source_page_preserves_authorized_bytes_and_line_identity
    assert result.ok, result.findings
E   AssertionError: (Finding(code='PROFILE_DRAFT', message='Draft configuration cannot satisfy completion or planning prerequisites.', next_action='Supply roots, repository pins and clients, then configure the profile.', severity='error', artifact_path=None, pointer='/profile_state', related_ids=(), related_paths=()),)
E   assert False
E    +  where False = DiscoveryResult(operation='read-source', mode='structural', ok=False, exit_code=2, findings=(Finding(code='PROFILE_DRAFT', message='Draft configuration cannot satisfy completion or planning prerequisites.', next_action='Supply roots, repository pins and clients, then configure the profile.', severity='error', artifact_path=None, pointer='/profile_state', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation could not start.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=None, runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).ok
_ test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-feature-contract] _
tests\discovery_runtime\test_service.py:379: in test_individual_kind_failure_does_not_hide_graph_wide_blockers
    assert result.exit_code == 1 and result.findings
E   AssertionError: assert (2 == 1)
E    +  where 2 = DiscoveryResult(operation='validate-feature-contract', mode='structural', ok=False, exit_code=2, findings=(Finding(code='PROFILE_DRAFT', message='Draft configuration cannot satisfy completion or planning prerequisites.', next_action='Supply roots, repository pins and clients, then configure the profile.', severity='error', artifact_path=None, pointer='/profile_state', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation could not start.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=None, runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).exit_code
_ test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-coverage-ledger] _
tests\discovery_runtime\test_service.py:379: in test_individual_kind_failure_does_not_hide_graph_wide_blockers
    assert result.exit_code == 1 and result.findings
E   AssertionError: assert (2 == 1)
E    +  where 2 = DiscoveryResult(operation='validate-coverage-ledger', mode='structural', ok=False, exit_code=2, findings=(Finding(code='PROFILE_DRAFT', message='Draft configuration cannot satisfy completion or planning prerequisites.', next_action='Supply roots, repository pins and clients, then configure the profile.', severity='error', artifact_path=None, pointer='/profile_state', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation could not start.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=None, runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).exit_code
_ test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-runtime-scenario] _
tests\discovery_runtime\test_service.py:379: in test_individual_kind_failure_does_not_hide_graph_wide_blockers
    assert result.exit_code == 1 and result.findings
E   AssertionError: assert (2 == 1)
E    +  where 2 = DiscoveryResult(operation='validate-runtime-scenario', mode='structural', ok=False, exit_code=2, findings=(Finding(code='PROFILE_DRAFT', message='Draft configuration cannot satisfy completion or planning prerequisites.', next_action='Supply roots, repository pins and clients, then configure the profile.', severity='error', artifact_path=None, pointer='/profile_state', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation could not start.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=None, runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).exit_code
_ test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-parity-matrix] _
tests\discovery_runtime\test_service.py:379: in test_individual_kind_failure_does_not_hide_graph_wide_blockers
    assert result.exit_code == 1 and result.findings
E   AssertionError: assert (2 == 1)
E    +  where 2 = DiscoveryResult(operation='validate-parity-matrix', mode='structural', ok=False, exit_code=2, findings=(Finding(code='PROFILE_DRAFT', message='Draft configuration cannot satisfy completion or planning prerequisites.', next_action='Supply roots, repository pins and clients, then configure the profile.', severity='error', artifact_path=None, pointer='/profile_state', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation could not start.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=None, runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).exit_code
_ test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-unspecified-behavior] _
tests\discovery_runtime\test_service.py:379: in test_individual_kind_failure_does_not_hide_graph_wide_blockers
    assert result.exit_code == 1 and result.findings
E   AssertionError: assert (2 == 1)
E    +  where 2 = DiscoveryResult(operation='validate-unspecified-behavior', mode='structural', ok=False, exit_code=2, findings=(Finding(code='PROFILE_DRAFT', message='Draft configuration cannot satisfy completion or planning prerequisites.', next_action='Supply roots, repository pins and clients, then configure the profile.', severity='error', artifact_path=None, pointer='/profile_state', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation could not start.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=None, runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).exit_code
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[list]
FAILED tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[read]
FAILED tests/discovery_runtime/test_service.py::test_source_page_preserves_authorized_bytes_and_line_identity[search]
FAILED tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-feature-contract]
FAILED tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-coverage-ledger]
FAILED tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-runtime-scenario]
FAILED tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-parity-matrix]
FAILED tests/discovery_runtime/test_service.py::test_individual_kind_failure_does_not_hide_graph_wide_blockers[validate-unspecified-behavior]
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 8 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
=================== 8 failed, 13 passed in 78.40s (0:01:18) ===================
<WORKSPACE>\.venv\Lib\site-packages\coverage\inorout.py:495: CoverageWarning: Module drm_copilot_discovery.service_bootstrap was never imported. (module-not-imported); see https://coverage.readthedocs.io/en/7.13.2/messages.html#warning-module-not-imported
  self.warn(f"Module {pkg} was never imported.", slug="module-not-imported")
```
