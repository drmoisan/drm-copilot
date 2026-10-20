# P6-T1 NIO1 source confirmation

Status: SOURCE_CONFIRMED_FOCUSED_PROOF_PENDING.

Compared the two frozen production files with `c2d7926c02a19ad02689f0111b353807221b8d36`. The strict `_absolute` parser and all existing path-policy definitions are unchanged. The new lexical identity helper is shared by request authorization, optional baseline authorization and required writer baseline checks.

The helper handles equivalent supported Windows drive/UNC spellings, keeps POSIX case sensitivity and rejects POSIX backslash aliases. Invalid or different roots fail closed. Other authority predicates and writer safeguards are unchanged. The fixed lexical work introduces no filesystem I/O or unbounded population. Both files meet the 500-line bound and the existing intent-contract requirements.

No new source finding or open probe remains. This confirmation covers the helper and three local guards; installed end-to-end and cross-platform capability are not established here. No behavior was replayed. The earlier NR1 harness failure and the NIO1 production failure remain distinct and preserved.

Owner test/body-coverage proof, final repair staging, package rebuild and native verification remain pending. P6-T1 is unchecked; counts remain 46/84 tasks and 23/66 acceptance criteria.

Next five: P6-T1, P6-T2, P6-T3, P7-T1, P7-T2.
