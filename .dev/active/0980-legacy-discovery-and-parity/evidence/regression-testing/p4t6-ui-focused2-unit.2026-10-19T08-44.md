# p4t6-ui-focused2-unit

Timestamp: 2026-10-19T08-44
Command: poetry run pytest tests/discovery_runtime/analyzer/test_ui_callbacks.py tests/discovery_runtime/analyzer/test_ui_callback_limits.py -q -o addopts= --cov=drm_copilot_discovery.analyzer.ui_callbacks --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p4t6-ui-coverage.json
EXIT_CODE: 1
Output Summary: FAIL scoped UI stage unit; duration 42.861 seconds. Exact bytes and original command output are in the paired JSON.

```text
.................................................................FFF.... [ 67%]
..................................                                       [100%]
================================== FAILURES ===================================
___ test_repeated_and_multiline_elements_have_stable_containing_anchors[\n] ___

catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
ending = '\n'

    @pytest.mark.parametrize("ending", ("\n", "\r\n", "\r"))
    def test_repeated_and_multiline_elements_have_stable_containing_anchors(
        catalog: SchemaCatalog, ending: str
    ) -> None:
        """Use str physical ending and SchemaCatalog; retain exact bytes/occurrences."""
        data = markup(f'{ending}<Button{ending} Click="OnClick"/><Button Click="OnClick"/>')
        result = UiCallbackAnalyzer().analyze(capture(catalog, (("src/a.xaml", data),)))
        # Same-line duplicate handlers retain distinct containing-element identities.
        assert len({item["finding_id"] for item in result.findings}) == 3
>       assert cast("JsonObject", result.findings[1]["source"])["line_range"] == row(
            start=2, end=2
        )
E       AssertionError: assert JsonObject(me...('start', 3))) == JsonObject(me...('start', 2)))
E
E         Differing attributes:
E         ['members']
E
E         Drill down into differing attribute members:
E           members: (('end', 3), ('start', 3)) != (('end', 2), ('start', 2))
E           At index 0 diff: ('end', 3) != ('end', 2)
E           Use -v to get more diff
E         Use -v to get more diff

tests\discovery_runtime\analyzer\test_ui_callbacks.py:296: AssertionError
__ test_repeated_and_multiline_elements_have_stable_containing_anchors[\r\n] __

catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
ending = '\r\n'

    @pytest.mark.parametrize("ending", ("\n", "\r\n", "\r"))
    def test_repeated_and_multiline_elements_have_stable_containing_anchors(
        catalog: SchemaCatalog, ending: str
    ) -> None:
        """Use str physical ending and SchemaCatalog; retain exact bytes/occurrences."""
        data = markup(f'{ending}<Button{ending} Click="OnClick"/><Button Click="OnClick"/>')
        result = UiCallbackAnalyzer().analyze(capture(catalog, (("src/a.xaml", data),)))
        # Same-line duplicate handlers retain distinct containing-element identities.
        assert len({item["finding_id"] for item in result.findings}) == 3
>       assert cast("JsonObject", result.findings[1]["source"])["line_range"] == row(
            start=2, end=2
        )
E       AssertionError: assert JsonObject(me...('start', 3))) == JsonObject(me...('start', 2)))
E
E         Differing attributes:
E         ['members']
E
E         Drill down into differing attribute members:
E           members: (('end', 3), ('start', 3)) != (('end', 2), ('start', 2))
E           At index 0 diff: ('end', 3) != ('end', 2)
E           Use -v to get more diff
E         Use -v to get more diff

tests\discovery_runtime\analyzer\test_ui_callbacks.py:296: AssertionError
___ test_repeated_and_multiline_elements_have_stable_containing_anchors[\r] ___

catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
ending = '\r'

    @pytest.mark.parametrize("ending", ("\n", "\r\n", "\r"))
    def test_repeated_and_multiline_elements_have_stable_containing_anchors(
        catalog: SchemaCatalog, ending: str
    ) -> None:
        """Use str physical ending and SchemaCatalog; retain exact bytes/occurrences."""
        data = markup(f'{ending}<Button{ending} Click="OnClick"/><Button Click="OnClick"/>')
        result = UiCallbackAnalyzer().analyze(capture(catalog, (("src/a.xaml", data),)))
        # Same-line duplicate handlers retain distinct containing-element identities.
        assert len({item["finding_id"] for item in result.findings}) == 3
>       assert cast("JsonObject", result.findings[1]["source"])["line_range"] == row(
            start=2, end=2
        )
E       AssertionError: assert JsonObject(me...('start', 1))) == JsonObject(me...('start', 2)))
E
E         Differing attributes:
E         ['members']
E
E         Drill down into differing attribute members:
E           members: (('end', 1), ('start', 1)) != (('end', 2), ('start', 2))
E           At index 0 diff: ('end', 1) != ('end', 2)
E           Use -v to get more diff
E         Use -v to get more diff

tests\discovery_runtime\analyzer\test_ui_callbacks.py:296: AssertionError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                            Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\analyzer\ui_callbacks.py     164      0     58      0   100%
---------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                             164      0     58      0   100%
Coverage JSON written to file SCRATCH/issue-980-p4t6-ui-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_repeated_and_multiline_elements_have_stable_containing_anchors[\n]
FAILED tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_repeated_and_multiline_elements_have_stable_containing_anchors[\r\n]
FAILED tests/discovery_runtime/analyzer/test_ui_callbacks.py::test_repeated_and_multiline_elements_have_stable_containing_anchors[\r]
3 failed, 103 passed in 41.12s
```
