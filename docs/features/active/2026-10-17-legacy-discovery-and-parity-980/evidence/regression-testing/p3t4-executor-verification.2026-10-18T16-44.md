# P3-T4 independent executor verification

Timestamp: 2026-10-18 16:44:35 UTC
Command: `poetry run python SCRATCH/issue-980-p3t4-final-check.py final docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t4-final-audit.2026-10-18T16-42.json`
EXIT_CODE: 0
Output Summary: VERIFIED. All 395 independent evidence, index, preservation, raw-coverage and ordering checks pass with zero findings. These checks are not additional behavioral test cases.

## Scope and acceptance

The original acceptance baseline remains `c114f98583599ebd5ee02281ece3524b2909fa51` across WIPs `d9791ad7baaed3e6990bc6dc6c06b8feb204482c` and `eb172ab85c40738f0cacaa7635a96a8b0f37a8de`. The [specialist handoff](../other/p3t4-drafting-handoff.2026-10-18T16-42.md) and [final index audit](../qa-gates/p3t4-final-audit.2026-10-18T16-42.json) identify the exact two new production modules, two prescribed test modules and authorized fixture-only split. All five working hashes and indexed objects match, allowing only configured checkout newline normalization. All 246 accepted prior paths and 24 frozen compatibility paths remain unchanged. Maximum size is 431 physical lines; no suppression was added.

The [25 boundary cases](p3t4-executor-boundaries-final.2026-10-18T15-57.json) and [four nested-observation cases](p3t4-executor-nested-final.2026-10-18T15-57.json) remain bound to the final production hashes. They verify deterministic IDs and bytes, configured roots and inherited requirements, missing links, linked unknown dimensions, multiple selected features, null unknown expectations, preserved unresolved records, collisions, exact caller grants and no-effect dry-run. Draft creation invents no evidence or approval and cannot promote observations or runtime results to verified/passed.

The consolidated nested-transition defect is corrected in every before/action/after position. Completed observations are rejected; unknown or contradictory phases retain or receive an open-question link and add state_transitions to the question even when the summary is inferred. Supplied inference remains inference. Malformed transition shapes still reach the authoritative schema rejection. The specialist's 15-case phase/state matrix and retained independent correction cases cover these distinctions.

Both public creation paths reuse the accepted mutation planner and commit contract. Required unresolved records are published with the selected artifact; existing collection identity, unrelated records and original-byte compare-and-swap preconditions are preserved. Trusted invocation/grant context is supplied by the caller and is not created by these APIs.

## Ordered quality proof

The new complete pass 2 ran formatting, Ruff, full repository Pyright, architecture, focused coverage and reversed isolation, compatibility/contracts, then composed integration. [The ordered sequence](../qa-gates/p3t4-final-ordered-sequence.2026-10-18T16-42.json), individual command receipts and independently checked start/duration ordering establish the clean restarted loop on unchanged source. Current-module structural inspection is separate from the six existing package architecture cases; those cases do not enumerate the new modules.

- Forward tests: 78 passed; reversed tests: 78 passed; compatibility/contracts: 551 passed. These completed populations have no failures, errors or skips.
- Raw production coverage: 169/170 executable lines and 51/52 branch arcs. Contracts cover 119/120 lines and 37/38 arcs; scenarios cover 50/50 lines and 14/14 arcs.
- All 18 class/function ranges were independently recomputed from AST locations and raw executable lines. The minimum is 94.117647%, above the required 90%.
- All five forward/reverse before-and-after hashes match the current index. [Raw coverage](../qa-gates/p3t4-final-raw-coverage.2026-10-18T16-42.json), [test bindings](../qa-gates/p3t4-final-test-bindings.2026-10-18T16-42.json) and the [independent check record](p3t4-executor-final-checks.2026-10-18T16-44.json) retain the numerical evidence.

Python task gates pass. TypeScript, PowerShell and C# are untouched. Repository-wide final QA and exhaustive property/mutation checks remain Phase 11.

