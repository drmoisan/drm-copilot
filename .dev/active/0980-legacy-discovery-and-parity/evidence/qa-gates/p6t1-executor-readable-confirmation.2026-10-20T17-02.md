# P6-T1 preservation evidence qualification

Status: **READY_FOR_COMBINED_PRESERVATION_COMMIT**. Task acceptance remains pending.

All 43 normalized Markdown views reconstruct exactly from their archived originals using the two documented byte substitutions. Every original matches the unchanged 16:48 manifest. The other 274 non-self staged bindings and all 10 retained committed references remain unchanged, including all eight gateway source/test streams and 43 raw sidecars.

The transform changes CRCRLF/CRLF/lone CR to LF and removes terminal spaces/tabs. UTF-8 and non-whitespace bytes are preserved. All 43 current views pass the bounded whitespace checks. The original staging diagnostic is retained losslessly in the confirmation JSON.

The updated manifest supersedes current-byte staging identities only. It preserves the historical manifest, both owner qualification artifacts and the existing source/test/evidence closure. The new manifest lists itself and reports its own hash externally.

No source review, test execution, coverage reconciliation, staging or checkpoint change occurred. Core remains unaccepted WIP. Subsequent core continuation and native preparation remain excluded.

Confirmation: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p6t1-executor-readable-confirmation.2026-10-20T17-02.json`; SHA-256 `b487557d69e9603a8d5e87b28269ead4399e741e788685b71d94bfec227f4f91`.

Plan counts remain 46/84 tasks and 23/66 source ACs. Current phase: P6. Next five: P6-T1, P6-T2, P6-T3, P7-T1, P7-T2.
