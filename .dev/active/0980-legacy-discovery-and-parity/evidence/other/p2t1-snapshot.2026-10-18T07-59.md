# P2-T1 immutable snapshot handoff

Timestamp: 2026-10-18T07-59
Command: poetry run python SCRATCH/issue-980-p2t1-task-audit.py 6
EXIT_CODE: 0
Output Summary: 9 exact staged paths; 112 focused and 112 reversed-order tests pass. 165 prior accepted paths and 24 frozen v1/export paths are unchanged. 587/587 executable lines and 251/258 branch arcs are covered.

## Exact scope

- packages/discovery-runtime/src/drm_copilot_discovery/snapshot.py (270 physical lines)
- packages/discovery-runtime/src/drm_copilot_discovery/snapshot_io.py (340 physical lines)
- packages/discovery-runtime/src/drm_copilot_discovery/repository_reader.py (178 physical lines)
- packages/discovery-runtime/src/drm_copilot_discovery/snapshot_loading.py (486 physical lines)
- tests/discovery_runtime/test_snapshot.py (193 physical lines)
- tests/discovery_runtime/test_snapshot_io.py (277 physical lines)
- tests/discovery_runtime/test_repository_reader.py (220 physical lines)
- tests/discovery_runtime/test_snapshot_loading.py (423 physical lines)
- tests/discovery_runtime/test_snapshot_imports.py (324 physical lines)

All nine files are new; baseline executable lines are zero. The explicitly approved snapshot_loading.py split keeps loading mechanics separate from immutable values and injected reads under the plan's 500-line provision. The test_snapshot_loading.py and test_snapshot_imports.py splits keep loading integration and bootstrap/import cases bounded; maximum final physical file length is 486. No dependency, suppression, coverage configuration, prior implementation, plan/AC or coordinator checkpoint was changed by this worker. Coordinator owns staging and executor owns task/AC checkoff.

## Interfaces and invariants

- snapshot.py provides SnapshotFile, ArtifactSnapshot, InputManifest and DiscoverySnapshot immutable values. Files preserve exact bytes, portable paths, categories, SHA-256 and sizes. InputManifest sorts entries/missing paths and repository role pins; its SHA-256 is canonical UTF-8 JSON of {versions, inputs}, with newline and fixed runtime/schema/policy 2.0.0 values. DiscoverySnapshot additionally hashes checkout identity, selected pinned Git objects and exclusions. Detached transport dictionaries cannot mutate captured inputs.
- load_snapshot in snapshot_loading.py takes a fresh SnapshotIO, explicit profile path, optional injected RepositoryReader and optional trusted unextended SchemaCatalog. One final catalog is reused across the workspace's artifact validations. An absent Git adapter preserves unknown checkout/object availability rather than inventing evidence. Loading ok only describes input loading and structural validation, not discovery/parity or host authority.
- SnapshotIO injects PathMetadataReader and bounded WorkspaceBytes callables. These host adapters must use workspace-anchored non-following opens and bounded allocation. The layer checks exact ordinary ancestors during bootstrap, then uses accepted PathPolicy for configured reads. It captures every selected file once, normalizes complete directory names while rejecting duplicate/alias names, and compares metadata and original bytes again before returning. Later mutation services must repeat freshness/compare-and-swap checks; this task performs no writes and makes no atomic OS transaction claim.
- Bootstrap first validates the raw core profile. Every local extension-schema declaration must be within exactly spelled documentation roots before any extension bytes are opened. Only checksummed immutable schema bytes then construct the pinned catalog and final ProfileV2. Raw profile, optional activation locator, local schemas, all structured artifacts, payloads, imported containers/content, extension outputs and selected source/test/documentation bytes remain in the input set. Explicit absence remains recorded.
- Known artifact locations and transport entries supply trusted expected kinds. Malformed/unrecognized files remain captured with blocking findings. Referenced JSON/YAML payloads are opaque unless they claim a structured artifact identity. Imported manifests stay beneath the configured transport root and preserve original repository pins and relative origin paths. Extension results stay in inventory scope; their selected source inputs stay in configured source/test scope. No configuration entry executes an adapter or fetches remote content.
- LocalGitReader accepts an injected fixed-argv GitCommand. It verifies the exact selected repository root, requires full literal revisions and ordinary file blobs, disables lazy fetch and transport, and verifies Git blob identity against returned bytes. It does not launch a subprocess itself. Selected source/test requests remain independent of payload references. Runtime capture revisions remain metadata and do not require the capture file to exist in the application commit; historical source/test evidence uses its own immutable pin.
- P2-T2 and later tasks retain reference indexing, evidence/manifest semantic hashes, revision/claim/decision/coverage/parity/completion rules. Snapshot loading keeps observations, authored claims and current/pinned bytes separate and does not infer those outcomes. Derived report envelopes are parsed here; report authenticity belongs to the later planned rule/service tasks.

