# P3-T6 checked prerequisite WIP

Timestamp: 2026-10-18T17:56:01.775698+00:00
Command: poetry run python SCRATCH/issue-980-p3t6-prerequisite-wip.py
EXIT_CODE: 0
Output Summary: Seven present authorized paths; full export/import API and acceptance remain pending.

Accepted task baseline: `27753e5f8b9a6cd1d85b9d1d28d2999800af209a`. Prior preservation: 251 unchanged accepted paths plus 24 frozen paths. Four exact predecessor changes are authorized.

The current correction preserves the local logical record, explicit imported source/manifest targets and schema-directed outgoing links for physical replicas. Conflicting/unbound copies remain rejected. No new native authority is introduced.

Formatting, Ruff and full Pyright pass. The historical 32-case suite passed before R1/R2; its coverage is retained with that qualification. The corrected narrow real-planner and conflict proofs are separate receipts. Final task coverage and the complete seven-stage acceptance loop remain pending.

| Path | Raw SHA-256 | Physical lines |
| --- | --- | --- |
| packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py | adcbf4a65bc444aa9794ff447c660ef9950f2a513a6c8d8c24ef76d3171156b2 | 483 |
| packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py | 1d0b1970f8ca3d4e139060f322e3d82c9989b515cb62b2f881f1b7abc968dace | 426 |
| packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py | d88262205076138fb8a6f7f5bd115d9d2c79a492be82ce1c6920bec0866a82eb | 437 |
| packages/discovery-runtime/src/drm_copilot_discovery/references.py | 6222b7135dce93869b02e9e00276d31b4f648dc3c9b42e4b5c8fdb8f8d904ed2 | 430 |
| packages/discovery-runtime/src/drm_copilot_discovery/transport_manifest.py | f70fba9b394490881f2e6c0e8d05fd9011b810ae15339dfe18a84c2ffef19f0f | 271 |
| tests/discovery_runtime/test_snapshot_export.py | ed7104a1aba7c98a553501ddc556e194e5f65d0415cf585233a9685e28b0ef91 | 455 |
| tests/discovery_runtime/test_snapshot_import.py | 549068c4963c4c3575f7ead4473c46028f0efa00a8589f905ef665e4e8b8673b | 278 |

`source_snapshots.py` is absent. Full export/import implementation, final forward/reverse tests, numeric module/callable coverage, compatibility/contracts and bounded actual commit integration remain to be completed after the WIP continuation.

A successful evidence_changes projection is not a promise that divergent same-pin replicas can be committed; strict conflicting-byte rejection remains in force.

## Worker evidence eligible for this checkpoint

- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/p3t6-transport-coverage.2026-10-18T17-30.json
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-baseline-pyright.2026-10-18T17-29.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-baseline-ruff.2026-10-18T17-29.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-baseline-tests.2026-10-18T17-30.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-coverage.2026-10-18T17-47.json
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-format-prepare.2026-10-18T17-42.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-format1.2026-10-18T17-42.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-format2.2026-10-18T17-43.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-format3.2026-10-18T17-44.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-format4.2026-10-18T17-50.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-format5.2026-10-18T17-54.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-probe.2026-10-18T17-31.json
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-probe.2026-10-18T17-31.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-pyright1.2026-10-18T17-43.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-pyright2.2026-10-18T17-43.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-pyright3.2026-10-18T17-45.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-pyright4.2026-10-18T17-50.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-pyright5.2026-10-18T17-54.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-r1-conflicts.2026-10-18T17-51.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-r1-format-prepare.2026-10-18T17-50.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-r1-test.2026-10-18T17-50.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-r2-test.2026-10-18T17-54.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-ruff-prepare.2026-10-18T17-42.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-ruff1.2026-10-18T17-43.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-ruff2.2026-10-18T17-43.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-ruff3.2026-10-18T17-44.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-ruff4.2026-10-18T17-50.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-ruff5.2026-10-18T17-54.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-tests2.2026-10-18T17-44.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-tests3.2026-10-18T17-47.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-prerequisite-wip-audit.2026-10-18T17-55.md

Inventory: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t6-prerequisite-wip.2026-10-18T17-56.json`. Review diff: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t6-prerequisite-patch.2026-10-18T17-56.md`. Coordinator/executor artifacts are enumerated separately by producer in the JSON inventory.
