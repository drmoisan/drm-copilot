# P3-T1 prerequisite correction verified

Timestamp: 2026-10-18T11-37
Command: poetry run python SCRATCH/issue-980-verify-p3t1-report-root.py
EXIT_CODE: 0
Output Summary: VERIFIED prerequisite only: two exact staged paths, 209 other accepted paths and 24 frozen paths unchanged; 38 focused and five reversed cases; 51/51 lines and 22/22 branch arcs; all three callable ranges retain 100% coverage; ten retained independent semantic checks pass.

The correction excludes the exact missing reports directory as derived output state, together with descendants. Neighboring prefixes and missing source inputs remain bound. The complete snapshot digest still includes report output state. Reversing the three textual production changes restores the accepted P2-T9 raw SHA256, confirming the bounded delta. Existing P2-T9 evidence remains unchanged.

| Path | Current SHA256 |
| --- | --- |
| packages/discovery-runtime/src/drm_copilot_discovery/validation_inputs.py | 147b363fbf5f1041ce79dc40e3b9c10d1ba3aab41be007a9b06cce8df8b4cda2 |
| tests/discovery_runtime/test_validation_modes.py | ce23a61febdf5a085a515cd350296ed86b7decef00ffac631d6d381897fdfaed |

The five separate ordered/isolation receipts in the [checks manifest](p3t1-executor-report-root-checks.2026-10-18T11-37.json) were read and reconciled with raw coverage. Formatting and linting passed; full Pyright returned zero errors and zero warnings. The affected module passed 38 tests and its five changed cases passed in reversed group order. Current module coverage equals the accepted 51/51 lines and 22/22 arcs; report_input_digest remains 7/7. Both paths are staged byte-for-byte, with 179 and 355 physical lines and no staged whitespace errors.

The retained [nine invariant probes](p3t1-executor-report-invariants.2026-10-18T11-31.json) bind the corrected production SHA. The [absent-root paired-report mutation](p3t1-executor-report-root-corrected.2026-10-18T11-30.json) passed on its recorded mutation module hashes; it will be rebound if those modules change before final P3-T1 acceptance. No passing gate was rerun for this receipt. The initial operational verifier newline-normalization error and correction are retained in [the failed command receipt](p3t1-executor-report-root-check-initial.2026-10-18T11-37.md).

This receipt accepts the authorized prerequisite correction only. P3-T1 remains unchecked pending the mutation task's corrected final gates, final byte-bound probes, and real Windows provider smoke. No plan, acceptance criterion, checkpoint, or production/test file was changed by the verifier.
