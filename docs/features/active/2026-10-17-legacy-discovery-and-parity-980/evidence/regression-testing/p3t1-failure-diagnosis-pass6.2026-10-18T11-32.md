# p3t1-failure-diagnosis-pass6

Timestamp: 2026-10-18T11-32
Command: poetry run pytest -o addopts= tests/discovery_runtime/test_mutation_plan.py -k opaque --no-cov -x -q
EXIT_CODE: 1
Output Summary: =========================== short test summary info ===========================; FAILED tests/discovery_runtime/test_mutation_plan.py::test_opaque_grants_cannot_create_structured_records[evidence-payload]; !!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!; 1 failed, 33 deselected in 1.98s

Working directory: .
Started: 2026-10-18T11:32:09.149164+00:00
Duration seconds: 3.168
Phase: P3-T1 planned mutations and guarded commits; focused task verification.

## Captured output

```text
F
================================== FAILURES ===================================
____ test_opaque_grants_cannot_create_structured_records[evidence-payload] ____

kind = 'evidence-payload'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize("kind", ["evidence-payload", "acceptance-view"])
    def test_opaque_grants_cannot_create_structured_records(
        kind: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """Opaque kinds cannot suppress authoritative parsed kind/ID comparisons."""
        _, baseline = mutation_case(mutation_catalog)
        key, structured = (
            ("evidence", "evidence-reference")
            if kind == "evidence-payload"
            else ("acceptance", "acceptance-specification")
        )
        change = MutationChange(
            artifact_kind=kind,
            artifact_id="granted",
            path=baseline.snapshot.profile.artifacts[key] + "/record.yaml",
            content=json.dumps(load_fixture(structured)).encode(),
            expected_sha256=None,
        )
        with pytest.raises(MutationError, match="MUTATION_IDENTITY"):
>           plan_mutation(baseline, (change,), grants=grants_for(change))

tests\discovery_runtime\test_mutation_plan.py:326:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py:329: in plan_mutation
    prospective = project_snapshot(baseline, changes)
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py:239: in project_snapshot
    return load_snapshot(
packages\discovery-runtime\src\drm_copilot_discovery\snapshot_loading.py:486: in load_snapshot
    return _Loader(io, profile, pinned, categories, repository).load()
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\snapshot_loading.py:396: in load
    self._read(path, "evidence")
packages\discovery-runtime\src\drm_copilot_discovery\snapshot_loading.py:120: in _read
    raw = self.io.read(path, limit=limit, required=required)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.snapshot_io.SnapshotIO object at 0x00000192CF160910>
path = 'docs/migration/discovery/evidence/capture-alpha.json'

    def read(self, path: str, *, limit: int, required: bool = True) -> bytes | None:
        """Capture exact bytes once, retaining the strictest requested byte limit."""
        if type(limit) is not int or not 1 <= limit <= 67108864:
            raise ValueError("Snapshot byte limits must be between 1 and 67108864")
        entry = self.inspect(path)
        if entry.kind == "missing":
            if required:
>               raise FileNotFoundError(f"Required snapshot input is missing: {path}")
E               FileNotFoundError: Required snapshot input is missing: docs/migration/discovery/evidence/capture-alpha.json

packages\discovery-runtime\src\drm_copilot_discovery\snapshot_io.py:192: FileNotFoundError
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_mutation_plan.py::test_opaque_grants_cannot_create_structured_records[evidence-payload]
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
1 failed, 33 deselected in 1.98s
```
