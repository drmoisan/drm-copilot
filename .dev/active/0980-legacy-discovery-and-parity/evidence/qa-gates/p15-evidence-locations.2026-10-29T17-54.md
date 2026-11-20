# P15-T2 evidence-location validator after removing the P7-T3 residue

Timestamp: 2026-10-29T17-54
Command: poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
EXIT_CODE: 0
Output Summary: the validator printed no finding and exited 0. Before the run, the two gitignored, untracked residue files that review finding R2 reported were deleted: `artifacts/coverage/issue-980-p7t3-coverage.json` and `artifacts/coverage/issue-980-p7t3-devtools-coverage.json`. Nothing was moved, because their content is superseded by the P14-T10 per-file comparison. `git ls-files -- artifacts/coverage/issue-980-p7t3-coverage.json artifacts/coverage/issue-980-p7t3-devtools-coverage.json` prints nothing for either path (zero lines), so no tracked file was affected. `artifacts/coverage/` is empty after the deletion.

## Deleted paths

- artifacts/coverage/issue-980-p7t3-coverage.json (deleted; `git ls-files` prints nothing)
- artifacts/coverage/issue-980-p7t3-devtools-coverage.json (deleted; `git ls-files` prints nothing)
