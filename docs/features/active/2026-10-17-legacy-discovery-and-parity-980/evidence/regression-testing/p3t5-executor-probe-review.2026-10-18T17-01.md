# P3-T5 independent boundary review

Timestamp: 2026-10-18T17:01:07Z
Command: `poetry run python SCRATCH/issue-980-p3t5-review-probes.py`
EXIT_CODE: 1
Output Summary: 28 checks passed. One real planner positive failed; remaining forwarding checks were not executed. Source and accepted fixture hashes stayed unchanged.

R1: the newly generated evidence link contains artifact_kind, id and path. The common artifact-reference schema requires repository, revision and sha256 whenever path is present. The narrow diagnosis below established three schema failures at the generated link. The existing local kind/ID reference form is sufficient; do not weaken the schema or fabricate transport identity. No other production defect was established by the completed review.

The earlier SCRATCH manifest-fixture correction removed the supplied collection from missing_paths; no repository source changed for that correction. Pure projection checks establish preservation only; they do not substitute for the failing prospective graph validation.

[Raw check result](p3t5-executor-probe-review.2026-10-18T17-01.json). [Exact planner diagnosis](p3t5-executor-planner-diagnosis.2026-10-18T17-01.json).

```text
{"name": "deterministic-exact-projection", "passed": true, "detail": null}
{"name": "explicit-create-and-original-digest-preconditions", "passed": true, "detail": null}
{"name": "runtime-link-preserves-entire-original-observation", "passed": true, "detail": null}
{"name": "source-projection-preserves-states", "passed": true, "detail": null}
{"name": "test-projection-preserves-states", "passed": true, "detail": null}
{"name": "observation-projection-preserves-states", "passed": true, "detail": null}
{"name": "documentation-projection-preserves-states", "passed": true, "detail": null}
{"name": "decision-projection-preserves-states", "passed": true, "detail": null}
{"name": "inventory-projection-preserves-states", "passed": true, "detail": null}
{"name": "nested-array-only-update", "passed": true, "detail": null}
{"name": "existing-exact-link-is-not-duplicated-and-other-link-remains", "passed": true, "detail": null}
{"name": "product-decision-collection-preserves-envelope-sibling-and-state", "passed": true, "detail": null}
{"name": "no-approval-container-is-created", "passed": true, "detail": {"code": "EVIDENCE_LINK_FIELD", "error": "EVIDENCE_LINK_FIELD: The selected link field does not exist"}}
{"name": "unspecified-behavior-collection-preserves-envelope-sibling-and-state", "passed": true, "detail": null}
{"name": "reject-extension-array", "passed": true, "detail": {"code": "EVIDENCE_LINK_FIELD", "error": "EVIDENCE_LINK_FIELD: Select a core evidence-reference array"}}
{"name": "reject-other-core-array", "passed": true, "detail": {"code": "EVIDENCE_LINK_FIELD", "error": "EVIDENCE_LINK_FIELD: Select a core evidence-reference array"}}
{"name": "reject-missing-field", "passed": true, "detail": {"code": "EVIDENCE_LINK_FIELD", "error": "EVIDENCE_LINK_FIELD: The selected link field does not exist"}}
{"name": "reject-scalar-state", "passed": true, "detail": {"code": "EVIDENCE_LINK_FIELD", "error": "EVIDENCE_LINK_FIELD: Select an existing link array"}}
{"name": "missing-target", "passed": true, "detail": {"code": "EVIDENCE_TARGET", "error": "EVIDENCE_TARGET: Select one captured local artifact"}}
{"name": "imported-target", "passed": true, "detail": {"code": "EVIDENCE_TARGET", "error": "EVIDENCE_TARGET: Select one captured local artifact"}}
{"name": "duplicate-id", "passed": true, "detail": {"code": "EVIDENCE_DUPLICATE", "error": "EVIDENCE_DUPLICATE: Evidence identity already exists"}}
{"name": "duplicate-evidence_id", "passed": true, "detail": {"code": "EVIDENCE_DUPLICATE", "error": "EVIDENCE_DUPLICATE: Evidence identity already exists"}}
{"name": "unrelated-supplied-payload", "passed": true, "detail": {"code": "EVIDENCE_PAYLOAD", "error": "EVIDENCE_PAYLOAD: Payload is not named by the record"}}
{"name": "malformed-short-pin", "passed": true, "detail": {"code": "EVIDENCE_RECORD", "error": "EVIDENCE_RECORD: Evidence metadata is invalid"}}
{"name": "malformed-bad-checksum", "passed": true, "detail": {"code": "EVIDENCE_RECORD", "error": "EVIDENCE_RECORD: Evidence metadata is invalid"}}
{"name": "malformed-bad-timestamp", "passed": true, "detail": {"code": "EVIDENCE_RECORD", "error": "EVIDENCE_RECORD: Evidence metadata is invalid"}}
{"name": "custom-evidence-root-is-respected", "passed": true, "detail": null}
{"name":"probe-harness-completed","passed":false,"detail":{"error":"MUTATION_INVALID: Prospective graph is invalid","traceback":"Traceback (most recent call last):\n  File \"SCRATCH\\issue-980-p3t5-review-probes.py\", line 192, in <module>\n    main()\n    ~~~~^^\n  File \"SCRATCH\\issue-980-p3t5-review-probes.py\", line 164, in main\n    plan = subject.plan_evidence_link(baseline, request, grants=grants)\n  File \"WORKTREE\\packages\\discovery-runtime\\src\\drm_copilot_discovery\\evidence_linking.py\", line 284, in plan_evidence_link\n    plan = plan_mutation(\n        baseline,\n    ...<2 lines>...\n        invocation=invocation,\n    )\n  File \"WORKTREE\\packages\\discovery-runtime\\src\\drm_copilot_discovery\\mutation_plan.py\", line 374, in plan_mutation\n    raise MutationError(\n    ...<3 lines>...\n    )\ndrm_copilot_discovery.mutation_plan.MutationError: MUTATION_INVALID: Prospective graph is invalid\n"}}
{"name": "source-and-accepted-fixtures-stable", "passed": true, "detail": null}
{"task": "P3-T5", "passed": 28, "failed": 1, "elapsed_seconds": 14.439}
```
