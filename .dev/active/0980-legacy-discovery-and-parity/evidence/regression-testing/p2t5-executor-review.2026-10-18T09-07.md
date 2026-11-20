# P2-T5 bounded decision review

Timestamp: 2026-10-18T09-07
Command: poetry run python SCRATCH/issue-980-review-p2t5.py
EXIT_CODE: 0
Output Summary: 36 diagnostic probes executed; 34 matched their initial expectations and two produced the outcomes below. This diagnostic runner returns its observations and is not an acceptance gate.

Source SHA-256 before and after: `8fde15d749cd75680c2a39e80d766152e9644d572fb72a2ce3eea8370b98e005`. Every structured artifact in these probes passed the authoritative v2 schema validator. Every graph had zero reference findings and retained its snapshot digest. [Machine-readable results](p2t5-executor-review.2026-10-18T09-07.json) preserve all cases.

1. **Historical conflict after a covering replacement:** approved decisions A and B overlap on the same key; approved C fully covers and explicitly supersedes both. The result correctly exposes only C as eligible but still reports `DECISION_CONFLICT` for A/B. Task P2-T5 requires conflicts for overlapping **unsuperseded** approvals. The specialist received this bounded correction.
2. **Observed uncertainty versus target resolution:** resolving the linked question through an approved target decision leaves the feature's observed timing unknown. Decision validation passes, while accepted claim validation reports `CLAIM_UNRESOLVED` because unknown observations require an open legacy question. A separate open legacy question preserves the historical uncertainty and passes both validators. The coordinator is determining the documented disposition; no prior claim-rule edit is authorized by this result.

The other probes cover owners, approval evidence types and payload integrity, proposed/rejected policy, unknown feature/client selectors, key and selector separation, wildcard overlap, full/partial supersession, cycles, retirement scope, resolution owner/text binding, and observed-evidence versus target-policy resolution. The current production source parses with Python 3.10's grammar; the worker had already replaced its initial incompatible alias syntax.

Two earlier probe setup attempts failed schema validation before the affected rule assertion. Their individual receipts retain the exact schema diagnostics; the probe fixtures were corrected by declaring ready criterion applicability and an approved retirement status. No production mutation was made by the verifier.
