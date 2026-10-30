Timestamp: 2026-10-20T16-14
Command: `.venv/Scripts/python.exe -m pytest -o addopts= tests/discovery_runtime/test_gateway_boundaries.py`
EXIT_CODE: 1
Output Summary: repair5-prechecks; exit 1; elapsed 1.873 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 12 items

tests\discovery_runtime\test_gateway_boundaries.py .......FF...          [100%]

================================== FAILURES ===================================
_ test_doctor_reserves_path_text_before_measurement_or_observation[False-False] _

config_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
monkeypatch = <_pytest.monkeypatch.MonkeyPatch object at 0x000001D2C11215E0>
selected = False, ample = False

    @pytest.mark.parametrize("selected", [False, True])
    @pytest.mark.parametrize("ample", [False, True])
    def test_doctor_reserves_path_text_before_measurement_or_observation(
        config_catalog: SchemaCatalog,
        monkeypatch: pytest.MonkeyPatch,
        selected: bool,
        ample: bool,
    ) -> None:
        """Reject the original 4095-character path before excess text work.

        config_catalog (SchemaCatalog) is immutable; monkeypatch (pytest.MonkeyPatch)
        restores counters/policy; selected (bool) uses an explicit profile; ample
        (bool) chooses sufficient work. Return None; assertions check actual input
        retention and no effects. Only the in-memory doctor composition runs.
        """
        case = ConfigurationCase(config_catalog)
        long_path = "/".join(("x" * 127,) * 32)
        case.service.candidate_paths = () if selected else (long_path,)
        measurements: list[int] = []
        original = ReportBudget.text

        def measured(self: ReportBudget, value: str) -> None:
            """Measure value (str) with the real budget and record long-path visits.

            Return None; budget errors propagate. Only counters and the test list
            change; observation occurs before any possible native I/O.
            """
            if value == long_path:
                measurements.append(self.work_left)
            original(self, value)

        monkeypatch.setattr(ReportBudget, "text", measured)
        monkeypatch.setattr(
            "drm_copilot_discovery.doctor.ParseLimits",
            lambda: ParseLimits(
                document_bytes=8192, artifact_records=10000 if ample else 32
            ),
        )
        ports = LocalServiceIO(
            activation=case.service,
            repository=None,
            principal="local-user",
            author_id="test-user",
            identity=lambda: IDENTITY,
        )

        result = inspect_doctor(
            io=ports,
            request=doctor_request(case, long_path if selected else None),
            runtime=IDENTITY,
        )

        assert result.input_manifest is not None
        assert (
            not case.disk.store.calls and not case.registry.writes and not case.revocations
        )
        if ample:
            assert measurements and result.exit_code == (2 if selected else 0)
            assert result.input_manifest.missing_paths == (LOCATOR_PATH, long_path)
        else:
            assert result.exit_code == 3 and not measurements
            assert result.input_manifest.missing_paths == ()
        assert result.summary["receipt_ref"] is None
>       assert result.findings[-1].code == "DISCOVERY_ENFORCEMENT_UNAVAILABLE"
E       AssertionError: assert 'DOCTOR_IO' == 'DISCOVERY_EN...T_UNAVAILABLE'
E
E         - DISCOVERY_ENFORCEMENT_UNAVAILABLE
E         + DOCTOR_IO

tests\discovery_runtime\test_gateway_boundaries.py:256: AssertionError
_ test_doctor_reserves_path_text_before_measurement_or_observation[False-True] _

config_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
monkeypatch = <_pytest.monkeypatch.MonkeyPatch object at 0x000001D2C0F2BC50>
selected = True, ample = False

    @pytest.mark.parametrize("selected", [False, True])
    @pytest.mark.parametrize("ample", [False, True])
    def test_doctor_reserves_path_text_before_measurement_or_observation(
        config_catalog: SchemaCatalog,
        monkeypatch: pytest.MonkeyPatch,
        selected: bool,
        ample: bool,
    ) -> None:
        """Reject the original 4095-character path before excess text work.

        config_catalog (SchemaCatalog) is immutable; monkeypatch (pytest.MonkeyPatch)
        restores counters/policy; selected (bool) uses an explicit profile; ample
        (bool) chooses sufficient work. Return None; assertions check actual input
        retention and no effects. Only the in-memory doctor composition runs.
        """
        case = ConfigurationCase(config_catalog)
        long_path = "/".join(("x" * 127,) * 32)
        case.service.candidate_paths = () if selected else (long_path,)
        measurements: list[int] = []
        original = ReportBudget.text

        def measured(self: ReportBudget, value: str) -> None:
            """Measure value (str) with the real budget and record long-path visits.

            Return None; budget errors propagate. Only counters and the test list
            change; observation occurs before any possible native I/O.
            """
            if value == long_path:
                measurements.append(self.work_left)
            original(self, value)

        monkeypatch.setattr(ReportBudget, "text", measured)
        monkeypatch.setattr(
            "drm_copilot_discovery.doctor.ParseLimits",
            lambda: ParseLimits(
                document_bytes=8192, artifact_records=10000 if ample else 32
            ),
        )
        ports = LocalServiceIO(
            activation=case.service,
            repository=None,
            principal="local-user",
            author_id="test-user",
            identity=lambda: IDENTITY,
        )

        result = inspect_doctor(
            io=ports,
            request=doctor_request(case, long_path if selected else None),
            runtime=IDENTITY,
        )

        assert result.input_manifest is not None
        assert (
            not case.disk.store.calls and not case.registry.writes and not case.revocations
        )
        if ample:
            assert measurements and result.exit_code == (2 if selected else 0)
            assert result.input_manifest.missing_paths == (LOCATOR_PATH, long_path)
        else:
>           assert result.exit_code == 3 and not measurements
E           AssertionError: assert (3 == 3 and not [6364476, 6400000])
E            +  where 3 = DiscoveryResult(operation='doctor', mode='structural', ok=False, exit_code=3, findings=(Finding(code='DISCOVERY_ENFORC...1111111111111111', policy_version=1, policy_sha256='2222222222222222222222222222222222222222222222222222222222222222')).exit_code

tests\discovery_runtime\test_gateway_boundaries.py:253: AssertionError
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_gateway_boundaries.py::test_doctor_reserves_path_text_before_measurement_or_observation[False-False]
FAILED tests/discovery_runtime/test_gateway_boundaries.py::test_doctor_reserves_path_text_before_measurement_or_observation[False-True]
======================== 2 failed, 10 passed in 1.46s =========================

```
