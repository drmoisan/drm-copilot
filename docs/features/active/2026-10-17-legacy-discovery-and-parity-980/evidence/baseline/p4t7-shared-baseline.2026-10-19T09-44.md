# P4-T7 shared baseline

Timestamp: 2026-10-19T09-44
Command: poetry run python SCRATCH/issue-980-p4t7-shared-baseline.py
EXIT_CODE: 0
Output Summary: PASS; all ten approved paths are absent, and all 62 accepted predecessor streams remain unchanged.

Accepted commit: `28b03c185f32fdeb9ccfdafd1bb7decce959161d`. Existing ordered format, lint, type, unit, contract and native proof is referenced through the immutable P4-T6 handoff. New paths have no prior executable lines. No suite was replayed.

The paired JSON binds exact working/index/commit streams and actual Git attributes, preserving CRLF-to-LF distinctions. Native routing, launch authority and provenance were rechecked before this baseline; the current C4 profile matches its durable receipt.

The lead owns the shared input contract and integration only; the three format parser/test pairs remain reserved and unreleased. This baseline does not authorize policy, registry, schema, dependency or predecessor changes.
