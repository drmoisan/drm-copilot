# P4-T5 development tests

Timestamp: 2026-10-19T07-19
Command: `poetry run python -m pytest -q -o addopts= tests/discovery_runtime/analyzer/test_filesystem_access.py tests/discovery_runtime/analyzer/test_registry_access.py --cov=drm_copilot_discovery.analyzer.api_access --cov=drm_copilot_discovery.analyzer.api_syntax --cov=drm_copilot_discovery.analyzer.filesystem_access --cov=drm_copilot_discovery.analyzer.registry_access --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p4t5-access-development-coverage.raw.json`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
...................................................................FFF.. [ 47%]
........................................................................ [ 95%]
.......                                                                  [100%]
================================== FAILURES ===================================
_ test_exact_captured_bytes_back_offsets_checksums_and_composed_inventory[utf-8-sig] _

catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
encoding = 'utf-8-sig'

    @pytest.mark.parametrize("encoding", ["utf-8-sig", "utf-16", "utf-32"])
    def test_exact_captured_bytes_back_offsets_checksums_and_composed_inventory(
        catalog: SchemaCatalog, encoding: str
    ) -> None:
        """Catalog and str encoding provide immutable payload/pin provenance.

        Returns None; composition validates source hashes and repeated deterministic IDs.
        """
        content = '// Ω\nFile.Open("VALUE_SENTINEL"); File.Open("VALUE_SENTINEL");'.encode(
            encoding
        )
        inputs = capture(catalog, (("src/a.CS", content),))
        result = FilesystemAccessAnalyzer().analyze(inputs)
        assert len(result.findings) == 2
        # Repeated API calls on one line must retain distinct occurrence identifiers.
        assert len({finding["finding_id"] for finding in result.findings}) == 2
        source = cast("JsonObject", result.findings[0]["source"])
        assert source["sha256"] == hashlib.sha256(content).hexdigest()
        assert source["line_range"] == row(start=2, end=2)
        assert FilesystemAccessAnalyzer().analyze(inputs) == result
        document = inventory_result(
            inputs,
            (result,),
            analyzer_ids=("filesystem-access",),
            timestamp="2026-10-19T00:00:00Z",
            author_or_agent=row(kind="tool", id="fixture"),
            catalog=catalog,
        )
