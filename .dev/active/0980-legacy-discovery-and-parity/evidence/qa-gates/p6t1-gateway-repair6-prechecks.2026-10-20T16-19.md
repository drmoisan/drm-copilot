Timestamp: 2026-10-20T16-19
Command: `.venv/Scripts/python.exe -m pytest -o addopts= tests/discovery_runtime/test_gateway_boundaries.py`
EXIT_CODE: 1
Output Summary: repair6-prechecks; exit 1; elapsed 1.883 seconds.

```text
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: WORKSPACE
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 12 items

tests\discovery_runtime\test_gateway_boundaries.py ..........F.          [100%]

================================== FAILURES ===================================
_ test_doctor_reserves_path_text_before_measurement_or_observation[True-True] _

config_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
monkeypatch = <_pytest.monkeypatch.MonkeyPatch object at 0x000001658D895550>
selected = True, ample = True

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
            if (
                value == long_path
                and self.limits.document_bytes == 8192
                and self.limits.artifact_records == (10000 if ample else 32)
            ):
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
>       assert result.findings[0].code == "DISCOVERY_ENFORCEMENT_UNAVAILABLE"
E       AssertionError: assert 'DOCTOR_CONFIGURATION' == 'DISCOVERY_EN...T_UNAVAILABLE'
E
E         - DISCOVERY_ENFORCEMENT_UNAVAILABLE
E         + DOCTOR_CONFIGURATION

tests\discovery_runtime\test_gateway_boundaries.py:260: AssertionError
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_gateway_boundaries.py::test_doctor_reserves_path_text_before_measurement_or_observation[True-True]
======================== 1 failed, 11 passed in 1.43s =========================

```
