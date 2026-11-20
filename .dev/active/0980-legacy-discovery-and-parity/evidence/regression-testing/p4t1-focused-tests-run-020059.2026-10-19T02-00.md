Timestamp: 2026-10-19T02:00:59.787398+00:00
Command: poetry run python -m pytest tests/discovery_runtime/analyzer tests/scripts/dev_tools/discovery/analyzer -q -o addopts= --cov=drm_copilot_discovery.analyzer --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p4t1-focused-coverage.2026-10-19T02-00-08.json
EXIT_CODE: 1
Output Summary:

```text
FF........FFFF.....FF...........FFFF.................................... [ 30%]
........................................................................ [ 60%]
........................................................................ [ 91%]
.....................                                                    [100%]
================================== FAILURES ===================================
___ test_capture_prunes_outputs_and_dependencies_before_descent[/workspace] ___

analyzer_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
workspace = '/workspace'

    @pytest.mark.parametrize("workspace", ["/workspace", "C:/workspace"])
    def test_capture_prunes_outputs_and_dependencies_before_descent(
        analyzer_catalog: SchemaCatalog, workspace: str
    ) -> None:
        """Excluded frontiers are accounted for without probing their child
        metadata/bytes.
        """
        profile = inventory_profile(
            analyzer_catalog,
            project_entry_points=["src/app.sln"],
            test_roots=["tests"],
            excluded_paths=[
                {"path_or_glob": "src/vendor/**", "rationale": "External source."}
            ],
            analyzers={
                "enabled": ["repository"],
                "options": {},
                "ignored_paths": [
                    {"path_or_glob": "src/generated", "rationale": "Build output."}
                ],
                "extension_result_manifests": [],
            },
        )
        store = MemoryStore(workspace)
        for path in (
            "src/.hidden",
            "src/app.sln",
            "src/vendor/private",
            "src/generated/private",
            "tests/test.cs",
            "docs/guide.md",
            profile.artifacts["inventory"] + "/old.json",
        ):
            store.put(path, path.encode())
        forbidden = {
            "src/vendor/private",
            "src/generated/private",
            profile.artifacts["inventory"] + "/old.json",
        }
        original = store.metadata
        seen: list[str] = []

        def metadata(path: str) -> PathMetadata:
            """Reject descendant access after a configured exclusion frontier."""
            assert path not in forbidden
            seen.append(path)
            return original(path)

        result = capture_inputs(
            profile, workspace_root=workspace, metadata=metadata, read_bytes=store.read
        )
        inspected = {item.path: item for item in result.inputs if item.file}
        assert set(inspected) == {
            "src/.hidden",
            "src/app.sln",
            "tests/test.cs",
            "docs/guide.md",
        }
>       assert {item.path for item in result.inputs if item.status == "excluded"} == {
            "src/vendor",
            "src/generated",
            profile.artifacts["inventory"],
        }
E       AssertionError: assert {'docs/migrat... 'src/vendor'} == {'docs/migrat... 'src/vendor'}
E
E         Extra items in the left set:
E         'docs/migration/discovery'
E         Extra items in the right set:
E         'docs/migration/discovery/inventory'
E         Use -v to get more diff

tests\discovery_runtime\analyzer\test_input_capture.py:103: AssertionError
__ test_capture_prunes_outputs_and_dependencies_before_descent[C:/workspace] __

analyzer_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
workspace = 'C:/workspace'

    @pytest.mark.parametrize("workspace", ["/workspace", "C:/workspace"])
    def test_capture_prunes_outputs_and_dependencies_before_descent(
        analyzer_catalog: SchemaCatalog, workspace: str
    ) -> None:
        """Excluded frontiers are accounted for without probing their child
        metadata/bytes.
        """
        profile = inventory_profile(
            analyzer_catalog,
            project_entry_points=["src/app.sln"],
            test_roots=["tests"],
            excluded_paths=[
                {"path_or_glob": "src/vendor/**", "rationale": "External source."}
            ],
            analyzers={
                "enabled": ["repository"],
                "options": {},
                "ignored_paths": [
                    {"path_or_glob": "src/generated", "rationale": "Build output."}
                ],
                "extension_result_manifests": [],
            },
        )
        store = MemoryStore(workspace)
        for path in (
            "src/.hidden",
            "src/app.sln",
            "src/vendor/private",
            "src/generated/private",
            "tests/test.cs",
            "docs/guide.md",
            profile.artifacts["inventory"] + "/old.json",
        ):
            store.put(path, path.encode())
        forbidden = {
            "src/vendor/private",
            "src/generated/private",
            profile.artifacts["inventory"] + "/old.json",
        }
        original = store.metadata
        seen: list[str] = []

        def metadata(path: str) -> PathMetadata:
            """Reject descendant access after a configured exclusion frontier."""
            assert path not in forbidden
            seen.append(path)
            return original(path)

        result = capture_inputs(
            profile, workspace_root=workspace, metadata=metadata, read_bytes=store.read
        )
        inspected = {item.path: item for item in result.inputs if item.file}
        assert set(inspected) == {
            "src/.hidden",
            "src/app.sln",
            "tests/test.cs",
            "docs/guide.md",
        }
>       assert {item.path for item in result.inputs if item.status == "excluded"} == {
            "src/vendor",
            "src/generated",
            profile.artifacts["inventory"],
        }
E       AssertionError: assert {'docs/migrat... 'src/vendor'} == {'docs/migrat... 'src/vendor'}
E
E         Extra items in the left set:
E         'docs/migration/discovery'
E         Extra items in the right set:
E         'docs/migration/discovery/inventory'
E         Use -v to get more diff

tests\discovery_runtime\analyzer\test_input_capture.py:103: AssertionError
______ test_default_and_dry_run_analysis_are_identical_and_do_not_write _______

analyzer_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_default_and_dry_run_analysis_are_identical_and_do_not_write(
        analyzer_catalog: SchemaCatalog,
    ) -> None:
        """Immutable capture inputs support both modes without a publication
        collaborator.
        """
        capture = inventory_capture(analyzer_catalog)
        original = capture
>       first = result_for(capture, analyzer_catalog)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\analyzer\test_pipeline.py:107:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\analyzer\test_pipeline.py:43: in result_for
    return run_inventory(
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py:182: in run_inventory
    return inventory_result(
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

capture = InventoryCapture(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-pr...space-example', revision='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'), path='src/main.cs', content=b'src/main.cs\r\n')))
analyses = (Analysis(components=(JsonObject(members=(('analyzer', JsonObject(members=(('id', 'repository'), ('version', '2.0.0'))...915ec13c494c7ba27bcc81a35587272ab9651900e28edb375ec560afc246a'))))))), findings=(), relationships=(), diagnostics=()),)

    def inventory_result(
        capture: InventoryCapture,
        analyses: tuple[Analysis, ...],
        *,
        analyzer_ids: tuple[str, ...],
        timestamp: str,
        author_or_agent: JsonObject,
        catalog: SchemaCatalog,
    ) -> InventoryResult:
        """Validate complete deterministic inventory JSON and separate ledger proposals.

        Required capture metadata is caller-supplied. Stable identity excludes it;
        content hashes come from the retained input bytes used by the adapters.
        Schema and cross-row failures raise ValueError; this function performs no I/O.
        """
        components = _ordered(
            tuple(item for analysis in analyses for item in analysis.components),
            "component_id",
        )
        findings = _ordered(
            tuple(item for analysis in analyses for item in analysis.findings), "finding_id"
        )
        relationships = _ordered(
            tuple(item for analysis in analyses for item in analysis.relationships),
            "relationship_id",
        )
        diagnostics = _ordered(
            tuple(item for analysis in analyses for item in analysis.diagnostics), "id"
        )
        if (
            sum(map(len, (components, findings, relationships, diagnostics)))
            > capture.profile.limits.artifact_records
        ):
            raise ValueError("Analyzer result exceeds the configured record limit")
        component_ids = {item["component_id"] for item in components}
        # A detection may refer only to a component actually returned in this run.
        for item in findings + relationships:
            references = (
                item.get("component_id"),
                item.get("from_component_id"),
                item.get("to_component_id"),
            )
            if any(
                value is not None and value not in component_ids for value in references
            ):
                raise ValueError("Analyzer result contains a broken component reference")
        files = tuple(
            row(
                path=item.path,
                status=item.status,
                sha256=item.sha256,
                size=len(item.file.content) if item.file else None,
                rationale=item.rationale,
                diagnostic_ids=tuple(
                    d["id"] for d in diagnostics if d.get("path") == item.path
                ),
            )
            for item in capture.inputs
        )
        values = row(
            **{"$schema": "urn:drm-copilot:discovery:2.0.0:inventory-snapshot"},
            schema_version="2.0.0",
            artifact_kind="inventory-snapshot",
            repository=capture.profile.repository.id,
            revision=capture.profile.repository.revision,
            tool=tool("discovery-inventory"),
            analyzers=tuple(tool(name) for name in sorted(analyzer_ids)),
            scan_configuration_sha256=inventory_configuration_digest(capture.profile),
            files=files,
            components=components,
            findings=findings,
            relationships=relationships,
            diagnostics=diagnostics,
            exclusions=capture.exclusions,
            extensions=row(),
        )
        document = JsonObject(
            values.members
            + (
                ("id", stable_id("inventory", values)),
                ("capture", row(timestamp=timestamp, author_or_agent=author_or_agent)),
            )
        )
        checked = validate_document(
            canonical_json(document),
            expected_kind="inventory-snapshot",
            expected_version="2.0.0",
            format="json",
            catalog=catalog,
            limits=capture.profile.limits.parse_limits(),
        )
        if not checked.ok:
>           raise ValueError(
                "Invalid analyzer inventory: "
                + "; ".join(finding.message for finding in checked.findings)
            )
E           ValueError: Invalid analyzer inventory: 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']

packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py:197: ValueError
___ test_inventory_publication_is_explicit_idempotent_and_scope_preserving ____

analyzer_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_inventory_publication_is_explicit_idempotent_and_scope_preserving(
        analyzer_catalog: SchemaCatalog,
    ) -> None:
        """First publication passes real schema/graph/CAS gates and creates only
        inventory.
        """
>       writer, baseline, result, grant = publication_case(analyzer_catalog)
                                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\analyzer\test_pipeline.py:125:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\analyzer\test_pipeline.py:89: in publication_case
    result = result_for(capture_snapshot(baseline.snapshot), catalog)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\analyzer\test_pipeline.py:43: in result_for
    return run_inventory(
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py:182: in run_inventory
    return inventory_result(
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

capture = InventoryCapture(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-pr...ace-example', revision='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'), path='src/main.cs', content=b'class Main {}\r\n')))
analyses = (Analysis(components=(JsonObject(members=(('analyzer', JsonObject(members=(('id', 'repository'), ('version', '2.0.0'))...95a3bd678735b13d9185b3bcaf80646b22c7ca7579d60401ca3501c8b5b05'))))))), findings=(), relationships=(), diagnostics=()),)

    def inventory_result(
        capture: InventoryCapture,
        analyses: tuple[Analysis, ...],
        *,
        analyzer_ids: tuple[str, ...],
        timestamp: str,
        author_or_agent: JsonObject,
        catalog: SchemaCatalog,
    ) -> InventoryResult:
        """Validate complete deterministic inventory JSON and separate ledger proposals.

        Required capture metadata is caller-supplied. Stable identity excludes it;
        content hashes come from the retained input bytes used by the adapters.
        Schema and cross-row failures raise ValueError; this function performs no I/O.
        """
        components = _ordered(
            tuple(item for analysis in analyses for item in analysis.components),
            "component_id",
        )
        findings = _ordered(
            tuple(item for analysis in analyses for item in analysis.findings), "finding_id"
        )
        relationships = _ordered(
            tuple(item for analysis in analyses for item in analysis.relationships),
            "relationship_id",
        )
        diagnostics = _ordered(
            tuple(item for analysis in analyses for item in analysis.diagnostics), "id"
        )
        if (
            sum(map(len, (components, findings, relationships, diagnostics)))
            > capture.profile.limits.artifact_records
        ):
            raise ValueError("Analyzer result exceeds the configured record limit")
        component_ids = {item["component_id"] for item in components}
        # A detection may refer only to a component actually returned in this run.
        for item in findings + relationships:
            references = (
                item.get("component_id"),
                item.get("from_component_id"),
                item.get("to_component_id"),
            )
            if any(
                value is not None and value not in component_ids for value in references
            ):
                raise ValueError("Analyzer result contains a broken component reference")
        files = tuple(
            row(
                path=item.path,
                status=item.status,
                sha256=item.sha256,
                size=len(item.file.content) if item.file else None,
                rationale=item.rationale,
                diagnostic_ids=tuple(
                    d["id"] for d in diagnostics if d.get("path") == item.path
                ),
            )
            for item in capture.inputs
        )
        values = row(
            **{"$schema": "urn:drm-copilot:discovery:2.0.0:inventory-snapshot"},
            schema_version="2.0.0",
            artifact_kind="inventory-snapshot",
            repository=capture.profile.repository.id,
            revision=capture.profile.repository.revision,
            tool=tool("discovery-inventory"),
            analyzers=tuple(tool(name) for name in sorted(analyzer_ids)),
            scan_configuration_sha256=inventory_configuration_digest(capture.profile),
            files=files,
            components=components,
            findings=findings,
            relationships=relationships,
            diagnostics=diagnostics,
            exclusions=capture.exclusions,
            extensions=row(),
        )
        document = JsonObject(
            values.members
            + (
                ("id", stable_id("inventory", values)),
                ("capture", row(timestamp=timestamp, author_or_agent=author_or_agent)),
            )
        )
        checked = validate_document(
            canonical_json(document),
            expected_kind="inventory-snapshot",
            expected_version="2.0.0",
            format="json",
            catalog=catalog,
            limits=capture.profile.limits.parse_limits(),
        )
        if not checked.ok:
>           raise ValueError(
                "Invalid analyzer inventory: "
                + "; ".join(finding.message for finding in checked.findings)
            )
E           ValueError: Invalid analyzer inventory: 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']

packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py:197: ValueError
__________ test_publication_rejects_wrong_grants_and_changed_inputs ___________

analyzer_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_publication_rejects_wrong_grants_and_changed_inputs(
        analyzer_catalog: SchemaCatalog,
    ) -> None:
        """Valid result bytes alone cannot grant write authority or override freshness."""
>       writer, baseline, result, grant = publication_case(analyzer_catalog)
                                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\analyzer\test_pipeline.py:158:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\analyzer\test_pipeline.py:89: in publication_case
    result = result_for(capture_snapshot(baseline.snapshot), catalog)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\analyzer\test_pipeline.py:43: in result_for
    return run_inventory(
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py:182: in run_inventory
    return inventory_result(
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

capture = InventoryCapture(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-pr...ace-example', revision='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'), path='src/main.cs', content=b'class Main {}\r\n')))
analyses = (Analysis(components=(JsonObject(members=(('analyzer', JsonObject(members=(('id', 'repository'), ('version', '2.0.0'))...95a3bd678735b13d9185b3bcaf80646b22c7ca7579d60401ca3501c8b5b05'))))))), findings=(), relationships=(), diagnostics=()),)

    def inventory_result(
        capture: InventoryCapture,
        analyses: tuple[Analysis, ...],
        *,
        analyzer_ids: tuple[str, ...],
        timestamp: str,
        author_or_agent: JsonObject,
        catalog: SchemaCatalog,
    ) -> InventoryResult:
        """Validate complete deterministic inventory JSON and separate ledger proposals.

        Required capture metadata is caller-supplied. Stable identity excludes it;
        content hashes come from the retained input bytes used by the adapters.
        Schema and cross-row failures raise ValueError; this function performs no I/O.
        """
        components = _ordered(
            tuple(item for analysis in analyses for item in analysis.components),
            "component_id",
        )
        findings = _ordered(
            tuple(item for analysis in analyses for item in analysis.findings), "finding_id"
        )
        relationships = _ordered(
            tuple(item for analysis in analyses for item in analysis.relationships),
            "relationship_id",
        )
        diagnostics = _ordered(
            tuple(item for analysis in analyses for item in analysis.diagnostics), "id"
        )
        if (
            sum(map(len, (components, findings, relationships, diagnostics)))
            > capture.profile.limits.artifact_records
        ):
            raise ValueError("Analyzer result exceeds the configured record limit")
        component_ids = {item["component_id"] for item in components}
        # A detection may refer only to a component actually returned in this run.
        for item in findings + relationships:
            references = (
                item.get("component_id"),
                item.get("from_component_id"),
                item.get("to_component_id"),
            )
            if any(
                value is not None and value not in component_ids for value in references
            ):
                raise ValueError("Analyzer result contains a broken component reference")
        files = tuple(
            row(
                path=item.path,
                status=item.status,
                sha256=item.sha256,
                size=len(item.file.content) if item.file else None,
                rationale=item.rationale,
                diagnostic_ids=tuple(
                    d["id"] for d in diagnostics if d.get("path") == item.path
                ),
            )
            for item in capture.inputs
        )
        values = row(
            **{"$schema": "urn:drm-copilot:discovery:2.0.0:inventory-snapshot"},
            schema_version="2.0.0",
            artifact_kind="inventory-snapshot",
            repository=capture.profile.repository.id,
            revision=capture.profile.repository.revision,
            tool=tool("discovery-inventory"),
            analyzers=tuple(tool(name) for name in sorted(analyzer_ids)),
            scan_configuration_sha256=inventory_configuration_digest(capture.profile),
            files=files,
            components=components,
            findings=findings,
            relationships=relationships,
            diagnostics=diagnostics,
            exclusions=capture.exclusions,
            extensions=row(),
        )
        document = JsonObject(
            values.members
            + (
                ("id", stable_id("inventory", values)),
                ("capture", row(timestamp=timestamp, author_or_agent=author_or_agent)),
            )
        )
        checked = validate_document(
            canonical_json(document),
            expected_kind="inventory-snapshot",
            expected_version="2.0.0",
            format="json",
            catalog=catalog,
            limits=capture.profile.limits.parse_limits(),
        )
        if not checked.ok:
>           raise ValueError(
                "Invalid analyzer inventory: "
                + "; ".join(finding.message for finding in checked.findings)
            )
E           ValueError: Invalid analyzer inventory: 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']

packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py:197: ValueError
____________ test_unverified_source_provenance_blocks_publication _____________

analyzer_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_unverified_source_provenance_blocks_publication(
        analyzer_catalog: SchemaCatalog,
    ) -> None:
        """A source with no immutable bytes remains an explicit blocking result."""
>       _, baseline, _, grant = publication_case(analyzer_catalog)
                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\analyzer\test_pipeline.py:175:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\analyzer\test_pipeline.py:89: in publication_case
    result = result_for(capture_snapshot(baseline.snapshot), catalog)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\analyzer\test_pipeline.py:43: in result_for
    return run_inventory(
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py:182: in run_inventory
    return inventory_result(
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

capture = InventoryCapture(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-pr...ace-example', revision='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'), path='src/main.cs', content=b'class Main {}\r\n')))
analyses = (Analysis(components=(JsonObject(members=(('analyzer', JsonObject(members=(('id', 'repository'), ('version', '2.0.0'))...95a3bd678735b13d9185b3bcaf80646b22c7ca7579d60401ca3501c8b5b05'))))))), findings=(), relationships=(), diagnostics=()),)

    def inventory_result(
        capture: InventoryCapture,
        analyses: tuple[Analysis, ...],
        *,
        analyzer_ids: tuple[str, ...],
        timestamp: str,
        author_or_agent: JsonObject,
        catalog: SchemaCatalog,
    ) -> InventoryResult:
        """Validate complete deterministic inventory JSON and separate ledger proposals.

        Required capture metadata is caller-supplied. Stable identity excludes it;
        content hashes come from the retained input bytes used by the adapters.
        Schema and cross-row failures raise ValueError; this function performs no I/O.
        """
        components = _ordered(
            tuple(item for analysis in analyses for item in analysis.components),
            "component_id",
        )
        findings = _ordered(
            tuple(item for analysis in analyses for item in analysis.findings), "finding_id"
        )
        relationships = _ordered(
            tuple(item for analysis in analyses for item in analysis.relationships),
            "relationship_id",
        )
        diagnostics = _ordered(
            tuple(item for analysis in analyses for item in analysis.diagnostics), "id"
        )
        if (
            sum(map(len, (components, findings, relationships, diagnostics)))
            > capture.profile.limits.artifact_records
        ):
            raise ValueError("Analyzer result exceeds the configured record limit")
        component_ids = {item["component_id"] for item in components}
        # A detection may refer only to a component actually returned in this run.
        for item in findings + relationships:
            references = (
                item.get("component_id"),
                item.get("from_component_id"),
                item.get("to_component_id"),
            )
            if any(
                value is not None and value not in component_ids for value in references
            ):
                raise ValueError("Analyzer result contains a broken component reference")
        files = tuple(
            row(
                path=item.path,
                status=item.status,
                sha256=item.sha256,
                size=len(item.file.content) if item.file else None,
                rationale=item.rationale,
                diagnostic_ids=tuple(
                    d["id"] for d in diagnostics if d.get("path") == item.path
                ),
            )
            for item in capture.inputs
        )
        values = row(
            **{"$schema": "urn:drm-copilot:discovery:2.0.0:inventory-snapshot"},
            schema_version="2.0.0",
            artifact_kind="inventory-snapshot",
            repository=capture.profile.repository.id,
            revision=capture.profile.repository.revision,
            tool=tool("discovery-inventory"),
            analyzers=tuple(tool(name) for name in sorted(analyzer_ids)),
            scan_configuration_sha256=inventory_configuration_digest(capture.profile),
            files=files,
            components=components,
            findings=findings,
            relationships=relationships,
            diagnostics=diagnostics,
            exclusions=capture.exclusions,
            extensions=row(),
        )
        document = JsonObject(
            values.members
            + (
                ("id", stable_id("inventory", values)),
                ("capture", row(timestamp=timestamp, author_or_agent=author_or_agent)),
            )
        )
        checked = validate_document(
            canonical_json(document),
            expected_kind="inventory-snapshot",
            expected_version="2.0.0",
            format="json",
            catalog=catalog,
            limits=capture.profile.limits.parse_limits(),
        )
        if not checked.ok:
>           raise ValueError(
                "Invalid analyzer inventory: "
                + "; ".join(finding.message for finding in checked.findings)
            )
E           ValueError: Invalid analyzer inventory: 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']

packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py:197: ValueError
_________ test_null_relationship_target_preserves_unresolved_binding __________

analyzer_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_null_relationship_target_preserves_unresolved_binding(
        analyzer_catalog: SchemaCatalog,
    ) -> None:
        """A declared relationship may retain an unresolved destination without
        inventing it.
        """
        capture = inventory_capture(analyzer_catalog)
        original = RepositoryAnalyzer().analyze(capture)
        component = original.components[0]
        relationship = row(
            relationship_id="dependency-one",
            from_component_id=component["component_id"],
            to_component_id=None,
            target_description="Unresolved external project",
            kind="project-reference",
            source=component["source"],
            analyzer=component["analyzer"],
            classification="detected",
            confidence="inferred",
            extensions=row(),
        )
>       result = inventory_result(
            capture,
            (replace(original, relationships=(relationship,)),),
            analyzer_ids=("repository",),
            timestamp="2026-10-19T01:00:00Z",
            author_or_agent=row(kind="tool", id="fixture"),
            catalog=analyzer_catalog,
        )

tests\discovery_runtime\analyzer\test_pipeline.py:245:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

capture = InventoryCapture(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-pr...space-example', revision='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'), path='src/main.cs', content=b'src/main.cs\r\n')))
analyses = (Analysis(components=(JsonObject(members=(('analyzer', JsonObject(members=(('id', 'repository'), ('version', '2.0.0'))...017d004ac')))), ('target_description', 'Unresolved external project'), ('to_component_id', None))),), diagnostics=()),)

    def inventory_result(
        capture: InventoryCapture,
        analyses: tuple[Analysis, ...],
        *,
        analyzer_ids: tuple[str, ...],
        timestamp: str,
        author_or_agent: JsonObject,
        catalog: SchemaCatalog,
    ) -> InventoryResult:
        """Validate complete deterministic inventory JSON and separate ledger proposals.

        Required capture metadata is caller-supplied. Stable identity excludes it;
        content hashes come from the retained input bytes used by the adapters.
        Schema and cross-row failures raise ValueError; this function performs no I/O.
        """
        components = _ordered(
            tuple(item for analysis in analyses for item in analysis.components),
            "component_id",
        )
        findings = _ordered(
            tuple(item for analysis in analyses for item in analysis.findings), "finding_id"
        )
        relationships = _ordered(
            tuple(item for analysis in analyses for item in analysis.relationships),
            "relationship_id",
        )
        diagnostics = _ordered(
            tuple(item for analysis in analyses for item in analysis.diagnostics), "id"
        )
        if (
            sum(map(len, (components, findings, relationships, diagnostics)))
            > capture.profile.limits.artifact_records
        ):
            raise ValueError("Analyzer result exceeds the configured record limit")
        component_ids = {item["component_id"] for item in components}
        # A detection may refer only to a component actually returned in this run.
        for item in findings + relationships:
            references = (
                item.get("component_id"),
                item.get("from_component_id"),
                item.get("to_component_id"),
            )
            if any(
                value is not None and value not in component_ids for value in references
            ):
                raise ValueError("Analyzer result contains a broken component reference")
        files = tuple(
            row(
                path=item.path,
                status=item.status,
                sha256=item.sha256,
                size=len(item.file.content) if item.file else None,
                rationale=item.rationale,
                diagnostic_ids=tuple(
                    d["id"] for d in diagnostics if d.get("path") == item.path
                ),
            )
            for item in capture.inputs
        )
        values = row(
            **{"$schema": "urn:drm-copilot:discovery:2.0.0:inventory-snapshot"},
            schema_version="2.0.0",
            artifact_kind="inventory-snapshot",
            repository=capture.profile.repository.id,
            revision=capture.profile.repository.revision,
            tool=tool("discovery-inventory"),
            analyzers=tuple(tool(name) for name in sorted(analyzer_ids)),
            scan_configuration_sha256=inventory_configuration_digest(capture.profile),
            files=files,
            components=components,
            findings=findings,
            relationships=relationships,
            diagnostics=diagnostics,
            exclusions=capture.exclusions,
            extensions=row(),
        )
        document = JsonObject(
            values.members
            + (
                ("id", stable_id("inventory", values)),
                ("capture", row(timestamp=timestamp, author_or_agent=author_or_agent)),
            )
        )
        checked = validate_document(
            canonical_json(document),
            expected_kind="inventory-snapshot",
            expected_version="2.0.0",
            format="json",
            catalog=catalog,
            limits=capture.profile.limits.parse_limits(),
        )
        if not checked.ok:
>           raise ValueError(
                "Invalid analyzer inventory: "
                + "; ".join(finding.message for finding in checked.findings)
            )
E           ValueError: Invalid analyzer inventory: 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'inferred' is not one of ['high', 'medium', 'low', 'unknown']

packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py:197: ValueError
_______________ test_registry_loads_only_explicit_core_adapters _______________

analyzer_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
monkeypatch = <_pytest.monkeypatch.MonkeyPatch object at 0x0000023B97F5E9D0>

    def test_registry_loads_only_explicit_core_adapters(
        analyzer_catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Selecting core inventory performs no optional imports or executable dispatch."""
        profile = inventory_profile(analyzer_catalog)

        def reject_import(*args: object, **kwargs: object) -> object:
            """Make even an attempted runtime import observable at this pure boundary."""
            raise AssertionError("Registry selection must not import optional modules")

        with monkeypatch.context() as context:
            context.setattr(builtins, "__import__", reject_import)
>           selected = select_analyzers(profile)
                       ^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\analyzer\test_registry.py:48:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\registry.py:38: in select_analyzers
    enabled = tuple(sorted(profile.analyzers.enabled))
                           ^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py:297: in analyzers
    return AnalyzerProfile(self)
           ^^^^^^^^^^^^^^^^^^^^^
<string>:5: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\profile_models.py:94: in __post_init__
    from drm_copilot_discovery.profile_v2 import ProfileV2
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

args = ('drm_copilot_discovery.profile_v2', {'AnalyzerProfile': <class 'drm_copilot_discovery.profile_models.AnalyzerProfile'...e', 'passed-runtime-evidence', 'path-safety', 'profile-validity', 'verified-evidence'}), ...}, None, ('ProfileV2',), 0)
kwargs = {}

    def reject_import(*args: object, **kwargs: object) -> object:
        """Make even an attempted runtime import observable at this pure boundary."""
>       raise AssertionError("Registry selection must not import optional modules")
E       AssertionError: Registry selection must not import optional modules

tests\discovery_runtime\analyzer\test_registry.py:44: AssertionError
__ test_repository_detects_real_project_markers_without_claiming_inspection ___

analyzer_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_repository_detects_real_project_markers_without_claiming_inspection(
        analyzer_catalog: SchemaCatalog,
    ) -> None:
        """Build manifest names yield structural facts and only unassigned ledger
        proposals.
        """
        capture = inventory_capture(
            analyzer_catalog,
            names=(
                "src/a.slnx",
                "src/b.csproj",
                "src/c.fsproj",
                "src/d.vbproj",
                "src/e.vcxproj",
                "src/pyproject.toml",
                "src/package.json",
                "src/Cargo.toml",
                "src/pom.xml",
                "src/build.gradle",
                "src/z.txt",
            ),
        )
>       result = run_inventory(
            capture,
            timestamp="2026-10-19T01:00:00Z",
            author_or_agent=row(kind="tool", id="fixture"),
            catalog=analyzer_catalog,
        )

tests\discovery_runtime\analyzer\test_repository.py:117:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py:182: in run_inventory
    return inventory_result(
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

capture = InventoryCapture(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-pr...workspace-example', revision='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'), path='src/z.txt', content=b'src/z.txt\r\n')))
analyses = (Analysis(components=(JsonObject(members=(('analyzer', JsonObject(members=(('id', 'repository'), ('version', '2.0.0'))...a90619053590a416a740d64b2739507ecc865bc234e9d65174d32c295d17f'))))))), findings=(), relationships=(), diagnostics=()),)

    def inventory_result(
        capture: InventoryCapture,
        analyses: tuple[Analysis, ...],
        *,
        analyzer_ids: tuple[str, ...],
        timestamp: str,
        author_or_agent: JsonObject,
        catalog: SchemaCatalog,
    ) -> InventoryResult:
        """Validate complete deterministic inventory JSON and separate ledger proposals.

        Required capture metadata is caller-supplied. Stable identity excludes it;
        content hashes come from the retained input bytes used by the adapters.
        Schema and cross-row failures raise ValueError; this function performs no I/O.
        """
        components = _ordered(
            tuple(item for analysis in analyses for item in analysis.components),
            "component_id",
        )
        findings = _ordered(
            tuple(item for analysis in analyses for item in analysis.findings), "finding_id"
        )
        relationships = _ordered(
            tuple(item for analysis in analyses for item in analysis.relationships),
            "relationship_id",
        )
        diagnostics = _ordered(
            tuple(item for analysis in analyses for item in analysis.diagnostics), "id"
        )
        if (
            sum(map(len, (components, findings, relationships, diagnostics)))
            > capture.profile.limits.artifact_records
        ):
            raise ValueError("Analyzer result exceeds the configured record limit")
        component_ids = {item["component_id"] for item in components}
        # A detection may refer only to a component actually returned in this run.
        for item in findings + relationships:
            references = (
                item.get("component_id"),
                item.get("from_component_id"),
                item.get("to_component_id"),
            )
            if any(
                value is not None and value not in component_ids for value in references
            ):
                raise ValueError("Analyzer result contains a broken component reference")
        files = tuple(
            row(
                path=item.path,
                status=item.status,
                sha256=item.sha256,
                size=len(item.file.content) if item.file else None,
                rationale=item.rationale,
                diagnostic_ids=tuple(
                    d["id"] for d in diagnostics if d.get("path") == item.path
                ),
            )
            for item in capture.inputs
        )
        values = row(
            **{"$schema": "urn:drm-copilot:discovery:2.0.0:inventory-snapshot"},
            schema_version="2.0.0",
            artifact_kind="inventory-snapshot",
            repository=capture.profile.repository.id,
            revision=capture.profile.repository.revision,
            tool=tool("discovery-inventory"),
            analyzers=tuple(tool(name) for name in sorted(analyzer_ids)),
            scan_configuration_sha256=inventory_configuration_digest(capture.profile),
            files=files,
            components=components,
            findings=findings,
            relationships=relationships,
            diagnostics=diagnostics,
            exclusions=capture.exclusions,
            extensions=row(),
        )
        document = JsonObject(
            values.members
            + (
                ("id", stable_id("inventory", values)),
                ("capture", row(timestamp=timestamp, author_or_agent=author_or_agent)),
            )
        )
        checked = validate_document(
            canonical_json(document),
            expected_kind="inventory-snapshot",
            expected_version="2.0.0",
            format="json",
            catalog=catalog,
            limits=capture.profile.limits.parse_limits(),
        )
        if not checked.ok:
>           raise ValueError(
                "Invalid analyzer inventory: "
                + "; ".join(finding.message for finding in checked.findings)
            )
E           ValueError: Invalid analyzer inventory: 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']

packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py:197: ValueError
____ test_semantic_identity_ignores_capture_time_but_tracks_changed_bytes _____

analyzer_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_semantic_identity_ignores_capture_time_but_tracks_changed_bytes(
        analyzer_catalog: SchemaCatalog,
    ) -> None:
        """Clock metadata changes serialized bytes without changing semantic identity."""
        capture = inventory_capture(analyzer_catalog)
        author = row(kind="agent", id="fixture")
>       first = run_inventory(
            capture,
            timestamp="2026-10-19T01:00:00Z",
            author_or_agent=author,
            catalog=analyzer_catalog,
        )

tests\discovery_runtime\analyzer\test_repository.py:157:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py:182: in run_inventory
    return inventory_result(
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

capture = InventoryCapture(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-pr...space-example', revision='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'), path='src/main.cs', content=b'src/main.cs\r\n')))
analyses = (Analysis(components=(JsonObject(members=(('analyzer', JsonObject(members=(('id', 'repository'), ('version', '2.0.0'))...915ec13c494c7ba27bcc81a35587272ab9651900e28edb375ec560afc246a'))))))), findings=(), relationships=(), diagnostics=()),)

    def inventory_result(
        capture: InventoryCapture,
        analyses: tuple[Analysis, ...],
        *,
        analyzer_ids: tuple[str, ...],
        timestamp: str,
        author_or_agent: JsonObject,
        catalog: SchemaCatalog,
    ) -> InventoryResult:
        """Validate complete deterministic inventory JSON and separate ledger proposals.

        Required capture metadata is caller-supplied. Stable identity excludes it;
        content hashes come from the retained input bytes used by the adapters.
        Schema and cross-row failures raise ValueError; this function performs no I/O.
        """
        components = _ordered(
            tuple(item for analysis in analyses for item in analysis.components),
            "component_id",
        )
        findings = _ordered(
            tuple(item for analysis in analyses for item in analysis.findings), "finding_id"
        )
        relationships = _ordered(
            tuple(item for analysis in analyses for item in analysis.relationships),
            "relationship_id",
        )
        diagnostics = _ordered(
            tuple(item for analysis in analyses for item in analysis.diagnostics), "id"
        )
        if (
            sum(map(len, (components, findings, relationships, diagnostics)))
            > capture.profile.limits.artifact_records
        ):
            raise ValueError("Analyzer result exceeds the configured record limit")
        component_ids = {item["component_id"] for item in components}
        # A detection may refer only to a component actually returned in this run.
        for item in findings + relationships:
            references = (
                item.get("component_id"),
                item.get("from_component_id"),
                item.get("to_component_id"),
            )
            if any(
                value is not None and value not in component_ids for value in references
            ):
                raise ValueError("Analyzer result contains a broken component reference")
        files = tuple(
            row(
                path=item.path,
                status=item.status,
                sha256=item.sha256,
                size=len(item.file.content) if item.file else None,
                rationale=item.rationale,
                diagnostic_ids=tuple(
                    d["id"] for d in diagnostics if d.get("path") == item.path
                ),
            )
            for item in capture.inputs
        )
        values = row(
            **{"$schema": "urn:drm-copilot:discovery:2.0.0:inventory-snapshot"},
            schema_version="2.0.0",
            artifact_kind="inventory-snapshot",
            repository=capture.profile.repository.id,
            revision=capture.profile.repository.revision,
            tool=tool("discovery-inventory"),
            analyzers=tuple(tool(name) for name in sorted(analyzer_ids)),
            scan_configuration_sha256=inventory_configuration_digest(capture.profile),
            files=files,
            components=components,
            findings=findings,
            relationships=relationships,
            diagnostics=diagnostics,
            exclusions=capture.exclusions,
            extensions=row(),
        )
        document = JsonObject(
            values.members
            + (
                ("id", stable_id("inventory", values)),
                ("capture", row(timestamp=timestamp, author_or_agent=author_or_agent)),
            )
        )
        checked = validate_document(
            canonical_json(document),
            expected_kind="inventory-snapshot",
            expected_version="2.0.0",
            format="json",
            catalog=catalog,
            limits=capture.profile.limits.parse_limits(),
        )
        if not checked.ok:
>           raise ValueError(
                "Invalid analyzer inventory: "
                + "; ".join(finding.message for finding in checked.findings)
            )
E           ValueError: Invalid analyzer inventory: 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']

packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py:197: ValueError
________ test_order_and_paths_are_portable_and_hashes_bind_exact_bytes ________

analyzer_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_order_and_paths_are_portable_and_hashes_bind_exact_bytes(
        analyzer_catalog: SchemaCatalog,
    ) -> None:
        """Input ordering cannot affect inventory and CRLF hashes use original bytes."""
        first = inventory_capture(analyzer_catalog, names=("src/z.cs", "src/État.cs"))
        second = replace(first, inputs=tuple(reversed(first.inputs)))
>       one = run_inventory(
            first,
            timestamp="2026-10-19T01:00:00Z",
            author_or_agent=row(kind="human", id="reviewer"),
            catalog=analyzer_catalog,
        )

tests\discovery_runtime\analyzer\test_repository.py:200:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py:182: in run_inventory
    return inventory_result(
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

capture = InventoryCapture(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-pr...sion='aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'), path='src/État.cs', content=b'src/\xc3\x83\xe2\x80\xb0tat.cs\r\n')))
analyses = (Analysis(components=(JsonObject(members=(('analyzer', JsonObject(members=(('id', 'repository'), ('version', '2.0.0'))...0e6c8ed055b4932dcb98e03600b112ed76b21c0b8ec2d04fecc44e86fe05f'))))))), findings=(), relationships=(), diagnostics=()),)

    def inventory_result(
        capture: InventoryCapture,
        analyses: tuple[Analysis, ...],
        *,
        analyzer_ids: tuple[str, ...],
        timestamp: str,
        author_or_agent: JsonObject,
        catalog: SchemaCatalog,
    ) -> InventoryResult:
        """Validate complete deterministic inventory JSON and separate ledger proposals.

        Required capture metadata is caller-supplied. Stable identity excludes it;
        content hashes come from the retained input bytes used by the adapters.
        Schema and cross-row failures raise ValueError; this function performs no I/O.
        """
        components = _ordered(
            tuple(item for analysis in analyses for item in analysis.components),
            "component_id",
        )
        findings = _ordered(
            tuple(item for analysis in analyses for item in analysis.findings), "finding_id"
        )
        relationships = _ordered(
            tuple(item for analysis in analyses for item in analysis.relationships),
            "relationship_id",
        )
        diagnostics = _ordered(
            tuple(item for analysis in analyses for item in analysis.diagnostics), "id"
        )
        if (
            sum(map(len, (components, findings, relationships, diagnostics)))
            > capture.profile.limits.artifact_records
        ):
            raise ValueError("Analyzer result exceeds the configured record limit")
        component_ids = {item["component_id"] for item in components}
        # A detection may refer only to a component actually returned in this run.
        for item in findings + relationships:
            references = (
                item.get("component_id"),
                item.get("from_component_id"),
                item.get("to_component_id"),
            )
            if any(
                value is not None and value not in component_ids for value in references
            ):
                raise ValueError("Analyzer result contains a broken component reference")
        files = tuple(
            row(
                path=item.path,
                status=item.status,
                sha256=item.sha256,
                size=len(item.file.content) if item.file else None,
                rationale=item.rationale,
                diagnostic_ids=tuple(
                    d["id"] for d in diagnostics if d.get("path") == item.path
                ),
            )
            for item in capture.inputs
        )
        values = row(
            **{"$schema": "urn:drm-copilot:discovery:2.0.0:inventory-snapshot"},
            schema_version="2.0.0",
            artifact_kind="inventory-snapshot",
            repository=capture.profile.repository.id,
            revision=capture.profile.repository.revision,
            tool=tool("discovery-inventory"),
            analyzers=tuple(tool(name) for name in sorted(analyzer_ids)),
            scan_configuration_sha256=inventory_configuration_digest(capture.profile),
            files=files,
            components=components,
            findings=findings,
            relationships=relationships,
            diagnostics=diagnostics,
            exclusions=capture.exclusions,
            extensions=row(),
        )
        document = JsonObject(
            values.members
            + (
                ("id", stable_id("inventory", values)),
                ("capture", row(timestamp=timestamp, author_or_agent=author_or_agent)),
            )
        )
        checked = validate_document(
            canonical_json(document),
            expected_kind="inventory-snapshot",
            expected_version="2.0.0",
            format="json",
            catalog=catalog,
            limits=capture.profile.limits.parse_limits(),
        )
        if not checked.ok:
>           raise ValueError(
                "Invalid analyzer inventory: "
                + "; ".join(finding.message for finding in checked.findings)
            )
E           ValueError: Invalid analyzer inventory: 'verified' is not one of ['high', 'medium', 'low', 'unknown']; 'verified' is not one of ['high', 'medium', 'low', 'unknown']

packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py:197: ValueError
________ test_unavailable_and_unpinned_inputs_remain_visible_blockers _________

analyzer_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_unavailable_and_unpinned_inputs_remain_visible_blockers(
        analyzer_catalog: SchemaCatalog,
    ) -> None:
        """Read failures and absent immutable proof cannot become verified source claims."""
        capture = inventory_capture(analyzer_catalog, pinned=False)
        capture = replace(
            capture,
            inputs=capture.inputs
            + (
                InventoryInput(
                    path="src/blocked.cs", status="unreadable", rationale="Access denied."
                ),
                InventoryInput(
                    path="src/vendor", status="excluded", rationale="External dependency."
                ),
            ),
        )
>       result = run_inventory(
            capture,
            timestamp="2026-10-19T01:00:00Z",
            author_or_agent=row(kind="tool", id="fixture"),
            catalog=analyzer_catalog,
        )

tests\discovery_runtime\analyzer\test_repository.py:236:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py:182: in run_inventory
    return inventory_result(
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

capture = InventoryCapture(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-pr...iscovery/unspecified-behaviors.yaml'), ('rationale', 'Discovery artifact or evidence output.')))), repository_files=())
analyses = (Analysis(components=(JsonObject(members=(('analyzer', JsonObject(members=(('id', 'repository'), ('version', '2.0.0'))...ng immutable repository bytes before publishing this inventory.'), ('path', 'src/main.cs'), ('severity', 'error'))))),)

    def inventory_result(
        capture: InventoryCapture,
        analyses: tuple[Analysis, ...],
        *,
        analyzer_ids: tuple[str, ...],
        timestamp: str,
        author_or_agent: JsonObject,
        catalog: SchemaCatalog,
    ) -> InventoryResult:
        """Validate complete deterministic inventory JSON and separate ledger proposals.

        Required capture metadata is caller-supplied. Stable identity excludes it;
        content hashes come from the retained input bytes used by the adapters.
        Schema and cross-row failures raise ValueError; this function performs no I/O.
        """
        components = _ordered(
            tuple(item for analysis in analyses for item in analysis.components),
            "component_id",
        )
        findings = _ordered(
            tuple(item for analysis in analyses for item in analysis.findings), "finding_id"
        )
        relationships = _ordered(
            tuple(item for analysis in analyses for item in analysis.relationships),
            "relationship_id",
        )
        diagnostics = _ordered(
            tuple(item for analysis in analyses for item in analysis.diagnostics), "id"
        )
        if (
            sum(map(len, (components, findings, relationships, diagnostics)))
            > capture.profile.limits.artifact_records
        ):
            raise ValueError("Analyzer result exceeds the configured record limit")
        component_ids = {item["component_id"] for item in components}
        # A detection may refer only to a component actually returned in this run.
        for item in findings + relationships:
            references = (
                item.get("component_id"),
                item.get("from_component_id"),
                item.get("to_component_id"),
            )
            if any(
                value is not None and value not in component_ids for value in references
            ):
                raise ValueError("Analyzer result contains a broken component reference")
        files = tuple(
            row(
                path=item.path,
                status=item.status,
                sha256=item.sha256,
                size=len(item.file.content) if item.file else None,
                rationale=item.rationale,
                diagnostic_ids=tuple(
                    d["id"] for d in diagnostics if d.get("path") == item.path
                ),
            )
            for item in capture.inputs
        )
        values = row(
            **{"$schema": "urn:drm-copilot:discovery:2.0.0:inventory-snapshot"},
            schema_version="2.0.0",
            artifact_kind="inventory-snapshot",
            repository=capture.profile.repository.id,
            revision=capture.profile.repository.revision,
            tool=tool("discovery-inventory"),
            analyzers=tuple(tool(name) for name in sorted(analyzer_ids)),
            scan_configuration_sha256=inventory_configuration_digest(capture.profile),
            files=files,
            components=components,
            findings=findings,
            relationships=relationships,
            diagnostics=diagnostics,
            exclusions=capture.exclusions,
            extensions=row(),
        )
        document = JsonObject(
            values.members
            + (
                ("id", stable_id("inventory", values)),
                ("capture", row(timestamp=timestamp, author_or_agent=author_or_agent)),
            )
        )
        checked = validate_document(
            canonical_json(document),
            expected_kind="inventory-snapshot",
            expected_version="2.0.0",
            format="json",
            catalog=catalog,
            limits=capture.profile.limits.parse_limits(),
        )
        if not checked.ok:
>           raise ValueError(
                "Invalid analyzer inventory: "
                + "; ".join(finding.message for finding in checked.findings)
            )
E           ValueError: Invalid analyzer inventory: 'inferred' is not one of ['high', 'medium', 'low', 'unknown']; 'inferred' is not one of ['high', 'medium', 'low', 'unknown']

packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py:197: ValueError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                             Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\__init__.py            0      0      0      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py            50      2     14      2    94%   99, 201
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\findings.py           22      2      2      0    92%   88-89
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\input_capture.py     101      0     38      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py          80      0     22      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\models.py            109      0     24      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py           60     14     10      0    74%   205-243
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\registry.py           14      0      2      0   100%
----------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                              436     18    112      2    96%
Coverage JSON written to file docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p4t1-focused-coverage.2026-10-19T02-00-08.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/analyzer/test_input_capture.py::test_capture_prunes_outputs_and_dependencies_before_descent[/workspace]
FAILED tests/discovery_runtime/analyzer/test_input_capture.py::test_capture_prunes_outputs_and_dependencies_before_descent[C:/workspace]
FAILED tests/discovery_runtime/analyzer/test_pipeline.py::test_default_and_dry_run_analysis_are_identical_and_do_not_write
FAILED tests/discovery_runtime/analyzer/test_pipeline.py::test_inventory_publication_is_explicit_idempotent_and_scope_preserving
FAILED tests/discovery_runtime/analyzer/test_pipeline.py::test_publication_rejects_wrong_grants_and_changed_inputs
FAILED tests/discovery_runtime/analyzer/test_pipeline.py::test_unverified_source_provenance_blocks_publication
FAILED tests/discovery_runtime/analyzer/test_pipeline.py::test_null_relationship_target_preserves_unresolved_binding
FAILED tests/discovery_runtime/analyzer/test_registry.py::test_registry_loads_only_explicit_core_adapters
FAILED tests/discovery_runtime/analyzer/test_repository.py::test_repository_detects_real_project_markers_without_claiming_inspection
FAILED tests/discovery_runtime/analyzer/test_repository.py::test_semantic_identity_ignores_capture_time_but_tracks_changed_bytes
FAILED tests/discovery_runtime/analyzer/test_repository.py::test_order_and_paths_are_portable_and_hashes_bind_exact_bytes
FAILED tests/discovery_runtime/analyzer/test_repository.py::test_unavailable_and_unpinned_inputs_remain_visible_blockers
12 failed, 225 passed in 50.00s

```

