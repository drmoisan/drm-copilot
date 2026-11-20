# P6-T1 capture candidate review — issue 980

Status: CHANGES_REQUIRED. Receipt: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t1-executor-capture-review.2026-10-21T08-31.json`; SHA-256 `320d0bb4294c8e47baa378508b4011782866cce480ad852aa6dd71ee3a6271c8`.

- MC2-R1: `project_snapshot` inserts selected originals before enforcing merged count/raw-byte limits. Reserve exact capacity before retention; preserve overlap, immutable originals and the empty-marker path.
- MT1: compare the empty-marker projection to the same recomputed baseline projection. The fixture omitted the pre-existing `application` directory; the accepted loader correctly reports it missing.
- MC2-C1: add four exact capture guard controls and four projection exact/exhausted count/byte controls. Preserve the existing eleven capture identities through the proposed test-only split.

The actual precheck was 12 passed / 1 failed in 282.386613 seconds. All input bindings stayed unchanged. The 29-case run was held. Preliminary capture coverage is 19/23 body statements; it is not final acceptance proof. No additional reviewer behavior or native execution was performed.

No other concrete source, intent, type, size or default-compatibility finding remains open. The actual guarded migration-write case remains required. Package identity must be regenerated after repair; prior native operations remain separately qualified historical evidence.

Plan and AC checkoffs are unchanged: 46/84 tasks and 23/66 criteria. Current phase: P6. Next five: P6-T1, P6-T2, P6-T3, P7-T1, P7-T2.
