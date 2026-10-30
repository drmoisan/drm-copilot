# p3t1-lint-pass8

Timestamp: 2026-10-18T11-36
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py tests/discovery_runtime/test_mutation_plan.py tests/discovery_runtime/test_mutation_commit.py tests/discovery_runtime/test_mutation_filesystem.py tests/discovery_runtime/mutation_test_support.py
EXIT_CODE: 1
Output Summary: [1m[94m432 |[0m     seen: set[str] = set();     [1m[94m|[0m; ; Found 26 errors.

Working directory: .
Started: 2026-10-18T11:36:51.313680+00:00
Duration seconds: 0.889
Phase: P3-T1 planned mutations and guarded commits; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py:141:89
    [1m[94m|[0m
[1m[94m139 |[0m     def child(self, name: str, *, create: bool) -> Generator[Directory, None, None]:
[1m[94m140 |[0m         """Keep every ancestor open and exclusively create requested missing parents."""
[1m[94m141 |[0m         # Only a previously absent parent may be created; existing parents are anchored as-is.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m142 |[0m         if create:
[1m[94m143 |[0m             os.mkdir(self._name(name), 0o700, dir_fd=self.descriptor)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py:150:89
    [1m[94m|[0m
[1m[94m148 |[0m         """Bound reads and reject file links while all parent handles remain pinned."""
[1m[94m149 |[0m         with ExitStack() as stack:
[1m[94m150 |[0m             # Windows needs a retained file handle because its open API has no dir_fd route.
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m151 |[0m             if os.name == "nt":
[1m[94m152 |[0m                 stack.enter_context(pin_windows_path(self.path / name, directory=False))
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py:203:89
    [1m[94m|[0m
[1m[94m201 |[0m         Publish within one filesystem; exclusive links never overwrite a collision.
[1m[94m202 |[0m         """
[1m[94m203 |[0m         # Replacement consumes its stage; creation uses a link that rejects a colliding leaf.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m204 |[0m         if replace:
[1m[94m205 |[0m             os.replace(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py:314:89
    [1m[94m|[0m
[1m[94m312 |[0m         except FileNotFoundError:
[1m[94m313 |[0m             return PathMetadata(kind="missing")
[1m[94m314 |[0m         # Classify links/reparse entries before ordinary types so policy can reject them.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m315 |[0m         kind = (
[1m[94m316 |[0m             "symlink"
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_filesystem.py:416:89
    [1m[94m|[0m
[1m[94m414 |[0m             published = False
[1m[94m415 |[0m             try:
[1m[94m416 |[0m                 # Creation must not read a foreign target; replacement verifies current bytes.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m417 |[0m                 if expected_sha256 is not None:
[1m[94m418 |[0m                     original = directory.read(parts[-1], limit=self.document_bytes)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_io.py:177:89
    [1m[94m|[0m
[1m[94m175 |[0m             if digest != write.change.expected_sha256:
[1m[94m176 |[0m                 raise MutationError("MUTATION_PRECONDITION", "Guarded original differs")
[1m[94m177 |[0m             # Absence permits only exclusive creation; existing bytes require replacement CAS.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m178 |[0m             if digest is None:
[1m[94m179 |[0m                 self._primitives.create_exclusive(write.target, write.change.content)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (95 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_io.py:325:89
    [1m[94m|[0m
[1m[94m323 |[0m         for write in plan.writes:
[1m[94m324 |[0m             _same_state(expected, writer.capture())
[1m[94m325 |[0m             # Same bytes require no publication but still require the complete freshness check.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^[0m
[1m[94m326 |[0m             if write.skipped:
[1m[94m327 |[0m                 outputs.append(_artifact(write, "skipped"))
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_io.py:329:89
    [1m[94m|[0m
[1m[94m327 |[0m                 outputs.append(_artifact(write, "skipped"))
[1m[94m328 |[0m                 continue
[1m[94m329 |[0m             # Revoke once before the first attempted write, including later partial failure.
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m330 |[0m             if not revoked:
[1m[94m331 |[0m                 writer.invalidate_authority()
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_io.py:385:89
    [1m[94m|[0m
[1m[94m383 |[0m         uncertain: tuple[str, ...] = ()
[1m[94m384 |[0m         if attempted is not None:
[1m[94m385 |[0m             # Report the file and every possibly created ancestor, retaining prior successes.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m386 |[0m             uncertain = tuple(
[1m[94m387 |[0m                 sorted(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py:214:89
    [1m[94m|[0m
[1m[94m212 |[0m                 )
[1m[94m213 |[0m                 prior = self.entries.get(path, PathMetadata(kind="missing"))
[1m[94m214 |[0m                 # Existing identities are retained; only projected additions are synthetic.
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m215 |[0m                 if prior.kind == "missing":
[1m[94m216 |[0m                     self.entries[path] = PathMetadata(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py:244:89
    [1m[94m|[0m
[1m[94m242 |[0m     overlay = _Overlay(baseline, changes)
[1m[94m243 |[0m     original = baseline.snapshot
[1m[94m244 |[0m     # Rebuild extension bindings through the accepted loader while replaying pinned bytes.
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m245 |[0m     return load_snapshot(
[1m[94m246 |[0m         io=SnapshotIO(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\mutation_test_support.py:97:89
   [1m[94m|[0m
[1m[94m95 |[0m     value = load_fixture(kind)
[1m[94m96 |[0m     value.update(id=identifier, records=[])
[1m[94m97 |[0m     # Updates bind the exact prior bytes, while new outputs carry an absence precondition.
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m98 |[0m     previous = next(
[1m[94m99 |[0m         (file for file in baseline.snapshot.manifest.files if file.path == path), None
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\mutation_test_support.py:213:89
    [1m[94m|[0m
[1m[94m211 |[0m         """Create exact path observations over the current memory namespace."""
[1m[94m212 |[0m         parts = path.split("/")
[1m[94m213 |[0m         # Include the root and every parent so handle-substitution probes retain full context.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m214 |[0m         names = [".", *("/".join(parts[:index]) for index in range(1, len(parts) + 1))]
[1m[94m215 |[0m         # Detach the original observations before any injected metadata-to-open race.
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_commit.py:126:89
    [1m[94m|[0m
[1m[94m124 |[0m     # Both exact outputs must be reported, with every unrelated captured byte preserved.
[1m[94m125 |[0m     assert all(item.status == "created" for item in result.artifacts)
[1m[94m126 |[0m     # Compare the whole original byte set rather than checking a selected sentinel alone.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m127 |[0m     assert all(store.files[path] == content for path, content in before.items())
[1m[94m128 |[0m     assert result.validation.input_sha256 == plan.prospective.sha256
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_commit.py:188:89
    [1m[94m|[0m
[1m[94m186 |[0m     change = collection_change(baseline)
[1m[94m187 |[0m     plan = plan_mutation(baseline, (change,), grants=grants_for(change))
[1m[94m188 |[0m     # Inject one kind of input drift after planning and before the writer captures again.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m189 |[0m     if race == "bytes":
[1m[94m190 |[0m         store.files["docs/migration/notes.md"] = b"changed"
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (95 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_commit.py:246:89
    [1m[94m|[0m
[1m[94m244 |[0m     result = commit_mutation(plan, writer=writer)
[1m[94m245 |[0m     assert not result.ok and result.authority_invalidated
[1m[94m246 |[0m     # Earlier success remains visible when the next publication fails or loses acknowledgement.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^[0m
[1m[94m247 |[0m     assert [item.status for item in result.artifacts] == ["created", "conflict"]
[1m[94m248 |[0m     assert plan.writes[0].change.path in store.files
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_commit.py:267:89
    [1m[94m|[0m
[1m[94m265 |[0m     def disturb() -> None:
[1m[94m266 |[0m         """Inject one explicit nonconforming adapter side effect in memory."""
[1m[94m267 |[0m         # Byte changes and same-byte identity replacement exercise independent postconditions.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m268 |[0m         if effect == "bytes":
[1m[94m269 |[0m             store.files["docs/migration/notes.md"] = b"unexpected"
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_commit.py:317:89
    [1m[94m|[0m
[1m[94m315 |[0m     mutation_catalog: SchemaCatalog,
[1m[94m316 |[0m ) -> None:
[1m[94m317 |[0m     """The concrete writer rejects a mismatched precondition even for a current capture."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m318 |[0m     store, baseline = mutation_case(mutation_catalog)
[1m[94m319 |[0m     change = collection_change(baseline)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_mutation_filesystem.py:70:89
   [1m[94m|[0m
[1m[94m68 |[0m     disk.fail_publish = failure == "publish"
[1m[94m69 |[0m     before = dict(disk.store.files)
[1m[94m70 |[0m     # Select failures before exclusion, during publication, or at reentry without retries.
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m71 |[0m     with pytest.raises(OSError):
[1m[94m72 |[0m         if failure == "guard":
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (95 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_filesystem.py:191:89
    [1m[94m|[0m
[1m[94m189 |[0m     monkeypatch.setattr(os, "unlink", removing)
[1m[94m190 |[0m     directory = NativeDirectory(Path("anchor"), 5, "7:11")
[1m[94m191 |[0m     # Successful short writes must flush all bytes; failure cases expose their cleanup outcome.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^[0m
[1m[94m192 |[0m     if failure == "none":
[1m[94m193 |[0m         directory.stage("stage", b"abcde")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_filesystem.py:255:89
    [1m[94m|[0m
[1m[94m253 |[0m         def __call__(self, *args: object) -> int | None:
[1m[94m254 |[0m             """Return a handle/status without invoking the kernel."""
[1m[94m255 |[0m             # Track native closes separately from descriptor closes after ownership transfer.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m256 |[0m             if self.closing:
[1m[94m257 |[0m                 native_closed.append(cast("int", args[0]))
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_filesystem.py:282:89
    [1m[94m|[0m
[1m[94m280 |[0m     )
[1m[94m281 |[0m     monkeypatch.setattr(os, "close", closed.append)
[1m[94m282 |[0m     # Every unsuccessful ownership transfer/open must unwind the resource it actually owns.
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m283 |[0m     if failure == "none":
[1m[94m284 |[0m         with filesystem.pin_windows_path(Path("anchor"), directory=True) as info:
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_filesystem.py:321:89
    [1m[94m|[0m
[1m[94m319 |[0m     monkeypatch.setattr(os, "close", closed.append)
[1m[94m320 |[0m     directory = NativeDirectory(Path("anchor"), 5, "7:11")
[1m[94m321 |[0m     # Valid reads assemble short chunks; overflow and nonregular handles fail explicitly.
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m322 |[0m     if failure == "none":
[1m[94m323 |[0m         assert directory.read("input", limit=3) == b"abc"
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_filesystem.py:356:89
    [1m[94m|[0m
[1m[94m355 |[0m     monkeypatch.setattr(filesystem, "open_local_directory", opening)
[1m[94m356 |[0m     # Replace every native operation reached by this test, preserving observable call order.
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m357 |[0m     for name in ("mkdir", "link", "replace", "unlink", "close"):
[1m[94m358 |[0m         monkeypatch.setattr(os, name, record(name))
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_plan.py:219:89
    [1m[94m|[0m
[1m[94m217 |[0m     with pytest.raises(MutationError, match="MUTATION_INVALID") as raised:
[1m[94m218 |[0m         plan_mutation(baseline, (change,), grants=grants_for(change))
[1m[94m219 |[0m     # Preserve the validator's concrete errors instead of replacing them with a generic code.
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m220 |[0m     assert raised.value.findings and any(
[1m[94m221 |[0m         item.severity == "error" for item in raised.value.findings
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_mutation_plan.py:430:89
    [1m[94m|[0m
[1m[94m428 |[0m     mutation_catalog: SchemaCatalog,
[1m[94m429 |[0m ) -> None:
[1m[94m430 |[0m     """A namespace identity change during one capture cannot yield an immutable input."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m431 |[0m     store, baseline = mutation_case(mutation_catalog)
[1m[94m432 |[0m     seen: set[str] = set()
    [1m[94m|[0m

Found 26 errors.
```
