# P5-T1 report-boundary3-tests

Timestamp: 2026-10-20T04-51

Command: poetry run pytest tests/discovery_runtime/test_coverage_report_contract.py -k "loaded_report_views or report_output_scope" -vv --cov=drm_copilot_discovery.coverage_scope_rules --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/report-boundary3-coverage.json

EXIT_CODE: 1

Output Summary: The exact completed command result is retained below; no inferred completion is claimed.

Duration seconds: 64.505

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 26 items / 17 deselected / 9 selected

tests/discovery_runtime/test_coverage_report_contract.py::test_loaded_report_views_do_not_replace_authored_documentation_accounting[reports-] FAILED [ 11%]
tests/discovery_runtime/test_coverage_report_contract.py::test_loaded_report_views_do_not_replace_authored_documentation_accounting[generated/views-nested/] FAILED [ 22%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/reports/coverage-report.md-documentation-False] PASSED [ 33%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/reports/nested/coverage-report.md-documentation-False] PASSED [ 44%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/reports-other/coverage-report.md-documentation-True] PASSED [ 55%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/Reports/coverage-report.md-documentation-True] PASSED [ 66%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/coverage-report.md-documentation-True] PASSED [ 77%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/reports/coverage-report.md-source-True] PASSED [ 88%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_output_scope_preserves_path_segments_and_input_categories[docs/migration/discovery/reports/coverage-report.md-test-True] PASSED [100%]

================================== FAILURES ===================================
_ test_loaded_report_views_do_not_replace_authored_documentation_accounting[reports-] _

snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
folder = 'reports', nested = ''

    @pytest.mark.parametrize(
        "folder,nested", [("reports", ""), ("generated/views", "nested/")]
    )
    def test_loaded_report_views_do_not_replace_authored_documentation_accounting(
        snapshot_catalog: SchemaCatalog, folder: str, nested: str
    ) -> None:
        """Configured report views are outputs; authored documents remain required."""
        profile = mode_profile(snapshot_catalog)
        roots = as_object(to_plain_value(profile.document["artifacts"]))
        roots["reports"] = ROOT + folder
        profile = profile_with(profile, snapshot_catalog, artifacts=roots)
        initial = no_scope_snapshot(snapshot_catalog, profile=profile)
        store = MemoryStore()
        # Real loader membership is derived from exact in-memory captured bytes.
        for file in initial.manifest.files:
            store.put(file.path, file.content)
        baseline = load_snapshot(
            io=store.io(),
            profile_path=profile.artifacts["profile"],
            catalog=snapshot_catalog,
        )
        assert baseline.ok
        report = build_coverage_report(baseline)
        assert report.document["discovery_result"] == "pass"
        prefix = profile.artifacts["reports"] + "/" + nested + "coverage-report"
        store.put(prefix + ".json", report.to_json().encode("utf-8"))
        store.put(prefix + ".md", report.to_markdown().encode("utf-8"))
        reloaded = load_snapshot(
            io=store.io(),
            profile_path=profile.artifacts["profile"],
            catalog=snapshot_catalog,
        )
        assert reloaded.ok
        assert reloaded.file(prefix + ".md").category == "documentation"
        assert reloaded.file(prefix + ".md").content == report.to_markdown().encode("utf-8")
        assert report_input_digest(reloaded) == report_input_digest(baseline)
        assert build_coverage_report(reloaded).document == report.document

        store.put("docs/architecture.md", b"Authored behavior description.")
        authored = load_snapshot(
            io=store.io(),
            profile_path=profile.artifacts["profile"],
            catalog=snapshot_catalog,
        )
        assert authored.ok
        assert authored.file("docs/architecture.md").category == "documentation"
>       assert "COVERAGE_INPUTS" in codes(authored)
                                    ^^^^^^^^^^^^^^^

tests\discovery_runtime\test_coverage_report_contract.py:340:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\test_coverage_rules.py:173: in codes
    for finding in validate_coverage(snapshot, complete=complete).findings
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\coverage_rules.py:314: in validate_coverage
    index = index if index is not None else index_references(snapshot)
                                            ^^^^^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

snapshot = DiscoverySnapshot(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-p...aaaaaaaaaaaaaaaaaaaaaaaaaaaa'), origin_path=None)), repository_files=(), checkout=None, excluded_paths=(), findings=())

    def index_references(snapshot: DiscoverySnapshot) -> ReferenceIndex:
        """Build a pure immutable graph with bounded diagnostics over all present input."""
        collector = FindingCollector(limit=snapshot.profile.limits.parse_limits().findings)
        # Loading failures remain blockers even when no identities can be extracted.
        for finding in snapshot.findings:
            collector.add(finding)
        # Flatten configured documents and permitted collection members exactly once.
        aliases = replica_aliases(snapshot)
        # Canonical enumeration preserves logical uniqueness without dropping raw inputs.
        records = tuple(
            record
            for artifact in snapshot.artifacts
            if artifact.path not in aliases
            for record in _records(artifact, collector)
        )
        # Retain each proven physical replica for path-keyed outgoing-link checks.
        replicas = tuple(
            (aliases[artifact.path], record)
            for artifact in snapshot.artifacts
            if artifact.path in aliases
            for record in _records(artifact, collector)
        )
        index = ReferenceIndex(records=records, replicas=replicas)
        _duplicates(index, collector)
        schemas = dict(snapshot.catalog.documents)
        links: dict[tuple[str, str], ReferenceResolution] = {}
        # Physical replicas need outgoing links for later path-keyed provenance checks.
        # Their common links retain canonical targets and existing evidence assessments.
        for record in records + tuple(record for _, record in replicas):
            if record.kind in _COLLECTIONS:
                continue
            # Trusted schemas select reference fields, not authored payload key names.
            for pointer, reference, expected, wire_kind in schema_references(
                record.document,
>               schemas[V2_URN + record.kind],
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                schemas,
                base=V2_URN + record.kind,
                pointer=record.pointer,
            ):
E           KeyError: 'urn:drm-copilot:discovery:2.0.0:coverage-report'

packages\discovery-runtime\src\drm_copilot_discovery\references.py:400: KeyError
_ test_loaded_report_views_do_not_replace_authored_documentation_accounting[generated/views-nested/] _

snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
folder = 'generated/views', nested = 'nested/'

    @pytest.mark.parametrize(
        "folder,nested", [("reports", ""), ("generated/views", "nested/")]
    )
    def test_loaded_report_views_do_not_replace_authored_documentation_accounting(
        snapshot_catalog: SchemaCatalog, folder: str, nested: str
    ) -> None:
        """Configured report views are outputs; authored documents remain required."""
        profile = mode_profile(snapshot_catalog)
        roots = as_object(to_plain_value(profile.document["artifacts"]))
        roots["reports"] = ROOT + folder
        profile = profile_with(profile, snapshot_catalog, artifacts=roots)
        initial = no_scope_snapshot(snapshot_catalog, profile=profile)
        store = MemoryStore()
        # Real loader membership is derived from exact in-memory captured bytes.
        for file in initial.manifest.files:
            store.put(file.path, file.content)
        baseline = load_snapshot(
            io=store.io(),
            profile_path=profile.artifacts["profile"],
            catalog=snapshot_catalog,
        )
        assert baseline.ok
        report = build_coverage_report(baseline)
        assert report.document["discovery_result"] == "pass"
        prefix = profile.artifacts["reports"] + "/" + nested + "coverage-report"
        store.put(prefix + ".json", report.to_json().encode("utf-8"))
        store.put(prefix + ".md", report.to_markdown().encode("utf-8"))
        reloaded = load_snapshot(
            io=store.io(),
            profile_path=profile.artifacts["profile"],
            catalog=snapshot_catalog,
        )
        assert reloaded.ok
        assert reloaded.file(prefix + ".md").category == "documentation"
        assert reloaded.file(prefix + ".md").content == report.to_markdown().encode("utf-8")
        assert report_input_digest(reloaded) == report_input_digest(baseline)
        assert build_coverage_report(reloaded).document == report.document

        store.put("docs/architecture.md", b"Authored behavior description.")
        authored = load_snapshot(
            io=store.io(),
            profile_path=profile.artifacts["profile"],
            catalog=snapshot_catalog,
        )
        assert authored.ok
        assert authored.file("docs/architecture.md").category == "documentation"
>       assert "COVERAGE_INPUTS" in codes(authored)
                                    ^^^^^^^^^^^^^^^

tests\discovery_runtime\test_coverage_report_contract.py:340:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\test_coverage_rules.py:173: in codes
    for finding in validate_coverage(snapshot, complete=complete).findings
                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\coverage_rules.py:314: in validate_coverage
    index = index if index is not None else index_references(snapshot)
                                            ^^^^^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

snapshot = DiscoverySnapshot(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-p...aaaaaaaaaaaaaaaaaaaaaaaaaaaa'), origin_path=None)), repository_files=(), checkout=None, excluded_paths=(), findings=())

    def index_references(snapshot: DiscoverySnapshot) -> ReferenceIndex:
        """Build a pure immutable graph with bounded diagnostics over all present input."""
        collector = FindingCollector(limit=snapshot.profile.limits.parse_limits().findings)
        # Loading failures remain blockers even when no identities can be extracted.
        for finding in snapshot.findings:
            collector.add(finding)
        # Flatten configured documents and permitted collection members exactly once.
        aliases = replica_aliases(snapshot)
        # Canonical enumeration preserves logical uniqueness without dropping raw inputs.
        records = tuple(
            record
            for artifact in snapshot.artifacts
            if artifact.path not in aliases
            for record in _records(artifact, collector)
        )
        # Retain each proven physical replica for path-keyed outgoing-link checks.
        replicas = tuple(
            (aliases[artifact.path], record)
            for artifact in snapshot.artifacts
            if artifact.path in aliases
            for record in _records(artifact, collector)
        )
        index = ReferenceIndex(records=records, replicas=replicas)
        _duplicates(index, collector)
        schemas = dict(snapshot.catalog.documents)
        links: dict[tuple[str, str], ReferenceResolution] = {}
        # Physical replicas need outgoing links for later path-keyed provenance checks.
        # Their common links retain canonical targets and existing evidence assessments.
        for record in records + tuple(record for _, record in replicas):
            if record.kind in _COLLECTIONS:
                continue
            # Trusted schemas select reference fields, not authored payload key names.
            for pointer, reference, expected, wire_kind in schema_references(
                record.document,
>               schemas[V2_URN + record.kind],
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                schemas,
                base=V2_URN + record.kind,
                pointer=record.pointer,
            ):
E           KeyError: 'urn:drm-copilot:discovery:2.0.0:coverage-report'

packages\discovery-runtime\src\drm_copilot_discovery\references.py:400: KeyError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                           Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\coverage_scope_rules.py     142     52     78     18    55%   87, 111-117, 149, 174, 184, 192-221, 229-236, 242->exit, 260-269, 289-295, 311-317, 325, 331->333, 339, 350, 366-372, 374-396, 405-408, 410-416, 418
--------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            142     52     78     18    55%
Coverage JSON written to file SCRATCH/report-boundary3-coverage.json
Coverage LCOV written to file artifacts/python/lcov.info
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_coverage_report_contract.py::test_loaded_report_views_do_not_replace_authored_documentation_accounting[reports-] - KeyError: 'urn:drm-copilot:discovery:2.0.0:coverage-report'
FAILED tests/discovery_runtime/test_coverage_report_contract.py::test_loaded_report_views_do_not_replace_authored_documentation_accounting[generated/views-nested/] - KeyError: 'urn:drm-copilot:discovery:2.0.0:coverage-report'
============ 2 failed, 7 passed, 17 deselected in 62.75s (0:01:02) ============

```
