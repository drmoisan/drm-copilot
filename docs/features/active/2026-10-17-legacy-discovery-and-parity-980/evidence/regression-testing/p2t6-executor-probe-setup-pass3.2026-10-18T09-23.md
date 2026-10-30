# P2-T6 independent probe setup

Timestamp: 2026-10-18T09-23

Command: `poetry run python SCRATCH/issue-980-review-p2t6.py`

EXIT_CODE: 1

Output Summary: The exact duplicated ledger object failed schema uniqueItems before the semantic duplicate-ID case. The probe stopped before completing its case set. This is a verifier fixture/setup failure, not a production finding.

Captured terminal diagnostic (host traceback paths omitted):

```text
AssertionError: SCHEMA_INVALID /components: array has non-unique elements.
```

Correction: Keep the repeated component ID but vary its substantive runtime-rationale text so the semantic identity check is reached. Only issue-scoped operational scratch changed. The subsequent complete result is recorded separately.
