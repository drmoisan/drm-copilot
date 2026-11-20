# Stage C Ledger Replay

Timestamp: 2026-11-07T07-03
Command: SCRATCH/issue-1097-stc-replay.ps1, from a `sh` launcher under SCRATCH: Test-ProcessReductionLedger over Read-ProcessReductionLedger, then for each path the entry's blocks applied in order with Invoke-ProcessReductionRevert to the working text and compared with the text of that path at HEAD after line-ending normalization
EXIT_CODE: 0
Output Summary: The ledger is valid with one index row and one entry. The entry holds 20 revert blocks over 12 paths. For all 12 paths the reverted text equals the text at HEAD; differing paths number 0. HEAD at the time of this run is the guard commit plus evidence. The Codex generator `--check` exited 0, and each of the eight bundle copies compares byte-identical to its source.
