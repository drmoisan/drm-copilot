# P3-T5 evidence registration and linking handoff

Timestamp: 2026-10-18T17-22
Status: TASK_READY_FOR_VERIFICATION. Four authored paths are frozen; executor acceptance and coordinator task commit remain required before P3-T6.
Acceptance baseline: 1cc73b60cd636f186ca0269bf3942d32acd18105. Checked WIP: 5046c52468b9509557a0f48de805d926ef70854b.
Plan: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/plan.2026-10-17T22-38.md, P3-T5; full-feature. The fixture-only evidence_test_support.py extraction was authorized before creation under the existing same-component size rule.

## Scope and interfaces

EvidencePayload carries immutable supplied bytes and a safe relative path. EvidenceLink selects one exact local artifact/member, original-byte digest, immutable provenance, optional payloads and an existing typed evidence-reference field. Neither value establishes native authority.

evidence_changes validates the supplied evidence schema, rejects duplicate record/evidence IDs and ambiguous/imported targets, preserves all unselected fields/collection siblings, and emits create-only evidence record/payload changes plus an exact digest-bound containing-artifact update. Local links use the accepted {artifact_kind,id} reference form. Exact payload paths and checksums remain in the evidence record. Unsupported arrays, missing targets, escaping paths, unrelated payloads and approval creation fail explicitly.

plan_evidence_link delegates the complete prospective graph to plan_mutation with unchanged authenticated grants/invocation, then requires assess_evidence to establish local byte proof. Source/test proof requires captured immutable Git objects and checkout identity; working-tree bytes or descriptive URLs cannot replace it. link_evidence delegates dry-run/publication to commit_mutation and returns its complete or partial MutationResult unchanged. Linking never changes observation, runtime execution or product approval state.

| Path | Working SHA-256 | Physical lines |
| --- | --- | --- |
| packages/discovery-runtime/src/drm_copilot_discovery/evidence_linking.py | 98a0b6dda37acb98fe143ce680f3a5caa3b65eccc15047394c1929d1a0cc4f18 | 343 |
| tests/discovery_runtime/test_evidence_linking.py | 8bb7317277b9c76236821e4adf6399f3acbcf9d2bdd77ba9f62b2ef42998a392 | 480 |
| tests/discovery_runtime/test_evidence_payloads.py | c53705640d294f496f7d6b1ca663d761b55baf5b9bcba7fee43e7f5fe6c85e14 | 354 |
| tests/discovery_runtime/evidence_test_support.py | bf84d9146bcac7ccbdb0fb6f712e15ae9aff176f0bb232c3f03ed6b3374695e3 | 117 |

Exact working/index SHA values and Git blob identities are in docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t5-final-audit.2026-10-18T17-22.json; any CRLF checkout normalization is recorded there. All 251 accepted prior paths and 24 frozen v1/export paths remain unchanged. No new suppression or undocumented callable was found. Scoped staged patch: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t5-scoped-patch.2026-10-18T17-22.md.

## Baseline and final QA

Baseline Ruff and full Pyright were clean; 90 accepted evidence/revision tests passed in 19.71 seconds. Baseline evidence_rules covered 110/110 executable lines and 42/42 arcs; revision_rules covered 186/187 lines and 106/108 arcs. The new module was absent at task entry, so prior new-module/callable coverage is not applicable. Final compatibility coverage deltas are recorded in docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t5-final-compatibility-coverage.2026-10-18T17-22.json: {"packages\\discovery-runtime\\src\\drm_copilot_discovery\\evidence_rules.py": {"covered_branches": 0, "covered_lines": 0, "num_branches": 0, "num_statements": 0}, "packages\\discovery-runtime\\src\\drm_copilot_discovery\\revision_rules.py": {"covered_branches": 0, "covered_lines": 0, "num_branches": 0, "num_statements": 0}}. This focused task gate does not claim a new repository-wide coverage measurement.

