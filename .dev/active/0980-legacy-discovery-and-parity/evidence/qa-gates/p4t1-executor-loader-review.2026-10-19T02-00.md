# P4-T1 loader candidate review

Timestamp: 2026-10-19T02-00 UTC, exact-byte review-record command start.
Command: `poetry run python SCRATCH/issue-980-p4t1-loader-review.py`
EXIT_CODE: 0
Output Summary: The single bounded semantic review has no findings. Policy correction P4T1-LOADER-R1 remains required before final gates. This command binds the reviewed files and executable AST; it does not rerun behavior or claim task acceptance.

Raw review: [p4t1-executor-loader-review.2026-10-19T02-00.json](p4t1-executor-loader-review.2026-10-19T02-00.json). Reviewed source copies remain under `SCRATCH/p4t1-loader-reviewed-candidate/` for documentation-only equivalence confirmation. The exact worker candidate is `p4t1-loader-candidate-manifest.2026-10-19T01-58.json`: loader 496 lines, helper 68 and test 240. The worker's focused proof reports 18 passing cases and helper coverage 22/22 lines, 14/14 branches; final baseline-matched loader coverage and composed first publication remain pending.

The helper requests only four explicit core source groups from schema-valid local, nonimported inventories. It filters to enumerated, captured source/test/documentation categories, deduplicates exact revision/path pairs and preserves existing immutable-reader identity checks. Unreferenced documentation is not automatically pinned. Imported artifacts remain transport-backed. No revision, coverage, mutation or authority rule changed.

P4T1-LOADER-R1: complete typed parameter, return/None, key exception and side-effect contracts for the helper/test functions and nested wrong-pin repository adapter. Add decision comments for file versus nested-source setup and missing/wrong-pin/mismatched-byte flows. This is required by the repository commenting policy; no behavior or added tests are requested. Confirm only executable AST/assertion preservation after repair, then retain this review for the joint P4-T1 acceptance.

The analyzer worker still owns explicit first-publication documentation pre-capture and identical fresh writer captures. The existing mutation freshness and projection replay requirements remain binding. This review does not claim final toolchain completion, full publication proof, or any plan/AC checkoff.
