# P3-T6 independent API boundary proof

Timestamp: 2026-10-18 18:15:52 UTC

Command: `poetry run python SCRATCH/issue-980-p3t6-executor-api.py d5ba8ec85f7e1937aa38d687cfe506a7001c814513257140cee8bfb280e181e5`

EXIT_CODE: 0

OutputSummary: 44/44 bounded memory API checks passed in 16.62 seconds. All six production and nine supporting input hashes were stable across the invocation. The nine currently owned source/test hashes match the worker's checked WIP inventory. This is scoped review evidence, not the final ordered task gate or task acceptance.

Raw result: [p3t6-executor-api.2026-10-18T18-15.json](p3t6-executor-api.2026-10-18T18-15.json).

Output:

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
combined_identity_reuses_existing_export_without_replacement: PASS
source_and_target_baselines_remain_unchanged: PASS
all_bound_source_and_fixture_bytes_unchanged: PASS
{"passed":44,"failed":0,"elapsed_seconds":16.62}
```
