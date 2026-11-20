# p3t3-wip5-core-tests

Timestamp: 2026-10-18T14-46
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_activation_filesystem.py tests/discovery_runtime/test_configuration.py tests/discovery_runtime/test_activation_store.py -x -q --durations=10 --cov=drm_copilot_discovery.configuration --cov=drm_copilot_discovery.activation_store --cov=drm_copilot_discovery.activation_filesystem --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-980-p3t3-wip5-coverage.json --junitxml=SCRATCH/issue-980-p3t3-wip5-tests.xml
EXIT_CODE: 0
Output Summary: 1.46s call     tests/discovery_runtime/test_configuration.py::test_ambiguous_missing_or_changed_configuration_fails[internal-path]; 1.38s call     tests/discovery_runtime/test_activation_store.py::test_inactive_workspace_and_missing_registry_are_read_only; 1.34s call     tests/discovery_runtime/test_configuration.py::test_protected_matching_bytes_enable_selection_but_are_not_grants; 65 passed in 32.74s

Working directory: .
Started: 2026-10-18T14:46:02.587079+00:00
Duration seconds: 33.989
Phase: P3-T3 configuration and activation; focused task verification.

## Captured output

```text
.................................................................        [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                            Stmts   Miss Branch BrPart  Cover
-----------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\activation_filesystem.py     102     58     30      0    42%
packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py          160     20     58     11    84%
packages\discovery-runtime\src\drm_copilot_discovery\configuration.py             123      1     48      1    99%
-----------------------------------------------------------------------------------------------------------------
TOTAL                                                                             385     79    136     12    78%
Coverage JSON written to file SCRATCH/issue-980-p3t3-wip5-coverage.json
============================ slowest 10 durations =============================
3.60s call     tests/discovery_runtime/test_activation_store.py::test_activate_update_and_deactivate_preserve_exact_audit_chain[docs/custom/profile.yaml]
3.45s call     tests/discovery_runtime/test_activation_store.py::test_partial_activation_keeps_protected_gate_active_and_recovers
3.44s call     tests/discovery_runtime/test_activation_store.py::test_activate_update_and_deactivate_preserve_exact_audit_chain[docs/migration/discovery/domain-profile.yaml]
2.10s call     tests/discovery_runtime/test_activation_store.py::test_active_configuration_tampering_cannot_disable_gate[delete-profile]
2.03s call     tests/discovery_runtime/test_configuration.py::test_default_and_custom_selection_require_explicit_activation[docs/Custom Profile.yaml]
2.00s call     tests/discovery_runtime/test_activation_store.py::test_active_configuration_tampering_cannot_disable_gate[malformed-profile]
1.98s call     tests/discovery_runtime/test_configuration.py::test_default_and_custom_selection_require_explicit_activation[docs/migration/discovery/domain-profile.yaml]
1.46s call     tests/discovery_runtime/test_configuration.py::test_ambiguous_missing_or_changed_configuration_fails[internal-path]
1.38s call     tests/discovery_runtime/test_activation_store.py::test_inactive_workspace_and_missing_registry_are_read_only
1.34s call     tests/discovery_runtime/test_configuration.py::test_protected_matching_bytes_enable_selection_but_are_not_grants
65 passed in 32.74s
```
