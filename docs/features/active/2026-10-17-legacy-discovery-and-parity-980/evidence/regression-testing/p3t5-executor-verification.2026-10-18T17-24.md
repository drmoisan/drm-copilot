# P3-T5 independent executor verification

Timestamp: 2026-10-18 17:24:55 UTC
Command: `poetry run python SCRATCH/issue-980-p3t5-final-check.py docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t5-final-audit.2026-10-18T17-22.json`
EXIT_CODE: 0
Output Summary: VERIFIED. All 387 independent evidence, index, preservation, raw-coverage and ordering checks pass with zero findings. These are evidence checks, not additional behavioral tests.

## Scope and acceptance

The original task baseline is `1cc73b60cd636f186ca0269bf3942d32acd18105`; checked WIP `5046c52468b9509557a0f48de805d926ef70854b` does not replace it. The [specialist handoff](../other/p3t5-evidence-linking-handoff.2026-10-18T17-22.md) and [final index audit](../qa-gates/p3t5-final-audit.2026-10-18T17-22.json) identify one production module, two prescribed test modules and the approved fixture-only split. All four working hashes and index objects match, allowing only recorded checkout newline normalization in the three test/support files. All 251 accepted prior paths and 24 frozen compatibility paths remain unchanged. Maximum size is 480 physical lines; no suppression or undocumented callable was added.

The retained [36-case behavioral proof](p3t5-executor-boundaries.2026-10-18T17-04.json) verifies all seven evidence types, exact bytes and preconditions, deterministic projection, nested/collection linkage, preserved states and unrelated records, duplicate and missing targets, invalid provenance and payloads, custom roots, exact grants, local proof eligibility and shared result forwarding. Its real runtime planner positive passed after the local-reference correction. The [six binding checks](p3t5-executor-proof-binding.2026-10-18T17-08.json) and this final audit establish identical executable AST and unchanged fixture inputs after intent-only documentation edits. Passing behavior was not rerun merely for new hashes.

The initial path-bearing local reference failed the authoritative transport-reference schema. The correction uses the existing local kind/ID form and retains exact payload provenance in the evidence record. Registration projects create-only record/payload bytes and changes only the recognized evidence-reference array of the selected containing artifact. Source/test proof requires captured immutable repository bytes and checkout identity; descriptive or unavailable evidence cannot satisfy the operation. The public planner forwards trusted grants/invocation unchanged and requires local verification after complete prospective validation. The commit wrapper returns the shared writer result unchanged, including partial failure. No observation, runtime result or approval state is promoted by linking.

## Ordered gate and measured coverage

The final frozen pass 1 completed format, lint, full Pyright, architecture, focused tests/coverage and reversed isolation, compatibility/contracts, then composed integration. The [ordered sequence](../qa-gates/p3t5-final-ordered-sequence.2026-10-18T17-22.json) and individual command receipts have independently checked starts, durations, exits and unchanged source bindings. The six existing architecture cases retain their original package scope; current-module import/I/O inspection is separate.

- Forward: 61 passed in 130.21 seconds; reversed: 61 passed in 52.03 seconds; contracts: 543 passed in 26.37 seconds. No failures, errors or skips remain in these complete final populations.
- [Raw production coverage](../qa-gates/p3t5-final-raw-coverage.2026-10-18T17-22.json): 108/108 lines and 38/38 arcs. All ten class/function ranges were independently recomputed from AST locations and raw lines; every range is 100%.
- [Unchanged dependency coverage](../qa-gates/p3t5-final-compatibility-coverage.2026-10-18T17-22.json): 296/297 lines and 148/150 arcs, with zero numeric delta or lost previously executed lines/branches.
- [Forward/reverse bindings](../qa-gates/p3t5-final-test-bindings.2026-10-18T17-22.json) and the [independent record](p3t5-executor-final-checks.2026-10-18T17-24.json) bind those measurements to the current four files and index.

Python task gates pass. Other languages are untouched. Repository-wide final coverage, exhaustive property/mutation checks and installed CLI/native-host verification remain their later assigned tasks.

## Composed proof and limitations

