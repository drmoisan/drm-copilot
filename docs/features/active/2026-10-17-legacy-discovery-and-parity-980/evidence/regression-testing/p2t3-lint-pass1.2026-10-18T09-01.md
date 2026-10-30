# p2t3-lint-pass1

Timestamp: 2026-10-18T09-01
Original capture timestamp: 2026-10-18T08-27
Source aggregate: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t3-gates.2026-10-18T08-27.md
Source block ordinal: 2
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/evidence_rules.py packages/discovery-runtime/src/drm_copilot_discovery/revision_rules.py tests/discovery_runtime/test_evidence_rules.py tests/discovery_runtime/test_revision_rules.py
EXIT_CODE: 1
Output Summary: [1m[94m460 |[0m         "inventory-snapshot",;     [1m[94m|[0m; ; Found 25 errors.

Working directory: .
Started: 2026-10-18T08:27:53.738718+00:00
Duration seconds: 0.788
Phase: P2-T3 evidence integrity and declared repository revisions; focused task verification.

## Captured output

```text
[1m[94m400 |[0m     """Foreign payloads cannot fall back to an unrelated local name or transport root."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m401 |[0m     profile = configured(snapshot_profile, snapshot_catalog)
[1m[94m402 |[0m     record = evidence(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_revision_rules.py:458:89
    [1m[94m|[0m
[1m[94m456 |[0m     snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
[1m[94m457 |[0m ) -> None:
[1m[94m458 |[0m     """Malformed upstream shapes remain available to schema diagnostics without crashes."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m459 |[0m     record = artifact(
[1m[94m460 |[0m         "inventory-snapshot",
    [1m[94m|[0m

Found 25 errors.
```
