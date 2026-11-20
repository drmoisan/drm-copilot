# P5-T2 frozen graph source review

Timestamp: 2026-10-20T06-53

Command: poetry run python SCRATCH/issue-980-p5t2-graph-probes.py; poetry run python SCRATCH/issue-980-p5t2-graph-review-publish.py

EXIT_CODE: 0

Output Summary: GRAPH_SOURCE_REVIEW_REQUIRES_SCOPED_REPAIR. Complete source finding set: GR1 and GR2. No behavioral probe remains open.

GR1: `ParityProjection.axes` omits required per-client authored passed, failed, blocked and not-run counters (spec.md:452). The bounded probe produced identical online rows for all four statuses. Add truthful authored status counts separately from evidence-backed verification, retaining conflict, optionality and disposition distinctions.

GR2: `name in requirements.modes` repeatedly scans a tuple. For 8/32/64 custom modes, measured equality comparisons are 52/592/2,208 while charged work is 19/67/131. At 64 modes the method returns despite only 192 remaining work units. Reserve one mode index and reuse membership, or reserve actual aggregate comparison work before traversal. Counted regressions must avoid time thresholds.

The remaining frozen source properties, policy and size checks are clear. Exact sources and executed probes are preserved in the payload; the rejected initial instrumentation is explicitly qualified. Existing helper/outcome reviews are reused, and no suite was replayed.

Graph test evidence reconciliation follows its owner freeze. This receipt does not accept P5-T2 or change any task/AC checkbox. Phase P5: 42/84 tasks, 17/66 ACs. Next: P5-T2, P5-T3, P5-T4, P5-T5, P6-T1.
