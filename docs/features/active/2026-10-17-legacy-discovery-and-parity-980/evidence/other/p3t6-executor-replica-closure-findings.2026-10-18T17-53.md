# P3-T6 correction-specific replica closure review

Timestamp: 2026-10-18 17:53:35 UTC

Status: CORRECTION REQUIRED; prerequisite WIP remains pending. P3-T6 is unchecked; 29/84 tasks and 11/66 acceptance criteria remain accepted.

## Measured correction and remaining defect

The R1 context correction passed 13/13 checks in 12.081 seconds on unchanged source and fixture hashes: the same local evidence projection succeeds before/after exact export, ordinary lookup preserves local origin, explicit source/transport links select proven imported bytes, and changed/unbound/ordinary duplicate controls remain blockers. This passing result is retained independently from the next failure.

The corrected index returns a physical imported record from an explicit source reference but constructs outgoing links only for representative records. A direct check through the existing `ClaimContext` and `TargetProof` APIs reproduced the consequence. The complete loaded fixture has no snapshot, index, evidence or revision findings. Its ordinary feature has 18 resolved outgoing targets; its proven imported replica has zero. `TargetProof.source_payload` recognizes the same capture as source proof for the ordinary feature but returns false for the imported source. The existing source-versus-target proof exclusion is therefore lost through the newly returned imported record.

The closure probe passed five controls and failed those two expectations in 8.011 seconds. All five prerequisite modules, five accepted caller modules and four fixture helpers remained byte-identical throughout. This directly measures the existing exclusion helper; it does not claim a complete parity-completion exploit or run a full parity workflow.

Correction must preserve both logical uniqueness and physical imported graph/proof context. It remains within the existing references/transport helper authorization. No generic duplicate exemption, grant relaxation, prior claim/parity edit, or new task is authorized. Final narrow proof must retain R1's local/imported contexts and show the imported source's outgoing links and source-proof exclusion are preserved.

## R1 context command receipt

Command: `poetry run python SCRATCH/issue-980-p3t6-executor-r1.py adcbf4a65bc444aa9794ff447c660ef9950f2a513a6c8d8c24ef76d3171156b2 1d0b1970f8ca3d4e139060f322e3d82c9989b515cb62b2f881f1b7abc968dace d88262205076138fb8a6f7f5bd115d9d2c79a492be82ce1c6920bec0866a82eb 0232a94b0398644b0efae402d2aac50bea870525e4e2e736b98014d655fc8461 f70fba9b394490881f2e6c0e8d05fd9011b810ae15339dfe18a84c2ffef19f0f`

EXIT_CODE: 0

OutputSummary: 13/13 corrected context and conflict checks passed; no mutation or task acceptance.

```text
frozen_production_hashes: PASS
local_evidence_projection_before_export: PASS
actual_export_projection_valid: PASS
local_evidence_projection_after_export: PASS
ordinary_lookup_keeps_local_identity: PASS
pinned_source_reference_uses_imported_bytes: PASS
transport_reference_uses_imported_bytes: PASS
manifest_links_retain_physical_imported_targets: PASS
changed_replica_bytes_still_block: PASS
unbound_replica_still_blocks: PASS
ordinary_same_byte_duplicate_still_blocks: PASS
physical_local_and_imported_bytes_retained: PASS
all_bound_bytes_unchanged: PASS
{"passed":13,"failed":0,"elapsed_seconds":12.081}
```

## Replica closure command receipt

Command: `poetry run python SCRATCH/issue-980-p3t6-executor-replica-links.py`

EXIT_CODE: 1

OutputSummary: 5 passed, 2 failed; imported physical links and source-proof exclusion require correction.

```text
actual_loaded_graph_valid: PASS []
explicit_source_selects_imported: PASS
ordinary_source_has_outgoing_links: PASS 18
imported_source_retains_outgoing_links: FAIL 0
ordinary_source_proof_cannot_be_target_proof: PASS
imported_source_proof_cannot_be_target_proof: FAIL
bound_bytes_unchanged: PASS
{"passed":5,"failed":2,"elapsed_seconds":8.011}
```

Exact results: [R1 contexts](../regression-testing/p3t6-executor-r1-context.2026-10-18T17-53.json) and [replica closure](../regression-testing/p3t6-executor-replica-links.2026-10-18T17-53.json). Both operational processes exited; no repository production file, plan, AC, checkpoint or index was changed by the verifier.
