# p3t5-corrected-boundaries12

Timestamp: 2026-10-18T17-15
Command: poetry run pytest -o addopts=-ra tests/discovery_runtime/test_evidence_linking.py tests/discovery_runtime/test_evidence_payloads.py -k source_and_test or wrapper or shared_writer or uri_description or unverified_assessment or working_bytes -q -x --durations=8
EXIT_CODE: 0
Output Summary: 3.26s call     tests/discovery_runtime/test_evidence_payloads.py::test_source_and_test_records_use_actual_captured_immutable_objects[test]; 2.79s setup    tests/discovery_runtime/test_evidence_payloads.py::test_source_and_test_records_use_actual_captured_immutable_objects[source]; 0.29s call     tests/discovery_runtime/test_evidence_payloads.py::test_unverified_assessment_cannot_be_hidden_by_an_injected_plan; 8 passed, 53 deselected in 26.18s

Working directory: .
Started: 2026-10-18T17:15:15.979409+00:00
Duration seconds: 27.264
Phase: P3-T5 evidence registration and linking; focused task verification.

## Captured output

```text
........                                                                 [100%]
============================= slowest 8 durations =============================
5.84s setup    tests/discovery_runtime/test_evidence_linking.py::test_wrapper_forwards_exact_context_grants_and_dry_run
3.63s call     tests/discovery_runtime/test_evidence_payloads.py::test_source_and_test_records_use_actual_captured_immutable_objects[source]
3.51s call     tests/discovery_runtime/test_evidence_payloads.py::test_uri_description_cannot_be_registered_as_locally_verified_evidence
3.38s setup    tests/discovery_runtime/test_evidence_payloads.py::test_unverified_assessment_cannot_be_hidden_by_an_injected_plan
3.32s call     tests/discovery_runtime/test_evidence_payloads.py::test_working_bytes_cannot_replace_missing_pinned_source
3.26s call     tests/discovery_runtime/test_evidence_payloads.py::test_source_and_test_records_use_actual_captured_immutable_objects[test]
2.79s setup    tests/discovery_runtime/test_evidence_payloads.py::test_source_and_test_records_use_actual_captured_immutable_objects[source]
0.29s call     tests/discovery_runtime/test_evidence_payloads.py::test_unverified_assessment_cannot_be_hidden_by_an_injected_plan
8 passed, 53 deselected in 26.18s
```
