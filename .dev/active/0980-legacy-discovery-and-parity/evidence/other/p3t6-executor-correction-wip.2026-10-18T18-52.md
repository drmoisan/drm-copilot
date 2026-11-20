# P3-T6 correction WIP review

Timestamp: 2026-10-18 18:52:28 UTC
Captured result: 2026-10-18T18:52:18.793557+00:00
Command: `poetry run python SCRATCH/issue-980-p3t6-correction-wip-check.py`
EXIT_CODE: 0

Output Summary: 12/12 bounded evidence/proof-applicability checks pass. All prior nine source/test hashes remain unchanged; the sole added path is the authorized 75-line test_snapshot_replica_resolution.py with four isolated context cases. The narrow raw coverage executes exactly statement 243 and arc 242 to 243. The same-source diagnostic union is 169/171 lines and 82/84 arcs; this is preparation evidence only.

Review: The test explicitly supplies an imported canonical representative and proven alias to the resolver. It asserts each manifest selects its own physical member, source-contract selection is deterministic, and an unmatched manifest is rejected. Existing manifest validation and provenance tests remain unchanged. Retained 44-case API executable provenance and the exact 13+7 reference proofs remain applicable without a behavior rerun. Their source/fixture checks are recorded in [the raw review](p3t6-executor-correction-wip.2026-10-18T18-52.json).

Disposition: CHECKED_WIP_NOT_ACCEPTED. The historical 430-test run passed behavior but failed its per-file coverage gate. The next full population is 434. Full uninterrupted ordered verification, single-run raw coverage, reversed isolation, contracts, composed integration and final index audit remain pending. P3-T6 is unchecked; plan progress remains 29/84 and feature criteria remain 11/66. No verifier process remains; repository edits are frozen after this receipt for the coordinator's WIP commit.

```text
{
  "timestamp": "2026-10-18T18:52:18.793557+00:00",
  "task": "P3-T6 correction WIP review",
  "wip": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t6-correction-wip.2026-10-18T18-50.json",
  "current_hashes": {
    "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py": "adcbf4a65bc444aa9794ff447c660ef9950f2a513a6c8d8c24ef76d3171156b2",
    "packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py": "1d0b1970f8ca3d4e139060f322e3d82c9989b515cb62b2f881f1b7abc968dace",
    "packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py": "d88262205076138fb8a6f7f5bd115d9d2c79a492be82ce1c6920bec0866a82eb",
    "packages/discovery-runtime/src/drm_copilot_discovery/references.py": "9a9a53d31366abc67126422cee4e3f0a3a8cd3dc41b7384bf99c7f5ba95e187c",
    "packages/discovery-runtime/src/drm_copilot_discovery/transport_manifest.py": "dd5d8c18c179a99e4ebf34f83fb38924b3ca083e1ca9db3509156c10cac7722c",
    "packages/discovery-runtime/src/drm_copilot_discovery/source_snapshots.py": "729569bca5a65cb44e7911aef6d794b89d4d60603c5a5ef335b39d7ab06167bd",
    "tests/discovery_runtime/test_snapshot_export.py": "ea977b4e0165a917df5f538e41d274120d8b2542501362a81d7f1c325bc58cf5",
    "tests/discovery_runtime/test_snapshot_import.py": "5b11836f53f723f98f1f21f627b4a675e9bc21e6f1c7da6cec419b4d1a0fbf0e",
    "tests/discovery_runtime/source_snapshot_test_support.py": "5d0d54ff616425c92a8da95929006f56caa1a8cc7335949b0685b9a0a3f3e699",
    "tests/discovery_runtime/test_snapshot_replica_resolution.py": "c19c3350ae8dbb0a98a155c75a103c40e5900e3f64bc023f45bb0a014363430e"
  },
  "checks": {
    "exact_authorized_ten_path_inventory": true,
    "all_ten_working_hashes_match_inventory": true,
    "prior_nine_source_test_fixture_hashes_unchanged": true,
    "unchanged_13_case_proof_inputs": true,
    "unchanged_7_case_proof_inputs": true,
    "four_direct_context_cases_and_documented_unit": true,
    "test_is_under_500_lines": true,
    "narrow_run_measures_exact_missing_line_and_arc": true,
    "same_source_statement_and_arc_universe": true,
    "diagnostic_union_is_169_of_171_and_82_of_84": true,
    "historical_full_430_binding_unchanged": true,
    "explicit_unaccepted_status_and_434_next_population": true
  },
  "passed": 12,
  "failed": 0,
  "new_test": "tests/discovery_runtime/test_snapshot_replica_resolution.py",
  "new_test_lines": 75,
  "new_contexts": [
    "representative",
    "alias",
    "source",
    "unmatched"
  ],
  "retained_reference_cases": 20,
  "diagnostic_union": {
    "lines": "169/171",
    "arcs": "82/84"
  },
  "pending_full_population": 434,
  "disposition": "No new production issue. Retained 44 API executable-provenance and exact 13+7 reference proof remain applicable. The four isolated resolver cases close the measured preparation gap. The union is diagnostic only; full single-pass seven-stage verification, final raw coverage, reverse, contracts, integration and index audit remain required. Plan and AC remain 29/84 and 11/66."
}
```
