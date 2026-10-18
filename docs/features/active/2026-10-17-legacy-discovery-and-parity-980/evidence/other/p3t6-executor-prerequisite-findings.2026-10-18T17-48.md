# P3-T6 bounded prerequisite review

Timestamp: 2026-10-18 17:48:36 UTC

Status: CORRECTION REQUIRED; P3-T6 remains unchecked at 29/84 tasks and 11/66 acceptance criteria.

## Scope and result

The original accepted baseline is `27753e5f8b9a6cd1d85b9d1d28d2999800af209a`. The parent authorized four predecessor modules (`path_policy.py`, `mutation_plan.py`, `mutation_io.py`, `references.py`) and the new `transport_manifest.py` helper as a prerequisite to the existing export/import task. This review does not accept the pending full `source_snapshots.py` API.

The independent memory-only probe passed 31 checks and failed one in 17.529 seconds. All five production hashes and five fixture/input hashes were unchanged before and after execution. It exercised one actual complete prospective mutation planner, exact manifest/member bytes and grants, root-only invocation, header-last ordering, complete physical input retention, invalid/unbound replica rejection, and ordinary duplicate rejection. No commit, native write, network call, or task checkoff occurred.

## R1: Export removes ordinary local mutation identity

The same schema-valid `EvidenceLink` for local feature `alpha` projects three intended changes before export. The complete export plan succeeds and its graph has no reference findings. Applying only that prospective snapshot to the original captured workspace causes the unchanged `evidence_changes` request to fail with `EVIDENCE_TARGET: Select one captured local artifact`.

Cause: `replica_aliases` chooses an imported representative and `index_references` omits the ordinary local record. The accepted local evidence-linking guard correctly rejects an imported target. Export must preserve ordinary local identity while explicit source/transport references continue to bind to proven imported bytes. A correction may not add an unverified duplicate exemption, change ordinary grants, or use an arbitrary first match. Both local and imported reference contexts require direct regression proof.

## Retained controls and limits

The remaining 31 checks passed, including changed bytes, missing/extra members, forged route fields, wrong ID/version/digest/count/pin, importer verification flags without authority, missing/excess grants, specialist invocation rejection, original input retention, manifest-last projection, and ordinary/unbound duplicate blockers. Final proof must bind the corrected bytes; this result is historical pre-correction evidence. The worker's separate 32-case pass does not supersede the independently reproduced local identity failure.

One read-only `rg` command initially used brace syntax rejected by the PowerShell parser (`Missing argument in parameter list`, exit 1, zero mutations). It was repeated with four explicit paths and exited 0. No policy or hook was changed.

## Command receipt

Command: `poetry run python SCRATCH/issue-980-p3t6-executor-prerequisite.py`

EXIT_CODE: 1

OutputSummary: 31 passed, 1 failed; stable source and fixture hashes; correction required.

```text
frozen_production_hashes: PASS
complete_member_bytes: PASS
missing_member: PASS
extra_member: PASS
changed_member_bytes: PASS
wrong_member_id: PASS
forged_route: PASS
wrong_manifest_digest: PASS
unsupported_version: PASS
mutable_pin: PASS
wrong_counts: PASS
verification_flags_not_digest_authority: PASS
export_metadata_still_bound: PASS
wrong_root_denied: PASS
local_evidence_projection_before_export: PASS
ordinary_grant_stays_closed: PASS
exact_transport_grant: PASS
root_route_rejects_specialist: PASS
incomplete_set: PASS
extra_grant: PASS
real_complete_planner_positive: PASS
manifest_published_last: PASS
all_write_contexts_bound: PASS
all_physical_inputs_retained: PASS
all_export_members_retained: PASS
proven_replicas_resolve_once: PASS
local_evidence_projection_after_export: FAIL
unbound_replicas_remain_duplicates: PASS
changed_raw_replicas_remain_duplicates: PASS
real_capture_agrees_with_projection: PASS
ordinary_same_byte_duplicate_still_rejected: PASS
bound_bytes_unchanged: PASS
{"passed":31,"failed":1,"elapsed_seconds":17.529}
```

Machine-readable proof: [p3t6-executor-prerequisite-probe.2026-10-18T17-48.json](../regression-testing/p3t6-executor-prerequisite-probe.2026-10-18T17-48.json).
