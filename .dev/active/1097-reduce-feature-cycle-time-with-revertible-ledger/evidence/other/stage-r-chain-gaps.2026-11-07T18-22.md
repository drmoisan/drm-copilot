# Stage R Chain Gaps

Timestamp: 2026-11-07T18-22
Command: sh-launched PowerShell 7 script SCRATCH/r/issue-1097-chain.ps1 (imports scripts/dev-tools/ProcessReductionChain.psm1, calls Read-ProcessReductionChainInput -RepositoryRoot <worktree>, then Invoke-ProcessReductionChain over the result; not a test run); first run 2026-11-07T18-20, final run 2026-11-07T18-22
EXIT_CODE: 0
Output Summary:
  First run: Read-ProcessReductionChainInput read 6 entries, 2 stored patches, and 285 paths; Invoke-ProcessReductionChain returned IsValid False with 1 error:
    0001-parallel-only-test-gates.md: .claude/skills/execution-environment/SKILL.md: Current text of the hunk at +106 of '.claude/skills/execution-environment/SKILL.md' was not found.
  This is the named gap of `## Known Gaps` (RF1): it names entry 0001 and the brief. No other gap was reported: every block of entries 0005, 0004, 0003, and 0002, every hunk of every non-derived path of the 0006 and 0001 patches except this one, and the block checks of the two patch entries reverted cleanly.
  Gap 1 fix (entry 0001, .claude/skills/execution-environment/SKILL.md): the hunk's context lacked the planning-contract-wording.Tests.ps1 line that a stage E commit with no ledger entry added to the brief's contract-test list. SCRATCH/r/issue-1097-rebase-brief.ps1 took the 0001 post-image of the brief as the chain state after entries 0006 to 0002 were reverted (that sub-chain reported 0 errors), reverted the four applying hunks and the failing hunk with the line inserted in both images, and git diff --no-index --binary --no-renames of the two images regenerated the section (the line becomes trailing context of the hunk at +106; the next two hunk headers move down one line; the index line changes). SCRATCH/r/issue-1097-splice.ps1 spliced that section into the 0001 patch for the brief and its five copies (.agents and .github skill copies and the three bundle copies), whose sections were identical apart from the path: 6 sections replaced, 233 of 239 split pieces byte-identical, 238 sections kept, no CR. Committed alone with `reduction: 0001`. The brief itself is not edited.
  Entry 0001 `## Stored Patch` gains one paragraph recording this rebase, committed alone with `reduction: 0001`; it lies outside every hunk region of the 0006 patch.
  PRL-PARTIAL-REVERT-LINKED targets (the 0001 index row, the 0001 `## Partial Revert` section, and the 0006 `## Summary` sentence naming entry 0001) are not edited.
  Final run: 6 entries, 2 stored patches, 285 paths; IsValid True; error count 0.
