# P2-T5 independent probe setup attempt 2

Timestamp: 2026-10-18T09-07
Command: poetry run python SCRATCH/issue-980-review-p2t5.py
EXIT_CODE: 1
Output Summary: Probe setup rejected retired feature without approved product-decision status before the retirement assertion.

Captured diagnostic:

```text
AssertionError: [('SCHEMA_INVALID', '/product_decision_status', "'approved' was expected")]
```

Correction: Set product_decision_status=approved on the retired feature fixture. No production code changed. This is retained failure evidence, not a successful task gate.
