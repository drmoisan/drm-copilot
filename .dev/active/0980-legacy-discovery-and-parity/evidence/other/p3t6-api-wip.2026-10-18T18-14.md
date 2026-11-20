# P3-T6 checked public API WIP

Timestamp: 2026-10-18T18:14:22.553384+00:00
Command: poetry run python SCRATCH/issue-980-p3t6-api-wip.py
EXIT_CODE: 0
Output Summary: 33 focused API cases and 11 composed checks pass; final task gates remain pending.

The public API projects exact source artifacts and verified evidence payloads from complete captures, then delegates planning and publication to the accepted transport mutation route. Import validates an already captured local bundle against a configured full source pin and preserves immutable destination bytes. No sibling lookup, remote fetch or native authority is supplied by request values.

Black, Ruff and full Pyright pass. Focused API preparation: 33 passed in 59.01 seconds. Composed readiness: 11 checks passed in 140.584 seconds, including new-destination import with staging retained, exact publication, dry-run, partial recovery, identical repeat and stale-input rejection. The composed proof records pre/post hashes for all nine paths.

Preparation coverage is 143/152 lines for the new API; final per-unit thresholds and the complete seven-stage acceptance loop remain pending. The 32 earlier prerequisite cases were not repeated during this focused API run. Closed prerequisite proofs remain bound to unchanged production.

| Path | Raw SHA-256 | Physical lines |
| --- | --- | --- |
| packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py | adcbf4a65bc444aa9794ff447c660ef9950f2a513a6c8d8c24ef76d3171156b2 | 483 |
| packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py | 1d0b1970f8ca3d4e139060f322e3d82c9989b515cb62b2f881f1b7abc968dace | 426 |
| packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py | d88262205076138fb8a6f7f5bd115d9d2c79a492be82ce1c6920bec0866a82eb | 437 |
| packages/discovery-runtime/src/drm_copilot_discovery/references.py | 6222b7135dce93869b02e9e00276d31b4f648dc3c9b42e4b5c8fdb8f8d904ed2 | 430 |
| packages/discovery-runtime/src/drm_copilot_discovery/transport_manifest.py | f70fba9b394490881f2e6c0e8d05fd9011b810ae15339dfe18a84c2ffef19f0f | 271 |
| packages/discovery-runtime/src/drm_copilot_discovery/source_snapshots.py | d5ba8ec85f7e1937aa38d687cfe506a7001c814513257140cee8bfb280e181e5 | 437 |
| tests/discovery_runtime/test_snapshot_export.py | cc1b079ebf51af27e0bfccd032c5b668eadd295d024caafcf79dca82ba8ce261 | 475 |
| tests/discovery_runtime/test_snapshot_import.py | e983600a0df7477dd3618a41db96b62539dc17904c8ef6f6c8f7a99ee424b077 | 449 |
| tests/discovery_runtime/source_snapshot_test_support.py | 34215fb4d2499575ad59857d302dfdddd8f59c050e3cae7e1e809b0c8aef6aa9 | 373 |

Preservation: 251 unaffected accepted paths and 24 frozen paths match the original task baseline. Exactly four accepted predecessor modules are authorized exceptions. Current HEAD is a4abf7737f656ad49cc39b5ab588d1352dc48cd4; task acceptance baseline remains 27753e5f8b9a6cd1d85b9d1d28d2999800af209a.

The JSON inventory lists exact new worker/coordinator/executor evidence paths separately. This WIP milestone does not check off the task or replace final coverage, reverse, contracts, integration and index verification.
