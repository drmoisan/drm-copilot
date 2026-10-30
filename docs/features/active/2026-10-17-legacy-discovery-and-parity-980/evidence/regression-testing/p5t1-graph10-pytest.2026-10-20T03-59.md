# P5-T1 graph10-pytest

Timestamp: 2026-10-20T03-59
Command: poetry run pytest tests/discovery_runtime/test_coverage_report.py tests/discovery_runtime/test_coverage_report_contract.py -vv --cov=drm_copilot_discovery.coverage_report --cov=drm_copilot_discovery.coverage_population --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/graph10-coverage.json
EXIT_CODE: 1

Duration seconds: 36.992

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- WORKSPACE\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 49 items

tests/discovery_runtime/test_coverage_report.py::test_inspection_disposition_and_blocked_identity_counts_are_independent[inspected-supporting-0-1] PASSED [  2%]
tests/discovery_runtime/test_coverage_report.py::test_inspection_disposition_and_blocked_identity_counts_are_independent[inspected-unassigned-0-0] PASSED [  4%]
tests/discovery_runtime/test_coverage_report.py::test_inspection_disposition_and_blocked_identity_counts_are_independent[blocked-blocked-1-0] PASSED [  6%]
tests/discovery_runtime/test_coverage_report.py::test_inspection_disposition_and_blocked_identity_counts_are_independent[blocked-supporting-1-1] PASSED [  8%]
tests/discovery_runtime/test_coverage_report.py::test_inspection_disposition_and_blocked_identity_counts_are_independent[uninspected-unassigned-0-0] PASSED [ 10%]
tests/discovery_runtime/test_coverage_report.py::test_missing_and_duplicate_ledger_rows_remain_in_selected_denominator[rows0] PASSED [ 12%]
tests/discovery_runtime/test_coverage_report.py::test_missing_and_duplicate_ledger_rows_remain_in_selected_denominator[rows1] PASSED [ 14%]
tests/discovery_runtime/test_coverage_report.py::test_only_valid_exclusions_leave_the_eligible_denominator[True] PASSED [ 16%]
tests/discovery_runtime/test_coverage_report.py::test_only_valid_exclusions_leave_the_eligible_denominator[False] PASSED [ 18%]
tests/discovery_runtime/test_coverage_report.py::test_unselected_inventory_and_multiple_feature_links_have_named_units PASSED [ 20%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[observed-1] PASSED [ 22%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[passed-1] PASSED [ 24%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[failed-0] PASSED [ 26%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[not-run-0] PASSED [ 28%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[blocked-0] PASSED [ 30%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_support_counts_source_scenarios_not_runs[absent-0] PASSED [ 32%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[missing] PASSED [ 34%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[checksum] PASSED [ 36%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[stale] PASSED [ 38%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[uri-only] PASSED [ 40%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[environment] PASSED [ 42%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[claim] PASSED [ 44%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[truncation] PASSED [ 46%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[passed-without-proof] PASSED [ 48%]
tests/discovery_runtime/test_coverage_report.py::test_runtime_proof_failures_cannot_inflate_verified_numerators[target-owned] PASSED [ 51%]
tests/discovery_runtime/test_coverage_report.py::test_required_feature_count_is_distinct_from_client_obligations PASSED [ 53%]
tests/discovery_runtime/test_coverage_report.py::test_confidence_never_substitutes_for_verified_claim_or_evidence[inferred-high-0] PASSED [ 55%]
tests/discovery_runtime/test_coverage_report.py::test_confidence_never_substitutes_for_verified_claim_or_evidence[verified-low-1] PASSED [ 57%]
tests/discovery_runtime/test_coverage_report.py::test_confidence_never_substitutes_for_verified_claim_or_evidence[unknown-high-0] PASSED [ 59%]
tests/discovery_runtime/test_coverage_report.py::test_unresolved_questions_are_counted_independently[open-1] PASSED [ 61%]
tests/discovery_runtime/test_coverage_report.py::test_unresolved_questions_are_counted_independently[under-review-1] PASSED [ 63%]
tests/discovery_runtime/test_coverage_report.py::test_unresolved_questions_are_counted_independently[resolved-0] PASSED [ 65%]
tests/discovery_runtime/test_coverage_report_contract.py::test_public_report_renders_exact_fields_and_null_empty_percentages PASSED [ 67%]
tests/discovery_runtime/test_coverage_report_contract.py::test_public_report_never_promotes_missing_or_invalid_graphs[draft] PASSED [ 69%]
tests/discovery_runtime/test_coverage_report_contract.py::test_public_report_never_promotes_missing_or_invalid_graphs[uninventoried] PASSED [ 71%]
tests/discovery_runtime/test_coverage_report_contract.py::test_public_report_never_promotes_missing_or_invalid_graphs[invalid] PASSED [ 73%]
tests/discovery_runtime/test_coverage_report_contract.py::test_report_outputs_do_not_change_input_digest_or_semantic_counts PASSED [ 75%]
tests/discovery_runtime/test_coverage_report_contract.py::test_arbitrary_objects_cannot_supply_graph_authority[None] PASSED [ 77%]
tests/discovery_runtime/test_coverage_report_contract.py::test_arbitrary_objects_cannot_supply_graph_authority[value1] PASSED [ 79%]
tests/discovery_runtime/test_coverage_report_contract.py::test_arbitrary_objects_cannot_supply_graph_authority[value2] PASSED [ 81%]
tests/discovery_runtime/test_coverage_report_contract.py::test_aggregate_preflight_limits_nonascii_input_before_validation PASSED [ 83%]
tests/discovery_runtime/test_coverage_report_contract.py::test_preflight_excludes_large_report_output_but_not_authored_artifacts FAILED [ 85%]
tests/discovery_runtime/test_coverage_report_contract.py::test_unknown_population_is_unavailable_instead_of_zero_components[empty-ledger] PASSED [ 87%]
tests/discovery_runtime/test_coverage_report_contract.py::test_unknown_population_is_unavailable_instead_of_zero_components[absent] PASSED [ 89%]
tests/discovery_runtime/test_coverage_report_contract.py::test_unknown_population_is_unavailable_instead_of_zero_components[missing-scope] PASSED [ 91%]
tests/discovery_runtime/test_coverage_report_contract.py::test_unknown_population_is_unavailable_instead_of_zero_components[ambiguous] FAILED [ 93%]
tests/discovery_runtime/test_coverage_report_contract.py::test_selector_work_is_reserved_before_the_accepted_scope_query[16-False] PASSED [ 95%]
tests/discovery_runtime/test_coverage_report_contract.py::test_selector_work_is_reserved_before_the_accepted_scope_query[128-False] PASSED [ 97%]
tests/discovery_runtime/test_coverage_report_contract.py::test_selector_work_is_reserved_before_the_accepted_scope_query[1024-True] PASSED [100%]

================================== FAILURES ===================================
___ test_preflight_excludes_large_report_output_but_not_authored_artifacts ____

snapshot_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...rocessing-example'), ('name', 'Example processing system'), ('role', 'legacy-source')))), ('test_roots', ('tests',)))))
snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_preflight_excludes_large_report_output_but_not_authored_artifacts(
        snapshot_profile: ProfileV2,
        snapshot_catalog: SchemaCatalog,
    ) -> None:
        """Derived views do not consume the structured semantic-input budget."""
        profile = profile_with(
            snapshot_profile, snapshot_catalog, limits={"document_bytes": 4096}
        )
        snapshot = captured(profile, snapshot_catalog)
        report = artifact("coverage-report", "coverage", fields={"extra": "😀" * 1200})
>       coverage_preflight(replace(snapshot, artifacts=(report,)))
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_coverage_report_contract.py:158:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = DiscoverySnapshot(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-p...aaaaaaaaaaaaaaaaaaaaaaaaaaa'), origin_path=None),), repository_files=(), checkout=None, excluded_paths=(), findings=())

    def __post_init__(self) -> None:
        """Freeze collections and require every parsed artifact to have raw bytes."""
        artifacts = tuple(sorted(self.artifacts, key=lambda item: item.path))
        check_path_collisions(item.path for item in artifacts)
        captured = {item.path for item in self.manifest.files}
        if any(item.path not in captured for item in artifacts):
>           raise ValueError("Every parsed artifact requires captured input bytes")
E           ValueError: Every parsed artifact requires captured input bytes

packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:215: ValueError
_ test_unknown_population_is_unavailable_instead_of_zero_components[ambiguous] _

snapshot_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...rocessing-example'), ('name', 'Example processing system'), ('role', 'legacy-source')))), ('test_roots', ('tests',)))))
snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
case = 'ambiguous'

    @pytest.mark.parametrize(
        "case", ["empty-ledger", "absent", "missing-scope", "ambiguous"]
    )
    def test_unknown_population_is_unavailable_instead_of_zero_components(
        snapshot_profile: ProfileV2,
        snapshot_catalog: SchemaCatalog,
        case: str,
    ) -> None:
        """Known inventory survives empty rows; unresolvable selection reports no counts."""
        snapshot = coverage_snapshot(
            snapshot_profile,
            snapshot_catalog,
            rows=[],
            detected=[
                detection(snapshot_profile),
                detection(snapshot_profile, component_id="second"),
            ],
        )
        if case == "absent":
            # Remove the entire ledger while preserving the same scope/inventory inputs.
            snapshot = replace(
                snapshot,
                artifacts=tuple(
                    item
                    for item in snapshot.artifacts
                    if item.expected_kind != "coverage-ledger"
                ),
            )
        elif case == "missing-scope":
            snapshot = change(
                snapshot, "coverage-ledger", scope_ref=reference("scope", "missing")
            )
        elif case == "ambiguous":
            # Duplicate scope identity prevents authoritative reference resolution.
            scope = next(
                item for item in snapshot.artifacts if item.expected_kind == "scope"
            )
>           snapshot = replace(
                snapshot,
                artifacts=(
                    *snapshot.artifacts,
                    replace(scope, path="docs/duplicate-scope.json"),
                ),
            )

tests\discovery_runtime\test_coverage_report_contract.py:201:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:11: in __init__
    ???
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = DiscoverySnapshot(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-p...aaaaaaaa'), path='src/component.cs', content=b'first\r\nsecond\nlast')), checkout=None, excluded_paths=(), findings=())

    def __post_init__(self) -> None:
        """Freeze collections and require every parsed artifact to have raw bytes."""
        artifacts = tuple(sorted(self.artifacts, key=lambda item: item.path))
        check_path_collisions(item.path for item in artifacts)
        captured = {item.path for item in self.manifest.files}
        if any(item.path not in captured for item in artifacts):
>           raise ValueError("Every parsed artifact requires captured input bytes")
E           ValueError: Every parsed artifact requires captured input bytes

packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:215: ValueError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                          Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\coverage_population.py     115      2     50      4    96%   93->92, 238, 278, 320->319
packages\discovery-runtime\src\drm_copilot_discovery\coverage_report.py         111      0     26      0   100%
-------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                           226      2     76      4    98%
Coverage JSON written to file SCRATCH/graph10-coverage.json
Coverage LCOV written to file artifacts/python/lcov.info
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_coverage_report_contract.py::test_preflight_excludes_large_report_output_but_not_authored_artifacts - ValueError: Every parsed artifact requires captured input bytes
FAILED tests/discovery_runtime/test_coverage_report_contract.py::test_unknown_population_is_unavailable_instead_of_zero_components[ambiguous] - ValueError: Every parsed artifact requires captured input bytes
======================== 2 failed, 47 passed in 34.93s ========================

```
