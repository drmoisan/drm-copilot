# P3-T4 independent draft boundaries

Timestamp: 2026-10-18T15-57
Command: poetry run python SCRATCH/issue-980-p3t4-review-probes.py
EXIT_CODE: 0
Output Summary: 25/25 assertions passed with both production hashes unchanged. This proves the bounded behavior set, not complete task gates or feature acceptance.

Exact cases and hashes: [probe result](p3t4-executor-boundaries-final.2026-10-18T15-57.json).

The current proof confirms deterministic identities and bytes, truthful default unknowns, exact unresolved linkage, absent synthesized evidence/approval, optional and inherited requirements, custom roots, preserved collection records, collisions, missing grants/feature links and prohibited summary/runtime/nested promotions through real memory-backed planner calls.

Both scripts used accepted memory fixtures, with no native workspace writes or temporary test files. The earlier fixture failure and unfrozen initial probe remain historical. Final worker gates, staged-byte audit and per-unit coverage are still required before P3-T4 checkoff.

## Captured output

```text
{"name": "contract-deterministic", "passed": true, "detail": null}
{"name": "contract-null-unknowns", "passed": true, "detail": null}
{"name": "contract-exact-question-links", "passed": true, "detail": null}
{"name": "contract-no-evidence-approval", "passed": true, "detail": null}
{"name": "optional-offline-mobile-not-required", "passed": true, "detail": null}
{"name": "real-contract-planner-positive", "passed": true, "detail": null}
{"name": "contract-missing-exact-grant", "passed": true, "detail": {"error": "MUTATION_GRANT: No exact kind/ID/path write grant", "findings": []}}
{"name": "contract-rejects-observation_state", "passed": true, "detail": {"error": "DRAFT_CLAIM: Creation cannot change observation_state", "findings": []}}
{"name": "contract-rejects-lifecycle", "passed": true, "detail": {"error": "DRAFT_CLAIM: Creation cannot change lifecycle", "findings": []}}
{"name": "contract-rejects-product_decision_status", "passed": true, "detail": {"error": "DRAFT_CLAIM: Creation cannot change product_decision_status", "findings": []}}
{"name": "custom-paths", "passed": true, "detail": null}
{"name": "inherited-requirements-monotonic", "passed": true, "detail": null}
{"name": "custom-real-planner-positive", "passed": true, "detail": null}
{"name": "append-preserves-prior-question", "passed": true, "detail": null}
{"name": "existing-feature-collision", "passed": true, "detail": {"error": "MUTATION_PRECONDITION: Original content digest differs", "findings": []}}
{"name": "scenario-multifeature-links", "passed": true, "detail": null}
{"name": "scenario-null-expectation-no-execution", "passed": true, "detail": null}
{"name": "scenario-question-planned-dimension", "passed": true, "detail": null}
{"name": "scenario-real-planner-positive", "passed": true, "detail": null}
{"name": "scenario-missing-feature", "passed": true, "detail": {"error": "MUTATION_INVALID: Prospective graph is invalid", "findings": ["REFERENCE_MISSING", "REFERENCE_MISSING"]}}
{"name": "scenario-rejects-result_status", "passed": true, "detail": {"error": "DRAFT_CLAIM: Creation cannot change result_status", "findings": []}}
{"name": "scenario-rejects-runs", "passed": true, "detail": {"error": "DRAFT_CLAIM: Creation cannot change runs", "findings": []}}
{"name": "scenario-rejects-pre_state_capture", "passed": true, "detail": {"error": "DRAFT_CLAIM: A new observation plan cannot claim captured execution", "findings": []}}
{"name": "scenario-unknown-cannot-invent-expectation", "passed": true, "detail": {"error": "MUTATION_INVALID: Prospective graph is invalid", "findings": ["SCHEMA_INVALID"]}}
{"name": "nested-verified-phase-rejected-by-draft-creation", "passed": true, "detail": {"error": "DRAFT_CLAIM: Creation cannot assert verified behavior", "findings": []}}
{"task": "P3-T4", "elapsed_seconds": 22.499, "source_hashes_before": {"packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": "a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d", "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": "0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1"}, "source_hashes_after": {"packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py": "a317f11b60ccffcb05fe040a28162388dd40d87de06506d4615455260755a00d", "packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py": "0e43b453774fcd10f669dc643ebcf33a11712ad9778a92343d85829d7ae0c1a1"}, "source_stable": true, "passed": 25, "failed": 0}
```
