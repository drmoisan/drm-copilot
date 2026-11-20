# p3t3-pass1-tests

Timestamp: 2026-10-18T15-04
Command: poetry run python SCRATCH/issue-980-p3t3-tests.py pass1
EXIT_CODE: 0
Output Summary: 1.41s call     tests/discovery_runtime/test_configuration.py::test_protected_matching_bytes_enable_selection_but_are_not_grants; 1.39s call     tests/discovery_runtime/test_configuration.py::test_ambiguous_missing_or_changed_configuration_fails[internal-path]; 92 passed in 44.18s; {"stable_source_and_tests": true, "exit_code": 0, "reverse": false}

Working directory: .
Started: 2026-10-18T15:03:36.000618+00:00
Duration seconds: 45.617
Phase: P3-T3 configuration and activation; focused task verification.

## Captured output

```text
........................................................................ [ 78%]
....................                                                     [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                            Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\activation_filesystem.py     102      0     30      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py          162      0     58      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\configuration.py             123      0     48      0   100%
---------------------------------------------------------------------------------------------------------------------------
TOTAL                                                                             387      0    136      0   100%
Coverage JSON written to file SCRATCH\issue-980-p3t3-pass1-coverage.json
============================ slowest 10 durations =============================
3.86s call     tests/discovery_runtime/test_activation_store.py::test_partial_activation_keeps_protected_gate_active_and_recovers
3.63s call     tests/discovery_runtime/test_activation_store.py::test_activate_update_and_deactivate_preserve_exact_audit_chain[docs/migration/discovery/domain-profile.yaml]
3.62s call     tests/discovery_runtime/test_activation_store.py::test_activate_update_and_deactivate_preserve_exact_audit_chain[docs/custom/profile.yaml]
2.23s call     tests/discovery_runtime/test_configuration.py::test_default_and_custom_selection_require_explicit_activation[docs/migration/discovery/domain-profile.yaml]
2.14s call     tests/discovery_runtime/test_activation_store.py::test_active_configuration_tampering_cannot_disable_gate[delete-profile]
2.04s call     tests/discovery_runtime/test_configuration.py::test_default_and_custom_selection_require_explicit_activation[docs/Custom Profile.yaml]
2.03s call     tests/discovery_runtime/test_activation_store.py::test_active_configuration_tampering_cannot_disable_gate[malformed-profile]
1.60s call     tests/discovery_runtime/test_activation_store.py::test_inactive_workspace_and_missing_registry_are_read_only
1.41s call     tests/discovery_runtime/test_configuration.py::test_protected_matching_bytes_enable_selection_but_are_not_grants
1.39s call     tests/discovery_runtime/test_configuration.py::test_ambiguous_missing_or_changed_configuration_fails[internal-path]
92 passed in 44.18s
{"stable_source_and_tests": true, "exit_code": 0, "reverse": false}
```