The complete frozen sequence passed formatting, lint, full type checking, module architecture/package checks, all forward and reversed task tests, schema/package/export compatibility, and the composed integration proof. Lint/type/test regression deltas are zero. Tests use fresh in-memory stores and no temporary files, process execution or network. Wrapper units verify exact collaborator arguments and successful/partial result identity; actual writer outcomes are tested separately below.

- pass1: 61 tests; 0 failures, 0 errors; 130.162 seconds.
- reverse1: 61 tests; 0 failures, 0 errors; 51.960 seconds.
- pass1-contracts: 543 tests; 0 failures, 0 errors; 26.337 seconds.

| New module | Covered lines | Covered arcs |
| --- | --- | --- |
| evidence_linking.py | 108/108 | 38/38 |

All class/function ranges meet 90%; minimum 100.000000%. Exact AST ranges: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t5-pass1-coverage-audit.2026-10-18T17-19.json. Raw coverage: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t5-final-raw-coverage.2026-10-18T17-22.json. Forward/reverse bindings: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t5-final-test-bindings.2026-10-18T17-22.json. Ordered timestamps/exits: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p3t5-final-ordered-sequence.2026-10-18T17-22.json.

Ordered command receipts:

- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-architecture.2026-10-18T17-17.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-contracts.2026-10-18T17-21.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-coverage-check.2026-10-18T17-19.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-format.2026-10-18T17-17.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-integration.2026-10-18T17-22.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-lint.2026-10-18T17-17.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-reverse.2026-10-18T17-20.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-tests.2026-10-18T17-19.md
- docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-pass1-types.2026-10-18T17-17.md

## Composed proof and limitations

The final composed proof passed all 17 assertions using the actual public evidence API, accepted graph planner, GuardedMutationWriter and LocalMutationPrimitives with fresh in-memory OS seams. It covers no-effect dry-run, exact record/payload/link publication, exclusive create and digest-bound replacement dispositions, authority invalidation, unchanged observation state and unrelated bytes, exact local evidence, duplicate registration, retained-handle cleanup, and an injected failure during the second publication with explicit prior success, conflict, findings and uncertain paths. Result: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t5-composed-final.2026-10-18T17-22.json. Timings: {"commit_seconds": 37.89777049999975, "partial_failure_seconds": 18.544830200000433, "preview_seconds": 7.343463199998951}.

Complete graph reload/validation makes composed operations slower than isolated projection tests; these measured durations remain a review limitation. No production cache, validator or new I/O provider was introduced. Existing provider platform proof is reused; this task adds no OS-platform claim. Cooperative authorized-writer serialization, optimistic freshness and individual atomic publication retain their accepted limits; no kernel digest-CAS or multi-file transaction is claimed.

## Retained corrections and evidence

The initial generated path-bearing local reference lacked the immutable transport fields required by the common schema. The exact real-planner failure was retained and the link was corrected to the local ID form. The executor's corrected 36-case proof passed, then six AST/input checks rebound the final documentation-only production edit without repeating behavior.

Preparation diagnostic 10 recorded 56 passes, one source-pin fixture failure and four unrun cases in 232.71 seconds on stable bytes. The fixture supplied a pinned blob but omitted checkout identity, correctly producing EVIDENCE_CONTENT_UNAVAILABLE; the corrected source/test positives and existing negatives passed in the eight-case continuation. Its expensive real writer unit calls were isolated through the existing commit collaborator, while all actual dry-run/success/partial/unrelated-byte assertions moved to the composed proof. The missing historical raw coverage report and failed audit attempt are retained as unavailable preparation coverage, not a successful numeric gate. The explicit-report preflight and final raw coverage above supply the measured result.

Earlier formatting/type/fixture failures remain preserved. The corrected 17-check composed diagnostic passed before this complete final sequence. Only final frozen full-suite data is acceptance evidence; no partial diagnostic is presented as a passing task gate.

No later task is implemented. Trusted host invocation/grant wiring, permitted-route enforcement, full installed CLI/host proof and exhaustive P11 property/mutation work remain pending under their existing task owners.
