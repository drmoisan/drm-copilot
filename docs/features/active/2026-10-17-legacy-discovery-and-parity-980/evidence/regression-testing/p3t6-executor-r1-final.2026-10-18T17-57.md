# p3t6-executor-r1-final

Timestamp: 2026-10-18T17:55:01.235619+00:00

Published: 2026-10-18 17:57:15 UTC

Command: `poetry run python SCRATCH/issue-980-p3t6-executor-r1.py adcbf4a65bc444aa9794ff447c660ef9950f2a513a6c8d8c24ef76d3171156b2 1d0b1970f8ca3d4e139060f322e3d82c9989b515cb62b2f881f1b7abc968dace d88262205076138fb8a6f7f5bd115d9d2c79a492be82ce1c6920bec0866a82eb 6222b7135dce93869b02e9e00276d31b4f648dc3c9b42e4b5c8fdb8f8d904ed2 f70fba9b394490881f2e6c0e8d05fd9011b810ae15339dfe18a84c2ffef19f0f`

EXIT_CODE: 0

Output Summary: 13/13 corrected local identity, explicit imported reference and conflict controls passed; source and fixture hashes stable.

This closes only the reported R1 contexts. Full task APIs, ordered gates and acceptance remain pending.

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
{"passed":13,"failed":0,"elapsed_seconds":11.89}
```
