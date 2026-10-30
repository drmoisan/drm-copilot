# p4t7-integration-focused6-unit

Timestamp: 2026-10-19T10-49
Command: poetry run pytest tests/discovery_runtime/analyzer/test_dependencies.py tests/discovery_runtime/analyzer/test_dependency_projection_limits.py -o addopts= -v --cov=drm_copilot_discovery.analyzer.dependencies --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/p4t7-integration-focused6-coverage.json
EXIT_CODE: 1
Output Summary: scoped unit; duration 66.687 seconds. Separate exact stdout/stderr hashes and SCRATCH-relative locations qualify sanitized presentation.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 66 items

tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/package.json-package-json] PASSED [  1%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/PACKAGE-LOCK.JSON-package-lock] PASSED [  3%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/npm-shrinkwrap.json-package-lock] PASSED [  4%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/setup.cfg-setup-cfg] PASSED [  6%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/requirements.txt-requirements] PASSED [  7%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/requirements-dev.txt-requirements] PASSED [  9%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/app.csproj-project] PASSED [ 10%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/app.vbproj-project] PASSED [ 12%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/app.fsproj-project] PASSED [ 13%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/app.proj-project] PASSED [ 15%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/Directory.Packages.props-project] PASSED [ 16%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/app.targets-project] PASSED [ 18%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/packages.config-packages-config] PASSED [ 19%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/packages.lock.json-packages-lock] PASSED [ 21%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/setup.py-unsupported] PASSED [ 22%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/pyproject.toml-unsupported] PASSED [ 24%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/poetry.lock-unsupported] PASSED [ 25%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/yarn.lock-unsupported] PASSED [ 27%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/pnpm-lock.yaml-unsupported] PASSED [ 28%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_path_dispatch_is_finite_and_platform_independent[src/readme.txt-None] PASSED [ 30%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_dispatch_passes_exact_bytes_and_limits[package-json-parse_node_dependencies] PASSED [ 31%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_dispatch_passes_exact_bytes_and_limits[package-lock-parse_node_dependencies] PASSED [ 33%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_dispatch_passes_exact_bytes_and_limits[requirements-parse_python_dependencies] PASSED [ 34%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_dispatch_passes_exact_bytes_and_limits[setup-cfg-parse_python_dependencies] PASSED [ 36%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_dispatch_passes_exact_bytes_and_limits[project-parse_dotnet_dependencies] PASSED [ 37%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_dispatch_passes_exact_bytes_and_limits[packages-config-parse_dotnet_dependencies] PASSED [ 39%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_dispatch_passes_exact_bytes_and_limits[packages-lock-parse_dotnet_dependencies] PASSED [ 40%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_projected_facts_and_edges_preserve_source_semantics PASSED [ 42%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_redacted_edge_and_repeated_container_identity PASSED [ 43%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_pin_identity_controls_confidence[absent] PASSED [ 45%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_pin_identity_controls_confidence[wrong-bytes] PASSED [ 46%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_pin_identity_controls_confidence[wrong-revision] PASSED [ 48%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_pin_identity_controls_confidence[wrong-path] PASSED [ 50%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_pin_identity_controls_confidence[wrong-repository] PASSED [ 51%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_pin_identity_controls_confidence[duplicate] PASSED [ 53%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_unavailable_excluded_and_unsupported_inputs_do_not_parse PASSED [ 54%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_parser_failures_use_fixed_diagnostics[dependency-malformed] PASSED [ 56%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_parser_failures_use_fixed_diagnostics[dependency-encoding] PASSED [ 57%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_parser_failures_use_fixed_diagnostics[dependency-unsupported] PASSED [ 59%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_parser_failures_use_fixed_diagnostics[dependency-limit] PASSED [ 60%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_analysis_is_deterministic_and_schema_valid PASSED [ 62%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_empty_capture_and_irrelevant_inputs_have_no_fabricated_fact PASSED [ 63%]
tests/discovery_runtime/analyzer/test_dependencies.py::test_real_parser_families_compose_with_inventory_schema PASSED [ 65%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_all_diagnostics_and_error_fallbacks_share_output_limits PASSED [ 66%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_impossible_error_envelope_raises_instead_of_emitting_over_budget[1] PASSED [ 68%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_impossible_error_envelope_raises_instead_of_emitting_over_budget[1023] PASSED [ 69%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_complete_output_budget_precedes_projection[artifact_records-1] PASSED [ 71%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_complete_output_budget_precedes_projection[document_bytes-1024] PASSED [ 72%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_complete_output_budget_precedes_projection[document_bytes-4096] PASSED [ 74%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_independent_aggregate_resource_limits[pin-count] PASSED [ 75%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_independent_aggregate_resource_limits[pin-bytes] PASSED [ 77%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_independent_aggregate_resource_limits[input-bytes] PASSED [ 78%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_independent_aggregate_resource_limits[scan-work] PASSED [ 80%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_independent_aggregate_resource_limits[path-work] PASSED [ 81%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_parser_contract_violations_cannot_escape[candidates] PASSED [ 83%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_parser_contract_violations_cannot_escape[diagnostics] PASSED [ 84%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_parser_contract_violations_cannot_escape[nodes] PASSED [ 86%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_parser_contract_violations_cannot_escape[text] PASSED [ 87%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_parser_contract_violations_cannot_escape[ordinal] PASSED [ 89%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_parser_contract_violations_cannot_escape[line] PASSED [ 90%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_invalid_public_capture_and_internal_reservations PASSED [ 92%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_pin_lookup_visits_only_each_inputs_retained_group FAILED [ 93%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_remaining_parser_resources_are_independent PASSED [ 95%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_exhausted_parser_budget_stops_before_next_call[maximum-file] FAILED [ 96%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_exhausted_parser_budget_stops_before_next_call[nodes] PASSED [ 98%]
tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_exhausted_parser_budget_stops_before_next_call[retained-text] PASSED [100%]

================================== FAILURES ===================================
___________ test_pin_lookup_visits_only_each_inputs_retained_group ____________

catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
monkeypatch = <_pytest.monkeypatch.MonkeyPatch object at 0x000001EB9E7130E0>

    def test_pin_lookup_visits_only_each_inputs_retained_group(
        catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Use catalog/monkeypatch fixtures to count pin work; return None.

        Retain exact comparison through the accepted helper. The fixture restores the
        observer; no file/process access or expected error occurs.
        """
        # Distinct paths expose an accidental full-pin rescan on every selected input.
        payloads = tuple((f"src/p{ordinal}/package.json", b"{}") for ordinal in range(12))
        captured = configured(catalog, payloads=payloads)
        original = pinned_matches
        groups: list[tuple[str, int]] = []

        def observe(local: InventoryCapture, selected: InventoryInput) -> bool:
            """Inspect local (InventoryCapture) and selected (InventoryInput).

            Return bool from the real comparator; record group sizes locally without
            I/O or changes to retained bytes. No expected exception occurs.
            """
            groups.append((selected.path, len(local.repository_files)))
            return original(local, selected)

        monkeypatch.setattr(dependencies, "pinned_matches", observe)
        stub(monkeypatch, DependencyResult())
        result = DependencyAnalyzer().analyze(captured)
        assert len(result.components) == 12
        # Every captured path receives exactly its own one-member pin group.
>       assert groups == [(path, 1) for path, _ in payloads]
E       AssertionError: assert [('src/p0/pac...son', 1), ...] == [('src/p0/pac...son', 1), ...]
E
E         At index 2 diff: ('src/p10/package.json', 1) != ('src/p2/package.json', 1)
E
E         Full diff:
E           [
E               (
E                   'src/p0/package.json',...
E
E         ...Full output truncated (55 lines hidden), use '-vv' to show

tests\discovery_runtime\analyzer\test_dependency_projection_limits.py:258: AssertionError
______ test_exhausted_parser_budget_stops_before_next_call[maximum-file] ______

catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
monkeypatch = <_pytest.monkeypatch.MonkeyPatch object at 0x000001EB9DFA7770>
case = 'maximum-file'

    @pytest.mark.parametrize("case", ["maximum-file", "nodes", "retained-text"])
    def test_exhausted_parser_budget_stops_before_next_call(
        catalog: SchemaCatalog, monkeypatch: pytest.MonkeyPatch, case: str
    ) -> None:
        """Use catalog/monkeypatch and case (str) to exhaust one resource; return None.

        Isolated parser calls expose reservation order; no I/O or uncontrolled errors.
        """
        captured = configured(
            catalog, payloads=(("src/a/package.json", b"{}"), ("src/b/package.json", b"{}"))
        )
        calls: list[DependencyLimits] = []

        def parse(
            content: bytes, format: str, limits: DependencyLimits
        ) -> DependencyResult:
            """Accept bytes/str/DependencyLimits; return an exhausting result.

            Append limits locally; fixed resource exhaustion is handled by the adapter.
            No I/O or external mutation occurs.
            """
            calls.append(limits)
            # Select one independently exhausted parser resource without producing rows.
            return DependencyResult(
                consumed_nodes=limits.max_nodes if case == "nodes" else 0,
                consumed_text_bytes=limits.max_text_bytes if case == "retained-text" else 0,
            )

        # A per-file cap must reject even when all aggregate input capacities suffice.
        if case == "maximum-file":
            captured = replace(
                captured,
                profile=replace(
                    captured.profile,
>                   analyzers=replace(captured.profile.analyzers, max_file_bytes=1),
                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                ),

tests\discovery_runtime\analyzer\test_dependency_projection_limits.py:332:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = AnalyzerProfile(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-pro...sing-example'), ('name', 'Example processing system'), ('role', 'legacy-source')))), ('test_roots', ())))), index=None)
changes = {'index': None, 'max_file_bytes': 1, 'profile': ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:di...id', 'processing-example'), ('name', 'Example processing system'), ('role', 'legacy-source')))), ('test_roots', ()))))}
f = Field(name='array',type='ClassVar[bool]',default=False,default_factory=<dataclasses._MISSING_TYPE object at 0x000001EB...metadata=mappingproxy({}),kw_only=<dataclasses._MISSING_TYPE object at 0x000001EB9A96ACF0>,_field_type=_FIELD_CLASSVAR)

    def _replace(self, /, **changes):
        # We're going to mutate 'changes', but that's okay because it's a
        # new dict, even if called with 'replace(self, **my_changes)'.

        # It's an error to have init=False fields in 'changes'.
        # If a field is not in 'changes', read its value from the provided 'self'.

        for f in getattr(self, _FIELDS).values():
            # Only consider normal fields or InitVars.
            if f._field_type is _FIELD_CLASSVAR:
                continue

            if not f.init:
                # Error if this field is specified in changes.
                if f.name in changes:
                    raise TypeError(f'field {f.name} is declared with '
                                    f'init=False, it cannot be specified with '
                                    f'replace()')
                continue

            if f.name not in changes:
                if f._field_type is _FIELD_INITVAR and f.default is MISSING:
                    raise TypeError(f"InitVar {f.name!r} "
                                    f'must be specified with replace()')
                changes[f.name] = getattr(self, f.name)

        # Create the new object, which calls __init__() and
        # __post_init__() (if defined), using all of the init fields we've
        # added and/or left in 'changes'.  If there are values supplied in
        # changes that aren't fields, this will correctly raise a
        # TypeError.
>       return self.__class__(**changes)
               ^^^^^^^^^^^^^^^^^^^^^^^^^
E       TypeError: AnalyzerProfile.__init__() got an unexpected keyword argument 'max_file_bytes'

..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: TypeError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                            Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependencies.py     149      0     62      0   100%
---------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                             149      0     62      0   100%
Coverage JSON written to file SCRATCH/p4t7-integration-focused6-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_pin_lookup_visits_only_each_inputs_retained_group
FAILED tests/discovery_runtime/analyzer/test_dependency_projection_limits.py::test_exhausted_parser_budget_stops_before_next_call[maximum-file]
=================== 2 failed, 64 passed in 64.93s (0:01:04) ===================
```
