# P2-T6 independent probe setup

Timestamp: 2026-10-18T09-23

Command: `poetry run python SCRATCH/issue-980-review-p2t6.py`

EXIT_CODE: 1

Output Summary: The diagnostic fixture used an uppercase code outside the declared identifier grammar. The probe stopped before completing its case set. This is a verifier fixture/setup failure, not a production finding.

Captured terminal diagnostic (host traceback paths omitted):

```text
AssertionError: SCHEMA_INVALID /diagnostics/0/code: 'SCAN_FAILURE' does not match the lowercase identifier pattern.
```

Correction: Use the schema-valid code scan-failure. Only issue-scoped operational scratch changed. The subsequent complete result is recorded separately.