Elapsed seconds: 50.846264
Source and test bytes unchanged: True

```json
{
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/__init__.py": "a1b8c4f0bc43990ce8e91eae6414aecf0e6fba6fa8cf03712b982d15a0dbe8d1",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/emitter.py": "c874dde0f440cd7d89a2e9970c7c58326f4870c5e4104c6e440d94e5d623e286",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/findings.py": "7edffaa36d0d3c4ca72d6e6f00e9f48e377205472d3874c8222ad00ece2de01d",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/input_capture.py": "d05e1fa8288ac01c391d1f20a5d8d5959a958f2c1f95361020ba18bc39520479",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/inventory.py": "4f70ed6243a4621c8685da95ebd94bd6d6e7ee860968abd66ff6637b822f9d95",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/models.py": "40d71361e26142f6ea2570feb2473e8c8896e0cb7d1f142cce66b422fbc8c791",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/pipeline.py": "36451dbec922c5e14e00a2ba8480e4c63e2734b2dadddc8871b656b176fdf6ad",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry.py": "5fe0b51412b45d26faf02476aae93435746efe4d996ad7ff841846d01fc54d97",
  "scripts/dev_tools/discovery/analyzer/emitter.py": "513ff724143710de873589f604c3f95c2845007e60a10eb906525318f4ca02d9",
  "scripts/dev_tools/discovery/analyzer/inventory.py": "ed56917f3bcf07ef808c1949898e3327f368b71b207cf121a98269d4245ec9a3",
  "scripts/dev_tools/discovery/analyzer/models.py": "de3c0adcf32a60dbcd89e929ee22a46c2d2b13a82f16aabb5b51646ece7eb1f9",
  "scripts/dev_tools/discovery/analyzer/pipeline.py": "9d7a756a9d1bb5b6934ffe1293298990313366ab652b846886ae100e06cdc793",
  "tests/discovery_runtime/analyzer/test_input_capture.py": "729062ce08e0df021bc32403f72cc90eee4333cb02766baeb1c18755bdf3b062",
  "tests/discovery_runtime/analyzer/test_pipeline.py": "7d54a4c3d697927d71ebcd795f7ea7a20548c127a78a560c562f5af828097a6a",
  "tests/discovery_runtime/analyzer/test_registry.py": "6362b7c683e7125a1f31e723c7c36a9b8d38ff4822cf9c9ae9140abf7be76c21",
  "tests/discovery_runtime/analyzer/test_repository.py": "545d60e955def9030255a1eab45a4ffae660aaf16c5f2214b2236331b3680ee4",
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
