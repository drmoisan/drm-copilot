# P3-T2 corrected bootstrap-corrected probes

Timestamp: 2026-10-18T13:22:13Z

Command: `poetry run python SCRATCH/issue-980-p3t2-boundaries.py`

EXIT_CODE: 0

## Output Summary

7/7 assertions passed. Source hashes were captured before runtime imports and remained unchanged throughout this command. The specialist has not declared a final production freeze; these are correction checks, not task acceptance. The two corrected commands have distinct init_io.py hashes and retain their own exact bindings.

- PASS: unchanged-bootstrap-postcondition-control.
- PASS: old-directory-identity-substitution-rejected.
- PASS: new-directory-identity-substitution-rejected.
- PASS: bootstrap-capture-rejects-post-open-directory-substitution.
- PASS: invalid-existing-artifact-has-structured-conflict.
- PASS: invalid-existing-profile-has-structured-conflict-with-force.
- PASS: concurrent-profile-collision-reports-known-partial-state.

Exact results, captured UTC time and before/after hashes: [p3t2-executor-bootstrap-corrected.2026-10-18T13-22.json](p3t2-executor-bootstrap-corrected.2026-10-18T13-22.json). The retained 13-13 review receipts preserve the original failed assertions. All scenarios use memory adapters; only SCRATCH diagnostic output and this evidence were written by the verifier. No plan or AC checkbox changed.
