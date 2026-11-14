# Stage R Patch Chain Gate (git level)

Timestamp: 2026-11-07T18-25
Command: sh-launched PowerShell 7 script SCRATCH/r/issue-1097-gate.ps1. GIT_INDEX_FILE under SCRATCH seeded by git read-tree HEAD. For 0006 and then 0001, the index is reset to HEAD and loaded with the FinalText of Invoke-ProcessReductionChain over the newer entries only (each byte-identical derived path holding its source's text; absent paths removed; blobs written with git hash-object -w --no-filters, mode and BOM taken from HEAD), then git apply -R --cached --check of the stored patch with each generated-variant path passed as --exclude. Then the full chain's end state of each source path is compared with the first parent of the 0001 merge commit recorded in 0001 `## Summary` (git cat-file blob), and each differing path is attributed by git log <0001 merge>..HEAD -- <path> to commits whose subjects carry no `reduction:` token.
EXIT_CODE: 0
Output Summary:
  0006 check: newer entries 0 (sub-chain errors 0); index loaded 224 paths, removed 11 absent paths; 50 generated-variant paths excluded; git apply -R --cached --check exit 0.
  0001 check: newer entries 5, 0006 to 0002 (sub-chain errors 0); index loaded 224 paths, removed 11 absent paths; 50 generated-variant paths excluded; git apply -R --cached --check exit 0.
  Excluded generated-variant count: 50 per patch (100 across both checks); the Codex generator re-creates them at revert step 3.
  Full chain: IsValid True, 0 errors.
  End-state comparison with the first parent of the 0001 merge commit: equal 119, attributed 18, unattributed 0. Skipped: 142 derived paths (byte-identical mirrors, bundle copies, and generated variants, re-created by revert steps 2 and 3) and 6 ledger entry files (records, outside every reduction's path set).
  Attributed differences: 14 paths to PR #1108 (issue #1106), 12 of them first listed with the merge of origin/main that brought PR #1108 in and 2 with its MSTest and example-word commits (tdd-red agent, remediate-comments prompt); 4 paths (the three atomic-plan-contract sources and the brief) to the stage E commit that states the process-reduction ledger rule for planners, which has no ledger entry because it adds a rule.
