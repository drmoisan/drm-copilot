# Stage R Cycle 2 Ledger Gates

Timestamp: 2026-11-07T19-38
Command: sh-launched PowerShell 7 scripts stored under SCRATCH, run from the worktree root: (a) Read-ProcessReductionChainInput then Invoke-ProcessReductionChain; (b) git apply -R --check of docs/engineering/process-reductions/patches/0006-test-suite-baseline-restored.patch on the live tree; (c) the git-level chain gate of [P1-T10] in plan.2026-11-07T12-03.md, rebuilt from that task's text and the Command field of the greatest stage-r-patch-chain-gate.*.md (scratch GIT_INDEX_FILE seeded by git read-tree HEAD, git apply -R --cached --check of the 0006 and 0001 patches over the newer entries' chain end state, then end-state comparison with the first parent of the 0001 merge commit); (d) Get-ProcessReductionSection of the 0001 entry for Revert Steps, searched for the pattern 000[2-6]
EXIT_CODE: 0
Output Summary:
  (a) Chain over the committed ledger: 6 entries, 2 patches, 285 paths; IsValid True, 0 errors.
  (b) git apply -R --check of the 0006 patch on the live tree: exit 0.
  (c) Git-level gate: 0006 check (newer entries 0, sub-chain errors 0) git apply -R --cached --check exit 0; 0001 check (newer entries 5, 0006 to 0002, sub-chain errors 0) exit 0; 50 generated-variant paths excluded per patch (100 total). Full chain IsValid True, 0 errors. End-state comparison: equal 119, attributed 18, unattributed 0; skipped 142 derived paths and 6 ledger entry files.
  (d) The 0001 Revert Steps section (2198 characters) holds 0 matches of 000[2-6]; the pre-change text contained 0006.
  Comparison with the Phase 0 baseline reference (119, 18, 0): identical counts; no regression. All four gates pass and the unattributed count is 0.
