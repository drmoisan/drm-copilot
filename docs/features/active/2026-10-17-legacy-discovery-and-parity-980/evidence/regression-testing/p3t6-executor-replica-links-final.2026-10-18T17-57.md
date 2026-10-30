# p3t6-executor-replica-links-final

Timestamp: 2026-10-18T17:54:57.308765+00:00

Published: 2026-10-18 17:57:15 UTC

Command: `poetry run python SCRATCH/issue-980-p3t6-executor-replica-links.py`

EXIT_CODE: 0

Output Summary: 7/7 corrected physical-link and source-proof exclusion checks passed; source and fixture hashes stable.

Both ordinary and explicitly resolved imported source records expose 18 resolved outgoing targets. The existing TargetProof.source_payload exclusion succeeds for both. This is direct helper composition, not a full parity-completion claim. Trailing output whitespace is omitted.

```text
actual_loaded_graph_valid: PASS []
explicit_source_selects_imported: PASS
ordinary_source_has_outgoing_links: PASS 18
imported_source_retains_outgoing_links: PASS 18
ordinary_source_proof_cannot_be_target_proof: PASS
imported_source_proof_cannot_be_target_proof: PASS
bound_bytes_unchanged: PASS
{"passed":7,"failed":0,"elapsed_seconds":7.966}
```
