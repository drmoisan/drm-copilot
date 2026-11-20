Timestamp: 2026-10-20T15-06
Command: `.venv/Scripts/python.exe -m pytest -o addopts= tests/discovery_runtime/test_gateway.py tests/discovery_runtime/test_gateway_local.py tests/discovery_runtime/test_doctor.py --cov=drm_copilot_discovery.gateway --cov=drm_copilot_discovery.gateway_local --cov=drm_copilot_discovery.doctor --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\issue-980-p6t1-gateway-loop3-coverage.json`
EXIT_CODE: 1
Output Summary: loop3-tests; exit 1; elapsed 203.430 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 75 items

tests\discovery_runtime\test_gateway.py ................................ [ 42%]
......                                                                   [ 50%]
tests\discovery_runtime\test_gateway_local.py .......FFFFFFFF..........  [ 84%]
tests\discovery_runtime\test_doctor.py ............                      [100%]

================================== FAILURES ===================================
_________ test_request_markers_cannot_expand_local_authority[prepare] _________

config_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
marker = 'prepare'

    @pytest.mark.parametrize(
        "marker",
        ["invocation", "authorization", "mode", "workspace", "prepare", "finalize"],
    )
    def test_request_markers_cannot_expand_local_authority(
        config_catalog: SchemaCatalog,
        marker: str,
    ) -> None:
        """Opaque references and a substituted root cannot acquire local permissions."""
        case, local, _ = memory_io(config_catalog)
        request = doctor_request(case)
        if marker == "invocation":
            request = replace(request, invocation_ref="opaque-invocation-0001")
        elif marker == "authorization":
            request = replace(request, authorization_ref="opaque-authorization-0001")
        elif marker == "mode":
            request = replace(
                request,
                operation="inventory",
                mode="agent-output",
                invocation_ref="opaque-invocation-0001",
            )
        elif marker == "workspace":
            request = replace(request, workspace_root="/other-workspace")
        else:
>           request = replace(
                request,
                operation="prepare-agent" if marker == "prepare" else "finalize-agent",
            )

tests\discovery_runtime\test_gateway_local.py:137:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:15: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\service_contracts.py:163: in __post_init__
    check_request(self)
packages\discovery-runtime\src\drm_copilot_discovery\service_serialization.py:228: in check_request
    check_combinations(fields)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

fields = {'$schema': 'urn:drm-copilot:discovery:2.0.0:service-request', 'artifact_kind': 'service-request', 'authorization_ref': None, 'dry_run': False, ...}

    def check_combinations(fields: dict[str, object]) -> None:
        """Check bounded schema-shaped fields against the fixed operation matrix.

        Return None or raise fixed ValueError for foreign/missing inputs or invalid
        mode/format/flag/conditional combinations. The caller reserves flat-field
        traversal before this function. No callbacks, modules, authority, graph
        assessment or filesystem operations are selected or executed.
        """
        operation = cast("str", fields["operation"])
        mode = fields["mode"]
        inputs = cast("JsonObject", fields["inputs"])
        if type(operation) is not str or operation not in _INPUTS:
            raise ValueError("Service operation is unsupported")
        modes = ("structural",)
        # Root reports and protected role-aware operations have distinct mode sets.
        if operation in (*_REPORTS, "prepare-agent"):
            modes = _ROOT_MODES
        elif operation in _ROLE_AWARE:
            modes = ("structural", "agent-output")
        elif operation == "finalize-agent":
            modes = ("agent-output",)
        if mode not in modes or (
            mode == "agent-output" and fields["invocation_ref"] is None
        ):
            raise ValueError("Service operation does not accept the selected mode")
        if operation not in _REPORTS and fields["format"] != "json":
            raise ValueError("This operation requires JSON representation")
        if operation not in _PLANNABLE and (fields["dry_run"] or fields["write"]):
            raise ValueError("This operation does not support a publication plan")
        allowed = _INPUTS[operation]
        # Small fixed allowlists bound exact comparisons before the single index copy.
        if any(key not in allowed for key, _ in inputs.members):
            raise ValueError("Service operation contains inapplicable input fields")
        values: dict[str, object] = dict(inputs.members)
        required = _REQUIRED.get(operation, ())
        if operation.startswith("validate-") and allowed == ("artifact_path",):
            required = ("artifact_path",)
        if any(key not in values for key in required):
>           raise ValueError("Service operation requires additional input fields")
E           ValueError: Service operation requires additional input fields

packages\discovery-runtime\src\drm_copilot_discovery\service_request_rules.py:278: ValueError
________ test_request_markers_cannot_expand_local_authority[finalize] _________

