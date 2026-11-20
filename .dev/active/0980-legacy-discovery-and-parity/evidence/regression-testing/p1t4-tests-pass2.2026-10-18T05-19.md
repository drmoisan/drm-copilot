# p1t4-tests-pass2

Timestamp: 2026-10-18T05-19
Command: poetry run pytest tests/schemas/discovery tests/discovery_runtime/test_resources.py tests/scripts/dev_tools/test_build_discovery_runtime.py tests/scripts/dev_tools/test_build_discovery_runtime_io.py -q -o addopts= --cov=drm_copilot_discovery.resources --cov=scripts.dev_tools.build_discovery_runtime --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p1t4-coverage.json
EXIT_CODE: 1
Output Summary: Coverage JSON written to file SCRATCH/issue-980-p1t4-coverage.json; =========================== short test summary info ===========================; FAILED tests/schemas/discovery/test_v2_observation_schemas.py::test_local_evidence_integrity_metadata_is_strict[timestamp-2026-02-30T00:00:00Z]; 1 failed, 524 passed in 8.70s

Working directory: .
Started: 2026-10-18T05:19:00.946052+00:00
Duration seconds: 9.978
Phase: P1-T4 observation/evidence schemas; focused task verification.

## Captured output

```text
........................................................................ [ 13%]
........................................................................ [ 27%]
........................................................................ [ 41%]
....................................F................................... [ 54%]
........................................................................ [ 68%]
........................................................................ [ 82%]
........................................................................ [ 96%]
.....................                                                    [100%]
================================== FAILURES ===================================
_ test_local_evidence_integrity_metadata_is_strict[timestamp-2026-02-30T00:00:00Z] _

field = 'timestamp', value = '2026-02-30T00:00:00Z'

    @pytest.mark.parametrize(
        "field,value",
        [
            ("checksum", None),
            ("checksum", {"algorithm": "md5", "value": "c" * 64}),
            ("timestamp", "2026-02-30T00:00:00Z"),
            ("runtime_artifact", None),
            ("line_range", {"start": 0, "end": 3}),
            ("line_range", {"start": True, "end": 3}),
            ("author_or_agent", {"kind": "owner", "id": "analyst"}),
        ],
    )
    def test_local_evidence_integrity_metadata_is_strict(field: str, value: object) -> None:
        """Invalid hashes, timestamps, spans, actors and missing captures fail closed."""
        evidence = load_fixture("evidence-reference")
        evidence[field] = value

>       assert schema_errors("evidence-reference", evidence)
E       AssertionError: assert []
E        +  where [] = schema_errors('evidence-reference', {'$schema': 'urn:drm-copilot:discovery:2.0.0:evidence-reference', 'artifact_kind': 'evidence-reference', 'author_or_ag... 'checksum': {'algorithm': 'sha256', 'value': 'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc'}, ...})

tests\schemas\discovery\test_v2_observation_schemas.py:320: AssertionError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\resources.py     103      0     34      0   100%
scripts\dev_tools\build_discovery_runtime.py                          209      0     98      0   100%
---------------------------------------------------------------------------------------------------------------
TOTAL                                                                 312      0    132      0   100%
Coverage JSON written to file SCRATCH/issue-980-p1t4-coverage.json
=========================== short test summary info ===========================
FAILED tests/schemas/discovery/test_v2_observation_schemas.py::test_local_evidence_integrity_metadata_is_strict[timestamp-2026-02-30T00:00:00Z]
1 failed, 524 passed in 8.70s
```
