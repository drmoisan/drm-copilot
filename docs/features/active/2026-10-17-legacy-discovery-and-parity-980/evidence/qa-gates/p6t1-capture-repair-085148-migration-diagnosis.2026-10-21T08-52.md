# P6-T1 publication repair migration-diagnosis

Timestamp: 2026-10-21T08-52

Command: `WORKSPACE\.venv\Scripts\python.exe -u -m pytest -v --tb=short --maxfail=0 -o addopts= -p no:cacheprovider -p pytest_cov --cov=drm_copilot_discovery.service_bootstrap --cov-branch --cov=drm_copilot_discovery.migration_capture --cov=drm_copilot_discovery.mutation_plan --cov-report=term-missing --cov-report=json:SCRATCH\p6t1-capture-repair-085148-migration-diagnosis-coverage.json tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True] tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False] -p p6t1_failure_reports`

EXIT_CODE: 1

Output Summary: FAIL; 37.914 seconds; 0 passed nodes.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: cov-7.0.0
collecting ... collected 2 items

tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True] FAILED [ 50%]
IMMEDIATE_FAILURE_BEGIN tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True] call
tests\discovery_runtime\test_service_publication.py:438: in test_migration_uses_explicit_v1_bytes_and_reports_real_effects
    assert result.ok and result.artifacts, result.findings
E   AssertionError: (Finding(code='MIGRATION_REQUIRED_CONTEXT', message='The discovery operation could not satisfy its contract.', next_action='Correct the input or repair the trusted runtime and retry.', severity='error', artifact_path=None, pointer='/', related_ids=(), related_paths=()),)
E   assert (False)
E    +  where False = DiscoveryResult(operation='migrate', mode='structural', ok=False, exit_code=2, findings=(Finding(code='MIGRATION_REQUIRED_CONTEXT', message='The discovery operation could not satisfy its contract.', next_action='Correct the input or repair the trusted runtime and retry.', severity='error', artifact_path=None, pointer='/', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation did not pass.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=InputManifest(files=(SnapshotFile(path='legacy/coverage-ledger.json', content=b'{"$schema": "../../../schemas/discovery/v1/coverage-ledger.schema.json", "entries": [{"evidence_refs": ["evidence-alpha-001"], "feature_ids": ["feature-alpha"], "notes": "Behavior characterized against the captured runtime log.", "status": "characterized", "unit_id": "unit-alpha", "unit_kind": "module"}, {"notes": "Unit deferred pending further discovery.", "status": "in_discovery", "unit_id": "unit-beta", "unit_kind": "component"}], "generated_at": "2026-07-18T10:12:00Z", "id": "coverage-ledger-alpha", "schema_version": "1.0.0", "subject": "legacy core corpus", "summary": {"covered_units": 1, "total_units": 2}}', category='documentation'),), missing_paths=(), source_repositories=(), target_repositories=()), runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).ok
IMMEDIATE_FAILURE_END tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True]


tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False] FAILED [100%]
IMMEDIATE_FAILURE_BEGIN tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False] call
tests\discovery_runtime\test_service_publication.py:438: in test_migration_uses_explicit_v1_bytes_and_reports_real_effects
    assert result.ok and result.artifacts, result.findings
E   AssertionError: (Finding(code='MIGRATION_REQUIRED_CONTEXT', message='The discovery operation could not satisfy its contract.', next_action='Correct the input or repair the trusted runtime and retry.', severity='error', artifact_path=None, pointer='/', related_ids=(), related_paths=()),)
E   assert (False)
E    +  where False = DiscoveryResult(operation='migrate', mode='structural', ok=False, exit_code=2, findings=(Finding(code='MIGRATION_REQUIRED_CONTEXT', message='The discovery operation could not satisfy its contract.', next_action='Correct the input or repair the trusted runtime and retry.', severity='error', artifact_path=None, pointer='/', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation did not pass.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=InputManifest(files=(SnapshotFile(path='legacy/coverage-ledger.json', content=b'{"$schema": "../../../schemas/discovery/v1/coverage-ledger.schema.json", "entries": [{"evidence_refs": ["evidence-alpha-001"], "feature_ids": ["feature-alpha"], "notes": "Behavior characterized against the captured runtime log.", "status": "characterized", "unit_id": "unit-alpha", "unit_kind": "module"}, {"notes": "Unit deferred pending further discovery.", "status": "in_discovery", "unit_id": "unit-beta", "unit_kind": "component"}], "generated_at": "2026-07-18T10:12:00Z", "id": "coverage-ledger-alpha", "schema_version": "1.0.0", "subject": "legacy core corpus", "summary": {"covered_units": 1, "total_units": 2}}', category='documentation'),), missing_paths=(), source_repositories=(), target_repositories=()), runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).ok
IMMEDIATE_FAILURE_END tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False]



================================== FAILURES ===================================
____ test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True] _____
tests\discovery_runtime\test_service_publication.py:438: in test_migration_uses_explicit_v1_bytes_and_reports_real_effects
    assert result.ok and result.artifacts, result.findings
