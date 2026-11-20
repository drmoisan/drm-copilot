# Stage C Ledger Replay (after the Phase 3 fix)

Timestamp: 2026-11-07T07-20
Command: SCRATCH/issue-1097-stc-replay.ps1, from a `sh` launcher under SCRATCH: Test-ProcessReductionLedger over Read-ProcessReductionLedger, then for each path the entry's blocks applied in order with Invoke-ProcessReductionRevert to the working text and compared with the text of that path at the parent of the reduction commit, after line-ending normalization
EXIT_CODE: 0
Output Summary: The ledger is valid with one index row and one entry. The entry holds 24 revert blocks over 12 paths. For all 12 paths the reverted text equals the text at the parent of the reduction commit; differing paths number 0. The comparison ref is that parent rather than HEAD because this fix lands after the reduction commit, so the entry still holds the full prior text of the state before the reduction.
