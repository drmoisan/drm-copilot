# P3-T1 corrected provider boundary probes

Timestamp: 2026-10-18 11:20:24 UTC

Command: `poetry run python SCRATCH/issue-980-p3t1-provider-probes.py`

EXIT_CODE: 0

## Output Summary

Three provider probes pass against stable mutation_filesystem.py SHA-256 `69f2b59123d7651fc3d3634a67786488b22f4f78b9c0a65f4683870f78e4f831`: the actual native staging method closes and removes its owned partial stage after an injected write error without deleting a foreign collision; a parent replaced between pathname inspection and handle opening is rejected before publication and all entered handles unwind; and a 16,777,217-byte original is replaced when the explicit configured read bound is 33,554,432 bytes.

The [structured result](p3t1-executor-provider-probes.2026-10-18T11-20.json) preserves call sequences and actual outcomes. All filesystem behavior was exercised through isolated memory directories or mocked OS primitives. The initial verifier adapter mismatch is retained separately in [interface correction evidence](p3t1-executor-provider-interface.2026-10-18T11-19.md).

This verifies the three bounded provider corrections at the recorded source version. Final staged bytes, remaining plan cases, ordered quality gates, coverage and the requested operational Windows smoke remain pending. It does not claim kernel-wide digest-conditioned replacement or multi-file atomicity.
