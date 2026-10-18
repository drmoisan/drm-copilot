# P3-T1 initial full mutation plan probes

Timestamp: 2026-10-18 11:24:21 UTC

Command: `poetry run python SCRATCH/issue-980-p3t1-probes.py`

EXIT_CODE: 1

## Output Summary

All 42 behavioral probes passed. They cover POSIX/Windows/UNC path models, creation/replacement/unchanged-byte skipping, repeated dry-run, exact grants, invalid prospective bytes, configuration and production path denial, stale input bytes/sets/identities, link/collision races, truthful partial and uncertain writes, authority invalidation failure, plan tampering, correct/wrong role output and guarded writer sequencing.

The command intentionally returns nonzero because production files changed during the run; the structured companion retains both source-hash sets. These are provisional semantic results, not final source-bound acceptance. The identical bounded probe set must be rerun once final source bytes are frozen. The run used isolated memory stores only and changed no production or test file.
