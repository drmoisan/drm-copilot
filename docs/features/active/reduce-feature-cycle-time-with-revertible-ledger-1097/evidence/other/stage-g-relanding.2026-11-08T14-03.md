# Stage G Re-landing Record

Timestamp: 2026-11-08T14-03
Command: git apply -R docs/engineering/process-reductions/patches/0009-less-evidence.patch; git rm of entry 0009 and its patch; README index row 0009 removed; commit. Then git checkout c3ac98596 -- <the 53 patch paths, the entry, its patch, README.md>; one history sentence corrected in entry 0009; commit.
EXIT_CODE: 0
Output Summary: The less-evidence reduction now lands whole in one commit. Commit 13a1340ac withdraws the split landing; commit 38517b6b3 (subject token `reduction: 0009`) holds the 53 reduction paths, entry 0009, its README index row, and its stored patch: 56 paths. The tree after 38517b6b3 differs from c3ac98596 only by the corrected history sentence in entry 0009. After the commit, `Test-ProcessReductionLedger` is valid with 9 rows, the revert chain reports 0 errors, and `git apply -R --check` of the 0009 patch exits 0. No history was rewritten and no forced push was made.

## Why

A session crash put most of the reduction's edits into the checkpoint commit `c58c16243`, separate from entry 0009, which was first committed as `fe81a1118` and amended in wording by `3681735fc`. The owner's condition is that each reduction is its own commit with its ledger entry in that same commit. The split landing did not meet it, so it was withdrawn and re-landed whole.

## Supersedes

The stage G ledger-replay record and the self-review were written before the re-landing. Where they name `fe81a1118` as the reduction commit, the reduction commit is `38517b6b3`. The commits `fe81a1118`, `3681735fc`, and `38517b6b3` all carry the `reduction: 0009` token; only `38517b6b3` holds the whole reduction with its entry.

## Carried to the next records commit

- Entry 0009's history sentence names the crash checkpoint but not `fe81a1118`; the next records commit names it (review finding CR1).
- Entry 0008 still reads `Merge commit: pending (PR #1123)`; PR #1123 merged as `e33635c14b55277d38caca52d6167b1d352f392e` (review finding CR3).
