# P2-T6 independent probe setup

Timestamp: 2026-10-18T09-23

Command: `poetry run python SCRATCH/issue-980-review-p2t6.py`

EXIT_CODE: 1

Output Summary: The probe used an obsolete snapshot property name. The probe stopped before completing its case set. This is a verifier fixture/setup failure, not a production finding.

Captured terminal diagnostic (host traceback paths omitted):

```text
AttributeError: 'DiscoverySnapshot' object has no attribute 'digest'
```

Correction: Use the accepted immutable snapshot.sha256 property. Only issue-scoped operational scratch changed. The subsequent complete result is recorded separately.
