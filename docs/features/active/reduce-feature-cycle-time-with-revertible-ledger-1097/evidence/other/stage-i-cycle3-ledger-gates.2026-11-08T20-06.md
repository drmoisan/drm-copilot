# Stage I Cycle 3 Ledger Gates

Timestamp: 2026-11-08T20-06
Command: sh SCRATCH/issue-1097-c3-ledger-gates.sh on head 785076762 (the reduction: 0010 regeneration commit): (a) to (d) through SCRATCH/issue-1097-c2-ledger.ps1 (Test-ProcessReductionLedger over Read-ProcessReductionLedger; Invoke-ProcessReductionChain over Read-ProcessReductionChainInput and with -StopBefore for each entry; created paths in FinalText; Get-ProcessReductionLanding for 0010); git apply -R --check of the 0010 patch; (e) git apply --cached -R of the patch on a scratch index of HEAD (GIT_INDEX_FILE under SCRATCH), git write-tree, git diff --quiet origin/main against that tree over the 38 patch paths; (f) git diff --quiet from the merge commit's first parent 8b374f939 to HEAD over entries 0001 to 0009, their patches, and README.md
EXIT_CODE: 0
Output Summary:
  (a) Test-ProcessReductionLedger: IsValid True, 0 errors, 10 index rows.
  (b) Invoke-ProcessReductionChain over all 10 entries: IsValid True, 0 errors. -StopBefore 0001 to 0010: each IsValid True, 0 errors.
  (c) End-state errors 0 (PRC-LEDGER-END-STATE-RECORDED condition); 12 created 0010 paths, 0 present in FinalText.
  (d) Get-ProcessReductionLanding for 0010: `first` only.
  (e) git apply --cached -R exit 0; reversed tree 69d4bf6f3d1e2505efca2850dfc669071df5628e; git diff --quiet against origin/main over the 38 patch paths exit 0.
  (f) Entries 0001 to 0009, their patches, and README.md unchanged since the first parent (exit 0). Only the 0010 entry and its patch changed in the ledger folder. No chain error in 0001 to 0009; no edit under another entry's token.
  git apply -R --check of the regenerated patch on the live tree: exit 0.

## [P3-T2] Regeneration Observations (sh SCRATCH/issue-1097-c3-regen.sh, commit 785076762)

- Patch: `git diff --binary --full-index --no-renames` from pre-0010 tree fe9980d69cfaa190a4ec3ecd84f2dd39f7eb63d4 to HEAD over the 38 paths of `## Files Changed` other than the ledger folder; 38 sections, 0 carriage returns.
- Pre-image blobs: 26 modify sections, each equal to the origin/main blob of its path.
- `+`/`-` line multisets against the cycle 2 patch (SCRATCH/issue-1097-c3-cycle2-0010.patch), pin digest lines excluded: cycle 2 2906 lines, new 2918 lines; the 12 extra lines are the [P2-T1] fix lines only: 2 lines of the fallback sentence in each of the Claude skill and its bundle copy (4) and the 8 lines of `ESS-CLAUDE-FALLBACK-KEEPS-BARRIER`. No other line differs.
- Pin digest lines of the new patch: `-` 5ff9c66f...899c and 2e67dae3...924e (origin/main), `+` 142e42d1...a7c8 and 198cfa0f...eee5 (merged).
- Entry: `## Stored Patch` holds the paragraph beginning "Regenerated in remediation cycle 3"; the Revert Order paragraph keeps #1142's `## Nesting Depth` sections, Agent-tool preflight, and `RE-BASELINED by issue #1138.` paragraph; revert step 4 carries 5ff9c66f58595fa91a1f568a18a0a5aae5d1736a9dd1b13a9bbbab459df7899c and 2e67dae3dd5a015693696125374e341f8c21963f36145bcf5fa8265ff8be924e; step 6 adds `NestingDepthContract.Tests.ps1`; `## Revert Signals` keeps its four bullets; `## Files Changed` gains no path (every fix path already listed).
- Commit subject: `docs(1097): regenerate entry 0010 against the #1142 merged base (reduction: 0010) [P3-T2]`.
