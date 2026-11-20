# P3-T1 initialized report-directory positive

Timestamp: 2026-10-18 11:24:21 UTC

Command: `poetry run python SCRATCH/issue-980-p3t1-report-view-probe.py --existing-report-root`

EXIT_CODE: 0

## Output Summary

The exact coverage-report JSON and Markdown pair is accepted when the configured reports directory already exists. The memory-only positive preserves stable source hashes in its structured companion. This confirms the corrected view identity behavior and isolates the earlier first-report failure to the exact missing reports-root digest entry. No production files changed in this verification step.
