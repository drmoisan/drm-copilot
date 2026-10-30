# P3-T5 corrected evidence-link boundary proof

Timestamp: 2026-10-18T17:04:00Z
Command: `poetry run python SCRATCH/issue-980-p3t5-review-probes.py`
EXIT_CODE: 0
Output Summary: 36 checks passed, zero failed, 14.724 seconds. The production and accepted fixture hashes remained unchanged.

The actual complete planner now accepts local runtime provenance with exact bytes while leaving the feature's unknown observation unchanged. Generated links use the schema-valid local kind/ID form. The probe's expected reference was corrected to that accepted contract; no schema requirement was removed. The initial fixture failure and R1 production failure remain in their original receipts.

The bounded cases cover every evidence type's projection, nested arrays and collection members, unchanged sibling/approval/observation data, duplicate identities, imported or missing targets, malformed provenance, unrelated payloads and custom roots. The real planner also rejects stale target digests and missing grants. Narrow forwarding seams separately verify exact caller context/grants, independent local-proof eligibility, and unchanged wrapper outcomes for dry-run and commit; these seams do not claim additional writer or native I/O proof.

This closes the consolidated semantic finding. Final acceptance still requires the worker's complete ordered gate, coverage and source/index/prior preservation audit. [Raw proof and source hashes](p3t5-executor-boundaries.2026-10-18T17-04.json).

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
{"name": "real-complete-planner-retains-exact-bytes-and-unknown-state", "passed": true, "detail": null}
{"name": "real-stale-destination-digest", "passed": true, "detail": {"code": "MUTATION_PRECONDITION", "error": "MUTATION_PRECONDITION: Original content digest differs"}}
{"name": "real-ungranted-destination", "passed": true, "detail": {"code": "MUTATION_GRANT", "error": "MUTATION_GRANT: No exact kind/ID/path write grant"}}
{"name": "planner-forwards-exact-grants-and-trusted-context", "passed": true, "detail": null}
{"name": "local-proof-gate-remains-independent", "passed": true, "detail": {"code": "EVIDENCE_UNVERIFIED", "error": "EVIDENCE_UNVERIFIED: Evidence must identify locally verified bytes"}}
{"name": "wrapper-preserves-outcome-and-context-dry-false", "passed": true, "detail": null}
{"name": "wrapper-preserves-outcome-and-context-dry-true", "passed": true, "detail": null}
{"name": "all-projections-leave-baseline-unchanged", "passed": true, "detail": null}
{"name": "source-and-accepted-fixtures-stable", "passed": true, "detail": null}
{"task": "P3-T5", "passed": 36, "failed": 0, "elapsed_seconds": 14.724}
```
