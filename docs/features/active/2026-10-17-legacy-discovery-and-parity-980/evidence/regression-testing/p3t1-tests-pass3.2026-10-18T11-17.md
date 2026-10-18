# p3t1-tests-pass3

Timestamp: 2026-10-18T11-17
Command: poetry run pytest -o addopts= tests/discovery_runtime/test_mutation_plan.py tests/discovery_runtime/test_mutation_commit.py --cov=drm_copilot_discovery.mutation_plan --cov=drm_copilot_discovery.mutation_io --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t1-coverage.json -q
EXIT_CODE: 1
Output Summary: FAILED tests/discovery_runtime/test_mutation_commit.py::test_stale_complete_inputs_and_parent_changes_block_before_writes[collision]; FAILED tests/discovery_runtime/test_mutation_commit.py::test_unexpected_adapter_side_effects_cannot_report_success[bytes]; FAILED tests/discovery_runtime/test_mutation_commit.py::test_unexpected_adapter_side_effects_cannot_report_success[identity]; 19 failed, 25 passed in 317.50s (0:05:17)

Working directory: .
Started: 2026-10-18T11:11:50.009616+00:00
Duration seconds: 318.754
Phase: P3-T1 planned mutations and guarded commits; focused task verification.

## Captured output

```text
..........FFFFFFFF....F.....F.FFFFFFF...FF..                             [100%]
================================== FAILURES ===================================
____ test_role_output_uses_exact_accepted_validator[legacy-parity-analyst] ____

role = 'legacy-parity-analyst'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize(
        "role",
        [
            "legacy-parity-analyst",
            "runtime-characterization-analyst",
            "requirements-reconciler",
        ],
    )
    def test_role_output_uses_exact_accepted_validator(
        role: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """Draft questions require an exact role output manifest."""
        _, baseline = mutation_case(mutation_catalog)
>       changes, context = role_plan(baseline, role=role)
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_plan.py:237:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\test_mutation_plan.py:110: in role_plan
    _, context = output_context(baseline.snapshot, role, outputs=(output,))
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\validation_test_support.py:302: in output_context
    manifest=replace(baseline.manifest, files=tuple(files.values())),
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:7: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:162: in __post_init__
    check_path_collisions(paths + missing)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

paths = ('docs/migration/discovery/domain-profile.yaml', 'docs/migration/discovery/reports/required.json', 'docs/migration/dis...aml', 'config/discovery.json', 'docs/migration/discovery/acceptance', 'docs/migration/discovery/characterization', ...)

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
E               drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/migration/discovery/unspecified-behaviors.yaml': Remove duplicate or aliased paths.

packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: PathPolicyError
_ test_role_output_uses_exact_accepted_validator[runtime-characterization-analyst] _

role = 'runtime-characterization-analyst'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize(
        "role",
        [
            "legacy-parity-analyst",
            "runtime-characterization-analyst",
            "requirements-reconciler",
        ],
    )
    def test_role_output_uses_exact_accepted_validator(
        role: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """Draft questions require an exact role output manifest."""
        _, baseline = mutation_case(mutation_catalog)
>       changes, context = role_plan(baseline, role=role)
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_plan.py:237:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\test_mutation_plan.py:110: in role_plan
    _, context = output_context(baseline.snapshot, role, outputs=(output,))
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\validation_test_support.py:302: in output_context
    manifest=replace(baseline.manifest, files=tuple(files.values())),
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:7: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:162: in __post_init__
    check_path_collisions(paths + missing)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

paths = ('docs/migration/discovery/domain-profile.yaml', 'docs/migration/discovery/reports/required.json', 'docs/migration/dis...aml', 'config/discovery.json', 'docs/migration/discovery/acceptance', 'docs/migration/discovery/characterization', ...)

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
E               drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/migration/discovery/unspecified-behaviors.yaml': Remove duplicate or aliased paths.

packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: PathPolicyError
___ test_role_output_uses_exact_accepted_validator[requirements-reconciler] ___

role = 'requirements-reconciler'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize(
        "role",
        [
            "legacy-parity-analyst",
            "runtime-characterization-analyst",
            "requirements-reconciler",
        ],
    )
    def test_role_output_uses_exact_accepted_validator(
        role: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """Draft questions require an exact role output manifest."""
        _, baseline = mutation_case(mutation_catalog)
>       changes, context = role_plan(baseline, role=role)
                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_plan.py:237:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\test_mutation_plan.py:110: in role_plan
    _, context = output_context(baseline.snapshot, role, outputs=(output,))
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\validation_test_support.py:302: in output_context
    manifest=replace(baseline.manifest, files=tuple(files.values())),
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:7: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:162: in __post_init__
    check_path_collisions(paths + missing)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

paths = ('docs/migration/discovery/domain-profile.yaml', 'docs/migration/discovery/reports/required.json', 'docs/migration/dis...aml', 'config/discovery.json', 'docs/migration/discovery/acceptance', 'docs/migration/discovery/characterization', ...)

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
E               drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/migration/discovery/unspecified-behaviors.yaml': Remove duplicate or aliased paths.

packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: PathPolicyError
_______ test_role_mismatches_and_unrequested_changes_are_rejected[role] _______

fault = 'role'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize(
        "fault", ["role", "workspace", "baseline", "manifest", "unrequested"]
    )
    def test_role_mismatches_and_unrequested_changes_are_rejected(
        fault: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """Caller context and required outputs cannot be substituted or widened by bytes."""
        _, baseline = mutation_case(mutation_catalog)
>       changes, context = role_plan(baseline)
                           ^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_plan.py:256:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\test_mutation_plan.py:110: in role_plan
    _, context = output_context(baseline.snapshot, role, outputs=(output,))
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\validation_test_support.py:302: in output_context
    manifest=replace(baseline.manifest, files=tuple(files.values())),
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:7: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:162: in __post_init__
    check_path_collisions(paths + missing)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

paths = ('docs/migration/discovery/domain-profile.yaml', 'docs/migration/discovery/reports/required.json', 'docs/migration/dis...aml', 'config/discovery.json', 'docs/migration/discovery/acceptance', 'docs/migration/discovery/characterization', ...)

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
E               drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/migration/discovery/unspecified-behaviors.yaml': Remove duplicate or aliased paths.

packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: PathPolicyError
____ test_role_mismatches_and_unrequested_changes_are_rejected[workspace] _____

fault = 'workspace'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize(
        "fault", ["role", "workspace", "baseline", "manifest", "unrequested"]
    )
    def test_role_mismatches_and_unrequested_changes_are_rejected(
        fault: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """Caller context and required outputs cannot be substituted or widened by bytes."""
        _, baseline = mutation_case(mutation_catalog)
>       changes, context = role_plan(baseline)
                           ^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_plan.py:256:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\test_mutation_plan.py:110: in role_plan
    _, context = output_context(baseline.snapshot, role, outputs=(output,))
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\validation_test_support.py:302: in output_context
    manifest=replace(baseline.manifest, files=tuple(files.values())),
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:7: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:162: in __post_init__
    check_path_collisions(paths + missing)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

paths = ('docs/migration/discovery/domain-profile.yaml', 'docs/migration/discovery/reports/required.json', 'docs/migration/dis...aml', 'config/discovery.json', 'docs/migration/discovery/acceptance', 'docs/migration/discovery/characterization', ...)

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
E               drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/migration/discovery/unspecified-behaviors.yaml': Remove duplicate or aliased paths.

packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: PathPolicyError
_____ test_role_mismatches_and_unrequested_changes_are_rejected[baseline] _____

fault = 'baseline'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize(
        "fault", ["role", "workspace", "baseline", "manifest", "unrequested"]
    )
    def test_role_mismatches_and_unrequested_changes_are_rejected(
        fault: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """Caller context and required outputs cannot be substituted or widened by bytes."""
        _, baseline = mutation_case(mutation_catalog)
>       changes, context = role_plan(baseline)
                           ^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_plan.py:256:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\test_mutation_plan.py:110: in role_plan
    _, context = output_context(baseline.snapshot, role, outputs=(output,))
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\validation_test_support.py:302: in output_context
    manifest=replace(baseline.manifest, files=tuple(files.values())),
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:7: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:162: in __post_init__
    check_path_collisions(paths + missing)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

paths = ('docs/migration/discovery/domain-profile.yaml', 'docs/migration/discovery/reports/required.json', 'docs/migration/dis...aml', 'config/discovery.json', 'docs/migration/discovery/acceptance', 'docs/migration/discovery/characterization', ...)

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
E               drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/migration/discovery/unspecified-behaviors.yaml': Remove duplicate or aliased paths.

packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: PathPolicyError
_____ test_role_mismatches_and_unrequested_changes_are_rejected[manifest] _____

fault = 'manifest'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize(
        "fault", ["role", "workspace", "baseline", "manifest", "unrequested"]
    )
    def test_role_mismatches_and_unrequested_changes_are_rejected(
        fault: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """Caller context and required outputs cannot be substituted or widened by bytes."""
        _, baseline = mutation_case(mutation_catalog)
>       changes, context = role_plan(baseline)
                           ^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_plan.py:256:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\test_mutation_plan.py:110: in role_plan
    _, context = output_context(baseline.snapshot, role, outputs=(output,))
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\validation_test_support.py:302: in output_context
    manifest=replace(baseline.manifest, files=tuple(files.values())),
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:7: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:162: in __post_init__
    check_path_collisions(paths + missing)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

paths = ('docs/migration/discovery/domain-profile.yaml', 'docs/migration/discovery/reports/required.json', 'docs/migration/dis...aml', 'config/discovery.json', 'docs/migration/discovery/acceptance', 'docs/migration/discovery/characterization', ...)

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
E               drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/migration/discovery/unspecified-behaviors.yaml': Remove duplicate or aliased paths.

packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: PathPolicyError
___ test_role_mismatches_and_unrequested_changes_are_rejected[unrequested] ____

fault = 'unrequested'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize(
        "fault", ["role", "workspace", "baseline", "manifest", "unrequested"]
    )
    def test_role_mismatches_and_unrequested_changes_are_rejected(
        fault: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """Caller context and required outputs cannot be substituted or widened by bytes."""
        _, baseline = mutation_case(mutation_catalog)
>       changes, context = role_plan(baseline)
                           ^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_plan.py:256:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\test_mutation_plan.py:110: in role_plan
    _, context = output_context(baseline.snapshot, role, outputs=(output,))
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\validation_test_support.py:302: in output_context
    manifest=replace(baseline.manifest, files=tuple(files.values())),
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:7: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:162: in __post_init__
    check_path_collisions(paths + missing)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

paths = ('docs/migration/discovery/domain-profile.yaml', 'docs/migration/discovery/reports/required.json', 'docs/migration/dis...aml', 'config/discovery.json', 'docs/migration/discovery/acceptance', 'docs/migration/discovery/characterization', ...)

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
E               drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/migration/discovery/unspecified-behaviors.yaml': Remove duplicate or aliased paths.

packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: PathPolicyError
____________ test_parser_findings_are_retained_in_graph_rejection _____________

mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_parser_findings_are_retained_in_graph_rejection(
        mutation_catalog: SchemaCatalog,
    ) -> None:
        """A schema-valid envelope with broken references returns actual graph findings."""
        _, baseline = mutation_case(mutation_catalog)
        value = load_fixture("unspecified-behavior-collection")
        change = replace(
            collection_change(baseline),
            artifact_id=str(value["id"]),
            content=json.dumps(value).encode(),
        )
>       with pytest.raises(MutationError, match="MUTATION_INVALID") as raised:
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
E       Failed: DID NOT RAISE <class 'drm_copilot_discovery.mutation_plan.MutationError'>

tests\discovery_runtime\test_mutation_plan.py:305: Failed
________ test_commit_creates_all_outputs_and_preserves_unrelated_bytes ________

mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_commit_creates_all_outputs_and_preserves_unrelated_bytes(
        mutation_catalog: SchemaCatalog,
    ) -> None:
        """A valid role mutation creates a new parent safely and revokes old authority."""
        store, baseline = mutation_case(mutation_catalog)
>       changes, context = role_plan(baseline)
                           ^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_commit.py:97:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\test_mutation_plan.py:110: in role_plan
    _, context = output_context(baseline.snapshot, role, outputs=(output,))
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\validation_test_support.py:302: in output_context
    manifest=replace(baseline.manifest, files=tuple(files.values())),
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:7: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:162: in __post_init__
    check_path_collisions(paths + missing)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

paths = ('docs/migration/discovery/domain-profile.yaml', 'docs/migration/discovery/reports/required.json', 'docs/migration/dis...aml', 'config/discovery.json', 'docs/migration/discovery/acceptance', 'docs/migration/discovery/characterization', ...)

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
E               drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/migration/discovery/unspecified-behaviors.yaml': Remove duplicate or aliased paths.

packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: PathPolicyError
______ test_repeatable_dry_run_has_no_writes_directories_or_revocations _______

mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_repeatable_dry_run_has_no_writes_directories_or_revocations(
        mutation_catalog: SchemaCatalog,
    ) -> None:
        """Repeated plans return identical projected output without any writable action."""
        store, baseline = mutation_case(mutation_catalog)
>       changes, context = role_plan(baseline)
                           ^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_commit.py:144:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\test_mutation_plan.py:110: in role_plan
    _, context = output_context(baseline.snapshot, role, outputs=(output,))
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
tests\discovery_runtime\validation_test_support.py:302: in output_context
    manifest=replace(baseline.manifest, files=tuple(files.values())),
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:7: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\snapshot.py:162: in __post_init__
    check_path_collisions(paths + missing)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

paths = ('docs/migration/discovery/domain-profile.yaml', 'docs/migration/discovery/reports/required.json', 'docs/migration/dis...aml', 'config/discovery.json', 'docs/migration/discovery/acceptance', 'docs/migration/discovery/characterization', ...)

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
E               drm_copilot_discovery.path_models.PathPolicyError: PATH_COLLISION: 'docs/migration/discovery/unspecified-behaviors.yaml': Remove duplicate or aliased paths.

packages\discovery-runtime\src\drm_copilot_discovery\path_models.py:100: PathPolicyError
__ test_stale_complete_inputs_and_parent_changes_block_before_writes[bytes] ___

race = 'bytes'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize(
        "race", ["bytes", "addition", "deletion", "identity", "parent", "collision"]
    )
    def test_stale_complete_inputs_and_parent_changes_block_before_writes(
        race: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """The complete read set detects changes beyond the destination's own digest."""
        store, baseline = mutation_case(mutation_catalog)
        store.put("src/a.py", b"original")
        baseline = writer_baseline = capture(store, mutation_catalog)
        change = collection_change(baseline)
>       plan = plan_mutation(baseline, (change,), grants=grants_for(change))
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_commit.py:168:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

baseline = CapturedWorkspace(workspace_root='/workspace', snapshot=DiscoverySnapshot(profile=ProfileV2(document=JsonObject(member...ace/src/a.py', children=())), ('tests', PathMetadata(kind='missing', identity=None, resolved_path=None, children=()))))
changes = (MutationChange(artifact_kind='unspecified-behavior-collection', artifact_id='questions', path='docs/migration/discove...kind": "unspecified-behavior-collection", "id": "questions", "records": [], "extensions": {}}', expected_sha256=None),)

            ),
        )


    def plan_mutation(
        baseline: CapturedWorkspace,
        changes: tuple[MutationChange, ...],
        *,
        grants: tuple[WriteGrant, ...],
        invocation: InvocationContext | None = None,
    ) -> MutationPlan:
        """Validate all prospective bytes before returning an immutable commit plan.

        Grants and optional native invocation must be authenticated by the caller.
        Absence of invocation is the explicit local-user/root route, not an analyst
        fallback. Invalid requests raise MutationError/ValueError/OSError; no writes
        or authority-store operations occur, including during repeated dry runs.
        """
        if not changes or len(changes) > baseline.snapshot.profile.limits.artifact_records:
            raise MutationError("MUTATION_LIMIT", "Provide a bounded nonempty change set")
        changes = tuple(sorted(changes, key=lambda item: item.path))
        check_path_collisions(item.path for item in changes)
        check_path_collisions(grant.path for grant in grants)
        permitted = {grant.path: grant for grant in grants}
        files = {item.path: item for item in baseline.snapshot.manifest.files}
        originals = {item.path: item for item in baseline.snapshot.artifacts}
        policy = PathPolicy(
            baseline.snapshot.profile,
            workspace_root=baseline.workspace_root,
            metadata=baseline.inspect,
        )
        if invocation is not None and (
            invocation.baseline.sha256 != baseline.snapshot.sha256
            or invocation.workspace.get("workspace_root") != baseline.workspace_root
        ):
            raise MutationError("MUTATION_CONTEXT", "Invocation baseline/workspace differs")
        writes: list[PlannedWrite] = []
        # Exact trusted grants and original-byte preconditions precede any projection.
        for change in changes:
            grant = permitted.get(change.path)
            if grant is None or grant != WriteGrant(
                artifact_kind=change.artifact_kind,
                artifact_id=change.artifact_id,
                path=change.path,
            ):
                raise MutationError("MUTATION_GRANT", "No exact kind/ID/path write grant")
            prior = files.get(change.path)
            if change.expected_sha256 != (prior.sha256 if prior else None):
                raise MutationError(
                    "MUTATION_PRECONDITION", "Original content digest differs"
                )
            original = originals.get(change.path)
            if original is not None and (
                original.expected_kind != change.artifact_kind
                or original.origin_path is not None
                or original.document is not None
                and original.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Existing artifact identity differs"
                )
            if len(change.content) > baseline.snapshot.profile.limits.document_bytes:
                raise MutationError(
                    "MUTATION_LIMIT", "Proposed content exceeds document limit"
                )
            writes.append(
                PlannedWrite(
                    change=change,
                    target=policy.resolve_write(change.path, grant=grant),
                    skipped=prior is not None and prior.content == change.content,
                )
            )
        prospective = project_snapshot(baseline, changes)
        artifacts = {item.path: item for item in prospective.artifacts}
        # Loader-derived kinds and document IDs must agree with granted output identities.
        for change in changes:
            artifact = artifacts.get(change.path)
            if change.artifact_kind not in {"evidence-payload", "acceptance-view"} and (
                artifact is None
                or artifact.expected_kind != change.artifact_kind
                or artifact.document is None
                or artifact.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Proposed artifact kind/ID differs"
                )
        validation = validate_snapshot(
            prospective,
>           mode="agent-output" if invocation else "structural",
            invocation=invocation,
        )
E       drm_copilot_discovery.mutation_plan.MutationError: MUTATION_INVALID: Prospective graph is invalid

packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py:339: MutationError
_ test_stale_complete_inputs_and_parent_changes_block_before_writes[addition] _

race = 'addition'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize(
        "race", ["bytes", "addition", "deletion", "identity", "parent", "collision"]
    )
    def test_stale_complete_inputs_and_parent_changes_block_before_writes(
        race: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """The complete read set detects changes beyond the destination's own digest."""
        store, baseline = mutation_case(mutation_catalog)
        store.put("src/a.py", b"original")
        baseline = writer_baseline = capture(store, mutation_catalog)
        change = collection_change(baseline)
>       plan = plan_mutation(baseline, (change,), grants=grants_for(change))
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_commit.py:168:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

baseline = CapturedWorkspace(workspace_root='/workspace', snapshot=DiscoverySnapshot(profile=ProfileV2(document=JsonObject(member...ace/src/a.py', children=())), ('tests', PathMetadata(kind='missing', identity=None, resolved_path=None, children=()))))
changes = (MutationChange(artifact_kind='unspecified-behavior-collection', artifact_id='questions', path='docs/migration/discove...kind": "unspecified-behavior-collection", "id": "questions", "records": [], "extensions": {}}', expected_sha256=None),)

            ),
        )


    def plan_mutation(
        baseline: CapturedWorkspace,
        changes: tuple[MutationChange, ...],
        *,
        grants: tuple[WriteGrant, ...],
        invocation: InvocationContext | None = None,
    ) -> MutationPlan:
        """Validate all prospective bytes before returning an immutable commit plan.

        Grants and optional native invocation must be authenticated by the caller.
        Absence of invocation is the explicit local-user/root route, not an analyst
        fallback. Invalid requests raise MutationError/ValueError/OSError; no writes
        or authority-store operations occur, including during repeated dry runs.
        """
        if not changes or len(changes) > baseline.snapshot.profile.limits.artifact_records:
            raise MutationError("MUTATION_LIMIT", "Provide a bounded nonempty change set")
        changes = tuple(sorted(changes, key=lambda item: item.path))
        check_path_collisions(item.path for item in changes)
        check_path_collisions(grant.path for grant in grants)
        permitted = {grant.path: grant for grant in grants}
        files = {item.path: item for item in baseline.snapshot.manifest.files}
        originals = {item.path: item for item in baseline.snapshot.artifacts}
        policy = PathPolicy(
            baseline.snapshot.profile,
            workspace_root=baseline.workspace_root,
            metadata=baseline.inspect,
        )
        if invocation is not None and (
            invocation.baseline.sha256 != baseline.snapshot.sha256
            or invocation.workspace.get("workspace_root") != baseline.workspace_root
        ):
            raise MutationError("MUTATION_CONTEXT", "Invocation baseline/workspace differs")
        writes: list[PlannedWrite] = []
        # Exact trusted grants and original-byte preconditions precede any projection.
        for change in changes:
            grant = permitted.get(change.path)
            if grant is None or grant != WriteGrant(
                artifact_kind=change.artifact_kind,
                artifact_id=change.artifact_id,
                path=change.path,
            ):
                raise MutationError("MUTATION_GRANT", "No exact kind/ID/path write grant")
            prior = files.get(change.path)
            if change.expected_sha256 != (prior.sha256 if prior else None):
                raise MutationError(
                    "MUTATION_PRECONDITION", "Original content digest differs"
                )
            original = originals.get(change.path)
            if original is not None and (
                original.expected_kind != change.artifact_kind
                or original.origin_path is not None
                or original.document is not None
                and original.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Existing artifact identity differs"
                )
            if len(change.content) > baseline.snapshot.profile.limits.document_bytes:
                raise MutationError(
                    "MUTATION_LIMIT", "Proposed content exceeds document limit"
                )
            writes.append(
                PlannedWrite(
                    change=change,
                    target=policy.resolve_write(change.path, grant=grant),
                    skipped=prior is not None and prior.content == change.content,
                )
            )
        prospective = project_snapshot(baseline, changes)
        artifacts = {item.path: item for item in prospective.artifacts}
        # Loader-derived kinds and document IDs must agree with granted output identities.
        for change in changes:
            artifact = artifacts.get(change.path)
            if change.artifact_kind not in {"evidence-payload", "acceptance-view"} and (
                artifact is None
                or artifact.expected_kind != change.artifact_kind
                or artifact.document is None
                or artifact.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Proposed artifact kind/ID differs"
                )
        validation = validate_snapshot(
            prospective,
>           mode="agent-output" if invocation else "structural",
            invocation=invocation,
        )
E       drm_copilot_discovery.mutation_plan.MutationError: MUTATION_INVALID: Prospective graph is invalid

packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py:339: MutationError
_ test_stale_complete_inputs_and_parent_changes_block_before_writes[deletion] _

race = 'deletion'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize(
        "race", ["bytes", "addition", "deletion", "identity", "parent", "collision"]
    )
    def test_stale_complete_inputs_and_parent_changes_block_before_writes(
        race: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """The complete read set detects changes beyond the destination's own digest."""
        store, baseline = mutation_case(mutation_catalog)
        store.put("src/a.py", b"original")
        baseline = writer_baseline = capture(store, mutation_catalog)
        change = collection_change(baseline)
>       plan = plan_mutation(baseline, (change,), grants=grants_for(change))
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_commit.py:168:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

baseline = CapturedWorkspace(workspace_root='/workspace', snapshot=DiscoverySnapshot(profile=ProfileV2(document=JsonObject(member...ace/src/a.py', children=())), ('tests', PathMetadata(kind='missing', identity=None, resolved_path=None, children=()))))
changes = (MutationChange(artifact_kind='unspecified-behavior-collection', artifact_id='questions', path='docs/migration/discove...kind": "unspecified-behavior-collection", "id": "questions", "records": [], "extensions": {}}', expected_sha256=None),)

            ),
        )


    def plan_mutation(
        baseline: CapturedWorkspace,
        changes: tuple[MutationChange, ...],
        *,
        grants: tuple[WriteGrant, ...],
        invocation: InvocationContext | None = None,
    ) -> MutationPlan:
        """Validate all prospective bytes before returning an immutable commit plan.

        Grants and optional native invocation must be authenticated by the caller.
        Absence of invocation is the explicit local-user/root route, not an analyst
        fallback. Invalid requests raise MutationError/ValueError/OSError; no writes
        or authority-store operations occur, including during repeated dry runs.
        """
        if not changes or len(changes) > baseline.snapshot.profile.limits.artifact_records:
            raise MutationError("MUTATION_LIMIT", "Provide a bounded nonempty change set")
        changes = tuple(sorted(changes, key=lambda item: item.path))
        check_path_collisions(item.path for item in changes)
        check_path_collisions(grant.path for grant in grants)
        permitted = {grant.path: grant for grant in grants}
        files = {item.path: item for item in baseline.snapshot.manifest.files}
        originals = {item.path: item for item in baseline.snapshot.artifacts}
        policy = PathPolicy(
            baseline.snapshot.profile,
            workspace_root=baseline.workspace_root,
            metadata=baseline.inspect,
        )
        if invocation is not None and (
            invocation.baseline.sha256 != baseline.snapshot.sha256
            or invocation.workspace.get("workspace_root") != baseline.workspace_root
        ):
            raise MutationError("MUTATION_CONTEXT", "Invocation baseline/workspace differs")
        writes: list[PlannedWrite] = []
        # Exact trusted grants and original-byte preconditions precede any projection.
        for change in changes:
            grant = permitted.get(change.path)
            if grant is None or grant != WriteGrant(
                artifact_kind=change.artifact_kind,
                artifact_id=change.artifact_id,
                path=change.path,
            ):
                raise MutationError("MUTATION_GRANT", "No exact kind/ID/path write grant")
            prior = files.get(change.path)
            if change.expected_sha256 != (prior.sha256 if prior else None):
                raise MutationError(
                    "MUTATION_PRECONDITION", "Original content digest differs"
                )
            original = originals.get(change.path)
            if original is not None and (
                original.expected_kind != change.artifact_kind
                or original.origin_path is not None
                or original.document is not None
                and original.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Existing artifact identity differs"
                )
            if len(change.content) > baseline.snapshot.profile.limits.document_bytes:
                raise MutationError(
                    "MUTATION_LIMIT", "Proposed content exceeds document limit"
                )
            writes.append(
                PlannedWrite(
                    change=change,
                    target=policy.resolve_write(change.path, grant=grant),
                    skipped=prior is not None and prior.content == change.content,
                )
            )
        prospective = project_snapshot(baseline, changes)
        artifacts = {item.path: item for item in prospective.artifacts}
        # Loader-derived kinds and document IDs must agree with granted output identities.
        for change in changes:
            artifact = artifacts.get(change.path)
            if change.artifact_kind not in {"evidence-payload", "acceptance-view"} and (
                artifact is None
                or artifact.expected_kind != change.artifact_kind
                or artifact.document is None
                or artifact.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Proposed artifact kind/ID differs"
                )
        validation = validate_snapshot(
            prospective,
>           mode="agent-output" if invocation else "structural",
            invocation=invocation,
        )
E       drm_copilot_discovery.mutation_plan.MutationError: MUTATION_INVALID: Prospective graph is invalid

packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py:339: MutationError
_ test_stale_complete_inputs_and_parent_changes_block_before_writes[identity] _

race = 'identity'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize(
        "race", ["bytes", "addition", "deletion", "identity", "parent", "collision"]
    )
    def test_stale_complete_inputs_and_parent_changes_block_before_writes(
        race: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """The complete read set detects changes beyond the destination's own digest."""
        store, baseline = mutation_case(mutation_catalog)
        store.put("src/a.py", b"original")
        baseline = writer_baseline = capture(store, mutation_catalog)
        change = collection_change(baseline)
>       plan = plan_mutation(baseline, (change,), grants=grants_for(change))
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_commit.py:168:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

baseline = CapturedWorkspace(workspace_root='/workspace', snapshot=DiscoverySnapshot(profile=ProfileV2(document=JsonObject(member...ace/src/a.py', children=())), ('tests', PathMetadata(kind='missing', identity=None, resolved_path=None, children=()))))
changes = (MutationChange(artifact_kind='unspecified-behavior-collection', artifact_id='questions', path='docs/migration/discove...kind": "unspecified-behavior-collection", "id": "questions", "records": [], "extensions": {}}', expected_sha256=None),)

            ),
        )


    def plan_mutation(
        baseline: CapturedWorkspace,
        changes: tuple[MutationChange, ...],
        *,
        grants: tuple[WriteGrant, ...],
        invocation: InvocationContext | None = None,
    ) -> MutationPlan:
        """Validate all prospective bytes before returning an immutable commit plan.

        Grants and optional native invocation must be authenticated by the caller.
        Absence of invocation is the explicit local-user/root route, not an analyst
        fallback. Invalid requests raise MutationError/ValueError/OSError; no writes
        or authority-store operations occur, including during repeated dry runs.
        """
        if not changes or len(changes) > baseline.snapshot.profile.limits.artifact_records:
            raise MutationError("MUTATION_LIMIT", "Provide a bounded nonempty change set")
        changes = tuple(sorted(changes, key=lambda item: item.path))
        check_path_collisions(item.path for item in changes)
        check_path_collisions(grant.path for grant in grants)
        permitted = {grant.path: grant for grant in grants}
        files = {item.path: item for item in baseline.snapshot.manifest.files}
        originals = {item.path: item for item in baseline.snapshot.artifacts}
        policy = PathPolicy(
            baseline.snapshot.profile,
            workspace_root=baseline.workspace_root,
            metadata=baseline.inspect,
        )
        if invocation is not None and (
            invocation.baseline.sha256 != baseline.snapshot.sha256
            or invocation.workspace.get("workspace_root") != baseline.workspace_root
        ):
            raise MutationError("MUTATION_CONTEXT", "Invocation baseline/workspace differs")
        writes: list[PlannedWrite] = []
        # Exact trusted grants and original-byte preconditions precede any projection.
        for change in changes:
            grant = permitted.get(change.path)
            if grant is None or grant != WriteGrant(
                artifact_kind=change.artifact_kind,
                artifact_id=change.artifact_id,
                path=change.path,
            ):
                raise MutationError("MUTATION_GRANT", "No exact kind/ID/path write grant")
            prior = files.get(change.path)
            if change.expected_sha256 != (prior.sha256 if prior else None):
                raise MutationError(
                    "MUTATION_PRECONDITION", "Original content digest differs"
                )
            original = originals.get(change.path)
            if original is not None and (
                original.expected_kind != change.artifact_kind
                or original.origin_path is not None
                or original.document is not None
                and original.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Existing artifact identity differs"
                )
            if len(change.content) > baseline.snapshot.profile.limits.document_bytes:
                raise MutationError(
                    "MUTATION_LIMIT", "Proposed content exceeds document limit"
                )
            writes.append(
                PlannedWrite(
                    change=change,
                    target=policy.resolve_write(change.path, grant=grant),
                    skipped=prior is not None and prior.content == change.content,
                )
            )
        prospective = project_snapshot(baseline, changes)
        artifacts = {item.path: item for item in prospective.artifacts}
        # Loader-derived kinds and document IDs must agree with granted output identities.
        for change in changes:
            artifact = artifacts.get(change.path)
            if change.artifact_kind not in {"evidence-payload", "acceptance-view"} and (
                artifact is None
                or artifact.expected_kind != change.artifact_kind
                or artifact.document is None
                or artifact.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Proposed artifact kind/ID differs"
                )
        validation = validate_snapshot(
            prospective,
>           mode="agent-output" if invocation else "structural",
            invocation=invocation,
        )
E       drm_copilot_discovery.mutation_plan.MutationError: MUTATION_INVALID: Prospective graph is invalid

packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py:339: MutationError
__ test_stale_complete_inputs_and_parent_changes_block_before_writes[parent] __

race = 'parent'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize(
        "race", ["bytes", "addition", "deletion", "identity", "parent", "collision"]
    )
    def test_stale_complete_inputs_and_parent_changes_block_before_writes(
        race: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """The complete read set detects changes beyond the destination's own digest."""
        store, baseline = mutation_case(mutation_catalog)
        store.put("src/a.py", b"original")
        baseline = writer_baseline = capture(store, mutation_catalog)
        change = collection_change(baseline)
>       plan = plan_mutation(baseline, (change,), grants=grants_for(change))
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_commit.py:168:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

baseline = CapturedWorkspace(workspace_root='/workspace', snapshot=DiscoverySnapshot(profile=ProfileV2(document=JsonObject(member...ace/src/a.py', children=())), ('tests', PathMetadata(kind='missing', identity=None, resolved_path=None, children=()))))
changes = (MutationChange(artifact_kind='unspecified-behavior-collection', artifact_id='questions', path='docs/migration/discove...kind": "unspecified-behavior-collection", "id": "questions", "records": [], "extensions": {}}', expected_sha256=None),)

            ),
        )


    def plan_mutation(
        baseline: CapturedWorkspace,
        changes: tuple[MutationChange, ...],
        *,
        grants: tuple[WriteGrant, ...],
        invocation: InvocationContext | None = None,
    ) -> MutationPlan:
        """Validate all prospective bytes before returning an immutable commit plan.

        Grants and optional native invocation must be authenticated by the caller.
        Absence of invocation is the explicit local-user/root route, not an analyst
        fallback. Invalid requests raise MutationError/ValueError/OSError; no writes
        or authority-store operations occur, including during repeated dry runs.
        """
        if not changes or len(changes) > baseline.snapshot.profile.limits.artifact_records:
            raise MutationError("MUTATION_LIMIT", "Provide a bounded nonempty change set")
        changes = tuple(sorted(changes, key=lambda item: item.path))
        check_path_collisions(item.path for item in changes)
        check_path_collisions(grant.path for grant in grants)
        permitted = {grant.path: grant for grant in grants}
        files = {item.path: item for item in baseline.snapshot.manifest.files}
        originals = {item.path: item for item in baseline.snapshot.artifacts}
        policy = PathPolicy(
            baseline.snapshot.profile,
            workspace_root=baseline.workspace_root,
            metadata=baseline.inspect,
        )
        if invocation is not None and (
            invocation.baseline.sha256 != baseline.snapshot.sha256
            or invocation.workspace.get("workspace_root") != baseline.workspace_root
        ):
            raise MutationError("MUTATION_CONTEXT", "Invocation baseline/workspace differs")
        writes: list[PlannedWrite] = []
        # Exact trusted grants and original-byte preconditions precede any projection.
        for change in changes:
            grant = permitted.get(change.path)
            if grant is None or grant != WriteGrant(
                artifact_kind=change.artifact_kind,
                artifact_id=change.artifact_id,
                path=change.path,
            ):
                raise MutationError("MUTATION_GRANT", "No exact kind/ID/path write grant")
            prior = files.get(change.path)
            if change.expected_sha256 != (prior.sha256 if prior else None):
                raise MutationError(
                    "MUTATION_PRECONDITION", "Original content digest differs"
                )
            original = originals.get(change.path)
            if original is not None and (
                original.expected_kind != change.artifact_kind
                or original.origin_path is not None
                or original.document is not None
                and original.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Existing artifact identity differs"
                )
            if len(change.content) > baseline.snapshot.profile.limits.document_bytes:
                raise MutationError(
                    "MUTATION_LIMIT", "Proposed content exceeds document limit"
                )
            writes.append(
                PlannedWrite(
                    change=change,
                    target=policy.resolve_write(change.path, grant=grant),
                    skipped=prior is not None and prior.content == change.content,
                )
            )
        prospective = project_snapshot(baseline, changes)
        artifacts = {item.path: item for item in prospective.artifacts}
        # Loader-derived kinds and document IDs must agree with granted output identities.
        for change in changes:
            artifact = artifacts.get(change.path)
            if change.artifact_kind not in {"evidence-payload", "acceptance-view"} and (
                artifact is None
                or artifact.expected_kind != change.artifact_kind
                or artifact.document is None
                or artifact.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Proposed artifact kind/ID differs"
                )
        validation = validate_snapshot(
            prospective,
>           mode="agent-output" if invocation else "structural",
            invocation=invocation,
        )
E       drm_copilot_discovery.mutation_plan.MutationError: MUTATION_INVALID: Prospective graph is invalid

packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py:339: MutationError
_ test_stale_complete_inputs_and_parent_changes_block_before_writes[collision] _

race = 'collision'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize(
        "race", ["bytes", "addition", "deletion", "identity", "parent", "collision"]
    )
    def test_stale_complete_inputs_and_parent_changes_block_before_writes(
        race: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """The complete read set detects changes beyond the destination's own digest."""
        store, baseline = mutation_case(mutation_catalog)
        store.put("src/a.py", b"original")
        baseline = writer_baseline = capture(store, mutation_catalog)
        change = collection_change(baseline)
>       plan = plan_mutation(baseline, (change,), grants=grants_for(change))
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_mutation_commit.py:168:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

baseline = CapturedWorkspace(workspace_root='/workspace', snapshot=DiscoverySnapshot(profile=ProfileV2(document=JsonObject(member...ace/src/a.py', children=())), ('tests', PathMetadata(kind='missing', identity=None, resolved_path=None, children=()))))
changes = (MutationChange(artifact_kind='unspecified-behavior-collection', artifact_id='questions', path='docs/migration/discove...kind": "unspecified-behavior-collection", "id": "questions", "records": [], "extensions": {}}', expected_sha256=None),)

            ),
        )


    def plan_mutation(
        baseline: CapturedWorkspace,
        changes: tuple[MutationChange, ...],
        *,
        grants: tuple[WriteGrant, ...],
        invocation: InvocationContext | None = None,
    ) -> MutationPlan:
        """Validate all prospective bytes before returning an immutable commit plan.

        Grants and optional native invocation must be authenticated by the caller.
        Absence of invocation is the explicit local-user/root route, not an analyst
        fallback. Invalid requests raise MutationError/ValueError/OSError; no writes
        or authority-store operations occur, including during repeated dry runs.
        """
        if not changes or len(changes) > baseline.snapshot.profile.limits.artifact_records:
            raise MutationError("MUTATION_LIMIT", "Provide a bounded nonempty change set")
        changes = tuple(sorted(changes, key=lambda item: item.path))
        check_path_collisions(item.path for item in changes)
        check_path_collisions(grant.path for grant in grants)
        permitted = {grant.path: grant for grant in grants}
        files = {item.path: item for item in baseline.snapshot.manifest.files}
        originals = {item.path: item for item in baseline.snapshot.artifacts}
        policy = PathPolicy(
            baseline.snapshot.profile,
            workspace_root=baseline.workspace_root,
            metadata=baseline.inspect,
        )
        if invocation is not None and (
            invocation.baseline.sha256 != baseline.snapshot.sha256
            or invocation.workspace.get("workspace_root") != baseline.workspace_root
        ):
            raise MutationError("MUTATION_CONTEXT", "Invocation baseline/workspace differs")
        writes: list[PlannedWrite] = []
        # Exact trusted grants and original-byte preconditions precede any projection.
        for change in changes:
            grant = permitted.get(change.path)
            if grant is None or grant != WriteGrant(
                artifact_kind=change.artifact_kind,
                artifact_id=change.artifact_id,
                path=change.path,
            ):
                raise MutationError("MUTATION_GRANT", "No exact kind/ID/path write grant")
            prior = files.get(change.path)
            if change.expected_sha256 != (prior.sha256 if prior else None):
                raise MutationError(
                    "MUTATION_PRECONDITION", "Original content digest differs"
                )
            original = originals.get(change.path)
            if original is not None and (
                original.expected_kind != change.artifact_kind
                or original.origin_path is not None
                or original.document is not None
                and original.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Existing artifact identity differs"
                )
            if len(change.content) > baseline.snapshot.profile.limits.document_bytes:
                raise MutationError(
                    "MUTATION_LIMIT", "Proposed content exceeds document limit"
                )
            writes.append(
                PlannedWrite(
                    change=change,
                    target=policy.resolve_write(change.path, grant=grant),
                    skipped=prior is not None and prior.content == change.content,
                )
            )
        prospective = project_snapshot(baseline, changes)
        artifacts = {item.path: item for item in prospective.artifacts}
        # Loader-derived kinds and document IDs must agree with granted output identities.
        for change in changes:
            artifact = artifacts.get(change.path)
            if change.artifact_kind not in {"evidence-payload", "acceptance-view"} and (
                artifact is None
                or artifact.expected_kind != change.artifact_kind
                or artifact.document is None
                or artifact.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Proposed artifact kind/ID differs"
                )
        validation = validate_snapshot(
            prospective,
>           mode="agent-output" if invocation else "structural",
            invocation=invocation,
        )
E       drm_copilot_discovery.mutation_plan.MutationError: MUTATION_INVALID: Prospective graph is invalid

packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py:339: MutationError
______ test_unexpected_adapter_side_effects_cannot_report_success[bytes] ______

effect = 'bytes'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize("effect", ["bytes", "identity"])
    def test_unexpected_adapter_side_effects_cannot_report_success(
        effect: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """Postchecks detect unrelated content and same-byte identity changes."""
        store, _ = mutation_case(mutation_catalog)
        store.put("src/a.py", b"original")
        baseline = capture(store, mutation_catalog)
        change = collection_change(baseline)
        writer = MemoryWriter(store, mutation_catalog)

        def disturb() -> None:
            """Inject one explicit nonconforming adapter side effect in memory."""
            if effect == "bytes":
                store.files["src/a.py"] = b"unexpected"
            else:
                store.metadata.entries["src/a.py"] = replace(
                    store.metadata.entries["src/a.py"], identity="unexpected"
                )

        writer.after_write = disturb
        result = commit_mutation(
>           plan_mutation(baseline, (change,), grants=grants_for(change)), writer=writer
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        )

tests\discovery_runtime\test_mutation_commit.py:253:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

baseline = CapturedWorkspace(workspace_root='/workspace', snapshot=DiscoverySnapshot(profile=ProfileV2(document=JsonObject(member...ace/src/a.py', children=())), ('tests', PathMetadata(kind='missing', identity=None, resolved_path=None, children=()))))
changes = (MutationChange(artifact_kind='unspecified-behavior-collection', artifact_id='questions', path='docs/migration/discove...kind": "unspecified-behavior-collection", "id": "questions", "records": [], "extensions": {}}', expected_sha256=None),)

            ),
        )


    def plan_mutation(
        baseline: CapturedWorkspace,
        changes: tuple[MutationChange, ...],
        *,
        grants: tuple[WriteGrant, ...],
        invocation: InvocationContext | None = None,
    ) -> MutationPlan:
        """Validate all prospective bytes before returning an immutable commit plan.

        Grants and optional native invocation must be authenticated by the caller.
        Absence of invocation is the explicit local-user/root route, not an analyst
        fallback. Invalid requests raise MutationError/ValueError/OSError; no writes
        or authority-store operations occur, including during repeated dry runs.
        """
        if not changes or len(changes) > baseline.snapshot.profile.limits.artifact_records:
            raise MutationError("MUTATION_LIMIT", "Provide a bounded nonempty change set")
        changes = tuple(sorted(changes, key=lambda item: item.path))
        check_path_collisions(item.path for item in changes)
        check_path_collisions(grant.path for grant in grants)
        permitted = {grant.path: grant for grant in grants}
        files = {item.path: item for item in baseline.snapshot.manifest.files}
        originals = {item.path: item for item in baseline.snapshot.artifacts}
        policy = PathPolicy(
            baseline.snapshot.profile,
            workspace_root=baseline.workspace_root,
            metadata=baseline.inspect,
        )
        if invocation is not None and (
            invocation.baseline.sha256 != baseline.snapshot.sha256
            or invocation.workspace.get("workspace_root") != baseline.workspace_root
        ):
            raise MutationError("MUTATION_CONTEXT", "Invocation baseline/workspace differs")
        writes: list[PlannedWrite] = []
        # Exact trusted grants and original-byte preconditions precede any projection.
        for change in changes:
            grant = permitted.get(change.path)
            if grant is None or grant != WriteGrant(
                artifact_kind=change.artifact_kind,
                artifact_id=change.artifact_id,
                path=change.path,
            ):
                raise MutationError("MUTATION_GRANT", "No exact kind/ID/path write grant")
            prior = files.get(change.path)
            if change.expected_sha256 != (prior.sha256 if prior else None):
                raise MutationError(
                    "MUTATION_PRECONDITION", "Original content digest differs"
                )
            original = originals.get(change.path)
            if original is not None and (
                original.expected_kind != change.artifact_kind
                or original.origin_path is not None
                or original.document is not None
                and original.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Existing artifact identity differs"
                )
            if len(change.content) > baseline.snapshot.profile.limits.document_bytes:
                raise MutationError(
                    "MUTATION_LIMIT", "Proposed content exceeds document limit"
                )
            writes.append(
                PlannedWrite(
                    change=change,
                    target=policy.resolve_write(change.path, grant=grant),
                    skipped=prior is not None and prior.content == change.content,
                )
            )
        prospective = project_snapshot(baseline, changes)
        artifacts = {item.path: item for item in prospective.artifacts}
        # Loader-derived kinds and document IDs must agree with granted output identities.
        for change in changes:
            artifact = artifacts.get(change.path)
            if change.artifact_kind not in {"evidence-payload", "acceptance-view"} and (
                artifact is None
                or artifact.expected_kind != change.artifact_kind
                or artifact.document is None
                or artifact.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Proposed artifact kind/ID differs"
                )
        validation = validate_snapshot(
            prospective,
>           mode="agent-output" if invocation else "structural",
            invocation=invocation,
        )
E       drm_copilot_discovery.mutation_plan.MutationError: MUTATION_INVALID: Prospective graph is invalid

packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py:339: MutationError
____ test_unexpected_adapter_side_effects_cannot_report_success[identity] _____

effect = 'identity'
mutation_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    @pytest.mark.parametrize("effect", ["bytes", "identity"])
    def test_unexpected_adapter_side_effects_cannot_report_success(
        effect: str, mutation_catalog: SchemaCatalog
    ) -> None:
        """Postchecks detect unrelated content and same-byte identity changes."""
        store, _ = mutation_case(mutation_catalog)
        store.put("src/a.py", b"original")
        baseline = capture(store, mutation_catalog)
        change = collection_change(baseline)
        writer = MemoryWriter(store, mutation_catalog)

        def disturb() -> None:
            """Inject one explicit nonconforming adapter side effect in memory."""
            if effect == "bytes":
                store.files["src/a.py"] = b"unexpected"
            else:
                store.metadata.entries["src/a.py"] = replace(
                    store.metadata.entries["src/a.py"], identity="unexpected"
                )

        writer.after_write = disturb
        result = commit_mutation(
>           plan_mutation(baseline, (change,), grants=grants_for(change)), writer=writer
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        )

tests\discovery_runtime\test_mutation_commit.py:253:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

baseline = CapturedWorkspace(workspace_root='/workspace', snapshot=DiscoverySnapshot(profile=ProfileV2(document=JsonObject(member...ace/src/a.py', children=())), ('tests', PathMetadata(kind='missing', identity=None, resolved_path=None, children=()))))
changes = (MutationChange(artifact_kind='unspecified-behavior-collection', artifact_id='questions', path='docs/migration/discove...kind": "unspecified-behavior-collection", "id": "questions", "records": [], "extensions": {}}', expected_sha256=None),)

            ),
        )


    def plan_mutation(
        baseline: CapturedWorkspace,
        changes: tuple[MutationChange, ...],
        *,
        grants: tuple[WriteGrant, ...],
        invocation: InvocationContext | None = None,
    ) -> MutationPlan:
        """Validate all prospective bytes before returning an immutable commit plan.

        Grants and optional native invocation must be authenticated by the caller.
        Absence of invocation is the explicit local-user/root route, not an analyst
        fallback. Invalid requests raise MutationError/ValueError/OSError; no writes
        or authority-store operations occur, including during repeated dry runs.
        """
        if not changes or len(changes) > baseline.snapshot.profile.limits.artifact_records:
            raise MutationError("MUTATION_LIMIT", "Provide a bounded nonempty change set")
        changes = tuple(sorted(changes, key=lambda item: item.path))
        check_path_collisions(item.path for item in changes)
        check_path_collisions(grant.path for grant in grants)
        permitted = {grant.path: grant for grant in grants}
        files = {item.path: item for item in baseline.snapshot.manifest.files}
        originals = {item.path: item for item in baseline.snapshot.artifacts}
        policy = PathPolicy(
            baseline.snapshot.profile,
            workspace_root=baseline.workspace_root,
            metadata=baseline.inspect,
        )
        if invocation is not None and (
            invocation.baseline.sha256 != baseline.snapshot.sha256
            or invocation.workspace.get("workspace_root") != baseline.workspace_root
        ):
            raise MutationError("MUTATION_CONTEXT", "Invocation baseline/workspace differs")
        writes: list[PlannedWrite] = []
        # Exact trusted grants and original-byte preconditions precede any projection.
        for change in changes:
            grant = permitted.get(change.path)
            if grant is None or grant != WriteGrant(
                artifact_kind=change.artifact_kind,
                artifact_id=change.artifact_id,
                path=change.path,
            ):
                raise MutationError("MUTATION_GRANT", "No exact kind/ID/path write grant")
            prior = files.get(change.path)
            if change.expected_sha256 != (prior.sha256 if prior else None):
                raise MutationError(
                    "MUTATION_PRECONDITION", "Original content digest differs"
                )
            original = originals.get(change.path)
            if original is not None and (
                original.expected_kind != change.artifact_kind
                or original.origin_path is not None
                or original.document is not None
                and original.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Existing artifact identity differs"
                )
            if len(change.content) > baseline.snapshot.profile.limits.document_bytes:
                raise MutationError(
                    "MUTATION_LIMIT", "Proposed content exceeds document limit"
                )
            writes.append(
                PlannedWrite(
                    change=change,
                    target=policy.resolve_write(change.path, grant=grant),
                    skipped=prior is not None and prior.content == change.content,
                )
            )
        prospective = project_snapshot(baseline, changes)
        artifacts = {item.path: item for item in prospective.artifacts}
        # Loader-derived kinds and document IDs must agree with granted output identities.
        for change in changes:
            artifact = artifacts.get(change.path)
            if change.artifact_kind not in {"evidence-payload", "acceptance-view"} and (
                artifact is None
                or artifact.expected_kind != change.artifact_kind
                or artifact.document is None
                or artifact.document.get("id") != change.artifact_id
            ):
                raise MutationError(
                    "MUTATION_IDENTITY", "Proposed artifact kind/ID differs"
                )
        validation = validate_snapshot(
            prospective,
>           mode="agent-output" if invocation else "structural",
            invocation=invocation,
        )
E       drm_copilot_discovery.mutation_plan.MutationError: MUTATION_INVALID: Prospective graph is invalid

packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py:339: MutationError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                    Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\mutation_io.py       131     60     32      8    47%   59-61, 65, 82-97, 121, 146-150, 155-156, 167-170, 182-185, 198-201, 213, 225-230, 238->245, 247, 249->251, 250, 282->291, 292, 297->309, 311, 313-315, 326-390
packages\discovery-runtime\src\drm_copilot_discovery\mutation_plan.py     144     14     54     13    82%   116, 123, 156, 160-162, 167-172, 223, 269->271, 282->287, 289->323, 297, 298->302, 312->316, 326->337, 328->326, 342->343, 342->348
-------------------------------------------------------------------------------------------------------------------
TOTAL                                                                     275     74     86     21    66%
Coverage JSON written to file SCRATCH/issue-980-p3t1-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_mutation_plan.py::test_role_output_uses_exact_accepted_validator[legacy-parity-analyst]
FAILED tests/discovery_runtime/test_mutation_plan.py::test_role_output_uses_exact_accepted_validator[runtime-characterization-analyst]
FAILED tests/discovery_runtime/test_mutation_plan.py::test_role_output_uses_exact_accepted_validator[requirements-reconciler]
FAILED tests/discovery_runtime/test_mutation_plan.py::test_role_mismatches_and_unrequested_changes_are_rejected[role]
FAILED tests/discovery_runtime/test_mutation_plan.py::test_role_mismatches_and_unrequested_changes_are_rejected[workspace]
FAILED tests/discovery_runtime/test_mutation_plan.py::test_role_mismatches_and_unrequested_changes_are_rejected[baseline]
FAILED tests/discovery_runtime/test_mutation_plan.py::test_role_mismatches_and_unrequested_changes_are_rejected[manifest]
FAILED tests/discovery_runtime/test_mutation_plan.py::test_role_mismatches_and_unrequested_changes_are_rejected[unrequested]
FAILED tests/discovery_runtime/test_mutation_plan.py::test_parser_findings_are_retained_in_graph_rejection
FAILED tests/discovery_runtime/test_mutation_commit.py::test_commit_creates_all_outputs_and_preserves_unrelated_bytes
FAILED tests/discovery_runtime/test_mutation_commit.py::test_repeatable_dry_run_has_no_writes_directories_or_revocations
FAILED tests/discovery_runtime/test_mutation_commit.py::test_stale_complete_inputs_and_parent_changes_block_before_writes[bytes]
FAILED tests/discovery_runtime/test_mutation_commit.py::test_stale_complete_inputs_and_parent_changes_block_before_writes[addition]
FAILED tests/discovery_runtime/test_mutation_commit.py::test_stale_complete_inputs_and_parent_changes_block_before_writes[deletion]
FAILED tests/discovery_runtime/test_mutation_commit.py::test_stale_complete_inputs_and_parent_changes_block_before_writes[identity]
FAILED tests/discovery_runtime/test_mutation_commit.py::test_stale_complete_inputs_and_parent_changes_block_before_writes[parent]
FAILED tests/discovery_runtime/test_mutation_commit.py::test_stale_complete_inputs_and_parent_changes_block_before_writes[collision]
FAILED tests/discovery_runtime/test_mutation_commit.py::test_unexpected_adapter_side_effects_cannot_report_success[bytes]
FAILED tests/discovery_runtime/test_mutation_commit.py::test_unexpected_adapter_side_effects_cannot_report_success[identity]
19 failed, 25 passed in 317.50s (0:05:17)
```
