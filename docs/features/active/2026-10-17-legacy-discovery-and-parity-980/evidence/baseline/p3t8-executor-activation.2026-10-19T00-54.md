# P3-T8 verifier activation

Timestamp: 2026-10-19T00-54 UTC, captured when the verification command began.
Command: `poetry run python SCRATCH/issue-980-p3t8-capture-baseline.py`
EXIT_CODE: 0
Output Summary: Native C4 Astra/max authority matches the persisted receipt and current profile. All 266 accepted predecessor working-byte hashes and Git blobs are preserved, with 24 separately bound frozen compatibility paths. The accepted baseline is `e04136458147cdf24069b6bde563231f3c38c709`. The plan remains 31/84 and each authoritative acceptance source remains 11/66.

Raw manifest: [p3t8-executor-prior-manifest.2026-10-19T00-54.json](p3t8-executor-prior-manifest.2026-10-19T00-54.json). Historical working bytes and canonical Git bytes remain separately identified; any difference is proven to be only Git-declared CRLF-to-LF conversion. No file normalization or prior behavioral rerun was performed.

The approved scope is two new runtime modules (`source_read_models.py`, `source_reads.py`) and two task test modules (`test_source_reads.py`, `test_source_read_limits.py`). Selected read authority must intersect configured roots independently of write grants. Imported snapshot membership cannot be bypassed through documentation-root selection. Working bytes cannot inherit an unproved configured revision. Enumeration, input, output, line and match limits are independent, and the service exposes no process, network or mutation operation.

The worker owns implementation and tests. This verifier owns one consolidated candidate review before final gates, evidence reconciliation and any justified task/acceptance checkoff. The parent owns checkpoint, Git, scope changes and subsequent task release. P3-T8 is not accepted by this activation receipt.