E   AssertionError: (Finding(code='MIGRATION_REQUIRED_CONTEXT', message='The discovery operation could not satisfy its contract.', next_action='Correct the input or repair the trusted runtime and retry.', severity='error', artifact_path=None, pointer='/', related_ids=(), related_paths=()),)
E   assert (False)
E    +  where False = DiscoveryResult(operation='migrate', mode='structural', ok=False, exit_code=2, findings=(Finding(code='MIGRATION_REQUIRED_CONTEXT', message='The discovery operation could not satisfy its contract.', next_action='Correct the input or repair the trusted runtime and retry.', severity='error', artifact_path=None, pointer='/', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation did not pass.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=InputManifest(files=(SnapshotFile(path='legacy/coverage-ledger.json', content=b'{"$schema": "../../../schemas/discovery/v1/coverage-ledger.schema.json", "entries": [{"evidence_refs": ["evidence-alpha-001"], "feature_ids": ["feature-alpha"], "notes": "Behavior characterized against the captured runtime log.", "status": "characterized", "unit_id": "unit-alpha", "unit_kind": "module"}, {"notes": "Unit deferred pending further discovery.", "status": "in_discovery", "unit_id": "unit-beta", "unit_kind": "component"}], "generated_at": "2026-07-18T10:12:00Z", "id": "coverage-ledger-alpha", "schema_version": "1.0.0", "subject": "legacy core corpus", "summary": {"covered_units": 1, "total_units": 2}}', category='documentation'),), missing_paths=(), source_repositories=(), target_repositories=()), runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).ok
____ test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False] ____
tests\discovery_runtime\test_service_publication.py:438: in test_migration_uses_explicit_v1_bytes_and_reports_real_effects
    assert result.ok and result.artifacts, result.findings
E   AssertionError: (Finding(code='MIGRATION_REQUIRED_CONTEXT', message='The discovery operation could not satisfy its contract.', next_action='Correct the input or repair the trusted runtime and retry.', severity='error', artifact_path=None, pointer='/', related_ids=(), related_paths=()),)
E   assert (False)
E    +  where False = DiscoveryResult(operation='migrate', mode='structural', ok=False, exit_code=2, findings=(Finding(code='MIGRATION_REQUIRED_CONTEXT', message='The discovery operation could not satisfy its contract.', next_action='Correct the input or repair the trusted runtime and retry.', severity='error', artifact_path=None, pointer='/', related_ids=(), related_paths=()),), artifacts=(), summary=JsonObject(members=(('counts', ()), ('invocation_ref', None), ('message', 'Operation did not pass.'), ('receipt_ref', None), ('validation_result', None))), input_manifest=InputManifest(files=(SnapshotFile(path='legacy/coverage-ledger.json', content=b'{"$schema": "../../../schemas/discovery/v1/coverage-ledger.schema.json", "entries": [{"evidence_refs": ["evidence-alpha-001"], "feature_ids": ["feature-alpha"], "notes": "Behavior characterized against the captured runtime log.", "status": "characterized", "unit_id": "unit-alpha", "unit_kind": "module"}, {"notes": "Unit deferred pending further discovery.", "status": "in_discovery", "unit_id": "unit-beta", "unit_kind": "component"}], "generated_at": "2026-07-18T10:12:00Z", "id": "coverage-ledger-alpha", "schema_version": "1.0.0", "subject": "legacy core corpus", "summary": {"covered_units": 1, "total_units": 2}}', category='documentation'),), missing_paths=(), source_repositories=(), target_repositories=()), runtime=RuntimeIdentity(package_version='2.0.0', schema_version='2.0.0', build_sha256='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', policy_version=1, policy_sha256='bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb')).ok
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                        Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\migration_capture.py     120     22     44     11    75%   34, 39, 45, 76, 83, 119, 141-145, 160, 164-165, 235, 260-269, 285
packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py         214     50     96     26    68%   75, 80, 107, 112, 118, 129, 132, 134, 146-158, 205-210, 266, 304, 330, 333->322, 337, 362, 365-384, 410, 420, 423-425, 429, 440, 444, 469, 471, 478, 487
packages\discovery-runtime\src\drm_copilot_discovery\service_bootstrap.py     111     71     28      5    34%   34, 83-98, 112-160, 177-232, 265, 273, 289-327, 349, 351, 354
-----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                         445    143    168     42    62%
Coverage JSON written to file SCRATCH\p6t1-capture-repair-085148-migration-diagnosis-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[True]
FAILED tests/discovery_runtime/test_service_publication.py::test_migration_uses_explicit_v1_bytes_and_reports_real_effects[False]
============================= 2 failed in 37.23s ==============================

```
