# P3-T1 prior report-projection invariant verification

Timestamp: 2026-10-18 11:31:13 UTC

Command: `poetry run python SCRATCH/issue-980-p3t1-report-invariants.py`

EXIT_CODE: 0

## Output Summary

Nine focused checks pass against stable `validation_inputs.py` SHA-256 `147b363fbf5f1041ce79dc40e3b9c10d1ba3aab41be007a9b06cce8df8b4cda2`. The actual loader confirms that creating the reports directory preserves the semantic report digest while changing the complete snapshot digest. Pure captured-input checks confirm exact exclusion of the report root, its missing descendants and view bytes; neighboring path prefixes, missing source inputs and actual source bytes remain digest-relevant.

The [structured result](p3t1-executor-report-invariants.2026-10-18T11-31.json) lists every assertion. This is the bounded prior-invariant verification authorized for the P3-T1 prerequisite correction; it does not rerun or rewrite historical Phase 2 acceptance. All stores and captures are in memory. Final owner gate/coverage evidence remains required.
