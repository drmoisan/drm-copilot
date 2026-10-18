# P3-T6 bounded prerequisite authorization

Timestamp: 2026-10-18T17-38
Status: Authorized for delegated implementation; P3-T6 remains unchecked.

The [two-case reproduction](../regression-testing/p3t6-prerequisite-probe.2026-10-18T17-31.json) returned PATH_WRITE_DENIED for an exported feature-contract member and DUPLICATE_ID/REFERENCE_AMBIGUOUS for the identical manifest-bound source-local replica. Five accepted source hashes remained unchanged. The [executor review](p3t6-executor-prerequisite-review.2026-10-18T17-34.md) supports this bounded prerequisite to the existing approved export/import outcome; it does not introduce an independent outcome or require a new plan.

## Exact ownership

The Python specialist workspace_operations owns the following eight paths. The atomic_execution specialist owns independent verification and task check-off. The coordinator owns orchestration state and commits. All agents preserve other edits.

Existing prerequisite modules:

- packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py
- packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py
- packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py
- packages/discovery-runtime/src/drm_copilot_discovery/references.py

New prerequisite helper:

- packages/discovery-runtime/src/drm_copilot_discovery/transport_manifest.py

Original task paths:

- packages/discovery-runtime/src/drm_copilot_discovery/source_snapshots.py
- tests/discovery_runtime/test_snapshot_export.py
- tests/discovery_runtime/test_snapshot_import.py

The pure helper keeps manifest validation and immutable transport values out of the existing 472-line path-policy module. No schema, native provider, dependency or predecessor test edit is authorized. Any further file split requires its exact paths recorded before editing.

## Required boundaries

1. Bind transport to actual schema-valid manifest bytes, canonical digest, unique paths and counts, full repository pins, and exact member kind, identifier, path, hash and size. Authored verification status is not authority.
2. Permit only configured source-snapshot-root members with exact trusted grants. Reject specialist invocation for transport publication. Preserve ordinary routing, path walking and containment checks.
3. Read the source without mutation or fetch. Allow absent creation or exact existing-byte skip only. Never silently replace snapshot bytes.
4. Validate the full prospective member set and graph; publish the manifest last. Carry the bound route through plan reconstruction, fresh path resolution, guarded publication and postchecks. Retain every physical input and parent freshness check, invalidation, create/CAS behavior and truthful partial results.
5. Normalize lookup replicas only after matching validated manifest physical entry, repository, full revision, declared origin, kind, identifier, member pointer and complete raw bytes. Ordinary duplicates, unbound copies and conflicting replicas still fail. No first-match, generic duplicate exemption or status-based trust.
6. Reuse the accepted mutation machinery. Do not relabel artifact kinds, replace configured roots, fabricate resolved paths or create a second writer.
7. Bind existing prerequisite baseline coverage to unchanged accepted source hashes and retained raw evidence; run affected regression suites plus new route/replica cases. New-module and changed-code coverage requirements remain mandatory.
8. Commit a coherent, independently checked prerequisite milestone before prolonged complete export/import integration. Keep P3-T6 unaccepted until the complete ordered gate, evidence and executor verification pass.

## Checkpoint

Accepted baseline: 27753e5f8b9a6cd1d85b9d1d28d2999800af209a, verified on the remote branch before this task. Progress: 29/84 tasks and 11/66 acceptance criteria. The baseline recorded 85 selected tests passing in 49.47 seconds, clean Ruff and full Pyright. Existing actual launch attestations and generated profile hashes were revalidated for both active specialists before release.