## Composed publication and retained limitations

The final [ten-check composed proof](p3t4-composed-integration.2026-10-18T16-41.json) uses the public draft APIs, accepted graph planner, guarded writer and existing local primitives with fresh memory OS seams. It verifies no-effect preview, exact contract creation, exact scenario creation plus collection replacement, authority invalidation, released guards/handles, preserved unrelated bytes, truthful incomplete discovery and collision rejection. It is composed integration evidence and does not claim a new native-platform run.

Full graph capture and validation make these workflow cases slower than isolated unit checks: forward/reverse suites took approximately 710.50/304.16 seconds. The final composed proof took 58.542 seconds; preview, contract commit and scenario commit measured approximately 4.517/19.527/28.405 seconds. These timings remain explicit limitations. No latency SLO or optimization result is claimed, and no current task acceptance criterion specifies one.

The initial nested-observation failures, wrong-environment import attempt and incomplete scenario fixture are retained. The first stage-7 harness failed before a draft API call because its root representation did not match the provider. Only the SCRATCH fixture was corrected. The successful pass-1 stages and corrected diagnostic remain historical; final acceptance uses the restarted complete pass 2. No passing independent behavioral suite was repeated for this audit.

## Checkoff disposition

P3-T4 is verified. Only its plan checkbox and traceability entry are updated. Feature criteria remain 11/66 in each requirement source; criteria requiring CLI or native hook enforcement are not inferred from these APIs. After the checkoff, progress is 28/84 tasks. P3-T5 remains unreleased until the coordinator completes the accepted-task commit and push.

## Captured checker output

```text
{
  "timestamp": "2026-10-18T16:43:28.555684+00:00",
  "task": "P3-T4",
  "phase": "final",
  "baseline": "c114f98583599ebd5ee02281ece3524b2909fa51",
  "head": "eb172ab85c40738f0cacaa7635a96a8b0f37a8de",
  "checks_passed": 395,
  "findings": [],
  "unchanged_prior": 246,
  "frozen_paths": 24,
  "coverage_raw_sha256": "01d2a31da3ed8ee2e9ade9a350d80110f5ca6c4ad2d70106ff59ac9e2dd69b54",
  "coverage_audit": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t4-pass2-coverage-audit.2026-10-18T16-35.json",
  "coverage": {
    "covered_lines": 169,
    "lines": 170,
    "covered_branches": 51,
    "branches": 52,
    "ranges": 18,
    "minimum_range_percent": 94.11764705882354
  },
  "max_physical_lines": 431,
  "physical_lines": {
    "packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": 396,
    "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": 231,
    "tests/discovery_runtime/draft_test_support.py": 126,
    "tests/discovery_runtime/test_draft_contracts.py": 431,
    "tests/discovery_runtime/test_draft_scenarios.py": 378
  },
  "audit": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t4-final-audit.2026-10-18T16-42.json",
  "raw_coverage": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t4-final-raw-coverage.2026-10-18T16-42.json",
  "test_counts": {
    "pass2": 78,
    "reverse2": 78,
    "pass2-contracts": 551
  },
  "integration": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-composed-integration.2026-10-18T16-41.json",
  "integration_checks": 10,
  "integration_timings": {
    "contract_preview_seconds": 4.516668900003424,
    "contract_commit_seconds": 19.527445300002,
    "scenario_commit_seconds": 28.404962800006615
  },
  "gate_receipts": [
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-architecture.2026-10-18T16-23.md",
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-contracts.2026-10-18T16-40.md",
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-coverage-check.2026-10-18T16-35.md",
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-format.2026-10-18T16-23.md",
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-integration.2026-10-18T16-41.md",
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-lint.2026-10-18T16-23.md",
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-reverse.2026-10-18T16-40.md",
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-tests.2026-10-18T16-35.md",
    "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-types.2026-10-18T16-23.md"
  ]
}
```
