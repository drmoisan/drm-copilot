# Stage I Cycle 1 Pre-Merge Ledger State

Timestamp: 2026-11-08T18-23
Command: sh SCRATCH/issue-1097-c1i-ledger.sh on the branch head before the merge (launcher runs PowerShell 7 with SCRATCH/issue-1097-c1i-ledger.ps1: Test-ProcessReductionLedger over Read-ProcessReductionLedger; Invoke-ProcessReductionChain over Read-ProcessReductionChainInput, then with -StopBefore for each stored-patch entry; then git apply -R --check of docs/engineering/process-reductions/patches/0010-early-dependent-starts.patch and git cat-file -e of every modify-section pre-image blob id)
EXIT_CODE: 0
Output Summary:
  Test-ProcessReductionLedger: IsValid True, 0 errors, 10 index rows.
  Invoke-ProcessReductionChain (10 entries): IsValid True, 0 errors; end-state errors 0.
  -StopBefore 0001, 0006, 0008, 0009, 0010: each IsValid True, 0 errors.
  0010 created paths: 12; present in FinalText: 0.
  Get-ProcessReductionLanding for 0010: first only.
  git apply -R --check of the 0010 patch: exit 0.
  0010 patch index lines: abbreviated 9-character blob ids; 25 modify-section pre-image ids, 0 missing (each resolves with git cat-file -e).
  This is the state the regeneration starts from.
