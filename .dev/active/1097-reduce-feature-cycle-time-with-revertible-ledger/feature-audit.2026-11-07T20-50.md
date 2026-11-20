# Feature Audit: Stage R Re-audit, Revertible Ledger Chain (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `2195ec4e01c54aa4fd28181f0b536de7379de4a7`
- **Audit date:** 2026-11-07
- **Reviewer:** feature-review agent

## Scope and Baseline

- Resolved base branch: `main`, supplied by the caller and confirmed by `artifacts/pr_context.summary.txt`, which resolves `origin/main` @ `12825cb0018a001a058aade4f65cc022f0a9ca6e`.
- Merge base: `12825cb0018a001a058aade4f65cc022f0a9ca6e`, the merge commit of PR #1112 (issue #1096), equal to `origin/main` after fetch. `git merge-tree --write-tree origin/main HEAD` exits 0.
- Range audited: `12825cb00..2195ec4e0`, 45 files, 51 commits including the merge `d48ea60ce`.
- Work mode: `full-feature` (`- Work Mode: full-feature` in `issue.md`), so the AC sources are `spec.md` and `user-story.md`.
- Delivery stage: this PR carries stage R per `spec.md` `## Delivery Stages`, so the five `[R]` criteria are owed here. Criteria tagged `[A]` to `[E2]` were delivered by earlier PRs and were re-checked only for regression. Criteria tagged `[F]` to `[J]` are owed by later stages and are not judged in this PR.
- Owner condition applied: each reduction is revertible months later from its entry alone, without `git revert`.
- Cycles judged: `remediation-inputs.2026-11-07T18-49.md` (F1 step 1, RN1 keep-later route, RN2 unreachable check) and `remediation-inputs.2026-11-07T19-38.md` (merge with PR #1112 and the later-landing order).

## Acceptance Criteria Inventory

Stage R criteria, identical item for item in `spec.md` and `user-story.md`:

| ID | Criterion (abridged) |
|---|---|
| R1 | The README states the revert order (newest-first; alone only when no later entry names its paths; later entries found through `## Files Changed`); no entry lists its dependants. |
| R2 | Each stored patch stays in place and is read hunk by hunk as a revert block; the `## Stored Patch` check runs after every later entry touching its paths is reverted; mirrors, bundle copies, and generated Codex variants are left to re-copy and regeneration. |
| R3 | `ProcessReductionChain.Ledger.Tests.ps1` reverts every committed entry newest-first in memory with no exception, skip list, or allowed-error list; its end-state check finds each created path absent and each pre-image of the oldest entry present. |
| R4 | No new structure-checker rule; the chain test is the check and runs on every full CI run in the PowerShell shards. |
| R5 | The chain compares only revert-block and hunk regions: an edit outside every region keeps it green, an edit inside a region fails it until the same commit updates the entry's record, as the `0001` brief-hunk rebase shows. |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| R1 | PASS | README `## Revert Order` states newest-first, the alone condition, and the `## Files Changed` search, and adds the later-landing order and the keep-later route. `0001` step 1 now defers to the README and names no entry. A reviewer search of every entry's `## Revert Steps` for a higher entry number found none. `PRC-README-REVERT-ORDER-STATED` passed in the cycle 3 gate. `0001` `## Partial Revert` names `0006`, as spec D12 requires; it is a partial-revert record, not a revert-order list. |
| R2 | PASS | `Get-ProcessReductionPatchHunk` assigns `Current` as context plus added lines and `Prior` as context plus removed lines. The `0001` and `0006` check sentences name the tree after later entries, and then the entry's own later landings, are reverted. `PRC-CHAIN-SKIPS-DERIVED-PATHS` passed. Reviewer: `git apply -R --check` of the `0006` patch on the live tree exits 0, which is that patch's check tree because no later entry exists. The `0001` patch check on its tree is recorded as exit 0 in `stage-r-cycle3-ledger-gates.2026-11-07T20-31.md` gate (c). The reviewer reproduced the `-StopBefore 0001` sub-chain (`IsValid` true) and found both created files equal to their create hunks in that state. |
| R3 | PASS | Five committed-ledger cases with no skip parameter or filter variable (`PRC-LEDGER-NO-EXCEPTIONS`). `PRC-LEDGER-CHAIN-HOLDS`, `PRC-LEDGER-SUBCHAIN-HOLDS`, and `PRC-LEDGER-END-STATE-RECORDED` passed. The last asserts each created path absent and no end-state pre-image error. The created-path half holds by construction, as the cycle 2 record states, and the criterion's text is still met. The pre-image half can fail (`PRC-CHAIN-END-STATE-PREIMAGES`). Reviewer: `IsValid` true, 0 errors, 298 paths. |
| R4 | PASS | `scripts/dev-tools/ProcessReductionLedger.psm1` is not in the diff, so no checker rule was added. The chain suites are under `tests/scripts`, which the Pester shards scan, and passed in the cycle 3 parallel gate (46 and 5 tests). The ledger lies outside the docs-only CI prefixes, as the prior review recorded. |
| R5 | PARTIAL | Modify hunks and blocks behave as stated. A reviewer control edit inside a `0001` modify hunk gives 1 error, and the out-of-region and rebase cases are pinned by `PRC-CHAIN-IGNORES-EDIT-OUTSIDE-REGIONS` and `PRC-CHAIN-REPORTS-UNLEDGERED-CONTEXT-EDIT`. A create hunk is also a recorded region, but an edit inside it does not fail the chain. A line appended to `tests/scripts/codex-hooks/feature-review-coverage-narrowing-parity.Tests.ps1` gives `IsValid` true, and so does deleting the file. `PRC-CHAIN-CREATED-FILE-ENDS-ABSENT` pins the edited case as valid. PR #1113 made such an edit, and only the item's evidence-only git gate detected it. Finding F1. |

Earlier criteria (`[A]` to `[E2]`): no regression found. The `PRL-*` suites passed unchanged (72, 15, and 4 tests). `PRL-REAL-LEDGER-AGREES` and `PRL-PARTIAL-REVERT-LINKED` passed over the merged ledger.

## Summary

Both remediation cycles meet the owner's condition for the ledger as it stands:

- Every entry's revert steps defer to one stated order.
- The `#1096` landing of `0001` is reverted at its own place in that order.
- Both stored patches reverse-check on their trees.
- The in-memory chain reverts all six entries with no exception.

The `--full-history --no-merges` change to the item's git-level gate corrects a history-simplification artifact of the merge. The reviewer verified it and accepts it.

One gap remains in how the condition is kept over time. The chain does not compare a created file with its create hunk, so an unrecorded edit to one of the two files `0001` creates passes CI. That edit leaves `git apply -R` of the `0001` patch failing as a whole. R5 promises that such an edit fails the chain, so R5 is PARTIAL. The fix is a contained change in `Invoke-ProcessReductionPatchStep` with its tests. Verdict: remediation required (F1, `autonomous`, light path).

### Acceptance Criteria Status

- Source: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` and `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/user-story.md`
- Total AC items: 57 per file
- Checked off (delivered): 34 per file
- Remaining (unchecked): 23 per file
- Items remaining: `[R]` R5 (PARTIAL, F1); the criteria tagged `[F]`, `[G]`, `[H]`, `[I]`, and `[J]`, which later stages owe.

## Acceptance Criteria Check-off

- R1 is evaluated PASS and was checked off by this review in `spec.md` and `user-story.md`, changing only the checkbox.
- R2, R3, and R4 were already checked and are confirmed PASS; they stay checked in both files.
- R5 was checked by the executor and is evaluated PARTIAL, so this review set it back to `- [ ]` in `spec.md` and `user-story.md`, changing only the checkbox. The re-review checks it off once F1 is fixed.
- No new criterion was added and no criterion text was changed.
