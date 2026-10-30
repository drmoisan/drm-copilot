# P3-T8 worker baseline and scope

Timestamp: 2026-10-19T00-56
Command: Read accepted task receipts, current scope, profile and native authority; git status --short
EXIT_CODE: 0
Output Summary: Accepted baseline e04136458147cdf24069b6bde563231f3c38c709 retained. All four authorized source/test paths are new; prior coverage for those paths is not applicable. No existing production, schema, policy or test changes are authorized.

Scope: packages/discovery-runtime/src/drm_copilot_discovery/source_reads.py; packages/discovery-runtime/src/drm_copilot_discovery/source_read_models.py; tests/discovery_runtime/test_source_reads.py; tests/discovery_runtime/test_source_read_limits.py. The helper was approved and persisted by the parent before implementation.

Reuse the accepted P3-T7 final source manifest and ordered gate receipts as the predecessor baseline: Ruff 0 findings, full Pyright 0 diagnostics, 75 forward and reverse cases passing, architecture/contracts/native composition passing, migration changed lines 100% covered. No predecessor behavior is changed by this additive task; repeating those suites would not establish coverage of the new paths. Executor independently captured 266 predecessor and 24 frozen paths in p3t8-executor-prior-manifest.2026-10-19T00-54.json.

The exact C4 profile SHA-256 is 0d02ca1f9b97abd4d84120f9443359404ab6ef4d094a1b97d520381fb1f9edd6. Native SubagentStart authority reports the selected python-typed-engineer-c4 profile, gpt-6-astra, max, valid routing and launch authority. The parent persisted workspace_operations_p3t8 before release.

Implement immutable selected-read values and a bounded reader using injected metadata/byte seams. Host-authenticated selection is separate from requested paths. Intersect profile scope before target byte reads; validate selected imported manifests and every member under aggregate limits; never infer working-byte provenance from the configured revision. Tests remain in memory. One consolidated candidate policy/semantic review precedes the final seven-stage task gate. Full feature aggregate gates remain the later plan obligation.
