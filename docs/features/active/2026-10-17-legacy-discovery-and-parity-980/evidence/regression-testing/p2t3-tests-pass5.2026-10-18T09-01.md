# p2t3-tests-pass5

Timestamp: 2026-10-18T09-01
Original capture timestamp: 2026-10-18T08-30
Source aggregate: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t3-gates.2026-10-18T08-27.md
Source block ordinal: 12
Command: poetry run pytest -q -o addopts= tests/discovery_runtime/test_evidence_rules.py tests/discovery_runtime/test_revision_rules.py --cov=drm_copilot_discovery.evidence_rules --cov=drm_copilot_discovery.revision_rules --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-980-p2t3-coverage.json
EXIT_CODE: 1
Output Summary: FAILED tests/discovery_runtime/test_revision_rules.py::test_transported_evidence_uses_its_origin_root_and_immutable_identity[pin]; FAILED tests/discovery_runtime/test_revision_rules.py::test_transported_evidence_uses_its_origin_root_and_immutable_identity[storage]; FAILED tests/discovery_runtime/test_revision_rules.py::test_imported_historical_declarations_use_their_own_pin; 22 failed, 66 passed in 18.65s

Working directory: .
Started: 2026-10-18T08:29:50.736584+00:00
Duration seconds: 19.850
Phase: P2-T3 evidence integrity and declared repository revisions; focused task verification.

## Captured output

```text
FAILED tests/discovery_runtime/test_revision_rules.py::test_declared_repositories_respect_source_and_target_roles[extension-result-manifest-repository-repository1-expected1]
FAILED tests/discovery_runtime/test_revision_rules.py::test_declared_repositories_respect_source_and_target_roles[implementation-record-target_repository-repository2-expected2]
FAILED tests/discovery_runtime/test_revision_rules.py::test_declared_repositories_respect_source_and_target_roles[source-snapshot-manifest-source_repository-repository3-expected3]
FAILED tests/discovery_runtime/test_revision_rules.py::test_parity_repository_lists_and_entry_target_pins_are_checked
FAILED tests/discovery_runtime/test_revision_rules.py::test_transport_entry_bytes_are_verified_without_trusting_authored_success[none-True]
FAILED tests/discovery_runtime/test_revision_rules.py::test_transport_entry_bytes_are_verified_without_trusting_authored_success[none-False]
FAILED tests/discovery_runtime/test_revision_rules.py::test_transport_entry_bytes_are_verified_without_trusting_authored_success[hash-True]
FAILED tests/discovery_runtime/test_revision_rules.py::test_transport_entry_bytes_are_verified_without_trusting_authored_success[hash-False]
FAILED tests/discovery_runtime/test_revision_rules.py::test_transport_entry_bytes_are_verified_without_trusting_authored_success[size-True]
FAILED tests/discovery_runtime/test_revision_rules.py::test_transport_entry_bytes_are_verified_without_trusting_authored_success[size-False]
FAILED tests/discovery_runtime/test_revision_rules.py::test_transport_entry_bytes_are_verified_without_trusting_authored_success[missing-True]
FAILED tests/discovery_runtime/test_revision_rules.py::test_transport_entry_bytes_are_verified_without_trusting_authored_success[missing-False]
FAILED tests/discovery_runtime/test_revision_rules.py::test_transported_evidence_uses_its_origin_root_and_immutable_identity[none]
FAILED tests/discovery_runtime/test_revision_rules.py::test_transported_evidence_uses_its_origin_root_and_immutable_identity[owner]
FAILED tests/discovery_runtime/test_revision_rules.py::test_transported_evidence_uses_its_origin_root_and_immutable_identity[pin]
FAILED tests/discovery_runtime/test_revision_rules.py::test_transported_evidence_uses_its_origin_root_and_immutable_identity[storage]
FAILED tests/discovery_runtime/test_revision_rules.py::test_imported_historical_declarations_use_their_own_pin
22 failed, 66 passed in 18.65s
```
