# p2t9-pass5-tests

Timestamp: 2026-10-18T10-44
Command: poetry run pytest tests/discovery_runtime/test_validation_modes.py tests/discovery_runtime/test_completion_rules.py tests/discovery_runtime/test_agent_output.py -q -o addopts=-ra --cov=drm_copilot_discovery.validation --cov=drm_copilot_discovery.validation_inputs --cov=drm_copilot_discovery.completion_rules --cov=drm_copilot_discovery.agent_output --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p2t9-coverage.json
EXIT_CODE: 1
Output Summary: Coverage JSON written to file SCRATCH/issue-980-p2t9-coverage.json; =========================== short test summary info ===========================; FAILED tests/discovery_runtime/test_completion_rules.py::test_full_repository_pins_are_core_completion_preconditions[no-target-COMPLETION_TARGET]; 1 failed, 104 passed in 374.46s (0:06:14)

Working directory: .
Started: 2026-10-18T10:38:22.379562+00:00
Duration seconds: 375.714
Phase: P2-T9 validation composition and role outputs; focused task verification.

## Captured output

```text
........................................F............................... [ 68%]
.................................                                        [100%]
================================== FAILURES ===================================
_ test_full_repository_pins_are_core_completion_preconditions[no-target-COMPLETION_TARGET] _

snapshot_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
case = 'no-target', expected = 'COMPLETION_TARGET'

    @pytest.mark.parametrize(
        "case,expected",
        [
            ("draft", "COMPLETION_PROFILE"),
            ("source-pin", "COMPLETION_SOURCE"),
            ("target-pin", "COMPLETION_TARGET"),
            ("no-source", "COMPLETION_SOURCE"),
            ("no-target", "COMPLETION_TARGET"),
        ],
    )
    def test_full_repository_pins_are_core_completion_preconditions(
        snapshot_catalog: SchemaCatalog, case: str, expected: str
    ) -> None:
        """Completion never derives source or target identity from the current HEAD."""
        profile = policy_profile(snapshot_catalog)
        if case in {"draft", "source-pin", "target-pin"}:
            value = as_object(to_plain_value(profile.document["repository"]))
            value["revision"] = None
            profile = profile_with(
                profile, snapshot_catalog, repository=value, profile_state="draft"
            )
        else:
            system = as_object(to_plain_value(profile.document["system"]))
            system["role"] = (
                "modernization-target" if case == "no-source" else "legacy-source"
            )
>           profile = profile_with(profile, snapshot_catalog, system=system)
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_completion_rules.py:156:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
tests\discovery_runtime\test_coverage_scope.py:46: in profile_with
    return ProfileV2(json.dumps(value), format="json", catalog=catalog)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = <[AttributeError("'ProfileV2' object has no attribute 'document'") raised in repr()] ProfileV2 object at 0x288772f6cb0>
content = '{"$schema": "urn:drm-copilot:discovery:2.0.0:domain-profile", "analyzers": {"enabled": ["repository", "dotnet", "depe...: {"id": "processing-example", "name": "Example processing system", "role": "legacy-source"}, "test_roots": ["tests"]}'

    def __init__(
        self,
        content: bytes | str,
        *,
        format: Literal["json", "yaml"] = "yaml",
        catalog: SchemaCatalog | None = None,
        limits: ParseLimits | None = None,
    ) -> None:
        """Reject malformed configuration before publishing any typed section."""
        catalog = catalog if catalog is not None else load_catalog()
        result = validate_document(
            content,
            expected_kind="domain-profile",
            expected_version="2.0.0",
            format=format,
            catalog=catalog,
            limits=limits,
        )
        if not result.ok or result.document is None:
            raise ProfileError(result.findings)
        findings = _binding_findings(result.document, catalog)
        if findings:
>           raise ProfileError(findings)
E           drm_copilot_discovery.profile_v2.ProfileError: /clients/0/target_repository: Unknown target repository: workspace-example

packages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py:178: ProfileError
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                        Stmts   Miss Branch BrPart  Cover   Missing
-----------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\agent_output.py          140      1     68      1    99%   196
packages\discovery-runtime\src\drm_copilot_discovery\completion_rules.py       72      0     46      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\validation.py            133      2     42      2    98%   172, 178
packages\discovery-runtime\src\drm_copilot_discovery\validation_inputs.py      51      0     22      0   100%
-----------------------------------------------------------------------------------------------------------------------
TOTAL                                                                         396      3    178      3    99%
Coverage JSON written to file SCRATCH/issue-980-p2t9-coverage.json
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_completion_rules.py::test_full_repository_pins_are_core_completion_preconditions[no-target-COMPLETION_TARGET]
1 failed, 104 passed in 374.46s (0:06:14)
```
