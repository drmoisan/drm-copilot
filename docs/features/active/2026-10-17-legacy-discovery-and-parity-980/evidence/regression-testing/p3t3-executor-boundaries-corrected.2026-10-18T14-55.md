# P3-T3 corrected boundary verification

Timestamp: 2026-10-18 14:55:18 UTC
Command: `poetry run python SCRATCH/issue-980-p3t3-initial-probes.py 'post-WIP correction verification'`
EXIT_CODE: 0
Output Summary: All eight original behavioral cases pass in 4.02 seconds, with unchanged before/after hashes for all three production modules. No behavioral probe was added, removed or weakened after the initial six-pass/two-failure result.

R1 now rejects concurrent reactivation with CONFIGURATION_CHANGED and two protected-registry reads. R2 rejects a known candidate appearing before guarded commit without protected activation publication or authority invalidation. Normal root lifecycle, activation-required state, active locator deletion, denied dry-run, parent identity freshness and fail-closed partial activation remain passing.

This run follows WIP commit e0f5b74fd0217ea266db2675ec0ec919f73084db. Task acceptance baseline remains 639c37269ed12b0bd4b5d74d66723e2f5ce4dedd. The companion JSON records all cases and exact source hashes. These corrections close the two independent semantic findings; final task coverage, ordered contracts and actual native provider proof remain pending. No plan or acceptance-criterion checkbox changes.
