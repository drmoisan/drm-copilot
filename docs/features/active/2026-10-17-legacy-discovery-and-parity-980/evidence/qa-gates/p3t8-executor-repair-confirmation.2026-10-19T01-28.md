# P3-T8 bounded repair confirmation

Timestamp: 2026-10-19T01-28 UTC, captured when the confirmation command began.
Command: `poetry run python SCRATCH/issue-980-p3t8-confirm-repair.py`
EXIT_CODE: 0
Output Summary: The single consolidated review findings are resolved on the five frozen repaired files. Both excluded-integrity cases now fail before reading the excluded or requested payload. All 34 prior top-level test/fixture/helper definitions and 14 comment tokens are preserved across the approved relocation. Only the two reviewed production predicates change executable behavior; the model module is documentation-only.

Raw bindings and focused outcomes: [p3t8-executor-repair-confirmation.2026-10-19T01-28.json](p3t8-executor-repair-confirmation.2026-10-19T01-28.json). Original failed proof: [candidate review](p3t8-executor-candidate-review.2026-10-19T01-21.md). Repaired candidate: [worker freeze](p3t8-review-fixed-freeze.2026-10-19T01-26.json).

`_profile_allows` now checks configured roots and ancestor exclusions for every manifest/member integrity input. `_eligible` adds the separate output selection and snapshot boundary. The transport diagnostics now name configured read scope. The narrow AST comparison permits only those two predicate changes and that exact diagnostic rename. Other reader functions and all original test assertions/decorators retain identical executable ASTs. The two nested fake-reader docstrings now identify typed inputs, return/failure behavior and isolated state changes, and ReadSelection describes read grants.

The parent-approved `test_source_read_snapshot_scope.py` receives existing snapshot cases and the one new parametrized exclusion regression (two cases). No original assertion or comment was removed. Source/test sizes are 423, 481, 364, 415 and 283 lines. All definitions have docstrings and every explicit loop retains its intent comment. The focused independent confirmation executes only the same two in-memory defect reproductions; it does not replay the full 127-case suite or any accepted lower-layer suite.

The original review is retained for unchanged behavior. The worker reports 127 passing candidate cases, 409/409 statements, 176/176 branches and 43 measured ranges at 100%; these remain candidate evidence until the final ordered seven-stage loop is complete. Checked WIP preservation is ready for the parent. P3-T8 and feature acceptance checkboxes remain unchanged: 31/84 tasks and 11/66 criteria.
