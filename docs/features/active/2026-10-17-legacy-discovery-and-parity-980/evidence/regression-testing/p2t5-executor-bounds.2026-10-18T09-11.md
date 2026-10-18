# P2-T5 supersession depth and diagnostic bounds

Timestamp: 2026-10-18T09-11
Command: poetry run python SCRATCH/issue-980-p2t5-bounds.py
EXIT_CODE: 0
Output Summary: Two bounded probes pass: 1,200 decision records yield one final approval and zero findings; 110 invalid-owner records yield exactly the 100-finding limit, one blocking FINDINGS_LIMIT marker and no approvals.

Both probes preserve input snapshot digests and bind to final production SHA-256 `618289a9f28eaad58a86148e9a3dba2a9513701fb319900657021c9a71a00c65`. Approved and historical seed shapes pass authoritative schema validation once; expanded graphs vary valid identifiers and references only, using the accepted parser, reference index and evidence rules. The long-history graph and rules completed in 0.633 seconds; this is one bounded observation, not a performance guarantee. Results are retained in the [independent checks](p2t5-executor-checks.2026-10-18T09-11.json).
