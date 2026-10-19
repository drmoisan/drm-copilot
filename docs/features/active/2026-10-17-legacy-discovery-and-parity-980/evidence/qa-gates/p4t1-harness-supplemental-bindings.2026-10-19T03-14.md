# P4-T1 supplemental harness evidence binding

Timestamp: 2026-10-19T03-14
Command: poetry run python SCRATCH/issue-980-p4t1-harness-supplement.py
EXIT_CODE: 0
Output Summary: PASS. All seven snapshots match accepted receipt hashes. Four stage unchanged; three have exactly one final CRLF normalized to LF by Git. Their raw originals are preserved byte-for-byte under session SCRATCH. No implementation, test, harness, checkpoint, plan, acceptance-criteria or Git changes were made.

This supplements accepted commit `bba0e8b1f2ee743655587dbf0fc703b33b6885bc`. The fresh `atomic_execution_p4t1_harnesses` routing receipt, current profile and native attestation agree on `atomic-executor-c4`, `gpt-6-astra` / `max`. The machine receipt records every exact accepted hash, receipt field, original-preservation reference and expected staged SHA-256/Git blob ID.

| Snapshot | Representation in Git | Expected staged blob |
| --- | --- | --- |
| p4t1-architecture-checker-before.2026-10-19T02-41.txt | none; exact byte identity | `eb7591228e16201e7bcc6289fedebad043dad2ad` |
| p4t1-architecture-checker-after.2026-10-19T02-41.txt | none; exact byte identity | `aa9a4796aea6c73f795c195831cc72c792bbf588` |
| p4t1-native-failed-harness.2026-10-19T02-46.txt | final CRLF to LF only | `4a396ee85053c7454ba35836bc8a2c0654055f10` |
| p4t1-native-corrected-harness.2026-10-19T02-47.txt | final CRLF to LF only | `918cc966de580a0bb10078d75b905c8dc3d3169f` |
| p4t1-final-final-harness.2026-10-19T02-55.txt | none; exact byte identity | `9524ccd1fecd07079f9c0bd8dfba9d3b20a35930` |
| p4t1-final-architecture-harness.2026-10-19T02-55.txt | none; exact byte identity | `aa9a4796aea6c73f795c195831cc72c792bbf588` |
| p4t1-final-native-harness.2026-10-19T02-55.txt | final CRLF to LF only | `918cc966de580a0bb10078d75b905c8dc3d3169f` |

The current Git attributes are `text=auto`, `eol=lf`. Read-only `git hash-object --no-filters` and `git hash-object --path` confirm the raw and filtered representations. Each of the three native snapshots has exactly one carriage return, immediately before its final newline. No other byte differs. Syntax and AST identity are unchanged by that exact mapping; no executable behavior was rerun.

The architecture-before snapshot remains an explicitly documented inverse-patch reconstruction; no original pre-edit digest was available. That existing provenance limitation is preserved. Architecture-after equals the final architecture snapshot; native-corrected equals the final native snapshot. The native-failed snapshot retains the rejected fixture.

The first hygiene predicate falsely interpreted the `y:` suffix in a `Summary` string followed by an escaped newline as a drive path. That finding is rejected as checker overreach. The subsequent anchored AST string-literal path check found no host-specific paths. The three CRLF findings are real Git-representation differences, now explicitly bound above.

Existing accepted receipts and all seven harness files remain unchanged. The parent may stage the seven snapshots plus this paired receipt, verify the expected blob IDs, and commit the supplement. This does not change P4-T1 acceptance or release a successor task. Plan remains 33/84; AC remains 12/66. Phase 4 next tasks: P4-T2, P4-T3, P4-T4, P4-T5 and P4-T6.
