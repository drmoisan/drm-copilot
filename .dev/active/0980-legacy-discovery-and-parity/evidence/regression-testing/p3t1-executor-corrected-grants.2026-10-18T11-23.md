# P3-T1 grant and capture regression verification

Timestamp: 2026-10-18 11:23:53 UTC

Command: `poetry run python SCRATCH/issue-980-p3t1-initial-probes.py 'Opaque payload grant cannot create a structured evidence record' 'Directory enumeration order is semantically irrelevant'`

EXIT_CODE: 0

## Output Summary

Both corrected cases pass on stable source bytes. A payload grant cannot create a differently identified structured evidence record, and reordering identical complete directory child lists preserves the snapshot digest. The structured companion records the exact source hashes and results. Final task acceptance remains pending the complete ordered gates and final source binding.
