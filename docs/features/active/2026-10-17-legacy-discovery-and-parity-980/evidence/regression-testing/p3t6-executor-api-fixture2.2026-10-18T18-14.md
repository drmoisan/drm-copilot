# P3-T6 second independent API fixture diagnostic

Timestamp: 2026-10-18 18:14:48 UTC

Command: `poetry run python SCRATCH/issue-980-p3t6-executor-api.py d5ba8ec85f7e1937aa38d687cfe506a7001c814513257140cee8bfb280e181e5`

EXIT_CODE: 1

OutputSummary: 41 passing markers, then a SCRATCH combined-profile fixture failure. Copied example clients still referenced target-example, which was absent from the combined profile. Corrective action binds those fixture clients to the local combined repository. No production finding or completed final stability claim is inferred; all repository production/test paths remained worker-owned and unchanged by this probe.

Helper SHA-256 before correction: `6487c4e1180f5b4564b04bf5c4bdad53128b899706d13c9cd8312033ff50d024`.

Output (host paths normalized):

```text
frozen_api_source: PASS
deterministic_export: PASS
closure_contains_contract_and_unresolved_collection: PASS
export_preserves_all_authored_bytes_and_states: PASS
export_header_last_and_complete_counts: PASS
export_identity_and_digest_bound: PASS
export_rejects_empty: PASS
export_rejects_duplicate: PASS
export_rejects_missing: PASS
export_rejects_imported: PASS
export_rejects_unresolved: PASS
export_rejects_malformed: PASS
export_rejects_path_escape_id: PASS
export_rejects_invalid_attribution: PASS
export_requires_immutable_pin: PASS
export_repeat_binds_identical_original_sha: PASS
export_never_replaces_changed_destination: PASS
pinned_source_payload_bytes_retained: PASS
missing_immutable_object_cannot_fall_back_to_worktree: PASS
changed_immutable_object_fails_checksum: PASS
both_runtime_capture_locations_exported: PASS
missing_secondary_runtime_bytes_rejected: PASS
import_uses_custom_root: PASS
import_preserves_two_target_clients: PASS
importer_attribution_is_explicit_and_digest_stable: PASS
import_preserves_original_member_bytes: PASS
target_cannot_export: PASS
source_only_cannot_import: PASS
import_rejects_foreign_id: PASS
import_rejects_foreign_revision: PASS
import_path_cannot_escape: PASS
import_rejects_changed_schema_version: PASS
import_rejects_changed_manifest_sha256: PASS
import_rejects_changed_member: PASS
import_rejects_missing_member: PASS
import_rejects_undeclared_member: PASS
configured_manifest_location_is_authoritative: PASS
identical_import_preserves_original_attribution_and_sha: PASS
changed_import_never_overwrites_existing_member: PASS
duplicate_existing_import_identity_rejected: PASS
existing_manifest_cannot_override_configured_destination: PASS
Traceback (most recent call last):
  File "SCRATCH/issue-980-p3t6-executor-api.py", line 169, in <module>
    combined = capture(source_store, catalog)
  File "tests/discovery_runtime/mutation_test_support.py", line 62, in capture
    return capture_workspace(
        workspace_root=store.metadata.root.as_posix(),
    ...<3 lines>...
        catalog=catalog,
    )
  File "packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py", line 67, in capture_workspace
    snapshot = load_snapshot(
        io=SnapshotIO(
    ...<4 lines>...
        catalog=catalog,
    )
  File "packages/discovery-runtime/src/drm_copilot_discovery/snapshot_loading.py", line 483, in load_snapshot
    profile, pinned, categories = load_profile_inputs(
                                  ~~~~~~~~~~~~~~~~~~~^
        io, profile_path, catalog or load_catalog()
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    )
    ^
  File "packages/discovery-runtime/src/drm_copilot_discovery/snapshot_io.py", line 326, in load_profile_inputs
    profile = ProfileV2(
        cast("bytes", raw), format=document_format(path), catalog=catalog
    )
  File "packages/discovery-runtime/src/drm_copilot_discovery/profile_v2.py", line 178, in __init__
    raise ProfileError(findings)
drm_copilot_discovery.profile_v2.ProfileError: /clients/0/target_repository: Unknown target repository: target-example
/clients/1/target_repository: Unknown target repository: target-example
```
