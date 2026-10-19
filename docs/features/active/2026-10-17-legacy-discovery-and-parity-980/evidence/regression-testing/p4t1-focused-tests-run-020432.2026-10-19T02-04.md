Timestamp: 2026-10-19T02:04:32.242639+00:00
Command: poetry run python -m pytest tests/discovery_runtime/analyzer tests/scripts/dev_tools/discovery/analyzer -q -o addopts= --cov=drm_copilot_discovery.analyzer --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p4t1-focused-coverage.2026-10-19T02-02-20.json
EXIT_CODE: 1
Output Summary:

```text
............F........................................................... [ 30%]
........................................................................ [ 60%]
........................................................................ [ 91%]
.....................                                                    [100%]
================================== FAILURES ===================================
__________ test_publication_rejects_wrong_grants_and_changed_inputs ___________

analyzer_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_publication_rejects_wrong_grants_and_changed_inputs(
        analyzer_catalog: SchemaCatalog,
    ) -> None:
        """Valid result bytes alone cannot grant write authority or override freshness."""
        writer, baseline, result, grant = publication_case(analyzer_catalog)
        with pytest.raises((ValueError, MutationError)):
            plan_inventory(baseline, result, grants=())
        forged = replace(result, semantic_sha256="0" * 64)
        with pytest.raises(MutationError, match="INVENTORY_INPUTS"):
            plan_inventory(baseline, forged, grants=(grant,))
        plan = plan_inventory(baseline, result, grants=(grant,))
        writer.store.files["docs/guide.md"] = b"changed after planning"
        stale = commit_mutation(plan, writer=writer)
>       assert not stale.ok and stale.findings[0].code == "MUTATION_STALE"
E       AssertionError: assert (not False and 'MUTATION_FAILED' == 'MUTATION_STALE'
E        +  where False = MutationResult(ok=False, artifacts=(), findings=(Finding(code='MUTATION_FAILED', message='MUTATION_STALE: Complete inp...lid=None, role=None, invocation_id=None, required_outputs_sha256=None), authority_invalidated=True, uncertain_paths=()).ok
E
E         - MUTATION_STALE
E         ?          ^^
E         + MUTATION_FAILED
E         ?          ^ +  +)

tests\discovery_runtime\analyzer\test_pipeline.py:167: AssertionError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                             Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\__init__.py            0      0      0      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py            50      1     14      1    97%   99
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\findings.py           22      0      2      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\input_capture.py     101      0     38      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py          80      0     22      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\models.py            109      0     24      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py           60      0     10      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\registry.py           14      0      2      0   100%
----------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                              436      1    112      1    99%
Coverage JSON written to file docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p4t1-focused-coverage.2026-10-19T02-02-20.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/analyzer/test_pipeline.py::test_publication_rejects_wrong_grants_and_changed_inputs
1 failed, 236 passed in 130.92s (0:02:10)

```

Elapsed seconds: 131.564992
Source and test bytes unchanged: True

```json
{
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/__init__.py": "a1b8c4f0bc43990ce8e91eae6414aecf0e6fba6fa8cf03712b982d15a0dbe8d1",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/emitter.py": "c874dde0f440cd7d89a2e9970c7c58326f4870c5e4104c6e440d94e5d623e286",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/findings.py": "7edffaa36d0d3c4ca72d6e6f00e9f48e377205472d3874c8222ad00ece2de01d",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/input_capture.py": "d05e1fa8288ac01c391d1f20a5d8d5959a958f2c1f95361020ba18bc39520479",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/inventory.py": "e7b0ed0e4084c6efc6a0a3db4857dd21214331526aebe9bd817fab603bcd9386",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/models.py": "40d71361e26142f6ea2570feb2473e8c8896e0cb7d1f142cce66b422fbc8c791",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/pipeline.py": "36451dbec922c5e14e00a2ba8480e4c63e2734b2dadddc8871b656b176fdf6ad",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry.py": "5fe0b51412b45d26faf02476aae93435746efe4d996ad7ff841846d01fc54d97",
  "scripts/dev_tools/discovery/analyzer/emitter.py": "513ff724143710de873589f604c3f95c2845007e60a10eb906525318f4ca02d9",
  "scripts/dev_tools/discovery/analyzer/inventory.py": "ed56917f3bcf07ef808c1949898e3327f368b71b207cf121a98269d4245ec9a3",
  "scripts/dev_tools/discovery/analyzer/models.py": "de3c0adcf32a60dbcd89e929ee22a46c2d2b13a82f16aabb5b51646ece7eb1f9",
  "scripts/dev_tools/discovery/analyzer/pipeline.py": "9d7a756a9d1bb5b6934ffe1293298990313366ab652b846886ae100e06cdc793",
  "tests/discovery_runtime/analyzer/test_input_capture.py": "7642bd5503f2f0e373f2964e961f2096491ac4f39d21760ea88d8c1b2894c215",
  "tests/discovery_runtime/analyzer/test_pipeline.py": "c23d3fccb4f9eca10d23e2a0841613b0372cca488e574b3c80ddc67f1b32127c",
  "tests/discovery_runtime/analyzer/test_registry.py": "d59c8a8a5d4fdd4b73f56b7474f061528ea46e2e711b489ad85ce02a13f05d31",
  "tests/discovery_runtime/analyzer/test_repository.py": "a1b992274d8b685e78161a2fb9ce5780b265b5215e3841b9b2010952f5fc8610",
  "tests/scripts/dev_tools/discovery/analyzer/test_cli.py": "6f177e8070be9599de1d3f0e36899123050ca668dce71d7f328b3639dca09ad0",
  "tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py": "90c784404abf7317afce595fd61f2938bf59feb35c0b819fdb47e9ac3f164af6",
  "tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py": "48ec26e4792c43bf21fd5bfa5c0b8cfa078677923122f3e90f28b4ae03b33749",
  "tests/scripts/dev_tools/discovery/analyzer/test_emitter.py": "cbaff8ed163fdf2335c517283986cf132266dc3a04f00fd879cc4b6c586a0d81",
  "tests/scripts/dev_tools/discovery/analyzer/test_inventory.py": "77183cb5d88dd28d9a20d8512ccc4086d541dbf96bd9944aa38e754cc0c2d9fc",
  "tests/scripts/dev_tools/discovery/analyzer/test_inventory_e2e.py": "a7ce45b77913c103fd2cc9bdc8455c21735bdc434a8f8613f100c09ca596dd29",
  "tests/scripts/dev_tools/discovery/analyzer/test_models.py": "c8d3644635c914ab351f3192572b504780653876adfa7b2f02420a9d1fd52042",
  "tests/scripts/dev_tools/discovery/analyzer/test_pipeline.py": "08c2a4b1da50740c9ff018c85334d84d6f96513b17971628474d67bab6a9d7da",
  "tests/scripts/dev_tools/discovery/analyzer/test_stack_cli.py": "e3e6a7ef146ce3128f3931a8ceae181c13888b82343088866b83b97ff8acb732",
  "tests/scripts/dev_tools/discovery/analyzer/test_vsto_office.py": "d0c2016309430c5e166f6119bdf1c458c8916d715a7f711d849418daded5a732"
}
```
