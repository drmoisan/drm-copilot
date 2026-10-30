# P2-T3 bounded executor review

Timestamp: 2026-10-18T08-22
Command: poetry run python SCRATCH/issue-980-review-p2t3.py
EXIT_CODE: 1
Output Summary: Twelve independent cases ran; eight passed and four failed, establishing two blocking defects in the pre-gate evidence boundary.

The [machine receipt](p2t3-executor-review.2026-10-18T08-22.json) retains both reviewed source hashes and every outcome. Each timestamp and line-span counterexample first passes the authoritative evidence schema; these are semantic implementation defects rather than invalid fixture assumptions.

- **P2T3-R1 — inconsistent timestamp semantics.** `_metadata` uses `datetime.fromisoformat`, rejecting the valid timestamp `2026-01-01t00:00:00z` and the known leap-second forms `2016-12-31T23:59:60Z` and `2017-01-01T00:59:60+01:00`. All three pass the existing authoritative RFC3339 checker but produce `EVIDENCE_TIMESTAMP` in this module. Reuse the established public timestamp predicate with an explicit string check and preserve these regressions.
- **P2T3-R2 — unhandled integer overflow.** A schema-valid one-based span with `start=1` and `end=10**400` raises `OverflowError: int too large to convert to float` in `_line_number` because `math.isfinite` coerces the integer. Handle integers without float conversion so this input returns `EVIDENCE_LINE_RANGE`; retain valid integer-valued floats and invalid boolean/fraction coverage.

Passing cases verify an ordinary RFC3339 capture, inclusive and integer-valued-float spans, reversed/out-of-range rejection, separate identical runtime payloads, a replaced runtime payload rejection and documentation-only HEAD advancement with matching source bytes. Remote freshness remains `unknown`. The runtime capture lookup uses local bytes and does not require a new capture to exist in the application commit.

This is the consolidated review return for the persisted evidence/revision boundaries. The specialist is still completing malformed-input guards, tests and ordered gates. Transport entry hashes and sizes are in this task; canonical manifest generation/importer-state hashing remains assigned to P3-T6. No production, tests, plan checkbox or acceptance criterion was changed by this review.
