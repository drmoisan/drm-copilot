# P3-T4 draft contract and scenario handoff

Timestamp: 2026-10-18T16-42
Status: TASK_READY_FOR_VERIFICATION; all five authored paths are frozen. Independent executor checkoff and the coordinator's task commit remain required before P3-T5.
Acceptance baseline: c114f98583599ebd5ee02281ece3524b2909fa51. Checked WIPs: d9791ad7baaed3e6990bc6dc6c06b8feb204482c and eb172ab85c40738f0cacaa7635a96a8b0f37a8de.
Plan of record: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/plan.2026-10-17T22-38.md, P3-T4, with the authorized same-component test-fixture split under line 28. Work Mode: full-feature.

## Behavior and interfaces

ContractDraft carries selected feature identity/name and immutable structured planning fields. contract_changes produces a deterministic feature-contract create plus a create/CAS update to the configured unresolved collection. Default observations stay unknown with null statements, open linked questions and no evidence or approval. Configured/client requirements are inherited. Supplied inference remains inference; verified/intentionally-unspecified observations are rejected, including nested before/action/after phases. Unknown nested phases receive the same link and add state_transitions to the question even when the summary is inferred.

ScenarioDraft requires unique selected feature IDs and caller-supplied environment, fixture, action, preconditions and observation plan. scenario_changes preserves explicit planning context, creates no execution record and leaves unknown expectations null. Its generated question links every selected feature and planned dimension. Supplied known expectations retain their stated basis and must pass the accepted graph validators. Creation cannot mark runtime passed, repeated or evidence-backed.

plan_contract/plan_scenario call the accepted shared mutation planner with exact grants supplied by a trusted caller and optional invocation. Caller authentication remains the responsibility of the host boundary. create_contract/create_scenario call the accepted shared commit/dry-run path with an injected writer. Neither layer creates native authority, a second validator or a second publication algorithm. Existing collection IDs, other records and extensions are preserved with original-byte CAS; conflicts and missing links fail before writes. Dry-run returns planned outputs without writes or revocation.

## Exact scope and index binding

| Path | Working-byte SHA-256 | Physical lines |
| --- | --- | --- |
| packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py | a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d | 396 |
| packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py | 0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1 | 231 |
| tests/discovery_runtime/test_draft_contracts.py | 76ec394037afad9a5700ad914358e6cccfc1e11c29bc1f2fb1670eff6cdbe296 | 431 |
| tests/discovery_runtime/test_draft_scenarios.py | 3bde4e6aa5e7d2aff71724f569f8cefe838926518eceb1c5d5bad56a6e6bc108 | 378 |
| tests/discovery_runtime/draft_test_support.py | 90e3ab8e7a77a824dd010292147c32712bcf05ae965db23c68b409868c8eb236 | 126 |

Exact Git blobs/index SHA values and permitted CRLF checkout normalization are recorded in docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t4-final-audit.2026-10-18T16-42.json. All 246 accepted prior paths and 24 frozen v1/export paths remain unchanged. No new suppression or missing docstring was found. The review patch is docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t4-scoped-patch.2026-10-18T16-42.md.

## Baseline and ordered validation

Baseline Ruff and full Pyright were clean; 98 accepted observation/runtime-claim tests passed. Their baseline coverage was 217/220 executable lines and 125/132 branch arcs across unchanged claim_rules/runtime_claim_rules. Exact baseline evidence: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/baseline/p3t4-baseline-index.2026-10-18T16-02.json. The two new production modules were absent at the accepted task baseline, so their prior module/class/callable coverage is not applicable. The prior-path audit preserves accepted implementations; this task does not claim a new repository-wide coverage measurement.

The final stable sequence passed Black, Ruff, full Pyright, current-module architecture checks plus six existing package architecture cases, complete focused forward/reversed tests, compatibility/contracts, then composed integration. Lint/type/test regression deltas are zero. No unit test uses temporary files, processes or network.
The ordered step exits, completion timestamps and unchanged five-path hashes are recorded in docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t4-final-ordered-sequence.2026-10-18T16-42.json.

- pass2: 78 tests, 0 failures, 0 errors, 710.437 seconds.
- reverse2: 78 tests, 0 failures, 0 errors, 304.116 seconds.
- pass2-contracts: 551 tests, 0 failures, 0 errors, 6.317 seconds.

| New module | Covered executable lines | Covered branch arcs |
| --- | --- | --- |
| draft_contracts.py | 119/120 | 37/38 |
| draft_scenarios.py | 50/50 | 14/14 |

All measured callable/class ranges meet the 90% requirement; the minimum is 94.117647%. Exact ranges: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t4-pass2-coverage-audit.2026-10-18T16-35.json. Raw coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t4-final-raw-coverage.2026-10-18T16-42.json. Forward/reverse source bindings: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t4-final-test-bindings.2026-10-18T16-42.json.

Ordered command receipts:

- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-architecture.2026-10-18T16-23.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-contracts.2026-10-18T16-40.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-coverage-check.2026-10-18T16-35.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-format.2026-10-18T16-23.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-integration.2026-10-18T16-41.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-lint.2026-10-18T16-23.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-reverse.2026-10-18T16-40.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-tests.2026-10-18T16-35.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-pass2-types.2026-10-18T16-23.md

## Integration, timing and preserved failures

The separate composed proof passed all ten checks through the public draft API, shared graph planner, GuardedMutationWriter and LocalMutationPrimitives with fresh in-memory OS seams. It checks preview without effects, exact contract creation, exact scenario creation plus collection CAS, honest null/not-run results, unrelated bytes, revocation, released guard/parent handles, incomplete discovery and existing-ID rejection. It adds no native provider and does not claim a new OS-platform run. Exact result and timings: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t4-composed-integration.2026-10-18T16-41.json; {"contract_commit_seconds": 19.527445300002, "contract_preview_seconds": 4.516668900003424, "scenario_commit_seconds": 28.404962800006615}.

Complete snapshot capture/validation makes the composed cases slower than pure unit checks; recorded durations remain a review limitation. No caching or unrelated optimization was introduced. The accepted native-provider fidelity proof remains unchanged.

Initial lint/type failures, the wrong-environment import-collection attempt, the nested-phase rejection/linkage findings and the missing environment.extensions fixture failure remain preserved. The WIP's 19 passing contract cases and later 4 passing scenario controls are historical partial checks; only the complete final frozen run is acceptance evidence. Executor's retained final 25 boundary plus four nested cases are independently bound to these production bytes.

The first stage-7 scratch harness stopped before invoking a draft API because a POSIX fixture root was assigned to the Windows-aware local provider. The corrected harness copies the same seed bytes into the existing platform-valid memory disk and recaptures that physical model. Its complete ten-check diagnostic passed before the second WIP checkpoint. No repository source/test bytes changed. Pass 1's successful earlier stages and failed setup receipt are historical; pass 2 restarted from formatting and supplies the complete ordered final evidence above.

No later task is implemented. Trusted native context/grant wiring, permitted-route enforcement and installed CLI/host validation remain later work. P11 retains exhaustive property/mutation coverage. Related ACs requiring native hooks remain pending.
