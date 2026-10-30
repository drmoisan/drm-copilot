# p3t1-lint-corrections2

Timestamp: 2026-10-18T11-23
Command: poetry run ruff check --fix packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py tests/discovery_runtime/test_mutation_plan.py tests/discovery_runtime/test_mutation_commit.py tests/discovery_runtime/test_mutation_filesystem.py tests/discovery_runtime/mutation_test_support.py
EXIT_CODE: 1
Output Summary: [36m-[0m [1mtests\discovery_runtime\test_mutation_plan.py[0m[36m:[0m;     7 × [1;31mF401[0m (unused-import); ; Found 28 errors (16 fixed, 12 remaining).

Working directory: .
Started: 2026-10-18T11:23:18.824414+00:00
Duration seconds: 0.815
Phase: P3-T1 planned mutations and guarded commits; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py:128:89
    [1m[94m|[0m
[1m[94m127 |[0m     def _name(self, name: str) -> str:
[1m[94m128 |[0m         """Reject multicomponent names before selecting relative or pinned absolute I/O."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m129 |[0m         if "/" in relative_path(name):
[1m[94m130 |[0m             raise ValueError("Anchored operation requires an immediate child name")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py:193:89
    [1m[94m|[0m
[1m[94m192 |[0m     def publish(self, staged: str, name: str, *, replace: bool) -> None:
[1m[94m193 |[0m         """Publish within one filesystem; exclusive links never overwrite a collision."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m194 |[0m         if replace:
[1m[94m195 |[0m             os.replace(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py:271:89
    [1m[94m|[0m
[1m[94m269 |[0m         document_bytes: int = 16777216,
[1m[94m270 |[0m     ) -> None:
[1m[94m271 |[0m         """Bind canonical trusted paths and injectable capabilities without touching disk."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m272 |[0m         self.root, self.lock_path = Path(workspace_root), Path(lock_path)
[1m[94m273 |[0m         if not self.root.is_absolute() or not self.lock_path.is_absolute():
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py:318:89
    [1m[94m|[0m
[1m[94m317 |[0m     def read_bytes(self, path: str, *, limit: int) -> bytes:
[1m[94m318 |[0m         """Read bounded snapshot inputs through non-following pinned directory chains."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m319 |[0m         parts = relative_path(path).split("/")
[1m[94m320 |[0m         with ExitStack() as stack:
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py:329:89
    [1m[94m|[0m
[1m[94m327 |[0m     @contextmanager
[1m[94m328 |[0m     def guard(self) -> Iterator[None]:
[1m[94m329 |[0m         """Serialize authorized writes and reject reentry instead of bypassing exclusion."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m330 |[0m         if self._guarded:
[1m[94m331 |[0m             raise OSError("Mutation workspace guard is already held")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py:348:89
    [1m[94m|[0m
[1m[94m346 |[0m         self, target: ResolvedPath, content: bytes, *, expected_sha256: str
[1m[94m347 |[0m     ) -> None:
[1m[94m348 |[0m         """Recheck original bytes under exclusion before atomically replacing the file."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m349 |[0m         self._publish(target, content, expected_sha256=expected_sha256)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py:354:89
    [1m[94m|[0m
[1m[94m352 |[0m         self, target: ResolvedPath, content: bytes, *, expected_sha256: str | None
[1m[94m353 |[0m     ) -> None:
[1m[94m354 |[0m         """Stage, validate parents/digest, publish once and clean only the owned stage."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m355 |[0m         if not self._guarded or self._anchors is None or target.grant is None:
[1m[94m356 |[0m             raise OSError("An active workspace guard and exact grant are required")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py:381:89
    [1m[94m|[0m
[1m[94m379 |[0m                 if old.kind != "missing" and directory.identity() != old.identity:
[1m[94m380 |[0m                     raise OSError("Opened mutation parent identity changed")
[1m[94m381 |[0m             # Stage ownership is established by exclusive creation; collisions propagate.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m382 |[0m             directory.stage(staged, content)
[1m[94m383 |[0m             cleanup.callback(directory.remove, staged)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_filesystem.py:159:89
    [1m[94m|[0m
[1m[94m158 |[0m def test_local_create_replace_and_parent_handles_remain_until_guard_exit() -> None:
[1m[94m159 |[0m     """Concrete publication pins parents through checks and preserves unrelated bytes."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m160 |[0m     disk = MemoryDisk()
[1m[94m161 |[0m     disk.store.put("docs/unrelated", b"preserve")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_filesystem.py:265:89
    [1m[94m|[0m
[1m[94m264 |[0m def stat_value(*, directory: bool = False) -> os.stat_result:
[1m[94m265 |[0m     """Return deterministic inode/device data without consulting the operating system."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m266 |[0m     return os.stat_result(
[1m[94m267 |[0m         (stat.S_IFDIR if directory else stat.S_IFREG, 11, 7, 1, 0, 0, 0, 0, 0, 0)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_filesystem.py:275:89
    [1m[94m|[0m
[1m[94m273 |[0m     failure: str, monkeypatch: pytest.MonkeyPatch
[1m[94m274 |[0m ) -> None:
[1m[94m275 |[0m     """Real native-stage control flow handles short writes, I/O failures and collisions."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m276 |[0m     removed: list[str] = []
[1m[94m277 |[0m     closed: list[int] = []
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_filesystem.py:318:89
    [1m[94m|[0m
[1m[94m316 |[0m     platform: str, monkeypatch: pytest.MonkeyPatch
[1m[94m317 |[0m ) -> None:
[1m[94m318 |[0m     """Both supported directory mechanisms bind identity; other platforms fail closed."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m319 |[0m     closed: list[int] = []
    [1m[94m|[0m


[1;32mFixed 16 errors:[0m
[36m-[0m [1mtests\discovery_runtime\mutation_test_support.py[0m[36m:[0m
    6 × [1;31mF401[0m (unused-import)
[36m-[0m [1mtests\discovery_runtime\test_mutation_filesystem.py[0m[36m:[0m
    3 × [1;31mF401[0m (unused-import)
[36m-[0m [1mtests\discovery_runtime\test_mutation_plan.py[0m[36m:[0m
    7 × [1;31mF401[0m (unused-import)

Found 28 errors (16 fixed, 12 remaining).
```
