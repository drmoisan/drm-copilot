# p3t3-pass2-reverse

Timestamp: 2026-10-18T15-17
Command: poetry run python SCRATCH/issue-980-p3t3-tests.py reverse2 --reverse
EXIT_CODE: 0
Output Summary: 0.58s call     tests/discovery_runtime/test_configuration.py::test_protected_matching_bytes_enable_selection_but_are_not_grants; 0.56s call     tests/discovery_runtime/test_configuration.py::test_ambiguous_missing_or_changed_configuration_fails[changed-profile]; 134 passed in 20.21s; {"stable_source_and_tests": true, "exit_code": 0, "reverse": true}

Working directory: .
Started: 2026-10-18T15:16:54.979174+00:00
Duration seconds: 21.369
Phase: P3-T3 configuration and activation; focused task verification.

## Captured output

```text
........................................................................ [ 53%]
..............................................................           [100%]
============================ slowest 10 durations =============================
1.69s call     tests/discovery_runtime/test_activation_store.py::test_activate_update_and_deactivate_preserve_exact_audit_chain[docs/migration/discovery/domain-profile.yaml]
1.67s call     tests/discovery_runtime/test_activation_store.py::test_partial_activation_keeps_protected_gate_active_and_recovers
1.64s call     tests/discovery_runtime/test_activation_store.py::test_activate_update_and_deactivate_preserve_exact_audit_chain[docs/custom/profile.yaml]
1.09s call     tests/discovery_runtime/test_activation_store.py::test_active_configuration_tampering_cannot_disable_gate[delete-profile]
1.02s call     tests/discovery_runtime/test_activation_store.py::test_active_configuration_tampering_cannot_disable_gate[malformed-profile]
0.84s call     tests/discovery_runtime/test_configuration.py::test_default_and_custom_selection_require_explicit_activation[docs/Custom Profile.yaml]
0.83s call     tests/discovery_runtime/test_configuration.py::test_default_and_custom_selection_require_explicit_activation[docs/migration/discovery/domain-profile.yaml]
0.72s call     tests/discovery_runtime/test_activation_store.py::test_inactive_workspace_and_missing_registry_are_read_only
0.58s call     tests/discovery_runtime/test_configuration.py::test_protected_matching_bytes_enable_selection_but_are_not_grants
0.56s call     tests/discovery_runtime/test_configuration.py::test_ambiguous_missing_or_changed_configuration_fails[changed-profile]
134 passed in 20.21s
{"stable_source_and_tests": true, "exit_code": 0, "reverse": true}
```
