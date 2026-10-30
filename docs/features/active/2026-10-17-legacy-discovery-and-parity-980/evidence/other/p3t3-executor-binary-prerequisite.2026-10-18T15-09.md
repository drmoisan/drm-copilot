# P3-T3 native byte-preservation prerequisite

Timestamp: 2026-10-18 15:09:55 UTC

The real Windows diagnosis in [p3t3-native-byte-diagnosis.2026-10-18T15-08.json](../regression-testing/p3t3-native-byte-diagnosis.2026-10-18T15-08.json) demonstrates an existing mutation-provider defect. A 2,121-byte LF proposal was physically stored as 2,122 bytes with CRLF translation. The provider's read returned 2,121 normalized bytes matching the proposal hash, while an independent binary read produced a different hash. Thus configuration reported success without preserving the proposed physical bytes.

Read-only source inspection confirms that `NativeDirectory.read` and `NativeDirectory.stage` in `packages/discovery-runtime/src/drm_copilot_discovery/mutation_filesystem.py` omit `O_BINARY` on their content-bearing `os.open` calls. The inspected provider SHA-256 is `db2aca8bf68f64333b509ca12cbe8445d1a0dadc0532064d93581acb1afb422c`.

This is a bounded prerequisite correction to the existing exact-byte read/publication and digest-precondition contract used by P3-T3. It introduces no new independent outcome, schema or task and requires no plan revision. The coordinator must authorize the original component owner to reopen only that provider and `tests/discovery_runtime/test_mutation_filesystem.py`. The six current P3-T3 paths remain within their existing ownership.

Acceptance requires explicit binary content opens, memory-only assertions for flags and byte preservation, a clean ordered task gate including affected provider tests, and actual Windows physical-byte/hash comparisons after exclusive creation and replacement. LF, CRLF and non-text bytes must remain exact. Historical P3-T1 proof remains unchanged; final P3-T3 preservation evidence must enumerate these two authorized prior-path corrections separately from unchanged prior paths. Prior mutation and initialization exact-byte fidelity claims are qualified pending this reproof, including a bounded comparison of initialization's projected outputs with independently read physical bytes. This diagnostic does not accept P3-T3 or change any plan/AC checkbox.
