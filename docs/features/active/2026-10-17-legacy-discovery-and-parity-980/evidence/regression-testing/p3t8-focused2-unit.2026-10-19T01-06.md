# p3t8-focused2-unit

Timestamp: 2026-10-19T01-06
Command: poetry run pytest tests/discovery_runtime/test_source_reads.py tests/discovery_runtime/test_source_read_limits.py -o addopts=-ra --cov=drm_copilot_discovery.source_reads --cov=drm_copilot_discovery.source_read_models --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t8-focused-coverage.json
EXIT_CODE: 1
Output Summary: FAIL scoped P3-T8 stage 5; duration 33.512 seconds. Exact source hashes are in the paired JSON receipt.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 122 items

tests\discovery_runtime\test_source_reads.py ...............F........... [ 22%]
F                                                                        [ 22%]
tests\discovery_runtime\test_source_read_limits.py ..................... [ 40%]
...................................................F.F.................F [ 99%]
.                                                                        [100%]

================================== FAILURES ===================================
_ test_read_adapter_failure_or_changed_input_returns_no_partial_result[changed-metadata] _

self = <drm_copilot_discovery.path_policy.PathPolicy object at 0x000002885273FAD0>
path = 'src/a'

    def _inspect(self, path: str) -> PathMetadata:
        """Read one non-following entry, rejecting ambiguity, links and escapes."""
        try:
>           entry = self._metadata(path)
                    ^^^^^^^^^^^^^^^^^^^^

packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:242:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.source_reads._Inspection object at 0x0000028852736BA0>
path = 'src/a'

    def _metadata(self, path: str) -> PathMetadata:
        """Read bounded stable metadata for path, or raise OSError; no byte reads."""
        if path != "." and len(path.split("/")) > self.limits.depth:
            raise OSError("Source inspection depth limit exceeded")
        if path not in self.observed and len(self.observed) >= min(
            self.limits.entries, self.profile.limits.source_files
        ):
            raise OSError("Source inspection enumeration limit exceeded")
        entry = self.reader.metadata(path)
        if len(entry.children) > self.limits.entries:
            raise OSError("Source directory child enumeration limit exceeded")
        entry = replace(entry, children=check_path_collisions(entry.children))
        prior = self.observed.setdefault(path, entry)
        if prior != entry:
>           raise OSError(f"Source metadata changed at {path!r}; repeat inspection")
E           OSError: Source metadata changed at 'src/a'; repeat inspection

packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:136: OSError

The above exception was the direct cause of the following exception:

read_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...', 'processing-example'), ('name', 'Example processing system'), ('role', 'combined')))), ('test_roots', ('tests',)))))
read_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
fault = 'changed-metadata'

    @pytest.mark.parametrize(
        "fault", ("changed-bytes", "changed-metadata", "read-error", "mutable-bytes")
    )
    def test_read_adapter_failure_or_changed_input_returns_no_partial_result(
        read_profile: ProfileV2,
        read_catalog: SchemaCatalog,
        fault: str,
    ) -> None:
        """Inject one isolated adapter fault; return None after fail-closed assertions."""
        store = MemoryStore()
        store.put("src/a", b"original")
        calls = 0

        def unstable(path: str, *, limit: int) -> bytes:
            """Return isolated fake bytes or the requested fault; never touch real files."""
            nonlocal calls
            calls += 1
            # Each branch models a different trusted-adapter contract violation.
            if fault == "read-error":
                raise PermissionError("blocked")
            if fault == "mutable-bytes":
                return cast("bytes", bytearray(b"original"))
            if fault == "changed-metadata":
                store.metadata.add(path, identity="replacement")
            return (
                b"changed"
                if fault == "changed-bytes" and calls > 1
                else store.read(path, limit=limit)
            )

        with pytest.raises(OSError):
>           make_reader(store, read_profile, read_catalog, read_bytes=unstable).inspect(
                SourceReadRequest(operation="read", paths=("src/a",))
            )

tests\discovery_runtime\test_source_reads.py:307:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:87: in inspect
    return _Inspection(self, request).run()
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:454: in run
    items.extend(self._items(path))
                 ^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:330: in _items
    evidence = self._evidence(path)
               ^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:267: in _evidence
    captured = self._capture(path)
               ^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:193: in _capture
    path=path, content=self._read(path), category="source"
                       ^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:186: in _read
    self.policy.resolve_read(path)
packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:421: in resolve_read
    return self._walk(path, allow_missing=allow_missing)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:327: in _walk
    entry = self._inspect(current)
            ^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.path_policy.PathPolicy object at 0x000002885273FAD0>
path = 'src/a'

    def _inspect(self, path: str) -> PathMetadata:
        """Read one non-following entry, rejecting ambiguity, links and escapes."""
        try:
            entry = self._metadata(path)
        except OSError as error:
>           raise PathPolicyError(
                "PATH_METADATA",
                path,
                "Restore readable path metadata before continuing.",
            ) from error
E           drm_copilot_discovery.path_models.PathPolicyError: PATH_METADATA: 'src/a': Restore readable path metadata before continuing.

packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:244: PathPolicyError
________ test_unconfigured_profile_fails_before_read_authority_is_used ________

read_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_unconfigured_profile_fails_before_read_authority_is_used(
        read_catalog: SchemaCatalog,
    ) -> None:
        """Reject structurally valid draft configuration without accessing source bytes."""
        document = profile_document()
        document["profile_state"] = "draft"
        profile = parse_profile_v2(json.dumps(document), catalog=read_catalog)
        store = MemoryStore()
        with pytest.raises(ValueError, match="configured"):
>           make_reader(store, profile, read_catalog)

tests\discovery_runtime\test_source_reads.py:443:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\test_source_reads.py:56: in make_reader
    return SourceReader(
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:65: in __init__
    profile.require_configured()
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...', 'processing-example'), ('name', 'Example processing system'), ('role', 'combined')))), ('test_roots', ('tests',)))))

    def require_configured(self) -> None:
        """Block callers that require configured input when only a draft exists."""
        if self.profile_state != "configured":
>           raise ProfileError(
                (
                    Finding(
                        code="PROFILE_DRAFT",
                        pointer="/profile_state",
                        message="Draft configuration cannot satisfy completion "
                        "or planning prerequisites.",
                        next_action="Supply roots, repository pins and clients, "
                        "then configure the profile.",
                    ),
                )
            )
E           drm_copilot_discovery.profile_v2.ProfileError: /profile_state: Draft configuration cannot satisfy completion or planning prerequisites.

packages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py:204: ProfileError

During handling of the above exception, another exception occurred:

read_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_unconfigured_profile_fails_before_read_authority_is_used(
        read_catalog: SchemaCatalog,
    ) -> None:
        """Reject structurally valid draft configuration without accessing source bytes."""
        document = profile_document()
        document["profile_state"] = "draft"
        profile = parse_profile_v2(json.dumps(document), catalog=read_catalog)
        store = MemoryStore()
>       with pytest.raises(ValueError, match="configured"):
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
E       AssertionError: Regex pattern did not match.
E         Expected regex: 'configured'
E         Actual message: '/profile_state: Draft configuration cannot satisfy completion or planning prerequisites.'

tests\discovery_runtime\test_source_reads.py:442: AssertionError
________ test_enumeration_is_bounded_before_any_bytes_are_read[depth] _________

self = <drm_copilot_discovery.path_policy.PathPolicy object at 0x000002885291D2E0>
path = 'src/a/one'

    def _inspect(self, path: str) -> PathMetadata:
        """Read one non-following entry, rejecting ambiguity, links and escapes."""
        try:
>           entry = self._metadata(path)
                    ^^^^^^^^^^^^^^^^^^^^

packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:242:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.source_reads._Inspection object at 0x0000028852917EE0>
path = 'src/a/one'

    def _metadata(self, path: str) -> PathMetadata:
        """Read bounded stable metadata for path, or raise OSError; no byte reads."""
        if path != "." and len(path.split("/")) > self.limits.depth:
>           raise OSError("Source inspection depth limit exceeded")
E           OSError: Source inspection depth limit exceeded

packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:125: OSError

The above exception was the direct cause of the following exception:

read_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...', 'processing-example'), ('name', 'Example processing system'), ('role', 'combined')))), ('test_roots', ('tests',)))))
read_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
fault = 'depth'

    @pytest.mark.parametrize(
        "fault", ("depth", "metadata-count", "child-count", "queued-count", "profile-count")
    )
    def test_enumeration_is_bounded_before_any_bytes_are_read(
        read_profile: ProfileV2,
        read_catalog: SchemaCatalog,
        fault: str,
    ) -> None:
        """Bound path depth, queued entries and metadata through fresh memory stores."""
        store = MemoryStore()
        store.put("src/a/one", b"1")
        store.put("src/b/two", b"2")
        limits, profile = SourceReadLimits(), read_profile
        # Select the smallest bound that exercises the named independent path axis.
        if fault == "depth":
            limits = replace(limits, depth=2)
        elif fault in {"metadata-count", "queued-count"}:
            limits = replace(limits, entries=2 if fault == "metadata-count" else 3)
        elif fault == "child-count":
            store.put("src/c", b"3")
            limits = replace(limits, entries=2)
        else:
            document = profile_document()
            document["limits"] = {"source_files": 2}
            profile = parse_profile_v2(json.dumps(document), catalog=read_catalog)
        with pytest.raises(OSError, match="limit"):
>           make_reader(store, profile, read_catalog, limits=limits).inspect(
                SourceReadRequest(operation="list", paths=("src",))
            )

tests\discovery_runtime\test_source_read_limits.py:283:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:87: in inspect
    return _Inspection(self, request).run()
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:450: in run
    paths = self._paths()
            ^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:297: in _paths
    resolved = self.policy.resolve_read(path)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:421: in resolve_read
    return self._walk(path, allow_missing=allow_missing)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:327: in _walk
    entry = self._inspect(current)
            ^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.path_policy.PathPolicy object at 0x000002885291D2E0>
path = 'src/a/one'

    def _inspect(self, path: str) -> PathMetadata:
        """Read one non-following entry, rejecting ambiguity, links and escapes."""
        try:
            entry = self._metadata(path)
        except OSError as error:
>           raise PathPolicyError(
                "PATH_METADATA",
                path,
                "Restore readable path metadata before continuing.",
            ) from error
E           drm_copilot_discovery.path_models.PathPolicyError: PATH_METADATA: 'src/a/one': Restore readable path metadata before continuing.

packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:244: PathPolicyError
_____ test_enumeration_is_bounded_before_any_bytes_are_read[child-count] ______

self = <drm_copilot_discovery.path_policy.PathPolicy object at 0x000002885291CEF0>
path = 'src'

    def _inspect(self, path: str) -> PathMetadata:
        """Read one non-following entry, rejecting ambiguity, links and escapes."""
        try:
>           entry = self._metadata(path)
                    ^^^^^^^^^^^^^^^^^^^^

packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:242:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.source_reads._Inspection object at 0x0000028852917540>
path = 'src'

    def _metadata(self, path: str) -> PathMetadata:
        """Read bounded stable metadata for path, or raise OSError; no byte reads."""
        if path != "." and len(path.split("/")) > self.limits.depth:
            raise OSError("Source inspection depth limit exceeded")
        if path not in self.observed and len(self.observed) >= min(
            self.limits.entries, self.profile.limits.source_files
        ):
            raise OSError("Source inspection enumeration limit exceeded")
        entry = self.reader.metadata(path)
        if len(entry.children) > self.limits.entries:
>           raise OSError("Source directory child enumeration limit exceeded")
E           OSError: Source directory child enumeration limit exceeded

packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:132: OSError

The above exception was the direct cause of the following exception:

read_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...', 'processing-example'), ('name', 'Example processing system'), ('role', 'combined')))), ('test_roots', ('tests',)))))
read_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
fault = 'child-count'

    @pytest.mark.parametrize(
        "fault", ("depth", "metadata-count", "child-count", "queued-count", "profile-count")
    )
    def test_enumeration_is_bounded_before_any_bytes_are_read(
        read_profile: ProfileV2,
        read_catalog: SchemaCatalog,
        fault: str,
    ) -> None:
        """Bound path depth, queued entries and metadata through fresh memory stores."""
        store = MemoryStore()
        store.put("src/a/one", b"1")
        store.put("src/b/two", b"2")
        limits, profile = SourceReadLimits(), read_profile
        # Select the smallest bound that exercises the named independent path axis.
        if fault == "depth":
            limits = replace(limits, depth=2)
        elif fault in {"metadata-count", "queued-count"}:
            limits = replace(limits, entries=2 if fault == "metadata-count" else 3)
        elif fault == "child-count":
            store.put("src/c", b"3")
            limits = replace(limits, entries=2)
        else:
            document = profile_document()
            document["limits"] = {"source_files": 2}
            profile = parse_profile_v2(json.dumps(document), catalog=read_catalog)
        with pytest.raises(OSError, match="limit"):
>           make_reader(store, profile, read_catalog, limits=limits).inspect(
                SourceReadRequest(operation="list", paths=("src",))
            )

tests\discovery_runtime\test_source_read_limits.py:283:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:87: in inspect
    return _Inspection(self, request).run()
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:450: in run
    paths = self._paths()
            ^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:297: in _paths
    resolved = self.policy.resolve_read(path)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:421: in resolve_read
    return self._walk(path, allow_missing=allow_missing)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:327: in _walk
    entry = self._inspect(current)
            ^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.path_policy.PathPolicy object at 0x000002885291CEF0>
path = 'src'

    def _inspect(self, path: str) -> PathMetadata:
        """Read one non-following entry, rejecting ambiguity, links and escapes."""
        try:
            entry = self._metadata(path)
        except OSError as error:
>           raise PathPolicyError(
                "PATH_METADATA",
                path,
                "Restore readable path metadata before continuing.",
            ) from error
E           drm_copilot_discovery.path_models.PathPolicyError: PATH_METADATA: 'src': Restore readable path metadata before continuing.

packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:244: PathPolicyError
____ test_entry_addition_during_read_fails_freshness_without_partial_page _____

self = <drm_copilot_discovery.path_policy.PathPolicy object at 0x000002885291CCB0>
path = 'src'

    def _inspect(self, path: str) -> PathMetadata:
        """Read one non-following entry, rejecting ambiguity, links and escapes."""
        try:
>           entry = self._metadata(path)
                    ^^^^^^^^^^^^^^^^^^^^

packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:242:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.source_reads._Inspection object at 0x0000028852A08EC0>
path = 'src'

    def _metadata(self, path: str) -> PathMetadata:
        """Read bounded stable metadata for path, or raise OSError; no byte reads."""
        if path != "." and len(path.split("/")) > self.limits.depth:
            raise OSError("Source inspection depth limit exceeded")
        if path not in self.observed and len(self.observed) >= min(
            self.limits.entries, self.profile.limits.source_files
        ):
            raise OSError("Source inspection enumeration limit exceeded")
        entry = self.reader.metadata(path)
        if len(entry.children) > self.limits.entries:
            raise OSError("Source directory child enumeration limit exceeded")
        entry = replace(entry, children=check_path_collisions(entry.children))
        prior = self.observed.setdefault(path, entry)
        if prior != entry:
>           raise OSError(f"Source metadata changed at {path!r}; repeat inspection")
E           OSError: Source metadata changed at 'src'; repeat inspection

packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:136: OSError

The above exception was the direct cause of the following exception:

read_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...', 'processing-example'), ('name', 'Example processing system'), ('role', 'combined')))), ('test_roots', ('tests',)))))
read_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_entry_addition_during_read_fails_freshness_without_partial_page(
        read_profile: ProfileV2,
        read_catalog: SchemaCatalog,
    ) -> None:
        """Detect changed parent enumeration using only an injected in-memory read."""
        store = MemoryStore()
        store.put("src/a", b"one")

        def adding(path: str, *, limit: int) -> bytes:
            """Add a sibling to the isolated store and return original requested bytes."""
            store.put("src/new", b"new")
            return store.read(path, limit=limit)

        with pytest.raises(OSError, match="metadata changed"):
>           make_reader(store, read_profile, read_catalog, read_bytes=adding).inspect(
                SourceReadRequest(operation="read", paths=("src/a",))
            )

tests\discovery_runtime\test_source_read_limits.py:429:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:87: in inspect
    return _Inspection(self, request).run()
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:454: in run
    items.extend(self._items(path))
                 ^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:330: in _items
    evidence = self._evidence(path)
               ^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:267: in _evidence
    captured = self._capture(path)
               ^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:193: in _capture
    path=path, content=self._read(path), category="source"
                       ^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py:186: in _read
    self.policy.resolve_read(path)
packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:421: in resolve_read
    return self._walk(path, allow_missing=allow_missing)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:327: in _walk
    entry = self._inspect(current)
            ^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.path_policy.PathPolicy object at 0x000002885291CCB0>
path = 'src'

    def _inspect(self, path: str) -> PathMetadata:
        """Read one non-following entry, rejecting ambiguity, links and escapes."""
        try:
            entry = self._metadata(path)
        except OSError as error:
>           raise PathPolicyError(
                "PATH_METADATA",
                path,
                "Restore readable path metadata before continuing.",
            ) from error
E           drm_copilot_discovery.path_models.PathPolicyError: PATH_METADATA: 'src': Restore readable path metadata before continuing.

packages\discovery-runtime\src\drm_copilot_discovery\path_policy.py:244: PathPolicyError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                         Stmts   Miss Branch BrPart  Cover   Missing
------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\source_read_models.py     182      0     60      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\source_reads.py           227      5    118      6    97%   206, 220, 224, 246, 295, 324->292
------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                          409      5    178      6    98%
Coverage JSON written to file SCRATCH/issue-980-p3t8-focused-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_source_reads.py::test_read_adapter_failure_or_changed_input_returns_no_partial_result[changed-metadata]
FAILED tests/discovery_runtime/test_source_reads.py::test_unconfigured_profile_fails_before_read_authority_is_used
FAILED tests/discovery_runtime/test_source_read_limits.py::test_enumeration_is_bounded_before_any_bytes_are_read[depth]
FAILED tests/discovery_runtime/test_source_read_limits.py::test_enumeration_is_bounded_before_any_bytes_are_read[child-count]
FAILED tests/discovery_runtime/test_source_read_limits.py::test_entry_addition_during_read_fails_freshness_without_partial_page
======================= 5 failed, 117 passed in 31.76s ========================
```