config_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
marker = 'finalize'

    @pytest.mark.parametrize(
        "marker",
        ["invocation", "authorization", "mode", "workspace", "prepare", "finalize"],
    )
    def test_request_markers_cannot_expand_local_authority(
        config_catalog: SchemaCatalog,
        marker: str,
    ) -> None:
        """Opaque references and a substituted root cannot acquire local permissions."""
        case, local, _ = memory_io(config_catalog)
        request = doctor_request(case)
        if marker == "invocation":
            request = replace(request, invocation_ref="opaque-invocation-0001")
        elif marker == "authorization":
            request = replace(request, authorization_ref="opaque-authorization-0001")
        elif marker == "mode":
            request = replace(
                request,
                operation="inventory",
                mode="agent-output",
                invocation_ref="opaque-invocation-0001",
            )
        elif marker == "workspace":
            request = replace(request, workspace_root="/other-workspace")
        else:
>           request = replace(
                request,
                operation="prepare-agent" if marker == "prepare" else "finalize-agent",
            )

tests\discovery_runtime\test_gateway_local.py:137:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1596: in replace
    return _replace(obj, **changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^
..\..\..\AppData\Local\Programs\Python\Python313\Lib\dataclasses.py:1630: in _replace
    return self.__class__(**changes)
           ^^^^^^^^^^^^^^^^^^^^^^^^^
<string>:15: in __init__
    ???
packages\discovery-runtime\src\drm_copilot_discovery\service_contracts.py:163: in __post_init__
    check_request(self)
packages\discovery-runtime\src\drm_copilot_discovery\service_serialization.py:228: in check_request
    check_combinations(fields)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

fields = {'$schema': 'urn:drm-copilot:discovery:2.0.0:service-request', 'artifact_kind': 'service-request', 'authorization_ref': None, 'dry_run': False, ...}

    def check_combinations(fields: dict[str, object]) -> None:
        """Check bounded schema-shaped fields against the fixed operation matrix.

        Return None or raise fixed ValueError for foreign/missing inputs or invalid
        mode/format/flag/conditional combinations. The caller reserves flat-field
        traversal before this function. No callbacks, modules, authority, graph
        assessment or filesystem operations are selected or executed.
        """
        operation = cast("str", fields["operation"])
        mode = fields["mode"]
        inputs = cast("JsonObject", fields["inputs"])
        if type(operation) is not str or operation not in _INPUTS:
            raise ValueError("Service operation is unsupported")
        modes = ("structural",)
        # Root reports and protected role-aware operations have distinct mode sets.
        if operation in (*_REPORTS, "prepare-agent"):
            modes = _ROOT_MODES
        elif operation in _ROLE_AWARE:
            modes = ("structural", "agent-output")
        elif operation == "finalize-agent":
            modes = ("agent-output",)
        if mode not in modes or (
            mode == "agent-output" and fields["invocation_ref"] is None
        ):
>           raise ValueError("Service operation does not accept the selected mode")
E           ValueError: Service operation does not accept the selected mode

packages\discovery-runtime\src\drm_copilot_discovery\service_request_rules.py:264: ValueError
____________ test_cross_workspace_baseline_and_writer_are_rejected ____________

config_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_cross_workspace_baseline_and_writer_are_rejected(
        config_catalog: SchemaCatalog,
    ) -> None:
        """A capture from another root never enters authorization or mutation."""
        case, local, baseline = memory_io(config_catalog)
        foreign = replace(baseline, workspace_root="/other-workspace")
>       authority = local.authorize(doctor_request(case), baseline=baseline)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_gateway_local.py:153:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.gateway_local.LocalServiceIO object at 0x00000172365AF700>
request = ServiceRequest(id='doctor', request_id='request', operation='doctor', mode='structural', workspace_root='C:/workspace'... dry_run=False, write=False, format='json', inputs=JsonObject(members=()), invocation_ref=None, authorization_ref=None)

    def authorize(
        self, request: ServiceRequest, *, baseline: CapturedWorkspace | None
    ) -> ServiceAuthority:
        """Authenticate a parsed request against this explicit outer local principal.

        Return local authority with bounded exact read selection when needed.
        Host markers, substituted roots and cross-workspace captures raise
        PermissionError before source I/O. Core derives exact local write grants
        only from its accepted planned changes; this method grants no root wildcard.
        """
        if (
            request.invocation_ref is not None
            or request.authorization_ref is not None
            or request.mode == "agent-output"
            or request.operation in ("prepare-agent", "finalize-agent")
            or request.workspace_root not in (".", self.initialization.workspace_root)
            or (
                baseline is not None
                and baseline.workspace_root != self.initialization.workspace_root
            )
        ):
>           raise PermissionError("Request has no local-user authority")
E           PermissionError: Request has no local-user authority

packages\discovery-runtime\src\drm_copilot_discovery\gateway_local.py:106: PermissionError
__________ test_writer_recaptures_real_memory_state_and_invalidates ___________

config_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_writer_recaptures_real_memory_state_and_invalidates(
        config_catalog: SchemaCatalog,
    ) -> None:
        """The local adapter forwards actual capture and revocation calls."""
        case, local, baseline = memory_io(config_catalog)
>       authority = local.authorize(doctor_request(case), baseline=baseline)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_gateway_local.py:181:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.gateway_local.LocalServiceIO object at 0x0000017234821B00>
request = ServiceRequest(id='doctor', request_id='request', operation='doctor', mode='structural', workspace_root='C:/workspace'... dry_run=False, write=False, format='json', inputs=JsonObject(members=()), invocation_ref=None, authorization_ref=None)

    def authorize(
        self, request: ServiceRequest, *, baseline: CapturedWorkspace | None
    ) -> ServiceAuthority:
        """Authenticate a parsed request against this explicit outer local principal.

        Return local authority with bounded exact read selection when needed.
        Host markers, substituted roots and cross-workspace captures raise
        PermissionError before source I/O. Core derives exact local write grants
        only from its accepted planned changes; this method grants no root wildcard.
        """
        if (
            request.invocation_ref is not None
            or request.authorization_ref is not None
            or request.mode == "agent-output"
            or request.operation in ("prepare-agent", "finalize-agent")
            or request.workspace_root not in (".", self.initialization.workspace_root)
            or (
                baseline is not None
                and baseline.workspace_root != self.initialization.workspace_root
            )
        ):
>           raise PermissionError("Request has no local-user authority")
E           PermissionError: Request has no local-user authority

packages\discovery-runtime\src\drm_copilot_discovery\gateway_local.py:106: PermissionError
_______________ test_read_selection_is_exact_and_profile_scoped _______________

config_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_read_selection_is_exact_and_profile_scoped(
        config_catalog: SchemaCatalog,
    ) -> None:
        """Explicit local reads receive only the requested configured file grant."""
        case, local, baseline = memory_io(config_catalog)
        path = baseline.snapshot.profile.artifacts["profile"]
        request = replace(
            doctor_request(case),
            operation="read-source",
            inputs=JsonObject((("read_operation", "read"), ("paths", (path,)))),
        )

>       authority = local.authorize(request, baseline=baseline)
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_gateway_local.py:204:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.gateway_local.LocalServiceIO object at 0x00000172361A2EB0>
request = ServiceRequest(id='doctor', request_id='request', operation='read-source', mode='structural', workspace_root='C:/works...migration/discovery/domain-profile.yaml',)), ('read_operation', 'read'))), invocation_ref=None, authorization_ref=None)

    def authorize(
        self, request: ServiceRequest, *, baseline: CapturedWorkspace | None
    ) -> ServiceAuthority:
        """Authenticate a parsed request against this explicit outer local principal.

        Return local authority with bounded exact read selection when needed.
        Host markers, substituted roots and cross-workspace captures raise
        PermissionError before source I/O. Core derives exact local write grants
        only from its accepted planned changes; this method grants no root wildcard.
        """
        if (
            request.invocation_ref is not None
            or request.authorization_ref is not None
            or request.mode == "agent-output"
            or request.operation in ("prepare-agent", "finalize-agent")
            or request.workspace_root not in (".", self.initialization.workspace_root)
            or (
                baseline is not None
                and baseline.workspace_root != self.initialization.workspace_root
            )
        ):
