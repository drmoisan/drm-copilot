# P3-T6 public snapshot API checkpoint

Timestamp: 2026-10-18 18:18:37 UTC

Status: checked work in progress. P3-T6 remains unchecked; 29/84 tasks and 11/66 acceptance criteria are accepted. The task acceptance baseline remains `27753e5f8b9a6cd1d85b9d1d28d2999800af209a`; the preceding prerequisite checkpoint is `a4abf7737f656ad49cc39b5ab588d1352dc48cd4`.

This checkpoint preserves the public export/import API, its prescribed tests, and the previously authorized fixture-only support extraction. The API projects captured source contracts and evidence into immutable, manifest-bound snapshots, supports configured source import and combined repository identities, preserves identical existing bytes, rejects conflicts, and delegates publication to the shared mutation planner and guarded writer.

The [worker inventory](p3t6-api-wip.2026-10-18T18-14.json) binds nine owned source/test paths; four changed since the prerequisite checkpoint and five prerequisite production files remain unchanged. Its 19 evidence entries and all nine raw hashes were checked before staging. The inventory records 251 unaffected predecessor paths and 24 frozen scopes preserved; the maximum production/test length is 483 lines.

Validation completed for this WIP:

- Black, Ruff, and full Pyright passed.
- The focused API suite passed 33/33 tests in 59.01 seconds.
- The [composed readiness proof](../regression-testing/p3t6-api-composed-readiness.2026-10-18T18-14.json) passed 11/11 checks in 140.584 seconds, including actual shared export/import publication, new destination import, exact bytes, dry-run, manifest-last partial failure and recovery, repeated skip, staging preservation, and stale-input rejection.
- The [independent API review](p3t6-executor-api-review.2026-10-18T18-15.md) passed 44/44 checks in 16.62 seconds, with source and input bindings stable. No production defect was established. Two preceding SCRATCH fixture-construction failures remain recorded as diagnostic attempts only.

Both specialists are frozen with no process running. This commit does not establish full task acceptance. Complete current-source module/class/callable coverage, the ordered seven-stage task loop, affected predecessor regression and contract checks, final composed integration, exact preservation audit, and final specialist handoff remain pending. The previously recorded native initialization latency and transport deadline/cancellation review concern remain open for their assigned later integration work.

After this checkpoint, resume the same P3-T6 with fresh routing receipts, retain the original acceptance baseline, and commit the independently accepted task before releasing P3-T7. The ignored canonical orchestration checkpoint is persisted separately and is not added to Git.
