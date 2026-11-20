# P3-T3 checked WIP

P3-T3 remains incomplete and unchecked. Six source/test files are frozen for coordinator staging and commit.

Black, Ruff and full Pyright passed, followed by 65/65 core tests in 32.74 seconds (33.989 seconds including the runner). Both measured race regressions pass. Failed earlier receipts are retained.

The three new modules had no pre-change executable baseline. Existing activation_models baseline was 28/28 lines and 4/4 arcs; 51 baseline tests passed. Preliminary coverage below is not final acceptance.

| Path | SHA-256 | Lines |
| --- | --- | --- |
| packages/discovery-runtime/src/drm_copilot_discovery/configuration.py | 0193463923026c5c06d4154b6854a9445682e3a05f372a81f2859b422494d3d2 | 310 |
| packages/discovery-runtime/src/drm_copilot_discovery/activation_store.py | d001281488ba92425a38929ce5770fbffd8000acfe34e0dade1e91f2e7fe572c | 450 |
| packages/discovery-runtime/src/drm_copilot_discovery/activation_filesystem.py | e597f46b02e938afe9de51bab42081a66d9b1d277b4458f8ff22ece7bd3f0746 | 179 |
| tests/discovery_runtime/test_configuration.py | 2f753f49d9e53df620b12e1a54f254632e5cdfa069cd2690d26c53b8ad4f5565 | 329 |
| tests/discovery_runtime/test_activation_store.py | 1529f379924ca5bff42379caaad5b1e46d39079ef9a834eb0e39be197f1fee86 | 331 |
| tests/discovery_runtime/test_activation_filesystem.py | 39ab451a74374a77b09361901f9dbc9cb57d3d64df70effe4c738790c1145c9b | 111 |

| Module | Covered lines | Covered arcs |
| --- | --- | --- |
| packages\discovery-runtime\src\drm_copilot_discovery\activation_filesystem.py | 44/102 | 12/30 |
| packages\discovery-runtime\src\drm_copilot_discovery\activation_store.py | 140/160 | 43/58 |
| packages\discovery-runtime\src\drm_copilot_discovery\configuration.py | 122/123 | 47/48 |

Preservation check: 240 accepted paths and 24 frozen paths unchanged.

Pending:

- Complete NativeRegistry memory seam coverage and remaining selection/commit negative and concurrency branches.
- Run final stable seven-stage ordered gate including module/class/function thresholds, reverse-order isolation, compatibility/contracts and native Windows integration.
- Record final raw callable ranges, native operation timing, staged-byte binding and final prior/frozen audit.
- Independent executor acceptance and task checkoff; P3-T4 remains unreleased.
- P11-T5 exhaustive property/mutation inventory remains owned by that later task.

Exact metadata: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t3-wip-inventory.2026-10-18T14-48.json
Baseline index: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/p3t3-baseline-index.2026-10-18T14-48.json

Native host proof has not yet run for P3-T3. No production/test edit or new test run is authorized during the WIP commit freeze.