>           raise PermissionError("Request has no local-user authority")
E           PermissionError: Request has no local-user authority

packages\discovery-runtime\src\drm_copilot_discovery\gateway_local.py:106: PermissionError
________ test_inventory_writer_preserves_exact_pinned_selection[False] ________

config_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
monkeypatch = <_pytest.monkeypatch.MonkeyPatch object at 0x0000017236530750>
mismatch = False

    @pytest.mark.parametrize("mismatch", [False, True])
    def test_inventory_writer_preserves_exact_pinned_selection(
        config_catalog: SchemaCatalog,
        monkeypatch: pytest.MonkeyPatch,
        mismatch: bool,
    ) -> None:
        """Inventory recapture uses the same reader and refuses unrelated extra objects."""
        repository = MemoryRepository()
        case, local, baseline = memory_io(config_catalog, repository=repository)
        pin = RepositoryFile(
            repository=RepositoryIdentity(id="consumer-repository", revision="a" * 40),
            path="application/one.py",
            content=b"one",
        )
        pinned = replace(
            baseline, snapshot=replace(baseline.snapshot, repository_files=(pin,))
        )
        observed: list[RepositoryReader] = []

        def recapture(**values: object) -> CapturedWorkspace:
            """Return the unchanged unaugmented capture and record selected reader."""
            assert values["repository"] is repository
            return baseline

        def augment(
            current: CapturedWorkspace, reader: RepositoryReader
        ) -> CapturedWorkspace:
            """Model only the accepted inventory source-pin transform."""
            assert current is baseline
            observed.append(reader)
            return baseline if mismatch else pinned

        monkeypatch.setattr(gateway_local, "capture_workspace", recapture)
        monkeypatch.setattr(
            "drm_copilot_discovery.analyzer.input_capture.pin_inventory_sources", augment
        )
        writer = local.writer(
>           pinned, authority=local.authorize(doctor_request(case), baseline=pinned)
                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        )

