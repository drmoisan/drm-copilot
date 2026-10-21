# P6-T1 publication repair tests

Timestamp: 2026-10-21T07-52

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v --tb=short --maxfail=0 -o addopts= -p no:cacheprovider -p pytest_cov --cov=drm_copilot_discovery.service_bootstrap --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p6t1-publication-repair-074132-tests-coverage.json tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[coverage-ledger] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[evidence-reference] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[feature-contract] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[parity-matrix] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[product-decision] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[runtime-characterization-scenario] tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[unspecified-behavior] tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[unknown] tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[body-mismatch] tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True] tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False] tests/discovery_runtime/test_service_publication.py::test_snapshot_export_uses_authored_identity_and_complete_original_capture[False] tests/discovery_runtime/test_service_publication.py::test_snapshot_export_uses_authored_identity_and_complete_original_capture[True] tests/discovery_runtime/test_service_publication.py::test_clean_snapshot_export_publishes_exact_files tests/discovery_runtime/test_service_publication.py::test_link_evidence_uses_captured_payload_and_exact_target_digest`

EXIT_CODE: 1

Output Summary: FAIL; 674.993 seconds; 11 passed nodes.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: cov-7.0.0
collecting ... collected 15 items

tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[coverage-ledger] PASSED [  6%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[evidence-reference] PASSED [ 13%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[feature-contract] PASSED [ 20%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[parity-matrix] PASSED [ 26%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[product-decision] PASSED [ 33%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[runtime-characterization-scenario] PASSED [ 40%]
tests/discovery_runtime/test_service_migration.py::test_registered_v1_kind_reaches_exact_migration_request[unspecified-behavior] PASSED [ 46%]
tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[unknown] PASSED [ 53%]
tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[body-mismatch] FAILED [ 60%]
tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True] FAILED [ 66%]
tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False] FAILED [ 73%]
tests/discovery_runtime/test_service_publication.py::test_snapshot_export_uses_authored_identity_and_complete_original_capture[False] PASSED [ 80%]
tests/discovery_runtime/test_service_publication.py::test_snapshot_export_uses_authored_identity_and_complete_original_capture[True] PASSED [ 86%]
tests/discovery_runtime/test_service_publication.py::test_clean_snapshot_export_publishes_exact_files PASSED [ 93%]
tests/discovery_runtime/test_service_publication.py::test_link_evidence_uses_captured_payload_and_exact_target_digest FAILED [100%]

================================== FAILURES ===================================
_______ test_invalid_v1_schema_identity_never_publishes[body-mismatch] ________
tests\discovery_runtime\test_service_migration.py:103: in test_invalid_v1_schema_identity_never_publishes
    assert any(
E   AssertionError: (Finding(code='INITIALIZATION_CONFLICT', message='Initialization conflicts with an existing path.', next_action='Reconcile this path before retrying.', severity='error', artifact_path='legacy/coverage-ledger.json', pointer='', related_ids=(), related_paths=()),)
E   assert False
E    +  where False = any(<generator object test_invalid_v1_schema_identity_never_publishes.<locals>.<genexpr> at 0x000002B3A8967B90>)
____ test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True] _____
tests\discovery_runtime\test_service_publication.py:438: in test_migration_uses_explicit_v1_bytes_and_reports_real_effects
    assert result.ok and result.artifacts, result.findings
E   AssertionError: (Finding(code='INITIALIZATION_CONFLICT', message='Initialization conflicts with an existing path.', next_action='Reconcile this path before retrying.', severity='error', artifact_path='legacy/coverage-ledger.json', pointer='', related_ids=(), related_paths=()),)
E   assert (False)
E    +  where False = DiscoveryResult(operation='migrate', mode='structural', ok=False, exit_code=1, findings=(Finding(code='INITIALIZATION_CONFLICT', message='Initialization conflicts with an existing path.', next_action='Reconcile this path before retrying.', severity='error', artifact_path='legacy/coverage-ledger.json', pointer='', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation did not pass.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=InputManifest(files=(SnapshotFile(path='legacy/coverage-ledger.json', content=b'{"$schema": "../../../schemas/discovery/v1/coverage-ledger.schema.json", "entries": [{"evidence_refs": ["evidence-alpha-001"], "feature_ids": ["feature-alpha"], "notes": "Behavior characterized against the captured runtime log.", "status": "characterized", "unit_id": "unit-alpha", "unit_kind": "module"}, {"notes": "Unit deferred pending further discovery.", "status": "in_discovery", "unit_id": "unit-beta", "unit_kind": "component"}], "generated_at": "2026-07-18T10:12:00Z", "id": "coverage-ledger-alpha", "schema_version": "1.0.0", "subject": "legacy core corpus", "summary": {"covered_units": 1, "total_units": 2}}', category='documentation'),), missing_paths=(), source_repositories=(), target_repositories=()), runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).ok
____ test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False] ____
tests\discovery_runtime\test_service_publication.py:438: in test_migration_uses_explicit_v1_bytes_and_reports_real_effects
    assert result.ok and result.artifacts, result.findings
E   AssertionError: (Finding(code='INITIALIZATION_CONFLICT', message='Initialization conflicts with an existing path.', next_action='Reconcile this path before retrying.', severity='error', artifact_path='legacy/coverage-ledger.json', pointer='', related_ids=(), related_paths=()),)
E   assert (False)
E    +  where False = DiscoveryResult(operation='migrate', mode='structural', ok=False, exit_code=1, findings=(Finding(code='INITIALIZATION_CONFLICT', message='Initialization conflicts with an existing path.', next_action='Reconcile this path before retrying.', severity='error', artifact_path='legacy/coverage-ledger.json', pointer='', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation did not pass.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=InputManifest(files=(SnapshotFile(path='legacy/coverage-ledger.json', content=b'{"$schema": "../../../schemas/discovery/v1/coverage-ledger.schema.json", "entries": [{"evidence_refs": ["evidence-alpha-001"], "feature_ids": ["feature-alpha"], "notes": "Behavior characterized against the captured runtime log.", "status": "characterized", "unit_id": "unit-alpha", "unit_kind": "module"}, {"notes": "Unit deferred pending further discovery.", "status": "in_discovery", "unit_id": "unit-beta", "unit_kind": "component"}], "generated_at": "2026-07-18T10:12:00Z", "id": "coverage-ledger-alpha", "schema_version": "1.0.0", "subject": "legacy core corpus", "summary": {"covered_units": 1, "total_units": 2}}', category='documentation'),), missing_paths=(), source_repositories=(), target_repositories=()), runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).ok
______ test_link_evidence_uses_captured_payload_and_exact_target_digest _______
tests\discovery_runtime\test_service_publication.py:479: in test_link_evidence_uses_captured_payload_and_exact_target_digest
    assert result.ok, result.findings
E   AssertionError: (Finding(code='CLAIM_RUNTIME_EVIDENCE', message='Runtime references require usable runtime capture evidence.', next_action='Correct the identity or supply the artifact, then validate again.', severity='error', artifact_path='docs/migration/discovery/feature-contracts/feature.json', pointer='/runtime_evidence_refs', related_ids=(), related_paths=()),)
E   assert False
E    +  where False = DiscoveryResult(operation='link-evidence', mode='structural', ok=False, exit_code=1, findings=(Finding(code='CLAIM_RUNTIME_EVIDENCE', message='Runtime references require usable runtime capture evidence.', next_action='Correct the identity or supply the artifact, then validate again.', severity='error', artifact_path='docs/migration/discovery/feature-contracts/feature.json', pointer='/runtime_evidence_refs', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation did not pass.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=InputManifest(files=(SnapshotFile(path='config/discovery.json', content=b'{\n  "enabled": true,\n  "profile_path": "docs/migration/discovery/domain-profile.yaml",\n  "required_runtime_major": 2,\n  "schema_version": "2.0.0"\n}\n', category='activation'), SnapshotFile(path='docs/migration/discovery/coverage-ledger.json', content=b'{"$schema":"urn:drm-copilot:discovery:2.0.0:coverage-ledger","artifact_kind":"coverage-ledger","components":[],"extensions":{},"id":"ledger-consumer-system","inventory_snapshot_refs":[],"repository":"consumer-repository","rev...ind":"human"},"checksum":{"algorithm":"sha256","value":"c1c5b3571fb5b5641631d085e69ed43ba7c499ab90821ef394dab3c86ee2e32c"},"confidence":"high","environment":{"client_id":null,"extensions":{},"id":"environment-alpha","operating_mode":"online","platform":"generic"},"evidence_id":"proof","evidence_type":"runtime","extensions":{},"id":"proof","notes":"Manual pre-state and post-state capture in an isolated synthetic environment.","path":"proposals/capture.txt","repository":"consumer-repository","revision":null,"runtime_artifact":{"capture_method":"manual","path":"proposals/capture.txt"},"schema_version":"2.0.0","timestamp":"2026-01-01T00:00:00Z"}\n', category='documentation')), missing_paths=(), source_repositories=(RepositoryIdentity(id='consumer-repository', revision='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),), target_repositories=(RepositoryIdentity(id='consumer-repository', revision='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'),)), runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).ok
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                        Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\service_bootstrap.py     110     70     28      4    35%   34, 83-98, 112-160, 177-232, 264, 291-331, 353, 355, 358
-----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                         110     70     28      4    35%
Coverage JSON written to file SCRATCH\p6t1-publication-repair-074132-tests-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_service_migration.py::test_invalid_v1_schema_identity_never_publishes[body-mismatch]
FAILED tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True]
FAILED tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False]
FAILED tests/discovery_runtime/test_service_publication.py::test_link_evidence_uses_captured_payload_and_exact_target_digest
================== 4 failed, 11 passed in 674.30s (0:11:14) ===================

```
