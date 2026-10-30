# P3-T6 independent r1-rebind

Timestamp: 2026-10-18 18:34:42 UTC
Captured result: 2026-10-18T18:33:56.315002+00:00
Command: `poetry run python SCRATCH/issue-980-p3t6-executor-r1.py adcbf4a65bc444aa9794ff447c660ef9950f2a513a6c8d8c24ef76d3171156b2 1d0b1970f8ca3d4e139060f322e3d82c9989b515cb62b2f881f1b7abc968dace d88262205076138fb8a6f7f5bd115d9d2c79a492be82ce1c6920bec0866a82eb 9a9a53d31366abc67126422cee4e3f0a3a8cd3dc41b7384bf99c7f5ba95e187c dd5d8c18c179a99e4ebf34f83fb38924b3ca083e1ca9db3509156c10cac7722c`
EXIT_CODE: 0

Output Summary: 13/13 retained reference-context cases passed in 13.665 seconds. The actual export keeps local mutation identity, resolves explicit source and manifest references to imported physical bytes, and continues to reject differing, unbound, and ordinary duplicate copies. All bound source/fixture bytes remained unchanged.

Raw evidence: [p3t6-executor-r1-rebind.2026-10-18T18-34.json](p3t6-executor-r1-rebind.2026-10-18T18-34.json).

Qualification: This is the bounded preparation/rebinding result for the corrected reference guard. The earlier 301-pass/1-failure task run remains failed historical evidence. The full restarted seven-stage task gate and final index/preservation audit remain required; P3-T6 is unchecked at 29/84 tasks and 11/66 acceptance criteria. The retained 44-case API proof remains historical with current API executable equivalence; this evidence separately covers its changed reference dependency and does not claim that all old byte hashes equal the current sources.

```text
frozen_production_hashes: PASS
local_evidence_projection_before_export: PASS
actual_export_projection_valid: PASS
local_evidence_projection_after_export: PASS
ordinary_lookup_keeps_local_identity: PASS
pinned_source_reference_uses_imported_bytes: PASS
transport_reference_uses_imported_bytes: PASS
manifest_links_retain_physical_imported_targets: PASS
changed_replica_bytes_still_block: PASS
unbound_replica_still_blocks: PASS
ordinary_same_byte_duplicate_still_blocks: PASS
physical_local_and_imported_bytes_retained: PASS
all_bound_bytes_unchanged: PASS
{"passed": 13, "failed": 0, "elapsed_seconds": 13.665}
```
