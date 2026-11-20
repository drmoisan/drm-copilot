# P4-T4 repair-5 tests

Timestamp: 2026-10-19T06-25
Command: `poetry run python -m pytest -q -o addopts= tests/discovery_runtime/analyzer/test_configuration.py tests/discovery_runtime/analyzer/test_configuration_input.py --cov=drm_copilot_discovery.analyzer.configuration --cov=drm_copilot_discovery.analyzer.configuration_input --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p4t4-repair-5-coverage.raw.json`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
........................................................................ [ 80%]
.....F............                                                       [100%]
================================== FAILURES ===================================
____ test_inherited_ini_paths_cannot_exceed_accumulated_text_reservations _____

monkeypatch = <_pytest.monkeypatch.MonkeyPatch object at 0x00000121BB0209F0>

    def test_inherited_ini_paths_cannot_exceed_accumulated_text_reservations(
        monkeypatch: pytest.MonkeyPatch,
    ) -> None:
        """Patch fixture observes bounded INI pointer allocations across inherited keys.

        Returns None; count encoded prospective paths before the real helper runs,
        and require fixed failure with no returned partial declaration collection.
        """
        # Each individually small section inherits the same escaped Unicode default.
        content = (
            "[DEFAULT]\nΩ/~=VALUE_SENTINEL\n"
            + "\n".join("[" + "Section" * 8 + str(index) + "]" for index in range(8))
        ).encode()
        remaining = 12000
        created = 0
        original = child_pointer

        def bounded_pointer(parent: str, part: str | int) -> str:
            """Check str/int path arguments against byte budget; return real pointer.

            Mutates only counters; assertion fails before any prohibited allocation.
            """
            nonlocal remaining, created
            segment = str(part)
            cost = 12 * (
                len(parent) + 1 + len(segment) + segment.count("~") + segment.count("/")
            )
            assert cost <= remaining
            remaining -= cost
            created += 1
            return original(parent, part)

        monkeypatch.setattr(input_module, "child_pointer", bounded_pointer)
        with pytest.raises(ConfigurationInputError) as caught:
            parse_configuration(
                content, format="ini", max_bytes=8192, max_keys=100, max_text_bytes=12000
            )
>       assert caught.value.code == "configuration-text-limit" and created > 10
E       AssertionError: assert ('configuration-text-limit' == 'configuration-text-limit'
E
E           configuration-text-limit and 9 > 10)

tests\discovery_runtime\analyzer\test_configuration_input.py:241: AssertionError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                                   Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\configuration.py            89      2     32      1    98%   270-271
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\configuration_input.py     204      3     90      6    97%   199->222, 208->210, 216->222, 324, 382, 386
----------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                    293      5    122      7    97%
Coverage JSON written to file SCRATCH\p4t4-repair-5-coverage.raw.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/analyzer/test_configuration_input.py::test_inherited_ini_paths_cannot_exceed_accumulated_text_reservations
1 failed, 89 passed in 52.79s

```
