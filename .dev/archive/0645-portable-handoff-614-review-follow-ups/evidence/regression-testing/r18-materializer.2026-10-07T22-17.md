# R18 Materializer Regression (P4-T17)

Timestamp: 2026-10-07T22-17
Task: [P4-T17]
Command: node run-jest.cjs test/lib/validate/orchestration-handoff-failure-cause.test.ts test/lib/validate/orchestration-handoff-materializer.test.ts test/lib/validate/orchestration-handoff-materializer-production.test.ts test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts (from extensions/drm-copilot)
EXIT_CODE: 0
Output Summary: `Test Suites: 4 passed, 4 total`; `Tests:       90 passed, 90 total`; 0 failed. A second run with `--reporters=default` (DEV-10) printed one `PASS` line for each of the four files. `git diff --quiet 08ee030d9584bf15882fbb3654c8e38f34c7c359 -- extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts extensions/drm-copilot/test/lib/validate/orchestration-handoff-materializer-test-support.ts` exited 0. Row M2 observed `envelope-decode: ERR_ENCODING_INVALID_ENCODED_DATA` as the plan assumed (Node v24.14.0; `TypeError`, code `ERR_ENCODING_INVALID_ENCODED_DATA`), so the M2 stop condition did not trigger.

## Per-file results (second run)

```
PASS test/lib/validate/orchestration-handoff-materializer-production.test.ts
PASS test/lib/validate/orchestration-handoff-failure-cause.test.ts
PASS test/lib/validate/orchestration-handoff-materializer.test.ts
PASS test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts
```

## Materializer Case Table rows (P4-T16), all passed

M1 checkpoint-read: EACCES; M2 envelope-decode: ERR_ENCODING_INVALID_ENCODED_DATA; M3 git-status: ENOENT; M4 destination-projection: invalid; M5 archive-write: EEXIST; archive-readback: EACCES; M6 archive-write: Error (HANDOFF_SOURCE_HASH_MISMATCH); M7 candidate-write: EEXIST; candidate-readback: EACCES; M8 candidate-write: Error; M9 candidate-validate: HANDOFF_CANDIDATE_MISMATCH; M10 candidate-replace: EPERM; M11 candidate-replace: EPERM; candidate-cleanup: EBUSY; M12 materialized, key absent; M13 workspace-root: unresolved; M14 target-path: unresolved; M15 target-path: unresolved; M16 envelope-read: ENOENT; M17 validated, key absent.

`orchestration-handoff-failure-cause.test.ts` length after P4-T16: 359 lines.

Result: PASS
