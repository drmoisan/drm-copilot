# P5-T2 final native

Timestamp: 2026-10-20T08-06
Command: `WORKSPACE\.venv\Scripts\python.exe -u NATIVE_SCRATCH\issue-980-p5t2-native-composition.py NATIVE_SCRATCH\issue-980-p5t2-fixture-547e8c4158814bbaabc09f68eb577c83.json NATIVE_SCRATCH\issue-980-p5t2-native-result.2026-10-20T08-03.json --release NATIVE_SCRATCH\issue-980-p5t2-native-release.2026-10-20T08-03.json`
EXIT_CODE: 0
Output Summary: Stage 5; 151.326 seconds; 0 completed nodes; timeout=False; changed bindings=0.

```text
PASS fixture-byte-identity-before
PASS checkout-identity
PASS actual-loaded-membership
PASS known-captured-bytes
PASS source-and-target-role-pins
PASS client-scope
PASS structural-contract
PASS qualification-read-only
PASS harness-release-hash
PASS candidate:packages/discovery-runtime/src/drm_copilot_discovery/coverage_population.py
PASS candidate:packages/discovery-runtime/src/drm_copilot_discovery/coverage_report.py
PASS candidate:packages/discovery-runtime/src/drm_copilot_discovery/parity_entry_rules.py
PASS candidate:packages/discovery-runtime/src/drm_copilot_discovery/parity_metrics.py
PASS candidate:packages/discovery-runtime/src/drm_copilot_discovery/parity_models.py
PASS candidate:packages/discovery-runtime/src/drm_copilot_discovery/parity_report.py
PASS candidate:packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py
PASS candidate:packages/discovery-runtime/src/drm_copilot_discovery/parity_target_rules.py
PASS candidate:packages/discovery-runtime/src/drm_copilot_discovery/report_models.py
PASS candidate:packages/discovery-runtime/src/drm_copilot_discovery/validation.py
PASS candidate:pyproject.toml
PASS candidate:scripts/dev_tools/discovery/io.py
PASS candidate:scripts/dev_tools/discovery/parity_report.py
PASS candidate:tests/discovery_runtime/parity_test_support.py
PASS candidate:tests/discovery_runtime/test_parity_axes.py
PASS candidate:tests/discovery_runtime/test_parity_clients.py
PASS candidate:tests/discovery_runtime/test_parity_metrics.py
PASS candidate:tests/discovery_runtime/test_parity_models.py
PASS candidate:tests/discovery_runtime/test_parity_report.py
PASS candidate:tests/discovery_runtime/test_parity_report_projection.py
PASS candidate:tests/discovery_runtime/test_parity_rules.py
PASS candidate:tests/discovery_runtime/test_report_models.py
PASS candidate:tests/discovery_runtime/test_validation_modes.py
PASS candidate:tests/scripts/dev_tools/discovery/test_parity_report.py
PASS metric-projection-identity
PASS explicit-failure-result
PASS explicit-failure-findings
PASS nonempty-population-available
PASS metric:/parity/clients/0/dimensions/mobile/not_required
PASS metric:/parity/clients/0/dimensions/mobile/required
PASS metric:/parity/clients/0/dimensions/mobile/verification/percentage
PASS metric:/parity/clients/0/dimensions/mobile/verified
PASS metric:/parity/clients/0/dimensions/offline/not_required
PASS metric:/parity/clients/0/dimensions/offline/required
PASS metric:/parity/clients/0/dimensions/offline/verification/percentage
PASS metric:/parity/clients/0/dimensions/offline/verified
PASS metric:/parity/entries/complete
PASS metric:/parity/entries/state_counts/missing
PASS metric:/parity/entries/total
PASS metric:/parity/feature_client_obligations/completed_required
PASS metric:/parity/feature_client_obligations/required
PASS metric:/parity/source_features/completed_required
PASS metric:/parity/source_features/required
PASS metric:/parity/source_features/total
PASS json-view-identity
PASS markdown-view-identity
PASS captured-input-immutability
PASS dry-run-dispositions
PASS dry-run-no-write
PASS publication-result
PASS publication-output-membership
PASS publication-invalidation-seam
PASS generated-json-membership
PASS generated-markdown-membership
PASS semantic-digest-stability
PASS full-snapshot-changed
PASS pinned-input-identity-stability
PASS authored-file-identity-stability
PASS recomputed-report-identity
PASS published-structural-validation
PASS failure-semantics-preserved
PASS idempotent-dispositions
PASS idempotent-no-invalidation
PASS missing-grant-rejected
PASS stale-original-rejected
PASS only-granted-report-bytes-changed

```
