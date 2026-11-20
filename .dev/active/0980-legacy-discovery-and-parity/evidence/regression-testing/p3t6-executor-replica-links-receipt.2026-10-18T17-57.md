# p3t6-executor-replica-links-receipt

Timestamp: 2026-10-18T17:53:02.648461+00:00

Published: 2026-10-18 17:57:15 UTC

Command: `poetry run python SCRATCH/issue-980-p3t6-executor-replica-links.py`

EXIT_CODE: 1

Output Summary: Historical correction-specific closure: 5 passed, 2 failed; failure retained.

This individual receipt materializes the previously grouped command from `other/p3t6-executor-replica-closure-findings.2026-10-18T17-53.md`. The original capture timestamp, command, exit and status output are retained; trailing output whitespace is omitted. No rerun occurred. Raw hashes remain in `p3t6-executor-replica-links.2026-10-18T17-53.json`.

```text
actual_loaded_graph_valid: PASS []
explicit_source_selects_imported: PASS
ordinary_source_has_outgoing_links: PASS 18
imported_source_retains_outgoing_links: FAIL 0
ordinary_source_proof_cannot_be_target_proof: PASS
imported_source_proof_cannot_be_target_proof: FAIL
bound_bytes_unchanged: PASS
{"passed":5,"failed":2,"elapsed_seconds":8.011}
```
