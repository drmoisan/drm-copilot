# p3t2-callable-diagnostic

Timestamp: 2026-10-18T13-48
Command: poetry run python SCRATCH/issue-980-p3t2-units.py targeted12 -o addopts=-ra tests/discovery_runtime/test_initialization.py -k commit_failure_dispositions or capture_rechecks_physical -x -q --durations=5 --cov=drm_copilot_discovery.init_flow --cov=drm_copilot_discovery.init_io --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p3t2-callable-diagnostic-coverage.json --cov-fail-under=0
EXIT_CODE: 1
Output Summary: FAILED tests/discovery_runtime/test_initialization.py::test_commit_failure_dispositions_preserve_guarded_boundary[reconstruction]; !!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!; 1 failed, 26 deselected in 12.84s; SOURCE_BINDING_STABLE: True

Working directory: .
Started: 2026-10-18T13:48:23.849065+00:00
Duration seconds: 14.091
Phase: P3-T2 safe draft initialization; focused task verification.

## Captured output

```text
PYTEST_ARGUMENTS: ["-o", "addopts=-ra", "tests/discovery_runtime/test_initialization.py", "-k", "commit_failure_dispositions or capture_rechecks_physical", "-x", "-q", "--durations=5", "--cov=drm_copilot_discovery.init_flow", "--cov=drm_copilot_discovery.init_io", "--cov-branch", "--cov-report=term-missing", "--cov-report=json:SCRATCH/issue-980-p3t2-callable-diagnostic-coverage.json", "--cov-fail-under=0"]
F
================================== FAILURES ===================================
_ test_commit_failure_dispositions_preserve_guarded_boundary[reconstruction] __

initialization_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
initialization_plan = InitializationPlan(request=InitializationRequest(system_id='consumer-system', system_name='Consumer system', role='leg...ation_result='pass', output_valid=None, role=None, invocation_id=None, required_outputs_sha256=None), invocation=None))
monkeypatch = <_pytest.monkeypatch.MonkeyPatch object at 0x000001E0744602B0>
failure = 'reconstruction'

    @pytest.mark.parametrize(
        "failure", ["reconstruction", "bootstrap", "graph", "revocation"]
    )
    def test_commit_failure_dispositions_preserve_guarded_boundary(
        initialization_catalog: SchemaCatalog,
        initialization_plan: InitializationPlan,
        monkeypatch: pytest.MonkeyPatch,
        failure: str,
    ) -> None:
        """Inject failed stage results to verify orchestration without repeating I/O."""
        case, plan = InitializationCase(initialization_catalog), initialization_plan
        accepted = plan.capture.proposal_base
        monkeypatch.setattr(
            "drm_copilot_discovery.init_flow.plan_initialization", constant(plan)
        )
        bootstrap = BootstrapResult(
            ok=failure != "bootstrap",
            created=(),
            uncertain=("docs/uncertain",) if failure == "bootstrap" else (),
            authority_invalidated=failure != "revocation",
            error="bootstrap interrupted" if failure == "bootstrap" else None,
            physical=accepted,
        )
        monkeypatch.setattr(case.io, "bootstrap", constant(bootstrap))
        monkeypatch.setattr(case.io, "physical_capture", constant(accepted))
        monkeypatch.setattr(
            "drm_copilot_discovery.init_flow.plan_mutation",
            constant(replace(plan.mutation, prospective=accepted.snapshot)),
        )
        # Each case fails at its named stage before ordinary artifact publication.
        if failure in {"reconstruction", "revocation"}:
            plan = replace(plan, directories=plan.directories + ("unconfigured",))
        if failure == "revocation":

            def fail_revoke() -> None:
                """Expose invalidation failure without granting a completed result."""
                raise OSError("protected state unavailable")

            case.io.invalidate_authority = fail_revoke

>       result = commit_initialization(plan, io=case.io)
                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

tests\discovery_runtime\test_initialization.py:388:
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:257: in commit_initialization
    outputs = _outputs(plan)
              ^^^^^^^^^^^^^^
packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:217: in _outputs
    outputs.extend(
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

.0 = <list_iterator object at 0x000001E074436350>

    outputs.extend(
        InitializationOutput(
            path=path,
            kind="directory",
>           status="planned" if physical[path].kind == "missing" else "skipped",
                                ^^^^^^^^^^^^^^
        )
        for path in sorted(directories)
    )
E   KeyError: 'unconfigured'

packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:221: KeyError
============================= slowest 5 durations =============================
12.62s setup    tests/discovery_runtime/test_initialization.py::test_commit_failure_dispositions_preserve_guarded_boundary[reconstruction]

(2 durations < 0.005s hidden.  Use -vv to show these durations.)
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_initialization.py::test_commit_failure_dispositions_preserve_guarded_boundary[reconstruction]
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
1 failed, 26 deselected in 12.84s
SOURCE_BINDING_STABLE: True
```