>       assert document.document["findings"] == result.findings
E       AssertionError: assert (JsonObject(m...e.Open'))))))) == (JsonObject(m...e.Open')))))))
E
E         At index 0 diff: JsonObject(members=(('analyzer', JsonObject(members=(('id', 'filesystem-access'), ('version', '2.0.0')))), ('classification', 'inferred'), ('component_id', 'component-1681434f4118c10ba4a52a748db97d40a9cac1cadd0d648a6dc30085ba5e6fb1'), ('confidence', 'medium'), ('extensions', JsonObject(members=(('drm.api-access', JsonObject(members=(('aliases', 'not-resolved'), ('anchor', 'physical-text'), ('arguments', 'not-collected'), ('binding', 'unresolved'), ('end_offset', 43), ('offset', 34), ('platform_applicability', 'unresolved'), ('preprocessing', 'not-evalua...
E
E         ...Full output truncated (2 lines hidden), use '-vv' to show

tests\discovery_runtime\analyzer\test_filesystem_access.py:201: AssertionError
_ test_exact_captured_bytes_back_offsets_checksums_and_composed_inventory[utf-16] _

catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
encoding = 'utf-16'

    @pytest.mark.parametrize("encoding", ["utf-8-sig", "utf-16", "utf-32"])
    def test_exact_captured_bytes_back_offsets_checksums_and_composed_inventory(
        catalog: SchemaCatalog, encoding: str
    ) -> None:
        """Catalog and str encoding provide immutable payload/pin provenance.

        Returns None; composition validates source hashes and repeated deterministic IDs.
        """
        content = '// Ω\nFile.Open("VALUE_SENTINEL"); File.Open("VALUE_SENTINEL");'.encode(
            encoding
        )
        inputs = capture(catalog, (("src/a.CS", content),))
        result = FilesystemAccessAnalyzer().analyze(inputs)
        assert len(result.findings) == 2
        # Repeated API calls on one line must retain distinct occurrence identifiers.
        assert len({finding["finding_id"] for finding in result.findings}) == 2
        source = cast("JsonObject", result.findings[0]["source"])
        assert source["sha256"] == hashlib.sha256(content).hexdigest()
        assert source["line_range"] == row(start=2, end=2)
        assert FilesystemAccessAnalyzer().analyze(inputs) == result
        document = inventory_result(
            inputs,
            (result,),
            analyzer_ids=("filesystem-access",),
            timestamp="2026-10-19T00:00:00Z",
            author_or_agent=row(kind="tool", id="fixture"),
            catalog=catalog,
        )
>       assert document.document["findings"] == result.findings
E       AssertionError: assert (JsonObject(m...e.Open'))))))) == (JsonObject(m...e.Open')))))))
E
E         At index 0 diff: JsonObject(members=(('analyzer', JsonObject(members=(('id', 'filesystem-access'), ('version', '2.0.0')))), ('classification', 'inferred'), ('component_id', 'component-1681434f4118c10ba4a52a748db97d40a9cac1cadd0d648a6dc30085ba5e6fb1'), ('confidence', 'medium'), ('extensions', JsonObject(members=(('drm.api-access', JsonObject(members=(('aliases', 'not-resolved'), ('anchor', 'physical-text'), ('arguments', 'not-collected'), ('binding', 'unresolved'), ('end_offset', 43), ('offset', 34), ('platform_applicability', 'unresolved'), ('preprocessing', 'not-evalua...
E
E         ...Full output truncated (2 lines hidden), use '-vv' to show

tests\discovery_runtime\analyzer\test_filesystem_access.py:201: AssertionError
_ test_exact_captured_bytes_back_offsets_checksums_and_composed_inventory[utf-32] _

catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
encoding = 'utf-32'

    @pytest.mark.parametrize("encoding", ["utf-8-sig", "utf-16", "utf-32"])
    def test_exact_captured_bytes_back_offsets_checksums_and_composed_inventory(
        catalog: SchemaCatalog, encoding: str
    ) -> None:
        """Catalog and str encoding provide immutable payload/pin provenance.

        Returns None; composition validates source hashes and repeated deterministic IDs.
        """
        content = '// Ω\nFile.Open("VALUE_SENTINEL"); File.Open("VALUE_SENTINEL");'.encode(
            encoding
        )
        inputs = capture(catalog, (("src/a.CS", content),))
        result = FilesystemAccessAnalyzer().analyze(inputs)
        assert len(result.findings) == 2
        # Repeated API calls on one line must retain distinct occurrence identifiers.
        assert len({finding["finding_id"] for finding in result.findings}) == 2
        source = cast("JsonObject", result.findings[0]["source"])
        assert source["sha256"] == hashlib.sha256(content).hexdigest()
        assert source["line_range"] == row(start=2, end=2)
        assert FilesystemAccessAnalyzer().analyze(inputs) == result
        document = inventory_result(
            inputs,
            (result,),
            analyzer_ids=("filesystem-access",),
            timestamp="2026-10-19T00:00:00Z",
            author_or_agent=row(kind="tool", id="fixture"),
            catalog=catalog,
        )
>       assert document.document["findings"] == result.findings
E       AssertionError: assert (JsonObject(m...e.Open'))))))) == (JsonObject(m...e.Open')))))))
E
E         At index 0 diff: JsonObject(members=(('analyzer', JsonObject(members=(('id', 'filesystem-access'), ('version', '2.0.0')))), ('classification', 'inferred'), ('component_id', 'component-1681434f4118c10ba4a52a748db97d40a9cac1cadd0d648a6dc30085ba5e6fb1'), ('confidence', 'medium'), ('extensions', JsonObject(members=(('drm.api-access', JsonObject(members=(('aliases', 'not-resolved'), ('anchor', 'physical-text'), ('arguments', 'not-collected'), ('binding', 'unresolved'), ('end_offset', 43), ('offset', 34), ('platform_applicability', 'unresolved'), ('preprocessing', 'not-evalua...
E
E         ...Full output truncated (2 lines hidden), use '-vv' to show

tests\discovery_runtime\analyzer\test_filesystem_access.py:201: AssertionError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                                 Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\api_access.py             65      0     16      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\api_syntax.py            101      0     52      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\filesystem_access.py      11      0      0      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\registry_access.py         9      0      0      0   100%
--------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                  186      0     68      0   100%
Coverage JSON written to file SCRATCH\p4t5-access-development-coverage.raw.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/analyzer/test_filesystem_access.py::test_exact_captured_bytes_back_offsets_checksums_and_composed_inventory[utf-8-sig]
FAILED tests/discovery_runtime/analyzer/test_filesystem_access.py::test_exact_captured_bytes_back_offsets_checksums_and_composed_inventory[utf-16]
FAILED tests/discovery_runtime/analyzer/test_filesystem_access.py::test_exact_captured_bytes_back_offsets_checksums_and_composed_inventory[utf-32]
3 failed, 148 passed in 88.40s (0:01:28)

```
