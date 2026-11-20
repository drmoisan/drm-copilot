# p3t3-native3-tests

Timestamp: 2026-10-18T15-01
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_activation_filesystem.py tests/discovery_runtime/test_configuration.py::test_invalid_protected_fields_fail_closed tests/discovery_runtime/test_activation_store.py::test_configuration_conflicts_are_rejected_before_lock_or_revocation tests/discovery_runtime/test_activation_store.py::test_guarded_input_changes_abort_before_protected_publication tests/discovery_runtime/test_activation_store.py::test_physical_substitutions_after_activation_intent_fail_explicitly tests/discovery_runtime/test_activation_store.py::test_postpublication_changes_invalidate_configuration_success tests/discovery_runtime/test_activation_store.py::test_inactive_selection_rejects_a_concurrent_protected_record_change tests/discovery_runtime/test_activation_store.py::test_activate_update_and_deactivate_preserve_exact_audit_chain -x -q --durations=8 --cov=drm_copilot_discovery.configuration --cov=drm_copilot_discovery.activation_store --cov=drm_copilot_discovery.activation_filesystem --cov-branch --cov-report=term --cov-report=json:SCRATCH/issue-980-p3t3-native3-coverage.json --junitxml=SCRATCH/issue-980-p3t3-native3-tests.xml
EXIT_CODE: 0
Output Summary: 0.72s call     tests/discovery_runtime/test_activation_store.py::test_guarded_input_changes_abort_before_protected_publication[parent]; 0.72s call     tests/discovery_runtime/test_activation_store.py::test_postpublication_changes_invalidate_configuration_success[parent]; 0.71s call     tests/discovery_runtime/test_activation_store.py::test_guarded_input_changes_abort_before_protected_publication[candidate]; 49 passed in 18.54s

Working directory: .
Started: 2026-10-18T15:01:19.875384+00:00
Duration seconds: 19.738
Phase: P3-T3 configuration and activation; focused task verification.

## Captured output

```text
.................................................                        [100%]
=============================== tests coverage ================================
______________ coverage: platform win32, python 3.13.12-final-0 _______________

Name                                                                            Stmts   Miss Branch BrPart  Cover
-----------------------------------------------------------------------------------------------------------------
packages\discovery-runtime\src\drm_copilot_discovery\activation_filesystem.py     102      0     30      0   100%
packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py          162      3     58      3    97%
packages\discovery-runtime\src\drm_copilot_discovery\configuration.py             123     14     48     15    82%
-----------------------------------------------------------------------------------------------------------------
TOTAL                                                                             387     17    136     18    93%
Coverage JSON written to file SCRATCH/issue-980-p3t3-native3-coverage.json
============================= slowest 8 durations =============================
3.75s call     tests/discovery_runtime/test_activation_store.py::test_activate_update_and_deactivate_preserve_exact_audit_chain[docs/custom/profile.yaml]
3.59s call     tests/discovery_runtime/test_activation_store.py::test_activate_update_and_deactivate_preserve_exact_audit_chain[docs/migration/discovery/domain-profile.yaml]
0.81s call     tests/discovery_runtime/test_activation_store.py::test_physical_substitutions_after_activation_intent_fail_explicitly[opened-parent]
0.74s call     tests/discovery_runtime/test_activation_store.py::test_postpublication_changes_invalidate_configuration_success[candidate]
0.72s call     tests/discovery_runtime/test_activation_store.py::test_physical_substitutions_after_activation_intent_fail_explicitly[leaf]
0.72s call     tests/discovery_runtime/test_activation_store.py::test_guarded_input_changes_abort_before_protected_publication[parent]
0.72s call     tests/discovery_runtime/test_activation_store.py::test_postpublication_changes_invalidate_configuration_success[parent]
0.71s call     tests/discovery_runtime/test_activation_store.py::test_guarded_input_changes_abort_before_protected_publication[candidate]
49 passed in 18.54s
```
