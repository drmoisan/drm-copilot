# p2t7-tests-pass7

Timestamp: 2026-10-18T09-52
Command: poetry run pytest tests/discovery_runtime/test_dimension_rules.py tests/discovery_runtime/test_acceptance_rules.py tests/discovery_runtime/test_acceptance_scope.py -o addopts=-ra --cov=drm_copilot_discovery.dimension_rules --cov=drm_copilot_discovery.acceptance_rules --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p2t7-coverage.json -q
EXIT_CODE: 1
Output Summary: Coverage JSON written to file SCRATCH/issue-980-p2t7-coverage.json; =========================== short test summary info ===========================; FAILED tests/discovery_runtime/test_acceptance_rules.py::test_custom_required_coordinates_cannot_be_satisfied_by_a_different_tuple[required_platforms-value1]; 1 failed, 91 passed in 39.89s

Working directory: .
Started: 2026-10-18T09:52:13.685163+00:00
Duration seconds: 41.083
Phase: P2-T7 dimension and acceptance obligations; focused task verification.

## Captured output

```text
........................................................................ [ 78%]
F...................                                                     [100%]
================================== FAILURES ===================================
_ test_custom_required_coordinates_cannot_be_satisfied_by_a_different_tuple[required_platforms-value1] _

snapshot_profile = ProfileV2(document=JsonObject(members=(('$schema', 'urn:drm-copilot:discovery:2.0.0:domain-profile'), ('analyzers', Js...rocessing-example'), ('name', 'Example processing system'), ('role', 'legacy-source')))), ('test_roots', ('tests',)))))
snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
axis = 'required_platforms', value = ['satellite']

    @pytest.mark.parametrize(
        "axis,value",
        [("required_modes", ["online", "batch"]), ("required_platforms", ["satellite"])],
    )
    def test_custom_required_coordinates_cannot_be_satisfied_by_a_different_tuple(
        snapshot_profile: ProfileV2,
        snapshot_catalog: SchemaCatalog,
        axis: str,
        value: list[str],
    ) -> None:
        """Explicit custom platform/mode coordinates participate in scenario accounting."""
        profile = profile_with(snapshot_profile, snapshot_catalog, **{axis: value})
        result = validate_acceptance(
            acceptance_graph(profile, snapshot_catalog), complete=True
        )
>       assert any(f.code == "ACCEPTANCE_REQUIRED" for f in result.findings)
E       assert False
E        +  where False = any(<generator object test_custom_required_coordinates_cannot_be_satisfied_by_a_different_tuple.<locals>.<genexpr> at 0x00000209AF166E90>)

tests\discovery_runtime\test_acceptance_rules.py:345: AssertionError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                       Stmts   Miss Branch BrPart  Cover   Missing
----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\acceptance_rules.py     151      3     76      4    97%   169, 265, 286, 293->292
packages\discovery-runtime\src\drm_copilot_discovery\dimension_rules.py       98      1     32      1    98%   142
----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                        249      4    108      5    97%
Coverage JSON written to file SCRATCH/issue-980-p2t7-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_acceptance_rules.py::test_custom_required_coordinates_cannot_be_satisfied_by_a_different_tuple[required_platforms-value1]
1 failed, 91 passed in 39.89s
```
