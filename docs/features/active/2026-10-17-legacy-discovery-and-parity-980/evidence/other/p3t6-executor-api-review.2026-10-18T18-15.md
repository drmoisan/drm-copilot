# P3-T6 scoped public API review

Timestamp: 2026-10-18 18:15:52 UTC

Status: bounded API review passed; P3-T6 remains unchecked.

Acceptance baseline: `27753e5f8b9a6cd1d85b9d1d28d2999800af209a`. Prerequisite checkpoint: `a4abf7737f656ad49cc39b5ab588d1352dc48cd4`.

The independent [44-case result](../regression-testing/p3t6-executor-api.2026-10-18T18-15.json) verifies deterministic whole-container dependency closure, exact unchanged artifact and runtime/pinned payload bytes, missing or changed evidence rejection, malformed selections, immutable source pins, exact manifest identity and digest, no overwrite, importer attribution, configured destination roots, both target clients, repeated-import attribution preservation, duplicate/foreign identities, configured-location conflicts, and combined source/target identity reuse. Pure projections preserved both input snapshots. No production defect was established in this API review.

The earlier documentation-staging concern is resolved: files outside the configured artifact root remain captured documentation inputs. The worker's [11-check composed result](../regression-testing/p3t6-api-composed-readiness.2026-10-18T18-14.json) proves the actual new-destination import through the shared planner and guarded writer while retaining all staging bytes. It also covers export/import dry-run, exact publication, manifest-last partial failure, recovery, repeat and stale rejection. The independent matrix does not claim to duplicate that publication proof.

All nine owned hashes match the [checked WIP inventory](p3t6-api-wip.2026-10-18T18-14.json). The five prerequisite production hashes are unchanged from the accepted prerequisite checkpoint; retained R1 13/13 and R2 7/7 results continue to bind their recorded inputs and source bytes. Those historical fixtures are not asserted to equal the newly extracted test-support file. The worker inventory records 251 unaffected predecessor paths and 24 frozen scopes preserved, with maximum 483 physical lines; final independent index/preservation and raw callable audits remain required.

Two failed SCRATCH harness attempts are retained individually: [missing captured duplicate file](../regression-testing/p3t6-executor-api-initial.2026-10-18T18-13.md) and [incorrect combined fixture client ownership](../regression-testing/p3t6-executor-api-fixture2.2026-10-18T18-14.md). They passed 39 and 41 markers respectively before fixture construction failed, and do not represent completed proof. Only the corrected 44/44 invocation has final before/after source binding. No production/test correction resulted from these diagnostics.

Remaining acceptance: complete current-source module/class/callable coverage, the clean ordered seven-stage task loop, affected predecessor regression/contract evidence, final composed proof, exact index/preservation audit, and final specialist handoff. Plan remains 29/84; existing ACs remain 11/66. No task or criterion is checked off here, and P3-T7 is unreleased.
