# P3-T2 consolidated initialization review

Timestamp: 2026-10-18T13:13:36Z

Task state: NOT VERIFIED. The acceptance baseline remains a74cb240a7698c1454a8e6018ac23862cd91dab0; projection WIP cba0ee0870018c1a2a57556be877ec1d7475ae08 is included in the task.

The corrected four-case check passes: dry-run makes no physical changes or revocations; first initialization and repeat preserve bytes and metadata; online is the default mode; the honest empty draft passes structural validation and fails completion. Two existing-directory/bootstrap controls and one handoff control also pass. Four assertions fail across three distinct contract defects. All three diagnostic processes exited zero because their collectors retained failures; assertion results remain authoritative.

## R1: Newly created empty-directory identities are not checked after open

In init_io.py, _directory retains handles but records only path strings for newly created directories. _after_bootstrap checks the resulting kind for those paths and skips identity comparison. A direct postcondition probe and a real guarded bootstrap with an injected post-open replacement both accept a different identity at docs/migration/discovery/evidence. The pre-existing docs-directory identity negative correctly fails, demonstrating the distinction. Retain the opened identities of newly created directories and compare them with final non-following metadata before reporting success. The existing cooperative-writer and optimistic-check boundary applies; no stronger kernel transaction guarantee is requested.

Proof: [bootstrap boundary results](p3t2-executor-bootstrap-boundaries.2026-10-18T13-13.json), cases new-directory-identity-substitution-rejected and bootstrap-capture-rejects-post-open-directory-substitution.

## R2: The handoff to ordinary mutations adopts changed parent metadata

commit_initialization compares the post-bootstrap physical snapshot digest with the virtual proposal digest, then creates a new mutation baseline. It does not bind that capture to the checked post-bootstrap metadata. Replacing docs with the same bytes and namespace but a different identity after bootstrap still reaches plan_mutation. The corresponding unchanged control reaches the same boundary as intended. The probe reuses an actual validated plan and actual successful bootstrap and stops at the next mutation-planning call; it does not claim an ordinary artifact write occurred. Carry the checked physical post-bootstrap state across this handoff and reject changed metadata before rebasing the ordinary artifact plan.

Proof: [handoff results](p3t2-executor-bootstrap-handoff.2026-10-18T13-13.json), changed-parent-handoff; raw input digest unchanged, metadata changed, and new mutation planning reached.

## R3: Existing artifact conflicts have only an unstructured exception

An invalid existing coverage-ledger.json correctly prevents all writes, but initialize_workspace raises plain ValueError with the path embedded in its sentence. It returns no typed path/status disposition or structured finding. This does not satisfy the specified conflict classification or permit the later service to report the conflicting file without parsing prose (spec initialization and service-result sections). Return an explicit conflict result or a typed conflict exception carrying relative path and finding/status data. Preserve the proven no-write behavior and verify incompatible profiles plus concurrent bootstrap collisions through the same structured contract.

Proof: [bootstrap boundary results](p3t2-executor-bootstrap-boundaries.2026-10-18T13-13.json), invalid-existing-artifact-has-structured-conflict.

## Verification boundary

No implementation was changed by the verifier. Remaining task gates, coverage, exact resource mirrors, prior-file preservation, complete conflict/recovery tests, and final source binding remain the specialist's handoff requirements. Existing successful initialization proof may be retained only for unchanged behavior and clearly identified hashes. P3-T2 is unchecked and P3-T3 is unreleased.