The final [17-check composed proof](p3t5-composed-final.2026-10-18T17-22.json) uses the actual public evidence API, accepted planner, guarded writer and local primitives with fresh memory OS seams. It verifies no-effect dry-run, exact three-output publication, exclusive creation and digest-bound replacement, authority invalidation, locally verifiable bytes, unchanged observation/unrelated bytes, duplicate rejection, explicit partial outcomes and released guards/anchors. This is not a new native-platform run.

Isolated wrapper units use exact collaborator arguments and result identity. Actual writer behavior is covered by the composed proof. Full graph validation remains slower than isolated transforms: final composed duration was 72.07 seconds, with preview 7.343, publication 37.898 and partial failure 18.545 seconds. These measured limitations do not establish a latency SLO or an optimization result. Cooperative authorized-writer serialization and individual atomic publication retain the accepted limits; no kernel digest-CAS or multi-file transaction is claimed.

Earlier harness, schema-reference and source-pin fixture failures remain retained. The source-pin fixture originally omitted checkout identity and correctly failed local evidence lookup; the positive fixture was corrected while the missing-pin negative remained. Unavailable preparation coverage is not presented as numeric proof. Final acceptance uses the complete frozen pass above.

## Checkoff disposition

P3-T5 is verified. Only its plan checkbox and traceability entry are updated. Progress becomes 29/84 tasks; all three requirement sources remain unchanged at 11/66 criteria. No current whole criterion requiring CLI or native hook enforcement is inferred from this API. P3-T6 remains unreleased until the coordinator commits and pushes this accepted task.

## Captured checker output

```text
{
  "timestamp": "2026-10-18T17:24:35.409952+00:00",
  "task": "P3-T5",
  "baseline": "1cc73b60cd636f186ca0269bf3942d32acd18105",
  "head": "5046c52468b9509557a0f48de805d926ef70854b",
  "checks_passed": 387,
  "findings": [],
  "unchanged_prior": 251,
  "frozen_paths": 24,
  "coverage_raw_sha256": "934c34768175ad54c0f4b774a9c478358c4d0ab980e2d159a13bc9833819cde0",
  "coverage_audit": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t5-pass1-coverage-audit.2026-10-18T17-19.json",
  "coverage": {
    "covered_lines": 108,
    "lines": 108,
    "covered_branches": 38,
    "branches": 38,
    "ranges": 10,
    "minimum_range_percent": 100
  },
  "max_physical_lines": 480,
  "physical_lines": {
    "packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py": 343,
    "tests/discovery_runtime/evidence_test_support.py": 117,
    "tests/discovery_runtime/test_evidence_linking.py": 480,
    "tests/discovery_runtime/test_evidence_payloads.py": 354
  },
  "audit": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t5-final-audit.2026-10-18T17-22.json",
  "raw_coverage": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t5-final-raw-coverage.2026-10-18T17-22.json",
  "test_counts": {
    "pass1": 61,
    "reverse1": 61,
    "pass1-contracts": 543
  },
  "integration": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-composed-final.2026-10-18T17-22.json",
  "integration_checks": 17,
  "integration_timings": {
    "preview_seconds": 7.343463199998951,
    "commit_seconds": 37.89777049999975,
    "partial_failure_seconds": 18.544830200000433
  },
  "gate_receipts": [
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-architecture.2026-10-18T17-17.md",
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-contracts.2026-10-18T17-21.md",
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-coverage-check.2026-10-18T17-19.md",
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-format.2026-10-18T17-17.md",
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-integration.2026-10-18T17-22.md",
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-lint.2026-10-18T17-17.md",
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-reverse.2026-10-18T17-20.md",
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-tests.2026-10-18T17-19.md",
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-types.2026-10-18T17-17.md"
  ],
  "retained_semantic_cases": 36,
  "compatibility_coverage": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t5-final-compatibility-coverage.2026-10-18T17-22.json",
  "compatibility_totals": {
    "lines": "296/297",
    "branches": "148/150"
  },
  "compatibility_coverage_deltas": {
    "packages\\discovery-runtime\\src\\drm_copilot_discovery\\evidence_rules.py": {
      "covered_lines": 0,
      "covered_branches": 0,
      "num_statements": 0,
      "num_branches": 0
    },
    "packages\\discovery-runtime\\src\\drm_copilot_discovery\\revision_rules.py": {
      "covered_lines": 0,
      "covered_branches": 0,
      "num_statements": 0,
      "num_branches": 0
    }
  }
}
```
