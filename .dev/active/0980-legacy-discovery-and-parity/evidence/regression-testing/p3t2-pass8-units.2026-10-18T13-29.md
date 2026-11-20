# p3t2-pass8-units

Timestamp: 2026-10-18T13-29
Command: poetry run python SCRATCH/issue-980-p3t2-units.py forward -o addopts=-ra tests/scripts/dev_tools/discovery/test_init_flow.py tests/scripts/dev_tools/discovery/test_init_cli.py tests/scripts/dev_tools/discovery/test_init_models.py tests/scripts/dev_tools/discovery/test_domain_neutrality.py tests/discovery_runtime/test_initialization_conflicts.py tests/discovery_runtime/test_initialization.py -x -q --cov=drm_copilot_discovery.init_flow --cov=drm_copilot_discovery.init_io --cov=drm_copilot_discovery.init_projection --cov=scripts.dev_tools.discovery.init_flow --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t2-pass8-coverage.json --cov-fail-under=0
EXIT_CODE: 1
Output Summary: FAILED tests/discovery_runtime/test_initialization_conflicts.py::test_invalid_or_incompatible_existing_content_aborts_before_any_write[scope]; !!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!; 1 failed, 30 passed in 19.51s; SOURCE_BINDING_STABLE: True

Working directory: .
Started: 2026-10-18T13:29:10.698428+00:00
Duration seconds: 20.680
Phase: P3-T2 safe draft initialization; focused task verification.

## Captured output

```text
ORDER: cheap boundary and fixture cases first; all collected cases retained: 83
..............................F
================================== FAILURES ===================================
_ test_invalid_or_incompatible_existing_content_aborts_before_any_write[scope] _

initialization_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
initialization_plan = InitializationPlan(request=InitializationRequest(system_id='consumer-system', system_name='Consumer system', role='leg...ation_result='pass', output_valid=None, role=None, invocation_id=None, required_outputs_sha256=None), invocation=None))
initialization_templates = InitializationTemplates(documents=(('coverage-ledger.json', JsonObject(members=(('$schema', 'urn:drm-copilot:discovery... ('extensions', JsonObject(members=())), ('id', '{{unresolved_id}}'), ('records', ()), ('schema_version', '2.0.0'))))))
conflict = 'scope'

    @pytest.mark.parametrize(
        "conflict", ["profile", "scope", "identity", "directory", "unknown-artifact"]
    )
    def test_invalid_or_incompatible_existing_content_aborts_before_any_write(
        initialization_catalog: SchemaCatalog,
        initialization_plan: InitializationPlan,
        initialization_templates: InitializationTemplates,
        conflict: str,
    ) -> None:
        """
        Existing bad bytes remain visible; no profile/directory is created around them.
        """
        case, plan = InitializationCase(initialization_catalog), initialization_plan
        profile = plan.capture.proposal_base.snapshot.profile
        request = request_for()
        if conflict == "profile":
            case.disk.store.put(profile.artifacts["profile"], b"invalid: true")
        elif conflict == "scope":
            case.disk.store.put(profile.artifacts["scope"], b"invalid: true")
        elif conflict == "directory":
            case.disk.store.put(profile.artifacts["reports"], b"occupied directory")
        elif conflict == "unknown-artifact":
            case.disk.store.put(
                profile.artifacts["feature_contracts"] + "/wrong.yaml", b"invalid: true"
            )
        else:
            case.disk.store.put(profile.artifacts["profile"], plan.profile_bytes)
            request = replace(request, system_name="Different consumer")
        before = (dict(case.disk.store.files), dict(case.disk.store.metadata.entries))

        with pytest.raises(InitializationConflict) as caught:
>           initialize_workspace(
                request, io=case.io, templates=initialization_templates, force=True
            )

tests\discovery_runtime\test_initialization_conflicts.py:76:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:396: in initialize_workspace
    plan = plan_initialization(request, io=io, templates=templates)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:173: in plan_initialization
    return _plan_initialization(request, io=io, templates=templates)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:101: in _plan_initialization
    str(scope.document["id"])
        ^^^^^^^^^^^^^^^^^^^^
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

self = JsonObject(members=(('invalid', True),)), key = 'id'

    def __getitem__(self, key: str) -> JsonValue:
        """Find a member by exact case-sensitive key, raising KeyError if absent."""
        # Read only exact keys; case folding would change artifact identity.
        for name, value in self.members:
            if key == name:
                return value
>       raise KeyError(key)
E       KeyError: 'id'

packages\discovery-runtime\src\drm_copilot_discovery\models.py:65: KeyError
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_initialization_conflicts.py::test_invalid_or_incompatible_existing_content_aborts_before_any_write[scope]
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
1 failed, 30 passed in 19.51s
SOURCE_BINDING_STABLE: True
```
