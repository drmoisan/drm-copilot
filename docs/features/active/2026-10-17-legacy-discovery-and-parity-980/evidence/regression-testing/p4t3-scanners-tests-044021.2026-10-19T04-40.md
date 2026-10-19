# P4-T3 scanners tests

Timestamp: 2026-10-19T04-40
Command: `poetry run python -m pytest -q -o addopts= tests/discovery_runtime/analyzer/test_csharp_declarations.py tests/discovery_runtime/analyzer/test_event_subscriptions.py tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py --cov=drm_copilot_discovery.analyzer.csharp_declarations --cov=drm_copilot_discovery.analyzer.event_subscriptions --cov=drm_copilot_discovery.analyzer.dotnet_inventory --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH\p4t3-scanners-coverage.raw.json`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
...................F.................................................... [ 68%]
.................................                                        [100%]
================================== FAILURES ===================================
_____ test_non_declaration_fragments_do_not_invent_names[delegate* ptr;] ______

source = 'delegate* ptr;'

    @pytest.mark.parametrize(
        "source",
        [
            "",
            "namespace ;",
            "class ;",
            "event ;",
            "delegate (int a) {};",
            "var item = object.class;",
            "where T : class",
            "record;",
            "event Action",
            "delegate* ptr;",
            "}",
        ],
    )
    def test_non_declaration_fragments_do_not_invent_names(source: str) -> None:
        """Incomplete str source produces no invented declaration; assertions are pure."""
>       assert declaration_candidates("a.cs", source) == ()
E       AssertionError: assert (Detection(pa..._line', 1))),) == ()
E
E         Left contains one more item: Detection(path='a.cs', line=1, detection_kind='delegate', symbol='ptr', symbol_kind='delegate', extra=(('offset', 0), ('end_line', 1)))
E         Use -v to get more diff

tests\discovery_runtime\analyzer\test_csharp_declarations.py:149: AssertionError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                                   Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\csharp_declarations.py     155      6     90      7    95%   72->76, 215, 221, 223, 228, 264, 266
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dotnet_inventory.py        137      1     36      1    99%   182
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\event_subscriptions.py      43      0     26      0   100%
----------------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                                    335      7    152      8    97%
Coverage JSON written to file SCRATCH\p4t3-scanners-coverage.raw.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/analyzer/test_csharp_declarations.py::test_non_declaration_fragments_do_not_invent_names[delegate* ptr;]
1 failed, 104 passed in 15.35s

```