tests\discovery_runtime\test_gateway_local.py:249:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.gateway_local.LocalServiceIO object at 0x00000172364FC830>
request = ServiceRequest(id='doctor', request_id='request', operation='doctor', mode='structural', workspace_root='C:/workspace'... dry_run=False, write=False, format='json', inputs=JsonObject(members=()), invocation_ref=None, authorization_ref=None)

    def authorize(
        self, request: ServiceRequest, *, baseline: CapturedWorkspace | None
    ) -> ServiceAuthority:
        """Authenticate a parsed request against this explicit outer local principal.

        Return local authority with bounded exact read selection when needed.
        Host markers, substituted roots and cross-workspace captures raise
        PermissionError before source I/O. Core derives exact local write grants
        only from its accepted planned changes; this method grants no root wildcard.
        """
        if (
            request.invocation_ref is not None
            or request.authorization_ref is not None
            or request.mode == "agent-output"
            or request.operation in ("prepare-agent", "finalize-agent")
            or request.workspace_root not in (".", self.initialization.workspace_root)
            or (
                baseline is not None
                and baseline.workspace_root != self.initialization.workspace_root
            )
        ):
>           raise PermissionError("Request has no local-user authority")
E           PermissionError: Request has no local-user authority

packages\discovery-runtime\src\drm_copilot_discovery\gateway_local.py:106: PermissionError
________ test_inventory_writer_preserves_exact_pinned_selection[True] _________

config_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
monkeypatch = <_pytest.monkeypatch.MonkeyPatch object at 0x0000017234823930>
mismatch = True

    @pytest.mark.parametrize("mismatch", [False, True])
    def test_inventory_writer_preserves_exact_pinned_selection(
        config_catalog: SchemaCatalog,
        monkeypatch: pytest.MonkeyPatch,
        mismatch: bool,
    ) -> None:
        """Inventory recapture uses the same reader and refuses unrelated extra objects."""
        repository = MemoryRepository()
        case, local, baseline = memory_io(config_catalog, repository=repository)
        pin = RepositoryFile(
            repository=RepositoryIdentity(id="consumer-repository", revision="a" * 40),
            path="application/one.py",
            content=b"one",
        )
        pinned = replace(
            baseline, snapshot=replace(baseline.snapshot, repository_files=(pin,))
        )
        observed: list[RepositoryReader] = []

        def recapture(**values: object) -> CapturedWorkspace:
            """Return the unchanged unaugmented capture and record selected reader."""
            assert values["repository"] is repository
            return baseline

        def augment(
            current: CapturedWorkspace, reader: RepositoryReader
        ) -> CapturedWorkspace:
            """Model only the accepted inventory source-pin transform."""
            assert current is baseline
            observed.append(reader)
            return baseline if mismatch else pinned

        monkeypatch.setattr(gateway_local, "capture_workspace", recapture)
        monkeypatch.setattr(
            "drm_copilot_discovery.analyzer.input_capture.pin_inventory_sources", augment
        )
        writer = local.writer(
>           pinned, authority=local.authorize(doctor_request(case), baseline=pinned)
                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        )

