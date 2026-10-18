# P3-T6 initial independent API diagnostic

Timestamp: 2026-10-18 18:13:58 UTC

Command: `poetry run python SCRATCH/issue-980-p3t6-executor-api.py d5ba8ec85f7e1937aa38d687cfe506a7001c814513257140cee8bfb280e181e5`

EXIT_CODE: 1

OutputSummary: 39 passing markers, then a SCRATCH fixture-construction failure before the duplicate-import assertion. No completed matrix or final byte-stability claim is made. The helper attempted to add a parsed duplicate manifest without its corresponding captured input bytes; the accepted snapshot invariant rejected that fixture. Corrective action is to add the matching captured file in the SCRATCH helper. Repository production/test files were not edited by this diagnostic. The actual planner/import positive is covered separately by the worker's composed run.

Helper SHA-256 before correction: `580ad112fffa11737d2062ac29be1ede8e2fa1e68ef436eddb078ec89da72503`.

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
Traceback (most recent call last):
  File "SCRATCH/issue-980-p3t6-executor-api.py", line 157, in <module>
    duplicate = replace(retained_target, snapshot=replace(retained_target.snapshot, artifacts=(*retained_target.snapshot.artifacts, replace(header, path="docs/transport/duplicate/manifest.json"))))
                                                  ~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "<Python>/Lib/dataclasses.py", line 1596, in replace
    return _replace(obj, **changes)
  File "<Python>/Lib/dataclasses.py", line 1630, in _replace
    return self.__class__(**changes)
  File "<string>", line 11, in __init__
  File "packages/discovery-runtime/src/drm_copilot_discovery/snapshot.py", line 215, in __post_init__
    raise ValueError("Every parsed artifact requires captured input bytes")
ValueError: Every parsed artifact requires captured input bytes
```
