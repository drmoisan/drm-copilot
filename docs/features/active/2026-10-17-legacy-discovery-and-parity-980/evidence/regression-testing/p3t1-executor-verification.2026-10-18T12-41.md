# P3-T1 independent executor verification

Timestamp: 2026-10-18 12:41:05 UTC

Command: `poetry run python SCRATCH/issue-980-verify-p3t1.py 2026-10-18T12-38`

EXIT_CODE: 0

## Output Summary

Accepted P3-T1. The seven new task paths and two explicitly authorized prerequisite corrections match the staged Git objects and recorded SHA-256 values. The other 209 accepted paths and all 24 frozen v1/export paths remain unchanged. All 48 independent mutation/provider checks remain bound to the applicable final source bytes, with nine separately verified report-digest invariants. Final real Windows integration passes six checks against the corrected provider. Raw coverage is 484/489 lines and 135/142 branch arcs; all 70 measured callable/class ranges meet the new-unit requirement, with a minimum of 93.75%. Maximum physical file length is 453.

The checker independently recomputed exact staged identities, working-file hashes, coverage totals, AST ranges, required docstrings and physical lengths. It verified Python 3.10 syntax and inspected the three mutation modules' package/standard-library imports. The existing six ordered architecture cases cover the original extracted modules; they are not represented as an exhaustive architecture harness for these new files. [Numerical proof](p3t1-executor-checks.2026-10-18T12-41.json) records the complete comparison.

## Task acceptance

- Immutable mutation proposals bind exact artifact kind, identifier, path, proposed bytes and original-content precondition. The complete prospective snapshot is loaded and validated before any mutation. Invalid proposed content cannot pass because the old document was valid.
- Exact grants, protected roots, structured identity and role-output context are enforced. An opaque payload claim cannot conceal a structured artifact; Markdown report identity follows its JSON peer. Unauthorized or invalid proposals leave all workspace bytes unchanged.
- Complete captured inputs, pinned inputs, parent identities and expected original digests are checked again before guarded publication. Unchanged bytes and repeated dry runs perform no writes or authority invalidation.
- The concrete guarded writer owns full-state checking, path revalidation, exclusive creation or digest-matched replacement and postcapture verification. Race, collision, changed-parent and partial-I/O cases fail explicitly. Prior successful writes and uncertain affected paths remain distinguishable; completion authority is invalidated or its invalidation failure is reported. No result mints native completion authority.
- The actual provider supplies retained parent handles/descriptors, exclusive staging, bounded reads, per-file atomic publication and explicit cleanup. The final Windows smoke verifies exclusive creation, retained-parent rename denial, replacement, stale/collision rejection, concurrent authorized-writer exclusion and handle/stage cleanup.
- The accepted report-root prerequisite correction excludes the exact absent reports root and its descendants from the derived-report digest, while retaining non-output missing inputs and the complete snapshot digest. First paired JSON/Markdown report creation succeeds without self-reference. Its separate [verification](p3t1-executor-report-root-verification.2026-10-18T11-37.md) confirms 38 affected tests, five reversed cases and unchanged 100% helper coverage.

The guarantee is cooperative serialization of authorized writers, optimistic complete-state/digest checks, retained verified parents and atomic individual publication. It does not provide a multi-file transaction or kernel digest-conditioned replacement against arbitrary processes that bypass the authorized guard. Later service/native integration must supply authenticated invocation/grants, the trusted common external lock path, configured read limits and real authority invalidation; client input cannot select those collaborators. Stale locks fail closed and are not stolen. These integration obligations and concurrency limits remain explicit P6/P7/P9/P10 handoff items.

## Quality and evidence provenance

The [specialist handoff](../other/p3t1-mutations.2026-10-18T12-38.md), its scoped patch and eight separate pass-13 command receipts establish one clean ordered task loop: Black, Ruff, full repository Pyright, architecture, units/property, contract/schema and integration. Format leaves seven files unchanged; Ruff and Pyright have zero diagnostics. The 89 focused tests and 89 reversed tests pass. The subsequent compatibility stage passes 232 tests, with the six already executed architecture cases excluded from that later stage. Final native integration begins after the compatibility command completes and passes all six operational checks.

[Raw coverage](p3t1-coverage.2026-10-18T12-38.json) and [metrics](p3t1-coverage-metrics.2026-10-18T12-38.json) agree: mutation_filesystem is 207/209 lines and 51/54 arcs; mutation_io is 130/131 and 31/32; mutation_plan is 147/149 and 53/56. All measured callable/class ranges meet 90%; CapturedWorkspace.inspect is 15/16, or 93.75%. The final single-line test-fixture correction is the only task source/test change since WIP commit `99e88cd08c9539f2972366a413cf7072ea725089`. No production bytes changed to clear the coverage gap.

The 42-case plan/I/O proof was captured before the Windows provider correction and published only after the explicit user resume. Its unchanged imported modules are bound by the [resume comparison](p3t1-executor-resume-binding.2026-10-18T12-12.json); it is not relabeled as corrected native evidence. The three provider cases use the corrected provider hash, and the final [Windows smoke](p3t1-windows-provider-smoke.2026-10-18T12-37.json) supplies current native proof. Two exact-grant regressions and the paired-report regression complete the 48-case independent mutation set. No broad independent probe suite was repeated.

Earlier failures remain preserved: the attrs-only Windows handle allowed parent relocation; its read/list access correction is directly verified. The user-interrupted pass 9 has no final coverage claim. The pass-11 fake-stat fixture failure and pass-12 87.5% callable gap remain explicit. The final established 89-test task suite was rerun after the bounded fixture correction rather than narrowed to obtain a clean result.

Python task gates pass. TypeScript, PowerShell and C# are unchanged by this task. Real Linux execution, full installed CLI/native-host workflows and repository-wide final QA remain assigned to later tasks; their completion is not claimed here.

No additional full-feature acceptance criterion is checked: initialization, native write enforcement, wrappers, publication and final QA retain later required proof. Plan progress is 25/84 and feature criteria remain 6/66 in each requirement source.

Current phase: Phase 3. Next tasks: P3-T2, P3-T3, P3-T4, P3-T5, P3-T6. Execution remains at the coordinator's per-task commit barrier until the next exact task is released.
