# P3-T1 report-view mutation boundary

Timestamp: 2026-10-18 11:12:43 UTC

Command: `poetry run python SCRATCH/issue-980-p3t1-report-view-probe.py`

EXIT_CODE: 1

## Output Summary

A valid recomputed JSON coverage report and its Markdown view, each with an exact coverage-report kind/ID/path grant and absent-original precondition, are rejected with `MUTATION_IDENTITY: Proposed artifact kind/ID differs`. The accepted loader recognizes the Markdown file as a derived documentation view rather than a structured artifact; the mutation identity check currently requires a parsed artifact for every report.

Both production hashes are stable during the run. [Structured output](p3t1-executor-report-view.2026-10-18T11-12.json) preserves those hashes and the actual failure. The shared mutation boundary must support the accepted report-view output contract while retaining exact kind/path/ID validation; arbitrary opaque bypass is not a correction.
