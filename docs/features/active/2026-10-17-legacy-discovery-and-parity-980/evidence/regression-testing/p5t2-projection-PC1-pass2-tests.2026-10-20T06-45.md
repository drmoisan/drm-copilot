# p5t2-projection-PC1-pass2-tests

Timestamp: 2026-10-20T06-45
Command: poetry run pytest tests/discovery_runtime/test_parity_report_projection.py tests/discovery_runtime/test_validation_modes.py::test_invalid_public_modes_and_unparsed_projection_raise_explicitly tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results tests/discovery_runtime/test_validation_modes.py::test_invalid_coverage_inputs_retain_original_findings_and_unavailable_counts -o addopts= -v --cov=drm_copilot_discovery.validation --cov-config=SCRATCH/coverage.ini --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/projection-coverage.json
EXIT_CODE: 1
Output Summary: tests, 289.493s; exact raw streams separately bound.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 25 items

tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[structural-False] PASSED [  4%]
tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[structural-True] PASSED [  8%]
tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[parity-complete-False] PASSED [ 12%]
tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[parity-complete-True] PASSED [ 16%]
tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[planning-False] PASSED [ 20%]
tests/discovery_runtime/test_parity_report_projection.py::test_requested_mode_and_independent_parity_results[planning-True] PASSED [ 24%]
tests/discovery_runtime/test_parity_report_projection.py::test_invalid_core_reports_unavailable_but_never_valid_output[missing-profile] FAILED [ 28%]
tests/discovery_runtime/test_parity_report_projection.py::test_invalid_core_reports_unavailable_but_never_valid_output[loader] PASSED [ 32%]
tests/discovery_runtime/test_parity_report_projection.py::test_invalid_core_reports_unavailable_but_never_valid_output[artifact] PASSED [ 36%]
tests/discovery_runtime/test_parity_report_projection.py::test_authored_parity_fields_cannot_override_recomputed_output[parity] PASSED [ 40%]
tests/discovery_runtime/test_parity_report_projection.py::test_authored_parity_fields_cannot_override_recomputed_output[parity_result] PASSED [ 44%]
tests/discovery_runtime/test_parity_report_projection.py::test_authored_parity_fields_cannot_override_recomputed_output[parity_findings] PASSED [ 48%]
tests/discovery_runtime/test_parity_report_projection.py::test_multiple_derived_reports_reuse_one_complete_assessment PASSED [ 52%]
tests/discovery_runtime/test_parity_report_projection.py::test_parity_preflight_rejects_excess_before_graph_work PASSED [ 56%]
tests/discovery_runtime/test_parity_report_projection.py::test_unsupported_parity_report_modes_remain_errors[automatic] PASSED [ 60%]
tests/discovery_runtime/test_parity_report_projection.py::test_unsupported_parity_report_modes_remain_errors[agent-output] PASSED [ 64%]
tests/discovery_runtime/test_validation_modes.py::test_invalid_public_modes_and_unparsed_projection_raise_explicitly PASSED [ 68%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[structural-False] PASSED [ 72%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[structural-True] PASSED [ 76%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[discovery-complete-False] PASSED [ 80%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[discovery-complete-True] PASSED [ 84%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[planning-False] PASSED [ 88%]
tests/discovery_runtime/test_validation_modes.py::test_coverage_preserves_requested_mode_and_independent_discovery_results[planning-True] PASSED [ 92%]
tests/discovery_runtime/test_validation_modes.py::test_invalid_coverage_inputs_retain_original_findings_and_unavailable_counts[missing-profile] PASSED [ 96%]
tests/discovery_runtime/test_validation_modes.py::test_invalid_coverage_inputs_retain_original_findings_and_unavailable_counts[loader] PASSED [100%]

================================== FAILURES ===================================
_ test_invalid_core_reports_unavailable_but_never_valid_output[missing-profile] _

snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
fault = 'missing-profile'

    @pytest.mark.parametrize("fault", ["missing-profile", "loader", "artifact"])
    def test_invalid_core_reports_unavailable_but_never_valid_output(
        snapshot_catalog: SchemaCatalog, fault: str
    ) -> None:
        """Retain original diagnostics and reject invalid completion authority.

        snapshot_catalog (SchemaCatalog) validates fixtures; fault (str) selects the
        captured-input defect. Return None; construct and inspect only memory values.
        """
        snapshot = no_scope_snapshot(snapshot_catalog)
        # Separate absent profile bytes, malformed artifacts and loader diagnostics.
        if fault == "missing-profile":
            snapshot = replace(
                snapshot,
                manifest=replace(
                    snapshot.manifest,
                    files=tuple(
                        item
                        for item in snapshot.manifest.files
                        if item.path != snapshot.profile.artifacts["profile"]
                    ),
                ),
            )
        elif fault == "artifact":
            snapshot = replace_document(snapshot, snapshot.artifacts[0].path, {})
        else:
            snapshot = replace(
                snapshot,
                findings=(
                    Finding(
                        code="CAPTURE_ERROR",
                        message="Unavailable",
                        next_action="Recapture.",
                    ),
                ),
            )
        expected = validate_snapshot(snapshot, mode="structural")
        report = build_parity_report(snapshot).to_dict()
        assert report["validation_result"] == report["parity_result"] == "fail"
        assert report["findings"] == report["parity_findings"]
        assert report["findings"] == [item.to_dict() for item in expected.findings]
        assert report["counts"] == {}
        assert report["parity"] == to_plain_value(unavailable_parity_summary())
        assert report["input_sha256"] == report_input_digest(snapshot)
        assert not validate_snapshot(snapshot, mode="planning").ok
        output = document_record(
            snapshot.profile, "parity-report", ROOT + "reports/invalid.json", report
        )
>       reviewed, invocation = output_context(
            snapshot,
            "migration-coverage-reviewer",
            outputs=(output,),
            review_mode="parity-complete",
        )

tests\discovery_runtime\test_parity_report_projection.py:128:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\validation_test_support.py:218: in output_context
    "profile_sha256": baseline.file(baseline.profile.artifacts["profile"]).sha256,
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = DiscoverySnapshot(profile=ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-p...aaaaaaaaaaaaaaaaaaaaaaaaaaaa'), origin_path=None)), repository_files=(), checkout=None, excluded_paths=(), findings=())
path = 'docs/migration/discovery/domain-profile.yaml'

    def file(self, path: str) -> SnapshotFile:
        """Return captured content by exact spelling, raising for uncaptured inputs."""
        # Match exact spelling; aliases cannot select another captured file.
        for item in self.manifest.files:
            if item.path == path:
                return item
>       raise KeyError(path)
E       KeyError: 'docs/migration/discovery/domain-profile.yaml'

packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:270: KeyError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                 Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\validation.py     162      8     56      8    93%   193, 195, 306->340, 357, 382, 390-397, 423, 431
----------------------------------------------------------------------------------------------------------------
TOTAL                                                                  162      8     56      8    93%
Coverage JSON written to file SCRATCH/projection-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_parity_report_projection.py::test_invalid_core_reports_unavailable_but_never_valid_output[missing-profile]
================== 1 failed, 24 passed in 287.44s (0:04:47) ===================
```