## Gate results and isolation

Clean ordered pass 6: Black and Ruff pass all nine paths, full repository Pyright reports zero errors/warnings/informations, and 112 focused tests pass. Reversed new-module order passes 112 tests in one process. Every new callable/class has at least 100.00% line coverage. No changed executable lines have a prior baseline population; accepted earlier task hashes are unchanged. Phase 0 repository baseline remains 7,336 passed, six existing skips, 94.111715% lines and 88.783742% branches; full feature QA belongs to Phase 11.

| Production module | Covered lines | Covered branch arcs |
| --- | --- | --- |
| packages/discovery-runtime/src/drm_copilot_discovery/repository_reader.py | 83/83 | 24/24 |
| packages/discovery-runtime/src/drm_copilot_discovery/snapshot.py | 116/116 | 27/28 |
| packages/discovery-runtime/src/drm_copilot_discovery/snapshot_io.py | 186/186 | 88/88 |
| packages/discovery-runtime/src/drm_copilot_discovery/snapshot_loading.py | 202/202 | 112/118 |

Tests use fresh in-memory file/metadata/Git stores, injected failures and deterministic permutation cases. Shared catalog/profile fixtures are immutable; mutable documents/read stores are local to each test. There are no temporary-file, subprocess or network calls in these unit tests. Existing static synthetic fixture resources are read through the previously accepted fixture helper. Positive, invalid/missing, byte/entry/depth limits, alias/link rejection, read/hash consistency, ordering and replacement/addition/deletion cases are exercised.

Initial failed receipts are retained. The executor identified three loader corrections: do not look up runtime capture bytes at the application commit, do not let payload references remove selected source reads, and normalize directory order without hiding collisions. All are corrected with direct regressions. Initial pass 4 had 102 passing cases, three fixture-expectation failures and two setup/teardown errors from one oversized automatic pytest ID. Fixtures now isolate the intended root rule, expect the existing checksum diagnostic and agree on imported source ID; the oversized byte case has a short explicit ID. Pass 5 had 110 passing cases and two absent fixture-file lookups; those report cases now use the accepted pure control_fixture helper. No safety rule or coverage floor was weakened. The static audit confirms 148 documented classes/functions, no suppression or trailing whitespace, and no external operations in the new tests. Tracked quality-tier checks report 26 entries/projects and packaged resource closure checks pass.

Exact staged SHA-256 values, unchanged-path inventories, callable ranges and per-file line/branch percentages: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t1-coverage-metrics.2026-10-18T07-59.json.
Raw coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p2t1-coverage.2026-10-18T07-59.json.

Canonical command records:
- p2t1-executor-review.2026-10-18T07-46.md
- p2t1-format-draft.2026-10-18T07-42.md
- p2t1-format-pass1.2026-10-18T07-47.md
- p2t1-format-pass2.2026-10-18T07-47.md
- p2t1-format-pass3.2026-10-18T07-48.md
- p2t1-format-pass4.2026-10-18T07-49.md
- p2t1-format-pass4a.2026-10-18T07-49.md
- p2t1-format-pass5.2026-10-18T07-53.md
- p2t1-format-pass5a.2026-10-18T07-53.md
- p2t1-format-pass6.2026-10-18T07-55.md
- p2t1-format-pass6a.2026-10-18T07-55.md
- p2t1-lint-pass2.2026-10-18T07-47.md
- p2t1-lint-pass3.2026-10-18T07-48.md
- p2t1-lint-pass4.2026-10-18T07-49.md
- p2t1-lint-pass5.2026-10-18T07-53.md
- p2t1-lint-pass6.2026-10-18T07-55.md
- p2t1-resource-check.2026-10-18T07-58.md
- p2t1-static-audit.2026-10-18T07-56.md
- p2t1-tests-pass4.2026-10-18T07-51.md
- p2t1-tests-pass5.2026-10-18T07-55.md
- p2t1-tests-pass6.2026-10-18T07-57.md
- p2t1-tests-reversed.2026-10-18T07-58.md
- p2t1-tracked-tiers.2026-10-18T07-58.md
- p2t1-types-pass3.2026-10-18T07-48.md
- p2t1-types-pass4.2026-10-18T07-49.md
- p2t1-types-pass5.2026-10-18T07-53.md
- p2t1-types-pass6.2026-10-18T07-55.md

P2-T1 remains subject to independent executor acceptance. No P2-T2 or later task is implemented or released by this handoff.
