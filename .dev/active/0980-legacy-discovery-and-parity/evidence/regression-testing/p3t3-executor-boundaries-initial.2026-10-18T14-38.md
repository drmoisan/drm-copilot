# P3-T3 independent activation boundary diagnostic

Timestamp: 2026-10-18 14:38:38 UTC
Command: `poetry run python SCRATCH/issue-980-p3t3-initial-probes.py`
EXIT_CODE: 1
Output Summary: Six of eight behavioral probes passed against stable hashes for all three new production modules. Two existing-task fail-closed boundaries failed. The prior constructor-wiring failure is separately retained and is not counted as a behavioral result.

Passed: actual memory-provider activation/deactivation with generations and invalidation; default-profile activation requirement; active locator deletion; denial of unauthenticated dry-run; parent identity change at protected-registry publication; partial workspace failure retaining protected active intent.

Failed: the implicit deactivated selection returned inactive after the protected record changed to active, using only one registry read; a known additional candidate appearing at guarded authorization was not rechecked, and activation returned success with protected record, config directory and locator publication.

The companion JSON records every case and before/after source hash. This is diagnostic evidence, not a final task gate or acceptance. No full initialization diagnostic ran.
