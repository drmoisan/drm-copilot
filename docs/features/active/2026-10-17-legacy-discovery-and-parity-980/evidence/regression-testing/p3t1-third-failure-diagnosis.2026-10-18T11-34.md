# p3t1-third-failure-diagnosis

Timestamp: 2026-10-18T11-34
Command: poetry run pytest -o addopts= tests/discovery_runtime/test_mutation_plan.py -k projection_replays --no-cov -x -q
EXIT_CODE: 1
Output Summary: =========================== short test summary info ===========================; FAILED tests/discovery_runtime/test_mutation_plan.py::test_projection_replays_only_captured_git_objects[True]; !!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!; 1 failed, 1 passed, 33 deselected in 3.16s

Working directory: .
Started: 2026-10-18T11:34:45.120018+00:00
Duration seconds: 4.275
Phase: P3-T1 planned mutations and guarded commits; focused task verification.

## Captured output

```text
.F
================================== FAILURES ===================================
___________ test_projection_replays_only_captured_git_objects[True] ___________

missing = True
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize("missing", [False, True])
    def test_projection_replays_only_captured_git_objects(
        missing: bool, mutation_catalog: SchemaCatalog
    ) -> None:
        """Projections reuse pinned byte values and cannot read new Git objects."""
        store, _ = memory_workspace()
        store.put("src/a.py", b"source")
        repository = MemoryRepository({("a" * 40, "src/a.py"): b"source"})
        baseline = capture_workspace(
            workspace_root="/workspace",
            profile_path=PROFILE_PATH,
            metadata=store.metadata,
            read_bytes=store.read,
            catalog=mutation_catalog,
            repository=repository,
        )
        if missing:
            baseline = replace(
                baseline, snapshot=replace(baseline.snapshot, repository_files=())
            )
        change = collection_change(baseline)
>       projected = project_snapshot(baseline, (change,))
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_plan.py:384:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py:239: in project_snapshot
    return load_snapshot(
packages\discovery-runtime\src\drm_copilot_discovery\snapshot_loading.py:486: in load_snapshot
    return _Loader(io, profile, pinned, categories, repository).load()
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\snapshot_loading.py:413: in load
    checkout, objects = self._git()
                        ^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\snapshot_loading.py:451: in _git
    item = self.repository.read_file(
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.mutation_plan._PinnedReader object at 0x000001ADEC765E50>

    def read_file(self, *, revision: str, path: str, limit: int) -> RepositoryFile:
        """Return an exactly pinned captured blob or require a new complete capture."""
        # A new reference cannot introduce an uninspected Git object during planning.
        for item in self.snapshot.repository_files:
            if item.path == path and item.repository.revision == revision:
                if len(item.content) > limit:
                    raise OSError("Captured Git object exceeds the read limit")
                return item
>       raise OSError("Pinned object was not captured; reload the requested inputs")
E       OSError: Pinned object was not captured; reload the requested inputs

packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py:174: OSError
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_mutation_plan.py::test_projection_replays_only_captured_git_objects[True]
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
1 failed, 1 passed, 33 deselected in 3.16s
```
