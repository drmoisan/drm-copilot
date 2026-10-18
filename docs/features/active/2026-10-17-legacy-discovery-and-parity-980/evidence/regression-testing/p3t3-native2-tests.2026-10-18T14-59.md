# p3t3-native2-tests

Timestamp: 2026-10-18T14-59
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_activation_filesystem.py tests/discovery_runtime/test_configuration.py::test_invalid_protected_fields_fail_closed tests/discovery_runtime/test_activation_store.py::test_configuration_conflicts_are_rejected_before_lock_or_revocation tests/discovery_runtime/test_activation_store.py::test_guarded_input_changes_abort_before_protected_publication tests/discovery_runtime/test_activation_store.py::test_physical_substitutions_after_activation_intent_fail_explicitly tests/discovery_runtime/test_activation_store.py::test_postpublication_changes_invalidate_configuration_success tests/discovery_runtime/test_activation_store.py::test_inactive_selection_rejects_a_concurrent_protected_record_change -x -q --durations=8 --cov=drm_copilot_discovery.configuration --cov=drm_copilot_discovery.activation_store --cov=drm_copilot_discovery.activation_filesystem --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-980-p3t3-native2-coverage.json --junitxml=SCRATCH/issue-980-p3t3-native2-tests.xml
EXIT_CODE: 1
Output Summary: =========================== short test summary info ===========================; FAILED tests/discovery_runtime/test_activation_store.py::test_postpublication_changes_invalidate_configuration_success[candidate]; !!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!; 1 failed, 45 passed in 11.15s

Working directory: .
Started: 2026-10-18T14:59:35.504491+00:00
Duration seconds: 12.359
Phase: P3-T3 configuration and activation; focused task verification.

## Captured output

```text
.............................................F
================================== FAILURES ===================================
__ test_postpublication_changes_invalidate_configuration_success[candidate] ___

config_catalog = SchemaCatalog(documents=(('schemas/discovery/v1/coverage-ledger.schema.json', JsonObject(members=(('$defs', JsonObject...'issued_at', 'writer')), ('title', 'Discovery v2 protected validation receipt'), ('type', 'object'))))), extensions=())
change = 'candidate'
monkeypatch = <_pytest.monkeypatch.MonkeyPatch object at 0x000001D3B4BD3700>

    @pytest.mark.parametrize("change", ["parent", "bytes", "candidate"])
    def test_postpublication_changes_invalidate_configuration_success(
        config_catalog: SchemaCatalog, change: str, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Retained parent identities and exact final bytes both bind successful output."""
        case = ConfigurationCase(config_catalog)
        alternate = "docs/alternate.yaml"
        case.service.candidate_paths = (DEFAULT_PROFILE, alternate)
        original = case.service.primitives.create_exclusive

        def publish(target: ResolvedPath, content: bytes) -> None:
            """Inject an observed external edit after the final atomic publication."""
            original(target, content)
            if target.path == LOCATOR_PATH:
                if change == "parent":
                    case.disk.store.metadata.add(
                        "docs", kind="directory", identity="changed"
                    )
                elif change == "bytes":
                    case.disk.store.put(LOCATOR_PATH, b"changed")
                else:
                    case.disk.store.put(alternate, profile_bytes(alternate))

        monkeypatch.setattr(case.service.primitives, "create_exclusive", publish)
        result = case.service.configure(
            ConfigurationRequest(action="activate", profile_bytes=profile_bytes())
        )
>       assert not result.ok and result.authority_invalidated
E       AssertionError: assert (not True)
E        +  where True = ConfigurationResult(ok=True, action='activate', changed=('protected-activation', 'docs/migration', 'docs/migration/dis...scovery/domain-profile.yaml', 'config', 'config/discovery.json'), uncertain=(), authority_invalidated=True, error=None).ok

tests\discovery_runtime\test_activation_store.py:451: AssertionError
============================= slowest 8 durations =============================
0.84s call     tests/discovery_runtime/test_activation_store.py::test_guarded_input_changes_abort_before_protected_publication[candidate]
0.74s call     tests/discovery_runtime/test_activation_store.py::test_physical_substitutions_after_activation_intent_fail_explicitly[root]
0.74s call     tests/discovery_runtime/test_activation_store.py::test_physical_substitutions_after_activation_intent_fail_explicitly[parent]
0.73s call     tests/discovery_runtime/test_activation_store.py::test_guarded_input_changes_abort_before_protected_publication[bytes]
0.71s call     tests/discovery_runtime/test_activation_store.py::test_guarded_input_changes_abort_before_protected_publication[parent]
0.71s call     tests/discovery_runtime/test_activation_store.py::test_configuration_conflicts_are_rejected_before_lock_or_revocation[candidate]
0.70s call     tests/discovery_runtime/test_activation_store.py::test_postpublication_changes_invalidate_configuration_success[candidate]
0.70s call     tests/discovery_runtime/test_activation_store.py::test_physical_substitutions_after_activation_intent_fail_explicitly[opened-parent]
=========================== short test summary info ===========================
FAILED tests/discovery_runtime/test_activation_store.py::test_postpublication_changes_invalidate_configuration_success[candidate]
!!!!!!!!!!!!!!!!!!!!!!!!!! stopping after 1 failures !!!!!!!!!!!!!!!!!!!!!!!!!!
1 failed, 45 passed in 11.15s
```
