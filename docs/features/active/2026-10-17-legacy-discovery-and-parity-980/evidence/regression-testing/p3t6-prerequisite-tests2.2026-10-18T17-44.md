# p3t6-prerequisite-tests2

Timestamp: 2026-10-18T17-44
Command: poetry run python SCRATCH/issue-980-p3t6-prerequisite-tests.py
EXIT_CODE: 1
Output Summary: =========================== short test summary info ===========================; FAILED tests/discovery_runtime/test_snapshot_export.py::test_bad_manifest_identity_version_and_digest_are_rejected[updates2-True-full immutable]; !!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!; 1 failed, 3 passed in 6.43s

Working directory: .
Started: 2026-10-18T17:44:15.661658+00:00
Duration seconds: 7.686
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
{"arguments": ["-o", "addopts=-ra", "tests/discovery_runtime/test_snapshot_export.py", "tests/discovery_runtime/test_snapshot_import.py", "-q", "-x", "--durations=5", "--cov=drm_copilot_discovery.transport_manifest", "--cov-branch", "--cov-report=term-missing", "--cov-report=json:EXTERNAL_PATH"]}
...F
================================== FAILURES ===================================
_ test_bad_manifest_identity_version_and_digest_are_rejected[updates2-True-full immutable] _

updates = {'source_repository': {'id': 'source', 'revision': None}}
digest = True, match = 'full immutable'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize(
        "updates,digest,match",
        [
            ({"schema_version": "3.0.0"}, False, "unsupported"),
            ({"manifest_sha256": "0" * 64}, False, "checksum"),
            (
                {"source_repository": {"id": "source", "revision": None}},
                True,
                "full immutable",
            ),
            (
                {"source_repository": {"id": "source", "revision": "main"}},
                True,
                "full lowercase",
            ),
        ],
    )
    def test_bad_manifest_identity_version_and_digest_are_rejected(
        updates: dict[str, object],
        digest: bool,
        match: str,
        mutation_catalog: SchemaCatalog,
    ) -> None:
        """Invalid declarations fail before becoming a route or a write plan."""
        route = unit_transport(mutation_catalog)
        with pytest.raises(ValueError, match=match):
>           bind_transport(
                route.manifest.path,
                changed_header(route, updates, digest=digest),
                catalog=mutation_catalog,
                limits=ParseLimits(),
            )

tests\discovery_runtime\test_snapshot_export.py:204:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

path = 'docs/migration/discovery/source-snapshots/export-alpha/manifest.json'
content = b'{"$schema":"urn:drm-copilot:discovery:2.0.0:source-snapshot-manifest","artifact_kind":"source-snapshot-manifest","ar...l"},"method":"local-files","payload_count":0,"verification_status":"pending","verified_at":null,"verified_by":null}}\n'

    def bind_transport(
        path: str, content: bytes, *, catalog: SchemaCatalog, limits: ParseLimits
    ) -> TransportRoute:
        """Validate one local manifest and derive its exact immutable member route.

        Raises ValueError for unsupported/malformed envelopes, mutable bytes, non-full
        pins, digest/count/identity/path conflicts, or finite-limit violations. This
        verifies declarations only; check_files and the complete loader verify bytes.
        """
        manifest = SnapshotFile(path=path, content=content, category="source-snapshot")
        if not path.endswith("/manifest.json"):
            raise ValueError("A transport requires a child manifest.json path")
        result = validate_document(
            content,
            expected_kind="source-snapshot-manifest",
            expected_version="2.0.0",
            artifact_path=path,
            catalog=catalog,
            limits=limits,
        )
        if not result.ok or result.document is None:
>           raise ValueError(
                "Transport manifest is malformed or uses an unsupported schema"
            )
E           ValueError: Transport manifest is malformed or uses an unsupported schema

packages\discovery-runtime\src\drm_copilot_discovery\transport_manifest.py:127: ValueError

During handling of the above exception, another exception occurred:

updates = {'source_repository': {'id': 'source', 'revision': None}}
digest = True, match = 'full immutable'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize(
        "updates,digest,match",
        [
            ({"schema_version": "3.0.0"}, False, "unsupported"),
            ({"manifest_sha256": "0" * 64}, False, "checksum"),
            (
                {"source_repository": {"id": "source", "revision": None}},
                True,
                "full immutable",
            ),
            (
                {"source_repository": {"id": "source", "revision": "main"}},
                True,
                "full lowercase",
            ),
        ],
    )
    def test_bad_manifest_identity_version_and_digest_are_rejected(
        updates: dict[str, object],
        digest: bool,
        match: str,
        mutation_catalog: SchemaCatalog,
    ) -> None:
        """Invalid declarations fail before becoming a route or a write plan."""
        route = unit_transport(mutation_catalog)
>       with pytest.raises(ValueError, match=match):
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
E       AssertionError: Regex pattern did not match.
E         Expected regex: 'full immutable'
E         Actual message: 'Transport manifest is malformed or uses an unsupported schema'

tests\discovery_runtime\test_snapshot_export.py:203: AssertionError
============================= slowest 5 durations =============================
1.90s call     tests/discovery_runtime/test_snapshot_export.py::test_manifest_binds_exact_bytes_and_excludes_only_importer_verification
1.46s call     tests/discovery_runtime/test_snapshot_export.py::test_bad_manifest_identity_version_and_digest_are_rejected[updates1-False-checksum]
1.35s call     tests/discovery_runtime/test_snapshot_export.py::test_bad_manifest_identity_version_and_digest_are_rejected[updates2-True-full immutable]
0.76s call     tests/discovery_runtime/test_snapshot_export.py::test_bad_manifest_identity_version_and_digest_are_rejected[updates0-False-unsupported]
0.70s setup    tests/discovery_runtime/test_snapshot_export.py::test_manifest_binds_exact_bytes_and_excludes_only_importer_verification
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_snapshot_export.py::test_bad_manifest_identity_version_and_digest_are_rejected[updates2-True-full immutable]
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
1 failed, 3 passed in 6.43s
```
