# Feature Audit: Stage R Re-audit after the Light Cycle, Revertible Ledger Chain (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `1d1ce4c3e67056c30d381d47bf9e3a922342d9ba`
- **Audit date:** 2026-11-07
- **Reviewer:** feature-review agent

## Scope and Baseline

- Resolved base branch: `main`, supplied by the caller and confirmed by `artifacts/pr_context.summary.txt`, which resolves `origin/main` @ `12825cb0018a001a058aade4f65cc022f0a9ca6e` for head `1d1ce4c3e`.
- Merge base: `12825cb0018a001a058aade4f65cc022f0a9ca6e`, equal to `origin/main` after fetch. `git merge-tree --write-tree origin/main HEAD` exits 0.
- Range audited: `12825cb00..1d1ce4c3e`, 52 files, 54 commits including the merge `d48ea60ce`.
- Work mode: `full-feature` (`- Work Mode: full-feature` in `issue.md`), so the AC sources are `spec.md` and `user-story.md`.
- Delivery stage: this PR carries stage R per `spec.md` `## Delivery Stages`, so the five `[R]` criteria are owed here. Criteria tagged `[A]` to `[E2]` were delivered by earlier PRs and were re-checked only for regression. Criteria tagged `[F]` to `[J]` are owed by later stages and are not judged in this PR.
- Owner condition applied: each reduction is revertible months later from its entry alone, without `git revert`.
- Cycle judged: `remediation-inputs.2026-11-07T20-50.md` (light path, F1: compare a created file with its create hunk), delivered by `4ef2e1f4f` and `1d1ce4c3e`.

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
| R1 | PASS | No README or entry changed in the light cycle. The prior review's evidence stands: README `## Revert Order` states the order, and no entry's `## Revert Steps` names a higher entry. `PRC-README-REVERT-ORDER-STATED` passed in the cycle 4 gate. |
| R2 | PASS | `Get-ProcessReductionPatchHunk` is unchanged. The ledger is unchanged, and `PRC-CHAIN-SKIPS-DERIVED-PATHS` passed in the cycle 4 gate. |
| R3 | PASS | `ProcessReductionChain.Ledger.Tests.ps1` is unchanged: 5 tests, 0 failed in the cycle 4 gate, with no skip list. The reviewer reproduced `IsValid` true, 0 errors, at this head. The new created-file check passes on the live ledger, so the chain still holds with no exception. |
| R4 | PASS | `scripts/dev-tools/ProcessReductionLedger.psm1` is not in the diff. The chain suites are under `tests/scripts` and ran in the parallel Pester gate. |
| R5 | PASS | Modify hunks: a reviewer control edit inside a `0001` modify hunk gives 5 errors naming `0001`. `PRC-CHAIN-IGNORES-EDIT-OUTSIDE-REGIONS` and `PRC-CHAIN-REPORTS-UNLEDGERED-CONTEXT-EDIT` passed. Create hunks: the two probes that the prior review found green now fail. Appending a line to `feature-review-coverage-narrowing-parity.Tests.ps1` gives `IsValid` false with `0001 ... differs from its create hunk`. Setting the file to `$null` gives `IsValid` false with `0001 ... is absent at this step`. A first-line edit and an appended blank line also fail. On `parallel-gate-wording.Tests.ps1`, an appended line fails at `0001`'s turn, after `0006` is reverted. `PRC-CHAIN-REPORTS-STALE-CREATED-FILE` pins the edited, absent, and two unchanged cases. One limit is recorded as non-blocking RN8: a change only to the end-of-file newline is not detected, for any hunk kind. R5 concerns edits to regions of lines, and the inputs prescribed this normalization. |

Earlier criteria (`[A]` to `[E2]`): no regression found. The `PRL-*` suites passed unchanged in the cycle 4 gate (72, 15, and 4 tests).

## Summary

The light cycle resolved F1 as its inputs required. The chain now compares a created file with its create hunk in chain state, so an unrecorded edit to, or deletion of, a file that an entry created fails CI. Before this change, CI passed such an edit while `git apply -R` of the stored patch failed. No README text, spec criterion, entry, or patch changed. Coverage of the new module is 100%, and the parallel Pester gate reports 0 failures.

All five stage R criteria pass. No blocking finding remains. Non-blocking items: RN8 (new, end-of-file newline), RN5 and RN6 (carried README sentences), and the carried Nits. Verdict: PASS. `ci.yml` run 42414817399 on this head is pending-CI and is read by the orchestrator at S9. No stage R criterion depends on it.

### Acceptance Criteria Status

- Source: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/spec.md` and `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/user-story.md`
- Total AC items: 57 per file
- Checked off (delivered): 35 per file
- Remaining (unchecked): 22 per file
- Items remaining: the criteria tagged `[F]`, `[G]`, `[H]`, `[I]`, and `[J]`, which later stages owe.

## Acceptance Criteria Check-off

- R5 is evaluated PASS and was checked off by this review in `spec.md` and `user-story.md`, changing only the checkbox.
- R1, R2, R3, and R4 were already checked and are confirmed PASS; they stay checked in both files.
- No new criterion was added and no criterion text was changed.
