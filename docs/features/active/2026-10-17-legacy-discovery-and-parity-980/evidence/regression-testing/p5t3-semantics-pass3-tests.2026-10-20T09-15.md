# p5t3-semantics-pass3-tests

Timestamp: 2026-10-20T09-15
Command: poetry run pytest tests/discovery_runtime/test_completion_projection.py tests/discovery_runtime/test_validation_modes.py::test_invalid_public_modes_and_unparsed_projection_raise_explicitly -o addopts= -v --cov=drm_copilot_discovery.validation --cov=drm_copilot_discovery.validation_operation --cov-config=SCRATCH/issue-980-coverage.ini --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-semantic-coverage.json
EXIT_CODE: 1
Output Summary: tests, 144.008s; exact raw streams separately bound.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0 -- .\.venv\Scripts\python.exe
cachedir: .pytest_cache
rootdir: .
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 20 items

tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[structural-False] PASSED [  5%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[structural-True] PASSED [ 10%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[discovery-complete-False] PASSED [ 15%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[discovery-complete-True] PASSED [ 20%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[parity-complete-False] PASSED [ 25%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[parity-complete-True] PASSED [ 30%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[planning-False] PASSED [ 35%]
tests/discovery_runtime/test_completion_projection.py::test_completion_uses_only_selected_mode_with_trusted_warnings[planning-True] PASSED [ 40%]
tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[missing-profile] FAILED [ 45%]
tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[malformed] FAILED [ 50%]
tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[loader] FAILED [ 55%]
tests/discovery_runtime/test_completion_projection.py::test_completion_recomputation_reuses_assessment_and_rejects_authored_override PASSED [ 60%]
tests/discovery_runtime/test_completion_projection.py::test_completion_preserves_bounded_warning_and_truncation_authority[100] PASSED [ 65%]
tests/discovery_runtime/test_completion_projection.py::test_completion_preserves_bounded_warning_and_truncation_authority[101] PASSED [ 70%]
tests/discovery_runtime/test_completion_projection.py::test_completion_preflight_precedes_input_validation PASSED [ 75%]
tests/discovery_runtime/test_completion_projection.py::test_completion_rejects_unsupported_modes[automatic-False] PASSED [ 80%]
tests/discovery_runtime/test_completion_projection.py::test_completion_rejects_unsupported_modes[automatic-True] PASSED [ 85%]
tests/discovery_runtime/test_completion_projection.py::test_completion_rejects_unsupported_modes[agent-output-False] PASSED [ 90%]
tests/discovery_runtime/test_completion_projection.py::test_completion_rejects_unsupported_modes[agent-output-True] PASSED [ 95%]
tests/discovery_runtime/test_validation_modes.py::test_invalid_public_modes_and_unparsed_projection_raise_explicitly PASSED [100%]

================================== FAILURES ===================================
_ test_malformed_completion_retains_diagnostics_without_semantic_assessment[missing-profile] _

snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
monkeypatch = <_pytest.monkeypatch.MonkeyPatch object at 0x000001B1B1CE65D0>
fault = 'missing-profile'

    @pytest.mark.parametrize("fault", ["missing-profile", "malformed", "loader"])
    def test_malformed_completion_retains_diagnostics_without_semantic_assessment(
        snapshot_catalog: SchemaCatalog, monkeypatch: MonkeyPatch, fault: str
    ) -> None:
        """Return unavailable diagnostics while preserving root and output refusal.

        snapshot_catalog (SchemaCatalog) supplies schemas; monkeypatch (MonkeyPatch)
        scopes an observer; fault (str) selects captured invalid input. Return None;
        use immutable snapshots and no external I/O.
        """
        baseline = no_scope_snapshot(snapshot_catalog)
        snapshot = baseline
        # Exercise absent captured authority, invalid core bytes and loader failure.
        if fault == "missing-profile":
            snapshot = replace(
                snapshot,
                manifest=replace(
                    snapshot.manifest,
                    # Remove only profile authority while retaining captured artifacts.
                    files=tuple(
                        item
                        for item in snapshot.manifest.files
                        if item.path != snapshot.profile.artifacts["profile"]
                    ),
                ),
            )
        elif fault == "malformed":
            snapshot = replace_document(snapshot, snapshot.artifacts[0].path, {})
        else:
            snapshot = replace(
                snapshot,
                findings=(
                    Finding(
                        code="CAPTURE_ERROR",
                        message="Unavailable.",
                        next_action="Recapture.",
                    ),
                ),
            )
        expected = validate_snapshot(snapshot, mode="structural")

        def unexpected(*args: object, **kwargs: object) -> None:
            """Reject args/kwargs (object) if invalid inputs reach semantic construction.

            Return None only by annotation; raise AssertionError without external effects.
            """
            raise AssertionError((args, kwargs))

        with monkeypatch.context() as scoped:
            scoped.setattr(validation, "_Validation", unexpected)
            report = build_completion_report(snapshot, mode="planning").to_dict()
        assert report["validation_result"] == "fail"
        assert report["counts"] is None
        # Preserve each original structural diagnostic without substituting a summary.
        assert report["findings"] == [item.to_dict() for item in expected.findings]
        assert as_object(report["completion"])["assessment_state"] == "unavailable"
        assert as_object(report["completion"])["planning_prerequisite"] is None
        assert not validate_snapshot(snapshot, mode="planning").ok
        output = document_record(
            baseline.profile, "completion-report", ROOT + "reports/invalid.json", report
        )
        reviewed, invocation = output_context(
            baseline,
            "migration-coverage-reviewer",
            outputs=(output,),
            review_mode="planning",
        )
        # Preserve the valid invocation binding while retaining the prospective fault.
        reviewed = replace(
            reviewed,
            artifacts=(*snapshot.artifacts, *reviewed.artifacts[len(baseline.artifacts) :]),
>           manifest=replace(
                reviewed.manifest,
                files=(
                    *snapshot.manifest.files,
                    *reviewed.manifest.files[len(baseline.manifest.files) :],
                ),
            ),
            findings=snapshot.findings,
        )

tests\discovery_runtime\test_completion_projection.py:177:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:7: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:160: in __post_init__
    paths = check_path_collisions(file.path for file in self.files)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

paths = <generator object InputManifest.__post_init__.<locals>.<genexpr> at 0x000001B1B1867280>

    def check_path_collisions(paths: Iterable[str]) -> tuple[str, ...]:
        """Return sorted paths or reject duplicates and case/Unicode ancestor aliases.

        Shared identical ancestors are permitted. Different spellings of the same
        component are rejected even when their final file names differ. Pure only.
        """
        spellings: dict[tuple[str, ...], str] = {}
        leaves: set[tuple[str, ...]] = set()
        result: list[str] = []
        # Record every prefix to detect aliases such as Docs/a and docs/b.
        for path in paths:
            key = collision_key(path)
            if key in leaves:
>               raise PathPolicyError(
                    "PATH_COLLISION", path, "Remove duplicate or aliased paths."
                )
E               drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/migration/discovery/scope.yaml': Remove duplicate or aliased paths.

packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: PathPolicyError
_ test_malformed_completion_retains_diagnostics_without_semantic_assessment[malformed] _

snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
monkeypatch = <_pytest.monkeypatch.MonkeyPatch object at 0x000001B1B19127B0>
fault = 'malformed'

    @pytest.mark.parametrize("fault", ["missing-profile", "malformed", "loader"])
    def test_malformed_completion_retains_diagnostics_without_semantic_assessment(
        snapshot_catalog: SchemaCatalog, monkeypatch: MonkeyPatch, fault: str
    ) -> None:
        """Return unavailable diagnostics while preserving root and output refusal.

        snapshot_catalog (SchemaCatalog) supplies schemas; monkeypatch (MonkeyPatch)
        scopes an observer; fault (str) selects captured invalid input. Return None;
        use immutable snapshots and no external I/O.
        """
        baseline = no_scope_snapshot(snapshot_catalog)
        snapshot = baseline
        # Exercise absent captured authority, invalid core bytes and loader failure.
        if fault == "missing-profile":
            snapshot = replace(
                snapshot,
                manifest=replace(
                    snapshot.manifest,
                    # Remove only profile authority while retaining captured artifacts.
                    files=tuple(
                        item
                        for item in snapshot.manifest.files
                        if item.path != snapshot.profile.artifacts["profile"]
                    ),
                ),
            )
        elif fault == "malformed":
            snapshot = replace_document(snapshot, snapshot.artifacts[0].path, {})
        else:
            snapshot = replace(
                snapshot,
                findings=(
                    Finding(
                        code="CAPTURE_ERROR",
                        message="Unavailable.",
                        next_action="Recapture.",
                    ),
                ),
            )
        expected = validate_snapshot(snapshot, mode="structural")

        def unexpected(*args: object, **kwargs: object) -> None:
            """Reject args/kwargs (object) if invalid inputs reach semantic construction.

            Return None only by annotation; raise AssertionError without external effects.
            """
            raise AssertionError((args, kwargs))

        with monkeypatch.context() as scoped:
            scoped.setattr(validation, "_Validation", unexpected)
            report = build_completion_report(snapshot, mode="planning").to_dict()
        assert report["validation_result"] == "fail"
        assert report["counts"] is None
        # Preserve each original structural diagnostic without substituting a summary.
        assert report["findings"] == [item.to_dict() for item in expected.findings]
        assert as_object(report["completion"])["assessment_state"] == "unavailable"
        assert as_object(report["completion"])["planning_prerequisite"] is None
        assert not validate_snapshot(snapshot, mode="planning").ok
        output = document_record(
            baseline.profile, "completion-report", ROOT + "reports/invalid.json", report
        )
        reviewed, invocation = output_context(
            baseline,
            "migration-coverage-reviewer",
            outputs=(output,),
            review_mode="planning",
        )
        # Preserve the valid invocation binding while retaining the prospective fault.
        reviewed = replace(
            reviewed,
            artifacts=(*snapshot.artifacts, *reviewed.artifacts[len(baseline.artifacts) :]),
>           manifest=replace(
                reviewed.manifest,
                files=(
                    *snapshot.manifest.files,
                    *reviewed.manifest.files[len(baseline.manifest.files) :],
                ),
            ),
            findings=snapshot.findings,
        )

tests\discovery_runtime\test_completion_projection.py:177:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:7: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:160: in __post_init__
    paths = check_path_collisions(file.path for file in self.files)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

paths = <generator object InputManifest.__post_init__.<locals>.<genexpr> at 0x000001B1B1867880>

    def check_path_collisions(paths: Iterable[str]) -> tuple[str, ...]:
        """Return sorted paths or reject duplicates and case/Unicode ancestor aliases.

        Shared identical ancestors are permitted. Different spellings of the same
        component are rejected even when their final file names differ. Pure only.
        """
        spellings: dict[tuple[str, ...], str] = {}
        leaves: set[tuple[str, ...]] = set()
        result: list[str] = []
        # Record every prefix to detect aliases such as Docs/a and docs/b.
        for path in paths:
            key = collision_key(path)
            if key in leaves:
>               raise PathPolicyError(
                    "PATH_COLLISION", path, "Remove duplicate or aliased paths."
                )
E               drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/migration/discovery/scope.yaml': Remove duplicate or aliased paths.

packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: PathPolicyError
_ test_malformed_completion_retains_diagnostics_without_semantic_assessment[loader] _

snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
monkeypatch = <_pytest.monkeypatch.MonkeyPatch object at 0x000001B1B1BE7A10>
fault = 'loader'

    @pytest.mark.parametrize("fault", ["missing-profile", "malformed", "loader"])
    def test_malformed_completion_retains_diagnostics_without_semantic_assessment(
        snapshot_catalog: SchemaCatalog, monkeypatch: MonkeyPatch, fault: str
    ) -> None:
        """Return unavailable diagnostics while preserving root and output refusal.

        snapshot_catalog (SchemaCatalog) supplies schemas; monkeypatch (MonkeyPatch)
        scopes an observer; fault (str) selects captured invalid input. Return None;
        use immutable snapshots and no external I/O.
        """
        baseline = no_scope_snapshot(snapshot_catalog)
        snapshot = baseline
        # Exercise absent captured authority, invalid core bytes and loader failure.
        if fault == "missing-profile":
            snapshot = replace(
                snapshot,
                manifest=replace(
                    snapshot.manifest,
                    # Remove only profile authority while retaining captured artifacts.
                    files=tuple(
                        item
                        for item in snapshot.manifest.files
                        if item.path != snapshot.profile.artifacts["profile"]
                    ),
                ),
            )
        elif fault == "malformed":
            snapshot = replace_document(snapshot, snapshot.artifacts[0].path, {})
        else:
            snapshot = replace(
                snapshot,
                findings=(
                    Finding(
                        code="CAPTURE_ERROR",
                        message="Unavailable.",
                        next_action="Recapture.",
                    ),
                ),
            )
        expected = validate_snapshot(snapshot, mode="structural")

        def unexpected(*args: object, **kwargs: object) -> None:
            """Reject args/kwargs (object) if invalid inputs reach semantic construction.

            Return None only by annotation; raise AssertionError without external effects.
            """
            raise AssertionError((args, kwargs))

        with monkeypatch.context() as scoped:
            scoped.setattr(validation, "_Validation", unexpected)
            report = build_completion_report(snapshot, mode="planning").to_dict()
        assert report["validation_result"] == "fail"
        assert report["counts"] is None
        # Preserve each original structural diagnostic without substituting a summary.
        assert report["findings"] == [item.to_dict() for item in expected.findings]
        assert as_object(report["completion"])["assessment_state"] == "unavailable"
        assert as_object(report["completion"])["planning_prerequisite"] is None
        assert not validate_snapshot(snapshot, mode="planning").ok
        output = document_record(
            baseline.profile, "completion-report", ROOT + "reports/invalid.json", report
        )
        reviewed, invocation = output_context(
            baseline,
            "migration-coverage-reviewer",
            outputs=(output,),
            review_mode="planning",
        )
        # Preserve the valid invocation binding while retaining the prospective fault.
        reviewed = replace(
            reviewed,
            artifacts=(*snapshot.artifacts, *reviewed.artifacts[len(baseline.artifacts) :]),
>           manifest=replace(
                reviewed.manifest,
                files=(
                    *snapshot.manifest.files,
                    *reviewed.manifest.files[len(baseline.manifest.files) :],
                ),
            ),
            findings=snapshot.findings,
        )

tests\discovery_runtime\test_completion_projection.py:177:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:7: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:160: in __post_init__
    paths = check_path_collisions(file.path for file in self.files)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

paths = <generator object InputManifest.__post_init__.<locals>.<genexpr> at 0x000001B1B1867880>

    def check_path_collisions(paths: Iterable[str]) -> tuple[str, ...]:
        """Return sorted paths or reject duplicates and case/Unicode ancestor aliases.

        Shared identical ancestors are permitted. Different spellings of the same
        component are rejected even when their final file names differ. Pure only.
        """
        spellings: dict[tuple[str, ...], str] = {}
        leaves: set[tuple[str, ...]] = set()
        result: list[str] = []
        # Record every prefix to detect aliases such as Docs/a and docs/b.
        for path in paths:
            key = collision_key(path)
            if key in leaves:
>               raise PathPolicyError(
                    "PATH_COLLISION", path, "Remove duplicate or aliased paths."
                )
E               drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/migration/discovery/scope.yaml': Remove duplicate or aliased paths.

packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: PathPolicyError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                           Stmts   Miss Branch BrPart  Cover   Missing
--------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\validation.py                86     17     40      9    76%   97, 122, 130-137, 154, 156-160, 162-169, 171, 209, 217-220
packages\discovery-runtime\src\drm_copilot_discovery\validation_operation.py      98     10     22      6    85%   145, 147, 163->208, 243->246, 263-293, 296->305
--------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                            184     27     62     15    80%
Coverage JSON written to file SCRATCH/issue-980-semantic-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[missing-profile]
FAILED tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[malformed]
FAILED tests/discovery_runtime/test_completion_projection.py::test_malformed_completion_retains_diagnostics_without_semantic_assessment[loader]
================== 3 failed, 17 passed in 142.07s (0:02:22) ===================
```
