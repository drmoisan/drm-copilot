# Stage I Cycle 1 Ledger Gates

Timestamp: 2026-11-08T18-34
Command: sh SCRATCH/issue-1097-c1i-ledger.sh (PowerShell 7 with SCRATCH/issue-1097-c1i-ledger.ps1: Test-ProcessReductionLedger over Read-ProcessReductionLedger; Invoke-ProcessReductionChain over Read-ProcessReductionChainInput and with -StopBefore for each stored-patch entry; created-path check on FinalText; Get-ProcessReductionLanding for 0010; then git apply -R --check of the 0010 patch) and sh SCRATCH/issue-1097-c1i-gates-ef.sh (git apply --cached -R of the 0010 patch on a scratch index of HEAD, git diff --quiet of the result against the P3-T1 tree over the patch paths; git diff --name-only from the merge commit's first parent to HEAD over entries 0001 to 0009 and their patches), on the head after the reduction: 0010 regeneration commit
EXIT_CODE: 0
Output Summary:
  (a) Test-ProcessReductionLedger: IsValid True, 0 errors, 10 index rows. PASS
  (b) Invoke-ProcessReductionChain over 10 entries: IsValid True, 0 errors. -StopBefore 0001, 0006, 0008, 0009, 0010: each IsValid True, 0 errors. PASS
  (c) End-state errors: 0 (PRC-LEDGER-END-STATE-RECORDED condition); 0010 created paths 12, present in FinalText 0. PASS
  (d) Get-ProcessReductionLanding for 0010: first only, matching README `## Revert Order` (no `### Later Landing:` heading). PASS
  (e) git apply --cached -R of the patch on a scratch index of HEAD: exit 0; the resulting tree equals the P3-T1 tree on every patch path (git diff --quiet exit 0). Outside the patch paths the two trees differ only in the 0010 entry, the 0010 patch, the P3-T1 evidence file, and the plan check-offs, all written after P3-T1 by design. PASS
  (f) Entries 0001 to 0009 and their patches changed since the merge commit's first parent: 0 files. PASS
  git apply -R --check of the 0010 patch on the live tree: exit 0.
  No chain error in 0001 to 0009; no fix under an older token; README unchanged; no exception list and no skip.
