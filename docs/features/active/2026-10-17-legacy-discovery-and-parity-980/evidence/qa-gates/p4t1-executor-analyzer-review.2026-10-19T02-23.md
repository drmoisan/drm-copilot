# P4-T1 consolidated analyzer candidate review

Timestamp: 2026-10-19T02-23
Command: Read the 26 bound candidate files and accepted-base changes; poetry run python SCRATCH/issue-980-p4t1-analyzer-candidate-probes.py; poetry run python SCRATCH/issue-980-p4t1-analyzer-review-record.py
EXIT_CODE: 0
Output Summary: Three concrete acceptance defects reproduced using isolated in-memory collaborators. The candidate requires the bounded repair below before final gates. No source or test files were changed and no existing suite was rerun.

The reviewed candidate remains bound to the original accepted baseline `a94c44fa31e66d830d01203ee9cc068fce2deef1` and the 02-14 candidate manifest. All 26 working-byte hashes are recorded in the adjacent JSON. The completed loader prerequisite review and its 62-case proof are retained without repetition. The worker's 238 passing cases and measured coverage remain valid for their bound bytes and covered scenarios; they do not cover the three cases below.

## R1: capture_snapshot

Snapshot-derived inputs do not apply exclusion_rules before assigning inspected state. Actual capture_workspace classifies generated report Markdown as documentation, so a generated report becomes a source component and pin_inventory_sources requests it from Git.

Required correction: Apply the same configured output/evidence/authored exclusion semantics to snapshot-derived inputs. Retain truthful excluded accounting and rationale; do not create a component, digest, or Git request for excluded output. Preserve accepted loader and coverage-rule behavior.

Focused verification: Add an in-memory ordinary capture_workspace case with an existing generated report/acceptance document under the artifact root. Confirm excluded accounting, absence of components/Git requests for the output, and guarded first/repeated publication without broadening source scope.

## R2: pin_inventory_sources

The trusted reader identity is verified before missing blobs are read but never after those reads. A reader changing checkout during the final read returns an apparently valid captured workspace.

Required correction: Recheck the repository identity after the bounded immutable reads and reject a changed id/revision before returning the enriched capture.

Focused verification: Add a fake reader that returns the correct last blob then changes checkout identity. Require an actionable failure; preserve stable-reader and existing-object reuse behavior.

## R3: capture_inputs

The entry budget is checked only when popping visited paths and separately per directory. A profile limit of four permits seven queued paths before rejection; larger trees can allocate a frontier proportional to the square of the configured budget.

Required correction: Enforce an aggregate discovered/pending-entry bound before enqueueing further paths, with duplicate and overlapping-root handling consistent with deterministic traversal. Preserve early exclusion pruning and truthful frontier accounting.

Focused verification: Add a branching-tree fake whose individual directories each fit the limit but whose aggregate frontier exceeds it. Assert rejection before the pending/discovered budget is exceeded, with unchanged deterministic duplicate/root behavior.

## Retained review and next transition

Compatibility adapters, new callable documentation and intent comments, file sizes, domain neutrality, immutable values, source linkage, deterministic assembly, ledger proposal boundaries, guarded publication, and modified legacy assertion preservation were reviewed together. No additional policy repair is requested. Relocated unchanged predecessor behavior is not reopened.

The writer should make one cohesive repair within its approved ownership and preserve all existing cases. Independent follow-up is limited to the three fixes and new regression cases, followed by reuse of this review and successful final bound receipts. P4-T1 and all acceptance criteria remain unchanged.

Current phase: P4. Next tasks after P4-T1 acceptance: P4-T2, P4-T3, P4-T4, P4-T5, P4-T6.
