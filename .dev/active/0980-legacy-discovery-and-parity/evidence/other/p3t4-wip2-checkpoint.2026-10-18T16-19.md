# P3-T4 second checked WIP checkpoint

Status: FROZEN_FOR_WIP; P3-T4 remains unaccepted and unchecked. Pass 2 has not started.
Accepted task baseline: c114f98583599ebd5ee02281ece3524b2909fa51.
Current WIP HEAD: d9791ad7baaed3e6990bc6dc6c06b8feb204482c.

The five exact authored paths remain byte-identical to the completed forward/reverse coverage bindings. The current inventory records their hashes, normalized Git blobs and line counts. All 246 accepted prior paths and 24 frozen v1/export paths were preserved.

Historical pass 1 completed Black, Ruff, full Pyright, architecture, 78/78 forward tests (715.59 s), 78/78 reversed tests (307.05 s), and 551/551 package/schema/claim compatibility tests (6.52 s). Measured coverage: 169/170 executable lines, 51/52 arcs; all 18 callable/class ranges meet 90%, minimum 94.117647%. Coverage audit: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t4-pass1-coverage-audit.2026-10-18T16-10.json. Canonical raw coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t4-wip2-historical-raw-coverage.2026-10-18T16-19.json. Source bindings: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t4-wip2-historical-test-bindings.2026-10-18T16-19.json.

Stage 7 failed during scratch fixture setup, before invoking any draft API: the Windows-aware local provider rejected the seed store's POSIX-only root. The failed receipt p3t4-pass1-integration.2026-10-18T16-16.md remains preserved. The scratch-only correction copies seed bytes into MemoryDisk's existing platform-valid root and recaptures the model; no repository source or test correction was made.

The complete corrected diagnostic passed all 10 expected assertions with source hashes stable: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-composed-integration.2026-10-18T16-18.json. Normal operation seconds: {"contract_commit_seconds": 19.637079199994332, "contract_preview_seconds": 4.929397399988375, "scenario_commit_seconds": 29.2522719999979}. Its command took 60.305 s. This composed proof uses the accepted guarded writer and local primitives with injected memory OS seams, not a new native-platform provider.

The canonical seven-stage policy requires a fresh ordered pass after a stage failure. Therefore the completed pass-1 measurements and corrected diagnostic are historical checked-WIP evidence, not final gate acceptance. After the coordinator's checkpoint commit/release, pass 2 must run format, lint, types, architecture, complete task coverage/reverse isolation, contracts and composed integration in order on frozen bytes. The unchanged independent 29-case proof is retained. Final index audit, executor acceptance and accepted-task commit remain pending; P3-T5 is unreleased.
