# P3-T3 activation WIP checkpoint

Timestamp: 2026-10-18T14-49
Command: preserve checked activation and configuration work in progress
EXIT_CODE: 0
Output Summary: P3-T3 remains unchecked; 26/84 tasks and 10/66 acceptance criteria are accepted.

The six-file checkpoint contains profile selection, root configuration operations, protected activation/tombstone state and the extracted native registry adapter with core tests. The two measured race corrections passed direct regression cases.

Bounded checks passed: Black, Ruff, full Pyright, and 65/65 core tests in 32.74 seconds. The three new modules had no prior executable baseline; the accepted locator baseline measured 28/28 lines and 4/4 arcs. All 240 earlier accepted paths and 24 frozen paths are unchanged.

Coverage remains incomplete: configuration 122/123 lines and 47/48 arcs; activation_store 140/160 and 43/58; activation_filesystem 44/102 and 12/30. These preliminary values do not satisfy or replace final task acceptance. Native adapter branches, per-callable thresholds, isolation, contracts and actual Windows activation proof remain pending.

This checkpoint implements the user-requested frequent WIP commit cadence. Resume the same P3-T3 task after the canonical commit. Preserve its original accepted baseline 639c37269ed12b0bd4b5d74d66723e2f5ce4dedd; do not release P3-T4 before independent acceptance and the accepted-task commit.

Exact inventory: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t3-wip-inventory.2026-10-18T14-48.json
Stageable inventory: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t3-wip-stageable.2026-10-18T14-48.json
Canonical orchestration state: artifacts/orchestration/orchestrator-state.json

Git applies the repository LF normalization to the six CRLF working files. The WIP inventory binds the tested working bytes; the committed index is separately identified by its Git tree. Final task verification still requires its complete index-byte audit.