tests\discovery_runtime\test_gateway_local.py:249:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.gateway_local.LocalServiceIO object at 0x0000017234F608A0>
request = ServiceRequest(id='doctor', request_id='request', operation='doctor', mode='structural', workspace_root='C:/workspace'... dry_run=False, write=False, format='json', inputs=JsonObject(members=()), invocation_ref=None, authorization_ref=None)

    def authorize(
        self, request: ServiceRequest, *, baseline: CapturedWorkspace | None
    ) -> ServiceAuthority:
        """Authenticate a parsed request against this explicit outer local principal.

        Return local authority with bounded exact read selection when needed.
        Host markers, substituted roots and cross-workspace captures raise
        PermissionError before source I/O. Core derives exact local write grants
        only from its accepted planned changes; this method grants no root wildcard.
        """
        if (
            request.invocation_ref is not None
            or request.authorization_ref is not None
            or request.mode == "agent-output"
            or request.operation in ("prepare-agent", "finalize-agent")
            or request.workspace_root not in (".", self.initialization.workspace_root)
            or (
                baseline is not None
                and baseline.workspace_root != self.initialization.workspace_root
            )
        ):
>           raise PermissionError("Request has no local-user authority")
E           PermissionError: Request has no local-user authority

packages\discovery-runtime\src\drm_copilot_discovery\gateway_local.py:106: PermissionError
_____________ test_extra_pins_require_the_bound_repository_reader _____________

config_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())

    def test_extra_pins_require_the_bound_repository_reader(
        config_catalog: SchemaCatalog,
    ) -> None:
        """A missing reader cannot be replaced by a working-tree or caller source."""
        case, local, baseline = memory_io(config_catalog)
        pin = RepositoryFile(
            repository=RepositoryIdentity(id="consumer-repository", revision="a" * 40),
            path="application/one.py",
            content=b"one",
        )
        pinned = replace(
            baseline, snapshot=replace(baseline.snapshot, repository_files=(pin,))
        )
        writer = local.writer(
>           pinned, authority=local.authorize(doctor_request(case), baseline=pinned)
                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        )

tests\discovery_runtime\test_gateway_local.py:274:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <drm_copilot_discovery.gateway_local.LocalServiceIO object at 0x00000172364FEE40>
request = ServiceRequest(id='doctor', request_id='request', operation='doctor', mode='structural', workspace_root='C:/workspace'... dry_run=False, write=False, format='json', inputs=JsonObject(members=()), invocation_ref=None, authorization_ref=None)

    def authorize(
        self, request: ServiceRequest, *, baseline: CapturedWorkspace | None
    ) -> ServiceAuthority:
        """Authenticate a parsed request against this explicit outer local principal.

        Return local authority with bounded exact read selection when needed.
        Host markers, substituted roots and cross-workspace captures raise
        PermissionError before source I/O. Core derives exact local write grants
        only from its accepted planned changes; this method grants no root wildcard.
        """
        if (
            request.invocation_ref is not None
            or request.authorization_ref is not None
            or request.mode == "agent-output"
            or request.operation in ("prepare-agent", "finalize-agent")
            or request.workspace_root not in (".", self.initialization.workspace_root)
            or (
                baseline is not None
                and baseline.workspace_root != self.initialization.workspace_root
            )
        ):
>           raise PermissionError("Request has no local-user authority")
E           PermissionError: Request has no local-user authority

packages\discovery-runtime\src\drm_copilot_discovery\gateway_local.py:106: PermissionError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                    Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\doctor.py             65      3     26      4    92%   52, 64, 74->79, 78
packages\discovery-runtime\src\drm_copilot_discovery\gateway.py           105      4     26      1    96%   63-65, 256, 271
packages\discovery-runtime\src\drm_copilot_discovery\gateway_local.py      96     28     30      1    66%   107-127, 138-145, 153-186
-------------------------------------------------------------------------------------------------------------------
TOTAL                                                                     266     35     82      6    84%
Coverage JSON written to file SCRATCH\issue-980-p6t1-gateway-loop3-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_gateway_local.py::test_request_markers_cannot_expand_local_authority[prepare]
FAILED tests/discovery_runtime/test_gateway_local.py::test_request_markers_cannot_expand_local_authority[finalize]
FAILED tests/discovery_runtime/test_gateway_local.py::test_cross_workspace_baseline_and_writer_are_rejected
FAILED tests/discovery_runtime/test_gateway_local.py::test_writer_recaptures_real_memory_state_and_invalidates
FAILED tests/discovery_runtime/test_gateway_local.py::test_read_selection_is_exact_and_profile_scoped
FAILED tests/discovery_runtime/test_gateway_local.py::test_inventory_writer_preserves_exact_pinned_selection[False]
FAILED tests/discovery_runtime/test_gateway_local.py::test_inventory_writer_preserves_exact_pinned_selection[True]
FAILED tests/discovery_runtime/test_gateway_local.py::test_extra_pins_require_the_bound_repository_reader
================== 8 failed, 67 passed in 202.15s (0:03:22) ===================

```
